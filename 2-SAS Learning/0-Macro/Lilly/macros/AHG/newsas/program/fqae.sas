%macro fqae;

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
  if Nmiss(&aeterm, &socterm)=1 then put "Warning not missing both term";
  if not missing(aeterm) and missing(&aeterm) then &aeterm='Uncoded';
  if not missing(aeterm) and missing(&socterm) then &socterm='Uncoded';

run;
  
proc sql;
  create table TEAEdsn AS
  select distinct subjid,trtpn,max(&TEAEflag)>'' as TEAE
  from patient
  group by subjid
  ;
  quit;



%macro newfreq(dsn,var,out=);
  %ahgfreqcore(&dsn,&var,out=&out);
  data &out;
    set &out;
    format column1st $80. value  $12.;
    percentstr='('||put(round(percent,0.1),5.1)||')';
    value=trim(left(frequency))||percentstr;
    drop percent ;
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
,out= TEAEnum(where=(value=1)),print=1
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

%macro newfreq(dsn,var,out=);
  %ahgfreqcore(&dsn,&var,out=&out);
  data &out;
    set &out;
    percentstr='('||put(round(percent,0.1),5.1)||')';
    valuestr=catx(' ',frequency,percentstr);
    if missing(valuestr) then valuestr='0';
    keep value  valuestr  ;
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


%macro getLine(which,OUTPRE,by);
  %local i four j;
  %do i=1 %to  &&&by ;
  %let four=&four &which&i;
  %if %AHGcount(&four)=4 %then
    %do;
    %AHGpm(four);
    %let j=%eval(&j+1);
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
%getLine(Bod_outfreq,AHGmerge,bod_N);

/*******************************/

proc sql;
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
  select distinct subjid, &socterm,&aeterm,1 as aeyn
  from adae
  where not missing(&aeterm)
  ;
quit;

%AHGmergedsn(justPT,allPT,alljustPT,by=subjid &socterm &aeterm,joinstyle=full/*left right full matched*/);

data alljustPT;
  set alljustPT;
  if missing(aeyn) then aeyn=0;
run;

%AHGfreeloop(allJustPT,&socterm &aeterm trtpn 
,cmd=newfreq(ahuige,aeyn,out=outfreq)
,out=outfreq
,in=Ahuige
,url=pterm_
,execute=1
,del=1
,addloopvar=1);

%getline(pterm_outfreq,mergePt_,pterm_N);

data theDSN;
  set AHGmerge: mergePt_:;
run;

%AHGrenamekeep(thedsn,out=renameDSN,pos=,names=value st1 soc term st2 st3 stALL,keep=1);

data renameDSN;
  set renameDSN;
  count=input(scan(stAll,1),best.);
run;
%AHGdatasort(data=renameDSN , out =ord , by =soc descending count );

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

%AHGreportby(ord,0,which=2 3 4 5,flow=flow,whichlength=12 12 12 12,sort=0,groupby=0,groupto=0,topline=,showby=0,option=nowd,labelopt=%str(option label;));

%AHGtoLocal(&tfl_output\&rtf..rtf,to=%mysdd(&tfl_output),open=0);

%AHGrtftotxt(&tfl_output\&rtf..rtf,,%mysdd(&replication_output\&rtf..txt) );

x "%mysdd(&replication_output\&rtf..txt) ";
x "%mysdd(&replication_output\qc_&rtf..txt)";
%mend;


