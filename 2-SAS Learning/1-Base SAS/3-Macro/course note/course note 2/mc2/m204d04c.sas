*m204d04c;

%macro numobs(dsn);
   %local dsid rc;
   %let dsid=%sysfunc(open(&dsn));
   %if &dsid>0 %then %do;
	%sysfunc(attrn(&dsid,nlobs))
   	%let rc=%sysfunc(close(&dsid));
   %end;
   %else %put ERROR: Could not open dataset %upcase(&dsn).;
%mend numobs;
