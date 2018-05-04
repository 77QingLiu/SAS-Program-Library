%macro AHGloopX(dsn,cmd,xvar=
,url=
,in=Ahuige
,out=outahuige /*freq sum */
,execute=1);
/*
if xvar has 3 distinct value as x y z.
&url.xCnt: Macro variable of how many distinct xvar
&url.Iter.1(2/3): Macro variable value -> x y z
DSN  &url.&in.x(y/z): processing Dataset x y z are the distinct values of xvar
DSN  &url.freq.x(y/z)); output Dataset for Freq
DSN  &url.sum.x(y/z));  output Dataset for sum
*/
%AHGkill(dsetlist=&in &out);

%local XisNum  theDsn;
%AHGgettempname(theDsn)	;
%if  %AHGblank(&xvar)  %then %let xvar=dummyXvar; 

data &theDsn;
	set &dsn;
%if  &xvar=dummyXvar  %then    dummyXvar=1;  ;
run;

%AHGvarisnum(&thedsn,&xvar,into=XisNum);

%local xloop  xCnt  xArr ;

%AHGdistinctValue(&thedsn,&xvar,into=xArr,dlm=@);
%global &url.xCnt;
%let &url.xCnt=%AHGcount(&xArr,dlm=@);
%do xloop=1 %to &&&url.xCnt;
  %put %nrstr(%%)&cmd%str(;);
  %local perccmd loopid;
  %let loopid=_%scan(&xArr,&xloop,@);
  %let loopNum=_&xloop;
  %let perccmd=%nrstr(%%)&cmd;
  %put(&xvar=%scan(&xArr,&xloop,@));
  data &in &url%sysfunc(compress(&in&loopid));
    /* create a processing dsn and a backup dsn*/
  	set &thedsn;
	if left(&xvar||'')="%scan(&xArr,&xloop,@)" ;
  run;
  %global &url.Iter&loopnum;
  %let &url.Iter&loopnum=&loopid;
  %AHGpm(&url.Iter&loopnum);

  %if &execute=1 %then %unquote(&perccmd);;
  %local i OneOut;
  
  %do i=1 %to %AHGcount(&out);
  %let OneOut=%scan(&out,&i);
  data &url%sysfunc(compress(&OneOut&loopid));
  	set  &OneOut;
  run;
  %end;
  %AHGkill(dsetlist=&oneout);  
  %loopxexit:;
%end;

%AHGkill(dsetlist=&in &out);
%mend;


