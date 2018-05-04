%macro AHGlibpath(lib,into);
%if not %index(&thedsn,.) %then %let lib=Work;
%else %let lib=%scan(&lib,1,.);

%if %upcase(lib)=WORK %then ;
%else %if %upcase(lib)=SASHELP %then ;
%else %if %upcase(lib)=SASUSER %then ;
%ELSE
%do;
data _null_;
  set sashelp.vlibnam(where=(upcase("&lib")=libname));
  call symput("&into",path);
run;
%end;

%mend;
