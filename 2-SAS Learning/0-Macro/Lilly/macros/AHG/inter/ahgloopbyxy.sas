%macro AHGloopByXY(dsn,cmd,xvar=,yvar=
,url=
,out=outAhuige
,in=Ahuige
,execute=1);

%AHGkill(dsetlist=&in);
%local XisNum YisNum theDsn;
%AHGgettempname(theDsn)	;
%if  %AHGblank(&xvar)  %then %let xvar=dummyXvar; 
%if  %AHGblank(&yvar)  %then %let yvar=dummyYvar;

data &theDsn;
	set &dsn;
%if  &xvar=dummyXvar  %then    dummyXvar=1;  ;
%if  &yvar=dummyYvar  %then    dummyYvar=1;  ;
run;

%AHGvarisnum(&thedsn,&xvar,into=XisNum);
%AHGvarisnum(&thedsn,&yvar,into=YisNum);
%local xloop yloop xCnt yCnt xArr yArr;

%AHGdistinctValue(&thedsn,&xvar,into=xArr,dlm=@);
%global &&url.xArr &&url.yArr;
%let &&url.xArr=&xArr;
%global &url.xCnt;
%let &url.xCnt=%AHGcount(&xArr,dlm=@);
%AHGdistinctValue(&thedsn,&yvar,into=yArr,dlm=@);
%let &&url.yArr=&yArr;
%global &url.yCnt;
%let &url.yCnt=%AHGcount(&yArr,dlm=@);

%do xloop=1 %to &&&url.xCnt;
%do yloop=1 %to &&&url.yCnt;
  %put %nrstr(%%)&cmd%str(;);
  %local perccmd loopid;
  %let loopid=_%scan(&xArr,&xloop,@)_%scan(&yArr,&yloop,@);
  %let loopNum=_&xloop._&yloop;
  %let perccmd=%nrstr(%%)&cmd;
  %put(&xvar=%scan(&xArr,&xloop,@));
  %put(&yvar=%scan(&yArr,&yloop,@));
  data &in &url%sysfunc(compress(&in&loopid));
  	set &thedsn;
	if left(&xvar||'')="%scan(&xArr,&xloop,@)" and  left(&yvar||'')="%scan(&yArr,&yloop,@)";
  run;
  %global Mtrx&url&loopnum;
  %let Mtrx&url&loopnum=&loopid;
  %AHGpm(Mtrx&url&loopnum);
/*  %if  &&&mac&url&loopid=0 %then %goto byxyexit;*/
  %if &execute=1 %then %unquote(&perccmd);;
  %local i OneOut;
  
  %do i=1 %to %AHGcount(&out);
  %let OneOut=%scan(&out,&i);
  data &url%sysfunc(compress(&OneOut&loopid));
  	set  &OneOut;
  run;
  %end;
  %AHGkill(dsetlist=&oneout);  
  %byxyexit:;
%end;
%end;
%AHGkill(dsetlist=&in &out);
%mend;


