%macro AHGdescDSN(dsn);
  %local varinfo thestat;
  %AHGgettempname(varinfo);
  %AHGvarinfo(&dsn,out=&varinfo,info= name  type  length num fmt);
  data _null_;
    set &varinfo end=end;
    format thestat $32222.;
    retain thestat;
    thestat=trim(thestat)||' format '||trim(name)||' '||trim(fmt)||';';
    if end then call symput('thestat',thestat);
  run;
  %put &thestat;
%mend;


