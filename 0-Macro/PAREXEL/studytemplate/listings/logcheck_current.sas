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

  Files Created:         gmLogScanReport_userId.pdf
                         logcheck_current.log

  Program Purpose:       To check all logs in the current multirun file.

  Macro Parameters:      NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/

* Scan the current multirun;
%gmLogScanReport(selectScan = multirun,
                 fileOut    = user,
                 sendEmail  = 1
                );
