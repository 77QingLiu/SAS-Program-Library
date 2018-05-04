*m206s01;

data _null_;
   set orion.club_members(keep=customer_ID first_name last_name);
   call symputx('cust' || left(customer_ID), catx(' ', first_name, last_name));
run;

%let custID=4;
proc print data=orion.order_fact noobs n;
   var order_date order_type quantity total_retail_price;
   sum quantity total_retail_price;
   where customer_ID=&custID;
   title "Customer #&custID: &&cust&custID";
run;
title;
