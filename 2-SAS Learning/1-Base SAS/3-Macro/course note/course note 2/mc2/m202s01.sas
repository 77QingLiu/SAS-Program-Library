*m202s01;

libname orion "&path";
*libname orion "S:\workshop";

proc options option=(mstored sasmstore);
run;

options mstored sasmstore=orion;

proc options option=(mstored sasmstore);
run;

%macro time / store source des='Lindsay Lohan';
   %put TIME: %sysfunc(time(), timeAMPM.);
%mend time;

proc catalog cat=orion.sasmacr;
	contents;
quit;

%time

%copy time / source;
