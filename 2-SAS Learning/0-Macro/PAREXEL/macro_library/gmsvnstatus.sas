/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dmitry Kolosov  $LastChangedBy: kolosod $
  Creation Date:         10SEP2015 $LastChangedDate: 2016-09-21 04:59:45 -0400 (Wed, 21 Sep 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsvnstatus.sas $

  Files Created:         N/A

  Program Purpose:       Check SVN status of a specified program or a program calling the macro. 
                         The SVN status is reported to the log. The macro performs checks 
                         in batch mode only.

                         # The following checks are performed:
                         * Check whether file content is committed
                         * Check whether SVN properties are committed
                         * Check whether required properties are set (Author, URL, Rev, Date) 
                         * Check whether program code contains required SVN keywords or default aliases
                         (Date|LastChangedDate;Revision|LastChangedRevision|Rev;Author|LastChangedBy;HeadURL|URL)

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                fileIn 
      Description:       Keep missing to check the currently executed sas file. Otherwise provide a full path and file name, 
                         of the file which should be checked. If the value contains HeadURL keyword, then it will be used
                         to derive path and filename.

    Name:                selectType         
      Allowed Values:    E|ERROR|ABORT
      Default Value:     ERROR
      Description:       Action taken in case SVN status of the checked program 
                         is invalid. See the gmMessage macro description for details.

    Name:                printStdOut         
      Allowed Values:    0|1
      Default Value:     1
      Description:       Flag which defines whether a message is printed to STDOUT
                         in case SVN status is invalid.

    Name:                checkKeyword         
      Allowed Values:    0|1
      Default Value:     1
      Description:       Check program code for SVN keywords. When the flag is set to 1 
                         and the code does not have required keywords, ERROR:[PXL] is 
                         printed to the log and ABORT is called (depending on selectType value).

    Name:                dateCheckKeyword         
      Default Value:     
      Description:       If the checkKeyword flag is enabled, ERROR:[PXL] is printed only for programs 
                         with commit date after the specified date. Can be required for old studies
                         where only some programs are updated. Date should provided in 
                         ISO 8601 format, e.g. 2010-12-31.

    Name:                metadataIn
      Default Value:     metadata.global
      Description:       Dataset containing metadata.

  Macro Returnvalue:     N/A

  Metadata Keys:

    Name:                svnDateCheckKeyword
      Description:       If the checkKeyword flag is enabled, ERROR:[PXL] is printed only for programs 
                         with commit date after the specified date. Can be required for old studies
                         where only some programs are updated. Date should provided in 
                         ISO 8601 format, e.g. 2010-12-31.

      Dataset:           Global
                          
  Macro Dependencies:    gmMessage (called)
                         gmExecuteUnixCmd (called)
                         gmStart (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2610 $
-----------------------------------------------------------------------------*/

%macro gmSvnStatus(fileIn           =,
                   selectType       = ERROR,
                   printStdOut      = 1,
                   checkKeyword     = 1,
                   dateCheckKeyword =,
                   metadataIn       = metadata.global
                  );

    %* Initiate environment; 
    %gmStart(headURL   = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsvnstatus.sas $,
             revision  = $Rev: 2610 $,
             checkMinSasVersion=9.2
            );

    %local svnStatus_sysIn         /* SYSIN option */
           svnStatus_sysInEscaped  /* Escaped version of path to file for SVN */
           svnStatus_pgmName       /* Program name */
           svnStatus_svnPath       /* Path to SVN executable */
           svnStatus_status        /* Status of a program */
           svnStatus_response      /* Temp var for Unix Cmd reponse */
           svnStatus_itemStatus    /* SVN Item status */
           svnStatus_propStatus    /* SVN Property status */
           svnStatus_quoteLenMax   /* Value of the quoteLenMax option */
           svnStatus_mInOperator   /* Value of the mInOperator option */
           svnStatus_keywordStatus /* Keyword status */
           svnStatus_commitDate    /* Date the program was last committed */
           svnStatus_repoName      /* Repository name from HeadURL */
    ;

    %* Try to fetch date for keyword checking from the metadata;
    %if %sysFunc(exist(&metadataIn)) %then %do;
        data _null_;
            set &metadataIn.;
            length gmSvnSRc $200;
            gmSvnSRc = " ";
            if upcase(key) = "SVNDATECHECKKEYWORD" and not missing(value) then do;
                %if "%superQ(dateCheckKeyword)" eq "" %then %do;
                    call symput("dateCheckKeyword",strip(value));
                %end;
                %else %do;
                    if strip(value) ne strip("&dateCheckKeyword.") then do;
                        gmSvnSRc = resolve('%gmMessage(codeLocation=gmSvnStatus/parameter check, linesOut='
                                           ||'dateCheckKeyword argument differs from metadata.global' 
                                           ||'@svnDateCheckKeyword value. dateCheckKeyword has been used.);'
                                          );
                    end;
                %end;
            end;
        run;
    %end;

    %* Check parameters;
    %* Check selectType is E, ERROR or ABORT;
    %if %sysFunc(prxMatch(/^(E|ERROR|ABORT)$/,%superQ(selectType))) ne 1 %then %do;
      %gmMessage( codeLocation = gmSvnStatus/Parameter checks
                , linesOut     = %str(Parameter selectType= &selectType. has an invalid value.
                                      @Please choose E,ERROR or ABORT.)
                , selectType   = ABORT
                , splitChar    = @
                );
    %end;

    %* Check the checkKeyword value;
    %if %superQ(checkKeyword) ne 1 and %superQ(checkKeyword) ne 0 %then %do;
        %gmMessage( codeLocation = gmSvnStatus/Parameter checks
                  , linesOut     = %str(Parameter checkKeyword = %superQ(checkKeyword) has an invalid value, please choose 1 or 0.)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;

    %* Check the printStdout value;
    %if %superQ(printStdOut) ne 1 and %superQ(printStdOut) ne 0 %then %do;
        %gmMessage( codeLocation = gmSvnStatus/Parameter checks
                  , linesOut     = %str(Parameter printStdOut = %superQ(printStdOut) has an invalid value, please choose 1 or 0.)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;

    %* Check dateCheckKeyword is in ISO 8601 format;
    %if %sysFunc(prxMatch(/^\d{4}-[01]\d-[0123]\d$/,%superQ(dateCheckKeyword))) ne 1 and "%superQ(dateCheckKeyword)" ne "" %then %do;
      %gmMessage( codeLocation = gmSvnStatus/Parameter checks
                , linesOut     = %str(Parameter(key) for keyword check date = &dateCheckKeyword. must be in the ISO 8601 format (yyyy-mm-dd).)
                , selectType   = ABORT
                , splitChar    = @
                );
    %end;

    %* Check dateCheckKeyword is provided when checkKeyword is enabled;
    %if "%superQ(dateCheckKeyword)" ne "" and &checkKeyword ne 1 %then %do;
      %gmMessage( codeLocation = gmSvnStatus/Parameter checks
                , linesOut     = %str(Parameter for keyword check date must be used only when checkKeyword is set to 1.)
                , selectType   = ABORT
                , splitChar    = @
                );
    %end;

    %* Set noQuoteLenMax option to avoid possible messaged produced by long OS response;
    %let svnStatus_quoteLenMax = %sysFunc(getOption(quoteLenMax));
    %* Fix a SAS bug by disabling the mInOperator option for the run of the macro;
    %let svnStatus_mInOperator = %sysFunc(getOption(mInOperator));
    option noQuoteLenMax noMInOperator;

    %if %superQ(fileIn) ne %then %do;
        %* Check if HeadURL keyword was used as a filename;
        %if %sysFunc(prxMatch(/^\$(HeadURL|URL): \S.+\S \$$/,%superQ(fileIn))) %then %do;
            %* Try to parse the repository name;
            %let svnStatus_repoName = %qSysFunc(prxChange(s#.*?svnrepo/(.*?)/.*#$1#,1,%superQ(fileIn)));
            %if not %sysFunc(prxMatch(/^(LP|EP)_(UN)?BLINDED_.+_.+$/,&svnStatus_repoName)) %then %do;
                %gmMessage(codeLocation = gmSvnStatus,
                           linesOut     = Cannot parse the repository name from HeadURL.,
                           selectType   = &selectType.,
                           printStdOut  = &printStdOut.
                          );
                %return;
            %end;
            %* Form the path from the repository name;
            %let svnStatus_sysIn = %sysFunc(prxChange(s#^LP_BLINDED#/projects#,1,&svnStatus_repoName.));
            %let svnStatus_sysIn = %sysFunc(prxChange(s#^LP_UNBLINDED#/unblinded#,1,&svnStatus_sysIn.));
            %let svnStatus_sysIn = %sysFunc(prxChange(s#^EP_#/ep/#,1,&svnStatus_sysIn.));
            %let svnStatus_sysIn = %lowCase(%sysFunc(prxChange(s#_(.+)_([^_]+)\s*$#/$1/$2#,-1,&svnStatus_sysIn.)));
            %* Add the last part;
            %let svnStatus_sysIn = &svnStatus_sysIn./%qSysFunc(prxChange(s#.*?svnrepo/.*?/(.*?)\s*\$#$1#,1,%superQ(fileIn)));
        %end;
        %else %do;
            %let svnStatus_sysIn = %superQ(fileIn);
        %end;

        %* Verify the file exists;
        %if not %sysFunc(fileExist(&svnStatus_sysIn.)) %then %do;
            %gmMessage(codeLocation = gmSvnStatus,
                       linesOut     = File %superQ(svnStatus_sysIn) does not exist or HeadURL could not be parsed.,
                       selectType   = &selectType.,
                       printStdOut  = &printStdOut.
                      );
            %return;
        %end;
    %end;
    %else %do;
        %* Get the current program name;
        %let svnStatus_sysIn = %qSysFunc(getOption(sysIn));
    %end;
    %let svnStatus_pgmName = %qScan(&svnStatus_sysIn,-1,/);

    %* Escape the path for SVN;
    %let svnStatus_sysInEscaped = %str(%')%superQ(svnStatus_sysIn)%str(%')@;
     
    %* In case of STDIO mode set the svnStatus_pgmName to missing;
    %if &svnStatus_pgmName = __STDIN__ %then %do;
        %let svnStatus_pgmName =;
    %end;

    %* Check SVN status in batch mode only;
    %if &svnStatus_pgmName ne %then %do;

        %* Set path to SVN command;
        %let svnStatus_svnPath = /opt/subversion_server_1.7.7/bin/svn;

        %* Get status of the current file;
        %let svnStatus_response = %gmExecuteUnixCmd
                     (
                      cmds               = &svnStatus_svnPath st -v --xml &svnStatus_sysInEscaped,
                      numberRecordLength = 32768,
                      splitCharIn        = `,
                      details            = 0
                     );

        %* Analyze the response;
        %if %index(&svnStatus_response,warning: W155007:) %then %do;
            %* Folder is not under version control;
            %let svnStatus_status = %bQuote(W155007: is not a working copy.);
        %end;
        %else %if %index(&svnStatus_response,wc-status) %then %do;
            %* Get item and properties status;
            %let svnStatus_itemStatus = %qSysFunc(prxChange(s/.*\@\s+item=.(\w+).*/$1/,1,&svnStatus_response.));
            %let svnStatus_propStatus = %qSysFunc(prxChange(s/.*\@\s+props=.(\w+).*/$1/,1,&svnStatus_response.));
            %* Get commit date for keyword checks;
            %if %index(&svnStatus_response,<date>) %then %do;
                %let svnStatus_commitDate = %qSysFunc(prxChange(s/.*\@<date>(.*)T.*/$1/,1,&svnStatus_response.));
            %end;
            %else %do;
                %* If the file was not committed, then set the date to today;
                %let svnStatus_commitDate = %sysFunc(today(),e8601da.);
            %end;

            %if &svnStatus_itemStatus = normal and &svnStatus_propStatus = normal %then %do;
                %* Check if required properties are added;
                %let svnStatus_response = %gmExecuteUnixCmd
                         (
                            cmds    = &svnStatus_svnPath pl -v --xml &svnStatus_sysInEscaped | grep "svn:keywords" || echo "No properties",
                            splitCharIn        = `,
                            details = 0
                         );
                %* Check whether Author, URL, Revision, Date properties are set for the file;
                %if not %index(%qUpcase(&svnStatus_response.),AUTHOR) 
                    or
                    not %index(%qUpcase(&svnStatus_response.),URL) 
                    or
                    not %index(%qUpcase(&svnStatus_response.),REV) 
                    or
                    not %index(%qUpcase(&svnStatus_response.),DATE) 
                %then %do;
                    %if %index(&svnStatus_response.,svn:keywords) %then %do;
                        %* Extract properties if they are present;
                        %let svnStatus_status = %bQuote(Not all required SVN properties (Author, URL, Rev, Date) are set.);
                        %let svnStatus_status = &svnStatus_status. %bQuote(Current list: %qSysFunc(prxChange(s/.*>(.*?)<.*/$1/,1,&svnStatus_response.)).);
                    %end;
                    %else %do;
                        %* There is no svn:keyword property;
                        %let svnStatus_status = %bQuote(Required properties (Author, URL, Rev, Date) are not set.);
                    %end;
                %end;
                %else %do;
                    %* Everything is fine;
                    %let svnStatus_status = &svnStatus_itemStatus.;
                %end;
            %end;
            %else %if &svnStatus_itemStatus = normal %then %do;
                %* File status is normal, but something is wrong with properties;
                %let svnStatus_status = Property status: &svnStatus_propStatus..;
            %end;
            %else %do;
                %* File is not comitted;
                %let svnStatus_status = File status: &svnStatus_itemStatus..;
            %end;
        %end;
        %else %do;
            %* Unknown response;
            %let svnStatus_status = Status Unknown;
        %end;
        
        %if "&svnStatus_commitDate" >= "&dateCheckKeyword" and &checkKeyword. = 1 %then %do;
            %* Check the source code for keyword presence;
            data _null_;
                infile "&svnStatus_sysIn." lRecL=32767 end=lastLine;
           
                input;

                length line $32767 keyList $64;
                line = _infile_;

                retain dateFl revFl authorFl urlFl 0;

                if prxMatch("/\$(Date|LastChangedDate):.*\$/",strip(line)) then do;
                    dateFl = 1;
                end;
                
                if prxMatch("/\$(Revision|Rev|LastChangedRevision):.*\$/",strip(line)) then do;
                    revFl = 1;
                end;

                if prxMatch("/\$(Author|LastChangedBy):.*\$/",strip(line)) then do;
                    authorFl = 1;
                end;

                if prxMatch("/\$(HeadURL|URL):.*\$/",strip(line)) then do;
                    urlFl = 1;
                end;

                if lastLine or (revFl+authorFl+dateFl+urlFl) = 4 then do;
                    if (revFl+authorFl+dateFl+urlFl) = 4 then do;
                        call symput("svnStatus_keywordStatus","Program has all required SVN keywords.");
                        return;
                    end;
                    else do;
                        if authorFl = 0 then do;
                            keyList = strip(keyList) || " LastChangedBy";
                        end;
                        if revFl = 0 then do;
                            keyList = strip(keyList) || " Rev";
                        end;
                        if dateFl = 0 then do;
                            keyList = strip(keyList) || " LastChangedDate";
                        end;
                        if urlFl = 0 then do;
                            keyList = strip(keyList) || " HeadURL";
                        end;
                        call symput("svnStatus_keywordStatus",
                                    "Program header does not have all required SVN keywords."||
                                    '@SVN: Missing keywords: '||strip(keyList)||'.'
                                   );
                        return;
                    end;
                end;
            run;
        %end;

        %* In case file is not commited properly, report it to the log;
        %if &svnStatus_status ne normal %then %do;
            %gmMessage(codeLocation = gmSvnStatus,
                       linesOut     = 
SVN: Check SVN status of &svnStatus_pgmName. 
@SVN: &svnStatus_status
@SVN: All programs must be committed before the production run.,
                       selectType = &selectType.
                      );
            %* Report to STDOUT if was requested;
            %if &printStdout. = 1 %then %do;
                %sysExec(echo "ERROR:[PXL] &svnStatus_pgmName.: Check SVN status. &svnStatus_status.");
            %end;
        %end;
        %else %do;
            %gmMessage(codeLocation = gmSvnStatus,
                       linesOut = SVN: File SVN status is checked. 
                      );
        %end;


        %* If check keyword date is not missing, report ERROR for programs with commit date later than it;
        %if "&svnStatus_commitDate" >= "&dateCheckKeyword" and &checkKeyword. = 1 %then %do;
            %if "&svnStatus_keywordStatus." ne "Program has all required SVN keywords." %then %do;
                %gmMessage(codeLocation = gmSvnStatus,
                           linesOut     = SVN: &svnStatus_keywordStatus.,
                           selectType   = &selectType.
                          );
                %* Report to STDOUT if was requested;
                %if &printStdout. = 1 %then %do;
                    %sysExec(echo "ERROR:[PXL] &svnStatus_pgmName: %sysFunc(tranWrd(&svnStatus_keywordStatus.,%str(@SVN: ),%str( )))");
                %end;
            %end;
            %else %do;
                %gmMessage(codeLocation = gmSvnStatus,
                           linesOut     = SVN: &svnStatus_keywordStatus.
                          );
            %end;
        %end;
    %end;
     
    %* Restore options;
    option &svnStatus_quoteLenMax. &svnStatus_mInOperator.;

    %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsvnstatus.sas $);
%mend;
