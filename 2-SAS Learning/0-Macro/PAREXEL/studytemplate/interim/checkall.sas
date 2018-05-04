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
                         gmCheckSpecification_&_type..pdf
                         gmCheckSpecification_&_type..xls
                         pinnacle21_&_type..xlsx

  Program Purpose:       Scan and report:
                         * SVN status of the project area  (i.e., /stats/)
                         * SVN status of the project type area (e.g., /stats/primary)
                         * Compare outputs in the project type arae 
                         * Log files for main and QC sides
                         * Pinnacle 21 report for the analysis library
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

                         
%*----------------------------------------------------------------------------*;
%*---  Run Pinnacle21 for the Analysis library                             ---*;
%*----------------------------------------------------------------------------*;                
%gmExecutePinnacle21( libsIn  = analysis
                    , pathOut = &_global.
                    , fileOut = projArea
                    , excludePattern = ^formats$
                    );                

%*----------------------------------------------------------------------------*;
%*---  Run checks between datasets and specification                       ---*;
%*----------------------------------------------------------------------------*;

%* Get the required values from the metadata: CT and link to spec;
data _null_;
    set metadata.global end=lastObs;
    
    retain aCtFl sCtFl specFl 0;
    
    if upcase(key) = "ADAMCT" and not missing(value) then do;
        call symput("_adamCtVer",strip(value));
        aCtFl = 1;
    end;
    
    if upcase(key) = "SDTMCT" and not missing(value) then do;
        call symput("_sdtmCtVer",strip(value));
        sCtFl = 1;
    end;
    
    if upcase(key) = "FILESPEC" and not missing(value) then do;
        call symput("_fileSpec",strip(value));
        specFl = 1;
    end;
    
    if lastObs and not (aCtFl and sCtFl and specFl) then do;
        length rc $1;
        rc = resolve(  '%gmMessage(codeLocation=checkall.sas'
                     ||' ,linesOut=%str(Either ADaM CT, SDTM CT, or spec file is not defined in the metadata)'
                     ||' ,printStdOut = 1, sendEmail = 1, selectType=ABORT);'
                    );
    end;
run;

%* Import Controlled Terminology;  
%gmImportCdiscTerminology( standards = ADaM \ver=&_adamCtVer
                                       @SDTM \ver=&_sdtmCtVer
                           ,dataOut = studyCT 
                         );
                         
%* Import Specifications;
%gmImportSpecification(  fileIn= &_fileSpec
                       , libOut = work
                       , dataTermIn = studyCT 
                      );     

%* Create report of cross-checks between specifications and datasets;
%gmCheckSpecificationReport(  libSpecIn = work
                            , libDataIn = analysis
                            , fileOut = projArea
                            , createXls = 1                            
                           );  
                     
