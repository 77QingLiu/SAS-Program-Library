%macro AHGup(dir,level );
  %if %AHGblank(&level) %then %let level=1;
  %local slash  i count updir;
  %let dir=%sysfunc(compress(&dir));
  %let slash=%bquote(/);
  %if %index(&dir,\) %then %let slash=\;
  %if %bquote(%substr(&dir,1,1))=&slash %then %let updir=&slash%scan(&dir,1,&slash);
  %else %let updir=%scan(&dir,1,&slash);
  %let count=%AHGcount(&dir,dlm=&slash);
  %do i=2 %to %eval(&count-&level);
  %let updir=&updir&slash%scan(&dir,&i,&slash);
  %end;
  &updir
%mend;
