*m207d01;

%macro customers(place) / minoperator;
   %let place=%upcase(&place);
   %if &place in AU CA DE IL TR US ZA %then %do;       	
		proc print data=orion.customer;
         var customer_name customer_address country;
         where upcase(country)="&place";
         title "Customers from &place";
      run;
		title;
   %end;
   %else %put Sorry, no customers from &place..;
%mend customers;

%customers(de)
%customers(aa)
