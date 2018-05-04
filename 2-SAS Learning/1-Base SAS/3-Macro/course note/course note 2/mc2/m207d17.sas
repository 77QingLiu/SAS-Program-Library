*m207d17;

%macro printwindow;

   %local dsn var vars dsid rc obs sup dbl lab supx dblx labx try msg;
   %let msg=Press ENTER to continue.;
   %let sysmsg=Enter dataset name.;
   %display dsn;
   %let dsn=%upcase(&dsn);

   %do %while(%sysfunc(exist(&dsn))=0);
	 	%let dsn=%upcase(&dsn);
	 	%let try=;
	 	%display err;
	 	%if %upcase(&try)=Y %then %display dsn;
	 	%else %do;
	    	%put ERROR: Dataset &dsn does not exist.;
	    	%return;
      %end;
   %end;

	%let sysmsg=Enter variable names or leave blank.;
   %display var;

   %if &var ne %then %do;
		%let dsid=%sysfunc(open(&dsn(keep=&var)));
		%let rc=%sysfunc(close(&dsid));
		%let var=%upcase(&var);
		%if &dsid=0 %then %do;
      	%put ERROR: Variables(&var) not in &dsn..;
	   	%return;
		%end;
		%let vars=var &var;
   %end;

	%let sysmsg=Select options.;
	%display opt;

	%if         &obs ne %then %let obs=(obs=&obs);
	%if %upcase(&sup)=Y %then %let supx=noobs;
	%if %upcase(&dbl)=Y %then %let dblx=double;
	%if %upcase(&lab)=Y %then %let labx=label;

	proc print data=&dsn &obs &supx &dblx &labx;
	   &vars;
	   title "&dsn";
	run;
	title;

	%put NOTE: Processing complete.;

%mend printwindow;

%printwindow


