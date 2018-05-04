%macro AHGrenameVar(dsn,out=,names=,prefix=AHG	,zero=0);
	%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
	%local i zeroI varlist;
	
	%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
	proc sql noprint;
	create table &out as
	select 
	%do i=1 %to %AHGcount(&varlist); 
		
		%if &zero>0 %then %let zeroI=%AHGzero(&i,z&zero..);
		%else %let zeroI=&i;

		%if &i ne 1 %then ,;

		%if %AHGblank(&names) %then %scan(&varlist,&i) as &prefix._&zeroI ;
		%else %if not %AHGblank(%scan(&names,&i)) %then %scan(&varlist,&i) as  %scan(&names,&i)  ;
		%else   %scan(&varlist,&i) ;
	%end;

	from &dsn
	;
	quit;
%mend;