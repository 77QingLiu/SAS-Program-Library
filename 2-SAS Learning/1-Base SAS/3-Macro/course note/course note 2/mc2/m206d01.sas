*m206d01;

data _null_;
   set orion.continent(keep=continent_ID continent_name);
   call symputx('C' || left(continent_ID), continent_name);
run;

%put _user_;

options symbolgen;

%let continent=93;
proc print data=orion.customer;
   var customer_ID gender customer_name country continent_ID;
   where continent_ID=&continent;
   title "Customers from &&C&continent";
run;

options nosymbolgen;

data customers;
	set orion.customer;
	length Continent $ 17;
	Continent=symget('C' || left(continent_ID));
run;

proc print data=customers (obs=25);
   var customer_ID gender customer_name country continent_ID continent;
   title "Customers";
run;

title;