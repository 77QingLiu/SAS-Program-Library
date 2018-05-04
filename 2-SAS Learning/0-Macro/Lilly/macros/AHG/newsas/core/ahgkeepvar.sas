%macro AHGkeepvar(dsn,IDs,out=);
	%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
	%local i count varlist;
	%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
	%let count=%ahgcount(&ids);
    data &out;
		set &dsn(keep=
		%do i=1 %to &count;
        %scan(&varlist,%scan(&IDs,&i)) 
		%end;
		);
	run;
	
%mend;

