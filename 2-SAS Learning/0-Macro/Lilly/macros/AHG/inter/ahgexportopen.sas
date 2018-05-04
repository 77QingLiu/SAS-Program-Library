%macro AHGexportOpen(dsn,n=11);
%if %sysfunc(exist(&dsn)) %then 
%do;
%local info all varlist ;
%let varlist=;
%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
%AHGgettempname(info);
%AHGgettempname(all);

%AHGvarinfo(&dsn,out=&info,info=label);

proc transpose data=&info out=&info(drop=_NAME_);
  var label;  
run;


%AHGsetprint(&info &dsn,out=&all,print=0);

%AHGpm(varlist);

%AHGrenamekeep(&all,out=new&all,names=&varlist,keepall=1);

x "del %AHGtempdir\&dsn..xls/f";





proc export data=new&all(obs=&n)
   outfile="%AHGtempdir\&dsn..xls"
   dbms=excel 
   replace
   ;
run;

x  "%AHGtempdir\&dsn..xls";
%end;

%mend;
