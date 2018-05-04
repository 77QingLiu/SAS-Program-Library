/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Elaine Wu $LastChangedBy: lup $
  Creation Date:         05Jul2016 / $LastChangedDate: 2016-07-14 04:46:29 -0400 (Thu, 14 Jul 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_qs.sas $

  Files Created:         qc_QS.log
						 qc_QS.txt
                         QS.sas7bdat

  Program Purpose:       To QC Questionnaire Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 13 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=QS;
%jjqcvaratt(domain=QS);
%jjqcdata_type;

*------------------- Read raw data --------------------;
data &domain.;
	set raw.ECOG01_QS_001(drop=studyid rename=(QSCAT=QSCAT_ QSEVAL=QSEVAL_)  where=(&raw_sub));
	attrib &&&domain._varatt_;
	if ^missing(QSCAT_) then do;
		STUDYID=strip(PROJECT);
		DOMAIN="QS";
		USUBJID=catx('-', PROJECT, SUBJECT);
		QSSEQ=.;
		QSSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
                    put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
		QSTESTCD="ECOG101";
		QSTEST="ECOG1-Performance Status";
		QSCAT="ECOG";
		QSORRES="";
		QSSTRESC=strip(ECOG101);
		QSSTRESN=input(ECOG101,best.);
		QSBLFL="";
		QSEVAL="INVESTIGATOR";
		VISITNUM=.;
		VISIT="";
		VISITDY=.;
		EPOCH="";
		QSDTC="";
		QSDY=.;
		output;
	end;

	drop QSSEQ VISITNUM VISIT VISITDY EPOCH QSDTC QSDY;

run;
*------------------- Visit --------------------;
%jjqcvisit(in_data=&domain., out_data=&domain.1, date=&domain.DTC, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=&domain.1,out_data=&domain.2, in_var=&domain.DTC, out_var=&domain.DY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=&domain.2,out_data=&domain.3, in_date=&domain.DTC);

*------------------- QSSEQ --------------------;
%jjqcseq(in_data=&domain.3, out_data=&domain.4, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =&domain.4 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
