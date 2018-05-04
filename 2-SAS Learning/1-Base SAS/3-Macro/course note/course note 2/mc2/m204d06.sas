*m204d06;

%macro numobs(dsn);
   %local dsid rc;
   %let dsid=%sysfunc(open(&dsn));
   %if &dsid>0 %then %do;
	%sysfunc(attrn(&dsid,nlobs))
   	%let rc=%sysfunc(close(&dsid));
   %end;
   %else %put ERROR: Could not open dataset %upcase(&dsn).;
%mend numobs;

%macro printds(dsn);
   %local obs;
   %let dsn=%upcase(&dsn);
   %if %numobs(&dsn) > 10 %then %do;
      title "First 10 observations from &dsn";
      %let obs=(obs=10);
   %end;
   %else %do;
	title "All observations from &dsn";
   %end;
   proc print data=&dsn &obs;
   run;
%mend printds;

%printds(orion.daily_sales)
%printds(orion.country)
