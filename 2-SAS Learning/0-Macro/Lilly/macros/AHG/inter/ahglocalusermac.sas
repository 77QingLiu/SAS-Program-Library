%macro AHGlocalusermac;
    %local usermacs;    
    proc sql noprint;
    select ' %local '|| name || ';' into :usermacs separated by ' '
    from sashelp.vmacro
    where scope='GLOBAL'
    ;
    &usermacs;
    quit;
%mend;
