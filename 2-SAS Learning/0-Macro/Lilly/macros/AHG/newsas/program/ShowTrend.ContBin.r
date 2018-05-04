ShowTrend.ContBin<-function(mean.TR=0.4,                # mean/proportion for treatment arm
                            mean.CO=0.2,                # mean/proportion for control arm
                            sigma=1,                    # SD, only for continuous case 
                            power=0.80,                 # probability of show trend
                            ratio=1,                    # sample size allocation ratio TR/CO 
                            rho=0.5,                    # effect size retaintion
                            n.iteration=10000,
                            alpha.global=0.05,          # global study type I error
                            beta.global=0.1,            # global study type II error
                            conditional=FALSE,          # condition on global positive or not
                            type="Cont",                # type of outcome: continuous/binomial (Cont/Binom)
                            size.china.TR=0,            # specify how many chinese pts (TR/CO) in global cohort
                            size.china.CO=0,            # if both are zero, then a separate bridging study
                            MRCT=FALSE,                 # if true, all Chinese pts in global cohort. no me2 part, no bridging part
                            effect.global.fix=FALSE     # compare with fixed global effect
){
  
  ##################################################################################### 
  # calculate sample size in Global study
  
  # calculate standard deviation for binomial data
  if (type=="Binom") sigma<-sqrt((mean.TR*(1-mean.TR)+mean.CO*(1-mean.CO))/2) 
  
  # sample size for global study - for both continuous and binary cases
  N.global<-(ratio+1)^2/ratio*(qnorm(1-alpha.global/2)+qnorm(1-beta.global))^2*sigma^2/(mean.TR-mean.CO)^2
  
  # a function generating data set
  #------------------------------------------------------------------#

    # a function of generating data set
    dataset<-function(totalN){
      N.CO<-round(totalN/(1+ratio),0)
      N.TR<-totalN-N.CO    
      # Create group indicator
      x<-c( rep(1,N.TR) , rep(0,N.CO) )
      # Generate group 1 and group 2 complete survival times.
      
      if (type=="Binom") {
        y1<-rbinom(N.TR,1,mean.TR)
        y2<-rbinom(N.CO,1,mean.CO)
      }
      else {
        y1<-rnorm(N.TR,mean.TR,sd=sigma)
        y2<-rnorm(N.CO,mean.CO,sd=sigma)
      }
      y<-c(y1,y2)
      
      data<-data.frame(y,x)
      return(data)
    }
  #------------------------------------------------------------------#
    
    MM<-NULL
    # X lists 10 samples from the defined range
    X<-as.integer(seq(max(round(N.global*0.10,0),size.china.TR+size.china.CO+2),
                      max(round(N.global*0.4,0),size.china.TR+size.china.CO+20),length.out=10))
  
  #####################################################################################  
  # for unconditional case
  if (conditional==FALSE){
    if (MRCT==TRUE){
    f1<-(qnorm(power))^2/((qnorm(1-alpha.global/2)+qnorm(1-beta.global))^2*(1-rho)^2+
                            (qnorm(power))^2*(2*rho-rho^2))
    samplesize=N.global*f1
    }
    if (MRCT==FALSE){
      for (total.N in X){
        res<-NULL
        for (i in 1:n.iteration){   
          
          data.global<-dataset(N.global)
          out<-lm(y~x,data=data.global)
          effect.global<-summary(out)$coefficients["x","Estimate"]
          P<-summary(out)$coefficients["x","Pr(>|t|)"]      
          
          a<-sum(data.global$x==1)
          b<-sum(data.global$x==0)

          n.c1<-sample(1:a,size=size.china.TR)
          n.c2<-sample((a+1):(a+b),size=size.china.CO)
          data.c1<-data.global[c(n.c1,n.c2),]        
          data.c2<-dataset(total.N-size.china.TR-size.china.CO)
          data.china<-data.frame(rbind(data.c2,data.c1))
          
          out<-lm(y~x,data=data.china)
          effect<-summary(out)$coefficients["x","Estimate"]        
          
          if (effect.global.fix==TRUE){
            effect.global=mean.TR-mean.CO
          }
          
          res<-c(res,as.numeric(effect>rho*effect.global))
        }    
        #  mean(res) # the power of consisitency
        MM<-c(MM,mean(res))  
      }
      #--------------------------------------------------------------------#
      # plot with smooth curve, may not work for small data
      lo <- loess(X~MM)
      samplesize<-predict(lo,power)
      plot(MM,X,type='n',ylab="Total.N",xlab="Power of consistency")
      lines(MM,predict(lo), col='red', lwd=2)
      lines(x=c(power,power), y=c(samplesize,0), lty="solid",lwd=2)
      lines(x=c(0,power),y=c(samplesize,samplesize), lty="solid",lwd=2)
      text(power,samplesize,paste("(",power,", ",round(samplesize,1),")"
                                  ,sep=""),offset=1,pos=4) 
    }
  }
  ##################################################################################### 
  # for conditional case
  if (conditional==TRUE) {
    # try different china sample sizes to find out the sample size corresponding the specifed power
    for (total.N in X){
      res<-NULL
      for (i in 1:n.iteration){   
        
        data.global<-dataset(N.global)
        out<-lm(y~x,data=data.global)
        effect.global<-summary(out)$coefficients["x","Estimate"]
        P<-summary(out)$coefficients["x","Pr(>|t|)"]      
        
        a<-sum(data.global$x==1)
        b<-sum(data.global$x==0)
        
        if (MRCT==TRUE){
          size.china.CO<-round(total.N/(1+ratio),0)
          size.china.TR<-total.N-size.china.CO
          n.c1<-sample(1:a,size=size.china.TR)
          n.c2<-sample((a+1):(a+b),size=size.china.CO)
          data.china<-data.global[c(n.c1,n.c2),]        
        }
        if (MRCT==FALSE){
          n.c1<-sample(1:a,size=size.china.TR)
          n.c2<-sample((a+1):(a+b),size=size.china.CO)
          data.c1<-data.global[c(n.c1,n.c2),]        
          data.c2<-dataset(total.N-size.china.TR-size.china.CO)
          data.china<-data.frame(rbind(data.c2,data.c1))
        }
        
        out<-lm(y~x,data=data.china)
        effect<-summary(out)$coefficients["x","Estimate"]     
        
        if (effect.global.fix==TRUE){
          effect.global=mean.TR-mean.CO
        }
        
        if (P<=alpha.global) {
          res<-c(res,as.numeric(effect>rho*effect.global))
        }
      }    
      #  mean(res) # the power of consisitency
      MM<-c(MM,mean(res))  
    }
    #--------------------------------------------------------------------#
    # plot with smooth curve, may not work for small data
    lo <- loess(X~MM)
    samplesize<-predict(lo,power)
    plot(MM,X,type='n',ylab="Total.N",xlab="Power of consistency")
    lines(MM,predict(lo), col='red', lwd=2)
    lines(x=c(power,power), y=c(samplesize,0), lty="solid",lwd=2)
    lines(x=c(0,power),y=c(samplesize,samplesize), lty="solid",lwd=2)
    text(power,samplesize,paste("(",power,", ",round(samplesize,1),")"
                                ,sep=""),offset=1,pos=4)  
  }
  #####################################################################################
  out<-as.data.frame(c(samplesize,power,N.global,samplesize/N.global))
  rownames(out)<-c("Sample size",
                   "Power of consistency","Global sample size","percentage")
  out<-round(out,3)
  colnames(out)<-"EST"
  out
}
####################### END ###########################################################