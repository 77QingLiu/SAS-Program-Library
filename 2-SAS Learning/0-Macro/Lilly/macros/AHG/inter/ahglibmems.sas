/***********************************
get all datasets'  names;
***********************************/

%macro AHGlibMems(lib=work,locallist=datalist);
  %global &locallist;
  proc sql noprint;
    select compress("&lib.."||memname) into :&locallist separated by ' '
    from sashelp.vtable
    where libname=upcase("&lib");
  quit;
  
%mend;

