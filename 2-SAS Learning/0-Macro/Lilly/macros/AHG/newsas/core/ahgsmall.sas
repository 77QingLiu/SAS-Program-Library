%macro AHGsmall(dsn,vars,out=);
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
%AHGdatasort(data =&dsn , out =&out , by =&vars );

data &out;
  set &out;
  by &vars;
  if first.%scan(&vars,-1) then output;
run;
%mend;
