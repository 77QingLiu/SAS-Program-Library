%macro AHGpush(arrname,value,dlm=%str( ));
	%if %AHGcount(&&&arrname,dlm=&dlm) >0 %then 	%let &arrname=&&&arrname&dlm&value;
	%else %let &arrname=&value;
%mend;
