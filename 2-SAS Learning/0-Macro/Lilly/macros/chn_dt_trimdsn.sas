%macro chn_dt_trimdsn(dsn,out=,min=3,left=1);
%macro _KQNaddcomma(mac,comma=%str(,) );
%if %_KQNnonblank(&mac) %then %sysfunc(tranwrd(     %sysfunc(compbl(&mac)),%str( ),&comma       ))   ;
%mend;
%macro _KQNallchar(dsn,into=);
%local allchar ;
%_KQNgettempname(allchar);
data deletefromithere;
%_KQNvarinfo(&dsn,out=&allchar,info= name  type );
 
data &allchar;
set &allchar(where=(type='C'));
run;
 
%_KQNdistinctValue(&allchar,name,into=&into,dlm=%str( ));
data writetofilefromithere;
 
 
%mend;
%macro _KQNbareName(dsn);
	%_KQNbasename(%_KQNpurename(&dsn))
%mend;
%macro _KQNbasename(dsn);
	%if %index(&dsn,.) %then %scan(&dsn,2,%str(.%());
	%else %scan(&dsn,1,%str(.%());
%mend;
%macro _KQNblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;
%macro _KQNcount(line,dlm=%str( ));
%local i _KQN66TheEnd;
%let i=1;
%do %until(&_KQN66TheEnd=yes);
%if  %qscan(%bquote(&line),&i,&dlm) eq %str() %then
%do;
%let _KQN66TheEnd=yes;
%eval(&i-1)
%end;
%else %let i=%eval(&i+1);
%end;
 
%mend;
%macro _KQNdistinctvalue(dsn,var,sort=1,into=,dlm=@,quote=0);
%local item varIsNum ;
%let varIsnum=1;
 
%if   &quote %then %_KQNvarisnum(&dsn,&var,into=varIsNum);
 
%let item=&var;
%if %eval(&quote and not &varIsNum )%then %let item=quote(&var);
 
%if not &sort %then
%do;
data _null_;
format line&var $32333.;
retain line&var;
set &dsn(keep=&var) end=end;
line&var=catx("&dlm",line&var,&var);
if end then call symput("&into",line&var);
run;
%end;
%else
%do;
proc sql noprint;
select distinct
 
&item
into :&into separated by "&dlm"
from &dsn
;quit;
%end;
%let &into=%trim(&&&into);
 
%mend;
%macro _KQNequaltext(text1,text2);
	(upcase(&text1)=upcase(&text2))
%mend;
%macro _KQNgettempname(tempname,start=,useit=0);
 
%if %_KQNblank(&start) %then %let start=T_&tempname;
%if %length(&start)>10 %then %let start=%substr(&start,1,10);
%local  _KQN9rdn  i;
%do %until (not %sysfunc(exist(&&&tempName))  );
%let _KQN9rdn=;
%do i=1 %to 7;
%let _KQN9rdn=&_KQN9rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(0))*24),1,2))) );
%end;
%let &tempname=&start._&_KQN9rdn;
%end;
%put &tempname=&&&tempname;
%if &useit %then
%do;
data &&&tempname;
run;
%end;
 
 
%mend;
%macro _KQNnonblank(str);
not %_KQNblank(&str)
%mend;
%macro _KQNordvar(dsn,vars,out=,keepall=0);
%local sql;
%_KQNgettempname(sql);
%if &keepall %then
%do;
%local restvardsn ;
%let restvardsn=;
%_KQNgettempname(restvardsn);
 
data &restvardsn;
set &dsn(drop=&vars);
run;
%end;
%if %_KQNblank(&out) %then %let out=%_KQNbasename(&dsn);
proc sql;
create table &sql as
select %_KQNaddcomma(&vars)
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
%macro _KQNpm(Ms);
%local Pmloop2342314314 mac;
%do Pmloop2342314314=1 %to %_KQNcount(&Ms);
%let mac=%scan(&Ms,&Pmloop2342314314,%str( ));
%put &mac=&&&mac;
%end;
%mend;
 
%macro _KQNpureName(dsn);
	%if %index(&dsn,%str(%()) %then %scan(&dsn,1,%str(%());
	%else &dsn;
%mend;
%macro _KQNrdm(length,seed=0);
%local i rdn;
%if %_KQNblank(&length) %then %let length=5;
%do i=1 %to &length;
%let rdn=&rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(&seed))*24),1,2))) );
%end;
&rdn
%mend;
%macro _KQNvarinfo(dsn,out=varinfoout,info= name  type  length num fmt);
%local i _KQN3allinfo;
%let _KQN3allinfo=name  type   length  format  informat label ;
 
data &out(keep=&info);
length dsn $40 name $32  type $4  length 8 format $12  informat $10 label $50  num 8 superfmt fmt $12;
tableid=open("&dsn",'i');
varlist=' ';
dsn="&dsn";
do i=1 to  attrn(tableid,'nvars');
%do i=1 %to %_KQNcount(&_KQN3allinfo);
%if %scan(&_KQN3allinfo,&i) ne num
and %scan(&_KQN3allinfo,&i) ne fmt
and %scan(&_KQN3allinfo,&i) ne superfmt
%then  %scan(&_KQN3allinfo,&i)= var%scan(&_KQN3allinfo,&i)(tableid,i);;
%end;
num=varnum(tableid,varname(tableid,i)) ;
if type='C' then fmt='$'||compress(put(length,best.))||'.';
else fmt=compress(put(length,best.))||'.';
superfmt=format;
if missing(superfmt) then superfmt=fmt;
output;
end;
rc=close(tableid);
run;
 
%mend;
%macro _KQNvarisnum(dsn,var,into=varIsNum);
%local varinfo;
%_KQNgettempname(varinfo);
%_KQNvarinfo(&dsn,out=&varinfo,info= name type);
data _null_;
set &varinfo(where=(%_KQNequaltext(name,"&var")  ) );
if type='N' then call symput("&into",'1');
else call symput("&into",'0');
run;
%mend;
%macro _KQNvarlist(dsn,Into=,dlm=%str( ),global=0,withlabel=0,print=0);
%if %sysfunc(exist(&dsn)) %then
%do;
data deletefromithere;
%if &global %then %global &into;;
data _null_;
length varlist $ 8000;
 
tableid=open("&dsn",'i');
varlist=' ';
do i=1 to  attrn(tableid,'nvars');
varlist=trim(varlist)||"&dlm"||varname(tableid,i);
%if &withlabel %then       varlist=trim(varlist)||"&dlm "||'/*'||trim(varlabel(tableid,i))||'*/';; ;
end;
call symput("&into", varlist);
rc=close(tableid);
run;
%end;
%else %let &into=;
%if &print %then %_KQNpm(&into);
data writetofilefromithere;
%mend;
%if %_KQNblank(&out) %then %let out=%_KQNbarename(&dsn);
%local max charlist i count rdn len varlist;
 
%_KQNvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
/*%_KQNgettempname(max);*/
 
%_KQNallchar(&dsn,into=charlist);
 
%let count=%_KQNcount(&charlist);
%let rdn=%_KQNrdm(20);
 
data _null_;
retain
%do i=1 %to &count;
&rdn.&i
%end;
&min
;
set &dsn end=end;
%do i=1 %to &count;
if length(%scan(&charlist,&i))> &rdn.&i then &rdn.&i=length(%scan(&charlist,&i));
%end;
 
keep &rdn:;
if end then  call symput('len',compbl(''
%do i=1 %to &count;
||put(&rdn.&i,best.)
%end;
))
 
;
run;
%local rdm;
%let rdm=%_KQNrdm(25);
data &out(rename=(
%do i=1 %to &count;
&rdm&i=%scan(&charlist,&i)
%end;
));
format
%do i=1 %to &count;
&rdm&i $%scan(&len,&i).
%end;
;
drop
%do i=1 %to &count;
%scan(&charlist,&i)
%end;
;
set &dsn;
%do i=1 %to &count;
%if &left %then &rdm&i=left(%scan(&charlist,&i));
%else &rdm&i=%scan(&charlist,&i);
;
%end;
 
run;
 
%_KQNordvar(&out,&varlist,out=&out,keepall=0);
 
%mend;
 
