%macro AHGscanReplace(str,n,to,dlm=%str( ));
	%local i outstr;
	%do i=1 %to %AHGcount(&str,dlm=&dlm);
	%if &i ne &n %then %let outstr=&outstr&dlm%scan(&str,&i,&dlm);	
	%else %let outstr=&outstr&dlm&to;	
	%end;
	%substr(&outstr,2)
%mend;
/*%put %ahgscanReplace(ok@ ok@ ok, 2,no,dlm=@);*/
/*%put %ahgscanReplace(ok  ok  ok, 1,no );*/

