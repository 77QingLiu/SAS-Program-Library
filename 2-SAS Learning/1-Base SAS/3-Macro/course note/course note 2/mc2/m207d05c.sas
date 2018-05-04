*m207d05c;

%macro exist(dsn);
   %sysfunc(exist(&dsn))
%mend exist;

%macro stats(datasets);
   %let i=1;
   %do %until(&dsn= );
      %let dsn=%upcase(%scan(&datasets,&i));
      %if &dsn= %then %put NOTE: Processing complete.;
      %else %if %exist(orion.&dsn) %then %do;
	  title "ORION.&dsn";
         proc means data=orion.&dsn n min mean max;
         run;
      %end;
      %else %put ERROR: No &dsn dataset in ORION library.;
      %let i=%eval(&i+1);
   %end;
%mend stats;

%stats(dead mans curve)
