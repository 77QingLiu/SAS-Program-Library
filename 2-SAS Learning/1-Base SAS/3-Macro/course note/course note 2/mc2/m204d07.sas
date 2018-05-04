*m204d07;

%macro numobs(dsn);
   %local dsid rc;
   %let dsid=%sysfunc(open(&dsn));
   %if &dsid>0 %then %do;
	%sysfunc(attrn(&dsid,nlobs))
   	%let rc=%sysfunc(close(&dsid));
   %end;
   %else %put ERROR: Could not open dataset %upcase(&dsn).;
%mend numobs;

%let dsn=orion.country;
proc print data=&dsn;
   title "%upcase(&dsn): %numobs(&dsn) observations";
run;
