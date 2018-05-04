/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275CRD1001
  PXL Study Code:        234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Deborah Liu $LastChangedBy: xiaz $
  Creation Date:         21JUN2017 / $LastChangedDate: 2017-09-13 02:15:40 -0400 (Wed, 13 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_qs.sas $

  Files Created:         qc_qs.log
                         qs.sas7bdat
                         suppqs.sas7bdat

  Program Purpose:       To QC Questionnaire Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 28 $
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
***Domain name:QS;
%let domain=QS;
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

************************************************************
*  IMPORT SPEC ("0A0D00"x)
************************************************************;
%jjqcgfname(fname=Mapping Specification, type=xlsx);
/*%put &fname; */
%let specname=%str(&fname);


proc import out=work.VALDEF
     datafile="&specpath.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     sheet="VALDEF";
run;

************************************************************
*  COPY RAW DATASETS
************************************************************;
/*data &domain._raw_1;
    set rawert.QS;
    %changelen(varname=STUDYID,tarlen=40,type=char);
    %changelen(varname=QSTESTCD,tarlen=8,type=char);
    %changelen(varname=QSCAT,tarlen=200,type=char);
    %changelen(varname=QSORRES,tarlen=200,type=char);
    %changelen(varname=QSSTRESC,tarlen=200,type=char);
    %changelen(varname=QSEVAL,tarlen=60,type=char);
    %changelen(varname=QSTPT,tarlen=10,type=char);
    %changelen(varname=QSEVINT,tarlen=45,type=char);
run; */

************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    *length STUDYID $40. DOMAIN $2. USUBJID $40.;

    DOMAIN="&domain.";
    USUBJID=catx("-",STUDYID,SUBJID);
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
    /*%put &&&domain._varatt_; */
    /*set &domain._raw_1;
    %assign_1;
    SOURCE=1;
    *VARIABLE=QS_01_1;

        QSSPID="";
        QSTEST=put(QSTESTCD,$QS_TESTCD.);
        QSNAM="ERT";
        length YY_ $200.;


    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.DY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY;*/
    call missing(of _all_);
run;

************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain._base(&keep_sub);
    set &domain._pre_1
    ;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
/*%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=QSDTC, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.DTC);

*ADD DY;
%jjqccomdy(in_data=&domain._1, in_var=&domain.DTC, out_var=&domain.DY);


data &domain.; set &domain._1; run;

*add seqnum;
%jjqcseq(in=&domain, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID); */

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;
data supp&domain._raw; set /*&domain.*/&domain._base; run;

data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set /*&domain*/&domain._base;
    if usubjid="" then delete;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

data main_&domain.; set transfer.&domain.; run;

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
    /*set &domain._raw;
    RDOMAIN="&rdomain.";
    IDVAR="&rdomain.SEQ";
    IDVARVAL=strip(put(&rdomain.SEQ,best.));
    QORIG="EDT";
    QEVAL="";
    call missing(QLABEL);
    drop QLABEL;

    *VARIABLE QS_01_01;
    if ^missing(RNGTXTHI) then do; %assign_2(QNAM=RNGTXTHI,QVAL=RNGTXTHI); end;
    *VARIABLE QS_01_02;
    if ^missing(RNGTXTLOI) then do; %assign_2(QNAM=RNGTXTLO,QVAL=RNGTXTLO); end;
    *VARIABLE QS_01_03;
    if ^missing(RNGVALHI) then do; %assign_2(QNAM=RNGVALHI,QVAL=RNGVALHI); end;
    *VARIABLE QS_01_04;
    if ^missing(RNGVALLO) then do; %assign_2(QNAM=RNGVALLO,QVAL=RNGVALLO); end;*/
    if usubjid="" then delete;
    call missing( of _all_);
    drop qlabel;

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

proc sort data=&domain._base nodupkey;
    by &&&domain._keyvar_ QVAL;
    /*%put &&&domain._keyvar_;*/
run;

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
    call missing(of _all_);
run;

data main_&domain.; set transfer.&domain.; run;

%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
