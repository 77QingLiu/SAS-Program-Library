%macro ahgtran(dsn,out=);
%local outdsn tran varlist;
%AHGgettempname(outdsn);
%AHGgettempname(tran);
 
%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0,print=1);

data &outdsn;
  set &dsn;
  theid=_n_;
  dlm='############################';  
;
run;


proc transpose data=&outdsn out=&tran;
  var   &VARLIST dlm;
  by theid;
run;

data &out(where=(not missing(value)));
  set &tran;
  format value $80.;
  keep _name_ value;
  col1=left(col1);
  begin=1;
  if length(trim(col1))<=50 then 
    do;
    value=col1;
    output;
    end;
  else 
    do end=1 to  length(col1) ;
    if (end-begin+1>=50 and substr(col1,end,1)=' ') or length(col1)=end then
      do;
      if begin ~= 1 then _name_='';
      value=substr(col1,begin,end-begin+1);
      output;
      begin=end+1;
      end;
    end;
run;

%mend;
