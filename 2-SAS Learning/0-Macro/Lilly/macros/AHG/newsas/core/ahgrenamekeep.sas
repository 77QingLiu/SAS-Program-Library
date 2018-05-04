%macro AHGrenamekeep(dsn,out=,pos=,names=,prefix=col,keepall=0);
  %if %AHGblank(&names) %then %let names=%AHGwords(&prefix,400);
  %if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
  %local varlist count;
  %AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
  %let count=%sysfunc(min(%AHGcount(&varlist),%AHGcount(&names)));
  option symbolgen;
  %if %AHGblank(&pos) %then %let pos=%AHGwords(%str( ),&count);
  %AHGpm(pos);
  option nosymbolgen;
  
  data &out;
    set &dsn;
    %local i;
    %if not &keepall %then
      %do;
      keep
      %do i=1 %to &count;
        %scan(&varlist, %scan(&pos,&i))
      %end;
      ;
      %end;
    rename
    %do i=1 %to &count;
    %scan(&varlist, %scan(&pos,&i))=%scan( &names,&i)
    %end;
    ;
  run;
%mend;
