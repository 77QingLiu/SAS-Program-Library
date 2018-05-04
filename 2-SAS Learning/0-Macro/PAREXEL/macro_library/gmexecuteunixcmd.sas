/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee 
  PXL Study Code:        80386
 
  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------
 
  Author:                Julius Kusserow $LastChangedBy: kolosod $
  Creation Date:         01NOV2011       $LastChangedDate: 2016-06-06 04:32:52 -0400 (Mon, 06 Jun 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecuteunixcmd.sas $

  Files Created:         N/A
 
  Program Purpose:       The macro %gmExecuteUnixCmd is used as a substitute for 
                         the %SYSEXEC() function and the X command. It avoids 
                         popping OS boxes and executes faster by using unnamed 
                         pipes. If correct UNIX syntax is used, it allows to read
                         the OS response output (from STDOUT and STDERR) of one 
                         or more commands. To achieve this, for every single 
                         command a redirect of STDERR to STDOUT is appended. 
                         This implies that custom redirects must not be used,  
                         because automatic redirecting will not work anymore.  
                         Also commands requiring user interaction should be 
                         avoided, because execution takes place in background.
                         The OS reply is printed to the SAS log. It is also 
                         returned by the macro and can be used. Errors in OS 
                         cmd execution are detected and will lead to a call of
                         gmMessage(selectType=ABORT).
                         
 
                         This macro is PAREXEL's intellectual property and 
                         shall not be used outside of contractual obligations
                         without written consent from PAREXEL's senior
                         management.
 
                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:
 
    Name:                cmds
      Description:       The Unix command(s) to be executed. splitCharIn
                         is used to separate multiple commands.
   
    Name:                splitCharIn
      Default Value:     @
      Description:       Character that separates multiple commands, e.g. 
                         'cd ~ @ ls'.     
 
    Name:                splitCharOut
      Default Value:     @
      Description:       Character that separates the lines of the OS response
                         output. Choose carefully, because '@' can be included 
                         in the lines themselves, e.g. as part of a file name 
                         when executing 'ls'.

    Name:                numberRecordLength
      Default Value:     2000
      Description:       The maximum length of a row-buffer. If any line is longer
                         than numberRecordLength the macro will fail.

    Name:                details 
      Allowed Values:    0|1
      Default Value:     1
      Description:       Setting this to 0 will enable the macro to print OS reply
                         only if the global macro variable gmDebug is set to 1.                                               

  Macro Returnvalue:     Unix response output, can be empty depending on command
                         executed.

  Macro Dependencies:    gmMessage (called)
                         gmCheckValueExists (called)
  
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2279 $
-----------------------------------------------------------------------------*/
%MACRO gmExecuteUnixCmd( cmds               = 
                       , splitCharIn        = @
                       , splitCharOut       = @
                       , numberRecordLength = 2000
                       , details            = 1
);
 /*
  * Print version and location information
  */
  %PUT NOTE:[PXL] %SYSFUNC(TRANWRD(%QSCAN($HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecuteunixcmd.sas $
                          , -1,:$), 7070/svnrepo, %STR()))
%STR(,) r%QSCAN($Rev: 2279 $,2);
  %IF %SYMEXIST(gmpxlerr) %THEN %DO;
    %IF &gmpxlerr.=1 %THEN %DO;
      %PUT NOTE:[PXL] Macro terminated because GMPXLERR is set to 1;
      %RETURN;
    %END;
  %END;
  %GLOBAL gmpxlerr;
  %LET gmpxlerr=0;
  /*
   * Declaration of local variables.
   */
  %LOCAL gmExecuteUnixCmd_OsOut;
  %LOCAL gmExecuteUnixCmd_fid;
  %LOCAL gmExecuteUnixCmd_rc;
  %LOCAL gmExecuteUnixCmd_line;
  %LOCAL gmExecuteUnixCmd_lines;
  %LOCAL gmExecuteUnixCmd_echoString;
  %LOCAL gmExecuteUnixCmd_prxid;
  
  %LET gmExecuteUnixCmd_macroname = gmExecuteUnixCmd;
  
  /* 
   * Check if splitchars are valid and cmds is not empty.
   */
  %IF %LENGTH(%SUPERQ(splitCharIn)) ~= 1 %THEN %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = %STR('splitCharIn' has to be a single character (splitcharIn = %SUPERQ(splitcharIn)))
              , splitChar    = ³
              , selectType   = ABORT
    )
  %END;
  %IF %LENGTH(%SUPERQ(splitCharOut)) ~= 1 %THEN %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = %STR('splitCharOut' has to be a single character (splitCharOut = %SUPERQ(splitCharOut)))
              , splitChar    = ³
              , selectType   = ABORT
    )
  %END;
  %gmCheckValueExists( codeLocation = gmExecuteUnixCmd/cmd
                     , selectMethod = EXISTS
                     , value        = &cmds.)
  %gmCheckValueExists( codeLocation = gmExecuteUnixCmd/numberRecordLength
                     , selectMethod = EXISTS
                     , value        = &numberRecordLength.)
  %IF %SYSFUNC(NOTDIGIT(&numberRecordLength.)) %THEN %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = %STR('numberRecordLength' has to be a positive integer number(numberRecordLength = %SUPERQ(numberRecordLength)))
              , selectType   = ABORT
    )
  %END;
  %IF %SUPERQ(DETAILS) NE 1 AND %SUPERQ(DETAILS) NE 0 %THEN %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = %STR('details' has to be either 0 or 1)
              , selectType   = ABORT
    )
  %END;
  /* 
   * Modify command to redirect stderr to stdin (pipe) and replace splitCharIn
   * with ampersands.
   */
  %LET gmExecuteUnixCmd_prxid=%QSYSFUNC(PRXPARSE(/&\s*(@|$)/));
  %IF  %QSYSFUNC(PRXMATCH(&gmExecuteUnixCmd_prxid.,&cmds.)) %THEN %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = One of the commands given ends with an & for background execution. 
³ This is not allowed with &gmExecuteUnixCmd_macroname. 
³ Commands given were cmds=%SUPERQ(cmds)
              , splitChar    = ³
              , selectType   = ABORT
    )
  %END;
  %SYSCALL PRXFREE(gmExecuteUnixCmd_prxid);
  
  %LET cmds = %QSYSFUNC(TRANWRD(&cmds., &splitcharIn., %NRSTR( 2>&1) %STR(&)%STR(&) ))%NRSTR( 2>&1);
  /* 
   * Modify command to do an ECHO to STDOUT as last operation for error detection.
   */
  %LET gmExecuteUnixCmd_echoString = %STR(--ALL COMMANDS WERE EXECUTED--);
  /*
   * @todo remove parameter changing
   */
  %LET cmds = &cmds. %STR(&)%STR(&) echo &gmExecuteUnixCmd_echoString.;

  /*  
   * Create unnamed pipe and associate with command. Always put out therefore no DEBUG output is needed.
   */
  %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
            , linesOut     = %STR(Executing OS command: &cmds., splitCharIn = &splitCharIn., splitCharOut = &SplitCharOut.)
            , splitChar    = ³
  )
  %LET gmExecuteUnixCmd_rc = %SYSFUNC(FILENAME(gmExecuteUnixCmd_OsOut, &cmds., PIPE, LRECL=&numberRecordLength.));

  /* 
   * Create ok
   */
  %IF (&gmExecuteUnixCmd_rc. = 0) %THEN %DO;
    /* 
     * Open pipe 
     */ 
    %LET gmExecuteUnixCmd_fid = %SYSFUNC(FOPEN(&gmExecuteUnixCmd_OsOut., S));

    /* 
     * Open ok
     */
    %IF (&gmExecuteUnixCmd_fid. ~= 0) %THEN %DO;
      /* 
       * Read loop
       */
      %DO %WHILE (%SYSFUNC(FREAD(&gmExecuteUnixCmd_fid.)) = 0);
        /* 
         * Get characters from pipe (and execute command).
         */
        %LET gmExecuteUnixCmd_rc    = %QSYSFUNC(FGET(&gmExecuteUnixCmd_fid., gmExecuteUnixCmd_line, &numberRecordLength.));
        %IF %LENGTH(%SUPERQ( gmExecuteUnixCmd_line ))=0 %THEN %DO;
          %LET gmExecuteUnixCmd_line = %STR( );
        %END;
        %IF %LENGTH(%SUPERQ(gmExecuteUnixCmd_lines))
          + %LENGTH(%SUPERQ(gmExecuteUnixCmd_line))
          + 2 > %SYSFUNC(GETOPTION(MVARSIZE)) %THEN %DO;
           %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.  
                     , linesOut     = The result will exceed the maximum length that a macrovariable
@can contain:%SYSFUNC(GETOPTION(MVARSIZE)). Change the MVARSIZE option to get longer results.
                     , selectType   = ABORT
           )
          %END;
        %LET gmExecuteUnixCmd_lines = &gmExecuteUnixCmd_lines.&splitcharOut.%SUPERQ(gmExecuteUnixCmd_line);
      %END;
      /* 
       * Close pipe
       */
      %LET gmExecuteUnixCmd_fid = %SYSFUNC(FCLOSE(&gmExecuteUnixCmd_fid.));
    %END;
    %ELSE %DO;
    /* 
     * Error (open pipe)
     */      
     %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.  
               , linesOut     = Could not open pipe: %SYSFUNC(SYSMSG())
               , selectType   = ABORT
     )
    %END;
    /* 
     * Disassociate fileref
     */
    %LET gmExecuteUnixCmd_rc = %SYSFUNC(FILENAME(gmExecuteUnixCmd_OsOut));
  %END;
  %ELSE %DO;
    /* 
     * Error (create pipe)
     */
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = %STR(Could not create pipe, return value was: &gmExecuteUnixCmd_rc..)
              , selectType   = ABORT
    )
  %END;

  /*
   * Check if last operation (ECHO to STDOUT) was executed by examining OS response.
   */
  %IF %LENGTH(&gmExecuteUnixCmd_lines.) < %LENGTH(&gmExecuteUnixCmd_echoString.) %THEN %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname. 
              , linesOut     = %STR(An error occured during command execution, please check syntax.)
                             @ Returned value was: %SUPERQ(gmExecuteUnixCmd_lines)
              , selectType   = ABORT
    )
  %END;
  %ELSE %IF (%QSUBSTR( &gmExecuteUnixCmd_lines.
                     , %EVAL(%LENGTH(&gmExecuteUnixCmd_lines.) - %LENGTH(&gmExecuteUnixCmd_echoString.) + 1)
                     , %LENGTH(&gmExecuteUnixCmd_echoString.) 
             ) ~= &gmExecuteUnixCmd_echoString. ) %THEN %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = %STR(An error occured during command execution, please check syntax.)
                             @ Response was: %SUPERQ(gmExecuteUnixCmd_lines)
              , selectType   = ABORT
    )
  %END;

  /*
   * Remove echo string from OS response.
   */
  %IF %NRBQUOTE(&gmExecuteUnixCmd_lines.) = %NRBQUOTE(&splitCharOut.&gmExecuteUnixCmd_echoString.) %THEN %DO;
    %LET gmExecuteUnixCmd_lines=;
  %END;
  %ELSE %DO;
    %LET gmExecuteUnixCmd_lines = %QSUBSTR( &gmExecuteUnixCmd_lines.
                                          , 2
                                          , %EVAL(%LENGTH(&gmExecuteUnixCmd_lines.) - %LENGTH(&gmExecuteUnixCmd_echoString.)-1)
                                  );
  %END;

  /*
   * "Return" OS response.
   */
  %BQUOTE(&gmExecuteUnixCmd_lines.)

  /*
   * Note for the log.
   */
  %IF %gmCheckValueExists( codeLocation = gmExecuteUnixCmd/Command response
                           , selectMethod = BOOLEAN
                           , value        = &gmExecuteUnixCmd_lines.
        ) %THEN %DO;
    %gmMessage( codeLocation = gmExecuteUnixCmd/Command response
              , linesOut     = &gmExecuteUnixCmd_lines. 
              , splitchar    = &splitCharOut.
              , debugOnly    = %SYSEVALF(NOT &details) 
    )
  %END;  
  %ELSE %DO;
    %gmMessage( codeLocation = &gmExecuteUnixCmd_macroname.
              , linesOut     = Command gave no response.
              , splitchar    = &splitCharOut.
    )  
  %END;
%MEND gmExecuteUnixCmd;
