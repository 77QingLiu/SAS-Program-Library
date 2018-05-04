%macro AHGtype(dsn,var);
%local did;
%let did=  %sysfunc(open(&dsn,in));
%sysfunc(vartype(&did,%sysfunc(varnum(&did,&var))))
%mend;
