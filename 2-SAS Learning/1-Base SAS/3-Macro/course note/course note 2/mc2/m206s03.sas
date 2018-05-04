*m206s03;

data _null_;
   set orion.country(keep=country country_name);
   call symputx(country, country_name);
run;

%let country=DE;
%let geo=country;

proc print data=orion.customer;
   var customer_ID gender customer_name country continent_ID;
   where country="&country";
   title "Customers from &&&&&&&geo";
run;

title;
