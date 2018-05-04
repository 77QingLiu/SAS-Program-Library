*m206s02;

proc sort data=orion.club_members(keep=customer_type club_code) nodupkey out=types;
   by club_code;
run;

data _null_;
   set types;
   call symputx(club_code, customer_type);
run;

%let code=GDL;
proc print data=orion.order_fact noobs n;
   var order_date order_type quantity total_retail_price;
   sum quantity total_retail_price;
   where club_code="&code";
   title "&&&code";
run;
title;

