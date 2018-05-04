%macro AHGremoveSlash(str);
	%let str=%sysfunc(reverse(&str));
	%if %substr(&str,1,1)=%str(/) or  %substr(&str,1,1)=%str(\) %then %let str=%substr(&str,2,%length(&str));
	%sysfunc(reverse(&str))
%mend;
