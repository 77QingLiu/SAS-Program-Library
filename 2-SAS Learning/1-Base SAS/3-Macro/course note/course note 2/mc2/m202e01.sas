*m202e01;

options mcompilenote=all;

proc options option=(mstored sasmstore);
run;

%macro time;
   %put TIME: %sysfunc(time(), timeAMPM.);
%mend time;

proc catalog cat=orion.sasmacr;
	contents;
quit;
