/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         13Nov2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjqcgfname.log

  Program Purpose:       To get the latest Spec. name

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
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