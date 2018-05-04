%macro AHGverticalInsert(master,slave,where=0,out=);
	%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
	%local masterVars slaveVars;
	%AHGrenameVar(&master,prefix=master);
	%AHGrenameVar(&slave,prefix=slave);
	%AHGvarlist(&master,Into=masterVars,dlm=%str( ),global=0);
	%AHGvarlist(&slave,Into=slaveVars,dlm=%str( ),global=0);
	%if &where>%AHGcount(&masterVars) %then %let where=	%AHGcount(&masterVars) ;
    %local master1 master2 ;
	%AHGgettempname(master1);
	%AHGgettempname(master2);

	data &master1;
		
		%if &where>=1 %then 
		%do;
		set &master 
		(keep=
        %do i=1 %to &where ; %scan(&masterVars,&i)  %end;
         )
		%end;
		%else ;

;  ;
	run;

	data &master2;
		%if &where<%AHGcount(&masterVars) %then 
		%do;
		set &master   (keep=%do i=%eval(&where+1) %to %AHGcount(&masterVars); %scan(&masterVars,&i)  %end;);  ;
		%end;
	run;

	data &out;
		merge &master1 &slave &master2;
	run;

%mend;
