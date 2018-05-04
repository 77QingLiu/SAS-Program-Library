%macro AHGsupercmp(dsn1,dsn2,by=,cmp1=,cmp2=,id=,keepbyvar=1,open=0);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);
	%if &cmp1=cmp1 or &cmp1 eq %then %let cmp1=cmp_%sysfunc(tranwrd(&dsn1,.,_));
	%if &cmp2=cmp2 or &cmp2 eq %then %let cmp2=cmp_%sysfunc(tranwrd(&dsn2,.,_));

  data &cmp1;
  run;
  data &cmp2;
  run;
  proc sort data=&dsn1 out=&cmp1%if &keepbyvar=1 %then (keep=&by);;;
    by &by;

  run;

  proc sort data=&dsn2 out=&cmp2%if &keepbyvar=1 %then (keep=&by);;;;
    by &by;

  run;

  proc compare data=&cmp1 comp=&cmp2;
    %if &id ne %then id &id;;
  run;
  %if &open %then %AHGopendsn(cmp1);;
  %if &open %then %AHGopendsn(cmp2);;
%mend;
