/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------
 
  Author:                Marcin Sosnowski, Dmitry Kolosov $LastChangedBy: kolosod $
  Creation Date:         21OCT2015  $LastChangedDate: 2016-04-23 05:22:50 -0400 (Sat, 23 Apr 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsvnreport.sas $
 
  Files Created:         Datasets containing results from scans:
                            metadata.gsr_sum
                         PDF file containing SVN report. The file is written to pathOut= location and named as per
                         fileOut= value.
 
  Program Purpose:       The macro generates SVN report for specific folder(s). Report includes:
                         * SVN status of all items.
                         * Check for presence of keywords in the header.
                         * Check of execution order by comparing dates of last modification, commit, log.
 
  Macro Parameters:

    Name:                pathsIn
      Allowed Values:    
      Default Value:     &_projpre 
      Description:       Full unix paths of directories to scan (separate multiple paths with splitChar).
 
    Name:                pathOut  
      Allowed Values:    
      Default Value:     &_global 
      Description:       Full unix path of directory to store report in.

    Name:                fileOut   
      Allowed Values:    default | projarea | full | user
      Default Value:     default
      Description:       Naming convention for report filename: 
                         #- default: gmSvnReport.pdf
                         #- projarea: dependent on project area, e.g. gmSvnReport_primary.pdf
                         #- full: dependent on project area and run date/time, e.g. gmSvnReport_primary_20140115T1338.pdf
                         #- user: dependent on user executing macro, e.g. gmSvnReport_clauss.pdf

    Name:                excludeFiles
      Allowed Values:     
      Default Value:     
      Description:       List of files to exclude from report. Supports regular expressions.
                         It is highly recommended not to use this parameter and to set up corresponding ignore patterns in SVN
                         instead.
                         #e.g. .*.log@.*sas7bdat

    Name:                noLogFiles 
      Allowed Values:     
      Default Value:     autoexec.sas@setup.sas
      Description:       List of SAS files for which datetime checks for log/program/commit are not performed. Supports regular expressions.
                         #e.g. autoexec.sas@setup.sas

    Name:                noLogDirs
      Allowed Values:    
      Default Value:     &_macros
      Description:       List of directories for which datetime checks for log/program/commit are not performed. Supports regular expressions.
                         #e.g. &_macros@&_global 

    Name:                dateCheckKeyword         
      Default Value:     
      Description:       If the checkKeyword flag is enabled, keywords are checked only for programs 
                         with commit date after the specified date. Can be required for old studies
                         where only some programs are updated. Date should provided in 
                         ISO 8601 format, e.g. 2010-12-31.
                         
    Name:                printStdOut         
      Allowed Values:    0|1
      Default Value:     1
      Description:       Flag which defines whether a summary message is printed to STDOUT.

    Name:                sendEmail   
      Allowed Values:    0|1
      Default Value:     0 
      Description:       Send email to user on completion of execution (0=No, 1=Yes) with summary report.
                         Also controls if ABORT messages are sent to user by e-mail.

    Name:                lockWait
      Allowed Values:    0 - 600
      Default Value:     30
      Description:       Number of seconds SAS waits in case output dataset is locked.

    Name:                splitChar
      Allowed Values:    
      Default Value:     @
      Description:       Split character used to separate items in parameters pathsIn, excludeFiles, noLogFiles, noLogDirs.

    Name:                metadataIn
      Allowed Values:    
      Default Value:     metadata.global
      Description:       Dataset containing metadata.
 
  Macro Returnvalue:     N/A
 
  Global Macrovariables:

    Name:                _global
      Usage:             read
      Description:       Path to global directory.

    Name:                _projpre
      Usage:             read
      Description:       Project directory.

    Name:                _type
      Usage:             read
      Description:       Delivery type.

    Name:                _macros
      Usage:             read
      Description:       Path to macro directory.

  Metadata Keys:

    Name:                svnDateCheckKeyword
      Description:       If the checkKeyword flag is enabled, keywords are checked only for programs 
                         with commit date after the specified date. Can be required for old studies
                         where only some programs are updated. Date should provided in 
                         ISO 8601 format, e.g. 2010-12-31.

  Macro Dependencies:    gmGetUserName (called)
                         gmExecuteUnixCmd (called) 
                         gmModifySplit (called)
                         gmMessage (called)
                         gmStart (called)
                         gmEnd (called)
 
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2195 $
-----------------------------------------------------------------------------*/
%macro gmsvnreport(
                    pathsIn         = &_projpre.
                   ,pathOut         = &_global.
                   ,fileOut         = default
                   ,excludeFiles    =
                   ,noLogFiles      = autoexec.sas@setup.sas
                   ,noLogDirs       = &_macros.   
                   ,dateCheckKeyword =
                   ,printStdOut     = 1
                   ,sendEmail       = 0
                   ,lockWait        = 30
                   ,splitChar       = @
                   ,metadataIn      = metadata.global
                   );

  %local gsr_tmplib;

  %let gsr_tmplib= %gmStart( headURL            = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsvnreport.sas $
                           , revision           = $Rev: 2195 $ 
                           , librequired        = 1
                           , checkMinSasVersion = 9.2
                           );
  
  %* Save options;
  proc optsave out=&gsr_tmpLib..options;
  run;

  option noquotelenmax compress=Y ibufsize=32760;

  %local
    gsr_svnPath
    gsr_tmpdir
    gsr_map_st
    gsr_map_pl
    gsr_tmplib
    gsr_utc_offset
    gsr_time_zone
    gsr_xmlEngine
    gsr_svnPathsIn
    gsr_mapPath
    gsr_numExcluded
    gsr_totalFiles    
    gsr_totalErrors   
    gsr_totalWarnings 
    gsr_sambaPath 
  ;

  %let gsr_svnPath = /opt/subversion_server_1.7.7/bin/svn;

  /* Get location of maps */
  %let gsr_mapPath = %sysFunc(prxChange(s#.*/svnrepo/\w*/(.*)/\w*\.sas.*#/opt/pxlcommon/stats/macros/$1/#,1,
$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsvnreport.sas $
                                        ));

  %let gsr_map_st = &gsr_mapPath.map_st.xml;
  %let gsr_map_pl = &gsr_mapPath.map_pl.xml;
  /* Set XML engine to XML for 9.2 and XMLV2 for 9.3+ */
  %if "&sysVer" = "9.2" %then %do;
    %let gsr_xmlEngine = XML;
  %end;
  %else %do;
    %let gsr_xmlEngine = XMLV2;
  %end;

  /*Kennet store in EST time zone while SVN in UTC. Difference between EST and UTC is 5 hours*/
  %let gsr_time_zone = %gmExecuteUnixCmd(cmds = echo $TZ);
  
  %if "&gsr_time_zone" eq "EST5EDT@" %then %do;
    %let gsr_utc_offset = 14400;
  %end;
  %else %if "&gsr_time_zone" eq "EST@" %then %do;
    %let gsr_utc_offset = 18000;
  %end;
  %else %do;
    %gmMessage( codeLocation = gmSvnReport/Initializing local parameters
              , linesOut     = %str(Unknown OS time zone &gsr_time_zone )
              , selectType   = ABORT
              , splitChar    = @
              );
  %end;
  
  %let gsr_tmpdir=%sysfunc(PATHNAME(&gsr_tmplib))/gmsvnreport/;
   
  %gmExecuteUnixCmd(cmds=mkdir -p &gsr_tmpdir);
   
  /*Make all macro parameters upcase for safety reasons*/

  %let fileOut        = %upcase(&fileOut);

/*----------------------------------------------------------------------------------------------------------------------------------
Start check input parameters 
----------------------------------------------------------------------------------------------------------------------------------*/  
  
  /*Start checking pathOut and dependent params*/
  %if "&pathOut"="" %then %do;
    %gmMessage( codeLocation=gmSvnReport/Parameter checks
              , linesOut=pathOut not specified
              , selectType=ABORT
              , printStdOut=1
              );
  %end;
  %else %do;
    filename gsr_out "&pathOut";
    %local gsr_doutexist;
    %let gsr_doutexist=0;
    data _null_;
      call symputx ('gsr_doutexist',put(fexist('gsr_out'),best.));
    run;
    
    %if "&gsr_doutexist" eq "1" %then %do;
      /* Get execution date/time for title and file name */
      data _null_;
        length date time $20;
        date = put(date(),is8601da.);
        time = put(time(),tod5.);
        call symputx("svnReportTitle_dt",strip(date)||" "||strip(time),"L");
        call symputx("svnReportFile_dt",prxChange("s/[:-]//",-1,compress(date||"T"||time)),"L");
        /*Check if last charter in pathOut is slash '/' - if not append it*/
        gsr_chk=char("&pathOut",length("&pathOut"));
        if gsr_chk ne '/' then call symputx('pathOut',cats("&pathOut",'/'));
      run;
      /* Generate filename for output pdf file */
      %if %superQ(fileOut)=DEFAULT %then %do;
        filename gsr_rep "&pathOut.gmSvnReport.pdf";
        %let gsr_sambaPath = \\kennet%qSysFunc(prxChange(s/\//\\/,-1,%qTrim(&pathOut.gmSvnReport.pdf)));
        %let gsr_sambaPath = %qSysFunc(prxChange(s/^\\\\kennet\\project(\d+|s)/\\\\kennet/,1,&gsr_sambaPath));
      %end;
      %else %if %superQ(fileOut)=USER %then %do;
        filename gsr_rep "&pathOut.gmSvnReport_&sysUserId..pdf";
        %let gsr_sambaPath = \\kennet%qSysFunc(prxChange(s/\//\\/,-1,%qTrim(&pathOut.gmSvnReport_&sysUserId..pdf)));
        %let gsr_sambaPath = %qSysFunc(prxChange(s/^\\\\kennet\\project(\d+|s)/\\\\kennet/,1,&gsr_sambaPath));
      %end;
      %else %if %superQ(fileOut)=PROJAREA %then %do;
        %if %symexist(_type) %then %do;
          filename gsr_rep "&pathOut.gmSvnReport_&_type..pdf";
          %let gsr_sambaPath = \\kennet%qSysFunc(prxChange(s/\//\\/,-1,%qTrim(&pathOut.gmSvnReport_&_type..pdf)));
          %let gsr_sambaPath = %qSysFunc(prxChange(s/^\\\\kennet\\project(\d+|s)/\\\\kennet/,1,&gsr_sambaPath));
        %end;
        %else %do;
          %gmMessage(codeLocation = gmSvnReport/Parameter check
          , linesOut     = Macro variable (_type) does not exist.
          , selectType   = ABORT
          , printStdOut  = 1
          );
        %end;
      %end;
      %else %if %superQ(fileOut)=FULL %then %do;
        %if %symexist(_type) %then %do;
          filename gsr_rep "&pathOut.gmSvnReport_&_type._&svnReportFile_dt..pdf";
          %let gsr_sambaPath = \\kennet%qSysFunc(prxChange(s/\//\\/,-1,%qTrim(&pathOut.gmSvnReport_&_type._&svnReportFile_dt..pdf)));
          %let gsr_sambaPath = %qSysFunc(prxChange(s/^\\\\kennet\\project(\d+|s)/\\\\kennet/,1,&gsr_sambaPath));
        %end;
        %else %do;
          %gmMessage(codeLocation = gmSvnReport/Parameter check
          , linesOut     = Macro variable (_type) does not exist.
          , selectType   = ABORT
          , printStdOut  = 1
          );
        %end;
      %end;
      %else %do;
        %gmMessage( codeLocation=gmSvnReport/Parameter checks
                  , linesOut=FileOut parameter value (&fileOut.) is not supported. 
                  , selectType=ABORT
                  , printStdOut=1
                  );
      %end;    
      /*FileOut checks*/
    %end;
    %else %do;
      %gmMessage( codeLocation = gmSvnReport/Parameter checks
                , linesOut     = Directory pathOut (%superQ(pathOut)) does not exist.
                , selectType   = ABORT
                , splitChar    = @
                , printStdOut=1
                );
    %end;
  %end;
  /*End checking pathOut*/
  /* Delete current output file if exists */
  %if %sysFunc(fexist(gsr_rep)) %then %do;
    data _null_;      
      rc = fdelete("gsr_rep");
    run;
  %end;

  /* check printstdout */
  %if %superQ(printStdOut) ne 0 and %superQ(printStdOut) ne 1 %then %do;
    %gmMessage( codeLocation = gmSvnReport/Parameter checks
              , linesOut     = Value of macro parameter printStdOut (%superq(printStdOut)) is invalid.
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %end;

  /* Check lockWait */
  %if %superQ(lockWait) < 0 or %superQ(lockWait) > 600 %then %do;
    %gmMessage( codeLocation = gmSvnReport/Parameter checks
              , linesOut     = Value of macro parameter lockWait (%superq(lockWait)) is invalid. It must be an integer value between 0 and 600.
              , selectType   = ABORT
              , printStdOut=1
              );
  %end;

  /* Check sendEmail */
  %if %superQ(sendEmail) ne 0 and %superQ(sendEmail) ne 1 %then %do;
    %gmMessage( codeLocation = gmSvnReport/Parameter checks
              , linesOut     = Value of macro parameter sendEmail (%superQ(sendEmail)) is invalid.
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %end;
  
  %if "&pathsIn"="" %then %do;
    %gmMessage( codeLocation=gmSvnReport/Parameter checks
              , linesOut=pathsIn not specified.
              , selectType=ABORT
              , printStdOut=1
              );
  %end;
  %else %do;
    data _null_;
      length rc splitChar $10 svnPathLine pathsIn $32767 currentPath $4096 ;
      splitChar = symGet("splitChar");
      pathsIn = resolve('&pathsIn');

      /* Escape special characters */
      if splitChar in ('$','\','/','@') then do;
        splitChar = '\'||strip(splitChar);
      end;
      else do;
        splitChar = '\Q'||strip(splitChar)||'\E';
      end;

      /* Convert projectXX to /projects */
      if prxMatch("#(^|"||strip(splitChar)||")\s*/project\d+#",strip(pathsIn)) then do;
        pathsIn = prxChange("s#(^|"||strip(splitChar)||")\s*/project\d+#$1/projects#",-1,strip(pathsIn));
      end;
    
      /* Check each path exists */
      i = 1;
      do while(scan(pathsIn,i,splitChar) ne "");
        currentPath = scan(pathsIn,i,splitChar);
        if not fileExist(currentPath) then do;
          rc = resolve('%gmMessage(codeLocation = gmSvnReport/Parameter checks,'
                       ||' linesOut = %str(Directory from PathsIn ('||strip(currentPath)||') does not exist.)'
                       ||", selectType   = ABORT, splitChar    = @, printStdOut=1);"
                      );
        end;
        i = i + 1;
      end;

      /* Create line, which can be parsed by SVN command */
      /* Path1@Path2 -> 'Path1'@ 'Path2'@ (adding @ to avoid special usage of @ in SVN) */
      svnPathLine = "'" || strip(prxChange("s/\s*"||strip(splitChar)||"\s*/'\@ '/",-1,pathsIn)) ||"'@";
      call symputx("gsr_svnPathsIn",strip(svnPathLine),"L");
    run;
  %end;

  /*Check if directory is under version control if not abort*/
  %let gsr_resp_st = %gmExecuteUnixCmd(  
         cmds            = &gsr_svnPath st %superQ(gsr_svnPathsIn) -v --xml > &gsr_tmpdir.gsr_st.xml 2>&gsr_tmpdir.errLog.txt || echo 'Execution failed.'
       , numberRecordLength = 32768 
       , splitCharIn = %sysFunc(byte(178))
       );

  %let gsr_svnst=&gsr_tmpdir.gsr_st.xml;
  
  %let gsr_resp_pl = %gmExecuteUnixCmd
          ( 
          cmds                = &gsr_svnPath pl -v -R --xml %superQ(gsr_svnPathsIn) > &gsr_tmpdir.gsr_pl.xml || echo 'Execution failed.'
          , numberRecordLength = 32768 
          , splitCharIn = %sysFunc(byte(178))
          );
               
  %let gsr_svnpl=&gsr_tmpdir.gsr_pl.xml;

  /* Check metadata library exists */
  %if %sysFunc(libRef(metadata)) ne 0 %then %do;
     %gmMessage(codeLocation=gmSvnReport/Metadata libname check
               , linesOut=Metadata libname not assigned.
               , selectType=ABORT
               , printStdOut=1
               );
  %end;

  /* Check splitChar */ 
  %if %length(%superQ(splitChar)) ne 1 %then %do;
    %if not %sysFunc(exist(&metadataIn)) %then %do;
      %gmMessage(codeLocation=gmSvnReport/Parameter check
                , linesOut=SplitChar value (%superQ(splitChar)) is incorrect. Must be a single character.
                , selectType=ABORT
                , printStdOut=1
                );
    %end;
  %end;

  /* Check custom metadata exists */ 
  %if "%superQ(metadataIn)" ne "metadata.global" and "%superQ(metadataIn)" ne "" %then %do;
    %if not %sysFunc(exist(&metadataIn)) %then %do;
      %gmMessage(codeLocation=gmSvnReport/Metadata check
                , linesOut=Custom metadata file does not exist.
                , selectType=ABORT
                , printStdOut=1
                );
    %end;
  %end;

  /* Try to fetch date for keyword checking from the metadata*/
  %if %sysFunc(exist(&metadataIn)) %then %do;
    data _null_;
      set &metadataIn.;
      length gsr_rc $200;
      gsr_rc = " ";
      if upcase(key) = "SVNDATECHECKKEYWORD" and not missing(value) then do;
        %if "%superQ(dateCheckKeyword)" eq "" %then %do;
          call symput("dateCheckKeyword",strip(value));
        %end;
        %else %do;
          if strip(value) ne strip("&dateCheckKeyword.") then do;
            gsr_rc = resolve('%gmMessage(codeLocation=gmSvnReport/parameter check, linesOut='
            ||'dateCheckKeyword argument differs from &metadataIn.' 
            ||'@svnDateCheckKeyword value. dateCheckKeyword has been used.);'
            );
          end;
        %end;
      end;
    run;
  %end;

  %* Check dateCheckKeyword is in ISO 8601 format;
  %if %sysFunc(prxMatch(/^\d{4}-[01]\d-[0123]\d$/,%superQ(dateCheckKeyword))) ne 1 and "%superQ(dateCheckKeyword)" ne "" %then %do;
    %gmMessage( codeLocation = gmSvnReport/Parameter checks
              , linesOut     = %str(Parameter(key) for keyword check date = &dateCheckKeyword. must be in the ISO 8601 format (yyyy-mm-dd).)
              , selectType   = ABORT
              , splitChar    = @
              );
  %end;
  
/*----------------------------------------------------------------------------------------------------------------------------------
End check input parameters 
----------------------------------------------------------------------------------------------------------------------------------*/

  /*Import xml file witch was generated*/

  filename gsr_path "&gsr_tmpdir.gsr_st.xml"; 

  filename gsr_map "&gsr_map_st";

  libname gsr_path &gsr_xmlEngine. xmlmap=gsr_map;

  proc sql noprint;
    create table &gsr_tmplib..st_data as 
    select e.path as path, props, item, wc.revision, author, date
    from gsr_path.wc_status as wc
    left join gsr_path.entry as e
    on wc.entry_ordinal = e.entry_ordinal
    left join gsr_path.commit as c
    on wc.wc_status_ordinal = c.wc_status_ordinal
    left join gsr_path.target as t
    on e.target_ordinal = t.target_ordinal
    order by path
    ;
    quit;

    filename gsr_map;
    filename gsr_path;

    filename gsr_path "&gsr_tmpdir.gsr_pl.xml";

    filename gsr_map "&gsr_map_pl";

    libname gsr_path &gsr_xmlEngine. xmlmap=gsr_map;

  proc sql noprint;
    create table &gsr_tmplib..pl_data as 
    select path, property, name
    from gsr_path.target as t
    left join gsr_path.property as p
    on t.target_ordinal = p.target_ordinal
    where name eq 'svn:keywords'

        /* order by t.target_ordinal, p.property_ordinal */
    order by path
    ;
    quit;

    filename gsr_map;
    filename gsr_path;
    libname gsr_path;

  data &gsr_tmplib..all_svn;
    merge &gsr_tmplib..st_data &gsr_tmplib..pl_data(keep=path property);
    by path;
  run;

  /* Convert commit datetime and short to server time zone */
  data &gsr_tmplib..st_data2;
    attrib cidtm format=datetime19.  label='Commit date - numeric';
    set &gsr_tmplib..all_svn;

    drop date;

    if not missing(date) then do;
      cidtm=input(date,E8601DT.);
    end;
    /* SVN time is show in UTC TimeZone, convert to the server TZ */
    if not missing(cidtm) then do;
      cidtm=cidtm-&gsr_utc_offset;
      /* Apply Daylight saving time offset */
      if nWkDoM(2,1,3,year(datePart(ciDtm)))* 3600*24 + 3600 * 2
         >= ciDtm >=
         nWkDoM(1,1,11,year(datePart(ciDtm))-1)* 3600*24 + 3600 * 2
      then do;
        cidtm=cidtm-3600;
      end;
    end;

    if not missing(ciDtm) then do;
      ciDt = datePart(ciDtm);
    end;
  run;

  /* Identify files and directories */
  data &gsr_tmplib..st_data3;
    set &gsr_tmplib..st_data2;

    isSAS = not(not (prxmatch('/(\.sas$)/i',(strip(path)))  )); /*Transform to boolean result*/

    length path_log $4096;

    if isSAS then do;
      path_log=prxchange('s/\.sas$/.log/i',1,strip(path));
      exist_log=fileexist(path_log);
    end;

    itemExist = fileExist(path);

    /* Identify directories and files*/
    drop gsr_rc gsr_fid;  
    if itemExist then do;
      gsr_rc = filename("gsr_chk",strip(path));
      /* Try to open as a file */
      gsr_fid = fopen("gsr_chk");
      if gsr_fid > 0 then do;
        isDir = 0;
        isFile = 1;
        gsr_rc = fclose(gsr_fid);
      end;
      else do;
        gsr_fid = dopen("gsr_chk");
        if gsr_fid > 0 then do;
          isDir = 1;
          isFile = 0;
          gsr_rc = dclose(gsr_fid);
        end;
      end;
      gsr_rc = filename("gsr_chk");
    end;

    /* If physical path was reported, change to symlink */
    if isDir and prxMatch("#^/project\d+/#",strip(path)) then do;
        path = prxChange("s#^/project\d+/#/projects/#",1,path);
    end;

    /* Unify directory names - end with slash */
    if isDir and not prxMatch("#/$#",trim(path)) then do;
        path = trim(path) || "/";
    end;

    length fileName $255 dir $4096;
    /* Extract file name */
    /* In case item is missing, assume it to be a file */
    if isFile or itemExist = 0  then do;
      fileName = prxchange('s/(\/.+)+(\/)(.+)/$3/',1,strip(path));
    end;
    /* Extract folder name */
    if not missing(path) then do;
      dir = prxChange("s/(\/.*\/)(.*)/$1/",1,strip(path));
    end;

    /* Flag files which should not be reported */
    if _N_ = 1 then do;
      length splitChar $10 excludeFilesPattern $32767;
      retain splitChar excludeFilesPattern;
      drop excludeFilesPattern;
      splitChar = symGet("splitChar");
      excludeFilesPattern = symGet("excludeFiles");
      /* Escape special characters */
      if splitChar in ('$','\','/','@') then do;
        splitChar = '\'||strip(splitChar);
      end;
      else do;
        splitChar = '\Q'||strip(splitChar)||'\E';
      end;
      /* Remove trailing and leading blanks between items*/
      /* Replace splitChar with | */
      if not missing(excludeFilesPattern) then do;
        excludeFilesPattern = prxChange("s/\s*"||strip(splitChar)||"\s*/|/",-1,strip(excludeFilesPattern));
      end;
    end;

    if not missing(excludeFilesPattern) then do;
      if isFile and prxMatch("/^("|| strip(excludeFilesPattern) ||")$/",strip(fileName)) then do;
        excludeFile = 1;
      end;
    end;
  run;

  /* Identify SAS files for which LOGs should be checked */
  data &gsr_tmplib..st_data4;
    set &gsr_tmplib..st_data3(where = (excludeFile ne 1));
    /* Identify files for which log does not need to be checked */
    if _N_ = 1 then do;
      length noLogFiles noLogDirs $32767;
      retain noLogFiles noLogDirs;
      drop splitChar noLogFiles noLogDirs;
      noLogFiles = symGet("noLogFiles");
      noLogDirs = resolve('&noLogDirs'); 
      /* Remove trailing and leading blanks between items*/
      /* Replace splitChar with | */
      if not missing(noLogFiles) then do;
        noLogFiles = prxChange("s/\s*"||strip(splitChar)||"\s*/|/",-1,strip(noLogFiles));
      end;
      if not missing(noLogDirs) then do;
        noLogDirs = prxChange("s/\s*"||strip(splitChar)||"\s*/|/",-1,strip(noLogDirs));
        /* Fix repeating slash */
        noLogDirs = prxChange("s/\/+/\//",-1,strip(noLogDirs));
      end;
    end;

    /* Default checkLog flag to 1 */
    if isSAS then do;
      checkLog = 1;
    end;
    /* Exclude directories */
    if isSAS and not missing(noLogDirs) then do;
      if prxMatch("#^("||strip(noLogDirs)||")/?$#",strip(dir)) then do;
        checkLog = 0;
      end;
    end;
    /* Exclude files */
    if isSAS and not missing(noLogFiles) then do;
      if prxMatch("/^("||strip(noLogFiles)||")$/",strip(fileName)) then do;
        checkLog = 0;
      end;
    end;
  run;

  /*Get dates from OS*/
  data &gsr_tmplib..os_dates(label="Data set with dates");
    attrib
    moddate_log length=$100.
    logdtm format=datetime19.
    fileDtm format=datetime19.
    ;
    length moddate_file tmpdt_file tmpdt_log $200;
    set &gsr_tmplib..st_data4 ;

    if _N_ = 1 then do; 
      retain re1 re2;
        /*Re1 - regular expression for dates obtion from kennet i.e. "Thu Jan 21 04:56:33 2016"*/
      re1 = prxparse('/([A-Za-z]{3})(\s)([A-Za-z]{3})(\s{1,2})(\d{1,2})(\s)(\d{2}:\d{2}:\d{2})(\s)(\d{4})/'); 
      re2 = prxparse('s/([A-Za-z]{3})(\s)([A-Za-z]{3})(\s{1,2})(\d{1,2})(\s)(\d{2}:\d{2}:\d{2})(\s)(\d{4})/$5$3$9:$7/'); 
    end; 

    /* Get log information */
    if checkLog = 1 and  exist_log and isSAS then do;
      rc_log=filename("gsr_log",path_log); 
      fid_log=fopen("gsr_log"); 

      /* Get date and convert to numeric */
      moddate_log=finfo(fid_log,'Last Modified');
      if prxmatch(re1,strip(moddate_log)) then do;
        tmpdt_log=prxchange(re2,1,moddate_log);
        logdtm=input(tmpdt_log,datetime18.);
      end;

      close_log=fclose(fid_log); 
      rc_log=filename("gsr_log"); 
    end;  

    /* Get file information */
    if itemExist and isFile then do;
      rc_file=filename("gsr_file",path,,"lRecL=32767"); 
      fid_file=fopen("gsr_file"); 

      /* Get date and convert to numeric */
      moddate_file=finfo(fid_file,'Last Modified');
      if prxmatch(re1,strip(moddate_file)) then do;
        tmpdt_file=prxchange(re2,1,moddate_file);
        fileDtm=input(tmpdt_file,datetime18.);
      end;
      if isSAS then do;
        /* Check keywords */
        dateKeyword = 0;
        revKeyword = 0;
        authorKeyword = 0;
        urlKeyword = 0;
        if fid_file ne 0 
        %if %superQ(dateCheckKeyword) ne %then %do;
          and ciDt >= input("&dateCheckKeyword",E8601DA.)
        %end;
        then do;
          do while (fread(fid_file) = 0);
            length codeLine $32767;
            drop codeLine rc_read;
            rc_read = fget(fid_file,codeLine,32767);
            %* Search for keywords or their aliases;
            if prxMatch("/\$(Date|LastChangedDate):.*\$/",strip(codeLine)) then do;
              dateKeyword = 1;
            end;

            if prxMatch("/\$(Revision|Rev|LastChangedRevision):.*\$/",strip(codeLine)) then do;
              revKeyword = 1;
            end;

            if prxMatch("/\$(Author|LastChangedBy):.*\$/",strip(codeLine)) then do;
              authorKeyword = 1;
            end;

            if prxMatch("/\$(HeadURL|URL):.*\$/",strip(codeLine)) then do;
              urlKeyword = 1;
            end;

            %* If all keywords were found, no need to continue;
            if urlKeyword and authorKeyword and dateKeyword and revKeyword then do;
              leave;
            end;
          end; /* While loop */ 
        end; /* If opened */
      end; /* If SAS */
      close_file=fclose(fid_file); 
      rc_file=filename("gsr_file"); 
    end;

    /* Convert dates to character */
    length fileDtmC logDtmC ciDtmC $19;

    if not missing(fileDtm) then do;
      fileDtmC = trim(left(put(datePart(fileDtm),is8601da.)))||' '||trim(left(put(timepart(fileDtm),tod8.)));
    end;

    if not missing(logDtm) then do;
      logDtmC = trim(left(put(datePart(logDtm),is8601da.)))||' '||trim(left(put(timepart(logDtm),tod8.)));
    end;

    if not missing(ciDtm) then do;
      ciDtmC = trim(left(put(datePart(ciDtm),is8601da.)))||' '||trim(left(put(timepart(ciDtm),tod8.)));
    end;
  run;

  data &gsr_tmplib..colors;
    length col5 $1000;
    label col5 ='Variable with description of issue';
    set &gsr_tmplib..os_dates;

    /* In case directory SVN status is wrong, output it in the first line */
    if isDir and upcase(item) ne "NORMAL" then do;
      col1 = dir;
      %gmModifySplit(var=col1,width=54,wordBorder=\/,selectType=NOTE,delimiter=~n);
      error_flg=1;
      error_id+1;
      col5='Unexpected SVN status: '|| strip(propcase(item)) ;
      output;ord+1;
    end;

    /* Continue for non-directories */
    if not isDir; 

    col1=strip(fileName)||'/'||strip(fileDtmc);
    %gmModifySplit(var=col1,width=54,wordBorder=\/,selectType=NOTE,delimiter=~n);
    ord0+1;
    col5='';
    call missing(error_id,warning_id,error_flg,warning_flg);


    /**********/
    /* Errors */
    /**********/

    /* Log Does not Exist*/
    if isSas and exist_log = 0 and checkLog = 1 then do;
      error_flg=1;
      error_id+1;
      col5 = "Program does not have log file";
      output;ord+1;
    end;

    /* SVN issues*/
    if upcase(item) not in ('MODIFIED','UNVERSIONED','NORMAL','MISSING') then do;
      error_flg=1;
      error_id+1;
      col5='Unexpected SVN status: '|| strip(propcase(item)) ;
      output;ord+1;
    end;
    else if upcase(item) eq 'UNVERSIONED' or missing(cidtm) then do;
      error_flg=1;
      error_id+1;
      col5='File is not under version control';
      output;ord+1;
    end;
    else if upcase(item) eq 'MODIFIED' then do;
      error_flg=1;
      error_id+1;
      col5='Last change was not committed';
      output;ord+1;
    end;
    else if upcase(item) eq 'MISSING' THEN DO;
      error_flg=1;
      col5='File is in SVN, but removed from the local server';
      output;ord+1;
    end;  

    /* Check SVN property settings */
    if isSAS and not( upcase(item) eq 'UNVERSIONED' or missing(cidtm) ) then do;
      if missing(property) then do;
        error_flg=1;
        error_id+1;
        col5="SVN keywords property is not set.";
        output;ord+1;
      end;
      else do;
        if not index(upcase(property),"AUTHOR") or not index(upcase(property),"URL") or not index(upcase(property),"REV") 
          or not index(upcase(property),"DATE") then do;
          error_flg=1;
          error_id+1;
          col5='Not all required SVN properties are set.';
          output;ord+1;
          col5='  Required list: Author URL Rev Date ';
          output;ord+1;
          col5='  Current list: ' || strip(property);
          output;ord+1;
        end;
      end;
    end;

    /* Check program header for required keywords */
    if (isSAS and not missing(fileDtm)) and (revKeyword ne 1 or authorKeyword ne 1 or dateKeyword ne 1 or urlKeyword ne 1) 
      %if %superQ(dateCheckKeyword) ne %then %do;
       and ciDt >= input("&dateCheckKeyword",E8601DA.) 
      %end;
    then do;
      error_flg=1;
      error_id+1;
      col5 = "Program header does not have all required SVN keywords.";
      output;ord+1;
      col5 = "  Missing keywords:";
      /* Identify missing keywords */
      if authorKeyword = 0 then do;
        col5 = trim(col5) || " LastChangedBy";
      end;
      if revKeyword = 0 then do;
        col5 = trim(col5) || " Rev";
      end;
      if dateKeyword = 0 then do;
        col5 = trim(col5) || " LastChangedDate";
      end;
      if urlKeyword = 0 then do;
        col5 = trim(col5) || " HeadURL";
      end;
      output;ord+1;
    end;

    /* Check execution order - applicable only if logs are checked */
    /** Log before commit date **/ 
    if cidtm gt logdtm and cmiss(cidtm,logdtm) eq 0 and isSAS and checkLog  eq 1 and upcase(item) eq "NORMAL" then do;
      error_flg=1;
      error_id+1;
      col5='Program was not run after last commit';
      output;ord+1;
      COL5='  Commit date - '||cidtmc;
      output;ord+1;
      col5='  Log date    - '||logdtmc;
      output;ord+1;
    end;     

    /************/
    /* Warnings */
    /************/

    /* Check execution order - applicable only if logs are checked */
    /** SVN before LOG before SAS **/ 
    if fileDtm gt logdtm gt cidtm and cmiss(logdtm,cidtm,fileDtm) eq 0 and isSAS and checkLog eq 1 and upcase(item) eq 'NORMAL' then do;
      warning_flg=1;
      warning_id+1;
      col5='Issue with files timestamps(program vs log vs commit)';
      output;ord+1;
      col5='  Commit datetime  - '||cidtmc;
      output;ord+1;
      col5='  Log datetime     - '||logdtmc;
      output;ord+1;
      col5='  Program datetime - '||fileDtmc;
      output;ord+1;
    end;


    if sum(error_flg,warning_flg,0) eq 0 then do;
      col5='No findings';
      output;ord+1;
    end;

  run;

  /* Get number of lines per each file */
  proc SQL;
    create table &gsr_tmplib..lineCount as
      select ord0, count(*) as lineCount
      from  &gsr_tmplib..colors
      group by ord0
    ;
  quit;

  data &gsr_tmplib..byFileSummary0;
    merge &gsr_tmplib..colors &gsr_tmplib..lineCount; 
    by ord0;  
  run;

  proc sort data = &gsr_tmplib..byFileSummary0;
    by dir ord0 ord;
  run;

  data &gsr_tmplib..byFileSummary;
    set &gsr_tmplib..byFileSummary0 end=lastObs;
    by dir ord0 ord;

    /* Count pages */
    /* Initialize linenum on 2 to reserve 2 lines for directory */
    retain page 0 lineNum 3 dirNum 0;

    if first.dir then do;
      dirNum = dirNum + 1;
      length bookmarkName $256;
      drop bookmarkName;
      /* Extract directory name */
      bookmarkName = prxChange("s#.*/(.+/.+)/$#$1#",1,strip(dir));
      /* Replace escapeCharacter */
      bookmarkName = prxChange("s/~/-/",-1,strip(bookmarkName));
      call symputx("gsr_dir"||strip(put(dirNum,best.)),bookmarkName,"L");
    end;

    if first.ord0 then do;    
      /* For each new file check if need a new page */
      /* Each directory starts a new page */
      if lineNum + lineCount > 39 or first.dir then do;
        page = page + 1;
        lineNum = 3 + lineCount + countC(col1,"~") + 1;
      end;
      else do;
        /* If new page is not needed add lines for the current file and 1 blank line */
        lineNum = lineNum + lineCount + countC(col1,"~") + 1;
      end;
    end;

    if lastObs then do;
      call symputx("gsr_dirNum",dirNum,"L");
    end;
  run;


/*----------------------------------------------------------------------------------------------------------------------------------
STEP 
   Create overall summary
----------------------------------------------------------------------------------------------------------------------------------*/

  proc SQL;
  /* Keep only 1 records per file */
    create table &gsr_tmplib..uniqueFileSummary as
    select dir, fileName
    ,ifn(sum(error_flg)>0,1,0) as error_flg
    ,ifn(sum(warning_flg)>0,1,0) as warning_flg
    ,ifn((calculated warning_flg + calculated error_flg) = 0,1,0) as clean_flg
    from &gsr_tmplib..colors
    group by dir, fileName
    ;
  /* Calculate number of files/errors/warnings per directory */
    create table &gsr_tmplib..overAllSummaryRaw as
    select dir, count(distinct(fileName)) as numFiles, sum(clean_flg) as numClean
           ,sum(error_flg) as numErr, sum(warning_flg) as numWarn
    from &gsr_tmplib..uniqueFileSummary
    group by dir   
    ;
    quit;

  data &gsr_tmplib..overAllSummary;
    set &gsr_tmplib..overAllSummaryRaw;

    * Dummy variable for bookmarks;
    bookmarkFlag = 1;

    * Convert counts to character;
    length numFilesC numErrC numWarnC $11;

    if numFiles > 0 then do;

      numFilesC = put(numFiles,4.);

      if numErr > 0 then do;      
        numErrC = put(numErr,4.)||' ('||put(round((numErr/numFiles)*100,1),3.)||'%)';
      end;
      else do;
        numErrC = put(numErr,4.);
      end;

      if numWarn> 0 then do;      
        numWarnC = put(numWarn,4.)||' ('||put(round((numWarn/numFiles)*100,1),3.)||'%)';
      end;
      else do;
        numWarnC = put(numWarn,4.);
      end;
    end;
    else do;
      /* There are no files in directory */
      numFilesC = put(numFiles,4.);
      numErrC = put(numErr,4.);
      numWarnC = put(numWarn,4.);
    end;
    /* Split in case of long directory name */
    %gmModifySplit(var=dir,width=79,wordBorder=\/,selectType=NOTE,delimiter=~n);
  run;

/*----------------------------------------------------------------------------------------------------------------------------------
STEP 
  Create summary for output files scanned 
----------------------------------------------------------------------------------------------------------------------------------*/

  %let gsr_totalFiles    = 0;
  %let gsr_totalErrors   = 0;
  %let gsr_totalWarnings = 0;

  proc SQL noprint;
    select sum(numFiles) into :gsr_totalFiles
    from &gsr_tmplib..overAllSummary
    ; 
    select sum(numErr) into :gsr_totalErrors
    from &gsr_tmplib..overAllSummary
    ; 
    select sum(numWarn) into :gsr_totalWarnings
    from &gsr_tmplib..overAllSummary
    ; 
  quit;

/*----------------------------------------------------------------------------------------------------------------------------------
STEP 
  Create summary of excluded files 
----------------------------------------------------------------------------------------------------------------------------------*/

  %let gsr_numExcluded = 0;

  proc SQL noprint;
  /* Count number of excluded files */
    select count(*) into :gsr_numExcluded
    from &gsr_tmplib..st_data3
    where excludeFile = 1
  ;
  quit;

  %if gsr_numExcluded > 0 %then %do;
    data  &&gsr_tmplib..excludedSummary0(keep = text color bookmarkFlag lineOrder);
      set &gsr_tmplib..st_data3(where = (excludeFile = 1)) end=lastObs;

      length sasList $32767;
      retain sasList "" lineOrder 0;

      bookmarkFlag = 1;

      if isFile and prxMatch("/.*\.sas$/i",strip(fileName)) then do;
        if missing(sasList) then do;
          sasList = strip(fileName);
        end;
        else do;
          sasList = strip(sasList)||", "||strip(fileName);
        end;
      end;

      if lastObs then do;
        length text $32767 color $10;
        color = "yellow";
        lineOrder=lineOrder + 1;
        if &gsr_numExcluded eq 1 then do;
          text = "There was 1 file";
        end;
        else do;
          text = "There were " || strip(symget("gsr_numExcluded")) || " files";
        end;
        text = strip(text) || " excluded from the report using the excludeFiles parameter with value ("
              || strip(prxChange("s/\s*"||strip(splitChar)||"\s*/, /",-1,symget("excludeFiles"))) 
              ||"). Any files which should not be in the SVN control should be ignored in SVN, rather than"
              || " excluded from the report.";
        output;
        if not missing(sasList) then do;
          color = "lightred";
          lineOrder=lineOrder + 1;
          text = "SAS files must not be excluded from the report and should be either committed or ignored in SVN."
                 ||" The following SAS files were excluded:";
          output;
          color = "lightred";
          text = sasList;
          output;
        end;
        color = "none";
        lineOrder=lineOrder + 1;
        text = 'For more information about how to ignore files, please refer to the following page:';
        output;
        text = '~S={URL="http://statwiki.pxl.int/wiki/index.php/Ignoring_Items_in_SVN" color=blue}Ignoring Items in SVN.';
        output;
      end;
    run;

    data  &&gsr_tmplib..excludedSummary;
      set &gsr_tmplib..excludedSummary0;

      %gmModifySplit(var=text,width=118,selectType=NOTE,delimiter=~n);
    run;
  %end;

/*----------------------------------------------------------------------------------------------------------------------------------
 Write dataset to metadata 
----------------------------------------------------------------------------------------------------------------------------------*/

  /* Create a library which directs to metadata and apply lockWait option to it */
  libName %sysFunc(prxChange(s/gm/gs/,1,&gsr_tmpLib)) "%sysFunc(pathName(metadata))" fileLockWait=&lockWait compress=Y;

  %let gsr_lockSysErrBefore = &sysErr.;

  data %sysFunc(prxChange(s/gm/gs/,1,&gsr_tmpLib.)).gsr_sum;
    set &gsr_tmpLib..byFileSummary; 
    
    keep author authorKeyword ciDtmC cidtm dateKeyword dir 
         fileDtm fileDtmC fileName isDir isFile isSAS item 
         itemExist logDtmC logdtm path property props revKeyword 
         revision urlKeyword col5;
    rename col5 = issueText;

    label col5 = " ";

  run;

  %let gsr_lockSysErrAfter = &sysErr.;

  libName %sysFunc(prxChange(s/gm/gs/,1,&gsr_tmpLib));

  %if &gsr_lockSysErrAfter > &gsr_lockSysErrBefore %then %do;
     %let gsr_errorText = &sysErrorText;
     %gmMessage(codeLocation=gmSvnReport/Metadata output
        , linesOut=Macro aborted as metadata GSR_SUM dataset is locked. %qLeft(&gsr_errorText);
        , selectType=ABORT
        , sendEmail=&sendEmail
        , printStdOut=1
     );
  %end;

/*----------------------------------------------------------------------------------------------------------------------------------
  create ods template;
----------------------------------------------------------------------------------------------------------------------------------*/
  ods path work(write) sasuser.templat(update) sashelp.tmplmst(read);

  proc template;
      define style gmSvnReport /store=work;
           parent=styles.rtf;
           replace fonts /
              "docfont"=("courier new, Monospace -encoding latin1",10pt)
              "headingfont" = ("courier new, Monospace -encoding latin1",10pt)
              "footfont" = ("courier new, Monospace -encoding latin1",10pt)
              "titlefont" = ("courier new, Monospace -encoding latin1",10pt)
              "titlefont2" = ("courier new, Monospace -encoding latin1",10pt)
              "title2font" = ("courier new, Monospace -encoding latin1",10pt)
              "strongfont" = ("courier new, Monospace -encoding latin1",10pt)
              "emphasisfont" = ("courier new, Monospace -encoding latin1",10pt)
              "fixedemphasisfont" = ("courier new, Monospace -encoding latin1",10pt)
              "fixedstrongfont" = ("courier new, Monospace -encoding latin1",10pt)
              "fixedheadingfont" = ("courier new, Monospace -encoding latin1",10pt)
              "batchfixedfont" = ("courier new, Monospace -encoding latin1",10pt)
              "fixedfont" = ("courier new, Monospace -encoding latin1",10pt)
              "headingemphasisfont" = ("courier new, Monospace -encoding latin1",10pt);
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
               font_face = "Courier New, Courier, Monospace -encoding latin1"
               font_size = 10pt
               linkcolor=_undef_;
           style header from headersandfooters /
               protectspecialchars=off
               just=center
               font_face = "Courier New, Courier, Monospace -encoding latin1"
               font_size = 10pt;
           style systemFooter /
               font_face = "Courier New, Courier, Monospace -encoding latin1"
               font_size = 10pt
               linkcolor=_undef_;
           style systemTitle /
               font_face = "Courier New, Courier, Monospace -encoding latin1"
               font_size = 10pt;
           style Data /
               font_face = "Courier New, Courier, Monospace -encoding latin1"
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

  title '';
  title1 "SVN Check Performed On &svnReportTitle_dt. EST [Executed by %gmGetUserName]";
  footnote1 j=c "Page ~{thispage} of ~{lastpage}";

  options nodate nonumber orientation=landscape;

  ods escapechar = "~";
  ods listing close;

  ods pdf file=gsr_rep style=gmsvnreport compress=0 pdftoc=1 uniform;

  /* Note about excluded files */
  %if gsr_numExcluded > 0 %then %do;
    ods proclabel 'Excluded Files';
    title2 "Files Excluded from Report";

    proc report data=&gsr_tmplib..excludedSummary nowd noheader headskip missing spacing=2 split="@" contents='';
      col bookmarkFlag lineOrder text color;
      define bookmarkFlag / order noprint;
      define lineOrder / order noprint;
      define text / order style={cellwidth=99% just=l} flow;
      define color / order noprint;

      break before bookmarkFlag / contents='' page;

      compute before lineOrder;
        line "";
      endcomp;

      compute color;
        if color = "yellow" then do;
          call define(_row_, "style", "STYLE=[BACKGROUND=yellow]");
        end;
        else if color = "lightred" then do;
          call define(_row_, "style", "STYLE=[BACKGROUND=lightred]");
        end;
      endcomp;
    run;
  %end;

  /* Overall summary */ 
  ods proclabel 'Summary';
  title2 "Summary of Files Checked";

  proc report data=&gsr_tmplib..overAllSummary nowd headline headskip missing spacing=2 split="@" contents='';
    col bookmarkFlag dir numClean numErr numWarn numFiles numFilesC numErrC numWarnC ;
    define bookmarkFlag / order noprint;
    define dir          / order style={cellwidth=66% just=l} "Directory";
    define numFiles     / noprint;
    define numFilesC    / style={cellwidth=10% just=l} "Files@Checked";
    define numClean     / noprint;
    define numErr       / noprint display;
    define numErrC      / style={cellwidth=10% just=l} "Issues";
    define numWarn      / noprint display;
    define numWarnC     / style={cellwidth=13% just=l} "Check Manually@Issues";

    break before bookmarkFlag / contents='' page;

    compute numErrC;
      if numErr = 0 then do;
        call define(_col_, "style", "STYLE=[BACKGROUND=lightgreen]");
      end;
      else do; 
        call define(_col_, "style", "STYLE=[BACKGROUND=lightred]");
      end;
    endcomp;

    compute numWarnC;
      if numWarn= 0 then do;
        call define(_col_, "style", "STYLE=[BACKGROUND=lightgreen]");
      end;
      else do; 
        call define(_col_, "style", "STYLE=[BACKGROUND=yellow]");
      end;
    endcomp;
  run;

  /* By file summary */
  ods proclabel 'Details of Issues';
  title2 "Details of Issues Found";

  /* Iterate by directory to create bookmarks */
  %do gsr_i = 1 %to &gsr_dirNum;
    ods proclabel "%superQ(gsr_dir&gsr_i)";
    proc report data=&gsr_tmplib..byFileSummary(where = (dirNum = &gsr_i.)) 
      nowd headline headskip missing spacing=2 split="@" contents="";
      col page error_flg warning_flg dir ord0 col1 ord  fileDtm cidtm item  col5;
      define page           / order  noprint;
      define dir            / order  noprint;
      define ord0           / order  noprint;
      define ord            / order  noprint;
      define item           / noprint;
      define cidtm          / noprint  display;
      define fileDtm        / noprint  display;
      define error_flg      / noprint  display;
      define warning_flg    / noprint  display;
      define col1           / order 'File/Modification Date Time'   style={cellwidth=45% just=l};
      define col5           / order 'Issue summary' style={cellwidth=54% just=l};

      break before page / contents='' page;

      compute before dir ;
        line @1 '~S={font_face = "Courier New, Courier, Monospace -encoding latin1"}Directory: ' dir $4096.;
        line @1 ' ';
      endcomp; 

      compute after ord0;
        line "";
      endcomp;

      compute col5;
        if error_flg eq  1 then  do;
          call  define(_col_, "style", "style=[background=lightred]");
        end;

        if warning_flg eq  1 then  do;
          call  define(_col_, "style", "style=[background=yellow]");
        end;

        if cmiss(warning_flg,error_flg) eq 2 then do;
          call  define(_col_, "style", "style=[background=lightgreen]");
        end;  
      endcomp;

      compute col1;
        call define(_col_, "style", "style=[background=lightgrey]");
      endcomp;

    run;
  %end;

  ods pdf close;
  ods listing;

  filename gsr_rep clear;

  /* Strip reporting variables */
  %let gsr_totalFiles = &gsr_totalFiles;
  %let gsr_totalErrors = &gsr_totalErrors;
  %let gsr_totalWarnings = &gsr_totalWarnings;
  %let gsr_numExcluded = &gsr_numExcluded;

  %gmMessage( codeLocation = gmSvnReport
              ,linesOut = %str(&gsr_totalFiles checked, &gsr_totalErrors issues, &gsr_totalWarnings check-manually issues, &gsr_numExcluded excluded.) 
              ,printStdOut = &printStdOut.
            );

  /* Send report to e-mail with completion */
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
      subject = "gmSvnReport summary"
      from= "&glsr_userEMail."
      to = "&glsr_userEMail."
      ct = "text/html"
    ;

    proc template;
      define style gsrmail /store=work;
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
    ods html body = sendEm style = gsrmail;
    title;
    footnote;

    ods text='Execution of gmSvnReport has completed.';
    ods text=' ';
    ods text="Full report can be found here: &gsr_sambaPath.";
    ods text=' ';

    option nocenter;

    proc report data=&gsr_tmplib..overAllSummary nowd headline headskip missing spacing=2 split="@" contents='';
      col bookmarkFlag dir numClean numErr numWarn numFiles numFilesC numErrC numWarnC ;
      define bookmarkFlag / order noprint;
      define dir          / order style={cellwidth=66% just=l} "Directory";
      define numFiles     / noprint;
      define numFilesC    / style={cellwidth=10% just=l} "Files@Checked";
      define numClean     / noprint;
      define numErr       / noprint display;
      define numErrC      / style={cellwidth=10% just=l} "Issues";
      define numWarn      / noprint display;
      define numWarnC     / style={cellwidth=13% just=l} "Check Manually@Issues";

      break before bookmarkFlag / contents='' page;

      compute numErrC;
        if numErr = 0 then do;
          call define(_col_, "style", "STYLE=[BACKGROUND=lightgreen]");
        end;
        else do; 
          call define(_col_, "style", "STYLE=[BACKGROUND=lightred]");
        end;
      endcomp;

      compute numWarnC;
        if numWarn= 0 then do;
          call define(_col_, "style", "STYLE=[BACKGROUND=lightgreen]");
        end;
        else do; 
          call define(_col_, "style", "STYLE=[BACKGROUND=yellow]");
        end;
      endcomp;
    run;

    ods html close;
    ods listing;
  %end;

  /* Restore options */
  /* Drop two options which do not need to be reset - SAS changes them during OPTLOAD */
  data &gsr_tmpLib..options;
      set &gsr_tmpLib..options(where = (optName not in ("SET","CMPOPT")));
  run;

  proc optload data=&gsr_tmpLib..options;
  run;

  title;
  footnote;

  %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsvnreport.sas $);

%mend gmsvnreport;
