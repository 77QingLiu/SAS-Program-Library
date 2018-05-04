%macro AHGdsnexists(dsn);
  %local out;
  %let out=0;
  %local lib dset;
  %if %index(&dsn,.) %then 
    %do;
    %let lib=%upcase(%scan(&dsn,1,.));
    %let dset=%upcase(%scan(&dsn,2,.));
    %end;
  %else
    %do;
    %let lib=WORK;
    %let dset=%upcase(dsn);
    %end;
    
  proc sql noprint;
    select 1 into :out
    from sashelp.vtable
    where libname="&lib" and memname="&dset"
    ;quit;
  &out
  
%mend;
