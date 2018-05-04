%macro AHGurlMacros(startwith=AHGurl,into=AHGmacs);
  proc sql noprint;
    select name into :&into   separated by ' '  
    from sashelp.vmacro
    where index(name,%upcase("&startwith"))=1
    ;quit;
%mend;
