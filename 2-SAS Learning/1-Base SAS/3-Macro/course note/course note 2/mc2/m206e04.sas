*m206e04;

%let custID=4;
proc print data=orion.order_fact noobs n;
   var order_date order_type quantity total_retail_price;
   sum quantity total_retail_price;
   where customer_ID=&custID;
   title "Customer #&custID: **********";
run;
