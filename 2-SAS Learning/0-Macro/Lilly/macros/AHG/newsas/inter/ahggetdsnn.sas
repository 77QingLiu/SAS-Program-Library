%macro AHGgetdsnn(lib=work,dsn=,outM=);
  proc sql noprint;
    select nobs into :nobs
    from  sashelp.vtable
    where libname=upcase("&lib") and memname=upcase("&dsn")
    ;
  quit;
%mend;
