%macro AHGfreqCoreold(dsn,var,by=,out=,print=0,rename=1,
keep=value frequency percent,tran=0
,cell=put(frequency,4.)||'('||put(percent,5.2)||')'
);
%if %AHGblank(&out) %then %let out=&sysmacroname;
proc freq data=&dsn(keep=&var &by rename=(&var=value));
    table value;
    %if not %AHGblank(&by) %then by &by;;
    ods output OneWayFreqs=&out(keep=&keep &by);
run;

%if not %AHGblank(&cell) %then 
%do;
data &out;
  set &out;
  cell=&cell;
run;
%end;


%if not &rename %then 
%do;
data &out;
  set &out;
  rename value=&var;
run;
%end;

%if &tran %then 
%do;

proc transpose data=&out;
  var 
  %if not %AHGblank(&cell) %then cell;
  %else %AHGremoveWords(&keep,value &var,dlm=%str( )) ;
  ;
  %if not &rename %then id &var;
  %else id value;
  ;
  %if not %AHGblank(&by) %then by &by; ;
run;

%end;


%if &print %then %AHGprt;
%mend;
