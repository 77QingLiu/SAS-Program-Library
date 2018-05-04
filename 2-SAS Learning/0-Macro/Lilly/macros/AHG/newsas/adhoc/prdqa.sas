%macro prdqa(file,folder,actions=);
%local from ext prd qa dsn;
%let qa=%sysfunc(tranwrd(&pathroot,\prd\,\qa\));
%let prd=%sysfunc(tranwrd(&pathroot,\qa\,\prd\));
%if %AHGpos(&file,.sas7bdat) %then  %let from=data\shared\adam;
%if %AHGpos(&file,.rtf) %then  %let from=programs_stat\tfl_output;
%if %AHGpos(&file,.log) %then  %let from=programs_stat\system_files;
%if %AHGpos(&folder,adam) %then  %let from=data\shared\adam;
%if %AHGpos(&folder,sdtm) %then  %let from=data\shared\sdtm;

%AHGmkdir(%mysdd(&prd\&from));
%AHGmkdir(%mysdd(&qa\&from));

%if %AHGpos(&actions,down) %then 
%do;
%AHGtolocal(&prd\&from\&file,to=%mysdd(&prd\&from) );
%AHGtolocal(&qa\&from\&file,to=%mysdd(&qa\&from) );
%end;

libname prd "%mysdd(&prd\&from)";
libname qa "%mysdd(&qa\&from)";

%if %AHGpos(&actions,open) %then 
  %do;
  %if %AHGpos(&file,.sas7bdat) %then 
    %do;
    %let dsn=%scan(&file,1);
    %AHGopendsn(prd.&dsn);
    %AHGopendsn(qa.&dsn);
    %end;
  %if %AHGpos(&file,.rtf) %then 
    %do;
    %AHGopenfile(%mysdd(&prd\&from\&file));
    %AHGopenfile(%mysdd(&qa\&from\&file));
    %end;
  %end;

%if %AHGpos(&actions,tailor) %then 
  %do;
  %if %AHGpos(&file,.rtf) %then 
    %do;
    %AHGrtftotxt(%mysdd(&prd\&from\&file),,%mysdd(&prd\&from\&file).txt);
    %AHGrtftotxt(%mysdd(&qa\&from\&file),,%mysdd(&qa\&from\&file).txt);
    %AHGopenfile(%mysdd(&prd\&from\&file).txt);
    %AHGopenfile(%mysdd(&qa\&from\&file).txt);
    %end;
  %end;

%if %AHGpos(&actions,comp) %then 
  %do;
  %if %AHGpos(&file,.sas7bdat) %then 
    %do;
    %let dsn=%scan(&file,1);
    proc compare data=qa.&dsn comp=prd.&dsn;
    run;
    %end;
  %end;

%mend;

