%macro AHGgettempname(tempname,start=,useit=0);
  
  %if %AHGblank(&start) %then %let start=T_&tempname;
  %if %length(&start)>10 %then %let start=%substr(&start,1,10);
  %local  ahg9rdn  i;
  %do %until (not %sysfunc(exist(&&&tempName))  );
  %let ahg9rdn=;
  %do i=1 %to 7;
  %let ahg9rdn=&ahg9rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(0))*24),1,2))) ); 
  %end;
  %let &tempname=&start._&ahg9rdn;
  %end;
  %put &tempname=&&&tempname;
  %if &useit %then
  %do;
  data &&&tempname;
  run;
  %end;


%mend;
