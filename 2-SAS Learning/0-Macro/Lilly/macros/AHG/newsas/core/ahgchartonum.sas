%macro AHGcharToNum(dsn,vars,out=);
	%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
	%local rdm i;
	%let rdm=_;
	data &out;
		set &dsn;
		%do i=1 %to %AHGcount(&vars);
		%scan(&vars,&i)&rdm=input(%scan(&vars,&i),best.);
		%end;

		drop
		%do i=1 %to %AHGcount(&vars);
		%scan(&vars,&i) 
		%end;
		;
		rename 
		%do i=1 %to %AHGcount(&vars);
		%scan(&vars,&i)&rdm=%scan(&vars,&i) 
		%end;
		;
	run;
	
%mend;
