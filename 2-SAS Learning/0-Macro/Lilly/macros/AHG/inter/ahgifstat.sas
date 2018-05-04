%macro AHGifstat(var,values,quote=0,dlm=%str( ));
	%local i one;
	
	%do i=1 %to %AHGcount(&values,dlm=&dlm);
	%if &quote %then %let one=%sysfunc(quote(%scan(&values,&i,&dlm)));
	%else  %let one= %scan(&values,&i,&dlm);
	%put %str(if &var=&one then );
	%put %str(	do;);
	%put %str(  );
	%put %str(	end;);
	%put %str(  );
	%end;

%mend;
