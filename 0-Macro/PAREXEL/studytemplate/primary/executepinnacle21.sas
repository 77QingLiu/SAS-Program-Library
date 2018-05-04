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

  Files Created:         pinnacle21_&_type..xlsx

  Program Purpose:       To perform Pinnacle21 checks for the dataset library.

  Macro Parameters:      NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/

* Run Pinnacle21 for the Analysis library;
%gmExecutePinnacle21( libsIn  = analysis
                    , pathOut = &_global.
                    , fileOut = projArea
                    , excludePattern = ^formats$
                    );