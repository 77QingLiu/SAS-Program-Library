/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   <client> / <protocol>
  PXL Study Code:        <TIME code>

  SAS Version:           9.3
  Operating System:      UNIX

-------------------------------------------------------------------------------

  Author:                <author> $LastChangedBy: $
  Creation Date:         <date in DDMMMYYYY format> / $LastChangedDate: $

  Program Location/Name: $HeadURL: $

  Files Created:         pinnacle21_validation_report_library_<timestamp>.xlsx

  Program Purpose:       To perform Pinnacle21 checks for the dataset library.

  Macro Parameters:      NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/

* Run Pinnacle21 for the Transfer library;
%gmExecutePinnacle21( libsIn  = transfer
                    , pathOut = &_global.
                    );