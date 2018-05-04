/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: JANSEEN RESEARCH and DEVELOPMENT / CNTO1275CRD1001
  PXL Study Code:        234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------
  Author:                Fu Wang $LastChangedBy: xiaz $
  Creation Date:         14JUL2017 / $LastChangedDate: 2017-07-26 23:31:16 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_pr.sas $

  Files Created:         /project28/janss231814/stats/transfer/data/qtransfer/pr.sas7bdat
                         qc_pr.txt
                         qc_pr.log

  Program Purpose:       To QC Procedure Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 10 $
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
***Domain name:PR;
%let domain=PR;
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
proc sort data=raw.DM_GL_900 out=DM_GL_900;by SITEID SUBJECT;run;
proc sort data=raw.PR_PS_001 out=PR_PS_001;by SITEID SUBJECT;run;
proc sort data=raw.PR_RA_001 out=PR_RA_001;by SITEID SUBJECT;run;

data &domain._raw_1;set raw.PR_GL_902;run;
data &domain._raw_2;merge PR_PS_001 DM_GL_900(keep=SUBJECT RFICDAT RFICDAT_YY RFICDAT_MM RFICDAT_DD SITEID);by SITEID SUBJECT;run;
data &domain._raw_3;merge PR_RA_001 DM_GL_900(keep=SUBJECT RFICDAT RFICDAT_YY RFICDAT_MM RFICDAT_DD SITEID);by SITEID SUBJECT;run;

data &domain._raw_3;set &domain._raw_3;%changelen(varname=PRINDC,tarlen=200,type=char);run;
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
    SOURCE=1;
    length YY_ $200.;
    *VARIABLE PR_01_01;
    if ^missing(PRTRT) then do;
        %assign_STD(VAL=PRSCAT)
        %assign_STD(VAL=PRINDC)
        PRLOC="";
        PRENDTC="";
        PRENDY=.;
        PRENRF="";
        PRSTRTPT="";
        PRSTTPT="";
        PRINDC=upcase(PRINDC);
        %jjqcdate2iso(in_date=PRPLNDAT, in_time=, out_date=PRSTDTC);
        output;
    end;
    if PRTRT^="";
    call missing(&domain.SEQ,EPOCH,&domain.STDY,VISIT,VISITNUM,VISITDY);
    drop &domain.SEQ EPOCH &domain.STDY VISIT VISITNUM VISITDY;
run;

*****RAW DATA 2******
*********************;
data &domain._pre_2;
    attrib &&&domain._varatt_;
    set &domain._raw_2(drop=STUDYID);
    %assign_1;
    SOURCE=2;

    length YY_ $200.;
    *VARIABLE PR_02_01;

    PRCAT=PRCAT_PS1;
    PRSCAT="";
/*    PRINDC=upcase(PRINDC_PS1);*/
/*	if PRINDC_PS1 = "Psoriatic Arthritis" then CMINDC= "TRIAL INDICATION";*/
/*	else if PRINDC_PS1 = "Non-Psoriatic Arthritis" then CMINDC = "OTHER";*/
    PRINDC = strip(PRINDC_PS1_STD);
    PRLOC="";

    if upcase(PRTRT_PS1)="OTHER" and ^missing(PRTRTO) then PRTRT=PRTRTO;
    else if upcase(PRTRT_PS1)^="OTHER" and ^missing(PRTRT_PS1) then PRTRT=PRTRT_PS1;

    if PRONGO=1 then PRENRF='AFTER' ;
    else PRENRF='';

    if PRPRIOR_STD="Y" then PRSTRTPT='BEFORE';
    else if PRPRIOR_STD="N" then PRSTRTPT='AFTER';

    %jjqcdate2iso(in_date=PRSTDAT, in_time=PRSTTIM, out_date=PRSTDTC);
    %jjqcdate2iso(in_date=PRENDAT, in_time=PRENTIM, out_date=PRENDTC);
    %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=PRSTTPT);
    if PRTRT^="";
    call missing(&domain.SEQ,EPOCH,&domain.STDY,&domain.ENDY,VISIT,VISITNUM,VISITDY);
    drop &domain.SEQ EPOCH &domain.STDY &domain.ENDY VISIT VISITNUM VISITDY;
run;

*****RAW DATA 3******
*********************;
data &domain._pre_3;
    attrib &&&domain._varatt_;
    set &domain._raw_3(drop=STUDYID);
    %assign_1;
    SOURCE=3;

    length YY_ $200.;
    *VARIABLE PR_03_01;

    PRSCAT="";
    PRTRT=PRTRT_RA1_STD;
    PRLOC="";
    /*%assign_STD(VAL=PRINDC)*/
/*    PRINDC=upcase(PRINDC);*/
	if PRINDC = "Psoriatic Arthritis" then PRINDC= "TRIAL INDICATION";
	else if PRINDC = "Non-Psoriatic Arthritis" then PRINDC = "OTHER";



    PRLOC=PRLOC_JNT_STD;

    PRENRF='';

    if PRPRIOR_PS_STD="Y" then PRSTRTPT='BEFORE';
    else if PRPRIOR_PS_STD="N" then PRSTRTPT='AFTER';

    %jjqcdate2iso(in_date=PRSTDAT_PD, in_time=, out_date=PRSTDTC);
    %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=PRSTTPT);

    PRENDTC="";
    PRENDY=.;
    if PRTRT^="";
    call missing(&domain.SEQ,EPOCH,&domain.STDY,&domain.ENDY,VISIT,VISITNUM,VISITDY);
    drop &domain.SEQ EPOCH &domain.STDY &domain.ENDY VISIT VISITNUM VISITDY PRINDC_STD;
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
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.STDTC);
%jjqccomdy(in_data=&domain._1, in_var=&domain.STDTC, out_var=&domain.STDY);
/*%jjqcmepoch(in_data=&domain._1,in_date=&domain.ENDTC);*/
%jjqccomdy(in_data=&domain._1, in_var=&domain.ENDTC, out_var=&domain.ENDY);
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

    *VARIABLE PR_01_01;
    if ^missing(PRINDDSC) then do; %assign_2(QNAM=PRINDDSC,QVAL=PRINDDSC); end;
    *VARIABLE PR_01_02;
    if ^missing(PRPLNDAT) then do; %assign_2(QNAM=PRMOOD,QVAL='SCHEDULED'); end;
    *VARIABLE PR_02_01;
    if ^missing(PRLAT_STD) then do; %assign_2(QNAM=PRLAT,QVAL=PRLAT_STD); end;
    *VARIABLE PR_02_02;
    if ^missing(PRLOCO) then do; %assign_2(QNAM=PRLOCO,QVAL=PRLOCO); end;

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
