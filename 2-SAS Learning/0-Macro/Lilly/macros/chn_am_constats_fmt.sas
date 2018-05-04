%macro chn_am_constats_fmt(indata=,trtn=,param=,out=,dec=,cond=,byvar=,stats=n mean std median min max q1 q3);
  %if %length(&out) = 0 %then %let out=&param._;
  %LOCAL newdsn;
  %let newdsn=%substr(%sysfunc(tranwrd(&indata&SYSPROCESSID,.,_)),1,25);
  data &newdsn;
    set &indata;
  %if &trtn eq %then 
    %do;
    %let trtn=trtn;
    trtn=1;
    %end;
  run;
  
  %chn_am_constats(indata=&newdsn,trtn=&trtn,param=&param,out=&out,dec=7,cond=&cond,byvar=&byvar);
  %local trtcount;
  proc sql noprint;
    select count(distinct(&trtn)) into :trtcount
    from &newdsn
    ;quit;
  %local i count onefmt def oneStat allstats allstatStr;
  %let count=%AHGcount(&stats);
  %do i=1 %to &count;
    %let allstats=&allstats %scan(%scan(&stats,&i,%str( )),1,|);
    %let allstatStr=&allstatStr %scan(%scan(&stats,&i,%str( )),1,|);
  %end;
  proc sql noprint;
    create table &out as
    select *
    from &out
    where indexw(upcase("&allstatStr"),upcase(_name_))
    ;quit;
  data &out;
    set &out;
    array allT t1-%sysfunc(compress(t&trtcount));
    %do i=1 %to &count;
      %let onestat=%scan(%scan(&stats,&i,%str( )),1,|);
      %let onefmt=%scan(%scan(&stats,&i,%str( )),2,|);
      %if %sysfunc(indexw(min max,%lowcase(&onestat))) %then %let def=15.&dec;
      %else %if  %lowcase(&onestat) =n %then %let def=15.;
      %else %let def=15.%eval(&dec+1);
      %if %length(&onefmt) = 0 %then %let onefmt=&def;
      if upcase("&onestat")=upcase(_name_) then 
      do;
      ord=&i;
      do over allT;
        allt=left(put(input(left(allT),best.),&onefmt));
      end;
      end;
    %end;
  run;
  proc sort data=&out; by &byvar ord;run;
%mend;
