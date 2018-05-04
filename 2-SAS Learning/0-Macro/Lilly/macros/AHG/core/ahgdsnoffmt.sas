%macro AHGdsnOfFmt(fmt,lib=work,out=&fmt,var=&fmt);
/* create a dsn with all possible format values
with a variable name =fmt 
*/
proc format library=&lib CNTLOUT=&out(where=(fmtname=upcase("&fmt")) keep=fmtname start label type );
run;
%local type;
%AHGdistinctValue(&out,type,into=type,dlm=@);

data &out;
  set &out;
  %if &type=N %then &var=input(left(start),best.);
  %else &var=start;
  ;
  keep start &var label;
run;
%mend;
