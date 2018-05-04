%macro AHGprocMeansBy(dsn,var,by,out=stats,print=0,alpha=0.05
,stats=n mean median  min max /*n @ min '-' max*/
,split=\
,orie=
,byorie=hori
,labels=
,left=left
);

%macro dosomething;
%AHGprocMeans(mean,&var,out=stats,print=&print,alpha=&alpha
,stats=&stats
,split=&split
,orie=&orie
,labels=&labels
,left=&left
);
%mend;



%AHGfreeloop(&dsn,&by
,cmd=doSomething
,out=stats
,in=mean
,url=vxu_
,execute=1
,del=1
,addloopvar=0);




%IF &byorie=hori %then %AHGmergePrint(%AHGwords(vxu_stats,&vxu_n),by=,drop=,out=,print=1,prefix=xde3);
%IF &byorie=vert %then 
%AHGsetprint(%AHGwords(vxu_stats,&vxu_n),out=setprint,print=1);


%mend;

