*m206d04;

%macro fmtc(value,format);
   %sysfunc(putc(&value,&format))
%mend fmtc;

%let country=DE;
proc print data=orion.customer;
   var customer_ID gender customer_name country continent_ID;
   where country="&country";
   title "Customers from %fmtc(&country,$country.)";
run;
