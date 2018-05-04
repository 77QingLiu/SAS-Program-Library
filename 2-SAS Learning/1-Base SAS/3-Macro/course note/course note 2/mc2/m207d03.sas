*m207d03;

%macro charlist(var=,dsn=);

	proc sql noprint;
   	select distinct &var into :list separated by " "
      	from &dsn;
	quit;

%mend charlist;

%global list;
%charlist(var=country, dsn=orion.customer)

%put &=list;

