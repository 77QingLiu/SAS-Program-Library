/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275CRD1001
  PXL Study Code:        234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Deborah Liu $LastChangedBy: xiaz $
  Creation Date:         07JUN2017 / $LastChangedDate: 2017-07-26 03:22:19 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_vs.sas $

  Files Created:         qc_vs.log
                         vs.sas7bdat


  Program Purpose:       To QC Vital Signs dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 3 $
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
***Domain name:VS;
%let domain=VS;
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

************************************************************
*  IMPORT SPEC ("0A0D00"x)
************************************************************;
%jjqcgfname(fname=Mapping Specification, type=xlsx);
/*%put &fname;*/
%let specname=%str(&fname);


proc import out=work.VALDEF
     datafile="&specpath.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     sheet="VALDEF";
run;

************************************************************
*  COPY RAW DATASETS
************************************************************;
data &domain._raw_1;set raw.VS_GL_903;run;
data &domain._raw_2;set raw.VS_GL_900;run;
data &domain._raw_3;set raw.VS_GL_900W;run;

************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    *length STUDYID $40. DOMAIN $2. USUBJID $40.;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain.";
    USUBJID=catx("-",PROJECT,SUBJECT);
    &domain.SPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                    put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));

%mend assign_1;

***assign_2;
%macro assign_2(QNAM=,QVAL=);
    QNAM="&QNAM.";
    QVAL=&QVAL.;
    output;
%mend assign_2;

***assign_STD;
%macro assign_STD(VAL=);
    &VAL.=strip(&VAL._STD);
%mend assign_STD;

************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*********************;
data &domain._pre_1;
    attrib &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID);
    %assign_1;

    *VARIABLE VS_01_01;

    VSCAT="VITAL SIGNS";

    if ^missing(PULSE) then do;
        SOURCE=1;

        VSTESTCD="PULSE";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(PULSE,best.));
        VSORRESU=PULSEU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=PULSE;
        VSSTRESU=PULSEU_STD;
        VSSTAT="";
        output;
    end;
    if ^missing(SYSBP) then do;
        SOURCE=2;
        VSTESTCD="SYSBP";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(SYSBP,best.));
        VSORRESU=SYSBPU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=SYSBP;
        VSSTRESU=SYSBPU_STD;
        VSSTAT="";
        output;
    end;
    if ^missing(DIABP) then do;
        SOURCE=3;
        VSTESTCD="DIABP";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(DIABP,best.));
        VSORRESU=DIABPU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=DIABP;
        VSORRESU=DIABPU_STD;
        VSSTAT="";
        output;
    end;
    if VSPERF_STD='N' then do;
        SOURCE=4;
        VSTESTCD="VSALL";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES="";
        VSORRESU="";
        VSSTRESC="";
        VSSTRESN=.;
        VSSTRESU="";
        VSSTAT="NOT DONE";
        output;
    end;

    call missing(&domain.SEQ,EPOCH,&domain.DY,VISIT,VISITNUM,VISITDY,&domain.BLFL,&domain.DTC);
    drop &domain.SEQ EPOCH &domain.DY VISITNUM VISIT VISITDY &domain.DTC &domain.BLFL;
run;

*****RAW DATA 2******
*********************;
data &domain._pre_2;
    attrib &&&domain._varatt_;
    set &domain._raw_2(drop=STUDYID);
    %assign_1;

    *VARIABLE VS_02_01;

    VSCAT="VITAL SIGNS BASELINE";

    if ^missing(HEIGHT) then do;
        SOURCE=5;
        VSTESTCD="HEIGHT";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(HEIGHT,best.));
        VSORRESU="cm";
        VSSTRESC=VSORRES;
        VSSTRESN=HEIGHT;
        VSSTRESU="cm";
        VSSTAT="";
        output;
    end;
    if ^missing(WEIGHT) then do;
        SOURCE=6;
        VSTESTCD="WEIGHT";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(WEIGHT,best.));
        VSORRESU="kg";
        VSSTRESC=VSORRES;
        VSSTRESN=WEIGHT;
        VSSTRESU="kg";
        VSSTAT="";
        output;
    end;

    if ^missing(PULSE) then do;
        SOURCE=7;
        VSTESTCD="PULSE";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(PULSE,best.));
        VSORRESU=PULSEU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=PULSE;
        VSSTRESU=PULSEU_STD;
        VSSTAT="";
        output;
    end;
    if ^missing(SYSBP) then do;
        SOURCE=8;
        VSTESTCD="SYSBP";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(SYSBP,best.));
        VSORRESU=SYSBPU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=SYSBP;
        VSSTRESU=SYSBPU_STD;
        VSSTAT="";
        output;
    end;
    if ^missing(DIABP) then do;
        SOURCE=9;
        VSTESTCD="DIABP";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(DIABP,best.));
        VSORRESU=DIABPU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=DIABP;
        VSORRESU=DIABPU_STD;
        VSSTAT="";
        output;
    end;
    if VSPERF_STD='N' then do;
        SOURCE=10;
        VSTESTCD="VSALL";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES="";
        VSORRESU="";
        VSSTRESC="";
        VSSTRESN=.;
        VSORRESU="";
        VSSTAT="NOT DONE";
        output;
    end;


    call missing(&domain.SEQ,EPOCH,&domain.DY,VISIT,VISITNUM,VISITDY,&domain.BLFL,&domain.DTC);
    drop &domain.SEQ EPOCH &domain.DY VISITNUM VISIT VISITDY &domain.DTC &domain.BLFL;
run;


*****RAW DATA 3******
*********************;
data &domain._pre_3;
    attrib &&&domain._varatt_;
    set &domain._raw_3(drop=STUDYID);
    %assign_1;

    *VARIABLE VS_03_01;

    VSCAT= "VITAL SIGNS (WEIGHT)";

    if ^missing(WEIGHT) then do;
        SOURCE=11;
        VSTESTCD="WEIGHT";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(WEIGHT,best.));
        VSORRESU="kg";
        VSSTRESC=VSORRES;
        VSSTRESN=WEIGHT;
        VSSTRESU="kg";
        VSSTAT="";
        output;
    end;

    if ^missing(PULSE) then do;
        SOURCE=12;
        VSTESTCD="PULSE";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(PULSE,best.));
        VSORRESU=PULSEU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=PULSE;
        VSSTRESU=PULSEU_STD;
        VSSTAT="";
        output;
    end;
    if ^missing(SYSBP) then do;
        SOURCE=13;
        VSTESTCD="SYSBP";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(SYSBP,best.));
        VSORRESU=SYSBPU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=SYSBP;
        VSSTRESU=SYSBPU_STD;
        VSSTAT="";
        output;
    end;
    if ^missing(DIABP) then do;
        SOURCE=14;
        VSTESTCD="DIABP";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES=strip(put(DIABP,best.));
        VSORRESU=DIABPU_STD;
        VSSTRESC=VSORRES;
        VSSTRESN=DIABP;
        VSORRESU=DIABPU_STD;
        VSSTAT="";
        output;
    end;
    if VSPERF_STD='N' then do;
        SOURCE=15;
        VSTESTCD="VSALL";
        VSTEST=put(VSTESTCD,$VS_TESTCD.);
        VSORRES="";
        VSORRESU="";
        VSSTRESC="";
        VSSTRESN=.;
        VSORRESU="";
        VSSTAT="NOT DONE";
        output;
    end;


    call missing(&domain.SEQ,EPOCH,&domain.DY,VISIT,VISITNUM,VISITDY,&domain.BLFL,&domain.DTC);
    drop &domain.SEQ EPOCH &domain.DY VISITNUM VISIT VISITDY &domain.DTC &domain.BLFL;
run;

************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain._base(&keep_sub);
    set &domain._pre_1
        &domain._pre_2
        &domain._pre_3
    ;
    if &raw_sub;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;

%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=VSDTC, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.DTC);
%jjqccomdy(in_data=&domain._1, in_var=&domain.DTC, out_var=&domain.DY);

data &domain.; set &domain._1; run;
%jjqcblfl(sortvar=%str(STUDYID, USUBJID, VSTESTCD, VSDTC));
%jjqcseq(in=&domain, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;

data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

/*data main_&domain.; set transfer.&domain.; run;*/

%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
