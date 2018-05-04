%macro fqaegrd;

%ahgfreqcore(adsl,trtpn,keep=value frequency,out=bigN);

proc transpose data=bigN out=bigNline;
  var frequency;
  id value;
run;

data bigNline;
  format frequency $200.;
  set bigNline;
run;


%AHGmergedsn(adsl,adae,adae,by=subjid,joinstyle=full );


data adae  patient(  keep=subjid &TEAEflag trtpn fasfl);
  set  adae;
  if missing(&aeterm) ne missing(&socterm) then put "Warning not missing both term";
  if not missing(aeterm) and missing(&aeterm) then &aeterm='Uncoded';
  if not missing(aeterm) and missing(&socterm) then &socterm='Uncoded';

run;
  
proc sql noprint;
  create table TEAEdsn AS
  select distinct subjid,trtpn,max(&TEAEflag)>'' as TEAE
  from patient
  group by subjid
  ;
  quit;


/*  data THEOUT /pgm=Lsdtm.bodfreq;*/
/*    format column1st $80. ;*/
/*    set THEIN;*/
/*    percentstr='('||put(round(percent,0.1),5.1)||')';*/
/*    drop percent ;*/
/*  run;*/
%macro newfreq(dsn,var,out=);
  %ahgfreqcore(&dsn,&var,out=&out);
  data pgm=lsdtm.bodfreq;   
     redirect output theout=&out; 
     redirect input thein=&out; 
     execute;
  run;    
%mend;

%AHGfreeloop(TEAEdsn,trtpn
,cmd=newfreq(ahuige,TEAE,out=outfreq)
,out=outfreq 
,in=Ahuige 
,url=TE_
,execute=1
,del=1
,addloopvar=0);

%AHGdsnInLib(lib=work,list=dsnlist,mask='TE_outfreq%',global=1);

%AHGmergeprintEx(
&dsnlist
,by=value
,label=label
,out= TEAEnum(where=(value=1)),print=0
,prefix=ahuigetefr
);

****************************************************************;

proc sql;
  create table nodup as
  select distinct &socterm
  from adae
  where not missing(&socterm)
  ;
  create table allsys as
  select subjid, &socterm,trtpn
  from nodup, adsl
  ;

  create table justSys as
  select distinct subjid, &socterm,put('',$200.) as &aeterm,1 as aeyn
  from adae
  where not missing(&socterm)
  ;
quit;

%AHGmergedsn(justsys,allsys,alljustsys,by=subjid &socterm,joinstyle=full/*left right full matched*/);

data alljustsys;
  set alljustsys;
  if missing(aeyn) then aeyn=0;
  &aeterm=put('',$200.);

run;

/*  data THEout/pgm=Lsdtm.termfreq;*/
/*    set thein;*/
/*    percentstr='('||put(round(percent,0.1),5.1)||')';*/
/*    valuestr=catx(' ',frequency,percentstr);*/
/*    if missing(valuestr) then valuestr='0';*/
/*    keep value  valuestr  ;*/
/*  run;*/

%macro newfreq(dsn,var,out=);
  %ahgfreqcore(&dsn,&var,out=&out);
  data pgm=lsdtm.termfreq;   
     redirect output theout=&out; 
     redirect input thein=&out; 
     execute;
  run;  
%mend;

%AHGfreeloop(alljustsys,&socterm  &aeterm trtpn 
,cmd=newfreq(ahuige,aeyn,out=outfreq)
,out=outfreq
,in=Ahuige
,url=bod_
,execute=1
,del=1
,addloopvar=1);

**********************************;


%macro getLine(which,OUTPRE,by,outdsns=);
  %let &outdsns=;
  %local i four j;
  %do i=1 %to  &&&by ;
  %let four=&four &which&i;
  %if %AHGcount(&four)=4 %then
    %do;
    %AHGpm(four);
    %let j=%eval(&j+1);
    %let &outdsns=&&&outdsns &outpre&j;
    %AHGmergeprintEx(
    &four
    ,by=&socterm &aeterm value
    ,keep=
    ,drop=trtpn
    ,label=label
    ,out=&outpre&j,print=1
    ,prefix=ahg_
    ,clean=1
    );
    %let four=;
    %local nobs;
    %let nobs=0;
    %AHGnobs(&outpre&j,into=nobs);
    %AHGpm(nobs);
    %if  &nobs =1 %then
      %do;
      data &outpre&j  ;
        set &outpre&j;
        output;
        if value=0 then
        do;
        value=1;
        array allahg ahg:;
        do over allahg;
         allahg='0';
        end;
        output;
        end;
      run;
      %end;

    data &outpre&j;
      set &outpre&j;
      array allstr _character_;
      do over allstr;
        if missing(allstr) then allstr='0';
      end;
      if value=1 then output;
    run;

    %end;

  %end;
%mend;
%let boddsns=;
%getLine(Bod_outfreq,AHGmerge,bod_N,outdsns=boddsns);

/*******************************/

proc sql noprint;
  create table noduppt as
  select distinct &socterm,&aeterm
  from adae
  where not missing(&aeterm)
  ;
  create table allpt as
  select subjid, &socterm,&aeterm,trtpn
  from nodupPT, adsl
  ;

  create table justPT as
  select distinct subjid, &socterm,&aeterm,max(aetoxgr) as aetoxgr,1 as aeyn
  from adae
  where not missing(&aeterm)
  group by subjid, &socterm,&aeterm
  ;
quit;

%AHGmergedsn(justPT,allPT,alljustPT,by=subjid &socterm &aeterm,joinstyle=full/*left right full matched*/);

data alljustPT(rename=(newaeterm=&aeterm));
  set alljustPT;
  if missing(aeyn) then aeyn=0;
  newaeterm=&aeterm;
  output;
  if &aeterm>'0' then
    do;
    do loop=1 to 5;
      newaeterm=trim(&aeterm)||'@  Grade '||left(put(loop,best.));
      if loop=input(aetoxgr,best.) then  
        do;
        aeyn=1;output;
        end;
      else
        do;
        aeyn=0;output;
        end;
    end;
    newaeterm=trim(&aeterm)||'@  Grade _3/4/5';
    if 3<=input(aetoxgr,best.)<=5 then  
        do;
        aeyn=1;output;
        end;
    else
        do;
        aeyn=0;output;
        end;
    end;
  drop &aeterm;
run;

%AHGfreeloop(allJustPT,&socterm &aeterm trtpn 
,cmd=newfreq(ahuige,aeyn,out=outfreq)
,out=outfreq ahuige
,in=Ahuige
,url=pterm_
,execute=1
,del=1
,addloopvar=1);

%let termdsns=;
%getline(pterm_outfreq,mergePt_,pterm_N,outdsns=termdsns);

data theDSN;
  set &boddsns &termdsns;
run;

%AHGrenamekeep(thedsn,out=renameDSN,pos=,names=value st1 soc term st2 st3 stALL,keep=1);

data newrenameDSN;
  set renameDSN;
  ordterm=scan(term,1,'@');
  if scan(term,2,'@')>'' then ordnum=rank(substr(scan(term,2,'@'),9,1));
  count=input(scan(stAll,1),best.);
  if missing(term) then count=999999;
  if index(term,'@') then term=scan(term,2,'@');
  term=tranwrd(term,'_3/4/5','3/4/5');
run;

proc sql;
  create table renameDSN as
  select *,max(count) as maxcount
  from newrenameDSN
  group by soc,ordterm

  ;
  quit;
%AHGdatasort(data=renameDSN , out =ord , by =soc descending maxcount ordterm ordnum);

data ord;
  set ord;
  if term='0' then term='';
  if  term ne ' ' then soc='';
  string=put(trim(soc)||'  '||term,$100.);
run;

%AHGordvar(ord,string st1 st2 st3 stALL,out=,keepall=0);

%AHGsetprint(bigNline ord,out=ord,print=1);

proc printto file="%mysdd(&replication_output\qc_&rtf..txt)" NEW;
run;

;

%AHGreportby(ord,0,which=2 3 4 5,flow=flow,whichlength=12 12 12 12,sort=0,groupby=0,groupto=0,topline=,showby=0,option=%str(nowd split='^'),labelopt=%str(option label ;));

%AHGtoLocal(&tfl_output\&rtf..rtf,to=%mysdd(&tfl_output),open=0);

/*%AHGrtftotxt(&tfl_output\&rtf..rtf,,%mysdd(&replication_output\&rtf..txt) );*/

/*x "%mysdd(&replication_output\&rtf..txt) ";*/
x "%mysdd(&replication_output\qc_&rtf..txt)";
%mend;


