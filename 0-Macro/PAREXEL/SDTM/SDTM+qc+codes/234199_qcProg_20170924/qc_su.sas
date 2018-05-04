/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research & Development / CNTO1959PSA3002
  PAREXEL Study Code:    234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 fu wang $LastChangedBy: wangfu $
  Last Modified:         2017-06-07 $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_su.sas $
  SVN Revision No:       $Rev: 1 $

  Files Created:         /project39/janss234199/stats/tabulate/qcprog/transfer/qc_su.sas
                         /project39/janss234199/stats/tabulate/qcprog/transfer/qc_su.log
                         /project39/janss234199/stats/tabulate/qcprog/transfer/qc_su.txt
                         /project39/janss234199/stats/tabulate/data/qtransfer/su.sas7dat
                         /project39/janss234199/stats/tabulate/data/qtransfer/suppsu.sas7dat

  Program Purpose:       to qc su & suppsu domains
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
***Domain name:SU;
%let domain=SU;
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

************************************************************
*  COPY RAW DATASETS
************************************************************;
data &domain._raw_1; set raw.SU_GL_900A(where=(&raw_sub)); run;
data &domain._raw_2; set raw.SU_GL_900B(where=(&raw_sub)); run;


************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*********************;
data &domain._pre_1;
    attrib &&&domain._varatt_;
    %put &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID rename=(SUCAT=SUCAT_ SUTRT=SUTRT_ SUDOSU=SUDOSU_ SUDOSFRQ=SUDOSFRQ_));
    SOURCE=1;
    %assign_1;
    *VARIABLE=SU_01_1;
    SUSPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),PAGEREPEATNUMBER,put(RECORDPOSITION,best.));
    SUCAT=SUCAT_;
    SUTRT=SUTRT_STD;
    SUPRESP="Y";
    if SUNCF_STD in ("CURRENT" "FORMER") then SUOCCUR="Y";
    else if SUNCF_STD="NEVER" then SUOCCUR="N";
    SUDOSE=SUDSTXT;
    if SUDOSE=. then SUDOSTXT=strip(put(SUDSTXT,best.));
    SUDOSU=SUDOSU_STD;
    SUDOSFRQ=SUDOSFRQ_STD;
    %jjqcdate2iso(in_date=SUSTDAT, in_time=, out_date=SUSTDTC);
    %jjqcdate2iso(in_date=SUENDAT, in_time=, out_date=SUENDTC);
    output;
    call missing(&domain.SEQ,VISITNUM,VISIT,VISITDY,EPOCH,&domain.DTC,&domain.DY,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM VISIT VISITDY EPOCH &domain.DTC &domain.DY &domain.STDY &domain.ENDY;
run;

*****RAW DATA 2******
*********************;
data &domain._pre_2;
    attrib &&&domain._varatt_;
    %put &&&domain._varatt_;
    set &domain._raw_2(drop=STUDYID rename=(SUCAT=SUCAT_ SUTRT=SUTRT_ SUDOSU=SUDOSU_ SUDOSFRQ=SUDOSFRQ_));
    SOURCE=2;
    %assign_1;
    *VARIABLE=SU_01_1;
    SUSPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),PAGEREPEATNUMBER,put(RECORDPOSITION,best.));
    SUCAT=SUCAT_;
    SUTRT=SUTRT_STD;
    SUPRESP="Y";
    if SUNCF_STD in ("CURRENT" "FORMER") then SUOCCUR="Y";
    else if SUNCF_STD="NEVER" then SUOCCUR="N";
    SUDOSE=SUDSTXT;
    if SUDOSE=. then SUDOSTXT=strip(put(SUDSTXT,best.));
    SUDOSU=SUDOSU_STD;
    SUDOSFRQ=SUDOSFRQ_STD;
    %jjqcdate2iso(in_date=SUSTDAT, in_time=, out_date=SUSTDTC);
    %jjqcdate2iso(in_date=SUENDAT, in_time=, out_date=SUENDTC);
    output;
    call missing(&domain.SEQ,VISITNUM,VISIT,VISITDY,EPOCH,&domain.DTC,&domain.DY,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM VISIT VISITDY EPOCH &domain.DTC &domain.DY &domain.STDY &domain.ENDY;
run;


************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain._base(&keep_sub);
    set &domain._pre_1
        &domain._pre_2(drop=SUDOSU_)
    ;
run;

************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=SUDTC, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.DTC);
data &domain._1;
    set &domain._1;
run;

*ADD DY;
%jjqccomdy(in_data=&domain._1, in_var=&domain.DTC, out_var=&domain.DY);
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

data temp;set &domain.(drop=SUDOSTXT);
  attrib SUDOSTXT length=$60 label="Substance Use Consumption Text";
  SUDOSTXT="";
run;

data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
  retain &&&domain._varlst_;
  attrib &&&domain._varatt_;
  set temp;
  keep &&&domain._varlst_ SUDOSTXT;
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

    if ^missing(SUNCF_STD) then do; %assign_2(QNAM=SUNCF,QVAL=SUNCF_STD); end;
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
