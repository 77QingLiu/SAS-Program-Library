/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.3
  Operating System:      UNIX

-------------------------------------------------------------------------------

  Author:                Julius Kusserow / $LastChangedBy: $
  Creation Date:         05AUG2014       / $LastChangedDate: $

  Program Location/Name: $HeadURL: $

  Files Created:         None

  Program Purpose:       Standard autoexec.sas to direct SAS to open the
                         project specific setup program with
                         the appropriate paramters.

  Macro Parameters       NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/
%LET _type   = dmc ;
%INCLUDE "/projects/<area>/stats/global/setup.sas";
