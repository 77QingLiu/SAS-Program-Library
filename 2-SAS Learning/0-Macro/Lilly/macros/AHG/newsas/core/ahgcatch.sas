%macro AHGcatch(dsn,value,out=,strict=1,open=1,justopen=0);
%local type;
%if %bquote(%substr(%bquote(&value),1,1))=%str(%')  
or %bquote(%substr(%bquote(&value),1,1))=%str(%") %then %let type=char;
%else %let type=num;
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn)ct;
data &out(label="&dsn Temp dataset");
  dummyASDFJSALFJSA='';
  DUMMYnumSADFSA=.;
  DROP dummyASDFJSALFJSA DUMMYnumSADFSA;
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

%if &open %then %AHGopendsn(&out,justopen=&justopen);


%mend;
