*m206d06a;

%macro fmtn(value,format);
   %sysfunc(putn(&value,&format))
%mend fmtn;

ods html close;
ods listing;

%let total=1000;
proc print data=orion.order_fact;
	var order_ID order_date quantity total_retail_price;
	where total_retail_price>&total;
	title "Orders over %fmtn(&total,dollar11.)";
run; 
title;
