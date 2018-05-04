%macro AHGtran(dsn,var,colvar,ordvar,colOrd=,out=);
  %local thedsn;
  %AHGgettempname(thedsn);
  data &thedsn;
    set &dsn;
    keep &var &colvar &ordvar;
  run;
  %AHGfreeloop(&thedsn,&colvar
,cmd=put
,out=outAhuige
,in=Ahuige
,url=vxwmc
,execute=1
,del=1
,addloopvar=0);
%mend;


%AHGtran(sashelp.class,height,sex);
