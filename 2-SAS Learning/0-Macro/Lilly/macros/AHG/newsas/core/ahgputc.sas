%macro ahgputc(var,fmt);
%if %AHGblank(&fmt) %then %let fmt=best.;
input(left(&var),&fmt)
%mend;
