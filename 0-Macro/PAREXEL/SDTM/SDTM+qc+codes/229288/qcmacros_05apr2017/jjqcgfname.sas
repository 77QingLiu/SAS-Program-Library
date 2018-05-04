/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: liuc5 $
  Creation Date:         13Nov2014 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqcgfname.sas $

  Files Created:         jjqcgfname.log

  Program Purpose:       To get the latest Spec. name

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/

/*Get The Latest Spec. Name*/
%macro jjqcgfname(fname=mapping specifications, type=xlsx);
filename fname pipe "ls -t /projects/%lowcase(&_client.)&_tims/stats/transfer/data/rawspec/*.&type | grep -i '&fname'| head -1";

data _null_;
    infile fname;
    input;
    if not prxmatch("/\$/", _INFILE_);
    _INFILE_=prxchange("s/(.+)\/(.+)(\.&type)/\2/", -1, _INFILE_);
    call symputx("fname", _INFILE_, "g");
run;

/* Close the pipe */
filename fname clear;

%mend jjqcgfname;