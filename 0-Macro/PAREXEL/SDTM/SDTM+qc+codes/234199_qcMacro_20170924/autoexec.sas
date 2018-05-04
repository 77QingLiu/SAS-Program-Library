/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   PAREXEL / Macro and Application Development committee
  PAREXEL Study Code:    80386

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:                 $LastChangedBy: $
  Last Modified:         $LastChangedDate: $

  Program Location/Name: $HeadURL: $
  SVN Revision No:       $Rev: $

  Files Created:         None

  Program Purpose:       Standard autoexec.sas to direct SAS to open the
                         project specific setup program with
                         the appropriate parameters.
-----------------------------------------------------------------------------*/
%LET _type   = tabulate ;
%INCLUDE "/projects/janss234199/stats/global/setup.sas";
