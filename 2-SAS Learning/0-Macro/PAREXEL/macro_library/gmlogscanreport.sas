/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dan Higgins $LastChangedBy: kolosod $
  Creation Date:         28JAN2015 $LastChangedDate: 2016-04-05 05:09:57 -0400 (Tue, 05 Apr 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscanreport.sas $

  Files Created:         Datasets containing results from scans:
                            metadata.glsr_sum_white
                            metadata.glsr_issue_white
                            metadata.glsr_text_white
                            metadata.glsr_sum_black
                            metadata.glsr_issue_black
                            metadata.glsr_text_black

                         PDF file containing log Scan report.  Written to pathOut= location and named as per
                         fileOut= value

  Program Purpose:       The purpose of the macro is to select SAS log files, scan them using the GmLogScanCore macro 
                         and produce a detailed report of findings. It offers the following functionality: 
                         #
                         #  Logs can be selected using three different approaches:
                         #     1. Scan of standard directories using macro variables defined in setup.sas, 
                         with option to exclude some.
                         #     2. Scan of specified directory, with option to include any sub-directories.
                         #     3. Scan of log files based on SAS programs listed in Multirun file.
                         #
                         # * Results from previous scan are stored in SAS datasets and referenced on each execution 
                         to avoid re-scanning of logs which have not changed (based on modification date/time) since 
                         previous scan.
                         #
                         # * Scans can be performed using whitelist or blacklist. 
                         #
                         # * Report is created in PDF format with bookmarks to sections. 
                         #
                         # * Naming of PDF file can be set to include user name or project area and/or date/time stamp.
                         #  
                         # * Messages found are summarised by type and risk.
                         #
                         # * Level of detail in report can be specified by user.
                         #
                         # * Email summary can be provided to user upon completion of execution.
                         #
                         # * Things to note: 
                         #     - The macro is currently only coded to work in PAREXEL Unix environment.
                         #     - In order to execute and save results from previous scans the project must have a metadata 
                         library intialised, e.g. /projects/study123/stats/primary/data/metadata
                         #  
                         # This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
                         #
                         # This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                selectScan
      Allowed Values:    directory | multirun | setup 
      Default Value:     REQUIRED
      Description:       Method of selecting logs for scanning

    Name:                selectList 
      Allowed Values:    white | black 
      Default Value:     REQUIRED
      Description:       Type of scan to perform, i.e. whitelist or blacklist (passed to gmLogScanCore).   If value present in
                         metadata.global that is used, but is overriden by macro argument if specified.

    Name:                fileMult 
      Allowed Values:    current | path and filename of valid multirun file
      Default Value:     current
      Description:       Full unix path and filename of multirun file.#Alternatively to select the multirun file from which
                         the macro is called from set fileMult=current

    Name:                excludeLastMult 
      Allowed Values:    0 | 1
      Default Value:     see description
      Description:       Exclude log from last program in multirun file from scanning (0=No, 1=Yes)
                         Default is set to 1 if fileMult=current, otherwise default is 0
 
    Name:                excludeDirs
      Allowed Values:         
      Default Value:          
      Description:       Directories to exclude from scan based on macro variables from setup or directory names
                         (@ separated).  Supports regular expressions.  Not applicable to multirun scans
                         #e.g. _PCORE@/projects/study99999/stats/primary/prog/analysis@projects/study99999/stats/primary/qc.*

    Name:                includeFiles
      Allowed Values:     
      Default Value:     
      Description:       List of files to scan.  Supports regular expressions.
                         #e.g. adsl.log@adsv.log@adex.log will force macro to scan 3 listing logs
                         #     ad.*.log will force the macro to scan only logs starting with ad
                        
    Name:                excludeFiles
      Allowed Values:     
      Default Value:     
      Description:       List of files to exclude from scan.  Supports regular expressions.
                         #e.g. adae.log@advs.log will force macro to exclude those 2 logs 
                         *     ad.* will force the macro to exclude logs starting with ad

    Name:                pathsIn
      Allowed Values:        
      Default Value:        
      Description:       Full unix paths of directories to scan (separate multiple paths with splitChar)

    Name:                subDir 
      Allowed Values:    0 | 1
      Default Value:     0
      Description:       Include any sub-directories in scan (0=No, 1=Yes)

    Name:                splitChar
    Allowed Values:     
    Default Value:       @
    Description:         Split character to separate pathsIn/excludeDirs/includeFiles/excludeFiles values

    Name:                pathOut  
      Allowed Values:    
      Default Value:     &_global 
      Description:       Full unix path of directory to store report in 

    Name:                fileOut   
      Allowed Values:    default | projarea | full | user
      Default Value:     default
      Description:       Naming convention for report filename: 
                         #- default: gmLogScanReport.pdf
                         #- projarea: dependant on project area, e.g. gmLogScanReport_primary.pdf
                         #- full: dependent on project area and run date/time, e.g. gmLogScanReport_primary_20140115T1338.pdf
                         #- user: dependent on user executing macro, e.g. gmLogScanReport_kolosod.pdf

    Name:                printStdOut
      Allowed Values:    0 | 1
      Default Value:     1
      Description:       Send execution messages to StdOut if macro run in batch mode (0=No, 1=Yes)
                         During interactive mode no messages will be send to StdOut.

    Name:                sendEmail   
      Allowed Values:    0 | 1
      Default Value:     0 
      Description:       Send email to user on completion of execution (0=No, 1=Yes)

    Name:                logDetail   
      Allowed Values:    0 | 1
      Default Value:     1
      Description:       Include details of messages found and text surrounding in report (0=No, 1=Yes)
                         Note: This only includes details of messages not classified as data issues.   Data issues
                         are listed in seperate section of report (see dataIssues parameter).

    Name:                dataIssues   
      Allowed Values:    0 | 1
      Default Value:     1
      Description:       Include details of data issues in report (0=No, 1=Yes)

    Name:                lockRetry 
      Allowed Values:    5 to 50
      Default Value:     10
      Description:       Number of times to retry locking metadata datasets before aborting.  Prior to each retry a 10 second
                         delay is applied.  

    Name:                maxLen  
      Allowed Values:    1 to 32767 
      Default Value:     1024 
      Description:       Maximum length of united message (see gmLogScanCore for more details)  

    Name:                metadataIn
      Default Value:     metadata.global
      Description:       Dataset containing metadata.
    
  Macro Returnvalue:     

      Description:       Macro does not return any values.

  Global Macrovariables:

    Name:                _global
      Usage:             read
      Description:       Path for global directory.

    Name:                _project
      Usage:             read
      Description:       Unix project name.

    Name:                _projpre
      Usage:             read
      Description:       Project directory.

    Name:                _type
      Usage:             read
      Description:       Delivery type.

  Metadata Keys:

    Name:                logScanList
      Description:       value (black or white) is used to set selectList= in macro call.  
                         Can be overridden in macro call if required.  A note is written to log if parameter in macro 
                         call is different to value in global metadata dataset.
      Dataset:           global (dataset specified in metadataIn=).

    Name:                customWhiteList
      Description:       value (full path and name of whitelist file) is passed to CustomWhiteListIn= parameter in 
                         gmlogScanCore.  This can only be set at study-level in global metadata dataset as no
                         corresponding parameter exists in gmLogScanReport.
      Dataset:           global (dataset specified in metadataIn=).

  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmLogScanCore (called)
                         gmMessage (called)
                         gmModifySplit (called)
                         gmGetUserName (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2006 $
-----------------------------------------------------------------------------*/

%macro gmLogScanReport
   (selectScan=,     /* directory/multirun/setup */
    selectList=,     /* specify black or white to select list for gmlogscancore */
    fileMult=current,/* filename of multirun file (where scan=multirun) or current for multirun file macro called from */
    excludeLastMult=,     /* 0/1 exclude last file from multirun file*/
    excludeDirs=,    /* dirs to exclude from scan (where selectScan=setup or directory) */
    includeFiles=,   /* regex to select files for scanning */
    excludeFiles=,   /* regex to exclude files for scanning */
    pathIn=,         /* depreciated (use pathsIn instead) */
    pathsIn=,        /* directories to scan (where scan=dir) */
    subDir=0,        /* 0/1 include sub-directories in scan (where scan=dir) */
    splitChar=@,     /* split char to separate pathsIn/excludeDirs/includeFiles/excludeFiles values */
    pathOut=&_global,/* default=&_global, specify dir to store report in */
    fileOut=default, /* default=gmLogScanReport.pdf,
                       projarea=project area e.g. gmLogScanReport_primary.pdf,
                       full=project area and date/time e.g. gmLogScanReport_primary_20131212T1338.pdf 
                       user=user name e.g. gmLogScanReport_kolosod.pdf */
    printStdOut=1,   /* 0/1 send execution messages to Stdout in batch mode */
    sendEmail=0,     /* 0/1 send summary email on completion */
    logDetail=1,     /* 0/1 include details of message and log text surrounding */
    dataIssues=1,    /* 0/1 include details of data issues */
    lockRetry=10,    /* number of times to retry locking datasets before aborting (default=10, range=5 to 50) */
    maxLen=1024,     /* argument to pass to gmLogScanCore */
    metaDataIn=metadata.global /* metadata.global dataset */
    );
    
   * create separate temp work library for use during execution;
   %local glsr_templib;
   %let glsr_templib=%gmStart(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscanreport.sas $,
      revision=$Rev: 2006 $, checkMinSasVersion=9.2, libRequired=1);

   * collect log, title and format options to reset after execution;
   %local glsr_comp glsr_d glsr_datasets glsr_dexist 
   glsr_dirs glsr_dirnum glsr_dirtot glsr_dsid glsr_dt glsr_emptydir glsr_epth glsr_err glsr_exdirs glsr_fexist 
   glsr_fmtmod glsr_fmtsearch glsr_inc glsr_it glsr_invfile glsr_lines glsr_lockapplied glsr_logDetail 
   glsr_logfiles glsr_loop glsr_metadate glsr_mg_customWhiteList glsr_mg_logScanList
   glsr_ml_cnt glsr_mvs glsr_nofiles glsr_out glsr_rc glsr_refresh glsr_slogs glsr_templib glsr_wldate;

   * null macros variables that may not be set later;
   %let glsr_logs=;
   %let glsr_mg_logScanList=;
   %let glsr_mg_customWhiteList=;

   * save options;
   proc optsave out=&glsr_templib..glsr_options; run;

   * lowercase selectList argument;
   %let selectList=%lowcase(&selectList);

   * set options;
   %let glsr_fmtsearch=%sysfunc(getoption(fmtsearch));
   data _null_;
      call symput ('glsr_fmtmod',"(&glsr_templib "||substr("&glsr_fmtsearch",2));
   run;
   options center nodate nonumber fmtsearch=&glsr_fmtmod noquotelenmax;

   %if %symExist(gmPxlErr) %then %do;
      %if &gmPxlErr. eq 1 %then %do;
            %gmMessage(codeLocation=gmLogScanReport/ABORT
             , linesOut=Macro aborted as GMPXLERR is set to 1.
             , selectType=ABORT
             , printStdOut=1
             , sendEmail=&sendEmail
             );
      %end;
   %end;

   * check if metadata library exists;
   %let glsr_rc=%sysfunc(libref(metadata));
   %if &glsr_rc ne 0 %then %do;
       %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as Metadata libname not assigned.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;
   %else %do;
      * if exists then check if a refresh is required;
      * refresh will delete all glsr_ (black and white) datasets when standard whitelist is updated;
      %let glsr_refresh=0;
      data _null_;
         length glsr_pathToWhiteList $1024;
         glsr_pathToWhiteList = prxChange("s#.*/svnrepo/\w*/(.*)/\w*\.sas.*#/opt/pxlcommon/stats/macros/$1/whitelist.xls#",1,
            '$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscanreport.sas $');
         call symput("glsr_pathToWhiteList",trim(left((glsr_pathToWhiteList))));
      run;
      filename glsr_wl "&glsr_pathToWhiteList";
      data _null_;
         call symput ('glsr_fexist',trim(left(put(fexist('glsr_wl'),best.))));
      run;
      %if &glsr_fexist=1 %then %do;
         data _null_;
            set sashelp.vextfl (where=(fileref='GLSR_WL'));
            call symput ('glsr_wldate',trim(left(put(modate,is8601dt.))));
         run;
         %let glsr_datasets=0;
         proc sql;
            create table &glsr_templib..glsr_metadate
            as select memname, modate from dictionary.tables
            where upcase(libname)='METADATA' and upcase(memname) like 'GLSR_%' and 
            (upcase(memname) like '%_BLACK' or upcase(memname) like '%_WHITE')
            order by modate;
         quit;
         data _null_;
            set &glsr_templib..glsr_metadate;
            by modate;
            if _n_=1 then call symput ('glsr_metadate',put(modate,is8601dt.));
            call symput ('glsr_dataset'||trim(left(put(_n_,best.))),trim(left(memname)));
            call symput ('glsr_datasets',trim(left(put(_n_,best.))));
         run;
         %if &glsr_datasets ne 0 %then %do;
            data _null_;
               if input("&glsr_metadate",is8601dt.)<=input("&glsr_wldate",is8601dt.) then call symput ('glsr_refresh','1');
               else call symput ('glsr_refresh','0');
            run;
         %end;
      %end;
   %end;

   * check if metadata.global dataset exists read logScanList and customWhiteList values if present;
   %if %sysFunc(exist(&metaDataIn)) %then %do;
      data _null_;
         set &metaDataIn;
         if upcase(key)='LOGSCANLIST' and value ne '' then call symput ('glsr_mg_logScanList',trim(left(value)));
         if upcase(key)='CUSTOMWHITELIST' and trim(left(value)) ne '' then call symput ('glsr_mg_customWhiteList',trim(left(value)));
      run;
   %end;
   %else %do;
      *check if custom metadata dataset specified that it exists;
      %if &metaDataIn ne metadata.global %then %do;
         %gmMessage(codeLocation=gmLogScanReport/ABORT
             , linesOut=Macro aborted as &metaDataIn does not exist.
             , selectType=ABORT
             , printStdOut=1
             , sendEmail=&sendEmail
             );
      %end;
   %end;

   * generate filename for output pdf file and delete existing version;
   filename glsr_po "&pathOut";
   %let glsr_dexist=0;
   data _null_;
      call symput ('glsr_dexist',trim(left(put(fexist('glsr_po'),best.))));
   run;
   data _null_;
      if substr(trim(left("&pathout")),length(trim(left("&pathout"))),1) ne '/' then
         call symput ('pathout',trim(left("&pathout"))||'/');
   run;
   %if &glsr_dexist=1 %then %do;
      %if %lowcase(&fileOut)=default %then %do;
         filename glsr_rep "&pathOut./gmLogScanReport.pdf";
         data _null_;
            call symput ('glsr_epth',"\\kennet"||tranwrd(tranwrd(substr("&pathOut",index(substr("&pathOut",2),'/')+1),'/','\'),'\\','\')||
               "gmLogScanReport.pdf");
         run;
      %end;
      %else %if %lowcase(&fileOut)=user %then %do;
         filename glsr_rep "&pathOut./gmLogScanReport_&sysUserId..pdf";
         data _null_;
            call symput ('glsr_epth',"\\kennet"||tranwrd(tranwrd(substr("&pathOut",index(substr("&pathOut",2),'/')+1),'/','\'),'\\','\')||
               "gmLogScanReport_&sysUserId..pdf");
         run;
      %end;
      %else %if %lowcase(&fileOut)=projarea %then %do;
         %if %symexist(_type) %then %do;
            filename glsr_rep "&pathOut./gmLogScanReport_&_type..pdf";
            data _null_;
               call symput ('glsr_epth',"\\kennet"||tranwrd(tranwrd(substr("&pathOut",index(substr("&pathOut",2),'/')+1),'/','\'),'\\','\')||
                  "gmLogScanReport_&_type..pdf");
            run;
         %end;
         %else %do;
            %gmMessage(codeLocation=gmLogScanReport/ABORT
             , linesOut=Macro aborted as _type not setup for use in projarea naming.
             , selectType=ABORT
             , printStdOut=1
             , sendEmail=&sendEmail
             );
         %end;
      %end;
      %else %if %lowcase(&fileOut)=full %then %do;
         %if %symexist(_type) %then %do;
            data _null_;
               call symput ('glsr_dt',trim(left(put(date(),yymmddn8.)))||'T'||compress(tranwrd(put(time(),tod5.),':','')));
            run;
            filename glsr_rep "&pathOut./gmLogScanReport_&_type._&glsr_dt..pdf";
            data _null_;
               call symput ('glsr_epth',"\\kennet"||tranwrd(substr("&pathOut",index(substr("&pathOut",2),'/')+1),'/','\')||
                  "gmLogScanReport_&_type._&glsr_dt..pdf");
            run;
         %end;
         %else %do;
            %gmMessage(codeLocation=gmLogScanReport/ABORT
             , linesOut=Macro aborted as _type not setup for use in projarea naming.
             , selectType=ABORT
             , printStdOut=1
             , sendEmail=&sendEmail
             );
         %end;
      %end;
      %else %do;
          %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as invalid value specified for fileOut= parameter.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;
   %end;
   %else %do;
       %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as report output directory does not exist.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;

   * if logSelectList specified in metadata.global then use if selectList not passed to macro;
   * if logSelectList and selectList differ use SeelctList value and put message in log;
   %if "&glsr_mg_logScanList" ne "" %then %do; 
      %if &selectList= %then %let selectList=%lowcase(&glsr_mg_logScanList);
      %else %if &selectList ne %lowcase(&glsr_mg_logScanList) %then %do;
         %gmMessage(codeLocation=gmLogScanReport/selectList
            , linesOut=selectList argument differs from metadata.global
            @logScanList value.  SelectList argument has been used.
           , selectType=NOTE
         );   
      %end;
   %end;
  
   * get modification date of whitelist if used;
   %if "&selectList"="white" %then %do;

      %local glsr_pathToWhiteList;
      %let glsr_pathToWhiteList=;

      /* custom whitelist */
      %if "&glsr_mg_customWhiteList" ne "" %then %do;
         %let glsr_pathToWhiteList=&glsr_mg_customWhiteList;
      %end;
      /* standard whitelist */
      %else %do; 
         data _null_;
            length glsr_pathToWhiteList $1024;
            glsr_pathToWhiteList = prxChange("s#.*/svnrepo/\w*/(.*)/\w*\.sas.*#/opt/pxlcommon/stats/macros/$1/whitelist.xls#",1,
               '$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscanreport.sas $');
            call symput("glsr_pathToWhiteList",trim(left((glsr_pathToWhiteList))));
         run;
      %end;
      filename glsr_wl "&glsr_pathToWhiteList";
      data _null_;
         call symput ('glsr_fexist',trim(left(put(fexist('glsr_wl'),best.))));
      run;
      %if &glsr_fexist ne 1 %then %do;
         %gmMessage(codeLocation=gmLogScanReport/ABORT
         , linesOut=Macro aborted as custom whitelist (&glsr_pathToWhiteList) does not exist.
         , selectType=ABORT
         , printStdOut=1
         , sendEmail=&sendEmail
         );
      %end;
      data _null_;
          set sashelp.vextfl (where=(fileref='GLSR_WL'));
          call symput ('glsr_wldate',trim(left(put(modate,is8601dt.))));
      run;
   %end;
   %else %if "&selectList" ne "black" %then %do;
       %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as selectList value missing or invalid.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;

   * check logDetail argument;
   %if &logDetail ne 0 and &logDetail ne 1 %then %do;
      %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as logDetail value missing or invalid.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;

   * check dataIssues argument;
   %if &dataIssues ne 0 and &dataIssues ne 1 %then %do;
      %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as dataIssues value missing or invalid.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;

   * check sendEmail argument;
   %if &sendEmail ne 1 and &sendEmail ne 0 %then %do;
      %gmMessage(codeLocation=gmLogScanReport/sendEmail check
       , linesOut=Macro aborted as sendEmail value missing or invalid.
       , selectType=ABORT
       , printStdOut=1
       );
   %end;
   %else%if &sendEmail=1 %then %do; 
      * check for email forward file ;
      filename glsr_ef "~/.forward ";
      %let glsr_fexist=0;
      data _null_;
         call symput ('glsr_fexist',trim(left(put(fexist('glsr_ef'),best.))));
      run;
      %if &glsr_fexist ne 1 %then %do;
         %let sendEmail=0;
         %gmMessage(codeLocation=gmLogScanReport/Execution
         , linesOut=.forward file missing for user so email cannot be sent.
         , selectType=NOTE
         , printStdOut=1
         );
      %end;
   %end;

    * check excludeLastMult argument and set default based on fileMult;
   %if &excludeLastMult= %then %do;
      %if %lowcase("&fileMult")="current" %then %let excludeLastMult=1;
      %else %let excludeLastMult=0;
   %end;
   %if &excludeLastMult ne 0 and &excludeLastMult ne 1 %then %do;
      %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as excludeLastMult value missing or invalid.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;
   
   * check lockRetry argument;
   %if &lockRetry < 5 or &lockRetry >50 %then %do;
      %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as lockRetry value missing or invalid.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;

   * check _projpre macro variable exists;
   %if %lowcase("&SelectScan")="setup" %then %do;
      %if %symExist(_projpre) %then %do;
         %gmMessage(codeLocation=gmLogScanReport/check for _projpre
          , linesOut=_projpre found.
          , selectType=NOTE
          );
      %end; 
      %else %do;
         %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as _projpre macro variable does not exist.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;
   %end;

   * check _project macro variable exists;
   %if "&excludeDirs" ne "" or %lowcase("&SelectScan")="setup" %then %do;
      %if %symExist(_project) %then %do;
         %gmMessage(codeLocation=gmLogScanReport/check for _project
          , linesOut=_project found.
          , selectType=NOTE
          ); 
      %end; 
      %else %do;
         %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as _project macro variable does not exist.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;
   %end;

   *******************************************************************************************;
   * multirun scan;
   *******************************************************************************************;
   %if %lowcase("&SelectScan")="multirun" %then %do;
      %if "&excludeDirs" ne "" %then %do;
          %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as excludeDirs parameter not applicable to multirun scan.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;
      %if "&includeFiles" ne "" %then %do;
          %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as includeFiles parameter not applicable to multirun scan.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;
      %if "&excludeFiles" ne "" %then %do;
          %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as excludeFiles parameter not applicable to multirun scan.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;

      %let glsr_emptydir=0;
      * checks;
      %if "&fileMult"="" %then %do;
          %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as multirun filename not specified.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;
      %else %if %lowcase("&fileMult")="current" %then %do;

         * get parents parent process ID - PID of the multirun script;
         filename _parent pipe "ps -f -p `ps -f -p &sysJobId | grep &sysJobId | awk '{print $3}'`";
         data _null_;
            infile _parent end = lastObs lrecl=1024;
            input;
            if lastObs then do;
                 * get value of the 3rd column;
                 ppid = input(prxChange("s/^\w+\s+\d+\s+(\d+).*$/$1/",1,strip(_infile_)),best.);
                 call symputX ("pppid",ppid);
              end;
         run;

         * close the pipe;
         filename _parent;

         filename _multscr "/tmp/multirunscr.&sysUserId..&pppid";

         * check tmp multirun file exists;
         %if %sysFunc(fexist(_multscr)) %then %do;

            * get list of logs from a file created by multirun script;
            data &glsr_templib..multi_logs (keep=log);
               infile _multscr lrecl=1024;
               input;
               * analyze the following string the string
                  .../sas path/to/file/file.sas -print '.../file.lst' -log '..../file.log'
               ;
               length log pgm $1024;
               if prxMatch("/^.*\/([^\/]*)\s+-print.*$/",strip(_infile_)) then do;
                  pgm = prxChange("s/^.*\/([^\/]*)\s+-print.*$/$1/i",1,strip(_infile_));
                  log = prxChange("s/.*-log\s*'(.*?)'.*$/$1/",1,strip(_infile_));
               end;

               * update /project99 to /projects if required;
               if log=:'/project' and not(log=:'/projects') then do;
                  log='/projects/'||trim(left(substr(log,index(substr(log,2),'/')+2)));
               end;
                
               * change multiple // to single /;
               log=prxChange("s/\/{2,}/\//",-1,log);

               if log ne '';
            run;

         %end;
         %else %do;
            %gmMessage(codeLocation=gmLogScanReport/ABORT
             , linesOut=Macro aborted as current multirun file does not exist.
             , selectType=ABORT
             , printStdOut=1
             , sendEmail=&sendEmail
             );
         %end;

      %end;
      %else %do;

         filename glsr_mul "&fileMult";
         %if %sysFunc(fexist(glsr_mul)) %then %do;

            * get list of log files based on multirun file;
            data &glsr_templib..multi_logs;
               infile glsr_mul length=reclen;
               input @1 record $varying1024. reclen;
               log=tranwrd(record,'.sas','.log');
               log=substr(log,1,index(log,'.log')+4);
               * update /project99 to /projects if required;
               if log=:'/project' and not(log=:'/projects') then do;
                  log='/projects/'||trim(left(substr(log,index(substr(log,2),'/')+2)));
               end;

               * change multiple // to single /;
               log=prxChange("s/\/{2,}/\//",-1,log);

               if index(log,'.log');
            run;

         %end;
         %else %do;
            %gmMessage(codeLocation=gmLogScanReport/ABORT
             , linesOut=Macro aborted as multirun file does not exist.
             , selectType=ABORT
             , printStdOut=1
             , sendEmail=&sendEmail
             );
         %end;
      %end;

      * check for invalid log filenames;
      %let glsr_invfile=0;
      data _null_;
         set &glsr_templib..multi_logs;
         length txt logname $1024;
         pos=index(log,'/');
         txt=substr(log,pos+1);
         do while (index(txt,'/'));
            pos=index(txt,'/');
            txt=substr(txt,pos+1);
         end;
         logname=txt;
         if substr(logname,1,1)=' ' then call symput ('glsr_invfile','1');
      run;
      %if &glsr_invfile=1 %then %do;
          %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as log filename starts with space/s.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;

      * exclude last file from multirun if required;
      %if &excludeLastMult=1 %then %do;
         data &glsr_templib..multi_logs;
            set &glsr_templib..multi_logs end=eof;
            if not eof;
         run;
      %end;

      * load log file names into macro variables;
      %let glsr_logfiles=0;
      data _null_;
         set &glsr_templib..multi_logs;
         call symput ('glsr_logfile'||trim(left(put(_n_,best.))),trim(left(log)));
         call symput ('glsr_logfiles',trim(left(put(_n_,best.))));
      run;

      * error, delete pdf and abort if no valid logs in multirun;
      %let glsr_nofiles=1;
      %do glsr_lf=1 %to &glsr_logfiles;
         filename glsr_log "%superQ(glsr_logfile&glsr_lf)";
         %if %sysFunc(fexist(glsr_log)) %then %let glsr_nofiles=0;
      %end;
      %if &glsr_nofiles=1 %then %do;
         %if %sysFunc(fexist(glsr_rep)) %then %do;
            data _null_;
               x=fdelete('glsr_rep');
            run;
         %end;
         %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as no logs selected from multirun file.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;

   %end;

   %else %if %lowcase("&SelectScan")="setup" %then %do;
   *******************************************************************************************;
   * setup scan;
   *******************************************************************************************;
      * get global macro variables starting with _ which contain directories;
      data &glsr_templib..macvars01 (keep=name value rename=(value=dir name=fname));
         set sashelp.vmacro (where=(substr(name,1,1)='_' and index(upcase(value),upcase("/&_project")) 
            and not(index(upcase(value),'.SAS'))));

            * change multiple // to single /;
            value=prxChange("s/\/{2,}/\//",-1,value);
            if substr(trim(left(value)),length(trim(left(value))),1) ne '/' then value=trim(left(value))||'/';
      run;
      proc sort data=&glsr_templib..macvars01; by fname; run;

      * exclude any dirs specified in excludeDirs= argument;
     %if "%superQ(excludeDirs)"^="" %then %do;
        %if %bquote(%substr(&excludeDirs, %length(&excludeDirs)))="&splitChar" %then %let excludeDirs=%substr(&excludeDirs, 1, %eval(%length(&excludeDirs)-1));;
        data &glsr_templib..exclude01 (drop=i);
           length DIR $1024;
           I=1;
           do while(scan("&excludeDirs", I, "&splitChar") ne "");
               DIR=cats(scan("&excludeDirs", I, "&splitChar"));
               /* Remove repeating slashes */
               DIR=prxchange("s#/+#/#", -1, DIR);
               /* Symbolic link path*/
               DIR=prxchange("s#^(/project\d+/)#/projects/#", -1, cats(DIR));
               I+1;
               output;
           end;
        run;
        %let glsr_mvs=0;
        data _null_;
           set sashelp.vmacro (where=(substr(name,1,1)='_' and index(value,"/&_project") and not(index(value,'.sas'))));
           call symput ('glsr_mv_name'||cats(put(_n_,best.)),cats(name));
           call symput ('glsr_mv_value'||cats(put(_n_,best.)),cats(value));
           call symput ('glsr_mvs',cats(put(_n_,best.)));
        run;
        * replace macro vars (e.g. _PTAB) with paths;
        data &glsr_templib..exclude02;
           set &glsr_templib..exclude01;
           %if &glsr_mvs ne 0 %then %do;
              %do glsr_i=1 %to &glsr_mvs;
                 if upcase(cats(dir))=upcase(cats("&&glsr_mv_name&glsr_i")) then dir=cats("&&glsr_mv_value&glsr_i");
                 if index(dir,"/&_project") and substr(trim(left(dir)),length(trim(left(dir))),1) ne '/' then dir=trim(left(dir))||'/';
              %end;
            %end;
        run;
        data _null_;
           set &glsr_templib..exclude02;
           if index(dir,"/&_project") and substr(trim(left(dir)),length(trim(left(dir))),1)='/' then
              dir="\Q"||trim(left(dir))||"\E";  
           call symput ('glsr_exdir'||trim(left(put(_n_,best.))),trim(left(dir)));
           call symput ('glsr_exdirs',trim(left(put(_n_,best.))));
        run;
        proc sort data=&glsr_templib..macvars01; by dir; run;
        %do glsr_d=1 %to &glsr_exdirs;
           data &glsr_templib..macvars01;
              set &glsr_templib..macvars01;
              by dir;
              if not prxmatch("#^&&glsr_exdir&glsr_d$#i", cats(DIR));
           run;
        %end;

     %end;
     
      data &glsr_templib..macvars02 (keep=dir);
         set &glsr_templib..macvars01;
      run;
      * load directories into macro variables;
      proc sort data=&glsr_templib..macvars02 nodupkey; by dir; run;
      %let glsr_dirs=0;
      data _null_;
         set &glsr_templib..macvars02;
         if substr(trim(left(dir)),length(trim(left(dir))),1) ne '/' then dir=trim(left(dir))||'/';
         call symput ('glsr_dir'||trim(left(put(_n_,best.))),trim(left(dir)));
         call symput ('glsr_dirs',trim(left(put(_n_,best.))));
      run;

      * scan each directory for logs files;
      %if &glsr_dirs ne 0 %then %do;
         %do glsr_d=1 %to &glsr_dirs;

            filename glsr_in pipe "ls -l '&&glsr_dir&glsr_d.'*.log";
            data &glsr_templib..logs01 (keep=logfile logname);
               infile glsr_in pad missover lrecl=1024;
               length logfile inlog logname $1024;
               input inlog 1-1024;
               logfile=substr(inlog,index(inlog,'/'));
               * update /project99 to /projects if required;
               if logfile=:'/project' and not(logfile=:'/projects') then do;
                  logfile='/projects/'||trim(left(substr(logfile,index(substr(logfile,2),'/')+2)));
               end;
               pos=index(logfile,'/');
               txt=substr(logfile,pos+1);
               do while (index(txt,'/'));
                  pos=index(txt,'/');
                  txt=substr(txt,pos+1);
               end;
               logname=txt;
            run;
            proc sort data=&glsr_templib..logs01; by logfile; run;
            %let glsr_slogs=0;
            data _null_;
               set &glsr_templib..logs01;
               call symput ('glsr_slogs',trim(left(put(_n_,best.))));
            run;
            %if  &glsr_slogs ne 0 %then %do;
               data &glsr_templib..set_logs;
                  set &glsr_templib..logs01 %if &glsr_d ne 1 %then %do; &glsr_templib..set_logs %end; ;
                  by logfile;
               run;
            %end;

            * check for invalid log filenames;
            %let glsr_invfile=0;
            data _null_;
               set &glsr_templib..logs01;
               if substr(logname,1,1)=' ' then call symput ('glsr_invfile','1');
            run;
            %if &glsr_invfile=1 %then %do;
               %gmMessage(codeLocation=gmLogScanReport/ABORT
               , linesOut=Macro aborted as log filename starts with space/s.
               , selectType=ABORT
               , printStdOut=1
               , sendEmail=&sendEmail
               );
            %end;

         %end;
      %end;
      %else %let glsr_logfiles=0;
            
      * subset based on includeFiles= argument if specified;
      %if "%superQ(includeFiles)"^="" %then %do;
         %if %bquote(%substr(&includeFiles, %length(&includeFiles)))="&splitChar" %then %let includeFiles=%substr(&includeFiles, 1, %eval(%length(&includeFiles)-1));;
         %if %index(&includeFiles, &splitChar) %then %let includeFiles=%sysfunc(tranwrd(&includeFiles, &splitChar, |));;
         data &glsr_templib..set_logs;
            set &glsr_templib..set_logs;
            length includeFiles $32676;
            drop includeFiles;
            includeFiles=symGet("includeFiles");
            includeFiles=prxChange("s/\s*(\|)\s*/$1/",-1,strip(includeFiles));
            if prxmatch("/^("||strip(includeFiles)||")$/i", cats(logname));
         run;
      %end;

      * exclude files using excludeFiles= argument if specified;
      %if "%superQ(excludeFiles)"^="" %then %do;
         %if %bquote(%substr(&excludeFiles, %length(&excludeFiles)))="&splitChar" %then %let excludeFiles=%substr(&excludeFiles, 1, %eval(%length(&excludeFiles)-1));;
         %if %index(&excludeFiles, &splitChar) %then %let excludeFiles=%sysfunc(tranwrd(&excludeFiles, &splitChar, |));;
         data &glsr_templib..set_logs;
            set &glsr_templib..set_logs;
            length excludeFiles $32676;
            drop excludeFiles;
            excludeFiles=symGet("excludeFiles");
            excludeFiles=prxChange("s/\s*(\|)\s*/$1/",-1,strip(excludeFiles));
            if not prxmatch("/^("||strip(excludeFiles)||")$/i", cats(logname));
         run;
      %end;

      data &glsr_templib..set_logs;
         set &glsr_templib..set_logs (drop=logname); 
      run;
   
      * load log file names into macro variables;
      %let glsr_logfiles=0;
      data _null_;
         set &glsr_templib..set_logs (where=(not(index(logfile,'log not found'))));
         call symput ('glsr_logfile'||trim(left(put(_n_,best.))),trim(left(logfile)));
         call symput ('glsr_logfiles',trim(left(put(_n_,best.))));
      run;

      * load any empty directories into dataset;
      data &glsr_templib..emptydir (keep=dir);
         set &glsr_templib..set_logs (where=(index(logfile,'log not found')));
         length dir $1024;
         dir=tranwrd(logfile,'*.log not found','');
      run;
      proc sort data=&glsr_templib..emptydir nodupkey; by dir; run;
      %let glsr_emptydir=0;
      data _null_;
         set &glsr_templib..emptydir;
         call symput ('glsr_emptydir',trim(left(put(_n_,best.))));
      run;

   %end;

   %else %if %lowcase("&SelectScan")="directory" %then %do;
   *******************************************************************************************;
   * directory scan;
   *******************************************************************************************;
     
      %if "&pathsIn" ne "" and "&pathIn" ne "" %then %do;
         %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as both pathIn and pathsIn are specified.  Only pathsIn should be used
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;      
      %else %if "&pathIn" ne "" %then %do;
         %gmMessage(codeLocation=gmLogScanReport/Parameter checks
          , linesOut=%str(THE PARAMETER pathIn IS DEPRECIATED, NO LONGER USED AND ONLY KEPT FOR BACKWARD COMPATIBILITY
            @ PLEASE REPLACE WITH pathsIn.)
          , selectType=NOTE
          );
          %if "&pathsIn"="" %then %let pathsIn=&pathIn;
      %end;
      %if "&pathsIn"="" %then %do;
         %gmMessage(codeLocation=gmLogScanReport/ABORT
          , linesOut=Macro aborted as pathsIn not specified.
          , selectType=ABORT
          , printStdOut=1
          , sendEmail=&sendEmail
          );
      %end;
      %else %do; 

         * pick out directories from pathsIn=;
         data &glsr_templib..dirlst01;
            length DIR $1024;
            I=1;
            do while(scan("&pathsIn", I, "&splitChar") ne "");
               dir=cats(scan("&pathsIn", I, "&splitChar"))||"/";
               *Remove repeating slashes;
               dir=prxchange("s#/+#/#", -1, dir);
               *Symbolic link path;
               dir=prxchange("s#^(/project\d+/)#/projects/#", -1, cats(dir));
               I+1;
               output;
         end;
         drop I;
         proc sort nodupkey;
            by DIR;
         run;
         %let glsr_dirtot=0;
         data _null_;
            set &glsr_templib..dirlst01 end=eod;
            call symputx("glsr_dir"||cats(_N_), dir, "L");
            if eod then call symputx("glsr_dirtot", _N_);
         run;
      
          * loop for each path;
         %do glsr_dirnum=1 %to &glsr_dirtot; 

            filename glsr_loc "&&glsr_dir&glsr_dirnum";
            %let glsr_dexist=0;
            data _null_;
               call symput ('glsr_dexist',trim(left(put(fexist('glsr_loc'),best.))));
            run;

            %if &glsr_dexist ne 1 %then %do; 
               %gmMessage(codeLocation=gmLogScanReport/ABORT
               , linesOut=Macro aborted as one or more directories specified in pathsIn does not exist.
               , selectType=ABORT
               , printStdOut=1
               , sendEmail=&sendEmail
               );
            %end;
            %else %do;

               data &glsr_templib..dir_in;
                  length dir $1024;
                  dir="&&glsr_dir&glsr_dirnum";
                  * change multiple // to single /;
                  dir=prxChange("s/\/{2,}/\//",-1,dir);

                  if substr(trim(left(dir)),length(trim(left(dir))),1)='/' then dir=substr(dir,1,length(trim(left(dir)))-1);
               run;

               data &glsr_templib..dir01;
                  set &glsr_templib..dir_in %if %sysfunc(exist(&glsr_templib..dir01)) %then %do; &glsr_templib..dir01 %end; ;
               run;

               * pick up subDirectories if subDir=1;
               %if &subDir=1 %then %do;
                  filename glsr_sub pipe "ls -R &&glsr_dir&glsr_dirnum | grep ':' |sed 's/://'";
                  data &glsr_templib..dir02;
                     infile glsr_sub pad missover lrecl=1024;
                     length dir $1024;
                     input dir 1-1024;
                  run;
                  data &glsr_templib..dir01;
                     set &glsr_templib..dir02 &glsr_templib..dir01;
                     * update /project99 to /projects if required;
                     if dir=:'/project' and not(dir=:'/projects') then do;
                        dir='/projects/'||trim(left(substr(dir,index(substr(dir,2),'/')+2)));
                     end;
                     if substr(trim(left(dir)),length(trim(left(dir))),1) ne '/' then dir=trim(left(dir))||'/';
                  run;
               %end;
               %else %if &subdir ne 0 %then %do;
                  %gmMessage(codeLocation=gmLogScanReport/ABORT
                   , linesOut=Macro aborted as subDir value missing or invalid.
                   , selectType=ABORT
                   , printStdOut=1
                   , sendEmail=&sendEmail
                   );
               %end;
           %end;

        %end;
        * end of loop for each paths;

        * exclude any dirs specified in excludeDirs= argument;
        %if "%superQ(excludeDirs)"^="" %then %do;
           %if %bquote(%substr(&excludeDirs, %length(&excludeDirs)))="&splitChar" %then 
              %let excludeDirs=%substr(&excludeDirs, 1, %eval(%length(&excludeDirs)-1));;
           data &glsr_templib..exclude01 (drop=i);
              length DIR $1024;
              I=1;
              do while(scan("&excludeDirs", I, "&splitChar") ne "");
                  DIR=cats(scan("&excludeDirs", I, "&splitChar"));
                  /* Remove repeating slashes */
                  DIR=prxchange("s#/+#/#", -1, DIR);
                  /* Symbolic link path*/
                  DIR=prxchange("s#^(/project\d+/)#/projects/#", -1, cats(DIR));
                  I+1;
                  output;
              end;
           run;
           %let glsr_mvs=0;
           data _null_;
              set sashelp.vmacro (where=(substr(name,1,1)='_' and index(value,"/&_project") and not(index(value,'.sas'))));
              call symput ('glsr_mv_name'||cats(put(_n_,best.)),cats(name));
              call symput ('glsr_mv_value'||cats(put(_n_,best.)),cats(value));
              call symput ('glsr_mvs',cats(put(_n_,best.)));
           run;
           * replace macro vars (e.g. _PTAB) with paths;
           data &glsr_templib..exclude02;
              set &glsr_templib..exclude01;
              %if &glsr_mvs ne 0 %then %do;
                 %do glsr_i=1 %to &glsr_mvs;
                    if upcase(cats(dir))=upcase(cats("&&glsr_mv_name&glsr_i")) then dir=cats("&&glsr_mv_value&glsr_i");
                    if index(dir,"/&_project") and substr(trim(left(dir)),length(trim(left(dir))),1) ne '/' then dir=trim(left(dir))||'/';
                 %end;
              %end;
           run;
                      
           data _null_;
              set &glsr_templib..exclude02;
              if index(dir,"/&_project") and substr(trim(left(dir)),length(trim(left(dir))),1)='/' then
                 dir="\Q"||trim(left(dir))||"\E";  
              call symput ('glsr_exdir'||trim(left(put(_n_,best.))),trim(left(dir)));
              call symput ('glsr_exdirs',trim(left(put(_n_,best.))));
           run;
           proc sort data=&glsr_templib..dir01; by dir; run;
           %do glsr_d=1 %to &glsr_exdirs;
              data &glsr_templib..dir01;
                 set &glsr_templib..dir01;
                 by dir;
                 if not prxmatch("#^&&glsr_exdir&glsr_d$#i", cats(DIR));
              run;
           %end;

        %end;

        * load directories into macro variables;
        %let glsr_dirs=0;
        data _null_;
           set &glsr_templib..dir01;
           call symput ('glsr_dir'||trim(left(put(_n_,best.))),trim(left(dir)));
           call symput ('glsr_dirs',trim(left(put(_n_,best.))));
        run;
            
        * scan each directory for logs files;
        %if &glsr_dirs ne 0 %then %do;
           %do glsr_d=1 %to &glsr_dirs;
              filename glsr_in pipe "ls -l '&&glsr_dir&glsr_d.'/*.log";
              data &glsr_templib..logs01 (keep=logfile logname);
                 infile glsr_in pad missover lrecl=1024;
                 length logfile inlog logname $1024;
                 input inlog 1-1024;
                 logfile=substr(inlog,index(inlog,'/'));
                 pos=index(logfile,'/');
                 txt=substr(logfile,pos+1);
                 do while (index(txt,'/'));
                    pos=index(txt,'/');
                    txt=substr(txt,pos+1);
                 end;
                 logname=txt;
                 * change multiple // to single /;
                 logfile=prxChange("s/\/{2,}/\//",-1,logfile);
              run;

              * check for invalid log filenames;
              %let glsr_invfile=0;
              data _null_;
                 set &glsr_templib..logs01;
                 if substr(logname,1,1)=' ' then call symput ('glsr_invfile','1');
              run;
              %if &glsr_invfile=1 %then %do;
                   %gmMessage(codeLocation=gmLogScanReport/ABORT
                   , linesOut=Macro aborted as log filename starts with space/s.
                   , selectType=ABORT
                   , printStdOut=1
                   , sendEmail=&sendEmail
                   );
              %end;

              proc sort data=&glsr_templib..logs01; by logfile; run;
              data &glsr_templib..set_logs;
                 set &glsr_templib..logs01 %if &glsr_d ne 1 %then %do; &glsr_templib..set_logs %end; ;
                 by logfile;
              run;
          %end;
        %end;
        %else %do;
           %gmMessage(codeLocation=gmLogScanReport/ABORT
             , linesOut=Macro aborted as no directories selected for scan.
             , selectType=ABORT
             , printStdOut=1
             , sendEmail=&sendEmail
             );
         %end;

         * subset based on includeFiles= argument if specified;
         %if "%superQ(includeFiles)"^="" %then %do;
            %if %bquote(%substr(&includeFiles, %length(&includeFiles)))="&splitChar" %then 
               %let includeFiles=%substr(&includeFiles, 1, %eval(%length(&includeFiles)-1));;
            %if %index(&includeFiles, &splitChar) %then %let includeFiles=%sysfunc(tranwrd(&includeFiles, &splitChar, |));;
            data &glsr_templib..set_logs;
               set &glsr_templib..set_logs;
               length includeFiles $32676;
               drop includeFiles;
               includeFiles=symGet("includeFiles");
               includeFiles=prxChange("s/\s*(\|)\s*/$1/",-1,strip(includeFiles));
               if prxmatch("/^("||strip(includeFiles)||")$/i", cats(logname));
            run;
         %end;

         * exclude files using excludeFiles= argument if specified;
         %if "%superQ(excludeFiles)"^="" %then %do;
            %if %bquote(%substr(&excludeFiles, %length(&excludeFiles)))="&splitChar" %then 
               %let excludeFiles=%substr(&excludeFiles, 1, %eval(%length(&excludeFiles)-1));;
            %if %index(&excludeFiles, &splitChar) %then %let excludeFiles=%sysfunc(tranwrd(&excludeFiles, &splitChar, |));;
            data &glsr_templib..set_logs;
               set &glsr_templib..set_logs;
               length excludeFiles $32676;
               drop excludeFiles;
               excludeFiles=symGet("excludeFiles");
               excludeFiles=prxChange("s/\s*(\|)\s*/$1/",-1,strip(excludeFiles));
               if not prxmatch("/^("||strip(excludeFiles)||")$/i", cats(logname));
            run;
         %end;

         * load log file names into macro variables;
         %let glsr_logfiles=0;
         data _null_;
            set &glsr_templib..set_logs (where=(not(index(logfile,'log not found'))));
            call symput ('glsr_logfile'||trim(left(put(_n_,best.))),trim(left(logfile)));
            call symput ('glsr_logfiles',trim(left(put(_n_,best.))));
         run;

         data &glsr_templib..set_logs;
            set &glsr_templib..set_logs (drop=logname); 
         run;

         * load empty directories into dataset;
         data &glsr_templib..emptydir (keep=dir);
            set &glsr_templib..set_logs (where=(index(logfile,'log not found')));
            length dir $1024;
            dir=tranwrd(logfile,'*.log not found','');
         run;
         proc sort data=&glsr_templib..emptydir nodupkey; by dir; run;
         %let glsr_emptydir=0;
         data _null_;
            set &glsr_templib..emptydir;
            call symput ('glsr_emptydir',trim(left(put(_n_,best.))));
         run;
      %end;
      
   %end;

   %else %do;
      %gmMessage(codeLocation=gmLogScanReport/ABORT
      , linesOut=Macro aborted as selectScan missing or invalid.
      , selectType=ABORT
      , printStdOut=1
      , sendEmail=&sendEmail
      );
   %end;

   %if &glsr_logfiles ne 0 %then %do;

      *******************************************************************************************;
      * scan logs;
      *******************************************************************************************;

      * check for glsr metadata datasets and try to lock if possible;
      %if %sysfunc(exist(metadata.glsr_sum_&selectList)) %then %do;
         %let glsr_dsid=%sysfunc(open(metadata.glsr_sum_&selectList,i)); 
         * if cannot open then loop and try again;
         %if (&glsr_dsid=0) %then %do;  
            %let glsr_loop=Y;
            %let glsr_it=1;
            %do %while (&glsr_loop=Y);
               data _null_;
                  x=sleep(10,1);
                  %gmMessage(codeLocation=gmLogScanReport/Lock check
                  , linesOut=Attempting to lock metadata datasets - attempt &glsr_it of &lockRetry.
                  , selectType=NOTE
                  );
               run;
               %let glsr_dsid=%sysfunc(open(metadata.glsr_sum_&selectList,i)); 
               %if (&glsr_dsid=0) %then %do;  
                  data _null_;
                     call symput ('glsr_it',trim(left(put(&glsr_it+1,best.))));
                  run;
                  %if &glsr_it=&lockRetry %then %let glsr_loop=N;
               %end;
               %else %let glsr_loop=N;
            %end;
            %if &glsr_dsid=0 %then %do;
               * cannot lock datasets;
               * attempt lock to get error containing process id;
               lock metadata.glsr_sum_&selectList;
               %let glsr_err=%superQ(sysErrorText);
               lock metadata.glsr_sum_&selectList clear;
               %gmMessage(codeLocation=gmLogScanReport/ABORT
                  , linesOut=Macro aborted as metadata locked. %qLeft(&glsr_err)
                  , selectType=ABORT
                  , sendEmail=&sendEmail
                  , printStdOut=1
               );
            %end;
            %else %do;
               * datasets not locked by other user - apply lock;
               lock metadata.glsr_sum_&selectList;
               %if %sysfunc(exist(metadata.glsr_text_&selectList)) %then %do; lock metadata.glsr_text_&selectList; %end;
               %if %sysfunc(exist(metadata.glsr_issue_&selectList)) %then %do; lock metadata.glsr_issue_&selectList; %end;
               %let glsr_rc=%sysfunc(close(&glsr_dsid)); 
               %let glsr_lockapplied=1;
               %gmMessage(codeLocation=gmLogScanReport/Execution
                  , linesOut=Metadata datasets locked successfully - log scanning in progress.
                  , selectType=NOTE                 
               );
            %end;
         %end;
         %else %do;
            * datasets not locked by other user - apply lock;
               lock metadata.glsr_sum_&selectList;
               %if %sysfunc(exist(metadata.glsr_text_&selectList)) %then %do; lock metadata.glsr_text_&selectList; %end;
               %if %sysfunc(exist(metadata.glsr_issue_&selectList)) %then %do; lock metadata.glsr_issue_&selectList; %end;
               %let glsr_rc=%sysfunc(close(&glsr_dsid)); 
               %let glsr_lockapplied=1;
               %gmMessage(codeLocation=gmLogScanReport/Execution
                  , linesOut=Metadata datasets locked successfully - log scanning in progress.
                  , selectType=NOTE
               );
         %end;
      %end;
      %else %do;
         %gmMessage(codeLocation=gmLogScanReport/Execution
             , linesOut=Metadata datasets not yet created - log scanning in progress.
             , selectType=NOTE
          );
          %let glsr_lockapplied=0;
      %end;

      * refresh (delete) metadata datasets if required;
      %if &glsr_refresh=1 and &glsr_datasets ne 0 %then %do;
         %gmMessage(codeLocation=gmLogScanReport/Execution
            , linesOut=Metadata refresh required.  Deleting all glsr_ datasets.
            , selectType=NOTE
            , printStdOut=&printStdOut
         );
         proc datasets memtype=data library=metadata nolist; 
            delete %do glsr_i=1 %to &glsr_datasets; &&glsr_dataset&glsr_i %end;;
         quit;
      %end;

      * check if data from previous scans if available - if it is then retain and dont re-scan;
      * (if data exists check log modification date/time and whitelist version havent changed);
      %if %sysfunc(exist(metadata.glsr_sum_&selectList)) %then %do;
         %do glsr_lf=1 %to &glsr_logfiles;
            * set glsr_comp as follows;
            * 0=log needs to be scanned (no details found);
            * 1=log scanned already, no re-scan needed;
            * 2=log needs to be re-scanned as updated;
            * 3=log needs to be re-scanned as no detail captured in previous scan;
            %let glsr_comp=0;
            %let glsr_logDetail=0;
            data _null_;
               set metadata.glsr_sum_&selectList (where=(log=trim(left("%superQ(glsr_logfile&glsr_lf)"))));
               %if &selectList=white %then %do; if wldate="&glsr_wldate" 
                  %if "&glsr_mg_customWhiteList" ne "" %then %do; and wlname="&glsr_mg_customWhiteList" %end; 
                  %else %do; and wlname="standard" %end; then 
                  call symput ('glsr_comp','1'); %end;
               %else %do; call symput ('glsr_comp','1'); %end;
               call symput ('glsr_modt',trim(left(recdate)));
               call symput ('glsr_logDetail',trim(left(logDetail)));
            run;
            %if &glsr_comp=1 %then %do;
               filename glsr_log "%superQ(glsr_logfile&glsr_lf)";
               data _null_;
                  set sashelp.vextfl (where=(fileref='GLSR_LOG'));
                  if (put(modate,is8601dt.) ne "&glsr_modt") then
                     call symput ('glsr_comp','2');
               run;
               %if &logDetail=1 and &glsr_logDetail=0 %then %do;
                  %let glsr_comp=3;
               %end;
            %end;
            %let glsr_logchk_&glsr_lf=&glsr_comp;

            * remove old scan data from permanent datasets;
            %if &glsr_comp=0 or &glsr_comp=2 or &glsr_comp=3 %then %do;
               data metadata.glsr_sum_&selectList (compress=yes);
                  set metadata.glsr_sum_&selectList (where=(log ne trim(left("%superQ(glsr_logfile&glsr_lf)"))));
               run;
               %if %sysfunc(exist(metadata.glsr_text_&selectList)) %then %do;
                  data metadata.glsr_text_&selectList (compress=yes);
                     set metadata.glsr_text_&selectList (where=(log ne trim(left("%superQ(glsr_logfile&glsr_lf)"))));
                  run;
               %end;
               %if %sysfunc(exist(metadata.glsr_issue_&selectList)) %then %do;
                  data metadata.glsr_issue_&selectList (compress=yes);
                     set metadata.glsr_issue_&selectList (where=(log ne trim(left("%superQ(glsr_logfile&glsr_lf)"))));
                  run;
               %end;
            %end;

         %end;
      %end;
      %else %do;
         %do glsr_lf=1 %to &glsr_logfiles;
            %let glsr_logchk_&glsr_lf=0;
         %end;
      %end;

      * loop for each log file;
      %do glsr_lf=1 %to &glsr_logfiles;

         * check if log exists;
         filename glsr_log "%superQ(glsr_logfile&glsr_lf)";
         %if %sysFunc(fexist(glsr_log)) %then %do;

            * if data already exists from previous scan dont re-scan;
            %if &&glsr_logchk_&glsr_lf=1 %then %do;
               %gmMessage(codeLocation=gmLogScanReport/re-scan check
               , linesOut=Not re-scanning %superQ(glsr_logfile&glsr_lf) as data already available.
               );
            %end;
            %else %do;

               * read content of log file into logchk dataset ready for scan;
               data &glsr_templib..logchk;
                  infile glsr_log length=reclen pad missover end=eof;
                  input @1 logtext $varying256. reclen;
               run;
               
               * if error reading log file then create empty logchk dataset;
               %if &syserr ne 0 %then %do;
                  data &glsr_templib..logchk;
                     length logtext $256;
                     logtext='';
                  run;
               %end;

               * run log scan using gmLogScanCore macro;
               %gmlogscancore (dataIn=&glsr_templib..logchk, selectList=&selectList, dataOut=&glsr_templib..scanout, maxLen=&maxLen
                  %if "&glsr_mg_customWhiteList" ne "" %then %do; ,customWhiteListIn=&glsr_mg_customWhiteList %end; );

               data &glsr_templib..scanout (drop=listType);
                  set &glsr_templib..scanout;
                  length log $1024;
                  log=trim(left("%superQ(glsr_logfile&glsr_lf)"));
               run;

               * add name and modification date/time of log file to scan results dataset;
               filename glsr_log "%superQ(glsr_logfile&glsr_lf)";
               data &glsr_templib..logfile03 (keep=log recdate);
                  set sashelp.vextfl (where=(fileref='GLSR_LOG'));
                  length log $1024 recdate $20;
                  log=trim(left("%superQ(glsr_logfile&glsr_lf)"));
                  recdate=put(modate,is8601dt.);
               run;
               data &glsr_templib..scanout02 (drop=logTextUnited);
                  merge &glsr_templib..scanout &glsr_templib..logfile03;
                  by log;
               run;

               * append scan results to alllogs datasets and reset detail flag;
               data &glsr_templib..alllogs01 (drop=pos txt);
                  set &glsr_templib..scanout02
                  %if %sysfunc(exist(&glsr_templib..alllogs01)) %then %do; &glsr_templib..alllogs01 %end;;
                  if log=trim(left("%superQ(glsr_logfile&glsr_lf)")) then logDetail="&logDetail";
                  length txt logfile $1024;
                  pos=index(log,'/');
                  txt=substr(log,pos+1);
                  do while (index(txt,'/'));
                     pos=index(txt,'/');
                     txt=substr(txt,pos+1);
                  end;
                  logfile=txt;
               run;

               * select rows from log file surrounding each error (if logDetail=1) *;
               %if &logDetail=1 %then %do;
                  proc sort data=&glsr_templib..scanout
                     (where=(type ne 'No errors found.' and risk ne 'Data Issue'))
                     out=&glsr_templib..lines01 (keep=linenum risk) nodupkey;
                     by linenum risk;
                  run;
                  %let glsr_lines=0;
                  data _null_;
                     set &glsr_templib..lines01 (where=(linenum ne .));
                     call symput ('glsr_line'||trim(left(put(_n_,best.))),trim(left(put(linenum,best.))));
                     call symput ('glsr_risk'||trim(left(put(_n_,best.))),trim(left(risk)));
                     call symput ('glsr_lines',trim(left(put(_n_,best.))));
                  run;
                  data &glsr_templib..logchk02 (where=(list='Y'));
                     set &glsr_templib..logchk;
                     length mark $50;
                     mark='';
                     list='';
                     %if &glsr_lines ne 0 %then %do;
                        %do glsr_ln=1 %to &glsr_lines; if _n_=&&glsr_line&glsr_ln then mark="&&glsr_risk&glsr_ln"; %end;
                        %do glsr_ln=1 %to &glsr_lines; if _n_ >= &&glsr_line&glsr_ln -10 and _n_ <= &&glsr_line&glsr_ln +5 then list='Y'; %end;
                     %end;
                     linenum=_n_;
                  run;
                  data &glsr_templib..logchk03 (drop=lastline);
                     set &glsr_templib..logchk02;
                     by linenum;
                     length log $1024;
                     log=trim(left("%superQ(glsr_logfile&glsr_lf)"));
                     retain lastline;
                     dum=1;
                     if _n_=1 then do;
                        page=1;
                        n=0;
                     end;
                     n+1;
                     if lastline ne linenum-1 and lastline ne . then do;
                        page+1;
                        n=1;
                     end;
                     output;
                     lastline=linenum;
                  run;
                  data &glsr_templib..alltext01;
                     set &glsr_templib..logchk03 %if %sysfunc(exist(&glsr_templib..alltext01)) %then %do; &glsr_templib..alltext01 %end;;
                     by log page n;
                  run;
               %end;

               * create dataset of data issue lines;
               proc sort data=&glsr_templib..scanout
                  (where=(type ne 'No errors found.' and risk='Data Issue'))
                  out=&glsr_templib..issue01 (keep=linenum risk logTextUnited) nodupkey;
                  by linenum risk logTextUnited;
               run;
               data &glsr_templib..issue02 (keep=logtext mark log n linenum);
                  set &glsr_templib..issue01;
                  length mark $50 log $1024 logtext $&maxlen;
                  log=trim(left("%superQ(glsr_logfile&glsr_lf)"));
                  mark='Data Issue';
                  n=linenum;
                  logtext=logTextUnited;
               run;
               data &glsr_templib..allissue;
                  set &glsr_templib..issue02 %if %sysfunc(exist(&glsr_templib..allissue)) %then %do; &glsr_templib..allissue %end;;
                  by log linenum;
               run;
            %end;

         %end;
         %else %if %lowcase("&SelectScan")="multirun" %then %do;
            data &glsr_templib..missing_log;
               length log $1024;
               log=trim(left("%superQ(glsr_logfile&glsr_lf)"));
            run;
            data &glsr_templib..missing_logs;
               set &glsr_templib..missing_log
               %if %sysfunc(exist(&glsr_templib..missing_logs)) %then %do; &glsr_templib..missing_logs %end;;
            run;
         %end;

      * end of loop for each log file;
      %end;

      * create permanent text dataset and refresh alltext01 dataset;
      %if %sysfunc(exist(&glsr_templib..alltext01)) %then %do; 
         data &glsr_templib..alltext01 (drop=txt pos list);
            set &glsr_templib..alltext01;   
            by log page n;
            length txt logfile $1024;
            pos=index(log,'/');
            txt=substr(log,pos+1);
            do while (index(txt,'/'));
               pos=index(txt,'/');
               txt=substr(txt,pos+1);
            end;
            logfile=txt;
         run;
      %end;
      data metadata.glsr_text_&selectList (compress=yes)
         &glsr_templib..alltext01 (where=(log in ( %do glsr_lf=1 %to &glsr_logfiles; "%superQ(glsr_logfile&glsr_lf)" %end;)));
         set %if %sysfunc(exist(&glsr_templib..alltext01)) %then %do; &glsr_templib..alltext01 %end;
         %if %sysfunc(exist(metadata.glsr_text_&selectList)) %then %do; metadata.glsr_text_&selectList %end;;
      run;

      * create permanent issues dataset and refresh allissue dataset;
      %if %sysfunc(exist(&glsr_templib..allissue)) %then %do; 
         data &glsr_templib..allissue (drop=txt pos);
            set &glsr_templib..allissue;
            by log linenum;
            length txt logfile $1024;
            dum=1;
            pos=index(log,'/');
            txt=substr(log,pos+1);
            do while (index(txt,'/'));
               pos=index(txt,'/');
               txt=substr(txt,pos+1);
            end;
            logfile=txt;
         run;
      %end;
      data metadata.glsr_issue_&selectList (compress=yes)
         &glsr_templib..allissue (where=(log in ( %do glsr_lf=1 %to &glsr_logfiles; "%superQ(glsr_logfile&glsr_lf)" %end;)));
         set %if %sysfunc(exist(&glsr_templib..allissue)) %then %do; &glsr_templib..allissue %end;
         %if %sysfunc(exist(metadata.glsr_issue_&selectList)) %then %do; metadata.glsr_issue_&selectList %end;;
      run;
      * create permanent summary dataset - add in date of whitelist creation (and name if custom), and refresh alllogs01 dataset;
      data metadata.glsr_sum_&selectList (compress=yes)
         &glsr_templib..alllogs01 (where=(log in ( %do glsr_lf=1 %to &glsr_logfiles; "%superQ(glsr_logfile&glsr_lf)" %end;))
            %if "&selectList"="white" %then %do; drop=wldate wlname %end;);
         set %if %sysfunc(exist(&glsr_templib..alllogs01)) %then %do; &glsr_templib..alllogs01 %end;
         %if %sysfunc(exist(metadata.glsr_sum_&selectList)) %then %do; metadata.glsr_sum_&selectList %end;;
         %if "&selectList"="white" %then %do;
            %do glsr_lf=1 %to &glsr_logfiles; if log=trim(left("%superQ(glsr_logfile&glsr_lf)")) then do;
               length wldate $19 wlname $1024;
               wldate="&glsr_wldate";
               %if "&glsr_mg_customWhiteList" ne "" %then %do; wlname="&glsr_mg_customWhiteList"; %end;
               %else %do; wlname='standard'; %end;
            end;
            %end;
         %end;
      run;

      * summary data - derive additional variables for reporting;
      data &glsr_templib..alllogs02 (drop=txt pos);
         set &glsr_templib..alllogs01;
         length txt dir $1024 logfile $1024;
         pos=index(log,'/');
         txt=substr(log,pos+1);
         do while (index(txt,'/'));
            pos=index(txt,'/');
            txt=substr(txt,pos+1);
         end;
         logfile=txt;
         dir=trim(left(substr(log,1,index(log,trim(left(logfile)))-1)));
      run;

      * summary data - count total number of logs in each directory;
      proc sort data=&glsr_templib..alllogs02 (keep=dir) out=&glsr_templib..dir01 nodupkey; by dir; run;
      %let glsr_dirs=0;
      data _null_;
         set &glsr_templib..dir01;
         call symput ('glsr_dir'||trim(left(put(_n_,best.))),trim(left(dir)));
         call symput ('glsr_dirs',trim(left(put(_n_,best.))));
      run;

      %if &glsr_dirs=0 %then %do;
         * remove locks;
         %if &glsr_lockapplied=1 %then %do;
            lock metadata.glsr_sum_&selectList clear;
            %if %sysfunc(exist(metadata.glsr_text_&selectList)) %then %do; lock metadata.glsr_text_&selectList clear; %end;
            %if %sysfunc(exist(metadata.glsr_issue_&selectList)) %then %do; lock metadata.glsr_issue_&selectList clear; %end;
         %end;
          %gmMessage(codeLocation=gmLogScanReport/ABORT
               , linesOut=Macro aborted as no directories selected for scan.
               , selectType=ABORT
               , printStdOut=1
               , sendEmail=&sendEmail
          );
      %end;

      %do glsr_d=1 %to &glsr_dirs;
          filename glsr_cnt pipe "ls -l '&&glsr_dir&glsr_d' ";
          data &glsr_templib..dirs01 (keep=dir totlogs);
             length dir $1024;
             dir="&&glsr_dir&glsr_d";
             infile glsr_cnt length=reclen end=eof lrecl=512;
             input @1 record $varying512. reclen;
             if index(record,"&&glsr_dir&glsr_d") then totlogs=0;
             if index(record,'.log')=length(record)-3 and index(record,'log not found')=0 then totlogs+1;
             if eof then output;
          run;
          data &glsr_templib..alldirs;
             set &glsr_templib..dirs01 %if &glsr_d ne 1 %then %do; &glsr_templib..alldirs %end;;
             by dir;
          run;
      %end;
      proc sort data=&glsr_templib..alllogs02; by dir log; run;
      data &glsr_templib..alllogs03;
         merge &glsr_templib..alllogs02 &glsr_templib..alldirs;
         by dir;
         if risk='Empty Log' then ord=1;
         else if risk='ERROR-like Condition' then ord=3;
         else if risk='Data Issue' then ord=6;
         else if risk='Check Manually' then ord=4;
         else if risk='Unassessed' then ord=5;
         else if risk='High Risk' then ord=2;
         else if risk='No Risk' then ord=7;
         else if risk ne'' then ord=1;
      run;

      *******************************************************************************************;
      * create dataset for report part 1 - summary of logs scanned;
      *******************************************************************************************;
      proc sort data=&glsr_templib..alllogs03; by dir log; run;
      data &glsr_templib..sum01_in (keep=dir totlogs scanned scannedp clean sissuesp dissues dissuesp totlogsc drisk_color);
         set &glsr_templib..alllogs03;
         by dir log;
         length scannedp sissuesp dissuesp $12 totlogsc $4;
         retain log_clean log_dissue risk_color drisk_color;
         if first.dir then do;
            scanned=0;
            clean=0;
            dissues=0;
            drisk_color='';
         end;
         if first.log then do;
            scanned+1;
            log_clean=1;
            log_dissue=0;
            risk_color='G';
         end;
         if risk='Data Issue' then log_dissue=1;
         else if risk ne '' then do;
            log_clean=0;
            if risk in ('ERROR-like Condition', 'High Risk' ' Empty Log') then risk_color='R';
            else if risk_color='G' then risk_color='Y';
         end;
         if last.log then do;
            if log_dissue=1 then dissues+1;
            if log_clean=1 then clean+1;
            if drisk_color='' and risk_color ne '' then drisk_color=risk_color;
            else if drisk_color='G' and risk_color in ('Y' 'R') then drisk_color=risk_color;
            else if drisk_color='Y' and risk_color='R' then drisk_color=risk_color;
         end;
         if last.dir then do;
            if scanned=0 then 
               scannedp=put(scanned,4.);
            else
               scannedp=put(scanned,4.)||' ('||put(round((scanned/totlogs)*100,1),3.)||'%)';
            if clean=scanned then    
               sissuesp=put(scanned-clean,4.);
            else
               sissuesp=put(scanned-clean,4.)||' ('||put(round(((scanned-clean)/scanned)*100,1),3.)||'%)';
            if dissues=0 then    
               dissuesp=put(dissues,4.);
            else
               dissuesp=put(dissues,4.)||' ('||put(round((dissues/scanned)*100,1),3.)||'%)';
            totlogsc=put(totlogs,4.);
            output;
         end;
      run;
      data &glsr_templib..sum01;
         set &glsr_templib..sum01_in %if &glsr_emptydir ne 0 %then %do; &glsr_templib..emptydir %end;;
         dum=1;
         if scannedp='' then scannedp='   0';
         if sissuesp='' then sissuesp='   0';
         if dissuesp='' then dissuesp='   0';
         if totlogsc='' then totlogsc='   0';
      run;
      proc sort data=&glsr_templib..sum01; by dir; run;

      *create summary message;
      %if %sysFunc(exist(&glsr_templib..sum01)) %then %do;
         data _null_;
            set &glsr_templib..sum01 end=eof;  
            if _n_=1 then do;
                t_scan=0; t_clean=0; t_dissues=0;
            end;
            t_scan+scanned;
            t_clean+clean;
            t_dissues+dissues;
            if eof then 
               call symput ("glsr_stdoutsum",cats(t_scan)||" logs scanned ["||cats(t_clean)||" clean, "||cats(t_dissues)||" data issues]");
         run;
            
         %gmMessage(codeLocation=gmLogScanReport/Execution
         , linesOut=Log scanning completed - %superQ(glsr_stdoutsum).
         , selectType=NOTE
         , printStdOut=&printStdOut
         );
      %end;

      *******************************************************************************************;
      * create dataset for report part 2 - list of logs scanned;
      *******************************************************************************************;
      proc sort data=&glsr_templib..alllogs03 out=&glsr_templib..list01_in; by dir log ord; run;
      data &glsr_templib..list01 (keep=dum moddate moddatec dir hrisk logfile sissues dissues space);
         set &glsr_templib..list01_in;
         by dir log ord;
         length clean dissues sissues $3 hrisk $30 moddatec $20;
         retain clean dissues hrisk;
         format moddate datetime15.;
         dum=1;
         space='  ';
         if first.log then do;
            clean='Yes';
            hrisk=risk;
            dissues='No';
         end;
         if type ne 'No errors found.' and risk ne 'Data Issue' then clean='No';
         if risk='Data Issue' then dissues='Yes';
         if last.log then do;
            if clean='Yes' then sissues='No';
            else sissues='Yes';
            moddate=input(recdate,is8601dt.);
            moddatec=trim(left(put(datepart(moddate),is8601da.)))||' '||trim(left(put(timepart(moddate),tod8.)));
            output;
         end;
      run;
      proc sort data=&glsr_templib..list01; by dum descending moddate dir logfile; run;
  
      *******************************************************************************************;
      * create dataset for report part 3 - summary (overall);
      *******************************************************************************************;
      proc sort data=&glsr_templib..alllogs03 (where=(type ne 'No errors found.') keep=risk type ord)
         out=&glsr_templib..sum02_in;
         by descending risk type;
      run;
      data &glsr_templib..sum02;
         set &glsr_templib..sum02_in;
         by descending risk type;
         dum=1;
         if first.type then cnt=0;
         cnt+1;
         if last.type;
      run;
      proc sort data=&glsr_templib..sum02; by ord type; run;

      *******************************************************************************************;
      * create dataset for report part 4 - summary (by log);
      *******************************************************************************************;
      proc sort data=&glsr_templib..alllogs03 (where=(type ne 'No errors found.')
         keep=dir logfile ord recdate risk type linenum) out=&glsr_templib..det01_in;
         by dir logfile ord type;
      run;

      data &glsr_templib..det01_in2 (drop=linenum cnt rename=(cntc=cnt));
         set &glsr_templib..det01_in;
         by dir logfile ord type;
         retain linenums;
         length linenums $500 comment $40;
         dum=1;
         comment='';
         if first.type then do;
            cnt=0;
            linenums='';
         end;
         cnt+1;
         if cnt=11 then do;
            linenums=trim(left(linenums))||' <more>';
         end;
         else if cnt<11 then do;
            if cnt=1 then linenums=trim(left(put(linenum,best.)));
            else linenums=trim(left(linenums))||', '||trim(left(put(linenum,best.)));
         end;
         if last.type then do;
            cntc=put(cnt,5.);
            output;
         end;
      run;
      data &glsr_templib..det01_hl (keep=dir logfile hl);
         set &glsr_templib..det01_in2 
         (where=(risk not in  ('Empty Log' 'Data Issue')));
         by dir logfile ord type;
         if last.logfile then do;
            hl='Y';
            output;
         end;
      run;
      data &glsr_templib..det01_in3;
         merge &glsr_templib..det01_in2 &glsr_templib..det01_hl;
         by dir logfile;
      run;
      proc sort data=&glsr_templib..det01_in3; by dir logfile ord type; run;
      data &glsr_templib..det01_in4 (drop=recdate);
         set &glsr_templib..det01_in3;
         by dir logfile ord type;
         length logtime $1024;
         if first.logfile then n=0;
         n+1;
         if n=1 then do;
            if hl='Y' then
               logtime= %if &logDetail=1 %then %do;
               '~S={cellpadding=0pt color=blue}'||
               %end; trim(left(logfile))||'/';
            else logtime=trim(left(logfile))||'/';
         end;
         else if n=2 then logtime=trim(left(put(datepart(input(recdate,is8601dt.)),is8601da.)))||' '||trim(left(put(timepart(input(recdate,is8601dt.)),tod8.)));

         if first.logfile and last.logfile then do;
            output;
            n=2;
            logtime=trim(left(put(datepart(input(recdate,is8601dt.)),is8601da.)))||' '||trim(left(put(timepart(input(recdate,is8601dt.)),tod8.)));
            type='';
            linenums='';
            cnt='';
            output;
         end;
         else output;
      run;

      data &glsr_templib..det01;
         set &glsr_templib..det01_in4;
         %gmModifySplit(var=linenums, width=24, delimiter=~n, selectType=NOTE);
         %gmModifySplit(var=type, width=30, delimiter=~n, selectType=NOTE);
      run;

      * tidy permanent datasets by removing any records relating to logs that no longer exist (multirun and directory scans only);
      %if %lowcase("&SelectScan")="setup" or %lowcase("&SelectScan")="directory" %then %do;
         * Create list of datasets to clean, clean TEXT only if logDetails is 1; 
         %local glsr_tidyList glsr_dset;
         %let glsr_tidyList = sum issue;
         %let glsr_inc = 1;

         %if &logDetail = 1 %then %do;
            %let glsr_tidyList = &glsr_tidyList text;
         %end;

         %do %while(%scan(&glsr_tidyList,&glsr_inc) ne);
            %let glsr_dset=%scan(&glsr_tidyList.,&glsr_inc);
            proc sort data=metadata.glsr_&glsr_dset._&selectList; by log; run;
            data metadata.glsr_&glsr_dset._&selectList (compress=yes);
               merge metadata.glsr_&glsr_dset._&selectList (in=a) &glsr_templib..set_logs (rename=(logfile=log) in=b);
               by log;
               if b then logfound='Y';
               if a;
            run;
            data metadata.glsr_&glsr_dset._&selectList (compress=yes);
               set metadata.glsr_&glsr_dset._&selectList;
               by log;
               length dir $1024;
               dir=tranwrd(log,trim(left(logfile)),'');
            run;
            proc sort data=metadata.glsr_&glsr_dset._&selectList; by dir log; run;
            data metadata.glsr_&glsr_dset._&selectList (compress=yes drop=dir logfound dirscan);
               merge metadata.glsr_&glsr_dset._&selectList (in=a) &glsr_templib..alldirs (keep=dir in=b);
               by dir;
               if b then dirscan='Y';
               if a then do;
                  if dirscan='Y' and logfound ne 'Y' then do;
                     put "NOTE:[PXL] Removing record as log no longer exists " log= linenum=;
                  end;
                  else output;
               end;
            run;
            %let glsr_inc = %eval(&glsr_inc + 1);
         %end;
      %end;

      * remove locks;
      %if &glsr_lockapplied=1 %then %do;
         lock metadata.glsr_sum_&selectList clear;
         %if %sysfunc(exist(metadata.glsr_text_&selectList)) %then %do; lock metadata.glsr_text_&selectList clear; %end;
         %if %sysfunc(exist(metadata.glsr_issue_&selectList)) %then %do; lock metadata.glsr_issue_&selectList clear; %end;
      %end;

      *******************************************************************************************;
      * create ods template;
      *******************************************************************************************;
      ods path work(read) sasuser.templat(update)
         sashelp.tmplmst(read);
      run;

      proc template;
         define style miglogchk /store=work;
         parent=styles.rtf;
         replace fonts /
            "docfont"=("courier new, Monospace –encoding latin1",10pt)
            "headingfont" = ("courier new, Monospace –encoding latin1",10pt)
            "footfont" = ("courier new, Monospace –encoding latin1",10pt)
            "titlefont" = ("courier new, Monospace –encoding latin1",10pt)
            "titlefont2" = ("courier new, Monospace –encoding latin1",10pt)
            "title2font" = ("courier new, Monospace –encoding latin1",10pt)
            "strongfont" = ("courier new, Monospace –encoding latin1",10pt)
            "emphasisfont" = ("courier new, Monospace –encoding latin1",10pt)
            "fixedemphasisfont" = ("courier new, Monospace –encoding latin1",10pt)
            "fixedstrongfont" = ("courier new, Monospace –encoding latin1",10pt)
            "fixedheadingfont" = ("courier new, Monospace –encoding latin1",10pt)
            "batchfixedfont" = ("courier new, Monospace –encoding latin1",10pt)
            "fixedfont" = ("courier new, Monospace –encoding latin1",10pt)
            "headingemphasisfont" = ("courier new, Monospace –encoding latin1",10pt);
         style table from container /
            frame=hsides
            rules=groups
            cellpadding=0pt
            cellspacing=0pt
            borderwidth=0.4pt
            asis=on
            linkcolor=_undef_;
         style body from document /
             bottommargin=.5in
             topmargin=.5in
             rightmargin=.5in
             leftmargin=.5in
             font_face = "Courier New, Courier, Monospace –encoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style header from headersandfooters /
             protectspecialchars=off
             just=center
             font_face = "Courier New, Courier, Monospace –encoding latin1"
             font_size = 10pt;
         style systemFooter /
             font_face = "Courier New, Courier, Monospace –encoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style systemTitle /
             font_face = "Courier New, Courier, Monospace –encoding latin1"
             font_size = 10pt;
         style Data /
             font_face = "Courier New, Courier, Monospace –encoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style systitleandfootercontainer from container/
             asis=on
             linkcolor=_undef_;
         style data from container/
             asis=on
             linkcolor=_undef_;
         end;
      run;

      *******************************************************************************************;
      * create report;
      *******************************************************************************************;

      * delete current output file if exists;
      %if %sysFunc(fexist(glsr_rep)) %then %do;
         data _null_;
            x=fdelete('glsr_rep');
         run;
      %end;

      ods escapechar = "~";
      ods listing close;
      goptions device=actximg;

      %let glsr_papersz=letter;
      options nodate nonumber nobyline orientation=landscape papersize=&glsr_papersz;

      ods pdf file=glsr_rep style=miglogchk pdftoc=1 uniform;

      *******************************************************************************************;
      * create report - part 1 - summmary of logs scanned;
      *******************************************************************************************;
      %let glsr_ml_cnt=0;
      %if %sysfunc(exist(&glsr_templib..missing_logs)) %then %do;
         data _null_;
            set &glsr_templib..missing_logs;
            call symput ('glsr_ml_'||trim(left(put(_n_,best.))),trim(left(log)));
            call symput ('glsr_ml_cnt',trim(left(put(_n_,best.))));
         run;
         %if &glsr_ml_cnt ne 0 %then %do;
            data _null_;
               put 'NOTE:[PXL] The following logs relating to programs listed in multirun file were not found:';
               %do glsr_ml_i=1 %to &glsr_ml_cnt;
                  put "NOTE:[PXL] &&glsr_ml_&glsr_ml_i";
               %end;
            run;
         %end;
      %end;
      title1 "Logcheck Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.))) EST [Executed by %gmGetUserName]";
      %if "&selectList"="white" %then %do;
         %if "&glsr_mg_customWhiteList" ne "" %then %do; 
            title2 "Summary of Logs Scanned Using gmLogScanCore Custom %sysfunc(propcase(&selectList))list [created &glsr_wldate]";
            title3 "[&glsr_mg_customWhiteList]";
         %end;
         %else %do;
            title2 "Summary of Logs Scanned Using gmLogScanCore Standard %sysfunc(propcase(&selectList))list [created &glsr_wldate]";
         %end;
      %end;
      %else %do;
         title2 "Summary of Logs Scanned Using gmLogScanCore %sysfunc(propcase(&selectList))list";
      %end;

      %if %lowcase("&SelectScan")="multirun" %then %do;
         title4 "Log Selection Method: Multirun File [&fileMult.]";
      %end;
      %else %if %lowcase("&SelectScan")="setup" %then %do;
         title4 "Log Selection Method: Setup File [&_projpre]";
      %end;
      %else %if %lowcase("&SelectScan")="directory" %then %do;
         %if &subDir=1 %then %do;
            title4 "Log Selection Method: Directory/Sub-Directories";
         %end;
         %else %do;
            title4 "Log Selection Method: Directory";
         %end;
      %end;
      footnote1 j=c "Page ~{thispage} of ~{lastpage}";
      ods proclabel 'Summary of Logs Scanned';
      proc report data=&glsr_templib..sum01 nowd headline headskip missing spacing=2 split="@" contents='';
         column dum dir totlogs totlogsc scanned clean scannedp drisk_color sissuesp dissuesp;
         define dum /order noprint;
         define dir /order order=data style={cellwidth=50% just=l} "Directory";
         define totlogs /order noprint;
         define totlogsc / style={cellwidth=10% just=l} "Logs in@Directory";
         define scanned /order noprint;
         define clean /order noprint;
         define scannedp / style={cellwidth=12% just=l} "Logs Scanned";
         define drisk_color /order noprint;
         define sissuesp / style={cellwidth=12% just=l} "Code Issues";
         define dissuesp / style={cellwidth=12% just=l} "Data Issues";

         break before dum / contents='' page;

         %if &glsr_ml_cnt ne 0 %then %do;
            compute after dum;
               line @1 "";
               line @1 "~S={color=red} NOTE: The following logs relating to programs listed in multirun file were not found: ";
               %do glsr_ml_i=1 %to &glsr_ml_cnt;
                  line @4 "&&glsr_ml_&glsr_ml_i";
               %end;
               line @1 "";
            endcomp;
         %end;

         compute scannedp;
            if scanned=totlogs then
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightgreen]");
            else if scanned ne totlogs then
               call define(_COL_, "style", "STYLE=[BACKGROUND=yellow]");
         endcomp;

         compute sissuesp;
            if scanned=clean then
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightgreen]");
            else if scanned ne clean then do;
               if drisk_color='Y' then
                  call define(_COL_, "style", "STYLE=[BACKGROUND=yellow]");
               else if drisk_color='R' then
                  call define(_COL_, "style", "STYLE=[BACKGROUND=lightred]");
            end;
         endcomp;

         compute dissuesp;
            if dissuesp='   0' then
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightgreen]");
            else
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightblue]");
         endcomp;
      run;
      *******************************************************************************************;
      * create report - part 2 - list of logs scanned;
      *******************************************************************************************;
      title1 "Logcheck Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.))) EST [Executed by %gmGetUserName]";
      footnote1 j=c "Page ~{thispage} of ~{lastpage}";
      title2 "List of Logs Scanned";

      ods proclabel 'List of Logs Scanned';
      proc report data=&glsr_templib..list01 nowd headline headskip missing spacing=2 split="@" contents='' style(report)={cellpadding=2pt}; 
         column dum moddate moddatec dir space logfile hrisk sissues dissues;
         define dum /order noprint;
         define moddate /order order=data noprint;
         define moddatec /display order=data style={cellwidth=17% just=l} "Creation DateTime";
         define dir /display order=data style={cellwidth=45% just=l} "Directory";
         define space /display order=data style={cellwidth=2% just=l} "";
         define logfile / style={cellwidth=23% just=l} "Log";
         define hrisk / noprint;
         define sissues / style={cellwidth=6% just=l} "Code Issues";
         define dissues / style={cellwidth=6% just=l} "Data Issues";

         break before dum / contents='' page;

         compute sissues;
            if hrisk='ERROR-like Condition' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
            else if hrisk='Data Issue' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightblue]");
            else if hrisk='Check Manually' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
            else if hrisk='Unassessed' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
            else if hrisk='High Risk' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
            else if hrisk='Empty Log' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
            else if hrisk='No Risk' or hrisk='' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightgreen]");
            else
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
         endcomp;
      run;
   
      *******************************************************************************************;
      * create report - part 3 - summmary (overall);
      *******************************************************************************************;
      title1 "Logcheck Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.))) EST [Executed by %gmGetUserName]";
      footnote1 j=c "Page ~{thispage} of ~{lastpage}";
      title2 "Summary of Messages Found in Scan";

      ods proclabel 'Summary (Overall)';
      proc report data=&glsr_templib..sum02 nowd headline headskip missing spacing=2 split="@" contents='';
         column dum ord risk type cnt;
         define dum /order noprint;
         define ord /order noprint;
         define risk /display order=data style={cellwidth=36% just=l} "Message Risk";
         define type /display order=data style={cellwidth=43% just=l} "Message Type";
         define cnt /display style={cellwidth=20% just=l} "Number of Occurences";
         break before dum / contents='' page;

         compute risk;
            if risk='ERROR-like Condition' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
            else if risk='Data Issue' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightblue]");
            else if risk='Check Manually' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
            else if risk='Unassessed' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
            else if risk='High Risk' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
               else if risk='Empty Log' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
            else if risk='No Risk' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=green]");
            else
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
         endcomp;
      run;

      *******************************************************************************************;
      * create report - part 4 - summmary by log;
      *******************************************************************************************;
      proc sort data=&glsr_templib..alllogs03 (keep=dir logfile risk 
         where=(risk not in ('Data Issue' ''))) 
         out=&glsr_templib..logs (drop=risk) nodupkey; 
         by logfile dir; 
      run;
      data &glsr_templib..logs (drop=ver) &glsr_templib..multver01 (keep=logfile multver);
         set &glsr_templib..logs;
         by logfile dir;
         if first.logfile then ver=0;
         ver+1;
         if ver>1 then do;
            multver='Y';
            output &glsr_templib..multver01;
         end;
         if ((not first.logfile) or (not last.logfile)) then do;
            logfile=trim(left(logfile))||' ['||trim(left(put(ver,best.)))||']';
         end;
         output &glsr_templib..logs;
      run;
      proc sort data=&glsr_templib..multver01 nodupkey; by logfile; run;

      proc sort data=&glsr_templib..logs; by logfile dir; run;
      data _null_;
         set &glsr_templib..logs;
         call symput ('glsr_log'||trim(left(put(_n_,best.))),
            compress(prxChange('s/[\(\)<>\[\]\{\}\/%&\\]/_/',-1,tranwrd(trim(left(dir))||trim(left(logfile)),' ','_'))));
         call symput ('glsr_logf'||trim(left(put(_n_,best.))), %if "&logDetail"="1" %then %do;
            '~S={cellpadding=0pt color=blue}'||
         %end; trim(left(logfile))||'/');
         call symput ('glsr_logs',trim(left(put(_n_,best.))));
      run;

      %if "&glsr_logs" ne "" %then %do;
         proc format lib=&glsr_templib;
            value $namelink
            %do glsr_l=1 %to &glsr_logs;
               "%superQ(glsr_logf&glsr_l)"="#%superQ(glsr_log&glsr_l)"
            %end;;
         run;
      %end;

      proc sort data=&glsr_templib..det01; by logfile dir; run;
      data &glsr_templib..det02;
         merge &glsr_templib..det01 (in=a) &glsr_templib..multver01;
         by logfile;
         if a;
      run;

      data &glsr_templib..det03 (drop=ver);
         length typerisk $65;
         set &glsr_templib..det02;
         by logfile dir;
         if first.logfile then ver=0;
         if first.dir and hl='Y' then ver+1;
         if ((not first.logfile) or (not last.logfile)) and n=1 and multver='Y' and hl='Y' then do;
            logtime=tranwrd(logtime,trim(left(logfile)),trim(left(logfile))||' ['||trim(left(put(ver,best.)))||']');
         end;
         if type ne '' and risk ne '' then typerisk=trim(left(type))||' ('||trim(left(risk))||')';
         else typerisk=type;
      run;
      proc sort data=&glsr_templib..det03; by dum dir logfile n logtime risk; run;

      *set page var to try and avoid splitting log summary across pages;
      data &glsr_templib..paging01 (keep=dum dir logfile n linereq);
         set &glsr_templib..det03;
         by dum dir logfile n logtime risk; 
         retain start;
         if _n_=1 then line=0;
         line+1;
         startline=line;
         if first.dir then line+2;
         if first.logfile then line+1;
         if length(typerisk)>32 then line+1;
         if length(linenums)>25 then line+1;
         if length(linenums)>50 then line+1;
         endline=line;
         if first.logfile then start=startline;
         if last.logfile then do;
            linereq=(endline-start)+1;
            output;
         end;
      run;
      data &glsr_templib..paging02 (keep=dum dir logfile page);
         set &glsr_templib..paging01;
         by dum dir logfile n;
         if _n_=1 then do;
            page=1;
            used=0;
         end;
         if used=0 or used+linereq<=39 then do;
            used+linereq;
         end;
         else do;
            page+1;
            used=0;
            used+linereq;
         end;
      run;
      data &glsr_templib..det04;
         merge &glsr_templib..det03 &glsr_templib..paging02;
         by dum dir logfile;
      run;      
      proc sort data=&glsr_templib..det04; by dum dir logfile n logtime risk; run;

      title1 "Logcheck Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.))) EST [Executed by %gmGetUserName]";
      footnote1 j=c "Page ~{thispage} of ~{lastpage}";
      title2 "Details of Messages Found in Scan";

      options missing='';
      ods pdf anchor='summary';
      ods proclabel 'Summary (By Log)';
      proc report data=&glsr_templib..det04 nowd headline headskip missing spacing=2 split='@' contents='';
         column dum page dir logfile n logtime risk typerisk cnt linenums comment outdir;
         define dum /order noprint;
         define page /order noprint;
         define dir /order noprint;
         define logfile /order noprint;
         define n /order noprint;
         define logtime /order order=data style={cellwidth=31% just=l
         %if &logDetail=1 %then %do; %if "&glsr_logs" ne "" %then %do; url=$namelink. %end; linkcolor=lightgrey %end; 
            } "Log File/@Creation DateTime";
         define risk /order noprint;
         define typerisk /display order=data style={cellwidth=28% just=l} "Message Type (Risk)";
         define cnt /display style={cellwidth=10% just=l} "Number of Occurences";
         define linenums /display style={cellwidth=20% just=l} "Found on Line Numbers";
         define comment /display style={cellwidth=10% just=l} "Comments";
         define outdir /noprint;

         break after page /page;
         
         compute logtime;
            call define(_COL_, "style", "STYLE=[BACKGROUND=lightgrey linkcolor=_undef_]");
         endcomp;

         %macro format (var=);
            compute &var;
               if risk='ERROR-like Condition' then
               call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
               else if risk='Data Issue' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightblue]");
               else if risk='Check Manually' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
               else if risk='Unassessed' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
               else if risk='High Risk' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
               else if risk='Empty Log' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
               else if risk='No Risk' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=green]");
               else
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
            endcomp;
         %mend format;
         %format (var=typerisk);
         %format (var=cnt);
         %format (var=linenums);
         %format (var=comment);

         break before dum / contents='' page;

         compute before dir;
            line @1 '~S={font_face="Courier New, Courier, Monospace –encoding latin1" font_size = 10pt}Directory: ' dir $200.;
            line "";
         endcomp;

         compute after logfile;
            line "";
         endcomp;
      run;

      *******************************************************************************************;
      * create report - part 5 - lines of text from logs with errors (if required);
      *******************************************************************************************;
      %if &logDetail=1 %then %do;
         %let glsr_out=0;
         data _null_;
            set &glsr_templib..alltext01;
            call symput ('glsr_out',trim(left(put(_n_,best.))));
         run;
         %if &glsr_out ne 0 %then %do;
            proc sql;
                create table &glsr_templib..alltext02 as
                select a.*,b.multver
                from &glsr_templib..alltext01 a
                left join &glsr_templib..multver01 b
                on a.logfile=b.logfile
                order by logfile, log, page, n;
            quit;
            data &glsr_templib..alltext03;
               set &glsr_templib..alltext02;
               by logfile log page n;
               if first.logfile then ver=0;
               if first.log then ver+1;
               logname=logfile;
               if multver='Y' then do;
                  log=trim(left(log))||' ['||trim(left(put(ver,best.)))||']';
                  logfile=trim(left(logfile))||' ['||trim(left(put(ver,best.)))||']';
               end;
            run;
            proc sort data=&glsr_templib..alltext03 (keep=logname ver log logfile page) 
               out=&glsr_templib..pages nodupkey; 
               by logname ver log page; 
            run;

            data _null_;
               set &glsr_templib..pages;
               call symput ('glsr_log'||trim(left(put(_n_,best.))),trim(left(log)));
               call symput ('glsr_loga'||trim(left(put(_n_,best.))),compress(prxChange('s/[\(\)<>\[\]\{\}\/%&\\]/_/',-1,tranwrd(trim(left(log)),' ','_'))));
               call symput ('glsr_logf'||trim(left(put(_n_,best.))),trim(left(logfile)));
               call symput ('glsr_page'||trim(left(put(_n_,best.))),trim(left(put(page,best.))));
               call symput ('glsr_pages',trim(left(put(_n_,best.))));
            run;

            %do glsr_p=1 %to &glsr_pages;
               title1 "Logcheck Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.))) EST [Executed by %gmGetUserName]";
               footnote1 link='#summary' '~S={color=blue}Return to Summary (By Log)';
               footnote3 j=c "Page ~{thispage} of ~{lastpage}";
               title2 "Text Found in Scan";
               title4 j=l "Log File: %superQ(glsr_log&glsr_p)";

               ods proclabel "%superQ(glsr_logf&glsr_p) (&&glsr_page&glsr_p)";

               %if "&&glsr_page&glsr_p"="1" %then %do;
                  ods pdf anchor="&&glsr_loga&glsr_p";
               %end;

               proc report data=&glsr_templib..alltext03 (where=(logfile="%superQ(glsr_logf&glsr_p)" and page=&&glsr_page&glsr_p))
                  nowd headline headskip missing spacing=2 split="@" contents='';
                  column dum page n mark linenum logtext;
                  define dum /order noprint;
                  define page /order noprint;
                  define n /order noprint;
                  define mark /order noprint;
                  define linenum /display order=data style={cellwidth=10% just=l} "Line Number";
                  define logtext /display order=data style={cellwidth=89% just=l} "Text from Log";

                  break after page / contents='' page;
                  break before dum / contents='' page;
                  compute mark;
                     if mark='ERROR-like Condition' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
                     else if mark='Data Issue' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=lightblue]");
                     else if mark='Check Manually' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
                     else if mark='Unassessed' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
                     else if mark='High Risk' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
                     else if mark='Empty Log' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
                     else if mark='No Risk' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=green]");
                     else if mark ne '' then
                        call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
                  endcomp;

               run;
            %end;
         %end;
      %end;

      *******************************************************************************************;
      * create report - part 6 - data issues (if required);
      *******************************************************************************************;
      %if &dataIssues=1 %then %do;
         %let glsr_out=0;
         data _null_;
            set &glsr_templib..allissue;
            call symput ('glsr_out',trim(left(put(_n_,best.))));
         run;
         %if &glsr_out ne 0 %then %do;
            title1 "Logcheck Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.))) EST [Executed by %gmGetUserName]";
            footnote1 j=c "Page ~{thispage} of ~{lastpage}";
            title2 "Data Issues";

            ods proclabel "Data Issues";

            proc report data=&glsr_templib..allissue nowd headline headskip missing spacing=2 split="@" contents='';
               column dum log n mark linenum logtext;
               define dum /order noprint;
               define log /order noprint;
               define n /order noprint;
               define mark /order noprint;
               define linenum /display order=data style={cellwidth=10% just=l} "Line Number";
               define logtext /display order=data style={cellwidth=89% just=l} "Text from Log";

               compute before log;
                  line @1 '~S={font_face="Courier New, Courier, Monospace –encoding latin1" font_size = 10pt}Log: ' log $1024.;
               endcomp;
               compute after log;
                  line "";
               endcomp;
               break before dum / contents='' page;
               compute mark;
                  if mark='Data Issue' then
                     call define(_ROW_, "style", "STYLE=[BACKGROUND=lightblue]");
               endcomp;
            run;
         %end;
      %end;

      ods pdf close;
      ods listing;

      *******************************************************************************************;
      * create email if required;
      *******************************************************************************************;
      %if &sendEmail=1 %then %do;

         %local glsr_userEMail;
         %local glsr_userName;
         data _null_;
            infile "~/.forward" lrecl = 256;
            input;
            if prxMatch("/^\S+@\S+$/",strip(_infile_)) then do;
               call symput("glsr_userEMail",strip(_infile_));
               if prxMatch("/^\S+\.\S+@\S+$/",strip(_infile_)) then do;
                   call symput("glsr_userName",strip(prxChange("s/^(\S+?)\..*$/$1/",1,strip(_infile_))));
               end;
            end;
         run;

         filename sendEm eMail
            %if %lowcase("&SelectScan")="multirun" %then %do;
               subject = "gmLogScanReport Summary: Multirun File [&fileMult.]"
            %end;
            %else %if %lowcase("&SelectScan")="setup" %then %do;
               subject = "gmLogScanReport Summary: Setup File [&_projpre]"
            %end;
            %else %if %lowcase("&SelectScan")="directory" %then %do;
               %if &subDir=1 %then %do;
                  subject = "gmLogScanReport Summary: Directory/Sub-Directories"
               %end;
               %else %do;
                  subject = "gmLogScanReport Summary: Directory"
               %end;
            %end;
            from= "&glsr_userEMail."
            to = "&glsr_userEMail."
            ct = "text/html"
         ;

         ods path work(read) sasuser.templat(update)
            sashelp.tmplmst(read);
         run;

         proc template;
            define style glsrmail /store=work;
            parent=styles.default;
            replace fonts /
               "docfont"=("courier new, Monospace –encoding latin1",10pt)
               "headingfont" = ("courier new, Monospace –encoding latin1",10pt,bold roman)
               "titlefont" = ("courier new, Monospace –encoding latin1",10pt)
               "titlefont2" = ("courier new, Monospace –encoding latin1",10pt)
               "title2font" = ("courier new, Monospace –encoding latin1",10pt)
               "strongfont" = ("courier new, Monospace –encoding latin1",10pt)
               "emphasisfont" = ("courier new, Monospace –encoding latin1",10pt)
               "fixedemphasisfont" = ("courier new, Monospace –encoding latin1",10pt)
               "fixedstrongfont" = ("courier new, Monospace –encoding latin1",10pt)
               "fixedheadingfont" = ("courier new, Monospace –encoding latin1",10pt)
               "batchfixedfont" = ("courier new, Monospace –encoding latin1",10pt)
               "fixedfont" = ("courier new, Monospace –encoding latin1",10pt)
               "headingemphasisfont" = ("courier new, Monospace –encoding latin1",10pt);
            style table from container /
               frame=hsides
               rules=groups
               cellpadding=0pt
               cellspacing=0pt
               borderwidth=0pt
               asis=on;
            style body from document /
                bottommargin=0
                topmargin=0
                rightmargin=0
                leftmargin=0;
             style header from headersandfooters /
                protectspecialchars=off
                just=center;
            style systitleandfootercontainer from container/
                asis=on;
            style data from container/
                asis=on;
            style color_list from color_list/
                'bgA' = cxFFFFFF;
            end;
         run;

         ods listing close;
         ods html body = sendEm style = glsrmail;
         title;
         footnote;

         options nocenter;

         ods text='Execution of gmLogScanReport has completed.';
         ods text=' ';
         ods text="Full report can be found here: &glsr_epth";
         ods text=' ';

         proc report data=&glsr_templib..sum01 nowd headline headskip missing spacing=2 split="@" contents='';
         column dum dir totlogs totlogsc scanned clean scannedp drisk_color sissuesp dissuesp;
         define dum /order noprint;
         define dir /order order=data style={cellwidth=50% just=l} "Directory";
         define totlogs /order noprint;
         define totlogsc / style={cellwidth=10% just=l} "Logs in@Directory";
         define scanned /order noprint;
         define clean /order noprint;
         define scannedp / style={cellwidth=12% just=l} "Logs Scanned";
         define drisk_color /order noprint;
         define sissuesp / style={cellwidth=12% just=l} "Code Issues";
         define dissuesp / style={cellwidth=12% just=l} "Data Issues";

         break before dum / contents='' page;

         %if &glsr_ml_cnt ne 0 %then %do;
            compute after dum;
               line @1 "";
               line @1 "~S={color=red} NOTE: The following logs relating to programs listed in multirun file were not found: ";
               %do glsr_ml_i=1 %to &glsr_ml_cnt;
                  line @4 "&&glsr_ml_&glsr_ml_i";
               %end;
               line @1 "";
            endcomp;
         %end;

         compute scannedp;
            if scanned=totlogs then
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightgreen]");
            else if scanned ne totlogs then
               call define(_COL_, "style", "STYLE=[BACKGROUND=yellow]");
         endcomp;

         compute sissuesp;
            if scanned=clean then
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightgreen]");
            else if scanned ne clean then do;
               if drisk_color='Y' then
                  call define(_COL_, "style", "STYLE=[BACKGROUND=yellow]");
               else if drisk_color='R' then
                  call define(_COL_, "style", "STYLE=[BACKGROUND=lightred]");
            end;
         endcomp;

         compute dissuesp;
            if dissuesp='   0' then
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightgreen]");
            else
               call define(_COL_, "style", "STYLE=[BACKGROUND=lightblue]");
         endcomp;
      run;

         *List of Logs Scanned;

         proc report data=&glsr_templib..list01 nowd headline headskip missing spacing=2 split="@" contents='' style(report)={cellpadding=2pt}; 
            column dum moddate moddatec dir space logfile hrisk sissues dissues;
            define dum /order noprint;
            define moddate /order order=data noprint;
            define moddatec /display order=data style={cellwidth=17% just=l} "Creation DateTime";
            define dir /display order=data style={cellwidth=45% just=l} "Directory";
            define space /display order=data style={cellwidth=2% just=l} "";
            define logfile / style={cellwidth=23% just=l} "Log";
            define hrisk / noprint;
            define sissues / style={cellwidth=6% just=l} "Code Issues";
            define dissues / style={cellwidth=6% just=l} "Data Issues";

            break before dum / contents='' page;

            compute sissues;
               if hrisk='ERROR-like Condition' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
               else if hrisk='Data Issue' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightblue]");
               else if hrisk='Check Manually' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
               else if hrisk='Unassessed' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=yellow]");
               else if hrisk='High Risk' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
               else if hrisk='Empty Log' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
               else if hrisk='No Risk' or hrisk='' then
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightgreen]");
               else
                  call define(_ROW_, "style", "STYLE=[BACKGROUND=lightred]");
            endcomp;
         run;

         ods html close;
         ods listing;

         %gmMessage(codeLocation=gmLogScanReport/Email
         , linesOut=Sending email to %gmGetUserName.
         , selectType=NOTE
         );

         %gmMessage(codeLocation=gmLogScanReport/Execution
         , linesOut=PDF report file created.
         , selectType=NOTE
         , printStdOut=&printStdOut
         );
         
      %end;

   * end of section to run if > 0 logfiles selected;
   %end;
   %else %do;
       %gmMessage(codeLocation=gmLogScanReport/ABORT
       , linesOut=Macro aborted as no logs selected for scan.
       , selectType=ABORT
       , printStdOut=1
       , sendEmail=&sendEmail
       );
   %end;

   *******************************************************************************************;
   * clean up;
   *******************************************************************************************;
   
   * restore options;
   * drop two options which do not need to be reset - SAS changes them during OPTLOAD;
   data &glsr_templib..glsr_options;
       set &glsr_templib..glsr_options (where=(optName not in ("SET","CMPOPT")));
   run;
   proc optload data=&glsr_templib..glsr_options; run;

   %if &gmdebug ne 1 %then %do;
      proc datasets lib=&glsr_templib kill memtype=data nolist; run; quit;
   %end;

   title;
   footnote;

   %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscanreport.sas $);

%mend gmLogScanReport;
