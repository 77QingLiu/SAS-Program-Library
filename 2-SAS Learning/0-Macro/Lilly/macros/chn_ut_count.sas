%macro chn_ut_count(line,dlm=%str( ));
%local i _CGJ66TheEnd;
%let i=1;
%do %until(&_CGJ66TheEnd=yes);
%if  %qscan(%bquote(&line),&i,&dlm) eq %str() %then
%do;
%let _CGJ66TheEnd=yes;
%eval(&i-1)
%end;
%else %let i=%eval(&i+1);
%end;
 
%mend;
