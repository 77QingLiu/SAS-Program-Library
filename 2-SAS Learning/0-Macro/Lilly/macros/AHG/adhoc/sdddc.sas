%macro SDDDC(dir,pre=);
  %if %AHGblank(&pre) %then 
  %do;
  %let pre=G:;
  %if %symexist(mapdrive) %then %if not %AHGblank(&mapdrive) %then %let pre=&mapdrive;
  %end;


  %local start;
  %Let dir=%sysfunc(compress(&dir));
  %let dir=%AHGanySlash(&dir,toslash=\);

  %let start=%AHGpos(&dir,lillyce\);
  %let dir=&pre\lillyce\%substr(&dir,&start+8);
  &dir
%mend;

