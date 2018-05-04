/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         27Jun2016 / $LastChangedDate: 2016-08-24 04:46:14 -0400 (Wed, 24 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_rs.sas $

  Files Created:         qc_RS.log
                         RS.sas7bdat

  Program Purpose:       To QC Disease Response Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 25 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=RS;
%jjqcvaratt(domain=RS);
%jjqcdata_type;

*------------------- Read raw data --------------------;
data RS_ONC_001;
    set raw.RS_ONC_001(where=(&raw_sub));
    keep sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername 
         RSDAT_:  DISRESP_STD RSREASNE;
run;

*------------------- Mapping --------------------;
data RS_1;
    set RS_ONC_001;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    RSSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    RSCAT   = 'IMWG CRITERIA';
    %jjqcdate2iso(in_date =RSDAT, in_time=, out_date=RSDTC);
    RSTESTCD ='OVRLRESP';
    RSTEST   =put(RSTESTCD,$RS_TESTCD.);
    RSORRES  =strip(upcase(DISRESP_STD));
    RSSTRESC =RSORRES;
    RSEVAL ='INVESTIGATOR';
    if ^missing(RSORRES);
    call missing(of RSSEQ RSBLFL VISITNUM VISIT VISITDY EPOCH RSDY);
    drop RSSEQ RSBLFL VISITNUM VISIT VISITDY EPOCH RSDY;
run;

*------------------- Visit --------------------;
%jjqcvisit(in_data=RS_1, out_data=RS_2, date=, time=);

*------------------- DY --------------------;
%jjqccomdy(in_data=RS_2,out_data=RS_3, in_var=RSDTC, out_var=RSDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=RS_3,out_data=RS_4, in_date=RSDTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=RS_4,out_data=RS_5,DTC=RSDTC);

*------------------- RSSEQ --------------------;
%jjqcseq(in_data=RS_5, out_data=RS_6, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =RS_6 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

***********************************SUPPDS*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPRS;
%jjqcvaratt(domain=SUPPRS);

*------------------- Mapping --------------------;
data SUPPRS_1;
    set RS_6;
    attrib &&&domain._varatt_;
    where ^missing(RSREASNE);
    RDOMAIN  ="RS";
    IDVAR    ='RSSEQ';
    IDVARVAL =put(RSSEQ,best. -l);
    QEVAL    ='';    
    QORIG    ='CRF';
    QNAM     ='RSREASNE ';
    QLABEL   =put(QNAM,RS_QL.);
    QVAL=strip(upcase(RSREASNE ));
run;

*------------------- Output --------------------;
%qcoutput(in_data =SUPPRS_1 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );