/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Julius Kusserow $LastChangedBy: kolosod $
  Creation Date:         01NOV2011 $LastChangedDate: 2016-07-11 04:30:14 -0400 (Mon, 11 Jul 2016) $

  Revision:              $Rev: 2426 $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmstart.sas $

  Program Purpose:       The macro %gmStart writes a message into the
                         log and describes the start of a macro. It initializes
                         global macro variables for the handling of line
                         counters and the temp libraries. The macro produces a
                         temporary library and returns the name of it, if
                         requested, by the parameter libRequired=1. The macro
                         guarantees that the provided library and corresponding
                         folder is always empty. The following global macro
                         variables will be created or modified by calling the
                         macro:
                         * gmStartCount    The Number of calling this macro
                         * gmLibCount      The Number of Libraries created
                         * gmLibsCreated   The Names of the Libraries created

                         These macro variables should only be modified by the
                         macros
                         * gmStart
                         * gmEnd

                         This macro is PAREXEL's intellectual property and
                         shall not be used outside of contractual obligations
                         without written consent from PAREXEL's senior
                         management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                headURL
      Allowed Values:    A valid HeadURL keyword substitution from SVN
      Default Value:     REQUIRED
      Description:       The name and path of the macro, identified by the
                         Subversion keyword HeadURL

    Name:                revision
      Allowed Values:    A valid Rev keyword substitution from SVN
      Default Value:     REQUIRED
      Description:       The revision/version of the macro started. This
                         corresponds to the keyword Rev in Subversion

    Name:                libRequired
      Allowed Values:    0|1
      Default Value:     0
      Description:       1 if a temporal library is required and should be
                         created by the macro and 0(default) if such a
                         library is not needed.

                         If 1 is given the return value has to be captured
                         in a macro variable for later referencing the library.
                         DO NOT use any predefined name of a temporary library,
                         as the name of the library may change through the
                         position in the macrocall stack or in further
                         implementations.

    Name:                splitcharDebug
      Allowed Values:    Any single character
      Default Value:     `
      Description:       The splitchar that is used to put out the parameters
                         of the calling macros. It is '`' and not '@' to allow
                         by default the output of @ separated parameters.

    Name:                checkMinSasVersion
      Allowed Values:    [1-9]+\.[0-9]+
      Default Value:     9.1
      Description:       Allows to set the minimum SAS version the calling macro
                         can be used with.

    Name:                deprecated
      Allowed Values:    0|1
      Default Value:     0
      Description:       Defines whether the calling macro is deprecated. If it is
                         deprecated, a corresponding message is shown.


  Macro Returnvalue:     The name of the Library created if LIBREQUIRED=1,
                         nothing otherwise

  Global Macrovariables:

    Name:                gmDebug
      Usage:             read/create
      Description:       gmStart checks for the existence of gmDebug and if
                         it has the value 1. If so it switches
                         to the debug mode (putting out own versioning and
                         local macro variables of calling macro).
                         gmDebug is created if not already existence and
                         initialized with 0.

    Name:                gmPxlErr
      Usage:             read/create
      Description:       gmStart checks for the existence of gmPxlErr and if
                         it has the value 1. If 1 is encountered the macro
                         execution is terminated.
                         gmPxlErr is created if not already existence and
                         initialized with 0.

    Name:                gmStartCount
      Usage:             create/modify
      Description:       The Number of calling this macro. This is an internal
                         variable for managing the temporal libraries, that
                         should only be modified by gmStart and gmEnd.

    Name:                gmLibCount
      Usage:             create/modify
      Description:       The Number of Libraries created. This is an internal
                         variable for managing the temporal libraries, that
                         should only be modified by gmStart and gmEnd.

    Name:                gmLibsCreated
      Usage:             create/modify
      Description:       The Names of the Libraries created. This is an internal
                         variable for managing the temporal libraries, that
                         should only be modified by gmStart and gmEnd.

  Macro Dependencies:    gmMessage (called)
                         gmExecuteUnixCmd (called )
                         gmCheckValueExists  (called)
                         gmEnd (interaction via global variables)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2426 $
-----------------------------------------------------------------------------*/
%MACRO gmStart( headURL            =
              , revision           =
              , libRequired        = 0
              , splitcharDebug     = `
              , checkMinSasVersion = 9.1
              , deprecated         = 0
);
  %IF %SYMEXIST(gmDebug) %THEN %DO;
    %IF &gmdebug.=1 %THEN %DO;
  %PUT NOTE:[PXL] %SYSFUNC(TRANWRD(%QSCAN($HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmstart.sas $
                          , -1,:$), 7070/svnrepo, %STR()))
%STR(,) r%QSCAN($Rev: 2426 $,2);
    %END;
  %END;

  %gmCheckValueExists( codeLocation = gmStart/headURL
                     , selectMethod = EXISTS
                     , value        = &headURL.
  )

  %IF %INDEX(&headURL.,$HeadURL:) = 0 OR %INDEX(%SUBSTR(&headURL.,9),$) = 0 %THEN %DO;
    %gmMessage( codeLocation = gmStart
              , linesOut     = %STR('HeadURL' has to be in the format of $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmstart.sas $)
              , selectType   = ABORT
    )
  %END;

  %gmMessage( codeLocation = gmStart,
              linesOut     = Started macro
@%SYSFUNC(STRIP(%SYSFUNC(TRANWRD(%QSCAN( &headURL., -1,:$), 7070/svnrepo,%STR()))))
%STR(,) r%QSCAN(&revision.,2)
)
  /* Set all used local macro variables to local */
  %LOCAL start_path
         start_temp
         start_libname
         start_cmdres
         start_prxid
         start_vmacro
         start_varnam
         start_fetchrc
         start_dbg_result
         start_dbg_name
         start_dbg_value
         start_macroname
         start_sysIn
         start_pgmName
   ;
%LET start_macroname = %QSCAN(%QSCAN(&headURL.,-1,/),1,.);
  /* Error Handling */
  %IF %SYMEXIST(gmpxlerr) %THEN %DO;
    %IF &gmpxlerr.=1 %THEN %DO;
      %gmMessage( codeLocation= gmStart of &start_macroname.
                , linesOut    = Macro terminated because GMPXLERR is set to 1
                , selectType  = ABORT
      )
      /* For 9.1 Return */
      %RETURN;
    %END;
  %END;

  /* Initialising Error Variable */
  %GLOBAL gmpxlerr;
  %LET    gmpxlerr=0;


  /* Checking parameters */
  %gmCheckValueExists( codeLocation = gmStart/splitcharDebug
                     , selectMethod = EXISTS
                     , value        = &splitcharDebug.)
  %IF %LENGTH(%SUPERQ(splitcharDebug)) ~= 1 %THEN %DO;
    %gmMessage( codeLocation = gmStart
              , linesOut     = %STR('splitcharDebug' has to be a single character (splitcharDebug = %SUPERQ(splitcharDebug)))
              , splitChar    = Z
              , selectType   = ABORT
    )
  %END;
  %gmCheckValueExists( codeLocation = gmStart/checkMinSasVersion
                     , selectMethod = EXISTS
                     , value        = &checkMinSasVersion.
  )
  %LET start_prxid=%QSYSFUNC(PRXPARSE(/^[1-9]+\.[0-9]+$/));
  %IF  ~%QSYSFUNC(PRXMATCH(&start_prxid.,&checkMinSasVersion.)) %THEN %DO;
    %gmMessage( codeLocation = gmStart
              , linesOut     = checkMinSasVersion is not a version number(format: X.Y)
@(checkMinSasVersion=%SUPERQ(checkMinSasVersion))
              , selectType   = ABORT
    )
  %END;
  %SYSCALL PRXFREE(start_prxid);
  /* Check SAS version */
  %IF %SYSEVALF(&SYSVER. < &checkMinSasVersion.) %THEN %DO;
    %gmMessage( codeLocation = gmStart
              , linesOut     = The macro %SUPERQ(start_macroname) is only programmed for SAS Version &checkMinSasVersion. and above.
@Your runnig version is: &SYSVER.
              , selectType   = ABORT
    )
  %END;

  /* Decision for submacro call. */
  %IF ~%SYMEXIST(gmStartCount) %THEN %DO;
    %GLOBAL gmStartCount;
    %GLOBAL gmLibCount;
    %GLOBAL gmLibsCreated;
    %LET gmStartCount=0;
    %LET gmLibCount=1;
    %LET gmLibsCreated=;
  %END;

  /* Handling Debug */
  %IF %SYMEXIST(gmDebug) %THEN %DO;
    %IF &gmDebug. %THEN %DO;
      %LET start_vmacro = %SYSFUNC(OPEN(sashelp.vmacro(WHERE=(%UPCASE("&start_macroname.")=SCOPE AND OFFSET=0)),I));
      %LET start_varnam = %SYSFUNC(VARNUM(&start_vmacro, NAME));
      %LET start_fetchrc= %SYSFUNC(FETCH (&start_vmacro));
      %LET start_dbg_result=The following values are available in the symbol table of
&start_macroname.&splitcharDebug.
variables that are not parameter of the macros are local variables created in
the setup phase of the macro;
      %DO %WHILE (&start_fetchrc. = 0);
        %LET start_dbg_name  = %SYSFUNC(GETVARC(&start_vmacro,&start_varnam. ));
        %LET start_dbg_result= &start_dbg_result. &splitcharDebug.     &start_dbg_name.=%SUPERQ(&start_dbg_name);
        %LET start_fetchrc=%SYSFUNC(FETCH(&start_vmacro));
      %END;
      %gmMessage( codeLocation = gmStart of &start_macroname.
                , linesOut     = &start_dbg_result.
                , splitChar    = &splitcharDebug.
      )
      %LET start_fetchrcc=%SYSFUNC(CLOSE(&start_vmacro));
    %END;
  %END;
  %ELSE %DO;
    %GLOBAL gmDebug;
    %LET gmDebug=0;
  %END;

  /* Deprecated flag */
  %IF &deprecated. = 1 %THEN %DO;
    %gmMessage( codeLocation= gmStart
              , linesOut    = Macro &start_macroname is deprecated.
                              @%str(If this is an ongoing study, please update the program not to use it.)
              , selectType  = NOTE
    )
  %END;
  %ELSE %IF &deprecated. ne 0 %THEN %DO;
    %gmMessage( codeLocation= gmStart of &start_macroname.
              , linesOut    = Unexpected value deprecated=%SUPERQ(deprecated).;
              , selectType  = ABORT
    )
  %END;

  /* Library flag */
  %IF &libRequired. = 1 %THEN %DO;

    %LET start_path = %QSYSFUNC(PATHNAME(work))/&gmLibCount.;

     /* If temp library already exists (due to prior runs and aborts) delete the
        directory and all of its contents. */
    %IF %SYSFUNC(FILEEXIST(&start_path.)) %THEN %DO;
      %LET start_cmdres  = %gmExecuteUnixCmd(cmds = rm -Rf "&start_path.");
    %END;

    %LET start_cmdres  = %gmExecuteUnixCmd(cmds = mkdir "&start_path.");
    %LET start_libname = gm%SYSFUNC(PUTN(&gmLibCount.,z6.));
    %LET start_temp    = %QSYSFUNC(LIBNAME(&start_libname.,&start_path.,,compress=yes));
    %LET gmLibsCreated      = &gmLibsCreated.%STR(&start_libname.@);

    /*
     * Return name of new created library.
     */
    /* Put Startmessage to Log */
    %gmMessage( codeLocation = &start_macroname.,
                linesOut     = Start of subcall level &gmStartCount.(Library=&start_libname)
    )
    &start_libname.

    %LET gmLibCount = %EVAL(&gmLibCount. + 1);
  %END;
  %ELSE %IF &libRequired. = 0 %THEN %DO;
    %LET gmLibsCreated = &gmLibsCreated.%STR( @);
    /* Put Startmessage to Log */
    %gmMessage( codeLocation = &start_macroname.,
                linesOut     = Start of subcall level &gmStartCount.
  )
  %END;
  %ELSE %DO;
    %gmMessage( codeLocation= gmStart of &start_macroname.
              , linesOut    = Unexpected value libRequired=%SUPERQ(libRequired).;
              , selectType  = ABORT
    )
  %END;

  /* Increase the depth counter */
  %LET gmStartCount=%EVAL(&gmStartCount. + 1);

  /* Tracking */

  /* Get the current program name */
  %LET start_sysIn = %QSYSFUNC(GETOPTION(sysIn));
  %LET start_pgmName = %QSCAN(%QSCAN(&start_sysIn,-1,/),1,.);

  /* In case of STDIO mode set the start_pgmName to missing */
  %IF "&start_pgmName" = "__STDIN__" %THEN %DO;
    %LET start_pgmName =;
  %END;

  /* Enable tracking only if the following conditions are met:
        - Program started in batch mode
        - Program was not started in the unblinded area
        - Program name is not equal to macro name obtained from HeadURL - avoid situations when gmStart is used within a program
  */
  %IF "&start_pgmName" NE "" AND "%QUPCASE(&start_macroname)" NE "%QUPCASE(&start_pgmName)"
      AND %QUPCASE(%QSCAN(&start_sysIn,1,/)) NE UNBLINDED
      AND %QUPCASE(%QSCAN(&start_sysIn,2,/)) NE UNBLINDED
  %THEN %DO;
    %IF &gmDebug. %THEN %DO;
      %gmMessage( codeLocation = &start_macroname./gmstart/tracking,
                  linesOut     = Start of tracking.
                )
    %END;
    /* Local variables required for logging */
    %LOCAL  start_value
            start_name
            start_par
            start_rc
            start_inGML
            start_logMsg
            start_log
            start_pgmPath
            start_setupInfo
    ;
    /* Check whether the macro is from the GML area */
    %IF %INDEX(&HeadURL.,_GLOBALMACROLIB) > 0  %THEN %DO;
      %LET start_inGML = 1;
    %END;
    %ELSE %DO;
      %LET start_inGML = 0;
    %END;

    /* Extract path information */
    %LET start_prxId = %SYSFUNC(PRXPARSE(s/(?:(.*)\/)?.+/$1/));
    %LET start_pgmPath = %SYSFUNC(PRXCHANGE(&start_prxId,1,&start_sysIn.));
    %SYSCALL PRXFREE(start_prxId);

    /* Create setup.sas attribute
     0 - no _projpre, _type
     1 - _projpre, _type
     2 - _projpre, _type, _metadata
    */
    %IF %SYMEXIST(_projPre) and %SYMEXIST(_type) %THEN %DO;
      %IF %SYMEXIST(_metadata) %THEN %DO;
        %LET start_setupInfo = 2;
      %END;
      %ELSE %DO;
        %LET start_setupInfo = 1;
      %END;
    %END;
    %ELSE %DO;
      %LET start_setupInfo = 0;
    %END;

    /* Form the message. */
    %LET start_logMsg=<start path="&start_pgmPath." macro="&start_macroname." gml="&start_inGML." setup="&start_setupInfo." rev="%qScan(&revision.,2)"
user="&sysUserId" pid="&sysJobId." sas="&sysVer." pgm="&start_pgmName"
time="%SYSFUNC(COMPRESS(%SYSFUNC(DATETIME(),is8601dt.),:-))" lvl="&gmStartCount.">;
    /* Check the message does not contain single quotes, in case it does, replace it with tab */
    %IF %INDEX(%BQUOTE(&start_logMsg),%STR(%')) %THEN %DO;
      %LET start_logMsg = %SYSFUNC(TRANWRD(%BQUOTE(&start_logMsg),%STR(%'),%SYSFUNC(BYTE(9)));
    %END;

    /* Obtain parameter values from SASHELP.VMACRO dataset */
    %LET start_vmacro = %SYSFUNC(OPEN(sashelp.vmacro(WHERE=(%UPCASE("&start_macroname.")=SCOPE AND OFFSET=0 
                                                            AND NOT MISSING(VALUE)
                                                           )
                                                    )
                                      ,I
                                     )
                                );
    %LET start_varnam = %SYSFUNC(VARNUM(&start_vmacro, NAME));
    %LET start_fetchrc= %SYSFUNC(FETCH (&start_vmacro));

    /* Create regex to mask special characters */
    %LET start_prxId = %SYSFUNC(PRXPARSE(s/(?:[^\x20-\x7F]|[%STR(;)\/\(\)<>\x25\x26\x22\x27\x2C])/%SYSFUNC(BYTE(9))/));
    /* Iterate through SASHELP.VMACRO records and get NAME and VALUE variable values */
    %DO %WHILE (&start_fetchrc. = 0);
      %LET start_name  = %SYSFUNC(GETVARC(&start_vmacro,&start_varnam.));
      /* Replace all special characters from VALUE with a tab */
      %LET start_value = %SYSFUNC(PRXCHANGE(&start_prxId,-1,%SUPERQ(&start_name)));
      /* In case value length is > 20, truncate it */
      %IF %LENGTH(&start_value) > 20 %THEN %DO;
        %LET start_par = &start_par.<p n="&start_name" cut="1">%SUBSTR(&start_value,1,20)</p>;
      %END;
      %ELSE %DO;
        %LET start_par = &start_par.<p n="&start_name">&start_value</p>;
      %END;
      /* Check parameter string does not exceed the maximum length limit
         Limit for the parameter part length, 7500. It is an empirical number,
         otherwise when a pipe length > 8000 SAS fails.
      */
      %IF %LENGTH(&start_par) < 7500 %THEN %DO;
        %LET start_fetchrc=%SYSFUNC(FETCH(&start_vmacro));
      %END;
      %ELSE %DO;
        %gmMessage( codeLocation = &start_macroname./gmstart/tracking,
                    linesOut     = Not all parameters are tracked due to a large number of them.
                  )
        %LET start_fetchrc=-1;
      %END;
    %END;
    /* Clean-up */
    %SYSCALL PRXFREE(start_prxId);
    %LET start_fetchrcc=%SYSFUNC(CLOSE(&start_vmacro));

    /* Output result to the log file*/
    %LET start_rc = %SYSFUNC(FILENAME(start_log, echo %BQUOTE('&start_logMsg.&start_par.</start>') >> /opt/pxlcommon/stats/macros/logging/gml_tracking.log &, PIPE));
    %LET start_rc = %SYSFUNC(FCLOSE(%SYSFUNC(FOPEN(&start_log,S))));

    %IF &gmDebug. %THEN %DO;
      %gmMessage( codeLocation = &start_macroname./gmstart/tracking,
                  linesOut     = End of tracking.
                )
    %END;
  %END;

%MEND gmStart;
