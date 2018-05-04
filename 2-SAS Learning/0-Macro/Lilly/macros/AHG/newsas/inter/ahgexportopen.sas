%macro AHGexportOpen(dsn,n=11,lookup=,open=1);
%if %sysfunc(exist(&dsn)) %then 
%do;
%local info all varlist ;
%let varlist=;
%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
%AHGgettempname(info);
%AHGgettempname(all);

%AHGvarinfo(&dsn,out=&info,info=%AHG1(&lookup,NAME) label);

proc transpose data=&info out=&info(drop=_NAME_);
  var %AHG1(&lookup,NAME)label;  
run;


%AHGsetprint(&info &dsn,out=&all,print=0);

data &all;
  if _n_=1 then
  do;
  output;
  output;
  end;
  set &all;
  output;
run;

%AHGpm(varlist);

%AHGrenamekeep(&all,out=new&all,names=&varlist,keepall=1);



x "del %AHGtempdir\&dsn..xls/f";

%if &lookup=1 %then
%do;
%local loop;
%let loop=%AHGrdm(20);
data new&all; drop &loop;
  set new&all;
  array ahg_all_char _character_;
  if _n_=1 then
  do;
  do over ahg_all_char;
  ahg_all_char='';
  end;
  output;
  &loop=0;
  do over ahg_all_char;
  &loop=&loop+1;
  ahg_all_char='=IFERROR(HLOOKUP(1,'||BYTE(64+&loop)||'5:'||BYTE(64+&loop)||'6,2,TRUE),"" )';
  end;
  output;
  set new&all;
  end;
  output;
run;

%end;



proc export data=new&all(obs=&n)
   outfile="%AHGtempdir\&dsn..xls"
   dbms=excel 
   replace
   ;
run;



option noxwait;
%if &open %then x  "start %AHGtempdir\&dsn..xls";;

%end;

%mend;
