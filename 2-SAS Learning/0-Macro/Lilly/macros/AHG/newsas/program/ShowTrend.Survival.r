ShowTrend.Survival<-function(Median.TR,             # median survival time for Treatment arm
                             Median.CO,             # median survival time for Treatment arm
                             power=0.80,            # probability of show trend
                             ratio=1,               # sample size allocation ratio TR/CO    
                             censorRate=0.2, 
                             n.iteration=10000,
                             rho=0.5,               # effect size retaintion
                             alpha.global=0.05,
                             beta.global=0.1,
                             size.china.TR=0,       # specify how many chinese pts (TR/CO) in global cohort
                             size.china.CO=0,       # if both are zero, then a separate bridging study
                             conditional=FALSE,     # condition on global positive or not
                             MRCT=FALSE,            # if true, all Chinese pts in global cohort. no me2 part, no bridging part
                             effect.measure=2,      # 1: 1/HR-1 2: logHR
                             HR.global.fix=FALSE    # compare with fixed global HR
){
  require(survival)
  require(rootSolve)
  
  MM<-NULL
  m1<-Median.TR/log(2)
  m2<-Median.CO/log(2)
  # calculate the cutoff time to generate censor
  fn<-function(cutoff){
    exp(-1/m1*cutoff)+exp(-1/m2*cutoff)-censorRate*2
  }
  cutoff<-rootSolve::uniroot.all(fn,c(0,100))
  ##################################################################################### 
  # calculate sample size in Global study
  N.global<-((qnorm(1-alpha.global/2)+qnorm(1-beta.global))*(Median.TR/Median.CO+1)/
               (Median.TR/Median.CO-1))^2/(1-censorRate)
  
  # generate data set
  dataset<-function(totalN){
    N.CO<-round(totalN/(1+ratio),0)
    N.TR<-totalN-N.CO    
    # Create group indicator
    x<-c( rep(1,N.TR) , rep(0,N.CO) )
    # Generate group 1 and group 2 complete survival times.
    y1<-rexp(N.TR, rate=1/m1)
    y2<-rexp(N.CO, rate=1/m2)
    y<-c(y1,y2)
    
    cen<-rep(cutoff,totalN)
    # Create observed censored survival time
    ycen<-pmin(y,cen)
    
    # Create censoring indicator, 
    # 0 for censored (y>cen), 1 for complete (y<=cen)
    censored<-as.numeric(y>cen)
    status<-1-censored
    data<-data.frame(ycen,status,x)
    return(data)
  }
  #####################################################################################
  # a function to calculate effect. 2 options
  effect.function<-function(ff){
    if (effect.measure==1){
      return(1/ff-1)
    }
    if (effect.measure==2){
      return(-log(ff))
    }
  }
 ####################################################################################### 
  # for lgHR, unconditional case and MRCT, a closed form could be derived
  if (effect.measure==2 & conditional==FALSE & MRCT==TRUE){
        f1<-(qnorm(power))^2/((qnorm(1-alpha.global/2)+qnorm(1-beta.global))^2*(1-rho)^2+
                                (qnorm(power))^2*(2*rho-rho^2))
        samplesize=N.global*f1
  }
  else {
  # for other cases, the closed form is not ready yet. simulation is used
  #---------------------------------------------------------------------------#
  # X lists 10 samples from the defined range
  X<-as.integer(seq(max(round(N.global*0.15,0),size.china.TR+size.china.CO+2),
                    max(round(N.global*0.6,0),size.china.TR+size.china.CO+20),length.out=10))
  
  for (total.N in X){
    res<-NULL
    for (i in 1:n.iteration){
      data.global<-dataset(N.global)
      out<-coxph(Surv(data.global$ycen,data.global$status)~data.global$x)
      HR.global<-exp(out$coefficients)
      P<-summary(out)$coefficients[5]
      
      
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
      
      out<-coxph(Surv(data.china$ycen,data.china$status)~data.china$x)
      HR<-exp(out$coefficients)        
      
      if (HR.global.fix==TRUE) {
        HR.global<-Median.CO/Median.TR
      }
      
      effect.global<-effect.function(HR.global)
      effect<-effect.function(HR)
      
      if (conditional==TRUE) {
        if (P<=alpha.global) {
          res<-c(res,as.numeric(effect>rho*effect.global))
        }
      }
      if (conditional==FALSE) {
        res<-c(res,as.numeric(effect>rho*effect.global))
      }      
    }    
    #  mean(res) # the power of consisitency
    MM<-c(MM,mean(res))  
  }
  #--------------------------------------------------------------------#
  # plot with smooth curve, may not work for small data
  #--------------------------------------------------------------------#
  lo <- loess(X~MM)
  samplesize<-predict(lo,power,control=loess.control(surface = "direct"))
  plot(MM,X,type='n',ylab="Total.N",xlab="Power of consistency")
  lines(MM,predict(lo), col='red', lwd=2)
  lines(x=c(power,power), y=c(samplesize,0), lty="solid",lwd=2)
  lines(x=c(0,power),y=c(samplesize,samplesize), lty="solid",lwd=2)
  text(power,samplesize,paste("(",power,", ",round(samplesize,1),")"
                              ,sep=""),offset=1,pos=4)
  }
  
  out<-as.data.frame(c(samplesize,samplesize*(1-censorRate),power,N.global,samplesize/N.global))
  rownames(out)<-c("Sample size","Number of events",
                   "Power of consistency","Global sample size","percentage")
  out<-round(out,3)
  colnames(out)<-"EST"
  out
}