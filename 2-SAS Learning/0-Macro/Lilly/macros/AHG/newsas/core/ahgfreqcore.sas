%macro AHGfreqCore(dsn,var,by=,out=,print=0,rename=1,
keep=cell frequency percent,tran=
,tranBy=
,cell=put(frequency,4.)||' ('||left(put(percent,5.1))||')'
);
%if %AHGblank(&out) %then %let out=&sysmacroname;
ods listing close;
proc freq data=&dsn(keep=&var &by  );
    table &var;
    %if not %AHGblank(&by) %then by &by;;
    ods output OneWayFreqs=&out(keep=&var  CUMFREQUENCY percent  frequency &by);
run;
ods listing;

%if %AHGpos(&keep,cell) %then 
%do;
data &out;
  set &out;
  cell=&cell;
run;
%end;

%if &rename %then 
%do;
data &out;
  set &out(rename=(&var=value));
run;
%end;


%if not %AHGblank(&tran) %then 
%do;

data &out.Notran;
  set &out;
run;
%if not %AHGblank(&TranBy) %then %AHGdatasort(data =&out , out = , by =&TranBy ) ;

proc transpose data=&out out=&out(drop=_name_);
  var 
  %if %AHGpos(&keep,cell)  %then cell;
  %else 
%AHGremoveWords(&keep,value &var,dlm=%str( )) ;
  ;
  id &tran;
  ;
  %if not %AHGblank(&TranBy) %then by &TranBy; ;
run;

%end;
%else 
  %do;
  data &out;
    set &out(keep=&keep &by %if not &rename %then &var; %else value;);
  run;
  %end;



%if &print %then %AHGprt;
%mend;
