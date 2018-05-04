%macro AHGrenamedsn(dsn,out);
%if not %sysfunc(exist(&out)) %then
  %do;
  %if not %index(&dsn,.) %then %let dsn=work.&dsn;
  %local lib ds dsout;
  %let lib=%scan(&dsn,1);
  %let ds=%scan(&dsn,2);
  proc datasets library=&lib;
     change &ds=%scan(&out,%AHGcount(&out,dlm=.));
  run;
  %end;
%else 
  %do; data %scan(&out,%AHGcount(&out,dlm=.));set &dsn;run;  %end; 


%mend;
