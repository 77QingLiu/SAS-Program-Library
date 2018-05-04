%macro AHGtop(dsn,var,by,out=,n=5,desc=1);
  proc sql noprint;
    create table &out as
    select &var,&by
    from &dsn
    order by &by %if &desc %then descending;
    ;
    quit;
  data &out;
    set &out(obs=&N);
  run;
%mend;
