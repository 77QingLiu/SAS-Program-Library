*m207d04;

%macro charlist(var=,dsn=);
    proc sql noprint;
       select distinct &var into :list separated by " "
          from &dsn;
    quit;
%mend charlist;

%macro customers(place) / minoperator;
   %let place=%upcase(&place);
   %local list;
   %charlist(dsn=orion.country,var=country)
   %if &place in &list %then %do;
      proc print data=orion.customer;
         var customer_name customer_address country;
         where upcase(country)="&place";
         title "Customers from &place";
      run;
      title;
   %end;
   %else %do;
      %put Sorry, no customers from &place..;
      %put Valid countries are: &list..;
   %end;
%mend customers;

%customers(de)
%customers(a)
