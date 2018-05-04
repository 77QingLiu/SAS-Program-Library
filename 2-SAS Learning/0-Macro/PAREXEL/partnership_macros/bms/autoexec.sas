/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BRISTOL-MYERS SQUIBB COMPANY / CA209-025
  PXL Study Code:        211241

  SAS Version:           9.2
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                
  Creation Date:         15FEB2014

  Program Location:      /projects/bms211241/stats/primary/prog/analysis
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

%LET _type=primary;

*----------------------------------------------------------------------------*;
*--- Distinguish the different platforms (WINDOWS / UNIX)                 ---*;
*--- and apply the the setup.sas                                          ---*;
*----------------------------------------------------------------------------*;

%MACRO autoexec;
  %GLOBAL _projpre;
  %IF &SYSSCP=WIN %THEN %DO;
    %INCLUDE "\\Mst2\bms211241\stats\global\setup.sas";
  %END;
  %IF &SYSSCP=HP IPF %THEN %DO;
    %INCLUDE "/projects/bms211241/stats/global/setup.sas";
  %END;
%MEND autoexec;
%autoexec;
