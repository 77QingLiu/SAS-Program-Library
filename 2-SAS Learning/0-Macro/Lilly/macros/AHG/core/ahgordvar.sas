%macro AHGordvar(dsn,vars,out=,keepall=0);
%local sql;
%AHGgettempname(sql);
%if &keepall %then
  %do;
  %local restvardsn ;
  %let restvardsn=;
  %AHGgettempname(restvardsn);  
  
  data &restvardsn;
    set &dsn(drop=&vars);
  run;
  %end;
%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
proc sql;
  create table &sql as
  select %AHGaddcomma(&vars)
  from  &dsn(keep=&vars)
;quit;



%if &keepall %then
%do;

data &sql ;
  merge &sql &restvardsn;
run;
%end;
%else 
%do;
data &out;
  set &sql;
run;
%end;


%mend;
