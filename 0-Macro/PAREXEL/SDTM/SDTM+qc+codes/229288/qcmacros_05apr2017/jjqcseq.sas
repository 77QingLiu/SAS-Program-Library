/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 32765LYM1002
  PXL Study Code:        221316

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: liuc5 $
  Creation Date:         11Nov2014 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqcseq.sas $

  Files Created:         jjqcseq.log

  Program Purpose:       To derive seq in domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/

%macro jjqcseq(in_data=&domain, out_data=, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

proc sort data = &in_data out = &in_data;
    by &&&domain._keyvar_;
run;

data &out_data(Label = "&&&domain._dlabel_");
    retain &retainvar_;
    attrib &&&domain._varatt_;
    attrib %upcase(&domain.SEQ) length = 8. Label = "Sequence Number";
    set &in_data;
    by &&&domain._keyvar_;
    if first.&idvar_ then &domain.SEQ = .;
    &domain.SEQ+1;
run;

%mend jjqcseq;
