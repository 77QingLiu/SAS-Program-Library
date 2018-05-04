%macro AHGonWIN;
	%if %UPCASE(%substr(&sysscp,1,3)) =WIN  %then 1;
	%else 0;
%mend;
