%macro AHGopendsn(dsn,relabel=1,justopen=0);
%if %AHGblank(&dsn) %then %let dsn=&SYSLAST;

%if &justopen %then dm  "vt &dsn COLHEADING=NAMES " viewtable:&dsn view=form %str(;)  ;
%else 
  %do;
  %local tempdsn99;
  %AHGgettempname(tempdsn99,start=%AHGbarename(&dsn));
  data &tempdsn99 %if &relabel %then (label="&dsn  Temp dataset ");;
    set &dsn;
  run;

  %local mynobs;
  %let mynobs=0;
  %AHGnobs(sashelp.class,into=mynobs);

  %if &mynobs=0 %then 
  %do;
  %AHGdelta(msg=&dsn is  empty!);
  %end;
  %else dm  "vt &tempdsn99 COLHEADING=labels " viewtable:&tempdsn99 view=form   ;;
  %end;



%mend;
