/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development, LLC / VAC89220HPX2004
  PXL Study Code:        227542

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Jasmine Zhang
  Creation Date:         18Jan2015

  Program Location:      /projects/janss227542/stats/transfer/global
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
    %INCLUDE "/project29/janss228775/stats/transfer/global/setup_transfer.sas";
  %END;
  %IF &SYSSCP=HP IPF %THEN %DO;
    %INCLUDE "/project29/janss228775/stats/transfer/global/setup_transfer.sas";
  %END;
%MEND autoexec;
%autoexec;
