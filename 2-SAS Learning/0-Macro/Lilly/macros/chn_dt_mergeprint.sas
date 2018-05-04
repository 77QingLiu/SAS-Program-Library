%macro chn_dt_mergeprint(dsns,by=,drop=,label=label
,out=mergeprintout,print=1
,prefix=
,clean=1
,z=3
,keep=0
,length=500
);
%macro _SLXallchar(dsn,into=);
%local allchar ;
%_SLXgettempname(allchar);
data deletefromithere;
%_SLXvarinfo(&dsn,out=&allchar,info= name  type );
 
data &allchar;
set &allchar(where=(type='C'));
run;
 
%_SLXdistinctValue(&allchar,name,into=&into,dlm=%str( ));
data writetofilefromithere;
 
 
%mend;
%macro _SLXbareName(dsn);
	%_SLXbasename(%_SLXpurename(&dsn))
%mend;
%macro _SLXbasename(dsn);
	%if %index(&dsn,.) %then %scan(&dsn,2,%str(.%());
	%else %scan(&dsn,1,%str(.%());
%mend;
%macro _SLXblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;
%macro _SLXcount(line,dlm=%str( ));
%local i _SLX66TheEnd;
%let i=1;
%do %until(&_SLX66TheEnd=yes);
%if  %qscan(%bquote(&line),&i,&dlm) eq %str() %then
%do;
%let _SLX66TheEnd=yes;
%eval(&i-1)
%end;
%else %let i=%eval(&i+1);
%end;
 
%mend;
 
%macro _SLXdatadelete(lib = , data = );
proc datasets
%if %length(&lib) %then %do; lib = &lib %end;
%else %do; lib = work %end;
%if not %length(&data) %then %do; kill %end;
memtype = data nolist   nodetails
;
		%if %length(&data) %then %do; delete &data; %end;
	run;
	quit;
%mend ;
 
%macro _SLXdatasort(data = , out = , by = );
%if %_SLXblank(&out) %then %let out=%_SLXbarename(&data);
proc sort
%if %length(&data) %then data = &data;
%if %length(&out) %then out = &out;
;
by &by;
 
 
run;
%mend ;
%macro _SLXdistinctvalue(dsn,var,sort=1,into=,dlm=@,quote=0);
%local item varIsNum ;
%let varIsnum=1;
 
%if   &quote %then %_SLXvarisnum(&dsn,&var,into=varIsNum);
 
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
%macro _SLXequaltext(text1,text2);
	(upcase(&text1)=upcase(&text2))
%mend;
%macro _SLXgettempname(tempname,start=,useit=0);
 
%if %_SLXblank(&start) %then %let start=T_&tempname;
%if %length(&start)>10 %then %let start=%substr(&start,1,10);
%local  _SLX9rdn  i;
%do %until (not %sysfunc(exist(&&&tempName))  );
%let _SLX9rdn=;
%do i=1 %to 7;
%let _SLX9rdn=&_SLX9rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(0))*24),1,2))) );
%end;
%let &tempname=&start._&_SLX9rdn;
%end;
%put &tempname=&&&tempname;
%if &useit %then
%do;
data &&&tempname;
run;
%end;
 
 
%mend;
%macro _SLXpm(Ms);
%local Pmloop2342314314 mac;
%do Pmloop2342314314=1 %to %_SLXcount(&Ms);
%let mac=%scan(&Ms,&Pmloop2342314314,%str( ));
%put &mac=&&&mac;
%end;
%mend;
 
%macro _SLXpureName(dsn);
	%if %index(&dsn,%str(%()) %then %scan(&dsn,1,%str(%());
	%else &dsn;
%mend;
%macro _SLXputn(var,fmt);
%if %_SLXblank(&fmt) %then %let fmt=best.;
left(put(&var,&fmt))
%mend;
%macro _SLXrdm(length,seed=0);
%local i rdn;
%if %_SLXblank(&length) %then %let length=5;
%do i=1 %to &length;
%let rdn=&rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(&seed))*24),1,2))) );
%end;
&rdn
%mend;
%macro _SLXrenamekeep(dsn,out=,pos=,names=,prefix=col,keepall=0);
%if %_SLXblank(&names) %then %let names=%_SLXwords(&prefix,400);
%if %_SLXblank(&out) %then %let out=%_SLXbarename(&dsn);
%local varlist count;
%_SLXvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
%let count=%sysfunc(min(%_SLXcount(&varlist),%_SLXcount(&names)));
option symbolgen;
%if %_SLXblank(&pos) %then %let pos=%_SLXwords(%str( ),&count);
%_SLXpm(pos);
option nosymbolgen;
 
data &out;
set &dsn;
%local i;
%if not &keepall %then
%do;
keep
%do i=1 %to &count;
%scan(&varlist, %scan(&pos,&i))
%end;
;
%end;
rename
%do i=1 %to &count;
%scan(&varlist, %scan(&pos,&i))=%scan( &names,&i)
%end;
;
run;
%mend;
%MACRO _SLXuniq(mac,into);
%local i uniq;
%_SLXgettempname(uniq);
data &uniq;
format word $100.;
%do i=1 %to %_SLXcount(&mac);
word="%lowcase(%scan(&mac,&i))";
i=&i;
output;
%end;
run;
 
 
%_SLXdatasort(data = &uniq, out = , by =word );
 
data &uniq;
set &uniq;
format ord $3.;
retain ord;
by word;
if first.word then ord='1';
else ord=%_SLXputn(input(ord,best.)+1);
run;
 
%_SLXdatasort(data = &uniq, out = , by =i);
 
data &uniq;
set &uniq;
if ord ne '1' then word=compress(word||'_'||ord);
run;
 
proc sql noprint;
select trim(word) into :&into separated by ' '
from &uniq
;
quit;
 
%mend;
%macro _SLXvarinfo(dsn,out=varinfoout,info= name  type  length num fmt);
%local i _SLX3allinfo;
%let _SLX3allinfo=name  type   length  format  informat label ;
 
data &out(keep=&info);
length dsn $40 name $32  type $4  length 8 format $12  informat $10 label $50  num 8 superfmt fmt $12;
tableid=open("&dsn",'i');
varlist=' ';
dsn="&dsn";
do i=1 to  attrn(tableid,'nvars');
%do i=1 %to %_SLXcount(&_SLX3allinfo);
%if %scan(&_SLX3allinfo,&i) ne num
and %scan(&_SLX3allinfo,&i) ne fmt
and %scan(&_SLX3allinfo,&i) ne superfmt
%then  %scan(&_SLX3allinfo,&i)= var%scan(&_SLX3allinfo,&i)(tableid,i);;
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
%macro _SLXvarisnum(dsn,var,into=varIsNum);
%local varinfo;
%_SLXgettempname(varinfo);
%_SLXvarinfo(&dsn,out=&varinfo,info= name type);
data _null_;
set &varinfo(where=(%_SLXequaltext(name,"&var")  ) );
if type='N' then call symput("&into",'1');
else call symput("&into",'0');
run;
%mend;
%macro _SLXvarlist(dsn,Into=,dlm=%str( ),global=0,withlabel=0,print=0);
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
%if &print %then %_SLXpm(&into);
data writetofilefromithere;
%mend;
%macro _SLXwords(word,n,base=1);
%local _SLX4I;
%if not %index(&word,@) %then %let word=&word@;
%if %_SLXcount(&n)=1 %then
%do _SLX4I=%eval(&base) %to %eval(&n+&base-1);
%sysfunc(tranwrd(&word,@,&_SLX4i))
%end;
%else
%do _SLX4i=1 %to %_SLXcount(&n) ;
%sysfunc(tranwrd(&word,@,%scan(&n,&_SLX4i)))
%end;
 
%mend;
 
 
 
 
 
%if %_SLXblank(&prefix) %then %let prefix=%_SLXrdm(9);
%local i dsnN   ;
%let dsnN=%_SLXcount(&dsns);
%local %_SLXwords(Printing,&dsnN);
 
 
%do i=1 %to &dsnN;
%let printing&i=;
%_SLXgettempName(printing&i);
%end;
 
%local allvar;
%do i=1 %to &dsnN;
%local varlist charlist;
%let varlist=;
%let charlist=;
%_SLXvarlist(%scan(&dsns,&i,%str( )),Into=varlist);
%let allvar=&allvar &varlist;
 
%_SLXallchar(%scan(&dsns,&i,%str( )),into=charlist);
%_SLXpm(printing&i);
data &&printing&i;
 
%do j=1 %to %_SLXcount(&varlist);
%if %sysfunc(indexw(&charlist,%scan(&varlist,&j))) %then format &prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))   $&length.. ;
%else length &prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))   8;
;
%end;
 
set %scan(&dsns,&i,%str( ))
(
%do j=1 %to %_SLXcount(&varlist);
%if not %sysfunc(indexw(%upcase(&by),%upcase(%scan(&varlist,&j))  )  )
and  %lowcase(%scan(&varlist,&j)) ne ahuigebylabel
%then rename=(%scan(&varlist,&j)=&prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))    ) ;
%end;
);
 
 
run;
 
%end;
 
 
data &out;
merge  %do i=1 %to &dsnN; &&printing&i  %end;   ;
run;
 
%_SLXuniq(&allvar,allvar);
 
%local dropstat;
%if not %_SLXblank(&drop) %then %let dropstat=( drop= &drop) ;
 
%if &keep %then %_SLXrenamekeep(&out,out=&out&dropstat ,names=&allvar,keepall=0);
 
%if &clean %then %_SLXdatadelete(data=%do i=1 %to &dsnN; &&printing&i  %end;);
 
%if &print %then
%do;
proc print &label noobs width=min
;
run;
%end;
 
 
%mend;
 
