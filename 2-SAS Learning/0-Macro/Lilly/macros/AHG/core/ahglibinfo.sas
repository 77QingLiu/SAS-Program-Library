%macro AHGlibinfo(lib,out=,info=dsn name  label);
%local dsnlist;
%AHGdsnInLib(lib=&lib,list=dsnlist);
%AHGpm(dsnlist);
%local all;
%macro dosomething(dsn);
%local infodsn;
%AHGgettempname(infodsn);
%let all=&all &infodsn;
%AHGvarinfo(&dsn,out=&infodsn,info=&info  );
%mend;
%AHGfuncloop(%nrbquote( dosomething(ahuige) ) ,loopvar=ahuige,loops=&dsnlist);

data &out;
  set &all;
run;
%mend;
