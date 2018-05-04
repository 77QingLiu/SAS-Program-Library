/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Icy Du, Allen Zeng $LastChangedBy: kolosod $
  Creation Date:         07Aug2013 / $LastChangedDate: 2016-10-25 07:19:40 -0400 (Tue, 25 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcomparereport.sas $

  Files Created:         Datasets containing results from scans: metadata.gcr_sum and metadata.gcr_det
                         PDF file containing compare scan report. Written to pathOut= location and named as per fileOut= value

  Program Purpose:       The macro is used to scan the QC compare outputs and
                         produce a detailed report of findings.
                         #  
                         # In order to produce the correct report the QC compare 
                         output must adhere to PXL standard, which is achieved by the 
                         usage of gmCompare.
                         #  
                         # This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
                         #
                         # This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                pathsIn
      Allowed Values:     
      Default Value:     REQUIRED
      Description:       List of directories to scan.
                         # Example values: 
                         &_qanal@&_qtab

    Name:                subDir
      Allowed Values:    0 | 1
      Default Value:     0
      Description:       Include any sub-directories in scan (0=No, 1=Yes).

    Name:                excludeDirs
      Allowed Values:     
      Default Value:     BLANK
      Description:       List of directories to exclude from scan.
                         # /path/path/folder1@/path/path/folder2@/path/path/folder3 will force the macro to exclude the 3 listed directories. 
                         # /path/path/folder1/.* will force the macro to exclude directories starting with /path/path/folder1/.

    Name:                includeFiles
      Allowed Values:     
      Default Value:     BLANK
      Description:       List of files to scan. 
                         # Example values: 
                         # qc_adsl.txt@qc_adae.txt@qc_adlb.txt will force the macro to scan the 3 listed compares. 
                         # qc_un.* will force the macro to scan only compares starting with qc_un.

    Name:                excludeFiles
      Allowed Values:     
      Default Value:     BLANK
      Description:       List of files to exclude from scan. 
                         # Example values: 
                         # multirun.txt@multirun_all.txt@multirun_main.txt will force the macro to exclude the 3 listed compares. 
                         # multirun.* will force the macro to exclude compares starting with multirun.

    Name:                compareDetails
      Allowed Values:    0 | 1
      Default Value:     1
      Description:       Include compare output for unequal values or differing attributes in report (0=No, 1=Yes).

    Name:                pathOut
      Allowed Values:     
      Default Value:     &_global
      Description:       Full path specifying location of the output file.

    Name:                fileOut
      Allowed Values:    default | projarea | full | user 
      Default Value:     default
      Description:       Naming convention for report filename:
                         # default: gmCompareReport.pdf.
                         # projarea: dependant on project area, e.g. gmCompareReport_primary.pdf.
                         # full: dependant on project area and run date/time, e.g. gmCompareReport_primary_20160101T1227.pdf.
                         # user: dependant on user executing macro, e.g. gmCompareReport_zenga.pdf.

    Name:                splitChar
      Allowed Values:     
      Default Value:     @
      Description:       Split character to separate pathsIn/excludeDirs/includeFiles/excludeFiles values.

    Name:                printStdOut
      Allowed Values:    0 | 1
      Default Value:     1
      Description:       Send execution messages to StdOut if macro run in batch mode (0=No, 1=Yes).
                         During interactive mode no messages will be send to StdOut.
 
    Name:                sendEmail   
      Allowed Values:    0 | 1
      Default Value:     0 
      Description:       Send email to user on completion of execution (0=No, 1=Yes) with summary report. Also controls if ABORT messages are sent to user by e-mail.

    Name:                lockWait
      Allowed Values:    0 - 600
      Default Value:     30
      Description:       Number of seconds SAS waits in case output dataset is locked.

    Name:                metadataIn
      Default Value:     metadata.global
      Description:       Dataset containing metadata.

  Macro Returnvalue:     
 
      Description:       Macro does not return any values.

  Global Macrovariables:

    Name:                _client
      Usage:             read
      Description:       Client short name.

    Name:                _tims
      Usage:             read
      Description:       Project number.

    Name:                _project
      Usage:             read
      Description:       Unix project name.

    Name:                _type
      Usage:             read
      Description:       Delivery type.

    Name:                gmCompareReportResult
      Usage:             create/modify
      Description:       Returns status of all compares:
                         * QCPassed - All files have compares without any issues.
                         * CheckManually - Some files or folders have Check Manually status.
                         * CompareIssues - Some files or folders have Compare issues.

  Metadata Keys:
 
    Name:                outputQcPrefix
      Description:       Prefix for QC dataset name.
      Dataset:           global (dataset specified in metadataIn=).

  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)
                         gmModifySplit(called)
                         gmGetUserName (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2799 $
-----------------------------------------------------------------------------*/

%macro gmCompareReport( pathsIn       =
                      , subDir         = 0
                      , excludeDirs    = 
                      , includeFiles   =
                      , excludeFiles   =  
                      , compareDetails = 1
                      , pathOut        = &_global
                      , fileOut        = default
                      , splitChar      = @
                      , printStdOut    = 1
                      , sendEmail      = 0
                      , lockWait       = 30
                      , metadataIn     = metadata.global
                      );

/* Create temporary library */
%local comreport_templib;

%let comreport_templib=%gmStart( headURL      = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcomparereport.sas $
                          ,revision           = $Rev: 2799 $
                          ,checkMinSasVersion = 9.2
                          ,librequired        = 1
                          );

/* Save the current system option settings in &comreport_templib..options */
proc optsave out=&comreport_templib..options;
run;

/* Prevent multi-threaded sorting and message to the SAS log about the maximum length for strings in quotation marks */
options NOTHREADS NOQUOTELENMAX;

/* Define local macro variables */
%local comreport_epath
       comreport_dt
       comreport_dirtot
       comreport_dirnum
       comreport_fexist
       comreport_fletot
       comreport_outputqcprefix
       comreport_flenum
       comreport_emptyfle
       comreport_qctime
       comreport_libm
       comreport_libq
       comreport_libdatam
       comreport_libdataq
       comreport_datam
       comreport_dataq
       comreport_dtm
       comreport_dtq
       comreport_mlab
       comreport_qlab
       comreport_mobs
       comreport_qobs
       comreport_pxlinfo
       comreport_sysinfo
       comreport_pfile
       comreport_timeord
       comreport_papersz
       comreport_plabel
       comreport_foot
       comreport_issname
       comreport_issdir
       comreport_issdir
       comreport_outnum
       comreport_totalFiles    
       comreport_comIssues   
       comreport_manIssues 
       comreport_numExcluded
       comreport_locksyserrbefore
       comreport_locksyserrafter 
       comreport_errortext
       ;

%global gmCompareReportResult;

/* Check if the inputs are valid */
%if not %sysfunc(fileexist(%nrbquote(&pathOut))) %then %do;
        %gmMessage(codeLocation = gmCompareReport
                  , linesOut     = PathOut directory (&pathOut) does not exist.
                  , selectType   = ABORT
                  , printStdOut  = 1
                  , sendEmail    = &sendEmail
                  );
%end;
%else %do;
    %let pathOut=&pathOut./;
    /* Remove repeating slashes */
    %let pathOut=%sysfunc(prxchange(s#/+#/#, -1, %quote(&pathOut)));
    /* Symbolic link path */
    %let pathOut=%sysfunc(prxchange(s#^(/project\d+/)#/projects/#, 1, %quote(&pathOut)));
%end;

/* Generate filename for output pdf file */
%if %lowcase(&fileOut)=default %then %do;
    filename gcr_rep "&pathOut.gmCompareReport.pdf";
    %let comreport_epath=\\kennet%sysfunc(prxchange(s#/+#\\#, -1, %quote(&pathOut.gmCompareReport.pdf)));
%end;
%else %if %lowcase(&fileOut)=user %then %do;
    filename gcr_rep "&pathOut.gmCompareReport_&sysUserId..pdf";
    %let comreport_epath=\\kennet%sysfunc(prxchange(s#/+#\\#, -1, %quote(&pathOut.gmCompareReport_&sysUserId..pdf)));
%end;
%else %if %lowcase(&fileOut)=projarea %then %do;
    %if %symexist(_type) %then %do;
        filename gcr_rep "&pathOut.gmCompareReport_&_type..pdf";
        %let comreport_epath=\\kennet%sysfunc(prxchange(s#/+#\\#, -1, %quote(&pathOut.gmCompareReport_&_type..pdf)));
    %end;
    %else %do;
        %gmMessage(codeLocation = gmCompareReport
                  , linesOut     = Macro variable (_type) does not exist.
                  , selectType   = ABORT
                  , printStdOut  = 1
                  , sendEmail    = &sendEmail
                  );
    %end;
%end;
%else %if %lowcase(&fileOut)=full %then %do;
    %if %symexist(_type) %then %do;
        data _null_;
            call symputx("comreport_dt", put(date(), yymmddn8.)||"T"||compress(cats(tranwrd(put(time(), tod5.), ":", ""))));
        run;

        filename gcr_rep "&pathOut.gmCompareReport_&_type._&comreport_dt..pdf";
        %let comreport_epath=\\kennet%sysfunc(prxchange(s#/+#\\#, -1, %quote(&pathOut.gmCompareReport_&_type._&comreport_dt..pdf)));
    %end;
    %else %do;
        %gmMessage(codeLocation = gmCompareReport
                  , linesOut     = Macro variable (_type) does not exist.
                  , selectType   = ABORT
                  , printStdOut  = 1
                  , sendEmail    = &sendEmail
                  );
    %end;
%end;

/* Delete current output file if exists */
%if %sysFunc(fexist(gcr_rep)) %then %do;
    data _null_;
        x=fdelete("gcr_rep");
    run;
%end;

%if "%superQ(pathsIn)"="" %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = List of directories (pathsIn) to scan can not be missing.
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

%if &subDir^=0 and &subDir^=1 %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = %str(Value of macro parameter subDir is invalid, valid values are 0, 1.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

%if &compareDetails^=0 and &compareDetails^=1 %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = %str(Value of macro parameter compareDetails is invalid, valid values are 0, 1.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

%if %lowcase(&fileOut)^=default and %lowcase(&fileOut)^=user and %lowcase(&fileOut)^=projarea and %lowcase(&fileOut)^=full %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = Value of macro parameter fileOut is invalid.
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

%if %length(%superQ(splitChar)) ^= 1 %then %do;
    %gmMessage(codeLocation = gmCompareReport
               , linesOut    = %str(Value of macro parameter SplitChar is invalid, must be a single character.)
               , selectType  = ABORT
               , printStdOut = 1
               , sendEmail   = &sendEmail
               );
%end;

%if &printStdOut^=0 and &printStdOut^=1 %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = %str(Value of macro parameter printStdOut is invalid, valid values are 0, 1.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

%if &sendEmail^=0 and &sendEmail^=1 %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = %str(Value of macro parameter sendEmail is invalid, valid values are 0, 1.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              ); 
%end;

%if %superQ(lockWait) < 0 or %superQ(lockWait) > 600 %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = %str(Value of macro parameter lockWait is invalid, valid values are 0 - 600.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

/* Identify directories to be scaned */
data &comreport_templib..dirlst01;
    length DIR $1024;
    I=1;
    do while(scan("&pathsIn", I, "&splitChar") ne "");
        DIR=cats(scan("&pathsIn", I, "&splitChar"))||"/";
        /* Remove repeating slashes */
        DIR=prxchange("s#/+#/#", -1, DIR);
        /* Symbolic link path*/
        DIR=prxchange("s#^(/project\d+/)#/projects/#", -1, cats(DIR));
        I+1;
        output;
    end;
    drop I;
    proc sort nodupkey;
        by DIR;
run;

data _null_;
    set &comreport_templib..dirlst01 end=eod;
    call symputx("comreport_dir"||cats(_N_), DIR, "L");
    call symputx("comreport_dir_escaped"||cats(_N_), "'"||cats(DIR)||"'", "L");	
    if eod then call symputx("comreport_dirtot", _N_);
run;

/* Pick up subDirectories if subDir=1 */
%if &subDir=1 %then %do;
    %do comreport_dirnum=1 %to &comreport_dirtot;
        filename gcr_sub pipe "ls -R &&comreport_dir_escaped&comreport_dirnum | grep ':' | sed 's#:#/#'";
        data &comreport_templib..dirlst02_&comreport_dirnum;
            infile gcr_sub truncover lrecl=1024;
            length DIR $1024;
            input DIR 1-1024;
        run;
    %end;

    data &comreport_templib..dirlst01;
        set &comreport_templib..dirlst01 &comreport_templib..dirlst02_:;
        /* Remove repeating slashes */
        DIR=prxchange("s#/+#/#", -1, DIR);
        /* Symbolic link path*/
        DIR=prxchange("s#^(/project\d+/)#/projects/#", -1, cats(DIR));
    run;

    /* Close the pipe */
    filename gcr_sub clear;
%end;

/* Exclude any specified in excludeDirs= argument */
%if "%superQ(excludeDirs)"^="" %then %do;
    %if %bquote(%substr(&excludeDirs, %length(&excludeDirs)))="&splitChar" %then %let excludeDirs=%substr(&excludeDirs, 1, %eval(%length(&excludeDirs)-1));;
    data &comreport_templib..excludedirs;
        length DIR $1024;
        I=1;
        do while(scan("&excludeDirs", I, "&splitChar") ne "");
            DIR=cats(scan("&excludeDirs", I, "&splitChar"))||"/";
            /* Remove repeating slashes */
            DIR=prxchange("s#/+#/#", -1, DIR);
            /* Symbolic link path*/
            DIR=prxchange("s#^(/project\d+/)#/projects/#", -1, cats(DIR));
            I+1;
            output;
        end;
    run;

    proc sql noprint;
        select distinct DIR into :excludeDirs separated by "&splitChar"
            from &comreport_templib..excludedirs
            ;
    quit;
    
    %if ^ %index(&excludeDirs, *) %then %do;
        data _null_;
            set &comreport_templib..excludedirs end=eod;
            call symputx("excludeDirs"||cats(_N_), DIR, "L");
            if eod then call symputx("excludeDirstot", _N_);
        run;

        %do comreport_dirnum=1 %to &excludeDirstot;
            /* Check if directory exists */
            %if not %sysfunc(fileexist(%nrbquote(&&excludeDirs&comreport_dirnum))) %then %do;
                %gmMessage(codeLocation = gmCompareReport
                          , linesOut     = ExcludeDirs directory (&&excludeDirs&comreport_dirnum) does not exist.
                          , selectType   = ABORT
                          , printStdOut  = 1
                          , sendEmail    = &sendEmail
                          );
            %end;
        %end;

        proc sql noprint;
            select distinct DIR into :excludeDirs separated by '", "'
            from &comreport_templib..excludedirs
            ;
        quit;

        data &comreport_templib..dirlst01;
            set &comreport_templib..dirlst01;
            if DIR not in ("&excludeDirs");
        run;
    %end;
    %else %if %index(&excludeDirs, *) %then %do;
        %let excludeDirs=%sysfunc(tranwrd(&excludeDirs, &splitChar, |));;
        data &comreport_templib..dirlst01;
            set &comreport_templib..dirlst01;
            if not prxmatch("#^(&excludeDirs)$#i", cats(DIR));
        run;
    %end;
%end;

/* Create macro varialbe for each directory */
proc sort data=&comreport_templib..dirlst01 nodupkey;
    by DIR;
run;

%let comreport_dirtot=0;
data _null_;
    set &comreport_templib..dirlst01 end=eod;
    call symputx("comreport_dir"||cats(_N_), DIR, "L");
    call symputx("comreport_dir_escaped"||cats(_N_), "'"||cats(DIR)||"'", "L");	
    if eod then call symputx("comreport_dirtot", _N_);
run;

%if &comreport_dirtot < 1 %then %do;
    %gmMessage(codeLocation = gmCompareReport
              , linesOut     = No directory selected for scanning.
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

/* Read in prefixs from metadata dataset */
%if %sysfunc(exist(&metaDataIn)) %then %do;
    data _null_;
        set &metaDataIn;
        if upcase(KEY)="OUTPUTQCPREFIX" then call symputx("comreport_outputqcprefix", lowcase(VALUE));
    run;
%end;

%do comreport_dirnum=1 %to &comreport_dirtot;

    /* Total number of files */
    %let comreport_fletot&comreport_dirnum=0;

    /* Check if directory exists */
    %if not %sysfunc(fileexist(%nrbquote(&&comreport_dir&comreport_dirnum))) %then %do;
        %gmMessage(codeLocation = gmCompareReport
                  , linesOut     = PathsIn directory (&&comreport_dir&comreport_dirnum) does not exist.
                  , selectType   = ABORT
                  , printStdOut  = 1
                  , sendEmail    = &sendEmail
                 );
    %end;

    /* Check if compare exist */
    %let comreport_fexist=1;
    %if "%superQ(comreport_outputqcprefix)"^="" %then
        filename gcr_fext pipe "ls &&comreport_dir_escaped&comreport_dirnum..&comreport_outputqcprefix.*.txt";
    %else filename gcr_fext pipe "ls &&comreport_dir_escaped&comreport_dirnum..qc_*.txt";;

    data _null_;
        infile gcr_fext truncover end=eof;
        input;
        if prxmatch("/(\*\.txt not found)/", _INFILE_) then call symputx("comreport_fexist", 0);
    run;

    /* Close the pipe */
    filename gcr_fext clear;

    /* There are 0 compares in directory */
    %if &comreport_fexist=0 %then %do;
        data &comreport_templib..combine&comreport_dirnum;
            length DIR $1024 QCNAME $256 ERRTXT $200 ERRNUM 8;
            DIR="&&comreport_dir&comreport_dirnum";
            QCNAME="";
            ERRTXT="QC findings";
            ERRNUM=2;
            output;
            ERRTXT="  There are 0 compares in the directory";
            ERRNUM=3;
            output;
        run;
    %end;
    %else %if &comreport_fexist=1 %then %do;
        proc sql;
            create table &comreport_templib..combine&comreport_dirnum (DIR char(1024), QCNAME char(256), ERRTXT char(200), ERRNUM num(8));
        quit;

        %if "%superQ(comreport_outputqcprefix)"^="" %then
            filename gcr_flst pipe "ls &&comreport_dir_escaped&comreport_dirnum..&comreport_outputqcprefix.*.txt";
        %else filename gcr_flst pipe "ls &&comreport_dir_escaped&comreport_dirnum..qc_*.txt";;

        data &comreport_templib..filelst01;
            infile gcr_flst truncover lrecl=1024;
            length QCFILE $256;
            input;
            QCFILE=prxchange("s/(.+)\/(.+)/\2/", -1, _INFILE_);
            keep QCFILE;
        run;

        /* Close the pipe */
        filename gcr_flst clear;

        /* Get the total number of files in each directory */
        data _null_;
            set &comreport_templib..filelst01 end=eod;
            call symputx("comreport_qcname"||cats(_N_), QCFILE, "L");
            if eod then call symputx("comreport_fletot&comreport_dirnum", _N_, "L");
        run;

        /* Include files using includeFiles */
        %if "%superQ(includeFiles)"^="" %then %do;
            %if %bquote(%substr(&includeFiles, %length(&includeFiles)))="&splitChar" %then %let includeFiles=%substr(&includeFiles, 1, %eval(%length(&includeFiles)-1));;
            data &comreport_templib..filelst01;
                set &comreport_templib..filelst01;
                if _N_=1 then do;
                    length SPLITCHAR $10 INCLUDEFILESPATTERN $32767;
                    retain SPLITCHAR INCLUDEFILESPATTERN;
                    SPLITCHAR=symget("splitChar");
                    INCLUDEFILESPATTERN=symget("includeFiles");
                    /* Escape special characters */
                    if SPLITCHAR in ("$", "\", "/", "@") then do;
                        SPLITCHAR="\"||cats(SPLITCHAR);
                    end;
                    else do;
                        SPLITCHAR="\Q"||cats(SPLITCHAR)||"\E";
                    end;
                    /* Remove trailing and leading blanks between items */
                    /* Replace splitChar with | */
                    INCLUDEFILESPATTERN=prxchange("s/\s*"||cats(SPLITCHAR)||"\s*/|/", -1, strip(INCLUDEFILESPATTERN));
                end;
                if prxmatch("/^("||cats(INCLUDEFILESPATTERN)||")$/i", cats(QCFILE));
                drop SPLITCHAR INCLUDEFILESPATTERN;
            run;
        %end;

        /* Exclude files using excludeFiles */
        %if "%superQ(excludeFiles)"^="" %then %do;
            %if %bquote(%substr(&excludeFiles, %length(&excludeFiles)))="&splitChar" %then %let excludeFiles=%substr(&excludeFiles, 1, %eval(%length(&excludeFiles)-1));;
            data &comreport_templib..filelst01;
                set &comreport_templib..filelst01;
                if _N_=1 then do;
                    length SPLITCHAR $10 EXCLUDEFILESPATTERN $32767;
                    retain SPLITCHAR EXCLUDEFILESPATTERN;
                    SPLITCHAR=symget("splitChar");
                    EXCLUDEFILESPATTERN=symget("excludeFiles");
                    /* Escape special characters */
                    if SPLITCHAR in ("$", "\", "/", "@") then do;
                        SPLITCHAR="\"||cats(SPLITCHAR);
                    end;
                    else do;
                        SPLITCHAR="\Q"||cats(SPLITCHAR)||"\E";
                    end;
                    /* Remove trailing and leading blanks between items */
                    /* Replace splitChar with | */
                    EXCLUDEFILESPATTERN=prxchange("s/\s*"||cats(SPLITCHAR)||"\s*/|/", -1, strip(EXCLUDEFILESPATTERN));
                end;
                if not prxmatch("/^("||cats(EXCLUDEFILESPATTERN)||")$/i", cats(QCFILE));
                drop SPLITCHAR EXCLUDEFILESPATTERN;
            run;
        %end;

        /* Get the total number of files in each directory selected for scanning */
        %let comreport_fletot=0;
        data _null_;
            set &comreport_templib..filelst01 end=eod;
            call symputx("comreport_qcname"||cats(_N_), QCFILE, "L");
            if eod then call symputx("comreport_fletot", _N_);
        run;

        %if &comreport_fletot >= 1 %then %do;
            %do comreport_flenum=1 %to &comreport_fletot;
                filename gcr_file "&&comreport_dir&comreport_dirnum..&&comreport_qcname&comreport_flenum";
                proc sql noprint;
                    select cats(tranwrd(put(MODATE, is8601dt.), "T", " ")) into :comreport_qctime
                        from dictionary.extfiles
                        where FILEREF="GCR_FILE"
                        ;
                quit;

                /* Close the pipe */
                filename gcr_file clear;
                
                /* Check if compare is mpty */
                %let comreport_emptyfle=1;
                data &comreport_templib..temp1;
                    length RECORD $256 DIR $1024 QCNAME $256 ERRTXT $200;
                    infile "&&comreport_dir&comreport_dirnum..&&comreport_qcname&comreport_flenum" length=reclen;
                    input @1 RECORD $varying256. reclen;
                    if compress(compress(RECORD, , "kw"))="" then delete;
                    RECORD=cats(RECORD);
                    DIR="&&comreport_dir&comreport_dirnum";
                    QCNAME=catx("/", "&&comreport_qcname&comreport_flenum", "&comreport_qctime");
                    call missing(ERRTXT);
                    if ^ missing(RECORD) then call symputx("comreport_emptyfle", 0);
                    /* Check if ultiple compare outputs in one compare */
                    if prxmatch("/^(Data Set Summary)$/", cats(RECORD)) then MULCOM=1;
                    COMMUL+MULCOM;
                run;

                %if &comreport_emptyfle=1 %then %do;
                    data  &comreport_templib..temp1;
                        length DIR $1024 QCNAME $256 ERRTXT $200;
                        DIR="&&comreport_dir&comreport_dirnum";
                        QCNAME=catx("/", "&&comreport_qcname&comreport_flenum", "&comreport_qctime");
                        ERRTXT="QC findings";
                        ERRNUM=2;
                        output;
                        ERRTXT="  Compare report is missing";
                        ERRNUM=3;
                        output;
                    run;
                %end;
                %else %if &comreport_emptyfle=0 %then %do;

                    %let comreport_mobs=;
                    %let comreport_qobs=;

                    /* Get the libnames, datasets name, libnames.datasets, observations, labels of both sides */
                    data _null_;
                        set &comreport_templib..temp1(where=(prxmatch("/^\w+\.\w+\s+.+:\d{2}\s+\d+\s+\d+(.+?)?$/", cats(RECORD))));
                        if _N_=1 then do;
                            call symputx("comreport_libm", scan(RECORD, 1, "."));
                            call symputx("comreport_datam", scan(scan(RECORD, 1, " "), 2, "."));
                            call symputx("comreport_libdatam", scan(RECORD, 1, " "));
                            call symputx("comreport_dtm", scan(RECORD, 3, " "));
                            call symputx("comreport_mobs", scan(RECORD, 5, " "));
                            call symputx("comreport_mlab", prxchange("s/^\w+\.\w+\s+.+:\d{2}\s+\d+\s+\d+\s?\s?(.+?)?$/\1/", -1, cats(RECORD)));
                        end;
                        else if _N_=2 then do;
                            call symputx("comreport_libq", scan(RECORD, 1, "."));
                            call symputx("comreport_dataq", scan(scan(RECORD, 1, " "), 2, "."));
                            call symputx("comreport_libdataq", scan(RECORD, 1, " "));
                            call symputx("comreport_dtq", scan(RECORD, 3, " "));
                            call symputx("comreport_qobs", scan(RECORD, 5, " "));
                            call symputx("comreport_qlab", prxchange("s/^\w+\.\w+\s+.+:\d{2}\s+\d+\s+\d+\s?\s?(.+?)?$/\1/", -1, cats(RECORD)));
                        end;
                        call symputx("comreport_pfile", scan(QCNAME, 1, "/"));	
                    run;

                    /* Get the PXL info */
                    %let comreport_pxlinfo=0;
                    %let comreport_sysinfo=0;
                    data _null_;
                        set &comreport_templib..temp1(where=(prxmatch("/.+SysInfo:PxlInfo \d+:\d+$/", cats(RECORD))));
                        if _N_=1 then call symputx("comreport_pxlinfo",  prxchange("s/.+SysInfo:PxlInfo\s\d+:(\d+)$/\1/", 1, cats(RECORD)));
                        if _N_=1 then call symputx("comreport_sysinfo",  prxchange("s/.+SysInfo:PxlInfo\s(\d+):\d+$/\1/", 1, cats(RECORD)));
                    run;

                    /* Check if text split into several lines in compare */
                    %if "&comreport_mobs"="" or "&comreport_qobs"="" %then %do;
                        %gmMessage(codeLocation = gmCompareReport
                                  , linesOut     = GmCompareReport does not support compares when line size is not sufficient to provide all the information. Please extend the line size option before calling gmCompare. The problem file is &comreport_pfile.
                                  , selectType   = ABORT
                                  , printStdOut  = 1
                                  , sendEmail    = &sendEmail
                                  );
                    %end;

                    /* Scan file */
                    data &comreport_templib..temp1(keep=DIR QCNAME ERRNUM ERRTXT MOBS QOBS);
                        set &comreport_templib..temp1 end=eof;
                        length RECORDL MLAB QLAB $256 MOBS QOBS $50;
                        RECORDL=cats(lag(RECORD));
                        retain IDQCD IDVAR IDOBS IDLAB IDDUP IDBNM IDDIF IDUNE IDTYP IDRUN IDLIB IDGMC IDPRO IDUNL IDFN1 IDFN2 IDFN3 IDCRI IDBYV IDABR 0 MOBS QOBS MLAB QLAB;
                        if prxmatch("/(All values compared are exactly equal\.)$/", cats(RECORD)) 
                           or prxmatch("/^(Number of Variables Compared with Some Observations Unequal: 0\.)$/", cats(RECORD)) then IDQCD=1;
                        if prxmatch("/^(Listing of Variables in &comreport_libdatam but not in &comreport_libdataq)$/i", cats(RECORD)) 
                           or prxmatch("/^(Listing of Variables in &comreport_libdataq but not in &comreport_libdatam)$/i", cats(RECORD)) or (band(&comreport_sysinfo, 1024) or band(&comreport_sysinfo, 2048)) then IDVAR=3;
                        if prxmatch("/^Total Number of Observations Read from \w+\.\w+: \d+\./", cats(RECORD)) then do;
                            if prxmatch("/^Total Number of Observations Read from &comreport_libdatam: \d+\./", cats(RECORDL)) then MOBS=prxchange("s/^Total Number of Observations Read from &comreport_libdatam: (\d+)\./\1/", 1, cats(RECORDL));
                            if prxmatch("/^Total Number of Observations Read from &comreport_libdataq: \d+\./", cats(RECORD)) then QOBS=prxchange("s/^Total Number of Observations Read from &comreport_libdataq: (\d+)\./\1/", 1, cats(RECORD));
                            if MOBS ^= QOBS then IDOBS=4;
                        end;
                        if band(&comreport_sysinfo, 1) then IDLAB=5;
                        if prxmatch("/^&comreport_libdataq\s+.+:\d{2}\s+\d+\s+\d+(.+?)?$/", cats(RECORD)) then do;
                            if prxchange("s/.+\s+\d+\s+\d+\s?\s?(.+?)?$/\1/", -1, cats(RECORD)) ^= 
                               prxchange("s/.+\s+\d+\s+\d+\s?\s?(.+?)?$/\1/", -1, cats(RECORDL)) then IDLAB=5;
                            MLAB=catt(prxchange("s/.+\s+\d+\s+\d+\s?\s?(.+?)?$/\1/", -1, cats(RECORDL)));
                            QLAB=catt(prxchange("s/.+\s+\d+\s+\d+\s?\s?(.+?)?$/\1/", -1, cats(RECORD)));
                        end;
                        if MOBS="0" and QOBS="0" then IDBNM=6;
                        if prxmatch("/^Duplicate recorded within ID variables \(.+?\) in the (production|QC) dataset$/", cats(RECORD)) or band(&comreport_pxlinfo, 4) then IDDUP=7;
                        if prxmatch("/^(Listing of Common Variables with Differing Attributes)$/", cats(RECORD)) 
                           or (band(&comreport_sysinfo, 4) or band(&comreport_sysinfo, 8) or band(&comreport_sysinfo, 16) or band(&comreport_sysinfo, 32)) then IDDIF=8;
                        if prxmatch("/^(Number of Variables Compared with Some Observations Unequal: [1-9][0-9]*\.)$/", cats(RECORD)) or band(&comreport_sysinfo, 4096) then IDUNE=9;
                        if prxmatch("/^(Listing of Common Variables with Conflicting Types)$/", cats(RECORD)) or band(&comreport_sysinfo, 8192) then IDTYP=10;
                        if prxmatch("/^(X{64})/", cats(RECORD)) then IDRUN=11;
                        if prxmatch("/^&comreport_libdatam\s+.+:\d{2}\s+\d+\s+\d+(.+?)?$/", cats(RECORD)) and scan(RECORD, 1, ".")="WORK" then IDLIB=12;

                        /* Check if macro variables _client, _tims, and _project exist */
                        %if not %symexist(_client) %then %do;
                            %gmMessage(codeLocation = gmCompareReport
                                      , linesOut     = macro variable (_client) does not exist.
                                      , selectType   = ABORT
                                      , printStdOut  = 1
                                      , sendEmail    = &sendEmail
                                      );
                        %end;
                        %if not %symexist(_tims) %then %do;
                            %gmMessage(codeLocation = gmCompareReport
                                      , linesOut     = macro variable (_tims) does not exist.
                                      , selectType   = ABORT
                                      , printStdOut  = 1
                                      , sendEmail    = &sendEmail
                                      );
                        %end;
                        %if not %symexist(_project) %then %do;
                            %gmMessage(codeLocation = gmCompareReport
                                      , linesOut     = macro variable (_project) does not exist.
                                      , selectType   = ABORT
                                      , printStdOut  = 1
                                      , sendEmail    = &sendEmail
                                      );
                        %end;

                        if _N_=1 and not 
                           (prxmatch("/^(EQC of &comreport_libdatam on &_client &_tims \(&_project\)\.  QC produced by .+? on \d{2}\w{3}\d{4}\.)$/", cats(RECORD)) or
                           prxmatch("/^(X{64})/", cats(RECORD))) then IDGMC=13;
                        if prxmatch("/^(Variable Order)$/", cats(RECORD)) or band(&comreport_pxlinfo, 2) then IDCRI=15;
                        if prxmatch("/^Observation \d+ in (&comreport_libdatam|&comreport_libdataq) not found in (&comreport_libdatam|&comreport_libdataq):/", cats(RECORD)) then IDBYV=17;
                        if prxmatch("/^NOTE: Comparison aborted\./", cats(RECORD)) or band(&comreport_sysinfo, 32768) then IDABR=18;
                        IDSUM=sum(of ID:);
                        if eof then do;
                            if (prxmatch("/^Observation \d+ in (&comreport_libdatam|&comreport_libdataq) not found/", cats(RECORD)) and IDOBS ^= 4) 
                               or ((band(&comreport_sysinfo, 64) or band(&comreport_sysinfo, 128)) and IDOBS ^= 4) then IDBYV=17;
                            IDSUM=IDSUM+IDBYV;
                            if IDSUM = 1 then do;
                                ERRTXT="QC passed";
                                ERRNUM=1;
                                output;
                            end;
                            if IDSUM ^= 1 then do;
                                ERRTXT="QC findings";
                                ERRNUM=2;
                                output;
                            end;
                            if IDVAR = 3 then do;
                                ERRTXT="  Number of variables is different";
                                ERRNUM=3;
                                output;
                            end;
                            if IDOBS = 4 then do;
                                ERRTXT="  Number of observations is different";
                                ERRNUM=4;
                                output;
                                /* List the unequal number of observations */
                                ERRTXT="    Number of observations in Main/QC dataset: "||cats(MOBS)||"/"||cats(QOBS);
                                ERRNUM=4.1;
                                output;
                            end;
                            if IDLAB = 5 then do;
                                ERRTXT="  Dataset labels are different";
                                ERRNUM=5;
                                output;
                                /* List the unequal labels */
                                %if %length("%superq(comreport_mlab)") > 49 %then %do;
                                    %gmModifySplit(var=MLAB, width=73, indentSize=24, delimiter=~n);
                                    MLAB=substr(MLAB, 25);
                                %end;
                                ERRTXT="    Main dataset label: "||catt(MLAB);
                                ERRNUM=5.1;
                                output;
                                %if %length("%superq(comreport_qlab)") > 51 %then %do;
                                    %gmModifySplit(var=QLAB, width=73, indentSize=22, delimiter=~n);
                                    QLAB=substr(QLAB, 23);
                                %end;
                                ERRTXT="    QC dataset label: "||catt(QLAB);
                                ERRNUM=5.2;
                                output;
                            end;
                            if IDBNM = 6 then do;
                                ERRTXT="  Both datasets contain 0 observations";
                                ERRNUM=6;
                                output;
                            end;
                            if IDDUP = 7 then do;
                                ERRTXT="  Duplicate recorded within ID variables";
                                ERRNUM=7;
                                output;
                            end;
                            if IDDIF = 8 then do;
                                ERRTXT="  Variables with differing attributes";
                                ERRNUM=8;
                                output;
                            end;
                            if IDUNE = 9 then do;
                                ERRTXT="  Variables with unequal values";
                                ERRNUM=9;
                                output;
                            end;
                            if IDTYP = 10 then do;
                                ERRTXT="  Variables with conflicting types";
                                ERRNUM=10;
                                output;
                            end;
                            if IDRUN = 11 then do;
                                ERRTXT="  The program was run in interactive mode";
                                ERRNUM=11;
                                output;
                            end;
                            if IDLIB = 12 then do;
                                ERRTXT="  Main dataset is saved to the work library";
                                ERRNUM=12;
                                output;
                            end;
                            if IDGMC = 13 then do;
                                ERRTXT="  Compare is not created with gmCompare";
                                ERRNUM=13;
                                output;
                            end;
                            if COMMUL >= 2 then do;
                                ERRTXT="  Multiple compare outputs in one compare";
                                ERRNUM=14;
                                output;
                            end;
                            if IDCRI = 15 then do;
                                ERRTXT="  Variable order is different";
                                ERRNUM=15;
                                output;
                            end;
                            if IDBYV = 17 then do;
                                ERRTXT="  Observations not found";
                                ERRNUM=17;
                                output;
                            end;
                            if IDABR = 18 then do;
                                ERRTXT="  Comparison aborted";
                                ERRNUM=18;
                                output;
                            end;
                        end;

                        /* List the variable which is not contained in both datasets */
                        retain NUM1 NUM2;
                        if prxmatch("/^(Listing of Variables in &comreport_libdatam but not in &comreport_libdataq)$/i", cats(RECORD)) then do;
                            NUM1=_N_;
                            ERRTXT="    Variables in main dataset but not in QC dataset";
                            ERRNUM=3.1;
                            output;
                        end;
                        if prxmatch("/^(Listing of Variables in &comreport_libdataq but not in &comreport_libdatam)$/i", cats(RECORD)) then do;
                            NUM2=_N_;
                            ERRTXT="    Variables in QC dataset but not in main dataset";
                            ERRNUM=3.3;
                            output;
                        end;

                        if prxmatch("/^\w+\s+(Num|Char)\s+.+$/", cats(RECORD)) and not prxmatch("/(&comreport_libdatam)/", RECORD)
                           and not prxmatch("/^(&comreport_libdataq)/i", cats(RECORD)) then do;
                            ERRTXT=prxchange("s/(.+?)\s(.+)/      \1/", -1, RECORD);
                            if NUM1 > NUM2 then ERRNUM=3.2;
                            if NUM1 < NUM2 then ERRNUM=3.4;
                            output;
                        end;

                        /* List the variable name which has differing attributes */
                        if prxmatch("/^&comreport_libdataq\s+(Num|Char)\s+.+$/", cats(RECORD)) then do;
                            if scan(RECORD,2," ") = scan(RECORDL, 3, " ") then do;
                                ERRTXT=prxchange("s/(.+?)\s(.+)/    \1/", -1, RECORDL);
                                ERRNUM=8.1;
                                output;
                            end;
                        end;

                        /* List the variable name which has unequal values */
                        if prxmatch("/^\w+\s+(NUM|CHAR)\s+\d+E*\d*?\s+.+$/", cats(RECORD)) then do;
                            ERRTXT=prxchange("s/(.+?)\s(.+)/    \1/", -1, RECORD);
                            ERRNUM=9.1;
                            output;
                        end;

                        /* List the variable name which has conflicting types */
                        if prxmatch("/^&comreport_libdataq\s+(Num|Char)\s+.+$/", cats(RECORD)) then do;
                            if scan(RECORD, 2, " ") ^= scan(RECORDL, 3, " ") then do;
                                ERRTXT=prxchange("s/(.+?)\s(.+)/    \1/", -1, RECORDL);
                                ERRNUM=10.1;
                                output;
                            end;
                        end;
                    run;

                    /* Check if main dataset was modified before qc dataset */
                    proc sql;
                        create table &comreport_templib..time as
                            select *
                            from dictionary.tables
                            where (LIBNAME=%upcase("&comreport_libm") and MEMNAME=%upcase("&comreport_datam")) or (LIBNAME=%upcase("&comreport_libq") and MEMNAME=%upcase("&comreport_dataq"))
                            order by MODATE
                            ;
                    quit;

                    data &comreport_templib..timeord01;
                        set &comreport_templib..time;
                        length DIR $1024 QCNAME $256 ERRTXT $200;
                        DIR="&&comreport_dir&comreport_dirnum";
                        QCNAME=catx("/", "&&comreport_qcname&comreport_flenum", "&comreport_qctime");;
                        MODATEL=lag(MODATE);
                        if _N_ = 2 and prxmatch("/^(&comreport_libm)/", cats(LIBNAME)) then do;
                            ERRTXT="  QC dataset was last modified before main dataset";
                            ERRNUM=16;
                            output;
                            ERRTXT="    Main/QC dataset modification date: "||cats(put(MODATE, datetime16.))||"/"||cats(put(MODATEL, datetime16.));
                            ERRNUM=16.1;
                            output;
                        end;
                        keep DIR QCNAME ERRNUM ERRTXT;
                    run;

                    data &comreport_templib..timeord02;
                        length DIR $1024 QCNAME $256 ERRTXT $200;
                        DIR="&&comreport_dir&comreport_dirnum";
                        QCNAME=catx("/", "&&comreport_qcname&comreport_flenum", "&comreport_qctime");;
                        if input("&comreport_dtm", datetime16.) > input("&comreport_dtq", datetime16.) then do;
                            ERRTXT="  QC dataset was last modified before main dataset";
                            ERRNUM=16;
                            output;
                            ERRTXT="    Main/QC dataset modification date: "||cats("&comreport_dtm")||"/"||cats("&comreport_dtq");
                            ERRNUM=16.1;
                            output;
                        end;
                        keep DIR QCNAME ERRNUM ERRTXT;
                    run;

                    data &comreport_templib..timeord;
                        set &comreport_templib..timeord01 &comreport_templib..timeord02;
                        proc sort nodupkey;
                            by DIR QCNAME ERRNUM ERRTXT;
                    run;

                    data  &comreport_templib..temp1;
                        set  &comreport_templib..temp1 &comreport_templib..timeord(where=(not missing(ERRTXT)));
                        keep DIR QCNAME ERRNUM ERRTXT;
                    run;

                    /* Only time order issue */
                    proc sql noprint;
                        select distinct n(ERRTXT) into :comreport_timeord
                            from &comreport_templib..temp1;
                    quit;

                    data &comreport_templib..temp1;
                        set &comreport_templib..temp1;
                        if ERRTXT="QC passed" and &comreport_timeord > 1 then do;
                            ERRTXT="QC findings";
                            ERRNUM=2;
                        end;
                    run;
                /* End of loop for each non empty compare */
                %end;

                data &comreport_templib..temp2;
                    set &comreport_templib..combine&comreport_dirnum &comreport_templib..temp1;
                run;

                data &comreport_templib..combine&comreport_dirnum;
                    set &comreport_templib..temp2;
                run;
            /* End of loop for each compare */
            %end;
        /* End of loop for total number of files in each directory >=1 */
        %end;
        %else %if &comreport_fletot = 0 %then %do;
            data &comreport_templib..combine&comreport_dirnum;
                length DIR $1024 QCNAME $256 ERRTXT $200 ERRNUM 8;
                DIR="&&comreport_dir&comreport_dirnum";
                QCNAME="";
                ERRTXT="QC findings";
                ERRNUM=2;
                output;
                ERRTXT="  No compares selected for scanning in the directory";
                ERRNUM=3;
                output;
            run;
        %end;
    /* End of loop for exist compare */
    %end;
/* End of loop for each directory */
%end;

/* Combine all diretories */
data &comreport_templib..combine;
    set &comreport_templib..combine:;
    if not missing(ERRTXT);
    proc sort nodupkey;
    by DIR QCNAME ERRTXT ERRNUM;
run;

/* Create a library which directs to metadata and apply lockWait option to it - gcr_det */
%if %sysfunc(libref(metadata))=0 %then %do;
    libname %sysfunc(prxchange(s/gm/gs/, 1, &comreport_templib)) "%sysfunc(pathname(metadata))" filelockwait=&lockWait compress=y;

    %let comreport_locksyserrbefore=&syserr;

    data %sysfunc(prxchange(s/gm/gs/, 1, &comreport_templib)).gcr_det;
        set &comreport_templib..combine;
        proc sort;
        by DIR QCNAME ERRNUM ERRTXT;
    run;

    %let comreport_locksyserrafter=&syserr;

    libname %sysfunc(prxchange(s/gm/gs/,1,&comreport_templib));

    %if &comreport_locksyserrafter > &comreport_locksyserrbefore %then %do;
         %let comreport_errortext=&syserrortext;

         %gmMessage(codeLocation = gmCompareReport
                   , linesOut     = Macro aborted as metadata GCR_DET dataset is locked. %qLeft(&comreport_errortext);
                   , selectType   = ABORT
                   , printStdOut  = 1
                   , sendEmail    = &sendEmail
                   );
    %end;
%end;

/* Create macro varialbe for each directory */
proc sort data=&comreport_templib..combine out=&comreport_templib..dirlstuni(keep=DIR) nodupkey;
    by DIR;
run;

/* Directory having compares selected for scanning */
data _null_;
    set &comreport_templib..dirlstuni end=eod;
    call symputx("comreport_dir"||cats(_N_), DIR, "L");
    if eod then call symputx("comreport_dirtot", _N_);
run;

/* Create directory format */
data &comreport_templib..fmt;
    set &comreport_templib..dirlstuni;
    FMTNAME='gcrdir';
    START=DIR;
    LABEL=_N_;
    TYPE='I';
run;

proc format lib=&comreport_templib cntlin=&comreport_templib..fmt;
run;

/* Specify format catalogs to search */
options fmtsearch=(&comreport_templib);

/******************************************* Dataset for report part 2 *************************************/

proc freq data=&comreport_templib..combine noprint;
    table ERRTXT /out=&comreport_templib..frequence;
    by DIR;
    where not prxmatch("/\./", cats(ERRNUM));
run;

proc sql;
    create table &comreport_templib..frequence01 as
        select a.DIR, a.ERRTXT, a.COUNT
             , b.TOTAL, c.ERRNUM
        from &comreport_templib..frequence a
        left join
        (select DIR, sum(COUNT) as TOTAL
         from &comreport_templib..frequence(where=(ERRTXT in ("QC passed", "QC findings")))
         group by DIR) b
        on a.DIR=b.DIR
        left join
        (select distinct ERRTXT, ERRNUM
         from &comreport_templib..combine) c
        on a.ERRTXT=c.ERRTXT
        order by DIR, ERRNUM
        ;
quit;

data &comreport_templib..frequence01;
    length PERCENT $20;
    set &comreport_templib..frequence01;
    PERCENT=put(COUNT, 4.)||" / "||put(TOTAL, 4.)||" ("||put(round(COUNT/TOTAL*100, 1), 3.)||"%)";
    ID=input(DIR, gcrdir.);
    /* Compute variable */
    if ERRTXT="QC passed" then COMVAR="g";
    else if ERRNUM in (6, 7, 16 ,16.1) or 
           (ERRTXT in ("  There are 0 compares in the directory", "  No compares selected for scanning in the directory") and &subDir=1) then COMVAR="y";
    else COMVAR="r";
run;

proc sql;
    create table &comreport_templib..dirlst03 as
        select distinct ID-0.5 AS ID, DIR, DIR as ERRTXT length=1024
        from &comreport_templib..frequence01
        ;
quit;

data &comreport_templib..frequence01;
    length ERRTXT $1024;
    set &comreport_templib..frequence01 &comreport_templib..dirlst03;
    keep ID DIR ERRNUM ERRTXT PERCENT COMVAR;
run;

/* Assign PERCENT="   0 /    0" for there are 0 compares or no compare in one directory */
proc sql;
    create table &comreport_templib..frequence02 as
        select a.*, case when FLAG=1 and a.ERRTXT="QC findings" then "   0 /    0"
                         when a.ERRTXT in ("  There are 0 compares in the directory", "  No compares selected for scanning in the directory") then ""
                         else PERCENT_
                    end as PERCENT
            from &comreport_templib..frequence01(rename=PERCENT=PERCENT_) a
            left join 
            (select *, 1 as FLAG
             from &comreport_templib..frequence01(where=(ERRTXT in ("  There are 0 compares in the directory", "  No compares selected for scanning in the directory")))) b
            on a.DIR=b.DIR
            order by ID, DIR, ERRNUM, ERRTXT
            ;
quit;

/* Page variable */
proc sql;
    create table &comreport_templib..page11 as
        select distinct DIR, sum(not missing(DIR))+1 as NUM1 
        from &comreport_templib..frequence02
        group by DIR
        order by DIR;
quit;

data &comreport_templib..page12;
    set &comreport_templib..page11 end=eod;
    by DIR;
    retain PAGE 1 NUM1 0;
    %gmModifySplit(var=DIR, width=95, delimiter=~n, selectType=NOTE, wordBorder=\/);
    SPLIT=count(DIR, "~n");
    if _N_=1 or eod then BLANK=0;
    else BLANK=1;
    NUM2+NUM1+BLANK+SPLIT;
    if NUM2 >= 40 then do;
        PAGE+1;
        NUM2=NUM1;
    end;
    DIR=prxchange("s/(~n)//", -1, DIR);
run;

proc sql;
    create table &comreport_templib..page13 as
        select a.*, b.PAGE
            from &comreport_templib..frequence02 a
            left join &comreport_templib..page12 b
            on a.DIR=b.DIR
            order by PAGE, ID, DIR, ERRNUM, ERRTXT
            ;
quit;

/* Assign COMVAR="y" for issues are only check manually (yellow) */
proc sql;
    create table &comreport_templib..summary1 as
        select *, case when ERRNUM ^= . and sum(COMVAR_="y") >= 1 and sum(COMVAR_="r")=1 and ERRTXT^="QC passed" then "y"
                       else COMVAR_
                  end as COMVAR
        from &comreport_templib..page13(rename=COMVAR=COMVAR_)
        group by DIR
        order by PAGE, ID, DIR, ERRNUM, ERRTXT
        ;
quit;

/* Split the long folder name */
data &comreport_templib..summary1;
    set &comreport_templib..summary1;
    %gmModifySplit(var=ERRTXT, width=95, delimiter=~n, selectType=NOTE, wordBorder=\/);
run;

/******************************************* Dataset for report part 3 *************************************/

/* Page variable */
proc sql;
    create table &comreport_templib..page21 as
        select distinct DIR, QCNAME, sum(not missing(ERRTXT)) as NUM1 
        from &comreport_templib..combine
        group by DIR, QCNAME
        order by DIR, QCNAME;
quit;

data &comreport_templib..page22;
    set &comreport_templib..page21;
    by DIR QCNAME;
    retain PAGE 1 NUM1 0;
    if first.DIR or last.DIR then BLANK=0;
    else BLANK=1;
    NUM2+NUM1+BLANK;
    if first.DIR then do;
        PAGE=1;
        NUM2=NUM1;
    end;
    if NUM2 >= 40 then do;
        PAGE+1;
        NUM2=NUM1;
    end;
run;

proc sql;
    create table &comreport_templib..page23 as
        select a.*, b.PAGE
            from &comreport_templib..combine a
            left join &comreport_templib..page22 b
            on a.DIR=b.DIR and a.QCNAME=b.QCNAME
            order by 1,2,4,3
            ;
quit;

/* Compute variable */
data &comreport_templib..compvar;
    set &comreport_templib..page23;
    length IDC $256.;
    if ERRTXT="QC passed" then COMVAR="g";
    else if ERRNUM in (6, 7, 16 ,16.1) then COMVAR="y";
    else COMVAR="r";
    IDC=prxchange("s/(.+)\/(.+?)\//\u\2/", -1, DIR);
run;

/* Bookmarks */
data &comreport_templib..bookmark;
    set &comreport_templib..compvar;
    ID=input(DIR, gcrdir.);
    if not missing(ID);
    proc sort nodupkey;
        by ID;
run;

data _null_;
    set &comreport_templib..bookmark end=eof;
    call symputx("comreport_plabel"||cats(_N_), IDC, "L");
run;

/* Files having compare issues */
%let comreport_issname=;

proc sql noprint;
    select QCNAME, DIR into :comreport_issname separated by '", "', :comreport_issdir separated by '", "'
    from (select distinct DIR, QCNAME
          from &comreport_templib..compvar(where=(^ missing(QCNAME) and ERRTXT ^ in ("QC findings", "  Compare report is missing")))
          group by DIR, QCNAME
          having sum(ERRNUM>1) >= 1)
    ;
quit;

/* Add colon to ERRTXT */
data &comreport_templib..compvar;
    set &comreport_templib..compvar;
    ID=input(DIR, gcrdir.);
    QCNAME_=QCNAME;
    if ERRNUM in (3, 3.1, 3.3, 4, 5, 8, 9, 10, 16) 
       and ERRTXT ^ in ("  Compare report is missing", "  There are 0 compares in the directory", "  No compares selected for scanning in the directory") then ERRTXT=trim(ERRTXT)||":";
run;

%if &compareDetails=1 and "&comreport_issname" ^= "" %then %do;
    proc sql;
        create table &comreport_templib..compvaruni as
            select distinct DIR, QCNAME_, QCNAME
            from &comreport_templib..compvar
            where QCNAME in ("&comreport_issname") and DIR in ("&comreport_issdir")
            order by QCNAME
            ;
    quit;

    /* Compares with the same name and last modification datetime */
    data &comreport_templib..compvaruni;
        length QCNAME $500;
        set &comreport_templib..compvaruni;
        by QCNAME;
        QCNAME_=QCNAME;
        if first.QCNAME + last.QCNAME ^= 2 then do;
            if first.QCNAME then I=1;
            else I+1;
            QCNAME="~S={cellpadding=0pt color=blue}"||cats(QCNAME)||" ("||cats(I)||")";
        end;
        else do;
            QCNAME="~S={cellpadding=0pt color=blue}"||cats(QCNAME);
        end;
    run;

    data &comreport_templib..compvar;
        length QCNAME $500;
        if _n_=1 then do;   
            if 0 then set &comreport_templib..compvaruni;
            dcl hash h(dataset: "&comreport_templib..compvaruni");
            h.definekey("DIR", "QCNAME_");
            h.definedata(all: "y");
            h.definedone();
        end;
        set &comreport_templib..compvar;
        if h.find()=0 or h.find();
    run;        
%end;

/* Assign COMVAR="y" for issues are only check manually (yellow) */
proc sql;
    create table &comreport_templib..summary2 as
        select *, case when sum(COMVAR_="y") >= 1 and sum(COMVAR_="r")=1 then "y"
                       else COMVAR_
                  end as COMVAR
        from &comreport_templib..compvar(rename=COMVAR=COMVAR_)
        group by DIR, QCNAME
        order by ID, DIR, PAGE, QCNAME_, QCNAME, ERRNUM, ERRTXT, COMVAR
        ;
quit;

/****************************************** Dataset for report part 1 **************************************/

/* Total number of files in each directory */
data &comreport_templib..totfle1;
    length ID 8 DIR $1024 TOTFLEC $4 TOTFLEN 8;
    %do comreport_dirnum=1 %to &comreport_dirtot;
        ID=&comreport_dirnum;
        DIR="&&comreport_dir&comreport_dirnum";
        TOTFLEN=&&comreport_fletot&comreport_dirnum;
        TOTFLEC=put(TOTFLEN, 4.);
        output;
    %end;
run;

/* Total number of files in each directory selected for scanning */
proc sql;
    create table &comreport_templib..totfle2 as
        select distinct ID, DIR, input(scan(PERCENT, 3, " "), best.) as SCANEDFLE
        from &comreport_templib..summary1
        where ^ missing(PERCENT)
        order by ID, DIR
        ;
quit;

/* Percent */
proc sql;
    create table &comreport_templib..percent as
        select ID, DIR, sum(RNUM) as RNUM, sum(YNUM) as YNUM
        from (select distinct ID, DIR, QCNAME
                      , case when ^ missing(QCNAME) and sum(COMVAR_="r") >= 2 then 1
                             else 0
                        end as RNUM
                      , case when ^ missing(QCNAME) and sum(COMVAR_="y") >= 1 then 1
                             else 0
                        end as YNUM
             from &comreport_templib..summary2
             group by DIR, QCNAME)
        group by ID, DIR
        order by ID, DIR
        ;
quit;

/* Combine */
data &comreport_templib..summary0;
    merge &comreport_templib..totfle1 &comreport_templib..totfle2 &comreport_templib..percent;
    by ID DIR;
    length SPERCENT RPERCENT YPERCENT $12.;
    if TOTFLEC="   0" or SCANEDFLE=0 then do;
        SPERCENT="   0";
        RPERCENT="   0";
        YPERCENT="   0";
    end;
    else do;
        SPERCENT=put(SCANEDFLE, 4.)||" ("||put(round(SCANEDFLE/TOTFLEN*100, 1), 3.)||"%)";
        RPERCENT=put(RNUM, 4.)||" ("||put(round(RNUM/SCANEDFLE*100, 1), 3.)||"%)";
        YPERCENT=put(YNUM, 4.)||" ("||put(round(YNUM/SCANEDFLE*100, 1), 3.)||"%)";
    end;
    if RNUM=0 then RPERCENT="   0";
    if YNUM=0 then YPERCENT="   0";
    PAGE=1;
    keep PAGE ID DIR TOTFLEC TOTFLEN SCANEDFLE SPERCENT RPERCENT YPERCENT RNUM YNUM;
    proc sort;
        by PAGE ID DIR;
run;

/* Split the long folder name */
data &comreport_templib..summary0;
    set &comreport_templib..summary0;
    %gmModifySplit(var=DIR, width=60, delimiter=~n, selectType=NOTE, wordBorder=\/);
run;

/* Create a library which directs to metadata and apply lockWait option to it - gcr_sum */
%if %sysfunc(libref(metadata))=0 %then %do;
    libname %sysfunc(prxchange(s/gm/gs/, 1, &comreport_templib)) "%sysfunc(pathname(metadata))" filelockwait=&lockWait compress=y;

    %let comreport_locksyserrbefore=&syserr;

    data %sysfunc(prxchange(s/gm/gs/, 1, &comreport_templib)).gcr_sum;
        retain DIR TOTFLEN SPERCENT RPERCENT YPERCENT;
        set &comreport_templib..summary0;
        keep DIR TOTFLEN SPERCENT RPERCENT YPERCENT;
    run;

    %let comreport_locksyserrafter=&syserr;

    libname %sysfunc(prxchange(s/gm/gs/,1,&comreport_templib));

    %if &comreport_locksyserrafter > &comreport_locksyserrbefore %then %do;
         %let comreport_errortext=&syserrortext;

         %gmMessage(codeLocation = gmCompareReport
                   , linesOut     = Macro aborted as metadata GCR_SUM dataset is locked. %qLeft(&comreport_errortext);
                   , selectType   = ABORT
                   , printStdOut  = 1
                   , sendEmail    = &sendEmail
                   );
    %end;
%end;

/* Create the global macro variable gmCompareReportResult */
proc sql noprint;
    select gmcrResult into :gmCompareReportResult
    from (select case when sum(COMVAR="r") = 0 and sum(COMVAR="y") = 0 then "QCPassed"
                      when sum(COMVAR="r") >= 1 then "CompareIssues"
                      else "CheckManually"
                 end as gmcrResult
               from &comreport_templib..summary1) 
    ;
quit;

/****************************************** Dataset for report part 4 **************************************/

%if &compareDetails=1 %then %do;
    /* Files having compare issues */
    proc sql;
        create table &comreport_templib..summary31 as
            select distinct DIR, scan(QCNAME, 1, "/") as COMPARE length=256
            from &comreport_templib..summary2(where=(^ missing(QCNAME)))
            group by DIR, COMPARE
            having sum(ERRNUM>1) >= 1
            order by DIR, COMPARE
            ;
    quit;

    proc sql;
        create table &comreport_templib..summary32 as
            select distinct DIR
            from &comreport_templib..summary31
            order by DIR
            ;
    quit;

    /* Get the total number of files having compare issues */
    %let comreport_fletot=0;
    data _null_;
        set &comreport_templib..summary31 end=eod;
        length FLEREF $1024;
        COMPARE=prxchange("s/(~S=\{cellpadding=0pt color=blue\})//", 1, COMPARE);
        FLEREF=cats(DIR, COMPARE);
        call symputx("comreport_fleref"||cats(_N_), FLEREF, "L");
        call symputx("comreport_qcname"||cats(_N_), COMPARE, "L");
        if eod then call symputx("comreport_fletot", _N_);
    run;

    %if &comreport_fletot >=1 %then %do;
        proc sql;
            create table &comreport_templib..summary3 (FLEREF char(1024), RECORD char(256));
        quit;

        %do comreport_flenum=1 %to &comreport_fletot;
            data &comreport_templib..temp1;
                length FLEREF $1024 RECORDL $256;
                infile "&&comreport_fleref&comreport_flenum" length=reclen;
                input @1 RECORD $varying256. reclen;
                PAGE=1;
                FLEREF="&&comreport_fleref&comreport_flenum";
                RECORDL=cats(lag(RECORD));
            run;

            /* Check if compare is mpty */
            %let comreport_emptyfle=1;
            data _null_;
                set &comreport_templib..temp1;
                if compress(compress(RECORD, , "kw"))="" then delete;
                if ^ missing(RECORD) then call symputx("comreport_emptyfle", 0);
            run;

            %if &comreport_emptyfle=1 %then %do;
                data &comreport_templib..temp1;
                    set &comreport_templib..temp1;
                    if compress(compress(RECORD, , "kw"))="" then delete;
                run;
            %end;

            data &comreport_templib..temp2;
                set &comreport_templib..summary3 &comreport_templib..temp1;
            run;

            data &comreport_templib..summary3;
                set &comreport_templib..temp2;
                if not missing(FLEREF);
            run;
        %end;
    %end;
%end;

/* Produce eqc reports */
ods path work(read) sasuser.templat(update) sashelp.tmplmst(read);

proc template;
    define style comcheck /store=work;
         parent=styles.rtf;
         replace fonts /
            "docfont"=("courier new, Monospace 每encoding latin1",10pt)
            "headingfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "footfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "titlefont" = ("courier new, Monospace 每encoding latin1",10pt)
            "titlefont2" = ("courier new, Monospace 每encoding latin1",10pt)
            "title2font" = ("courier new, Monospace 每encoding latin1",10pt)
            "strongfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "emphasisfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "fixedemphasisfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "fixedstrongfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "fixedheadingfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "batchfixedfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "fixedfont" = ("courier new, Monospace 每encoding latin1",10pt)
            "headingemphasisfont" = ("courier new, Monospace 每encoding latin1",10pt);
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
             font_face = "Courier New, Courier, Monospace 每encoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style header from headersandfooters /
             protectspecialchars=off
             just=center
             font_face = "Courier New, Courier, Monospace 每encoding latin1"
             font_size = 10pt;
         style systemFooter /
             font_face = "Courier New, Courier, Monospace 每encoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style systemTitle /
             font_face = "Courier New, Courier, Monospace 每encoding latin1"
             font_size = 10pt;
         style Data /
             font_face = "Courier New, Courier, Monospace 每encoding latin1"
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

ods escapechar="~";
ods listing close;
goptions device=actximg;

%let comreport_papersz=letter;
options nodate nonumber nobyline orientation=landscape papersize=&comreport_papersz;

ods pdf file=gcr_rep style=comcheck pdftoc=1 uniform;

title1 "EQC Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.)))
 EST [Executed by %gmGetUserName]";

footnote1 j=c "Page ~{thispage} of ~{lastpage}";

/*********************************************** Report part 1 *********************************************/

ods proclabel="Summary of Compares Scanned";

title2 "Summary of Compares Scanned";

proc report data=&comreport_templib..summary0 nowd missing spacing=0 split="@" contents="";
    column PAGE ID DIR TOTFLEC TOTFLEN SCANEDFLE SPERCENT RPERCENT YPERCENT;

    define PAGE      / order noprint order=data;
    define ID        / order noprint order=data;
    define DIR       / order order=data style={cellwidth=50% just=l} "Directory";
    define TOTFLEC   / style={cellwidth=10% just=l} "Compares in@Directory";
    define TOTFLEN   / order noprint;
    define SCANEDFLE / order noprint;
    define SPERCENT  / style={cellwidth=12% just=l} "Compares@Scanned";
    define RPERCENT  / style={cellwidth=12% just=l} "Compare@Issues";
    define YPERCENT  / style={cellwidth=15% just=l} "Check Manually@Issues";

    compute SPERCENT;
        if SCANEDFLE=TOTFLEN then call define(_COL_, "style", "style={background=lightgreen}");
        else call define(_COL_, "style", "style={background=yellow}");
    endcomp;

    compute RPERCENT;
        if RPERCENT="   0" then call define(_COL_, "style", "style={background=lightgreen}");
        else call define(_COL_, "style", "style=[background=lightred]");
    endcomp;

    compute YPERCENT;
        if YPERCENT="   0" then call define(_COL_, "style", "style={background=lightgreen}");
        else call define(_COL_, "style", "style={background=yellow}");
    endcomp;

    break before PAGE / contents="" page;
run;

/*********************************************** Report part 2 *********************************************/

%if &compareDetails=1 %then %do;
    /* Link */
    proc sql;
        create table &comreport_templib..fmt as 
            select distinct DIR, QCNAME
            from &comreport_templib..summary2(where=(^ missing(QCNAME) and ERRTXT ^ in ("QC findings", "  Compare report is missing")))
            group by DIR, QCNAME
            having sum(ERRNUM>1) >= 1
            order by DIR, QCNAME
            ;
    quit;

    data &comreport_templib..fmt;
        set &comreport_templib..fmt;
        length LABEL $1024 START $500;
        FMTNAME='gcrlink';
        START=cats(QCNAME);
        LABEL=cats(DIR)||cats(prxchange("s/(~S=\{cellpadding=0pt color=blue\})(.+)\/.+/\2/", 1, QCNAME));
        LABEL="#"||cats(prxchange("s#\W##", -1, LABEL));
        TYPE="C";
    run;

    proc format lib=&comreport_templib cntlin=&comreport_templib..fmt;
    run;
%end;

ods proclabel="Summary (Overall)";

title2 "Summary of Messages Found in Scan";

proc report data=&comreport_templib..summary1 nowd missing spacing=0 split="@" contents="";
    column PAGE ID DIR ERRNUM ERRTXT PERCENT COMVAR;

    define PAGE    / order noprint order=internal;
    define ID      / order noprint order=internal;
    define DIR     / order noprint order=internal;
    define ERRNUM  / order noprint order=internal;
    define ERRTXT  / style={cellwidth=80% just=l} order order=data "Directory/@Message Type" flow;
    define PERCENT / style={cellwidth=19% just=l} "Number of Occurences/@Compares Scanned";
    define COMVAR  / noprint;

    compute after DIR;
        line "";
    endcomp;

    compute COMVAR;
        if COMVAR="g" then call define(_ROW_, "style", "style={background=lightgreen}");
        else if COMVAR="r" then call define(_ROW_, "style", "style={background=lightred}");
        else if COMVAR="y" then call define(_ROW_, "style", "style={background=yellow}");
    endcomp;

    break before PAGE / contents="" page;
run;

/*********************************************** Report part 3 *********************************************/

title2 "Details of Messages in Scan";

%do comreport_outnum=1 %to &comreport_dirtot;
    title4 "&&comreport_dir&comreport_outnum";

    ods pdf anchor="%sysfunc(prxchange(s#\W##, -1, %quote(&&comreport_dir&comreport_outnum)))anchor";
    ods proclabel="&&comreport_plabel&comreport_outnum";

    proc report data=&comreport_templib..summary2(where=(ID=&comreport_outnum and not missing(QCNAME))) nowd missing spacing=0 split="@" contents="";
        column ID DIR PAGE QCNAME_ QCNAME ERRTXT COMVAR;

        define ID      / order noprint order=internal;
        define DIR     / order noprint order=internal;
        define PAGE    / order noprint order=internal;
        define QCNAME_ / order noprint order=internal;
        define QCNAME  / style={cellwidth=39% just=l %if &compareDetails=1 and "&comreport_issname" ^= "" %then url=$gcrlink.;} order "Compare/Creation DateTime";
        define ERRTXT  / style={cellwidth=60% just=l} flow "Message Type";
        define COMVAR  / noprint;

        break after PAGE / page;

        compute after QCNAME;
            line "";
        endcomp;

        compute DIR;
            call define(_ROW_, "style", "style={background=lightgrey}");
        endcomp;

        compute COMVAR;
            if COMVAR="g" then call define("ERRTXT", "style", "style={background=lightgreen}");
            else if COMVAR="r" then call define("ERRTXT", "style", "style={background=lightred}");
            else if COMVAR="y" then call define("ERRTXT", "style", "style={background=yellow}");
        endcomp;

        break before ID / contents="" page;
    run;
%end;

/*********************************************** Report part 4 *********************************************/

%if &compareDetails=1 %then %do;
    %if &comreport_fletot >=1 %then %do;
        title2 "Compare Report Contents";

        %do comreport_outnum=1 %to &comreport_fletot;
        
            %let comreport_issdir=%sysfunc(prxchange(s#(.+)/.+#\1#, -1, %quote(&&comreport_fleref&comreport_outnum)));

            footnote1 link="#%sysfunc(prxchange(s#\W##, -1, %quote(&comreport_issdir)))anchor" "~S={color=blue}Return to Details of Messages in Scan";
            footnote3 j=c "Page ~{thispage} of ~{lastpage}";

            title4 j=l "Compare: &&comreport_fleref&comreport_outnum";

            ods proclabel="&&comreport_qcname&comreport_outnum";
            ods pdf anchor="%sysfunc(prxchange(s#\W##, -1, %quote(&&comreport_fleref&comreport_outnum)))";

            proc report data=&comreport_templib..summary3(where=(FLEREF="&&comreport_fleref&comreport_outnum")) nowd missing spacing=0 split="@" contents="";
                column PAGE RECORD COMVAR;

                define PAGE    / order noprint order=internal;
                define RECORD  / style={cellwidth=99% just=l} flow "Compare Text";
                define COMVAR  / noprint;

                break before PAGE / contents="" page;
            run;
        /* End of loop for each compare */
        %end;
    /* End of loop for total number of files in each directory >=1 */
    %end;
/* End of loop for &compareDetails=1 */
%end;

ods pdf close;
ods listing;

/* Close the pipe */
filename gcr_rep clear;

title;
footnote;

/* Create summary message */
%let comreport_totalFiles  = 0;
%let comreport_comIssues   = 0;
%let comreport_manIssues   = 0;
%let comreport_numExcluded = 0;

proc sql noprint;
    select sum(SCANEDFLE)
         , sum(RNUM)
         , sum(YNUM)
         , sum(TOTFLEN) - sum(SCANEDFLE) into
           :comreport_totalFiles separated by ' '
         , :comreport_comIssues separated by ' '
         , :comreport_manIssues separated by ' '
         , :comreport_numExcluded separated by ' '
        from &comreport_templib..summary0
        ; 
quit;

%gmMessage(codeLocation = gmCompareReport
          , linesOut     = Compare scanning completed - %str(&comreport_totalFiles checked, &comreport_comIssues compare issues, &comreport_manIssues check-manually issues, &comreport_numExcluded excluded.)
          , printStdOut  = &printStdOut.
          );

/* Send report to e-mail if required */
%if &sendEmail=1 %then %do;
    %local comreport_userEMail;

    data _null_;
        infile "~/.forward" lrecl = 256;
        input;
        if prxmatch("/^\S+@\S+$/", cats(_INFILE_)) then call symputx("comreport_userEMail", cats(_INFILE_));
    run;

    filename sendEm eMail
        subject="gmCompareReport summary"
        from="&comreport_userEMail"
        to="&comreport_userEMail"
        ct="text/html"
        ;

    proc template;
        define style gcrmail /store=work;
            parent=styles.default;
            replace fonts /
                "docfont"=("courier new, Monospace -encodining latin1",10pt)
                "headingfont" = ("courier new, Monospace -encodining latin1",10pt,bold roman)
                "titlefont" = ("courier new, Monospace -encodining latin1",10pt)
                "titlefont2" = ("courier new, Monospace -encodining latin1",10pt)
                "title2font" = ("courier new, Monospace -encodining latin1",10pt)
                "strongfont" = ("courier new, Monospace -encodining latin1",10pt)
                "emphasisfont" = ("courier new, Monospace -encodining latin1",10pt)
                "fixedemphasisfont" = ("courier new, Monospace -encodining latin1",10pt)
                "fixedstrongfont" = ("courier new, Monospace -encodining latin1",10pt)
                "fixedheadingfont" = ("courier new, Monospace -encodining latin1",10pt)
                "batchfixedfont" = ("courier new, Monospace -encodining latin1",10pt)
                "fixedfont" = ("courier new, Monospace -encodining latin1",10pt)
                "headingemphasisfont" = ("courier new, Monospace -encodining latin1",10pt);
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
    ods html body=sendEm style=gcrmail;

    options nocenter;

    ods text='Execution of gmCompareReport has completed.';
    ods text=' ';
    ods text="Full report can be found here: &comreport_epath";
    ods text=' ';

    option nocenter;

    proc report data=&comreport_templib..summary0 nowd missing spacing=0 split="@" contents="";
        column PAGE ID DIR TOTFLEC TOTFLEN SCANEDFLE SPERCENT RPERCENT YPERCENT;

        define PAGE      / order noprint order=data;
        define ID        / order noprint order=data;
        define DIR       / order order=data style={cellwidth=50% just=l} "Directory";
        define TOTFLEC   / style={cellwidth=10% just=l} "Compares in@Directory";
        define TOTFLEN   / order noprint;
        define SCANEDFLE / order noprint;
        define SPERCENT  / style={cellwidth=12% just=l} "Compares@Scanned";
        define RPERCENT  / style={cellwidth=12% just=l} "Compare@Issues";
        define YPERCENT  / style={cellwidth=15% just=l} "Check Manually@Issues";

        compute SPERCENT;
            if SCANEDFLE=TOTFLEN then call define(_COL_, "style", "style={background=lightgreen}");
            else call define(_COL_, "style", "style={background=yellow}");
        endcomp;

        compute RPERCENT;
            if RPERCENT="   0" then call define(_COL_, "style", "style={background=lightgreen}");
            else call define(_COL_, "style", "style=[background=lightred]");
        endcomp;

        compute YPERCENT;
            if YPERCENT="   0" then call define(_COL_, "style", "style={background=lightgreen}");
            else call define(_COL_, "style", "style={background=yellow}");
        endcomp;

        break before PAGE / contents="" page;
    run;

    ods html close;
    ods listing;
%end;

/* Drop two options which do not need to be reset - SAS changes them during OPTLOAD */
data &comreport_templib..options;
    set &comreport_templib..options(where=(OPTNAME not in ("SET", "CMPOPT")));
run;

/* Load the saved system option settings */
proc optload data=&comreport_templib..options;
run;

%gmEnd( headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcomparereport.sas $);

%mend gmCompareReport;