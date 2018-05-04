%macro AHGdsnFilename(dsn,ext=.sas7bdat);
  %local lib mem del line out;
  %if not %index(&dsn,.) %then %let dsn=work.&dsn;
  %let lib=%scan(&dsn,1,.);
  %let mem=%scan(&dsn,2,.);
  %let del=%AHGdelimit;
  %if %AHGequalmactext(&lib,sashelp) 
      or %AHGequalmactext(&lib,work) %then &lib&del&mem.&ext;
  %else 
    %do;
    %if not %index(%sysfunc(pathname(&lib)),%str(%()) %then  %sysfunc(pathname(&lib))&del&mem.&ext;
    %else 
    %do;
    %let line=%qscan(%sysfunc(pathname(&lib)),1);
    %qscan(&line,1)&del&mem.&ext;
    %end;
    %end;
%mend;

