%macro AHGqscan(str,n,dlm=%str(%'));
%local i cnt word start end inQuote;
%let cnt=0;   
%let str=&str%str( );
%do i=1 %to %length(&str);
  %if &start=b and %qsubstr(&str,&i,1) eq %then %let end=1;
  %if &start=q and %qsubstr(&str,&i,1) eq &dlm %then %let end=1;
  %if &end=1 %then 
    %do;
    %let start=;
    %let word=&word%qsubstr(&str,&i,1);
    %AHGincr(cnt)
    %if &cnt=&n %then &word;
    %let word=;
    %let end=0;
    %end;
  %else 
    %do;
    %if %AHGblank(&start) and %qsubstr(&str,&i,1) eq &dlm %then %let start=q  ;
    %else %if %AHGblank(&start) and %qsubstr(&str,&i,1) gt %then %let start=b  ;
    %let word=&word%qsubstr(&str,&i,1) ;
    %end;
%end;
%mend;






