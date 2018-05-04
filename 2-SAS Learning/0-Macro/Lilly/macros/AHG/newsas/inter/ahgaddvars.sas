%macro AHGaddvars(dsn,vars,out=&dsn,fmt=$15.);
	data &out;
		format &vars &fmt;
		set &dsn;
	run;
%mend;


