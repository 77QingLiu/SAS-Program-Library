%macro AHGpastedsn(dsn1,dsn2,url=,out=);
	%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn1);
/*	%local nobs;*/
/*	%AHGnobs(&dsn2,into=nobs);*/
	%AHGalltocharNew(&dsn2,rename=AHG);
	%local up down;
	%AHGgettempname(up);
	%AHGgettempname(down);
	%if %AHGblank(&url) %then %let url=%scan(&dsn2,2,_);
	
	data &up &down;
		set &dsn1;
		if AHGurl<"&url" then output &up;
		else output &down;
	run;

	data &down;
		merge &down &dsn2;
    run;

	data &out;
		set &up &down;
	run;

%mend;
