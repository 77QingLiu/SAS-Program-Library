%macro AHGnobs(dsn,into=);
  %if %sysfunc(exist(&dsn)) %then
  %do;
  proc sql noprint;
  select count(*) into :&into
  from &dsn
  ;quit;
  %end; 
  %else %let &into=0;
%mend;
