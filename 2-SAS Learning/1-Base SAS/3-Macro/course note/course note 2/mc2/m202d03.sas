*m202d03;

*Save the macro definition as CALC.SAS;

%macro calc(stats,vars);
   proc means data=orion.order_fact &stats;
		var &vars;
   run;
%mend calc;

options nomstored mautolocdisplay mautosource sasautos=("&path",sasautos);
*options nomstored mautolocdisplay mautosource sasautos=("S:\workshop",sasautos);


%calc(min max,quantity)
