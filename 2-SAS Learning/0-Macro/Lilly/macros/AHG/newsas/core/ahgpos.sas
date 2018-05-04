%macro AHGpos(string,word);
	%let string=%upcase(&string);
	%let word=%upcase(&word);
	%index(&string,&word)
%mend;
