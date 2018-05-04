%macro AHGkeepN(dsn,by,n=2,m=0,out=);
	%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
	proc sort data=&dsn out=&out;
		by &by;
	run;

	data &out(drop=ahuigeID3498273456);
		set &out;
		by &by;
		if first.%scan(&by,%AHGcount(&by)) then	ahuigeID3498273456=1;
		else ahuigeID3498273456+1;
		if &m<ahuigeID3498273456<=&n then output;
	run;

%mend;
