
%macro ahgaddfmtby(dsn,by,out=,outbyvar=);
	%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
	data &out;
		set &dsn;
		&outbyvar=&by;
		format &outbyvar 8.;
	run;
%mend;
