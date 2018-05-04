*m207d02;

proc sql noprint;
   select distinct country into :list separated by ' '
   	from orion.customer;
quit;
