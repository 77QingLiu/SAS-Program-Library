/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development, LLC / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Alex Ni
  Creation Date:         03Jun2016

  Program Location:      /projects/janss229288/stats/transfer/global
  Program Name:          autoexec.SAS

  Files Created:         None

  Program Purpose:       To direct SAS to open the project setup program                      

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:

Version/   | Programmer    |
Date       | Name          | Description of change
-------------------------------------------------------------------------------

-----------------------------------------------------------------------------*/

%LET _type=transfer;

*----------------------------------------------------------------------------*;
*--- Distinguish the different platforms (WINDOWS / UNIX)                 ---*;
*--- and apply the the setup.sas                                          ---*;
*----------------------------------------------------------------------------*;

%MACRO autoexec;
  %GLOBAL _projpre;
  %IF &SYSSCP=WIN %THEN %DO;
    %INCLUDE "/projects/janss229288/stats/transfer/global/setup_transfer.sas";
  %END;
  %IF &SYSSCP=HP IPF %THEN %DO;
    %INCLUDE "/projects/janss229288/stats/transfer/global/setup_transfer.sas";
  %END;
%MEND autoexec;
%autoexec;
