%macro AHGtranspec(dsn,out=,where=1,open=1);
%local   maxL;
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn)Transpec;
%AHGvarinfo(&dsn,out=&out,info=  length );

proc sql noprint;
  select distinct put(max(length),best.) into :maxL
  from &out
  ;quit;


data &out;

  set &dsn;
  array allchar _character_;
  array allnum _numeric_;
  keep vname line;
  format vname $30. line $&maxL.. ;
  do over allnum;
    vname=vname(allnum);
    line=%AHGputn(allnum);
    output;
  end;

  do over allchar;
    vname=vname(allchar);
    line=allchar;
    output;
  end;
  where &where;
run;

%if &open %then %AHGopendsn;

%mend;
