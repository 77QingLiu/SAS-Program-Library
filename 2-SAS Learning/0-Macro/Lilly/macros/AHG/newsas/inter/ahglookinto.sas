%MACRO AHGlookinto(dsn,out=,uniq=,trt=trtm,by=bym,
num=numm,trtnum=trtnumm,n=200);
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn)_lk;
%if %AHGblank(&uniq) %then %let uniq=%AHGbarename(&dsn)_uniq;
%LOCAL nobs;
%AHGnobs(&dsn,into=nobs);
%AHGDataView(dsin=&dsn,
dsout=&uniq,order=original,SameVal=noDelete,open=0);

data &uniq;
  set &uniq(obs=&n) ;
run;

%local i varlist varinfo;
%AHGvarlist(&dsn,Into=varlist);

  proc sql;
      create table miss_&out as 
      select 
      %do i=1 %to %AHGcount(&varlist);
      %AHGd
      sum(missing(%scan(&varlist,&i)))/count(*) as %scan(&varlist,&i)
      %end;
      from &dsn
      ;
      create table &out as 
      select 
      %do i=1 %to %AHGcount(&varlist);
      %AHGd
      count(%scan(&varlist,&i)) as %scan(&varlist,&i)
      %end;
      from &uniq
      ;
    quit;

  proc transpose data=&out out=tran&out(rename=(_name_=name col1=uniq));
    var &varlist;
  run;

  proc transpose data=miss_&out out=tranMiss_&out(rename=(_name_=name col1=MissP));
    var &varlist;
  run;

%AHGgettempname(varinfo);
%AHGvarinfo(&dsn,out=&varinfo,info= name  type label format);

%AHGmergedsn(&varinfo,tran&out,&out,by=name,joinstyle=full/*left right full matched*/);
%AHGmergedsn(&out,tranMiss_&out,&out,by=name,joinstyle=full/*left right full matched*/);

%local fn;
%let fn=ahgxsadfsaz;
%macro ahgxsadfsaz(big,word);
 index(lowcase(&big),"&word")  or 
%mend;

data &out;
  set &out;
  rate=uniq/&n;
  if %AHGfuncloop(%nrbquote(&fn(label,ahuige)) ,
      loopvar=ahuige,loops=treatment drug drg dose arm trt ) 0 then trtlike=90000;
      else trtlike=10000;
  if %AHGfuncloop(%nrbquote(&fn(name,ahuige)) ,
      loopvar=ahuige,loops=treatment drug  drg dose arm trt) 0 then trtlike=trtlike+9000;
  trtlike=trtlike+((2<=uniq<=4)*9+(5<=uniq<=10)*5+(11<=uniq<=15)*3)*100+(type="C")*90
      ;
  trtlike=trtlike*(1-MissP);
  
  bylike=((2<=uniq<=4)*9+(5<=uniq<=10)*8+(11<=uniq<=15)*7)*10000
        +(index(lowcase(format),"date")<1)*1000 
        +(index(lowcase(format),"yy")<1)*1000
        +(index(lowcase(format),"dt")<1)*1000
        +(format ne '')*900;
  bylike=bylike*(1-MissP);

/*  freqlike=(2<=uniq<=5)*5+(6<=uniq<=12)*3+(1-missp)*8+ 10*(MissP<0.1);*/
  freqlike=((2<=uniq<=4)*9+(5<=uniq<=10)*8+(11<=uniq<=15)*7)*10000;
  numlike=(type='N')*((index(lowcase(format),"date")<1)*1000
  +(index(lowcase(label),"dt")<1)*1000
  +(index(lowcase(format),"dt")<1)*1000
  +(index(lowcase(label),"key")<1)*1000
  +(index(lowcase(format),"yy")<1)*1000
  +(index(lowcase(label),"id")<1)*1000
  +(0.3<uniq/&n<0.6)*900+(0.6<=uniq/&n)*600+(0.1<uniq/&n<=0.3)*300+uniq*100
  );
  numname=name;
  if numlike=0 then numname='';
  byonly=bylike*100-trtlike;
  trtnumlike=trtlike*(type="N");

run;
%local trtlike bylike numlike trtnumlike;
%AHGgettempname(trtlike);
%AHGgettempname(bylike);
%AHGgettempname(numlike);
%AHGgettempname(trtnumlike);

%AHGtop(&out,%str(name,uniq),trtlike,out=&trtlike);
%AHGtop(&out,name,byonly,out=&bylike);
%AHGtop(&out,numname,numlike,out=&numlike);
%AHGtop(&out,name,trtnumlike,out=&trtnumlike);

data &trtlike;
  set &trtlike(where=(uniq<=20));
run;

%if %AHGnonblank(&trt) %then %AHGdistinctValue(&trtlike,name,sort=0,into=&trt,dlm=%str( ));
%if %AHGnonblank(&by) %then %AHGdistinctValue(&bylike,name,sort=0,into=&by,dlm=%str( ));
%if %AHGnonblank(&num) %then %AHGdistinctValue(&numlike,numname,sort=0,into=&num,dlm=%str( ));
%if %AHGnonblank(&trtnum) %then %AHGdistinctValue(&trtnumlike,name,sort=0,into=&trtnum,dlm=%str( ));

%mend;

