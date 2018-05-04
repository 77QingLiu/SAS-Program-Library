/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         27Jun2016 / $LastChangedDate: 2017-01-22 07:36:40 -0500 (Sun, 22 Jan 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_mh.sas $

  Files Created:         qc_MH.log
                         MH.sas7bdat

  Program Purpose:       To QC Medical History Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 116 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=MH;
%jjqcvaratt(domain=MH);
%jjqcdata_type;

*------------------- Read raw data --------------------;
data MH_GL_900;
    set raw.MH_GL_900(where=(&raw_sub));
    if ^missing(MHTERM);
    rename MHTERM = MHTERM_ MHCAT=MHCAT_ MHSCAT=MHSCAT_ MHTOXGR=MHTOXGR_;
    keep sitenumber project subject INSTANCENAME DATAPAGENAME RECORDPOSITION foldername  PAGEREPEATNUMBER
         MHTERM MHTERM_PT MHTERM_SOC  MHCAT MHSCAT MHTOXGR MHONGO_STD ;
run;             
*------------------- Mapping --------------------;
data MH_1;
    set MH_GL_900;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    MHSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    MHTERM  =compbl(strip(upcase(MHTERM_)));
    MHCAT   ='GENERAL';
    MHSCAT  =strip(upcase(MHSCAT_));
    MHTOXGR =strip(upcase(MHTOXGR_));
    MHDECOD = upcase(MHTERM_PT);
    MHBODSYS = upcase(MHTERM_SOC);
    if MHONGO_STD='Y' then MHENRTPT='ONGOING';
    else if MHONGO_STD='N' then MHENRTPT='BEFORE';
    MHENTPT ='DATE OF HISTORY COLLECTION DATE';

    call missing(of MHSEQ VISITNUM VISIT VISITDY EPOCH MHDTC MHDY);
    drop MHSEQ VISITNUM VISIT VISITDY EPOCH MHDTC MHDY;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=MH_1, out_data=MH_2, date=MHDTC, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=MH_2,out_data=MH_3, in_var=MHDTC, out_var=MHDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=MH_3,out_data=MH_4, in_date=MHDTC);

*------------------- MHSEQ --------------------;
%jjqcseq(in_data=MH_4, out_data=MH_5, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =MH_5 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
