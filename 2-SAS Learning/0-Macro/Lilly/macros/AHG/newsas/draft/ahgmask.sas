
%macro AHGstartwith(word,leadstr);
	%if %ahgpos(&word,&leadstr)=1 %then 1;
	%else 0;
%mend;

%macro AHGtestANDcut(word,leadstr);
	%if %AHGstartwith(&word,&leadstr) %then ;
%mend;
%macro AHGmask(word,mask);
	%local i item;
	%let mask=%upcase(&mask);
/*	%let mask=%sysfunc(&mask,);*/
	%let word=%upcase(&word);
	%do i=1 %to  %AHGcount(&mask,dlm=:);
	
	%end;


	
%mend;
