%macro AHGgetwords(words,from,num,dlm1st=0,dlm=%str( )/*right*/);
	%local i outstr;
	%let outstr=;
	%do i=0 %to %eval(&num-1);
		%if &i gt &dlm1st %then %let outstr=&outstr&dlm;
		%let outstr=&outstr%scan(&words,%eval(&i+&from),&dlm);
	%end;
	&outstr
%mend;
