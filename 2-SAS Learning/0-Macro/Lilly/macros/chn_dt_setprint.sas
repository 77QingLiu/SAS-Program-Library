%macro chn_dt_setprint(dsns,out=setprint,print=0,prefix=,by=,ord=,keep=0);
%macro _MKSaddcomma(mac,comma=%str(,) );
%if %_MKSnonblank(&mac) %then %sysfunc(tranwrd(     %sysfunc(compbl(&mac)),%str( ),&comma       ))   ;
%mend;
%macro _MKSallchar(dsn,into=);
%local allchar ;
%_MKSgettempname(allchar);
data deletefromithere;
%_MKSvarinfo(&dsn,out=&allchar,info= name  type );
 
data &allchar;
set &allchar(where=(type='C'));
run;
 
%_MKSdistinctValue(&allchar,name,into=&into,dlm=%str( ));
data writetofilefromithere;
 
 
%mend;
%macro _MKSalltocharnew(dsn,out=%_MKSbasename(&dsn),rename=,zero=0,width=100);
%local i varlist informat nobs varinfo  %_MKSwords(cmd,100);
%_MKSgettempname(varinfo);
 
%_MKSvarinfo(&dsn,out=&varinfo,info= name  type  length num);
data deletefromithere;
data _null_;
set &varinfo;
format cmd $200.;
if type='N' then cmd='input(left(put('||name||',best.)),$'||"&width"||'.) as '||name;
else cmd=name ;
call symput('cmd'||%_MKSputn(_n_),cmd);
call symput('nobs',%_MKSputn(_n_));
run;
data writetofilefromithere;
 
/*%_MKSdatadelete(data=&varinfo);*/
 
proc sql noprint;
create table &varinfo(drop= _MKSdrop) as
select ' ' as _MKSdrop
%do i=1 %to &nobs;
%local zeroI;
%if &zero %then %let zeroI=%_MKSzero(&i,z&zero.);
%else %let zeroI=&i;
,&&cmd&i %if not %_MKSblank(&rename) %then as &rename&zeroI;
%end;
from &dsn
;quit;
 
%_MKSrenamedsn(&varinfo,&out);
 
%mend;
 
 
 
 
%macro _MKSbareName(dsn);
	%_MKSbasename(%_MKSpurename(&dsn))
%mend;
%macro _MKSbasename(dsn);
	%if %index(&dsn,.) %then %scan(&dsn,2,%str(.%());
	%else %scan(&dsn,1,%str(.%());
%mend;
%macro _MKSblank(string);
	%if %length(%bquote(&string)) %then 0 ;
	%else 1;
%mend;
%macro _MKScount(line,dlm=%str( ));
%local i _MKS66TheEnd;
%let i=1;
%do %until(&_MKS66TheEnd=yes);
%if  %qscan(%bquote(&line),&i,&dlm) eq %str() %then
%do;
%let _MKS66TheEnd=yes;
%eval(&i-1)
%end;
%else %let i=%eval(&i+1);
%end;
 
%mend;
 
%macro _MKSdatadelete(lib = , data = );
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
 
%macro _MKSdatasort(data = , out = , by = );
%if %_MKSblank(&out) %then %let out=%_MKSbarename(&data);
proc sort
%if %length(&data) %then data = &data;
%if %length(&out) %then out = &out;
;
by &by;
 
 
run;
%mend ;
%macro _MKSdistinctvalue(dsn,var,sort=1,into=,dlm=@,quote=0);
%local item varIsNum ;
%let varIsnum=1;
 
%if   &quote %then %_MKSvarisnum(&dsn,&var,into=varIsNum);
 
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
%macro _MKSequaltext(text1,text2);
	(upcase(&text1)=upcase(&text2))
%mend;
%macro _MKSgettempname(tempname,start=,useit=0);
 
%if %_MKSblank(&start) %then %let start=T_&tempname;
%if %length(&start)>10 %then %let start=%substr(&start,1,10);
%local  _MKS9rdn  i;
%do %until (not %sysfunc(exist(&&&tempName))  );
%let _MKS9rdn=;
%do i=1 %to 7;
%let _MKS9rdn=&_MKS9rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(0))*24),1,2))) );
%end;
%let &tempname=&start._&_MKS9rdn;
%end;
%put &tempname=&&&tempname;
%if &useit %then
%do;
data &&&tempname;
run;
%end;
 
 
%mend;
%macro _MKSmergeprint(dsns,by=,drop=,label=label
,out=mergeprintout,print=1
,prefix=
,clean=1
,z=3
,keep=0
,length=500
);
%if %_MKSblank(&prefix) %then %let prefix=%_MKSrdm(9);
%local i dsnN   ;
%let dsnN=%_MKScount(&dsns);
%local %_MKSwords(Printing,&dsnN);
 
 
%do i=1 %to &dsnN;
%let printing&i=;
%_MKSgettempName(printing&i);
%end;
 
%local allvar;
%do i=1 %to &dsnN;
%local varlist charlist;
%let varlist=;
%let charlist=;
%_MKSvarlist(%scan(&dsns,&i,%str( )),Into=varlist);
%let allvar=&allvar &varlist;
 
%_MKSallchar(%scan(&dsns,&i,%str( )),into=charlist);
%_MKSpm(printing&i);
data &&printing&i;
 
%do j=1 %to %_MKScount(&varlist);
%if %sysfunc(indexw(&charlist,%scan(&varlist,&j))) %then format &prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))   $&length.. ;
%else length &prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))   8;
;
%end;
 
set %scan(&dsns,&i,%str( ))
(
%do j=1 %to %_MKScount(&varlist);
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
 
%_MKSuniq(&allvar,allvar);
 
%local dropstat;
%if not %_MKSblank(&drop) %then %let dropstat=( drop= &drop) ;
 
%if &keep %then %_MKSrenamekeep(&out,out=&out&dropstat ,names=&allvar,keepall=0);
 
%if &clean %then %_MKSdatadelete(data=%do i=1 %to &dsnN; &&printing&i  %end;);
 
%if &print %then
%do;
proc print &label noobs width=min
;
run;
%end;
 
 
%mend;
 
%macro _MKSnonblank(str);
not %_MKSblank(&str)
%mend;
%macro _MKSordvar(dsn,vars,out=,keepall=0);
%local sql;
%_MKSgettempname(sql);
%if &keepall %then
%do;
%local restvardsn ;
%let restvardsn=;
%_MKSgettempname(restvardsn);
 
data &restvardsn;
set &dsn(drop=&vars);
run;
%end;
%if %_MKSblank(&out) %then %let out=%_MKSbasename(&dsn);
proc sql;
create table &sql as
select %_MKSaddcomma(&vars)
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
%macro _MKSpm(Ms);
%local Pmloop2342314314 mac;
%do Pmloop2342314314=1 %to %_MKScount(&Ms);
%let mac=%scan(&Ms,&Pmloop2342314314,%str( ));
%put &mac=&&&mac;
%end;
%mend;
 
%macro _MKSprt(dsn=_last_,label=label);
proc print data=&dsn noobs &label;run;
%mend;
%macro _MKSpureName(dsn);
	%if %index(&dsn,%str(%()) %then %scan(&dsn,1,%str(%());
	%else &dsn;
%mend;
%macro _MKSputn(var,fmt);
%if %_MKSblank(&fmt) %then %let fmt=best.;
left(put(&var,&fmt))
%mend;
%macro _MKSrdm(length,seed=0);
%local i rdn;
%if %_MKSblank(&length) %then %let length=5;
%do i=1 %to &length;
%let rdn=&rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(&seed))*24),1,2))) );
%end;
&rdn
%mend;
%macro _MKSrenamedsn(dsn,out);
%if not %sysfunc(exist(&out)) %then
%do;
%if not %index(&dsn,.) %then %let dsn=work.&dsn;
%local lib ds dsout;
%let lib=%scan(&dsn,1);
%let ds=%scan(&dsn,2);
proc datasets library=&lib;
change &ds=%scan(&out,%_MKScount(&out,dlm=.));
run;
%end;
%else
%do; data %scan(&out,%_MKScount(&out,dlm=.));set &dsn;run;  %end;
 
 
%mend;
%macro _MKSrenamekeep(dsn,out=,pos=,names=,prefix=col,keepall=0);
%if %_MKSblank(&names) %then %let names=%_MKSwords(&prefix,400);
%if %_MKSblank(&out) %then %let out=%_MKSbarename(&dsn);
%local varlist count;
%_MKSvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
%let count=%sysfunc(min(%_MKScount(&varlist),%_MKScount(&names)));
option symbolgen;
%if %_MKSblank(&pos) %then %let pos=%_MKSwords(%str( ),&count);
%_MKSpm(pos);
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
%macro _MKSscanSubstr(words,from,num,dlm1st=0,dlm=%str( ),compress=0/*right*/);
	%local i outstr;
	%let outstr=;
	%do i=0 %to %eval(&num-1);
		%if &i gt &dlm1st %then %let outstr=&outstr&dlm;
		%let outstr=&outstr%scan(&words,%eval(&i+&from),&dlm);
	%end;
	%if &compress %then %let outstr=%sysfunc(compress(&outstr));
	&outstr
%mend;
%macro _MKStrimDsn(dsn,out=,min=3,left=1);
%if %_MKSblank(&out) %then %let out=%_MKSbarename(&dsn);
%local max charlist i count rdn len varlist;
 
%_MKSvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
/*%_MKSgettempname(max);*/
 
%_MKSallchar(&dsn,into=charlist);
 
%let count=%_MKScount(&charlist);
%let rdn=%_MKSrdm(20);
 
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
%let rdm=%_MKSrdm(25);
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
 
%_MKSordvar(&out,&varlist,out=&out,keepall=0);
 
%mend;
 
%MACRO _MKSuniq(mac,into);
%local i uniq;
%_MKSgettempname(uniq);
data &uniq;
format word $100.;
%do i=1 %to %_MKScount(&mac);
word="%lowcase(%scan(&mac,&i))";
i=&i;
output;
%end;
run;
 
 
%_MKSdatasort(data = &uniq, out = , by =word );
 
data &uniq;
set &uniq;
format ord $3.;
retain ord;
by word;
if first.word then ord='1';
else ord=%_MKSputn(input(ord,best.)+1);
run;
 
%_MKSdatasort(data = &uniq, out = , by =i);
 
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
%macro _MKSvarinfo(dsn,out=varinfoout,info= name  type  length num fmt);
%local i _MKS3allinfo;
%let _MKS3allinfo=name  type   length  format  informat label ;
 
data &out(keep=&info);
length dsn $40 name $32  type $4  length 8 format $12  informat $10 label $50  num 8 superfmt fmt $12;
tableid=open("&dsn",'i');
varlist=' ';
dsn="&dsn";
do i=1 to  attrn(tableid,'nvars');
%do i=1 %to %_MKScount(&_MKS3allinfo);
%if %scan(&_MKS3allinfo,&i) ne num
and %scan(&_MKS3allinfo,&i) ne fmt
and %scan(&_MKS3allinfo,&i) ne superfmt
%then  %scan(&_MKS3allinfo,&i)= var%scan(&_MKS3allinfo,&i)(tableid,i);;
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
%macro _MKSvarisnum(dsn,var,into=varIsNum);
%local varinfo;
%_MKSgettempname(varinfo);
%_MKSvarinfo(&dsn,out=&varinfo,info= name type);
data _null_;
set &varinfo(where=(%_MKSequaltext(name,"&var")  ) );
if type='N' then call symput("&into",'1');
else call symput("&into",'0');
run;
%mend;
%macro _MKSvarlist(dsn,Into=,dlm=%str( ),global=0,withlabel=0,print=0);
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
%if &print %then %_MKSpm(&into);
data writetofilefromithere;
%mend;
%macro _MKSwords(word,n,base=1);
%local _MKS4I;
%if not %index(&word,@) %then %let word=&word@;
%if %_MKScount(&n)=1 %then
%do _MKS4I=%eval(&base) %to %eval(&n+&base-1);
%sysfunc(tranwrd(&word,@,&_MKS4i))
%end;
%else
%do _MKS4i=1 %to %_MKScount(&n) ;
%sysfunc(tranwrd(&word,@,%scan(&n,&_MKS4i)))
%end;
 
%mend;
 
 
 
 
 
%macro _MKSzero(n,length);
	%sysfunc(putn(&n,&length))
%mend;
%local i dsnN item onedsn alldsn;
%if %_MKSblank(&prefix) %then %let prefix=%_MKSrdm(9);
%let dsnN=%_MKScount(&dsns);
%local allvar varlist;
%do i=1 %to  &dsnN;
%let item=%scan(&dsns,&i,%str( ));
%_MKSgettempname(onedsn);
%let alldsn=&alldsn &onedsn;
data &onedsn;
%if %_MKSnonblank(&ord) %then  &ord=&i;;
%if %_MKSnonblank(&by) %then
%do;
format &by $40.; &by="&item";
%end;
set &item;
run;
%_MKSalltocharnew(&onedsn,out=&onedsn);
%_MKSvarlist(%scan(&dsns,&i,%str( )),Into=varlist);
%if %_MKScount(&varlist)> %_MKScount(&allvar) %then
%let allvar=&allvar %_MKSscansubstr( &varlist,%eval(%_MKScount(&allvar)+1),%eval(%_MKScount(&varlist)-%_MKScount(&allvar)));
%_MKSmergeprint(&onedsn,out=&onedsn,print=0,prefix=&prefix);
 
%end;
 
data &out;
set &alldsn;
run;
 
%if &keep %then %_MKSrenamekeep(&out,names=&allvar,keepall=0);
%else  %_MKSrenamekeep(&out,keepall=0);
%_MKStrimdsn(&out);
 
%if  &print %then %_MKSprt;
%mend;
