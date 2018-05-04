%macro AHGsomeTempName(tempname,n,start=);
    %local onetemp i;
	%if %AHGblank(&start) %then %let start=T_&tempname;
	%local  rdn condition ;


	%do %until ( %unquote(&condition)    );
		%let rdn=%sysfunc(normal(0));
		%let rdn=%sysfunc(translate(&rdn,00,.-));
		%let onetemp=&start._%substr(&rdn,1,5);
		%let &tempname=%AHGwords(&onetemp,&n);
		%let condition=	1 ;
	    %do i=1 %to &n;
	    %let condition=%str(&condition and not %sysfunc(exist(&onetemp.&i)) )  ;
		%AHGpm(condition);
		%end;
	%end;
	%put &tempname=&&&tempname;



%mend;

