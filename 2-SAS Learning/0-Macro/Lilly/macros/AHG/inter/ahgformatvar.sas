%macro AHGformatvar(dsn,formatstr,out=);
%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
data &out;
	set &dsn;
	format &formatstr;
run;
%mend;
