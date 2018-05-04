%macro AHGmkdir(dir,drive=D:,execute=1);
  %local dirstr cnt i   ITEM  found stmt;
  %let cnt=0;
  %let found=0;
  %let dirstr=%AHGremoveslash(%AHGanySlash(&dir,%AHGdelimit,compress=0))%AHGdelimit%str(xxx);
  %AHGpm(dirstr);
  %do %while(%AHGnonblank(&dirStr) and &found=0 );
  %AHGpop(dirstr,item,dlm=%AHGdelimit );
  %AHGpm(dirStr);
  %let found=%sysfunc(fileexist(&dirStr));
  %if &found=0 %then %AHGincr(cnt);
/*  %else %AHGpm(dirstr cnt);*/
  %end;


  %let dirstr=%AHGremoveslash(%AHGanySlash(&dir,%AHGdelimit ,compress=0))%AHGdelimit%str(xxx);
    %do i=1 %to &cnt;
    %AHGpop(dirstr,item,dlm=%AHGdelimit );
    %if %AHGnonblank(&dirstr) %then %let stmt=%bquote(x mkdir  "&dirstr" %str(;)&stmt );
  /*  %if not %sysfunc(fileexist(&newdir)) %then x mkdir "&newdir";*/
    %end;
  %AHGpm(stmt);
  %if &execute %then %unquote(&stmt);
%mend;
