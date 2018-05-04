*m204d10;

%let mywhere=YEAR(order_date)=2007 and MONTH(order_date)=1;

%let dsn=orion.order_fact;

title "%upcase(&dsn): &mywhere";

footnote "Internet Orders: 
   %wherobs(&dsn,&mywhere & order_type=3)";

proc print data=&dsn;
   var order_date order_type quantity total_retail_price;
   where &mywhere;
run;

title;
footnote;
