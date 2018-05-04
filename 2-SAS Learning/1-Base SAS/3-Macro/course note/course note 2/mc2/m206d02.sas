*m206d02;

data _null_;
   set orion.country(keep=country country_name);
   call symputx(country, country_name);
run;

%put _user_;

options symbolgen;

%let country=DE;
proc print data=orion.customer;
   var customer_ID gender customer_name country continent_ID;
   where country="&country";
   title "Customers from &&&country";
run;

options nosymbolgen;

data customers;
	set orion.customer;
	length Country_name $ 13;
	Country_name=symget(country);
run;

proc print data=customers (obs=25);
   var customer_ID gender customer_name country Country_name;
   title "Customers";
run;

title;