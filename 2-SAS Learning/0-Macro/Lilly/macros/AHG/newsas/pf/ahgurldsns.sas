%macro AHGurlDSNs(startwith=AHGurl,into=AHGdsns);
  proc sql noprint;
    select memname into :&into   separated by ' '  
    from sashelp.vstable
    where %AHGequaltext(libname,'work') and index(memname,upcase("&startwith"))=1
    ;quit;
%mend;
