/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         27Jun2016 / $LastChangedDate: 2016-08-24 04:46:14 -0400 (Wed, 24 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_ds.sas $

  Files Created:         qc_DS.log
                         DS.sas7bdat

  Program Purpose:       To QC Disposition Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 25 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=DS;
%jjqcvaratt(domain=DS);
%jjqcdata_type;

*------------------- Read raw data --------------------;
data DM_GL_900;
    set raw.DM_GL_900(where=(&raw_sub));
    if ^missing(RFICDAT);
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername RFICDAT_: SPRTDAT:;
run;

data DS_GL_905;
    set raw.DS_GL_905(where=(&raw_sub));
    if DSSTUDYN= 'Yes';
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername DSSTUDYN ;
run; 

data DS_GL_902;
    set raw.DS_GL_902(where=(&raw_sub));
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername DSRANDYN_STD RANDOMIZED_AT: ;
run;

data DS_GL_908;
    set raw.DS_GL_908(where=(&raw_sub));
    rename DSDECOD=DSDECOD_;
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername DSSTDAT_TDD: DSDECOD_REAS_STD DSPREDAT: 
         DSTERM_OTH DSTERM_WITH DSDECOD;
run;

data DS_GL_900;
    set raw.DS_GL_900(where=(&raw_sub));
    rename DSTERM=DSTERM_ DSDECOD=DSDECOD_;
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername DSSTDAT: DSDECOD_REAS_STD DSTERM_WITH DSTERM DSDECOD DSPREDAT: ;
run;

*------------------- Mapping --------------------;
/* Form:  Demographics*/
data DS_1a;
    set DM_GL_900;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    DSSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    DSTERM  ='INFORMED CONSENT OBTAINED';
    DSDECOD ='INFORMED CONSENT OBTAINED';
    DSCAT   ='PROTOCOL MILESTONE';
    %jjqcdate2iso(in_date =RFICDAT, in_time=, out_date=DSSTDTC);
    call missing(of DSSEQ DSSCAT VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY);
    drop DSSEQ DSSCAT VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY;
run;

/* Form: Consent for Participation in Substudy(ies */
data DS_1b;
    set DS_GL_905;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    DSSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    DSTERM  ='SUBSTUDY CONSENT OBTAINED';
    DSDECOD ='SUBSTUDY CONSENT OBTAINED';
    DSCAT   ='OTHER EVENT';
    DSSCAT  ='PK SUBSTUDY';
    call missing(of DSSEQ DSSTDTC VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY);
    drop DSSEQ DSSTDTC VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY;
run; 

/* Form: Randomization */
data DS_1c;
    set DS_GL_902;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    DSSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    DSTERM  =ifc(DSRANDYN_STD='Y','RANDOMIZED','NOT RANDOMIZED');
    DSDECOD =DSTERM;
    DSCAT   ='PROTOCOL MILESTONE';
    %jjqcdate2iso(in_date =RANDOMIZED_AT, in_time=, out_date=DSSTDTC);
    call missing(of DSSEQ DSSCAT VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY);
    drop DSSEQ DSSCAT VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY;
run; 

/* Form: Treatment Disposition */
data DS_1d;
    set DS_GL_908;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    DSSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    DSCAT   ='DISPOSITION EVENT';
    DSSCAT  ='TREATMENT';
    %jjqcdate2iso(in_date =DSSTDAT_TDD, in_time=, out_date=DSSTDTC);
    if DSDECOD_='Completed' then do;
        DSTERM = 'COMPLETED';DSDECOD='COMPLETED';
        output;
    end;
    else do;
        DSDECOD=strip(DSDECOD_REAS_STD);
        if DSDECOD_REAS_STD ='OTHER' then DSTERM =upcase(strip(DSTERM_OTH));
        else if DSDECOD_REAS_STD ='WITHDRAWAL BY SUBJECT' then DSTERM=upcase(strip(DSTERM_WITH));
        else DSTERM=strip(DSDECOD_REAS_STD);
        output;
    end;
    call missing(of DSSEQ VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY);
    drop DSSEQ VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY;
run; 

/* Form:  Trial Disposition*/
data DS_1e;
    set DS_GL_900;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    DSSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    DSCAT   ='DISPOSITION EVENT';
    DSSCAT  ='TRIAL';
    %jjqcdate2iso(in_date =DSSTDAT, in_time=, out_date=DSSTDTC);
    if DSDECOD_='Completed' then do;
        DSTERM = 'COMPLETED';DSDECOD='COMPLETED';
        output;
    end;
    else do;    
        DSDECOD=strip(DSDECOD_REAS_STD);
        if DSDECOD_REAS_STD ='OTHER' then DSTERM =upcase(strip(DSTERM_));
        else if DSDECOD_REAS_STD ='WITHDRAWAL BY SUBJECT' then DSTERM=upcase(strip(DSTERM_WITH));
        else DSTERM=strip(DSDECOD_REAS_STD);
        if ^missing(DSTERM) then output;
    end;
    call missing(of DSSEQ VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY);
    drop DSSEQ VISITNUM VISIT VISITDY EPOCH DSDTC DSDY DSSTDY;
run; 

/* Join All */
data DS_2;
    set DS_1a DS_1b DS_1c DS_1d DS_1e;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=DS_2, out_data=DS_3, date=DSDTC, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=DS_3,out_data=DS_4, in_var=DSDTC, out_var=DSDY);
%jjqccomdy(in_data=DS_4,out_data=DS_5, in_var=DSSTDTC, out_var=DSSTDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=DS_5,out_data=DS_6, in_date=DSSTDTC);

*------------------- DSSEQ --------------------;
%jjqcseq(in_data=DS_6, out_data=DS_7, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =DS_7 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

***********************************SUPPDS*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPDS;
%jjqcvaratt(domain=SUPPDS);

*------------------- Mapping --------------------;
data SUPPDS_1;
    set DS_7;
    attrib &&&domain._varatt_;
    RDOMAIN  ="DS";
    IDVAR    ='DSSEQ';
    IDVARVAL =put(DSSEQ,best. -l);
    QEVAL    ='';    
    QORIG    ='CRF';
    if ^missing(SPRTDAT) then do;
        QNAM     ='SPRTDTC';
        QLABEL   =put(QNAM,DS_QL.);
        %jjqcdate2iso(in_date =SPRTDAT, in_time=, out_date=QVAL);
        output;
    end;
    if ^missing(DSPREDAT) then do;
        QNAM     ='DSPREDTC';
        QLABEL   =put(QNAM,DS_QL.);
        %jjqcdate2iso(in_date =DSPREDAT, in_time=, out_date=QVAL);
        output;
    end;
run;
*------------------- Output --------------------;
%qcoutput(in_data =SUPPDS_1 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );