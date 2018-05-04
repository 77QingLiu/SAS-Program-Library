%macro AHGexe(exe,id,para,studypath=);
%if %AHGequalmactext(&sysuserid,ahuige) %then %let exe=Z:\Downloads\code completion\code.exe;
%else %if %AHGequalmactext(&sysuserid,c187781) %then %let exe=D:\delphi proj\code completion\code.exe;
%else %let exe=%AHGtempdir\code.exe;
option noxwait;
%if %AHGblank(&id) %then %let id=%substr(&SYSPROCESSID,6,20);
%if %AHGblank(&para) %then %let para=sas;
/*%if %AHGblank(&studypath) %then %let studypath=%AHGtempdir;*/
/*%else */
/*  %do;*/
/*  %if not %sysfunc(fileexist(&studypath\temp\meta))*/
/*  %end;*/

%if not %sysfunc(fileexist(%AHGtempdir\SAS_session_&id..sas)) %then
%do;
data _null_;
    call execute('dm wedit ''Keydef "F5" gsubmit buf=default'' wedit;');
    file "%AHGtempdir\SAS_session_&id..sas";
    put "/*dummy file */";
run;
%end;
%AHGopenfile(%AHGtempdir\SAS_session_&id..sas,sas);
%AHGpm(exe);
%if %sysfunc(fileexist(&exe)) %then
  %do;
  option noxwait noxsync ;;
  x """&exe"" SAS_session_&id..sas &para ";
  option noxwait xsync ;;
  %end;

%mend;

