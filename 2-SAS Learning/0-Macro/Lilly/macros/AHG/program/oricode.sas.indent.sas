%let ahgrdminc=0;
%macro AHGrdm(length,seed=0,inc=ahgrdminc);
%let &inc=%eval(&&&inc+1);
_&&&inc
%mend;
 
 
%macro AHGgettempname(tempname,start=,useit=0);
%let &tempname=&tempname._%AHGrdm;
%mend;
 
 
option xsync nomprint nomfile noxwait;
%AHGclearlog;
%AHGkill;
x 'del c:\temp\mfile1.sas';
x 'del z:\downloads\newsas\program\oricode.sas';
x 'del z:\downloads\newsas\program\oricode.sas.indent.sas' ;
x 'del c:\temp\mfile1.sas.indent.sas';
filename mprint clear;
filename mprint "c:\temp\mfile1.sas";
/*filename mprint 'c:\temp\mfile1.sas' new;*/
option mprint mfile;
;
data thedsn__2;
  set sashelp.class;
  ;
run;

;
;
;
;
proc sort data = thedsn__2 out = thedsn__2 ;
  by Name Sex;
run;

;
proc means data=thedsn__2 noprint alpha=0.05;
  ;
  var Height;
  by Name Sex;
  output
  out=stat_Height n = n mean = mean median = median min = min max = max ;
run;

proc sql noprint;
  create table stat_Height as select
  left(put(n, 5.)) as n
  , left(put(mean, 9.)) as mean
  , left(put(median, 9.2)) as median
  , left(put(min, 9.2)) as min
  , '-'
  , left(put(max, 9.2)) as max
  ,Name
  ,
  Sex from stat_Height ;
  quit;

;
;
;
;
data vertdsn__4;
  set stat_Height;
  keep
  Sex
  Name theVerticalvar1 theVerticalvar2 theVerticalvar3 theVerticalvar4 ;
  theVerticalvar1=compbl( n );
  theVerticalvar2=compbl( mean );
  theVerticalvar3=compbl( median );
  theVerticalvar4=compbl( min ||'  '|| _TEMA001 ||'  '|| max );
  ;
run;

data horistat_Height;
  set stat_Height;
run;

data stat_Height;
  set vertdsn__4;
  keep Name
  label
  ahgdummy_1
  Sex
  stat;
  array allvar(1:4) theVerticalvar1-theVerticalvar4;
  do i=1 to dim(allvar);
  label=left(scan("n@ mean@ median@ min - max",i,'@'));
  ahgdummy_1=i ;
  stat=input(allvar(i),$50.);
  output;
  end;
run;

proc sort data = stat_Height out = sortstat_Height ;
  by Name ahgdummy_1 label Sex;
run;

;
proc transpose data=sortstat_Height out=stat_Height(drop=_name_);
  var stat;
  by Name ahgdummy_1
  label ;
  id Sex;
run;

;
;
;
data sortdsn__5;
  length word $100;
  word=scan("M F",1," ");
  output;
  word=scan("M F",2," ");
  output;
run;

proc sql noprint;
  select distinct trim(word) into :ids separated by " " from sortdsn__5 order by word ;
  quit;

proc datasets lib = work memtype = data nolist nodetails ;
  delete sortdsn__5;
run;

quit;

;
;
;
proc sql;
  create table sql__6 as select
  Name,ahgdummy_1,label,F,M
  from stat_Height(keep=Name ahgdummy_1 label F M) ;
  quit;

data stat_Height;
  set sql__6;
run;

;
data stat_Height;
  set stat_Height(drop
  = ahgdummy_1 );
run;

;
;
;
;
proc sql noprint;
  create table varinfo__7(drop= AHGdrop) as select ' ' as AHGdrop ,Name
  ,label
  ,F
  ,M
  from stat_Height ;
  quit;

data
  stat_Height;
  set varinfo__7;
run;

;
;
;
;
;
;
data allchar__8;
  set allchar__8(where=(type='C'));
run;

proc sql noprint;
  select distinct name into :charlist separated by " " from allchar__8 ;
  quit;

;
option mprint;
;
;
                
data stat_Height(rename=( _101=F _102=M _103=Name _104=label ));
  format _101 $13. _102 $13. _103 $7. _104 $9. ;
  drop F M Name label ;
  set stat_Height;
  _101=left(F) ;
  _102=left(M) ;
  _103=left(Name) ;
  _104=left(label) ;
run;

;
proc sql;
  create table sql__11 as select
  Name,label,F,M
  from stat_Height(keep=Name label F M) ;
  quit;

data stat_Height;
  set sql__11;
run;

;
;
data stat_Height;
  set stat_Height(obs=100);
run;

;
;
;
;
;
title;
title1 "Dataset:  sashelp.class   ";
title2
"Variable:  Height ";
title3
"Treatment: Sex  ";
Title4
"By: Name  ";
;
data rptdsn__13;
  ahuige34xbege5435='_';
  set stat_Height;
run;

option label;
;
;
;
;
option mprint;
;
;
;
;
;
;
;
;
;
;
;
;
option label;
;
proc report data=rptdsn__13 nowd nocenter headline;
  column
  ahuige34xbege5435 Name label F M ;
  define ahuige34xbege5435/order noprint ;
  define Name / width=7 display flow ;
  define label / width=9 display flow ;
  define F / width=13 display flow ;
  define M / width=13 display flow ;
run;

;
data sepdsn__15;
  format line $200.;
  line=repeat('#',200);
  output;
  line=
  "End of  Dataset:sashelp.class    Variable:Height   Treatment:Sex  By:Name";
  output;
  line=repeat('#',200);
  output;
run;

proc print data=_last_ noobs label;
run;

;
 
