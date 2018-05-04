/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275CRD1001
  PXL Study Code:        234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Fu Wang $LastChangedBy: wangfu $
  Creation Date:         14JUL2017 / $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_be.sas $

  Files Created:         qc_be.log
                         be.sas7bdat

  Program Purpose:       To QC Biospecimen Events dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 1 $
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
***Domain name:BE;
%let domain=BE;
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
data &domain._raw_1; set raw.BE_GL_902; run;
data &domain._raw_2; set raw.DN2; run;
data &domain._raw_3; set raw.BE_GL_903; run;
data &domain._raw_4; set raw.BE_GL_905; run;

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

************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*********************;
data &domain._pre_1;
    attrib &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID);
    %assign_1;
    SOURCE=1;
    length YY_ $200.;
    *VARIABLE BE_01_01;
    if BEDNAYN_STD='Y' then do;
        BETERM='CONSENT OBTAINED';
        BECAT=strip(BECAT_STD);
        %jjqcdate2iso(in_date=BESTDAT, in_time=, out_date=BESTDTC);
        output;
    end;
    call missing(&domain.SEQ,EPOCH,&domain.STDY);
    drop &domain.SEQ EPOCH &domain.STDY;
run;

*****RAW DATA 2******
*********************;
data &domain._pre_2;
    attrib &&&domain._varatt_;
    set &domain._raw_2(drop=STUDYID);
    %assign_1;
    SOURCE=2;
    length YY_ $200.;
    *VARIABLE BE_02_01;
    if ^missing(DN2INFDT) then do;
        BETERM='DNA SAMPLE CONSENT MODIFICATION';
        BECAT="DNA SAMPLE CONSENT MODIFICATION";
        %jjqcdate2iso(in_date=DN2INFDT, in_time=, out_date=BESTDTC);
        output;
    end;
    call missing(&domain.SEQ,EPOCH,&domain.STDY);
    drop &domain.SEQ EPOCH &domain.STDY;
run;

*****RAW DATA 3******
*********************;
data &domain._pre_3;
    attrib &&&domain._varatt_;
    set &domain._raw_3(drop=STUDYID);
    %assign_1;
    SOURCE=3;
    length YY_ $200.;
    *VARIABLE BE_03_01;
    if BEWDNAYN_STD ='Y' then do;
        BETERM='CONSENT WITHDRAWN';
        BECAT=strip(BECAT_STD);
        %jjqcdate2iso(in_date=BESTDAT, in_time=, out_date=BESTDTC);
        output;
    end;
    call missing(&domain.SEQ,EPOCH,&domain.STDY);
    drop &domain.SEQ EPOCH &domain.STDY;
run;

*****RAW DATA 4******
*********************;
data &domain._pre_4;
    attrib &&&domain._varatt_;
    set &domain._raw_4(drop=STUDYID);
    %assign_1;
    SOURCE=4;
    length YY_ $200.;
    *VARIABLE BE_04_01;
    if BEWFRYN_STD ='Y' then do;
        BETERM='CONSENT WITHDRAWN';
        BECAT=strip(BECAT_STD);
        %jjqcdate2iso(in_date=BESTDAT, in_time=, out_date=BESTDTC);
        output;
    end;
    call missing(&domain.SEQ,EPOCH,&domain.STDY);
    drop &domain.SEQ EPOCH &domain.STDY;
run;

************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain._base(&keep_sub);
    set &domain._pre_1
        &domain._pre_2
        &domain._pre_3
        &domain._pre_4
    ;
    if &raw_sub;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.STDTC);
%jjqccomdy(in_data=&domain._1, in_var=&domain.STDTC, out_var=&domain.STDY);
data &domain.; set &domain._1; run;
%jjqcseq(in=&domain, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;
data supp&domain._raw; set &domain.; run;

data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
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
    set &domain._raw;
    RDOMAIN="&rdomain.";
    IDVAR="&rdomain.SEQ";
    IDVARVAL=strip(put(&rdomain.SEQ,best.));
    QORIG="CRF";
    QEVAL="";
    call missing(QLABEL);
    drop QLABEL;

    *VARIABLE BE_01_01;
    if ^missing(BEAGDNAYN_STD) then do; %assign_2(QNAM=BEYNP1,QVAL=BEAGDNAYN_STD); end;
    *VARIABLE BE_01_02;
    if ^missing(BEAGSAMYN_STD) then do; %assign_2(QNAM=BEYNP2,QVAL=BEAGSAMYN_STD); end;
    *VARIABLE BE_02_01;
    if ^missing(DN2AGDNAYN_STD) then do; %assign_2(QNAM=BEYNP1,QVAL=DN2AGDNAYN_STD); end;
    *VARIABLE BE_02_02;
    if ^missing(DN2SAMYN_STD) then do; %assign_2(QNAM=BEYNP2,QVAL=DN2SAMYN_STD); end;


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
    set &domain._base;
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
