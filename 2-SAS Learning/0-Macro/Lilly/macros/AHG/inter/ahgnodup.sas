%macro AHGnodup(sentence,dlm=%str( ));
	%local i  CountS final;
	%let sentence=%bquote(&sentence);
	%let countS=%AHGcount(&sentence,dlm=&dlm);
	%let final=&dlm;
	%do i=1 %to &Counts;
		%if not %sysfunc(indexw(%lowcase(&final),%lowcase(%scan(&sentence,&i,&dlm)),&dlm ))
			%then %let final=&final&dlm%scan(&sentence,&i,&dlm);
	%end;
	%let final=%sysfunc(tranwrd(&final,&dlm&dlm,));
	 &final
%mend;