%macro AHGfillzero(dsn,vars=,out=,fillwith=0);
%local i;
%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
data &out;
  set &dsn;
  %do i=1 %to %AHGcount(&vars);
  if missing(%scan(&vars,&i))  then %scan(&vars,&i)="&fillwith";  
  %end;

  %if %AHGblank(&vars) %then
  %do;
  array allchar _character_;
  do over allchar;
  if missing(allchar) then allchar="&fillwith";
  end;
  array allnum _numeric_;
  do over allnum;
  if missing(allnum) then allnum=&fillwith;
  end;

  %end;

run;
%mend;
