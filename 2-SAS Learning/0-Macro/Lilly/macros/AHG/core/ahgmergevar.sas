%macro AHGmergevar(dsn,out=,mode=/*3:5@7:9*/,space=" ");
	%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
	%local varlist ;
	%AHGalltocharnew(&dsn,out=&out,rename=AHGmv);
	%AHGvarlist(&out,Into=varlist,dlm=%str( ),global=0);
	%AHGpm(varlist);


	%local i j bigvarN dropstr lengthstr;
	%let bigvarN=%AHGcount(&mode,dlm=@); 
	%do  i=1 %to &bigvarN;
	 	%AHGsetvarLen(&out,AHGmv%AHGscan2(&mode,&i,1,dlm=@,dlm2=:),$80);
		%do j=%eval(1+%AHGscan2(&mode,&i,1,dlm=@,dlm2=:)) %to %AHGscan2(&mode,&i,2,dlm=@,dlm2=:);
		%let dropstr=&dropstr AHGmv&j  ;
		%end;
	%end;
	%let dropstr=drop %str( &dropstr;);
	%AHGpm(dropstr);

	data &out;
		set &out;
		&dropstr;
		%do  i=1 %to &bigvarN;
			AHGmv%AHGscan2(&mode,&i,1,dlm=@,dlm2=:) =''
			%do j=%AHGscan2(&mode,&i,1,dlm=@,dlm2=:) %to %AHGscan2(&mode,&i,2,dlm=@,dlm2=:);
			||trim(left(AHGmv&j)) ||&space
			%end;
			;
		%end;
	run;
	%AHGprt;
%mend;
option nomlogic;

