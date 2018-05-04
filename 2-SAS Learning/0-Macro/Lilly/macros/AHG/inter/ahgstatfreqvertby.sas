%macro AHGstatfreqvertby(dsn,var,out=
,stats=n percent
,missing=0
,print=0
,by=
,varfmt=
,layout=hori /*hori vert*/

);
%local varIsNum mydsn ;
%if %AHGblank(&out)  %then %let out=&sysmacroname.out; 

%AHGvarisnum(&dsn,&var,into=varIsNum);
%local defaultdsn;
%AHGgettempname(defaultdsn);
%if %AHGblank(&varfmt) %then 
%do;
proc sql;
  create table &defaultdsn as
  select distinct &var as ahuigebycol,&var as byvar
  from &dsn
  order by &var
  ;quit;
%end;
%else %if %index(&varfmt,\) %then
%do;
data &defaultdsn;
  format ahuigebycol $50.;
  %do i=1 %to %AHGcount(&varfmt,dlm=#);
  ahuigebycol=%AHGscan2(&varfmt,&i,2,dlm=#,dlm2=\);
  byvar=&i;
  output;
  %end;
run;
%end;
%else %if not %index(&varfmt,\) and not %AHGblank(&varfmt) %then
%do;
proc sql;
  create table &defaultdsn as
  select distinct &varfmt as ahuigebycol,&var as byvar
  from &dsn
  order by &var
  ;quit;
%end;




%local  byvalues byloop byN;

%AHGdistinctValue(&dsn,&by,into=byvalues,quote=1);
  
%let byN=%AHGcount(&byvalues,dlm=@);

%do byloop=1 %to &byn;
  %if &varIsNum %then %let mydsn=%bquote(&dsn(where=(&by=%scan(&byvalues,&byloop,@))))   ;
  %else %let putfmt=%bquote(&dsn(where=(&by="%scan(&byvalues,&byloop,@)")))   ;
  %local tempdsn&byloop;
  %local alltempdsn;
  %AHGgettempname(tempdsn&byloop);  
  %let alltempdsn=&alltempdsn &&tempdsn&byloop;
  %AHGstatfreqvert(&mydsn,&var,varfmt=&varfmt,stats=&stats,print=0
,out=&&tempdsn&byloop,missing=&missing);
proc sql;
  create table   &&tempdsn&byloop(drop=rightbycol) as
  select l.ahuigebycol,r.*
  from &defaultdsn as l left join &&tempdsn&byloop(rename=(ahuigebycol=rightbycol)) as r
    on  l.ahuigebycol=r.rightbycol
    order by l.byvar
  ;quit;

%end;

%if %AHGequalmactext(&layout,vert) %then
%do;
data &out;
  set &alltempdsn;
run;
%end;

%if %AHGequalmactext(&layout,hori) %then
 %AHGmergeprint(&alltempdsn,by=ahuigebycol,drop=,label=label
,out=&out,print=&print
,prefix=ahuigecol
);

%if &print %then %AHGprt;
%mend;
