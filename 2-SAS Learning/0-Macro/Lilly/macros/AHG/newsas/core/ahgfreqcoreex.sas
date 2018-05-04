%macro AHGfreqCoreEX(dsn,var,out=,by=,print=0,rename=1
,keep=value cell frequency percent
);
%if %AHGblank(&out) %then %let out=&sysmacroname;
%local core;
%AHGgettempname(core);
data &core;
  set &dsn;
run;

proc freq data=&core(keep=&var %if %AHGnonblank(&by) %then  &by; rename=(&var=value));
    table value;
    ods output OneWayFreqs=%AHGbarename(&out);
    %if %AHGnonblank(&by) %then by  &by;;
run;
%if not &rename %then 
  %do;
  data  %AHGbarename(&out)(keep=&keep &var %if %AHGnonblank(&by) %then  &by;);
    set %AHGbarename(&out);
    rename value=&var;
    cell=catx(' ',%AHGputn(frequency),' (',%AHGputn(percent,6.1),')');
  run;
  %end;
%else 
  %do;
  data  %AHGbarename(&out)(keep=&keep value %if %AHGnonblank(&by) %then  &by;);
    set %AHGbarename(&out);
    cell=catx(' ',%AHGputn(frequency),' (',%AHGputn(percent,6.1),')');
  run;
  %end;
%if &print %then %AHGprt;
%mend;

