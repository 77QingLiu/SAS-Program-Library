/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research & Development / CNTO1959PSA3002
  PAREXEL Study Code:    234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 Fu Wang $LastChangedBy: wangfu $
  Last Modified:         14JUL2017 $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_ex.sas $
  SVN Revision No:       $Rev: 1 $

  Files Created:         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ex.sas
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ex.log
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_ex.txt
                         /project39/janss234200/stats/tabulate/data/qtransfer/ex.sas7dat
                         /project39/janss234200/stats/tabulate/data/qtransfer/suppex.sas7dat

  Program Purpose:       to qc ex & suppex domains
-----------------------------------------------------------------------------*/


title;footnote;
dm "log; clear; out; clear;";
options nomprint;

************************************************************
*  GENERAL MACROS
************************************************************;
***macro used to change the length of specific character variables;
%macro changelen(varname=,tarlen=,type=);
  **varname: variable name;
  **tarlen:  target length;
  %IF &type.=char %THEN %DO; length &varname._ $&tarlen.; %END;
  %IF &type.=num %THEN %DO; length &varname._ &tarlen.; %END;
  &varname._=&varname;
  drop &varname;
  rename &varname._=&varname;
%mend changelen;

************************************************************
*  BASIC SETTINGS
************************************************************;
***Cleaning WORK library ;
%jjqcclean;
***Do not use threaded processing;
options nothreads;
***Domain name:EX;
%let domain=EX;
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

************************************************************
*  IMPORT SPEC ("0A0D00"x)
************************************************************;
%jjqcgfname(fname=mapping specification, type=xlsx);
%put &fname;
%let specname=%str(&fname);
%let _rawspec=/project39/janss234199/stats/tabulate/data/rawspec/;

proc import out=work.VALDEF
     datafile="&_rawspec.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     sheet="VALDEF";
run;


************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    length STUDYID $40. DOMAIN $2. USUBJID $40.;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain.";
    USUBJID=catx("-",PROJECT,SUBJECT);
%mend assign_1;

***assign_2;
%macro assign_2(QNAM=,QVAL=);
    QNAM="&QNAM.";
    QVAL=strip(&QVAL.);
    output;
%mend assign_2;

***assign_2;
%macro assign_3(var=,val=,QNAM=,QVAL=);
    if index(&var, "&val.")>0 then do;
      QNAM="&QNAM.";
      QVAL="&QVAL.";
      output;
    end;
%mend assign_3;

************************************************************
*  COPY RAW DATASETS
************************************************************;
data &domain._raw_1; set raw.explace(where=(&raw_sub)); run;
data &domain._raw_2; set raw.ex5(where=(&raw_sub)); run;
data &domain._raw_3; set raw.exyn(where=(&raw_sub)); run;
data &domain._raw_4; set raw.ex4(where=(&raw_sub)); run;


************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*********************;
data &domain._pre_1;
    attrib &&&domain._varatt_;
    %put &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID);
    where exadmin_std="N";
    %assign_1;
    SOURCE=1;
    length EXSPID $200.;
    EXREFID="";
    EXSPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),PAGEREPEATNUMBER,put(RECORDPOSITION,best.));
    EXTRT="GUS 100 mg SC & Placebo";
    EXCAT="";
    EXSCAT=strip(EXPLACE_STD);
    EXSTAT="NOT DONE";
    EXDOSE=.;
    EXDOSU="";
    EXDOSFRM="";
    EXDOSFRQ="";
    EXROUTE="";
    EXLOC="";
    EXSTDTC="";
    EXENDTC="";
    output;
    call missing(&domain.SEQ,VISITNUM,VISIT,VISITDY,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM VISIT VISITDY EPOCH &domain.STDY &domain.ENDY;
run;

*****RAW DATA 2******
*********************;
data &domain._pre_2;
    attrib &&&domain._varatt_;
    set &domain._raw_2(drop=STUDYID);
    %assign_1;
    SOURCE=2;
    length EXSPID $200.;
    EXREFID=strip(put(EXSYRIN,best.));
    EXSPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),PAGEREPEATNUMBER,put(RECORDPOSITION,best.));
    EXTRT="GUS 100 mg SC & Placebo";
    EXCAT="";
    EXSCAT="AT HOME";
    EXSTAT="";
    EXDOSE=.;
    EXDOSU="";
    EXDOSFRM="";
    EXDOSFRQ="";
    EXROUTE="SUBCUTANEOUS";
    if EXINJLO_STD in ('UPPER RIGHT ARM' 'UPPER LEFT ARM') then EXLOC='ARM';
    else if EXINJLO_STD in ('LEFT ABDOMEN' 'RIGHT ABDOMEN') then EXLOC='ABDOMEN';
    else if EXINJLO_STD in ('LEFT THIGH' 'RIGHT THIGH') then EXLOC='THIGH';
    %jjqcdate2iso(in_date=EXSTDT5, in_time=EXSTTM, out_date=EXSTDTC);
    EXENDTC="";
    output;
    call missing(&domain.SEQ,VISITNUM,VISIT,VISITDY,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM VISIT VISITDY EPOCH &domain.STDY &domain.ENDY;
run;

*****RAW DATA 3******
*********************;
data &domain._pre_3;
    attrib &&&domain._varatt_;
    set &domain._raw_3(drop=STUDYID);
    where EXADMIN_STD = 'N';
    %assign_1;
    SOURCE=3;
    length EXSPID $200.;
    EXREFID="";
    EXSPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),PAGEREPEATNUMBER,put(RECORDPOSITION,best.));
    EXTRT="GUS 100 mg SC & Placebo";
    EXCAT="";
    EXSCAT="AT SITE";
    EXSTAT="NOT DONE";
    EXDOSE=.;
    EXDOSU="";
    EXDOSFRM="";
    EXDOSFRQ="";
    EXROUTE="";
    EXLOC="";
    EXSTDTC="";
    EXENDTC="";
    output;
    call missing(&domain.SEQ,VISITNUM,VISIT,VISITDY,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM VISIT VISITDY EPOCH &domain.STDY &domain.ENDY;
run;

*****RAW DATA 4******
*********************;
data &domain._pre_4;
    attrib &&&domain._varatt_;
    set &domain._raw_4(drop=STUDYID);
    %assign_1;
    SOURCE=4;
    length EXSPID $200.;
    EXREFID=strip(put(EXSYRIN,best.));
    EXSPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),PAGEREPEATNUMBER,put(RECORDPOSITION,best.));
    EXTRT="GUS 100 mg SC & Placebo";
    EXCAT="";
    EXSCAT="AT SITE";
    EXSTAT="";
    EXDOSE=.;
    EXDOSU="";
    EXDOSFRM="";
    EXDOSFRQ="";
    EXROUTE="SUBCUTANEOUS";
    if EXINJLO_STD in ('UPPER RIGHT ARM' 'UPPER LEFT ARM') then EXLOC='ARM';
    else if EXINJLO_STD in ('LEFT ABDOMEN' 'RIGHT ABDOMEN') then EXLOC='ABDOMEN';
    else if EXINJLO_STD in ('LEFT THIGH' 'RIGHT THIGH') then EXLOC='THIGH';
    %jjqcdate2iso(in_date=EXSTDT, in_time=EXSTTM, out_date=EXSTDTC);
    EXENDTC="";
    output;
    call missing(&domain.SEQ,VISITNUM,VISIT,VISITDY,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM VISIT VISITDY EPOCH &domain.STDY &domain.ENDY;
run;


************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
%macro changeunit(var=,unitvar=,origin=,target=);
    if upcase(&var.)="&origin." then &var.="&target.";
%mend changeunit;

data &domain._base(&keep_sub);
    set &domain._pre_1
        &domain._pre_2
        &domain._pre_3
        &domain._pre_4
    ;
    ***USE INTERNATIONAL UNIT INSTEAD;
    %changeunit(var=EXDOSFRM,origin=INJECTABLE,target=INJECTION);
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.STDTC);
data &domain._1;
    set &domain._1;
run;

*ADD DY;
%jjqccomdy(in_data=&domain._1, in_var=&domain.STDTC, out_var=&domain.STDY);
%jjqccomdy(in_data=&domain._1, in_var=&domain.ENDTC, out_var=&domain.ENDY);

data &domain.; set &domain._1; 

proc sort; by USUBJID;
run;

*add seqnum;
%jjqcseq(in=&domain, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;
data supp&domain._raw; set &domain.; run;

data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
  retain &&&domain._varlst_;
  attrib &&&domain._varatt_;
  merge &domain(in=a) qtrans.dm(in=b keep=USUBJID arm);
  by USUBJID;
  if a;
  excat=arm;
  
  keep &&&domain._varlst_;
  format _all_;
  informat _all_;
run;


%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )

************************************************************
*  PREPARE FOR SUPP DOMAIN.
************************************************************;
%let domain=SUPP&domain.;
%let rdomain=%substr(&domain.,5,2);
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

data &domain._pre;
    attrib &&&domain._varatt_;
    set &domain._raw;
    RDOMAIN="&rdomain.";
    IDVAR="&rdomain.SEQ";
    IDVARVAL=strip(put(&rdomain.SEQ,best.));
    QORIG="CRF";
    QEVAL="";
    call missing(QLABEL);
    drop QLABEL;

    %assign_3(var=EXINJLO_STD,val=RIGHT,QNAM=EXLAT,QVAL=RIGHT);
    %assign_3(var=EXINJLO_STD,val=LEFT,QNAM=EXLAT,QVAL=LEFT);
    %assign_3(var=EXINJLO_STD,val=UPPER,QNAM=EXDIR,QVAL=UPPER);
    %assign_3(var=EXINJLO_STD,val=LOWER,QNAM=EXDIR,QVAL=LOWER);
    if ^missing(EXADMAGN_STD) then do; %assign_2(QNAM=EXADMAGN,QVAL=EXADMAGN_STD); end;
    if ^missing(EXTOTADM_STD) then do; %assign_2(QNAM=EXPOCCUR,QVAL=EXTOTADM_STD); end;
run;

proc sql;
    create table &domain._base as
        select a.*,b.QLABEL
        from &domain._pre as a
        left join  (select VALUEOID,VALVAL,strip(compress(VALLABEL,"0A0D00"x)) as QLABEL length=40
                    from VALDEF
                    where strip(compress(VALUEOID,"0A0D00"x))="&domain..QNAM") as b
        on a.QNAM=strip(compress(b.VALVAL,"0A0D00"x));
quit;

proc sort data=&domain._base nodupkey; by &&&domain._keyvar_ QVAL; run;
%put &&&domain._keyvar_;


************************************************************
*  FOR OUTPUTING SUPP DATASET AND COMPARATION.
************************************************************;
data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
  retain &&&domain._varlst_;
  attrib &&&domain._varatt_;
  set &domain._base;
  keep &&&domain._varlst_;
  format _all_;
  informat _all_;
run;



%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
