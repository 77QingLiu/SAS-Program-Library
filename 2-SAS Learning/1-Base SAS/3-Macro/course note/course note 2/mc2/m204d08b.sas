*m204d08b;

%macro wherobs(dsn,mywhere);
   %if %superq(mywhere)= %then %do;
	%numobs(&dsn)
	%return;
   %end;
   %local dsid rc;
   %let dsid=%sysfunc(open(&dsn(where=(&mywhere))));
   %if &dsid>0 %then %do;
	%sysfunc(attrn(&dsid,nlobsf))
   	%let rc=%sysfunc(close(&dsid));
   %end;
   %else %put ERROR: Could not open dataset %upcase(&dsn).;
%mend wherobs;
