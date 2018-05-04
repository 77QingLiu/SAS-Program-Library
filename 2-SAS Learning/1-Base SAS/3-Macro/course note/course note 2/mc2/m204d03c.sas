*m204d03c;

%macro orders(year);
   data orders;
      keep order_date order_type quantity total_retail_price;
      set orion.order_fact end=final;
      where order_type=3 and year(order_date)=&year;
      Number+1;
      if final then call symputx('num', Number, 'L');
   run;

   %if &num le 20 %then %do;	
      proc print data=orders;
         title "Internet Orders &year";
   	  footnote "&num Internet Orders &year";
      run;
   %end;
%mend orders;

data _null_;
   do year=2003 to 2007;
      call execute(cats('%nrstr(%orders(', year, '))' ));
   end;
run;
