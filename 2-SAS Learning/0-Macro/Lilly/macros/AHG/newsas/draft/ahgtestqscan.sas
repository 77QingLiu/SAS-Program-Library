%macro AHGtestqscan(str,n,dlm=%str(%'));
%local i loop word;
%let str=%str( )&str;
%let cnt=0;
%do i=1 %to %length(&str);
%if %eval(%substr(&str,&i,1)=&dlm) %then %AHGinc(cnt);
%else %if &cnt=%eval(&n*2-1)  %then %let word=&word%substr(&str,&i,1);
%end;
%put word=&word;
%mend;

