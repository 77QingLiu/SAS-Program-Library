/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275CRD1001
  PXL Study Code:        234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Fu Wang $LastChangedBy: wangfu $
  Creation Date:         07JUN2017 / $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_ae.sas $

  Files Created:         qc_ae.log
                         ae.sas7bdat
                         suppae.sas7bdat

  Program Purpose:       To QC Adverse Events dataset

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
***Domain name:AE;
%let domain=AE;
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
data &domain._raw_1;
    set raw.AE_GL_900;
    %changelen(varname=AETERM,tarlen=200,type=char);
run;

************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    *length STUDYID $40. DOMAIN $2. USUBJID $40.;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain.";
    USUBJID=catx("-",PROJECT,SUBJECT);
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
    /*%put &&&domain._varatt_;*/
    set &domain._raw_1(drop=STUDYID
        AESEV AEACN AEREL AEOUT AESER AESCONG AESDISAB AESDTH AESHOSP
        AESLIFE AESMIE AESCAT rename=(AECAT=AECAT_));
    %assign_1;
    if &raw_sub;
    SOURCE=1;
    *VARIABLE=MO_01_1;
    if ^missing(AETERM) then do;
        AESPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        AETERM=strip(AETERM);
        AELLT=strip(AETERM_LLT);
        AELLTCD=input(AETERM_LLT_CODE,??best.);
        AEDECOD=strip(AETERM_PT);
        AEPTCD=input(AETERM_PT_CODE,??best.);
        AEHLT=strip(AETERM_HLT);
        AEHLTCD=input(AETERM_HLT_CODE,??best.);
        AEHLGT=strip(AETERM_HLGT);
        AEHLGTCD=input(AETERM_HLGT_CODE,??best.);
        AEBODSYS=strip(AETERM_SOC);
        AEBDSYCD=input(AETERM_SOC_CODE,??best.);
        AESOC=strip(AETERM_SOC);
        AESOCCD=input(AETERM_SOC_CODE,??best.);
        length YY_ $200.;
/* call missing(of AELLT AELLTCD AEDECOD AEPTCD AEHLT AEHLTCD AEHLGT AEHLGTCD AEBODSYS AEBDSYCD AESOC AESOCCD ); */
        if AECAT_="Yes" then AECAT="ADVERSE EVENTS OF INTEREST";
        else if AECAT_ in ("No","") then AECAT = "GENERAL ADVERSE EVENTS";

        %assign_STD(VAL=AESCAT)
        %assign_STD(VAL=AESEV)
        %assign_STD(VAL=AESER)
        %assign_STD(VAL=AEACN)
        %assign_STD(VAL=AEREL)
        %assign_STD(VAL=AEOUT)
        %assign_STD(VAL=AESCONG)
        %assign_STD(VAL=AESDISAB)
        %assign_STD(VAL=AESDTH)
        %assign_STD(VAL=AESHOSP)
        %assign_STD(VAL=AESLIFE)
        %assign_STD(VAL=AESMIE)
        /*%assign_STD(VAL=AECONTRT)*/
        %jjqcdate2iso(in_date=AESTDAT, in_time=AESTTIM, out_date=AESTDTC);
        %jjqcdate2iso(in_date=AEENDAT, in_time=AEENTIM, out_date=AEENDTC);
        if AEONGO=1 then AEENRF='AFTER';else AEENRF='';
        output;
    end;
    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY;
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
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.STDTC);

*ADD DY;
%jjqccomdy(in_data=&domain._1, in_var=&domain.STDTC, out_var=&domain.STDY);
%jjqccomdy(in_data=&domain._1, in_var=&domain.ENDTC, out_var=&domain.ENDY);

data &domain.; set &domain._1; run;

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

    if ^missing(aeinjsrc_std) then do; %assign_2(QNAM=AEINJSRC,QVAL=aeinjsrc_std);end;
    if ^missing(AEINJS_STD) /* and AEINJSRC_STD="Y"  */then do;%assign_2(QNAM=AEINJS,QVAL=aeinjs_std);end;
    if ^missing(AEINF_STD) then do;%assign_2(QNAM=AEINF,QVAL=AEINF_STD);end;
    if ^missing(AETRTOPA_STD) and AEINF_STD='Y' then do;%assign_2(QNAM=AETRTOPA,QVAL=AETRTOPA_STD);end;
    if ^missing(AESIBEYN_STD) then do;%assign_2(QNAM=AESIBEYN,QVAL=AESIBEYN_STD);end;
    if ^missing(AESIBE_STD) and AESIBEYN_STD='Y' then do;%assign_2(QNAM=AESIBE,QVAL=AESIBE_STD);end;
    if ^missing(AESHOSPP_STD) then do;%assign_2(QNAM=AESHOSPP,QVAL=AESHOSPP_STD);end;
    if ^missing(AEMROBT_STD) then do;%assign_2(QNAM=AEMROBT,QVAL=AEMROBT_STD);end;
    if ^missing(AETRLPRC_STD) then do;%assign_2(QNAM=AETRLPRC,QVAL=AETRLPRC_STD);end;
    if ^missing(AERELDEV_STD) then do;%assign_2(QNAM=AERELDEV,QVAL=AERELDEV_STD);end;
    if ^missing(AEREDEMA_STD) then do;%assign_2(QNAM=AEREDEMA,QVAL=AEREDEMA_STD);end;
    if ^missing(AESINTV_STD) then do;%assign_2(QNAM=AESINTV,QVAL=AESINTV_STD);end;
  
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
run;

data main_&domain.; set transfer.&domain.; run;

%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
