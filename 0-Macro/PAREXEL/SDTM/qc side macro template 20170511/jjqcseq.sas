/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 32765LYM1002
  PXL Study Code:        221316

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         11Nov2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjqcseq.log

  Program Purpose:       To derive seq in domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro jjqcseq(in=&domain, out=sdtmpri.&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

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
