%macro AHGclip;

/*%AHGclearlog;*/
filename ahgclip clear;
filename ahgclip clipbrd;

%local cmdfile findvar rdm line;
%let rdm=%AHGrdm;
%let cmdfile=%AHGtempdir\&rdm..txt;
%if %sysfunc(fileexist(&cmdfile)) %then x del "&cmdfile":;

data   _null_;
  infile ahgclip truncover;
  file "&cmdfile";
  format cmd  line $500.;
  input line 1-500 ;
  call symput('line',trim(line));
  if exist(line) then 
    do;
    cmd='%AHGopendsn('||trim(line)||');';
    put cmd;
    end;  
  else if index(line,'\')  OR  index(line,'&') then call execute('%AHGopenfile('|| line||');');
  else DO;call symput('findvar','1');    ;END;
run;



%AHGpm(findvar);



%if &findvar=1 %then
%do;
%local vcolumn;
%if %sysfunc(exist(irtfl.vcolumn)) %then %let vcolumn=irtfl.vcolumn;
%else %let vcolumn=sashelp.vcolumn;;
  data findvar&rdm;
    file "&cmdfile";
    do i=1 to nobs;
    set &vcolumn nobs=nobs;
    where name=upcase("&line") and (libname='ADAM' or libname='SDTM');
    ahgstr=catx(' ',"data ",compress(trim(libname)||'_'||trim(memname)||   "_T"), ";format usubjid subjid $50.; set ",
compress(libname||'.'||memname),";  keep usubjid subjid &line ;", 'run; %AHGopendsn(dsn=',compress(trim(libname)||'_'||trim(memname)||   "_T")," );");
    put ahgstr;
/*    call execute(ahgstr);*/
    leave;
    end;
    ;
  run;
%end;
;
/*x " start &cmdfile";*/

%if %sysfunc(fileexist(&cmdfile)) %then %inc "&cmdfile";
;


%mend;
