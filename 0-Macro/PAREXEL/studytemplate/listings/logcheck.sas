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

  Files Created:         gmLogScanReport_&_type..pdf
                         qc_gmLogScanReport_&_type..pdf

  Program Purpose:       To check all logs in the project area.
                         There are 2 files created, one for QC logs and
                         another for programming logs

  Macro Parameters:      NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/

* Check the programming area;
** Assume setting logDetail and dataIssues to 0 during the project development stage;
%gmLogScanReport(selectScan = directory,
                 pathIn     = &_projPre./&_type./prog/,
                 fileOut    = projArea,
                 subDir     = 1,
                 sendEmail  = 0,
                 logDetail  = 1,
                 dataIssues = 1
                );

* Check the QC area and keep the result in the work folder;
%gmLogScanReport(selectScan = directory,
                 pathIn     = &_projPre./&_type./qcprog/,
                 fileOut    = projArea,
                 pathOut    = %sysFunc(pathName(work)),
                 subDir     = 1,
                 sendEmail  = 0,
                 logDetail  = 0,
                 dataIssues = 0
                );
* Move the QC log report to a separate file in the global folder;
%gmExecuteUnixCmd(cmds = mv %sysFunc(pathName(work))/gmLogScanReport_&_type..pdf &_global./qc_gmLogScanReport_&_type..pdf);
