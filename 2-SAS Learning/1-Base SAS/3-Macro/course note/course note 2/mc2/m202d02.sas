*m202d02;

libname orion "&path";
options mstored sasmstore=orion;

%macro calc(stats,vars)/store source;
   proc means data=orion.order_fact &stats;
      var &vars;
   run;
%mend calc;

options mprint;

%calc(min max,quantity)

%copy calc / source;
