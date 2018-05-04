%macro AHGscanSubstr(words,from,num,dlm1st=0,dlm=%str( ),compress=0/*right*/);
	%local i outstr;
	%let outstr=;
	%do i=0 %to %eval(&num-1);
		%if &i gt &dlm1st %then %let outstr=&outstr&dlm;
		%let outstr=&outstr%scan(&words,%eval(&i+&from),&dlm);
	%end;
	%if &compress %then %let outstr=%sysfunc(compress(&outstr));
	&outstr
%mend;
