%macro AHGclearglobalmac(begin=);
%local allmac len;
%if %AHGblank(&begin) %then %let len=0;
%else %let len=%length(&begin);
%AHGgettempname(allmac);
data deletefromithere; 
  data &allmac;
    set sashelp.vmacro(keep=name scope);
    where scope='GLOBAL' and (substr(upcase(name),1,&len)=upcase("&begin") or %AHGblank(&begin));
  run;  
  
  

    %local drvrmacs;    
    proc sql noprint;
    select '/* clear '||name||'*/'||' %symdel '|| name || '/NOWARN ;' into :drvrmacs separated by ' '
    from &allmac
    ;
    quit;
    %PUT %NRBQUOTE(&DRVRMACS);
    &drvrmacs;
data writetofilefromithere;
%mend;
