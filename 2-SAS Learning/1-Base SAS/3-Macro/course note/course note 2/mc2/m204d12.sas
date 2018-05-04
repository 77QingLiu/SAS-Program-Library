*m204d12;

%macro cust_info(cust_ID);
   %local dsid rc1 rc2 customer_ID customer_name gender birth_date;
   %if %datatyp(&cust_ID) ne NUMERIC %then %goto exit;
   %let dsid=%sysfunc(open(orion.customer(
      keep=customer_ID customer_name gender birth_date
      where=(customer_ID=&cust_ID))));
   %if &dsid=0 %then %goto exit;
   %syscall set(dsid);
   %let rc1=%sysfunc(fetch(&dsid));
   %let rc2=%sysfunc(close(&dsid));
   %if &rc1 ne 0 %then %goto exit;
   %let age=%sysevalf(("&sysdate"d-&birth_date)/365.25,floor);
   %trim(&customer_name) &gender &age
   %return;
   %exit: Unknown
%mend cust_info;

%let cust_ID=63;
proc print data=orion.order_fact noobs;
   where customer_ID=&cust_ID;
   var order_date order_type quantity total_retail_price;
   title1 "Customer &cust_ID: %cust_info(&cust_ID)";
run;
