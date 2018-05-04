*m207d06;

%macro calc(dsn=,var=);
   proc means data=&dsn n nmiss min mean max maxdec=2;
	var &var;
   run;
%mend calc;

%calc(dsn=orion.order_fact,var=Total_Retail_Price)
