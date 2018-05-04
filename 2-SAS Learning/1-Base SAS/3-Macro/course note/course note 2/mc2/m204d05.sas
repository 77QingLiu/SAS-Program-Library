*m204d05;

%macro numobs(dsn);
   %local dsid rc;
   %let dsid=%sysfunc(open(&dsn));
   %if &dsid>0 %then %do;
	%sysfunc(attrn(&dsid,nlobs))
   	%let rc=%sysfunc(close(&dsid));
   %end;
   %else %put ERROR: Could not open dataset %upcase(&dsn).;
%mend numobs;

%put %numobs(abc);
%put Number of Observations: %numobs(orion.country);

%let nobs=%numobs(orion.country);
%put &=nobs;
