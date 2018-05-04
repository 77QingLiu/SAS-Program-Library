%macro AHGclearusermac;
	%if  not	%AHGonwin %then %goto myexit;
  data afterruntot;
    set sashelp.vmacro(keep=name scope);
    where scope='GLOBAL';
  run;  
  
  %local beforeruntot;
  
  %if exist(sasuser.beforeruntot) %then %let beforeruntot=yes;
  ;
  
  %IF &BEFORERUNTOT=yes %then
    %do;
    %local drvrmacs;    
    proc sql noprint;
    select '/* clear '||name||'*/'||' %symdel '|| name || '/NOWARN ;' into :drvrmacs separated by ' '
    from afterruntot
    where name not in (select name from sasuser.beforeruntot)
    ;
    quit;
    %PUT %NRBQUOTE(&DRVRMACS);
    &drvrmacs;
    %end;
    %myexit:;
%mend;
