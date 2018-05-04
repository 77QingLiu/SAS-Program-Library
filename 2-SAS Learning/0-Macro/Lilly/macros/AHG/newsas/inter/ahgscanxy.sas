%macro AHGscanxy(str,x,y,by=2,dlm=%str( ));
	%local i;
	%let i=%eval( (&x-1)*2 +&y);
	%scan(&str,&i,&dlm)
%mend;
