*m207d05a;

%macro stats(datasets);
   %let i=1;
   %let dsn=%upcase(%scan(&datasets,1));
   %do %while(&dsn ne );
		title "ORION.&dsn";
      proc means data=orion.&dsn n min mean max;  
		run;
      %let i=%eval(&i+1);
		%let dsn=%upcase(%scan(&datasets,&i));
   %end;
	title;
%mend stats;

%stats(dead mans curve)
