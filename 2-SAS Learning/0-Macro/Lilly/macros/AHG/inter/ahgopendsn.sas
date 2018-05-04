%macro AHGopendsn(dsn);
%if %AHGblank(&dsn) %then %let dsn=_last_;
%local tempdsn;
%AHGgettempname(tempdsn,start=%AHGbarename(&dsn));
data &tempdsn;
  set &dsn;
run;
dm  "vt &tempdsn  " viewtable:&tempdsn view=form ;

%mend;

