%macro AHGmergelike(dsn1,dsn2,out,by=,by1=,by2=,j=matched);
%if %AHGnonblank(&by) %then %let by1=&by;
%if %AHGnonblank(&by) %then %let by2=&by;
%local one two drop;
%AHGgettempname(one);
%AHGgettempname(two);

%if %AHGeqm(&by1,&by2) %then %let drop=&by1;


data &one(drop=&drop);
  set &dsn1;
  SDFALJPIJDASDFKJDFJKE=compbl(upcase(&by1));
run;

data &two;
  set &dsn2;
  SDFALJPIJDASDFKJDFJKE=compbl(upcase(&by2));
run;

%AHGmergedsn(&one,&two,&out(drop=SDFALJPIJDASDFKJDFJKE),by=SDFALJPIJDASDFKJDFJKE,joinstyle=&j/*left right full matched*/);

%mend;
