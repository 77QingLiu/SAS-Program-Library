/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         04Jul2016 / $LastChangedDate: 2016-11-21 01:02:25 -0500 (Mon, 21 Nov 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_xc.sas $

  Files Created:         qc_XC.log
                         XC.sas7bdat

  Program Purpose:       To QC Cytogenetics Findings Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 71 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=XC;
%jjqcvaratt(domain=XC);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier site sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
data XC_ONC_001;
    set raw.XC_ONC_001(where=(&raw_sub));
    drop &dropvar XCSPEC;
    rename XCMETHOD=XCMETHOD_;
run;

data XC_ONC_002;
    set raw.XC_ONC_002(where=(&raw_sub));
    drop &dropvar XCSPEC;
    rename XCMETHOD=XCMETHOD_;
run;

*------------------- Mapping --------------------;
/* Form  Bone Marrow Cytogenetics (Local) - Karyotype*/
data XC_1a;
    set XC_ONC_001;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    XCSPID  = catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    XCCAT   = 'CYTOGENETICS';
    XCSPEC  = XCSPEC_STD;
    %jjqcdate2iso(in_date =XCDAT, in_time=, out_date=XCDTC);
    XCMETHOD = XCMETHOD_;
    if XCPERF_STD = 'N' then do;
        XCTESTCD = 'CYTABNRM';
        XCTEST   = put(XCTESTCD,$XC_TESTCD.);
        XCORRES  = '';
        XCSTAT   = 'NOT DONE';
        output;
    end;        
    if CYTABNRM_STD = 'N' then do;
        XCTESTCD = 'CYTABNRM';
        XCTEST   = put(XCTESTCD,$XC_TESTCD.);
        XCORRES  = 'NORMAL';
        XCSTRESC  = 'NORMAL';
        output;
    end;
    do i = 1 to 6;
        XCTESTCD = 'CYTABNRM';
        XCTEST   = put(XCTESTCD,$XC_TESTCD.);
        if i=1  then do; if CYTABN1 = 1  then XCORRES = 'HYPOPLOIDY';else XCORRES='';end;
        if i=2  then do; if CYTABN2 = 1  then XCORRES = 'HYPERPLOIDY';else XCORRES='';end;
        if i=3  then do; if CYTABN3 = 1  then XCORRES = 'T(4;14)';else XCORRES='';end;
        if i=4  then do; if CYTABN10 = 1 then XCORRES = 'DEL(17P)';else XCORRES='';end;
        if i=5  then do; if CYTABN11 = 1 then XCORRES = 'DEL(13Q)';else XCORRES='';end;
        if i =6 then do; if ^missing(CYTABNO) then XCORRES = upcase(strip(CYTABNO));else XCORRES='';end;

        if i = 6 then XCSTRESC = 'OTHER';
        else XCSTRESC = XCORRES;

        call missing(of XCSTAT);
        if ^missing(XCORRES) then output;
    end;
    call missing(of XCNAM XCSEQ XCBLFL VISITNUM VISIT VISITDY EPOCH XCDY);
    drop XCSEQ XCBLFL VISITNUM VISIT VISITDY EPOCH XCDY;
run;

/* Form: Bone Marrow Cytogenetics (Local) - Karyotype*/
data XC_1b;
    set XC_ONC_002;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    XCSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    XCCAT   = 'CYTOGENETICS';
    XCSPEC  = XCSPEC_STD;
    %jjqcdate2iso(in_date =XCDAT, in_time=, out_date=XCDTC);
    XCMETHOD = XCMETHOD_;
    if XCPERF_STD = 'N' then do;
        XCTESTCD = 'CYTABNRM';
        XCTEST   = put(XCTESTCD,$XC_TESTCD.);
        XCORRES  = '';
        XCSTAT   = 'NOT DONE';
        output;
    end;        
    if CYTABNRM_STD = 'N' and upcase(XCPERF) ='YES' then do;
        XCTESTCD = 'CYTABNRM';
        XCTEST   = put(XCTESTCD,$XC_TESTCD.);
        XCORRES  = 'NORMAL';
        XCSTRESC  = 'NORMAL';
        output;
    end;
    do i = 1 to 10;
        XCTESTCD = 'CYTABNRM';
        XCTEST   = put(XCTESTCD,$XC_TESTCD.);
        if i=1  then do; if CYTABN1 = 1 then XCORRES='HYPOPLOIDY';else XCORRES=''; end;
        if i=2  then do; if CYTABN2 = 1 then XCORRES='HYPERPLOIDY';else XCORRES=''; end;
        if i=3  then do; if CYTABN3 = 1 then XCORRES='T(4;14)';else XCORRES=''; end;
        if i=4  then do; if CYTABN4 = 1 then XCORRES='T(14;16)';else XCORRES=''; end;
        if i=5  then do; if CYTABN5 = 1 then XCORRES='T(14;20)';else XCORRES=''; end;
        if i=6  then do; if CYTABN6 = 1 then XCORRES='MYC TRANSLOCATION';else XCORRES=''; end;
        if i=7  then do; if CYTABN7 = 1 then XCORRES='DEL(17P13)';else XCORRES=''; end;
        if i=8  then do; if CYTABN8 = 1 then XCORRES='DEL(13Q14)';else XCORRES=''; end;
        if i=9  then do; if CYTABN9 = 1 then XCORRES='AMP(1Q21)';else XCORRES=''; end;
        if i =10 then XCORRES = upcase(strip(CYTABNO));

        if i = 10 then XCSTRESC = 'OTHER';
        else XCSTRESC = XCORRES;

        call missing(of XCSTAT);
        if ^missing(XCORRES) then output;
    end;
    call missing(of XCNAM XCSEQ XCBLFL VISITNUM VISIT VISITDY EPOCH XCDY);
    drop XCSEQ XCBLFL VISITNUM VISIT VISITDY EPOCH XCDY;
run;

data XC_2;
    set XC_1a XC_1b;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=XC_2, out_data=XC_3, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=XC_3,out_data=XC_4, in_var=XCDTC, out_var=XCDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=XC_4,out_data=XC_5, in_date=XCDTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=XC_5,out_data=XC_6,dtc=XCDTC);

*------------------- XCSEQ --------------------;
%jjqcseq(in_data=XC_6, out_data=XC_7, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =XC_7 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
