%macro AHGdefault(mac,default,global=1);
	%if  &global %then %global &mac;
	%if %AHGblank(%bquote(%trim(&&&mac))) %then %let &mac=&default; ;
%mend;
