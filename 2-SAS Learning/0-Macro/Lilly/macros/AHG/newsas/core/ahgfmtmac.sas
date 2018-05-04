%macro AHGfmtmac(dsn,var=,url=);
%local varinfo;
%AHGgettempname(varinfo)
%AHGvarinfo(&dsn,out=&varinfo,info= name  type  length num fmt);

data _null_;
  set &varinfo;
  format command $200.;
  command=' %global &url.type'||name||';'||' %global &url.fmt'||name||';';
  call execute(command);
run;

data _null_;
  set &varinfo;
  call symput("&url.type"||name,type);
  call symput("&url.fmt"||name,fmt);
run;

%mend;

/*%AHGfmtmac(sashelp.class);*/
