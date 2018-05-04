/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   PAREXEL / Macro and Application Development committee
  PAREXEL Study Code:    80386

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 $LastChangedBy: xiaz $
  Last Modified:         $LastChangedDate: 2017-07-26 03:22:19 -0400 (Wed, 26 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/autoexec.sas $
  SVN Revision No:       $Rev: 3 $

  Files Created:         None

  Program Purpose:       Standard autoexec.sas to direct SAS to open the
                         project specific setup program with
                         the appropriate parameters.
-----------------------------------------------------------------------------*/
%LET _type   = tabulate ;
%INCLUDE "/projects/janss234199/stats/global/setup.sas";
