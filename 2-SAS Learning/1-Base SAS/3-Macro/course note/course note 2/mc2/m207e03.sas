*m207e03;

proc pmenu catalog=orion.menus;
   menu exit;
      item 'Exit' menu=x;
	    menu x;

             item 'OK'     selection=y; 
		  item 'Cancel' selection=z; 

		  selection y 'end';
		  selection z 'command focus';
quit;

%macro printwindow;

   %local min avg max sum;

   %if &min ne %then %let min=min;
   %if &avg ne %then %let avg=mean;
   %if &max ne %then %let max=max;
   %if &sum ne %then %let sum=sum;

   proc means data=orion.order_fact &min &avg &max &sum maxdec=2;
	 	var total_retail_price;
	 	class club_code;
	 	title "Order Statistics";
   run;
   title;

%mend printwindow;
