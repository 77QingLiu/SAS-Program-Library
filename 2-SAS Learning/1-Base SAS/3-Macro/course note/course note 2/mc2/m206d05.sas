*m206d05;

%macro fmtn(value,format);
   %sysfunc(putn(&value,&format))
%mend fmtn;
 
%let continent=93;
proc print data=orion.customer;
   var customer_ID gender customer_name country continent_ID;
   where continent_ID=&continent;
   title "Customers from %fmtn(&continent,continent.)";
run;
