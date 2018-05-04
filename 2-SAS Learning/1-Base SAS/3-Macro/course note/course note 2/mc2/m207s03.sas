*m207s03;

proc pmenu catalog=orion.menus;
   menu exit;
      item 'Exit' menu=x;

	    	menu x;

            item 'OK'     selection=y; 
	       	item 'Cancel' selection=z; 

            selection y 'end';
            selection z 'command focus';

quit;

%window stats columns=80 rows=20 menu=orion.menus.exit

	# 3 @10 'Select Statistics'
	# 5 @ 6 'Minimum Value   ' min  1 attr=underline
	# 6 @ 6 'Average Value   ' avg  1 attr=underline
	# 7 @ 6 'Maximum Value   ' max  1 attr=underline
	# 8 @ 6 'Total   Value   ' sum  1 attr=underline
	#10 @10 'Press ENTER to continue.';

%macro printwindow;

	%local min avg max sum;
	%display stats;

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

options mprint;
%printwindow
