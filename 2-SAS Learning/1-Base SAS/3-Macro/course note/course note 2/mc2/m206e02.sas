*m206e02;

%let code=GDL;
proc print data=orion.order_fact noobs n;
   var order_date order_type quantity total_retail_price;
   sum quantity total_retail_price;
   where club_code="&code";
   title "**********";
run;
