libname mytemp 'd:\temp';
%AHGkill;

/*option sasautos=(sasautos "D:\kanbox\baiduyun\allover");*/
/*option mrecall;*/
/* */
/*libname mytemp 'c:\download';*/
/* */
%macro AHGalltonum(dsn,out=%AHGbasename(&dsn),rename=,zero=0,width=100);
%local i varlist informat nobs varinfo  %AHGwords(cmd,100);
%AHGgettempname(varinfo);
%AHGvarinfo(&dsn,out=&varinfo,info= name  type  length num);
data _null_;
 set &varinfo;
 format cmd $200.;
 if type='C' then cmd='input( '||name||',best. ) as '||name;
 else cmd=name ;
    call symput('cmd'||left(_n_),cmd);
 call symput('nobs',_n_);
run;
 
%AHGdatadelete(data=&varinfo);
 
proc sql noprint;
 create table &out(drop= AHGdrop) as
 select ' ' as AHGdrop 
    %do i=1 %to &nobs;
    %local zeroI;
    %if &zero %then %let zeroI=%AHGzero(&i,z&zero.);
    %else %let zeroI=&i;
 ,&&cmd&i %if not %AHGblank(&rename) %then as &rename&zeroI;
 %end;
 from &dsn
 ;quit;
 
%mend;
 
 
 
 
 
 
 
%AHGalltocharnew(mytemp.hospital1 );
data hosp1(keep=subjid age oac  af  la  aftype CAD sex hypertension diab  stroke thrombus CHADS2 aspr CHADS2VASC    coumadin  INR);
  set  hospital1(rename=(la=lalen));
  rename 
  var1=sex
  var3=age
  var7=thrombus
  var8=af
  var9=aftype
  var10=hypertension
  var11=diab
  var12=CAD
  var13=stroke
  var16=aspr
  ;
  if left(lalen)>='38' then la='1';
  else la='0';
  subjid=compress('100'||put(_n_,z3.));
  oac=0;
 

run;
 
 
 
%AHGalltocharnew(mytemp.hospital2 );
 

 /* hospital 2
   VAR1 VAR2      VAR3        VAR4       VAR5   VAR6  VAR7     VAR8   VAR9      VAR10       VAR11              VAR12      CHADS2VASC  VAR14     coumadin  INR
??   ?????AF  ????  ????  ??? ??  ??? ??? ????  ????? ????????  CHADS2??  CHADS2-VASC ????  coumadin  INR
  */
/*51  0 0 1 0 1 0 0 0 0 0 0 1 1   */
/*40  1 0 1 0 1 0 0 0 0 0 0 0     */
data hosp2(keep=subjid age oac af  la  aftype CAD sex hypertension diab heartfailure stroke thrombus CHADS2 aspr CHADS2VASC    coumadin  INR);
  set hospital2;
  rename
  var1=age 
  var2=af 
  var3=la 
  var4=aftype
  var5=CAD
  var6=sex
  var7=hypertension
  var8=diab
  var9=heartfailure
  var10=stroke
  var11=thrombus
  var12=CHADS2
  var14=aspr;
  ;
  subjid=compress('200'||put(_n_,z3.));
  oac=1;
 

run;
 
 
 

/*
VAR1  VAR2  VAR3  LA  LVED  LVEF  VAR7          VAR8      VAR9      VAR10    VAR11   VAR12  VAR13   CHADS2  CHADS2VASC  VAR16 coumadin  INR
??  ??  ??  LA  LVED  LVEF  ????  ?????AF ????  ??? ??? ??? ??? CHADS2  CHADS2VASC  ????  coumadin  INR
0 ? 64  28  53  55.6  1 1 1 1 0 0 0 1 2 1   
0 ? 66  25  46  63.6  0 0 1 0 0 0 0 1 2     


*/
 
 
proc format ;
  value   sex  
  0='Female'
  1='Male'
  ;
  value  af  
  0="No Atrial Fibrillation"
  1="Atrial Fibrillation"
  ;

  value  la  
  0="No left atrial hypertrophy"
  1="left atrial hypertrophy"
  ;

  value  hp  
  0="No Hypertension"
  1="Hypertension"
  ;

  value  Paro_AF  
  1='Paroxysmal AF'
  0='NON-Paroxysmal AF'

  ;

  value  Diab  
  0="No Diabetes"
  1="Diabetes"
  ;

  value  CAD  
  0="No CAD"
  1="CAD "
  ;

  value  Stroke  
  0="No Stroke"
  1="Stroke "
  ;

  value  Asprin   
  0="No Asprin "
  1="Asprin  "
  ;


  value  score   
  0="CHADS2 0~1"
  1="CHADS2 2~More"
  ;

  value  scorevas
  0="CHADS2VASC 0~1"
  1="CHADS2VASC 2~More"
  ;

  value  Coumadin   
  0="No Coumadin therapy"
  1="Coumadin therapy"
  ;


  value  INR    
  0="INR 0~1"
  1="INR 2~3"
  ;

  value  thr    
  0="No Thrombus"
  1="Thrombus"
  ;

  value  oac    
  0="Without Adequate OAC"
  1="With Adequate OAC"
  ;

run;
 
 
data allhos;
  format subjid $20.;
  set hosp1 hosp2;


run;
 
 
 

%AHGalltonum(allhos,out=allnum);
 

data allnum;
  set allnum;

  array all  aspr CHADS2VASC    coumadin  INR heartfailure;
  do over all;
    if missing(all) then all=0;
  end;
  if chads2<=1 then chads2grp=0;
/*  else if chads2=1 then chads2grp=0;*/
  else if chads2>=2 then chads2grp=1;
 

  if chads2vasc<=1 then chads2vascgrp=0;
/*  else if chads2vasc=1 then chads2vascgrp=1;*/
  else if chads2vasc>=2 then chads2vascgrp=1;

 
  IF AFTYPE=1 THEN paro=1;
  else paro=0;
  format sex sex. af af. hypertension hp. paro paro_af. diab diab.
  cad cad.  stroke stroke. aspr asprin. chads2grp score. chads2vascgrp scorevas.
  coumadin coumadin. inr inr. thrombus thr. oac oac.;
;
 

run;
 
 
 

proc means data=allnum n  mean std;
  var age    ;
run;
 

proc freq data=allnum;
  tables sex af hypertension diab CAD stroke aspr 
    inr paro oac chads2grp chads2vascgrp coumadin thrombus;
run;
 

option byline;
title;footnote;
%AHGdatasort(data =allnum , out = , by =oac );

%macro dosomething(one);
%if %AHGblank(&one) %then %goto out;
%AHGfreqCore(allnum,&one,rename=1, by=oac,out=freq_&one,print=0,keep=value frequency percent)
data freq_&one;
  label=put("&one  ",$200.);
  set freq_&one;
  format value 8.;
/*  rename frequency=&one._frequency percent=&one._percent;*/
run;

proc freq data=allnum;
  tables &one*oac/chisq;
  output out=ChiSqData pchi  ;
run;


DATA CHI_&one;
/*  label_&one*/
  label=put("&one* oac ",$200.);
  set chisqdata;
/*  rename _PCHI_=&one._chisq P_PCHI=&one._P;*/
run;
%out:;
%mend;
%doSomething
 



%AHGfuncloop(%nrbquote( dosomething(ahuige) ) ,loopvar=ahuige,
loops=sex af la hypertension diab paro CAD stroke aspr inr chads2grp chads2vascgrp  thrombus);


;

data fqoac0 fqoac1;
  set freq:;
  if oac=0 then output fqoac0;
  if oac=1 then output fqoac1;
run;


data Pvalue;
  set chi_:;
run;

%AHGprt(dsn=fqoac0 );
%AHGprt(dsn=fqoac1 );
%AHGprt(dsn=Pvalue);



title "Logistical regression for chads2vascgrp in all patients" ;
proc logistic data=allnum descending;
  class sex  hypertension diab CAD stroke aspr chads2vascgrp / param=ref ;
  model thrombus= age sex  hypertension diab CAD stroke aspr  chads2vascgrp  ;
run;
 

title "Logistical regression for chads2grp in all patients" ;
proc logistic data=allnum descending;
  class sex  hypertension diab CAD stroke aspr chads2grp  / param=ref ;
  model thrombus= age sex  hypertension diab CAD stroke aspr chads2grp   ;
run;


title "Logistical regression for chads2vascgrp in patients without adequate oac" ;
proc logistic data=allnum(where=(oac=0)) descending;
  class sex  hypertension diab CAD stroke aspr chads2vascgrp / param=ref ;
  model thrombus= age sex  hypertension diab CAD stroke aspr  chads2vascgrp  ;
run;
 

title "Logistical regression for chads2grp in patients without adequate oac" ;
proc logistic data=allnum(where=(oac=0)) descending;
  class sex  hypertension diab CAD stroke aspr chads2grp  / param=ref ;
  model thrombus= age sex  hypertension diab CAD stroke aspr chads2grp   ;
run;


title "Logistical regression for chads2vascgrp in patients with adequate oac" ;
proc logistic data=allnum(where=(oac=1)) descending;
  class sex  hypertension diab CAD stroke aspr chads2vascgrp / param=ref ;
  model thrombus= age sex  hypertension diab CAD stroke aspr  chads2vascgrp  ;
run;
 
/
title "Logistical regression for chads2grp in patients with adequate oac" ;
proc logistic data=allnum(where=(oac=1)) descending;
  class sex  hypertension diab CAD stroke aspr chads2grp  / param=ref ;
  model thrombus= age sex  hypertension diab CAD stroke aspr chads2grp   ;
run;
 
 







