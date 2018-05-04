/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   <client> / <protocol>
  PXL Study Code:        <TIME Code>

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                <author> / $LastChangedBy:  $
  Creation Date:         <date in DDMMMYYYY format> / $LastChangedDate:  $

  Program Location/Name: $HeadURL: $

  Files Created:         gmSvnReport_global.pdf
                         gmSvnReport_&_type..pdf
                         gmCompareReport_&_type..pdf
                         gmLogScanReport_&_type..pdf
                         qc_gmLogScanReport_&_type..pdf

  Program Purpose:       Scan and report:
                         * SVN status of the project area  (i.e., /stats/)
                         * SVN status of the project type area (e.g., /stats/primary)
                         * Compare outputs in the project type arae 
                         * Log files for main and QC sides
                         All files are created in the /stats/global/ folder


  Macro Parameters       NA

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/

%*----------------------------------------------------------------------------*;
%*---  Remove existing report files                                        ---*;
%*----------------------------------------------------------------------------*;
%let rc = %gmExecuteUnixCmd(cmds= rm -f &_global./gmSvnReport_global.pdf);
%let rc = %gmExecuteUnixCmd(cmds= rm -f &_global./gmSvnReport_&_type..pdf);
%let rc = %gmExecuteUnixCmd(cmds= rm -f &_global./gmCompareReport_&_type..pdf);
%let rc = %gmExecuteUnixCmd(cmds= rm -f &_global./gmLogScanReport_&_type..pdf);
%let rc = %gmExecuteUnixCmd(cmds= rm -f &_global./qc_gmLogScanReport_&_type..pdf);

%*----------------------------------------------------------------------------*;
%*---  Scan the logs                                                       ---*;
%*----------------------------------------------------------------------------*;

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

%*----------------------------------------------------------------------------*;
%*---  Create the SVN reports                                              ---*;
%*----------------------------------------------------------------------------*;

* SVN report for the project area folder;
%gmSvnReport(  pathsIn   = &_projpre./&_type/@&_macros.@&_global.@&_formats.
              ,fileOut   = projArea
              ,noLogDirs = &_macros.@&_global.@&_formats.
            );

* SVN report for the whole /stat/ folder;
%gmSvnReport( pathOut=%sysFunc(pathName(work))
             ,noLogDirs = &_macros.@&_global.@&_formats.
            );

* Move the SVN report to the global folder;
%gmExecuteUnixCmd(cmds = mv %sysFunc(pathName(work))/gmSvnReport.pdf &_global./gmSvnReport_global.pdf);

%*----------------------------------------------------------------------------*;
%*---  Compare Report                                                      ---*;
%*----------------------------------------------------------------------------*;

%gmCompareReport( pathsIn = &_projpre./&_type./qcprog
                 ,subDir  = 1
                 ,fileOut = projArea
                )
