%macro AHGblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;
