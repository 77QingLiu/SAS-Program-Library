/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         27Jun2016 / $LastChangedDate: 2016-11-21 01:02:40 -0500 (Mon, 21 Nov 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_fa.sas $

  Files Created:         qc_FA.log
                         FA.sas7bdat

  Program Purpose:       To QC Findings About Events or Interventions Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 72 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=FA;
%jjqcvaratt(domain=FA);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier site sitegroup instanceid 
             instancerepeatnumber folderid targetdays datapageid recorddate recordid 
             mincreated maxupdated savets coder_hierarchy ;

data FA_ONC_002;
    set raw.FA_ONC_002(where=(&raw_sub));
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername OCCUR_ONC02_STD REAS_STD
         REASO ;
run;

data FA_ONC_003;
    set raw.FA_ONC_003(where=(&raw_sub));
    rename FACAT = FACAT_ FAMETHOD = FAMETHOD_ FAOBJ =FAOBJ_;
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername FACAT FAMETHOD FAOBJ CANSTG_STD FAGRPID_STD DIAGDTC: ;
run;

proc sql;
    create table CM_ONC_001 as /* Remove repeated logline */
    select sitenumber,project,subject,INSTANCENAME,DATAPAGENAME,PAGEREPEATNUMBER,RECORDPOSITION,foldername,
           CMGRPID_LT,BSTRSP_STD,METREQ_STD,NORESP_STD,PROGRES_STD
            ,case when RECORDPOSITION=min(RECORDPOSITION) then 1 else . end as unique_flag 
    from  raw.CM_ONC_001(where=(&raw_sub))
    group by SITENUMBER,SUBJECT,INSTANCENAME,DATAPAGENAME
    having unique_flag=1;
quit;

data CE_ONC_003;
    set raw.CE_ONC_003(where=(&raw_sub));
    drop &dropvar;
run;

data CM_ONC_003;
    set raw.CM_ONC_003(where=(&raw_sub));
    drop &dropvar;
run;

*------------------- Mapping --------------------;
/* Form Cycle Delay*/
data FA_1a;
    set FA_ONC_002;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    FASPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),  put(RECORDPOSITION,best.));
    FACAT   = 'CYCLE DELAY';
    if ^missing(OCCUR_ONC02_STD) then do;
        FATESTCD = 'OCCUR';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = 'DAY1 CYCLE DELAY';
        FAORRES  = OCCUR_ONC02_STD;
        FASTRESC = FAORRES;
        Output;
    end;
    if ^missing(REAS_STD) then do;
        FATESTCD = 'REAS';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = 'WHAT WAS THE REASON THE CYCLE WAS DELAYED?';
        FAORRES  = ifc(REAS_STD='OTHER',strip(upcase(REASO)),REAS_STD);
        FASTRESC = ifc(REAS_STD='OTHER',"OTHER",FAORRES);
        Output;        
    end;
    call missing(of FAGRPID FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY FAMETHOD);
    drop FAGRPID FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY;
run;

/* Form: Diagnosis Form - Additional Information*/
data FA_1e;
    set FA_ONC_003;
    attrib &&&domain._varatt_;
    STUDYID  =strip(PROJECT);
    DOMAIN   ="&domain";
    USUBJID  =catx("-",PROJECT,SUBJECT);
    FASPID   =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),  put(RECORDPOSITION,best.));
    FACAT    = FACAT_;
    FAMETHOD = FAMETHOD_;
    FAOBJ    = FAOBJ_;
    %jjqcdate2iso(in_date =DIAGDTC, in_time=, out_date=DIAGDTC_);

    if ^missing(CANSTG_STD) then do;
        FATESTCD = 'CANSTG';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAORRES  = CANSTG_STD;
        FASTRESC = FAORRES;
        Output;
    end;
    if ^missing(FAGRPID_STD) then do;
        FATESTCD = 'TRTREC';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAORRES  = FAGRPID_STD;
        FASTRESC = FAORRES;
        Output;        
    end;
    if ^missing(DIAGDTC) then do;
        FATESTCD = 'DIAGDTC';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAORRES  = DIAGDTC_;
        FASTRESC = FAORRES;
        Output;        
    end;    
    call missing(of FAGRPID FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY);
    drop FAGRPID FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY;
run;

/* Form Prior Systemic Therapy */
data FA_1b;
    set CM_ONC_001;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    FASPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),  put(RECORDPOSITION,best.));
    FACAT   = 'PRIOR SYSTEMIC THERAPY';
    FAGRPID = put(CMGRPID_LT,best. -l);
    if ^missing(BSTRSP_STD) then do;
        FATESTCD = 'BESTRESP';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = 'REGIMEN';
        FAORRES  = BSTRSP_STD;
        FASTRESC = FAORRES;
        Output;    
    end;
    if ^missing(METREQ_STD) then do;
        FATESTCD = 'METREQ';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = 'REFRACTORY';
        FAORRES  = METREQ_STD;
        FASTRESC = FAORRES;
        Output;    
    end;    
    if ^missing(NORESP_STD) then do;
        FATESTCD = 'OCCUR';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = 'NON-RESPONSIVE WHILE ON THERAPY';
        FAORRES  = NORESP_STD;
        FASTRESC = FAORRES;
        Output;    
    end;   
    if ^missing(PROGRES_STD) then do;
        FATESTCD = 'OCCUR';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = 'DISEASE PROGRESSES WITHIN 60 DAYS OF THERAPY';
        FAORRES  = PROGRES_STD;
        FASTRESC = FAORRES;
        Output;    
    end;    
    call missing(of FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY FAMETHOD);
    drop FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY;
run;

/* Form  Disease Progression*/
%let OBJ =%nrbquote(>= 25% increase in the level of serum monoclonal paraprotein, which must also be an absolute increase of at least 5 g/L (500 mg/dL) and confirmed on a repeat investigation|
>=25% increase in 24-hour urine monoclonal paraprotein, which must also be an absolute increase of at least 200 mg/24 h and confirmed on a repeat investigation|
>= 25% increase in plasma cells in a bone marrow aspirate or on trephine biopsy, which must also be an absolute increase of at least 10%|
Definite increase in the size of existing lytic bone lesions|
Definite increase in the size of existing soft tissue plasmacytomas|
Development of new bone lesions (not including compression fracture)|
Development of new soft tissue plasmacytomas|
Development of hypercalcemia (corrected serum calcium > 11.5 mg/dL or 2.8 mmol/L) that can be attributed solely to the plasma cell proliferative disorder|
Difference of >= 25% increase between involved and uninvolved FLC levels, absolute increase must be > 10 mg/dL (Only in patients without measurable serum and urine M-protein levels at baseline));

%macro obj;
    %let i =1;
    %do %while(%qscan(&obj,&i,|) ne );
        %global obj&i;
        %let obj&i=%scan(&obj,&i,|);
        %put &&obj&i;
        %let i=%eval(&i+1);
    %end;
%mend;
%obj;
%macro FA(where=,FATESTCD=,FAOBJ=,FAORRES=,FASTRESC=);
    if &where then do;
        FATESTCD = "&FATESTCD";
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = upcase("&FAOBJ");
        FAORRES  = ifc(&FAORRES=1,'Y','N');
        FASTRESC = FAORRES;
        Output;
    end;   
%mend FA;

data FA_1c;
    set CE_ONC_003;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    FASPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),  put(RECORDPOSITION,best.));
    FACAT   = CETERM;
    %FA(where =%str(^missing(OCCUR_MMY09)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ1),FAORRES =OCCUR_MMY09,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY10)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ2),FAORRES =OCCUR_MMY10,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY11)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ3),FAORRES =OCCUR_MMY11,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY12)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ4),FAORRES =OCCUR_MMY12,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY13)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ5),FAORRES =OCCUR_MMY13,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY14)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ6),FAORRES =OCCUR_MMY14,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY15)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ7),FAORRES =OCCUR_MMY15,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY16)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ8),FAORRES =OCCUR_MMY16,FASTRESC=);
    %FA(where =%str(^missing(OCCUR_MMY17)),FATESTCD=OCCUR,FAOBJ =%nrbquote(&OBJ9),FAORRES =OCCUR_MMY17,FASTRESC=);   
    call missing(of FAGRPID FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY FAMETHOD);
    drop FAGRPID FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY;
run;

/* Form  Subsequent Systemic Therapy*/
data FA_1d;
    set CM_ONC_003;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    FASPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),  put(RECORDPOSITION,best.));
    FACAT   = 'SUBSEQUENT SYSTEMIC THERAPY';
    FAGRPID = put(CMGRPID_LT,best. -l);
    if ^missing(BSTRSP) then do;
        FATESTCD = 'BESTRESP';
        FATEST   = put(FATESTCD,$FA_TESTCD.);
        FAOBJ    = 'REGIMEN';
        FAORRES  = BSTRSP_STD;
        FASTRESC = FAORRES;
    end;        
    call missing(of FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY FAMETHOD);
    drop FADTC FASEQ FABLFL VISITNUM VISIT VISITDY EPOCH FADY;
run;

/* Join All */
data FA_2;
    set FA_1a FA_1b FA_1c FA_1d FA_1e;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=FA_2, out_data=FA_3, date=FADTC, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=FA_3,out_data=FA_4, in_var=FADTC, out_var=FADY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=FA_4,out_data=FA_5, in_date=FADTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=FA_5,out_data=FA_6,DTC=FADTC);

*------------------- FASEQ --------------------;
%jjqcseq(in_data=FA_6, out_data=FA_7, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =FA_7 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
