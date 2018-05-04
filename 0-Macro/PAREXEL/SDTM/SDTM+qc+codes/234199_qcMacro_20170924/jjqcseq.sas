/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / MMY1006
  PXL Study Code:        228657

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         10Aug2016/ $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcseq.sas $

  Files Created:         jjqcseq.log

  Program Purpose:       To derive seq in domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%macro jjqcseq(in=&domain, out=qtrans.&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

proc sort data = &in out = &in;
    by &&&domain._keyvar_;
run;

data &out(Label = "&&&domain._dlabel_");
    retain &retainvar_;
    attrib &&&domain._varatt_;
    attrib %upcase(&domain.SEQ)  length = 8. Label = "Sequence Number";
    set &in;
    by &&&domain._keyvar_;
    if first.&idvar_ then &domain.SEQ = .;
    &domain.SEQ+1;
run;

%mend jjqcseq;
