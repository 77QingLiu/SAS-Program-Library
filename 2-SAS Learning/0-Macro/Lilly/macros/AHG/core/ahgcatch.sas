
%macro AHGcatch(dsn,value,out=,strict=1);
%local type;
%if %bquote(%substr(%bquote(&value),1,1))=%str(%')  
or %bquote(%substr(%bquote(&value),1,1))=%str(%") %then %let type=char;
%else %let type=num;
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn)ct;
data &out;
  set &dsn;
  array allchar _character_;
  array allnum _numeric_;
  %if &type=char %then
    %do;
    do over allchar;
    if 
    %if &strict %then  upcase(allchar)=%upcase(&value);
     
    %else index(upcase(allchar),%upcase(&value)); 
    then do;output;return; end;
    end;
    %end;
  %else
    %do;
    do over allnum;
    if allnum=&value then do;output;return; end;
    end;
    %end;

run;

%mend;
