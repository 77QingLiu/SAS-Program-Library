/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research & Development / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 Hyland Zhang $LastChangedBy: xiaz $
  Last Modified:         2017-06-07 $LastChangedDate: 2017-07-27 02:40:47 -0400 (Thu, 27 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_sr.sas $
  SVN Revision No:       $Rev: 17 $

  Files Created:         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_sr.sas
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_sr.log
                         /project39/janss234200/stats/tabulate/qcprog/transfer/qc_sr.txt
                         /project39/janss234200/stats/tabulate/data/qtransfer/sr.sas7dat

  Program Purpose:       to qc sr domains
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
***Domain name:SR;
%let domain=SR;
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

************************************************************
*  IMPORT SPEC ("0A0D00"x)
************************************************************;
%jjqcgfname(fname=mapping specification, type=xlsx);
%put &fname;
%let specname=%str(&fname);
%let _rawspec=&specpath;

proc import out=work.VALDEF
     datafile="&_rawspec.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     sheet="VALDEF";
run;

************************************************************
*  COPY RAW DATASETS
************************************************************;
data &domain._raw_1; set raw.TT(where=(&raw_sub)); run;
data &domain._raw_2; set raw.TBINFO_1(where=(&raw_sub)); run;

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
    SROBJ="TST";
    SRGRPID="REPEAT";
    SRCAT="TUBERCULOSIS TESTING";

    if TTNA_STD in ("N", " ") then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="SRALL";
        SRTEST="Skin Response Tests";
        SRORRES="";
        SRORRESU="";
        SRSTRESC=SRORRES;
        SRSTRESN=.;
        SRSTRESU="";
        SRSTAT="NOT DONE";
        SRREASND="";
        %jjqcdate2iso(in_date=TTDTD, in_time=, out_date=&domain.DTC);
        DTC="N";
        output;
    end;

    if TTNA_STD="NA" then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="SRALL";
        SRTEST="Skin Response Tests";
        SRORRES="";
        SRORRESU="";
        SRSTRESC=SRORRES;
        SRSTRESN=.;
        SRSTRESU="";
        SRSTAT="NOT DONE";
        SRREASND="NOT APPLICABLE";
        %jjqcdate2iso(in_date=TTDTD, in_time=, out_date=&domain.DTC);
        DTC="N";
        output;
    end;

    if  TTNA_STD="Y" and TTRM^=. then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="DIAMETER";
        SRTEST="Diameter";
        SRORRES=strip(put(TTRM,best.));
        SRORRESU="mm";
        SRSTRESC=SRORRES;
        SRSTRESN=input(SRSTRESC,best.);
        SRSTRESU="mm";
        SRSTAT="";
        SRREASND="";
        %jjqcdate2iso(in_date=TTDTD, in_time=, out_date=&domain.DTC);
        output;
    end;

    if  TTNA_STD="Y" and TTIPN_STD^="" then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="INTP";
        SRTEST="Interpretation";
        SRORRES=TTIPN_STD;
        SRORRESU="";
        SRSTRESC=SRORRES;
        SRSTRESN=.;
        SRSTRESU="";
        SRSTAT="";
        SRREASND="";
        %jjqcdate2iso(in_date=TTDTD, in_time=, out_date=&domain.DTC);
        output;
    end;
    format _all_; informat _all_;

    call missing(SRSEQ, VISITNUM, VISIT, VISITDY, EPOCH, SRDY, SRBLFL);
    drop SRSEQ VISITNUM VISIT VISITDY EPOCH SRDY SRBLFL;
run;


data &domain._pre_2;
    attrib &&&domain._varatt_;
    set &domain._raw_2(drop=STUDYID);
    %assign_1;
    SOURCE=2;
    SROBJ="TST";
    SRGRPID="";
    SRCAT="SCREENING FOR TUBERCULOSIS";

    if TBADM_STD="N" then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="SRALL";
        SRTEST="Skin Response Tests";
        SRORRES="";
        SRORRESU="";
        SRSTRESC=SRORRES;
        SRSTRESN=.;
        SRSTRESU="";
        SRSTAT="NOT DONE";
        SRREASND="";
        %jjqcdate2iso(in_date=TBADMDT, in_time=, out_date=&domain.DTC);
        DTC="N";
        output;
    end;

    if TBADM_STD="U" then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="SRALL";
        SRTEST="Skin Response Tests";
        SRORRES="";
        SRORRESU="";
        SRSTRESC=SRORRES;
        SRSTRESN=.;
        SRSTRESU="";
        SRSTAT="NOT DONE";
        SRREASND="UNKNOWN";
        %jjqcdate2iso(in_date=TBADMDT, in_time=, out_date=&domain.DTC);
        DTC="N";
        output;
    end;

    if  TBADM_STD="Y" and TBRSLT^=. then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="DIAMETER";
        SRTEST="Diameter";
        SRORRES=strip(put(TBRSLT,best.));
        SRORRESU="mm";
        SRSTRESC=SRORRES;
        SRSTRESN=input(SRSTRESC,best.);
        SRSTRESU="mm";
        SRSTAT="";
        SRREASND="";
        %jjqcdate2iso(in_date=TBADMDT, in_time=, out_date=&domain.DTC);
        output;
    end;

    if  TBADM_STD="Y" and TBRPN_STD^="" then do;
        SRSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        SRTESTCD="INTP";
        SRTEST="Interpretation";
        SRORRES=TBRPN_STD;
        SRORRESU="";
        SRSTRESC=SRORRES;
        SRSTRESN=.;
        SRSTRESU="";
        SRSTAT="";
        SRREASND="";
        %jjqcdate2iso(in_date=TBADMDT, in_time=, out_date=&domain.DTC);
        output;
    end;
    format _all_; informat _all_;

    call missing(SRSEQ, VISITNUM, VISIT, VISITDY, EPOCH, SRDY, SRBLFL);
    drop SRSEQ VISITNUM VISIT VISITDY EPOCH SRDY SRBLFL;
run;

************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
%macro changeunit(var=,unitvar=,origin=,target=);
    if upcase(&var.)="&origin." then &var.="&target.";
%mend changeunit;

data &domain._base(&keep_sub);
    set &domain._pre_1 &domain._pre_2
    ;
    ***USE INTERNATIONAL UNIT INSTEAD;
    %changeunit(var=SRORRESU,origin=MM,target=mm);
    %changeunit(var=SRSTRESU,origin=MM,target=mm);

    rename SRDTC=SRDTC_base;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=SRDTC, time=);
data &domain._1;
    set &domain._1;
    if DTC^="N" then SRDTC=SRDTC_base;
run;

%jjqcmepoch(in_data=&domain._1,in_date=&domain.DTC);
%jjqccomdy(in_data=&domain._1, in_var=&domain.DTC, out_var=&domain.DY);
data &domain.; set &domain._1; run;
%jjqcblfl(sortvar=%str(STUDYID, USUBJID, &domain.TESTCD));
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
