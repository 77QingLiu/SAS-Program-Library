/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         28Jun2016 / $LastChangedDate: 2016-07-17 08:57:45 -0400 (Sun, 17 Jul 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_ce.sas $

  Files Created:         qc_CE.log
                         CE.sas7bdat

  Program Purpose:       To QC Clinical Elements Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 14 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=CE;
%jjqcvaratt(domain=CE);
%jjqcdata_type;

*------------------- Read raw data --------------------;

data CM_ONC_001_;
    set raw.CM_ONC_001(where=(&raw_sub));
    if ^missing(CETERM);
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername CMGRPID_LT CMCAT CEOCCUR_STD CESTDAT_:;
run;
proc sql;
    create table CM_ONC_001 as select * from CM_ONC_001_ group by subject,INSTANCENAME,foldername having RECORDPOSITION=min(RECORDPOSITION);
quit;

data CE_ONC_003;
    set raw.CE_ONC_003(where=(&raw_sub));
    if ^missing(CETERM);
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername CESTDAT_:  CECNFDTC:;
run;    

data CM_ONC_003_;
    set raw.CM_ONC_003(where=(&raw_sub));
    if ^missing(CETERM);
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername CMGRPID_LT CMCAT CEOCCUR_STD CESTDAT_: ;
run;
proc sql;
    create table CM_ONC_003 as select * from CM_ONC_003_ group by subject,INSTANCENAME,foldername having RECORDPOSITION=min(RECORDPOSITION);
quit;
*------------------- Mapping --------------------;
/* Form Prior Systemic Therapy*/
data CE_1a;
    set CM_ONC_001;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);    
    CESPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    CEGRPID =strip(upcase(put(CMGRPID_LT,best. -l)));
    CETERM  ='PROGRESSION/RELAPSE';
    CECAT   =strip(upcase(CMCAT));
    CEPRESP ='Y';
    CEOCCUR = CEOCCUR_STD;
    %jjqcdate2iso(in_date =CESTDAT, in_time=, out_date=CESTDTC);
    call missing(of CESEQ visitnum visitdy visit Epoch cestdy);
    drop CESEQ visitnum visitdy visit Epoch cestdy;
run;

/* Form: Disease Progression*/
data CE_1b;
    set CE_ONC_003;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);    
    CESPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    CEGRPID ='';
    CETERM  ='DISEASE PROGRESSION';
    CECAT   ='DISEASE PROGRESSION';
    CEPRESP ='';
    CEOCCUR = '';
    %jjqcdate2iso(in_date =CESTDAT, in_time=, out_date=CESTDTC);
    call missing(of CESEQ visitnum visitdy visit Epoch cestdy);
    drop CESEQ visitnum visitdy visit Epoch cestdy;    
run;

/* Form: Subsequent Systemic Therapy*/
data CE_1c;
    set CM_ONC_003;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);    
    CESPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    CEGRPID =strip(upcase(put(CMGRPID_LT,best. -l)));
    CETERM  = "PROGRESSION/RELAPSE";
    CECAT   =strip(upcase(CMCAT));
    CEPRESP ='Y';
    CEOCCUR = CEOCCUR_STD;
    %jjqcdate2iso(in_date =CESTDAT, in_time=, out_date=CESTDTC);
    call missing(of CESEQ visitnum visitdy visit Epoch cestdy);
    drop CESEQ visitnum visitdy visit Epoch cestdy;        
run;

/* Join all */
data CE_2;
    set CE_1a CE_1b CE_1c;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=CE_2, out_data=CE_3, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=CE_3,out_data=CE_4, in_var=CESTDTC, out_var=CESTDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=CE_4,out_data=CE_5, in_date=CESTDTC);

*------------------- CESEQ --------------------;
%jjqcseq(in_data=CE_5, out_data=CE_6, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =CE_6 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

***********************************SUPPCE*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPCE;
%jjqcvaratt(domain=SUPPCE);

*------------------- Mapping --------------------;
data SUPPCE_1;
    set CE_6;
    attrib &&&domain._varatt_;
    where ^missing(CECNFDTC);
    RDOMAIN  ="CE";
    IDVAR    ='CESEQ';
    IDVARVAL =put(CESEQ,best. -l);
    QNAM     ='CECNFDTC';
    QLABEL   =put(QNAM,CE_QL.);
    QORIG    ='CRF';
    QEVAL    ='';    
    %jjqcdate2iso(in_date =CECNFDTC, in_time=, out_date=QVAL);
run;

*------------------- Output --------------------;
%qcoutput(in_data =SUPPCE_1 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );