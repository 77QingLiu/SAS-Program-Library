/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research & Development / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 FU WANG $LastChangedBy: wangfu $
  Last Modified:         2017-07-17 $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_co.sas $
  SVN Revision No:       $Rev: 1 $

  Files Created:         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_co.sas
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_co.log
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_co.txt
                         /project39/janss234200/stats/tabulate/data/qtransfer/co.sas7dat

  Program Purpose:       to qc co domains
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
***Domain name:CO;
%let domain=CO;
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

proc import out=work.&domain.spec_VALDEF
     datafile="&_rawspec.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     range="VALDEF$A1:C118";
run;

************************************************************
*  COPY RAW DATASETS
************************************************************;
data &domain._raw_1; set raw.CO_GL_900(where=(&raw_sub)); run;

************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain.";
    USUBJID=catx("-",PROJECT,SUBJECT);
%mend assign_1;


************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*********************;
data &domain._pre_1;
    attrib &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID rename=(COVAL=COVAL_));
    %assign_1;

    if not missing(COVAL_) then do;
        COREF=upcase(catx(";",COREF_F,COREF_V));
        COVAL=COVAL_;
        COEVAL="INVESTIGATOR";
        output;
    end;

    format _all_; informat _all_;
    call missing(RDOMAIN, IDVAR, IDVARVAL, COSEQ);
    drop COSEQ;
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
%let &domain._keyvar_= STUDYID USUBJID IDVAR IDVARVAL COREF COVAL;
data &domain.; set &domain._base; run;
proc sort data=&domain._base; by  &&&domain._keyvar_; run;
proc sort data=&domain.; by  &&&domain._keyvar_; run;
%put "SORTING VARIABLES FOR &domain. DOMIAN: " &&&domain._keyvar_;
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



%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
