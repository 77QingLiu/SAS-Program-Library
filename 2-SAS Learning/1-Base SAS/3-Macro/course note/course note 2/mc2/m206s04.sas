*m206s04;

data members;
   keep customer_ID name;
   set orion.club_members(keep=customer_ID first_name last_name);
   length name $ 24;
   name=catx(' ', first_name, last_name);
run;

%makefmt(custname, members, customer_ID, name)

%let custID=4;
proc print data=orion.order_fact noobs n;
   var order_date order_type quantity total_retail_price;
   sum quantity total_retail_price;
   where customer_ID=&custID;
   title "Customer #&custID: %sysfunc(putn(&custID,custname.))";
run;
title;
