%macro AHGreLabel(dsn,out=,pos=,labels=,dlm=@);
	%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
	%local varlist;
	%if %AHGblank(&pos) %then %let pos=%AHGwords(,%AHGcount(&labels,dlm=&dlm));
	%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
	%AHGpm(varlist);
	data &out;
		set &dsn;
		%local i;
		label
		%do i=1 %to %AHGcount(&pos);
		%scan(&varlist, %scan(&pos,&i))="%scan( &labels,&i,&dlm)"
		%end;
		;
	run;
%mend;
