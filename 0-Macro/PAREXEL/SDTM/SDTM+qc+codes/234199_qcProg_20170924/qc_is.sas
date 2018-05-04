/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: JANSEEN RESEARCH and DEVELOPMENT / CNTO1959PSA3001
  PXL Study Code:        234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Deborah Liu  $LastChangedBy: xiaz $
  Creation Date:         09SEP2017/ $LastChangedDate: 2017-09-11 02:42:49 -0400 (Mon, 11 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_is.sas $

  Files Created:          /project33/janss234200/stats/transfer/data/qtransfer/is.sas7bdat
                          /project33/janss234200/stats/transfer/data/qtransfer/suppis.sas7bdat
                         qc_is.txt
                         qc_is.log

  Program Purpose:       To QC Immunogenicity Specimen Assessments Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 27 $
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
***Domain name:IS;
%let domain=IS;
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
data &domain._raw_1; set raw.PC_GL_901; /*%changelen(varname=MHTERM,tarlen=200,type=char);*/run;


************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
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
    set &domain._raw_1 (drop=STUDYID);
    %assign_1;
    SOURCE=1;
    *VARIABLE IS_01_01;
    if PCYN_STD="Y" then do;
        ISREFID="";
        ISTESTCD="SUPTITR";
        ISTEST=put(ISTESTCD,$IS_TESTCD.);
        ISCAT="GUSELKUMAB";
        ISORRES="";
        ISORRESU="";
        ISSTRESC="";
        ISSTRESN=.;
        ISSTRESU="";
        ISSTAT="";
        ISREASND="";
        ISNAM="";
        ISSPEC="SERUM";
        ISMETHOD="";
        ISLLOQ=.;
        %jjqcdate2iso(in_date=PCDAT, in_time=, out_date=ISDTC);
        output;
    end;
    call missing(&domain.SEQ, EPOCH, &domain.DY, VISIT, VISITNUM ,VISITDY,ISBLFL);
    drop &domain.SEQ EPOCH &domain.DY  VISIT VISITNUM VISITDY ISBLFL;
run;

*****RAW DATA 2******
*********************;
data &domain._pre_2;
    attrib &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID);
    %assign_1;
    SOURCE=2;
    *VARIABLE IS_02_01;
    if PCYN_STD="N" then do;
        ISREFID="";
        ISTESTCD="ISALL";
        ISTEST=put(ISTESTCD,$IS_TESTCD.);
        ISCAT="GUSELKUMAB";
        ISORRES="";
        ISORRESU="";
        ISSTRESC="";
        ISSTRESN=.;
        ISSTRESU="";
        ISSTAT="NOT DONE";
        ISREASND="SAMPLE NOT COLLECTED";
        ISNAM="";
        ISSPEC="";
        ISMETHOD="";
        ISLLOQ=.;
        %jjqcdate2iso(in_date=PCDAT, in_time=, out_date=ISDTC);
        output;
    end;
    call missing(&domain.SEQ, EPOCH, &domain.DY, VISIT, VISITNUM ,VISITDY,ISBLFL);
    drop &domain.SEQ EPOCH &domain.DY  VISIT VISITNUM VISITDY ISBLFL;
run;


************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain._base(&keep_sub);
    set &domain._pre_1
        &domain._pre_2

    ;
    if &raw_sub;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.DTC);

%jjqccomdy(in_data=&domain._1, in_var=&domain.DTC, out_var=&domain.DY);

data &domain._1;
     set &domain._1;
     if VISIT in ("WEEK 0","WEEK 4","WEEK 12","WEEK 24","WEEK 28","WEEK 52","WEEK 76","WEEK 100","WEEK 112")
     or index(visit,"UNSCHEDULED") >0;
run;

data &domain.; set &domain._1; run;
%jjqcblfl( sortvar = %str(STUDYID, USUBJID, ISTESTCD, ISDTC, ISSPEC, VISITNUM, ISORRES));
%jjqcseq(in=&domain, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;
/*data supp&domain._raw; set &domain.; run;*/
data supp&domain._raw; set /*&domain*/&domain._base; if usubjid="" then delete;run;

data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
    if usubjid="" then delete;
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
    QORIG="CRF";
    QEVAL="";
    call missing(QLABEL);
    drop QLABEL;

    *VARIABLE MH_01_01;
    if ^missing(TBBCGYR_STD) then do; %assign_2(QNAM=TBBCGYR,QVAL=TBBCGYR_STD); end; */
    call missing(of _all_);
         drop QLABEL;
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
    /*%put &&&domain._keyvar_; */
run;

************************************************************
*  FOR OUTPUTING SUPP DATASET AND COMPARATION.
************************************************************;
data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    /*set &domain._base; */
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
    if usubjid="" then delete;
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
