/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocpl No: Janssen Research & Development / 26866138MMY3037
  PXL Study code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         28Jun2016 / $LastChangedDate: 2016-08-25 05:09:30 -0400 (Thu, 25 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_da.sas $

  Files Created:         qc_DA.log
                         DA.sas7bdat

  Program Purpose:       To QC Drug Accountability Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 28 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=DA;
%jjqcvaratt(domain=DA);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets;
data DA_GL_900C; /* Form: Drug Preparation - Subcutaneous Injection */
    set raw.DA_GL_900C(where=(&raw_sub));
    rename VISIT = VISIT_;
    drop &dropvar;
run;

*------------------- Mapping --------------------;
/* Form: DAmments */
data DA_1;
    set DA_GL_900C;
    attrib &&&domain._varatt_;
    STUDYID = strip(PROJECT);
    DOMAIN  = "&domain";
    USUBJID = catx("-",PROJECT,SUBJECT);
    DASPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));    
    DACAT='TREATMENT';
    DATESTCD = 'DISPAMT';
    DATEST = put(DATESTCD,$DA_TESTCD.);
    DAREFID = strip(upcase(DAREFID_ATL));
    call missing(of DASEQ DAORRES DASTRESC VISITNUM VISIT VISITDY EPOCH DADTC DADY);
    drop DASEQ VISITNUM VISIT VISITDY;
run;

proc sql;
    create table DA_2 as 
    select a.*, b.VISIT, b.VISITDY, b.VISITNUM
    from DA_1 as a left join qtrans.sv as b
    on a.SUBJECT=b.SUBJECT and a.VISIT_=upcase(b.foldername);
quit;


*------------------- DASEQ --------------------;
%jjqcseq(in_data=DA_2, out_data=DA_3, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =DA_3 );

*------------------- DAmpare --------------------;
%Gmcompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );


