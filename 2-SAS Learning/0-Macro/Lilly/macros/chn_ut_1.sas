%macro chn_ut_1(m,str);
%macro _SHVblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;
%if not %_SHVblank(&m) %then &str;
%mend;
