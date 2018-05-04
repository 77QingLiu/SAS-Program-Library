%macro AHGindex2(str,dlm);
%local i one result;
%let result=0;
%do i=1 %to %length(&str);
%if %qsubstr(&str,&i,1) = &dlm and (&result=0) and (&one=1) %then %let result=&i;
%if %qsubstr(&str,&i,1) eq &dlm %then %let one=1;
%end;
&result
%mend;
