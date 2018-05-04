%macro chn_ut_0(m,str);
%macro _QPDblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;
%if %_QPDblank(&m) %then &str;
%mend;
