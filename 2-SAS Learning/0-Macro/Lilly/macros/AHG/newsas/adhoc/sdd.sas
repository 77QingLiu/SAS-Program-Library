%macro SDD(dir);
  %local start;
  %Let dir=%sysfunc(compress(&dir));
  %let dir=%AHGanySlash(&dir,toslash=%str(/));

  %let start=%AHGpos(&dir,lillyce/);
  %let dir=/lillyce/%substr(&dir,&start+8);
  &dir
%mend;



