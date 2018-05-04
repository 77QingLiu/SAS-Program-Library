%macro ahgputn(var,fmt);
%if %AHGblank(&fmt) %then %let fmt=best.;
left(put(&var,&fmt))
%mend;
