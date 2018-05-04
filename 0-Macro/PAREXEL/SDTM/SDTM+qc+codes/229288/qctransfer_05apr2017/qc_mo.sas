/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         27Jun2016 / $LastChangedDate: 2016-08-29 03:51:21 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_mo.sas $

  Files Created:         qc_MO.log
                         MO.sas7bdat

  Program Purpose:       To QC Morphology Findings Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 39 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=MO;
%jjqcvaratt(domain=MO);
%jjqcdata_type;

*------------------- Read raw data --------------------;
data MO_GL_901;
    set raw.MO_GL_901(where=(&raw_sub));
    rename MOREASND=MOREASND_;
    keep sitenumber project subject INSTANCENAME DATAPAGENAME RECORDPOSITION PAGEREPEATNUMBER foldername MOREASND MODAT_: 
         MOPERF_STD INTP2_STD MOMETHOD1  MOCLSIG_STD;
run;

data MO_GL_902;
    set raw.MO_GL_902(where=(&raw_sub));
    rename MOREASND=MOREASND_ MOMETHOD=MOMETHOD_;
    keep sitenumber project subject INSTANCENAME DATAPAGENAME RECORDPOSITION PAGEREPEATNUMBER foldername MOPERF_ECMU_STD
         MOREASND MODAT_: MOMETHOD MOINTP_STD LVEF MOCLSIG_STD;
run;

*------------------- Mapping --------------------;
/* Form  Chest Radiological Assessment*/
data MO_1a;
    set MO_GL_901;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    MOSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    if MOPERF_STD = 'N' then do;
        MOTESTCD = 'MOALL';
        MOTEST   = put(MOTESTCD,$MO_TESTCD.);
        MOSTAT   = 'NOT DONE';
        MOREASND = MOREASND_;
        Output;
    end;
    %jjqcdate2iso(in_date =MODAT, in_time=, out_date=MODTC);
    if ^missing(INTP2_STD) then do;
        MOTESTCD  = 'INTP';
        MOTEST    = put(MOTESTCD,$MO_TESTCD.);
        MOORRES   = strip(upcase(INTP2_STD));
        MOORRESU  = '';
        MOSTRESC  = MOORRES;
        MOSTRESU  = '';
        MOLOC     = 'CHEST';
        MOMETHOD = upcase(MOMETHOD1);
        Output;
    end;
    call missing(of MOSEQ MOBLFL VISITNUM VISIT VISITDY EPOCH MODY MOSTRESN);
    drop MOSEQ MOBLFL VISITNUM VISIT VISITDY EPOCH MODY;
run;

/* Form Echocardiogram/MUGA Result s*/
data MO_1b;
    set MO_GL_902;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    MOSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    if MOPERF_ECMU_STD ne 'Y' and ^missing(MOPERF_ECMU_STD) then do;
        MOTESTCD = 'MOALL';
        MOTEST   = put(MOTESTCD,$MO_TESTCD.);
        MOSTAT   = 'NOT DONE';
        if MOPERF_ECMU_STD = 'N' then MOREASND = MOREASND_;
        else if MOPERF_ECMU_STD = 'NA' then MOREASND = 'NOT APPLICABLE';
        else if MOPERF_ECMU_STD = 'U' then MOREASND = 'UNKNOWN';
        Output;
    end;
    %jjqcdate2iso(in_date =MODAT, in_time=, out_date=MODTC);
    MOMETHOD = upcase(MOMETHOD_);
    if ^missing(LVEF) then do;
        MOTESTCD= 'LVEF';
        MOTEST   = put(MOTESTCD,$MO_TESTCD.);
        MOORRES = put(LVEF,best. -l);
        MOORRESU = '%';
        MOSTRESC  = MOORRES;
        MOSTRESN  = LVEF;
        MOSTRESU  = '%';
        Output;
    end;
    if ^missing(MOINTP_STD) then do;
        MOTESTCD= 'INTP';
        MOTEST   = put(MOTESTCD,$MO_TESTCD.);
        MOORRES = MOINTP_STD;
        MOORRESU = '';
        MOSTRESC  = MOORRES;
        MOSTRESU  = '';
        MOSTRESN  = .;
        Output;
    end;    
    call missing(of MOLOC MOSEQ MOBLFL VISITNUM VISIT VISITDY EPOCH MODY);
    drop MOLOC MOSEQ MOBLFL VISITNUM VISIT VISITDY EPOCH MODY;    
run;

/* Join All */
data MO_2;
    set MO_1a(in=a) MO_1b(in=b);
    source=a+10*b;
    if MOMETHOD = 'CHEST X-RAY' then MOMETHOD='XRAY';
run;
*------------------- Visit --------------------;
%jjqcvisit(in_data=MO_2, out_data=MO_3, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=MO_3,out_data=MO_4, in_var=MODTC, out_var=MODY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=MO_4,out_data=MO_5, in_date=MODTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=MO_5,out_data=MO_6,dtc=MODTC);

*------------------- MOSEQ --------------------;
%jjqcseq(in_data=MO_6, out_data=MO_7, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =MO_7 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

***********************************SUPPMO*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPMO;
%jjqcvaratt(domain=SUPPMO);

*------------------- Mapping --------------------;
data SUPPMO_1;
    set MO_7;
    attrib &&&domain._varatt_;
    RDOMAIN  ="MO";
    IDVAR    ='MOSEQ';
    IDVARVAL =put(MOSEQ,best. -l);
    QEVAL    ='';    
    QORIG    ='CRF';
    if MOTESTCD='INTP' and ^missing(MOCLSIG_STD) then do;
        QNAM     ='MOCLSIG ';
        QLABEL   =put(QNAM,MO_QL.);
        QVAL=strip(upcase(MOCLSIG_STD));
        Output;
    end;
run;

data a;
    set MO_7;
    if ^missing(MOCLSIG_STD) and MOTESTCD='INTP';
run;

*------------------- Output --------------------;
%qcoutput(in_data =SUPPMO_1 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );