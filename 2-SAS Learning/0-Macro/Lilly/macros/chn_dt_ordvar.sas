%macro chn_dt_ordvar(dsn,vars,out=,keepall=0);
%macro _OWNaddcomma(mac,comma=%str(,) );
%if %_OWNnonblank(&mac) %then %sysfunc(tranwrd(     %sysfunc(compbl(&mac)),%str( ),&comma       ))   ;
%mend;
%macro _OWNbasename(dsn);
	%if %index(&dsn,.) %then %scan(&dsn,2,%str(.%());
	%else %scan(&dsn,1,%str(.%());
%mend;
%macro _OWNblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;
%macro _OWNgettempname(tempname,start=,useit=0);
 
%if %_OWNblank(&start) %then %let start=T_&tempname;
%if %length(&start)>10 %then %let start=%substr(&start,1,10);
%local  _OWN9rdn  i;
%do %until (not %sysfunc(exist(&&&tempName))  );
%let _OWN9rdn=;
%do i=1 %to 7;
%let _OWN9rdn=&_OWN9rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(0))*24),1,2))) );
%end;
%let &tempname=&start._&_OWN9rdn;
%end;
%put &tempname=&&&tempname;
%if &useit %then
%do;
data &&&tempname;
run;
%end;
 
 
%mend;
%macro _OWNnonblank(str);
not %_OWNblank(&str)
%mend;
%local sql;
%_OWNgettempname(sql);
%if &keepall %then
%do;
%local restvardsn ;
%let restvardsn=;
%_OWNgettempname(restvardsn);
 
data &restvardsn;
set &dsn(drop=&vars);
run;
%end;
%if %_OWNblank(&out) %then %let out=%_OWNbasename(&dsn);
proc sql;
create table &sql as
select %_OWNaddcomma(&vars)
from  &dsn(keep=&vars)
;quit;
 
 
 
%if &keepall %then
%do;
 
data &sql ;
merge &sql &restvardsn;
run;
%end;
%else
%do;
data &out;
set &sql;
run;
%end;
 
 
%mend;
