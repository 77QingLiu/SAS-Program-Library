/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275SLE2001
  PXL Study Code:        221689

  SAS Version:           9.3
  Operating System:      UNIX
  ---------------------------------------------------------------------------------------

  Author:                Ran Liu $LastChangedBy: liuc5 $
  Creation Date:         07Sep2015 / $LastChangedDate: 2016-08-29 03:53:10 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/qcids.sas $

  Files Created:         sdtm_ids.log

  Program Purpose:       To create the STUDYID, DOMAIN, USUBJID, -SPID.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 40 $
-----------------------------------------------------------------------------*/
%macro qcids;
    length studyid $40 domain $2 usubjid $70 &domain.spid $200;
    studyid = strip(project);
    domain  = upcase("&domain");
    usubjid = catx("-",studyid,subject);
    &domain.spid   = "RAVE-"||strip(upcase(instancename))||"-"||strip(upcase(datapagename))||"-"||strip(put(recordposition,best.));

%mend qcids;
