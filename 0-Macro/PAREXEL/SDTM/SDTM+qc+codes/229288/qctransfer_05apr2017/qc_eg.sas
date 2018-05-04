/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Elaine Wu $LastChangedBy: liuc5 $
  Creation Date:         05Jul2016 / $LastChangedDate: 2016-08-25 05:09:30 -0400 (Thu, 25 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_eg.sas $

  Files Created:         qc_EG.log
                                                 qc_EG.txt
                         EG.sas7bdat
                                                 SUPPEG.sas7bdat

  Program Purpose:       To QC ECG Test Results Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 28 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=EG;
%jjqcvaratt(domain=EG);
%jjqcdata_type;

/* Remove the duplicated record when they have more than one logline */
%macro rmv_logline(indata=, outdata=);
proc sort data = raw.&indata. out = outdata1;
    by SITENUMBER SUBJECT DATAPAGENAME INSTANCENAME RECORDPOSITION;
run;

proc sort nodupkey data = outdata1 out = &outdata.;
    by SITENUMBER SUBJECT DATAPAGENAME INSTANCENAME;
run;
%mend;

%rmv_logline(indata=EG_GL_900,outdata=EG_GL_900_);

*------------------- Create domain --------------------;
data &domain.;
        set EG_GL_900_(drop=studyid where=(&raw_sub));
        attrib &&&domain._varatt_;
        format _all_; informat _all_;
        STUDYID=strip(PROJECT);
        DOMAIN   ="EG";
        USUBJID  =catx('-', PROJECT, SUBJECT);
        EGSEQ    =.;
        EGSPID   =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
        EGBLFL   ="";
        VISITNUM =.;
        VISIT    ="";
        VISITDY  =.;
        EPOCH    ="";
        %jjqcdate2iso(in_date =EGDAT, in_time=, out_date=EGDTC);
        EGDY     =.;
        if strip(EGPERF)="No" then do;
                EGTESTCD ="INTP";
                EGTEST   =put(&domain.TESTCD, $&domain._TESTCD.);
                EGORRES  =strip(INTP_STD);
                EGSTRESC ="";
                EGSTAT   ="NOT DONE";
                output;
        end;

        if strip(EGPERF)="Yes" then do;
                EGTESTCD ="INTP";
                EGTEST   =put(&domain.TESTCD, $&domain._TESTCD.);
                EGORRES  =strip(INTP_STD);
                EGSTRESC =EGORRES;
                EGSTAT   ="";
                output;
        end;

        drop EGSEQ EGBLFL VISITNUM VISIT VISITDY EPOCH EGDY;

run;
*------------------- Visit --------------------;
%jjqcvisit(in_data=&domain., out_data=&domain.1, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=&domain.1,out_data=&domain.2, in_var=&domain.DTC, out_var=&domain.DY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=&domain.2,out_data=&domain.3, in_date=&domain.DTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=&domain.3,out_data=&domain.4,dtc=EGDTC);

*------------------- QSSEQ --------------------;
%jjqcseq(in_data=&domain.4, out_data=&domain.5, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =&domain.5 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

***********************************SUPPEG*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPEG;
%jjqcvaratt(domain=SUPPEG);

*------------------- Mapping --------------------;
data &domain.;
    set EG5;
    attrib &&&domain._varatt_;
        format _all_; informat _all_;
    RDOMAIN  ="EG";
    IDVAR    ="EGSEQ";
    IDVARVAL =strip(put(EGSEQ,best.));
    QEVAL    ='';
    QORIG    ='CRF';
    if ^missing(EGCLSIG) then do;
        QNAM   ="EGCLSIG";
        QLABEL =put(QNAM,EG_QL.);
        QVAL   =strip(upcase(EGCLSIG_STD));
        Output;
    end;
run;


*------------------- Output --------------------;
%qcoutput(in_data =&domain. );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
