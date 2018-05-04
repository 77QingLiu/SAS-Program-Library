%macro mySDD(dir,pre=d:);
	%if %AHGblank(&pre) %THEN %let pre=substr(%AHGtempdir,1,2);
  %local start;
  %Let dir=%sysfunc(compress(&dir));
  %let dir=%AHGanySlash(&dir,toslash=\);

  %let start=%AHGpos(&dir,lillyce\);
  %let dir=&pre\lillyce\%substr(&dir,&start+8);
  &dir
%mend;

