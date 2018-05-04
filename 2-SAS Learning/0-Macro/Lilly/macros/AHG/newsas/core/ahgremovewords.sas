
%macro AHGremovewords(sentence,words,dlm=%str( ));
	%local i j CountS CountW final found itemS ;
	%let sentence=%bquote(&sentence);
	%let words=%bquote(&words);
	%let  CountS=%AHGcount(&sentence,dlm=&dlm);
	%let  CountW=%AHGcount(&words,dlm=&dlm);

	%let final=&dlm;
	%do i=1 %to &Counts;
		%let found=0;
		%let itemS=%scan(&sentence, &i,&dlm);
		%let j=0;
		%do %until (&j=&countW or &found) ;
		    %AHGincr(j)
	
			%if %upcase(&itemS)= %upcase(%scan(&words, &j,&dlm)) %then %let found=1;
		%end;
		%if &found=0 %then %let final=&final&dlm&itemS;
	%end;
	%let final=%sysfunc(tranwrd(&final,&dlm&dlm,));
	 &final
%mend;
