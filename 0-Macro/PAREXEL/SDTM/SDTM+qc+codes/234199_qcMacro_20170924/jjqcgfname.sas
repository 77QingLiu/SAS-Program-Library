/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Last Modified:     2017-06-05    $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcgfname.sas $

  Files Created:         jjqcgfname.log

  Program Purpose:       To get the latest Spec. name

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

/*Get The Latest Spec. Name*/
%macro jjqcgfname(fname=Mapping Specification, type=xlsx);
filename fname pipe "ls -t /projects/%lowcase(&_client.)&_tims/stats/tabulate/data/rawspec/*.&type | grep -i '&fname'| head -1";

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