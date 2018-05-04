/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Julius Kusserow $LastChangedBy: kolosod $
  Creation Date:         02NOV2011 $LastChangedDate: 2015-08-31 04:18:26 -0400 (Mon, 31 Aug 2015) $

  Revision:              $Rev: 1074 $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmend.sas $

  Program Purpose:       The macro %gmEnd writes a macro end message to
                         the log. It unmounts the current temporary library and
                         if this is the final call, compared to the
                         number of %gmStart calls, it deletes the global
                         macro variables created by %gmStart unless
                         the global macro variable gmdebug is set to a
                         value~=0.

                         This macro is PAREXEL’s intellectual property and
                         shall not be used outside of contractual obligations
                         without written consent from PAREXEL’s senior
                         management.

                         This macro has been validated for use only in PAREXELs
                         working environment.
  Macro Parameters:

    Name:                headURL
      Allowed Values:    A valid HeadURL keyword substitution from SVN
      Default Value:     REQUIRED
      Description:       The name and path of the macro, identified by the
                         Subversion keyword HeadURL

  Global Macrovariables:

    Name:                gmDebug
      Usage:             read
      Description:       gmEnd checks for the existence of gmDebug and if
                         it has the value not 0 it will no deassign temporary
                         libraries and keep the global macro variables if they
                         would otherwise been removed.

    Name:                gmStartCount
      Usage:             modify/remove
      Description:       The Number of calling this macro. This is an internal
                         variable for managing the temporal libraries, that
                         should only be modified by gmStart and gmEnd.

    Name:                gmLibCount
      Usage:             modify/remove
      Description:       The Number of Libraries created. This is an internal
                         variable for managing the temporal libraries, that
                         should only be modified by gmStart and gmEnd.

     Name:               gmLibsCreated
       Usage:            modify/remove
       Description:      The Names of the Libraries created. This is an internal
                         variable for managing the temporal libraries, that
                         should only be modified by gmStart and gmEnd.


  Macro Dependencies:    gmMessage (called)
                         gmStart (interaction via global variables)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1074 $
-----------------------------------------------------------------------------*/

%MACRO gmEnd( headURL = );
  %IF %SYMEXIST(gmDebug) %THEN %DO;
    %IF &gmdebug.=1 %THEN %DO;
  %PUT NOTE:[PXL] %SYSFUNC(TRANWRD(%QSCAN($HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmend.sas $
                          , -1,:$), 7070/svnrepo, %STR()))
%STR(,) r%QSCAN($Rev: 1074 $,2);
    %END;
  %END;
  %LOCAL end_lib
         end_libcount
         end_idx
         end_temp
         end_macroname
         end_pgmName
         end_sysIn
  ;

  %LET end_macroname = %QSCAN(%QSCAN(&headURL.,-1,/),1,.);
  /* Logging */

  /* Get the current program name */
  %LET end_sysIn = %QSYSFUNC(GETOPTION(sysIn));
  %LET end_pgmName = %QSCAN(%QSCAN(&end_sysIn,-1,/),1,.);

  /* In case of STDIO mode set the end_pgmName to missing */
  %IF "&end_pgmName" = "__STDIN__" %THEN %DO;
    %LET end_pgmName =;
  %END;

  /* Enable tracking only if the following conditions are met:
        - Program started in batch mode
        - Program name is not equal to macro name obtained from HeadURL
  */
  %IF "&end_pgmName" NE "" AND "%UPCASE(&end_macroname)" NE "%UPCASE(&end_pgmName)" 
      AND %QUPCASE(%QSCAN(&end_sysIn,1,/)) NE UNBLINDED
      AND %QUPCASE(%QSCAN(&end_sysIn,2,/)) NE UNBLINDED
  %THEN %DO;
    /* Local variables required for logging */
    %LOCAL  end_rc
            end_inGML
            end_logMsg
            end_log
    ;
    /* Check whether the macro is from the GML area */ 
    %IF %INDEX(&HeadURL.,_GLOBALMACROLIB) > 0  %THEN %DO;
      %LET end_inGML = 1;
    %END;
    %ELSE %DO;
      %LET end_inGML = 0;
    %END;

    /* Form the message. */
    %LET end_logMsg= <end macro="&end_macroname" user="&sysUserId" pid="&sysJobId."
time="%SYSFUNC(COMPRESS(%SYSFUNC(DATETIME(),is8601dt.),:-))" lvl="&gmStartCount." />;

    /* Output result to the log file*/
    %LET end_rc = %SYSFUNC(FILENAME(end_log, echo %BQUOTE('&end_logMsg.') >> /opt/pxlcommon/stats/macros/logging/gml_tracking.log &, PIPE));
    %LET end_rc = %SYSFUNC(FCLOSE(%SYSFUNC(FOPEN(&end_log,S))));
  %END;
  /*
   * Decrease counter for each execution.
   */
  %LET gmStartCount=%EVAL(&gmStartCount.-1);

  %gmMessage( codeLocation = &end_macroname.,
              linesOut     = End of Subcall level &gmStartCount.
  )

  %IF &gmStartCount.>0 %THEN %DO;

    %LET end_lib=%QSCAN(&gmLibsCreated.,-1,@);
    %LET gmLibsCreated=%QSUBSTR(%SUPERQ(gmLibsCreated),1,%EVAL(%LENGTH(&gmLibsCreated.)-%LENGTH(&end_lib.)-1));

    %IF  &end_lib. NE %THEN %DO;
        /*
         * if gmdebug is enabled, do not remove temp libs
         */
      %IF &gmdebug. = 0 %THEN %DO;
        %LET end_temp = %QSYSFUNC(LIBNAME(&end_lib.));
      %END;
    %END;

  %END;
  %ELSE %DO;
    %LET end_libcount = %EVAL(%SYSFUNC(COUNTC(&gmLibsCreated.,@))+1);
    %LET end_idx=1;
    %DO %WHILE(&end_idx. <= &end_libcount. );
      /*
       * Execute the LIBNAME Clear statements.
       */
      %LET end_lib=%QSCAN(&gmLibsCreated.,&end_idx.,@);

      %IF  &end_lib. NE %THEN %DO;
        /*
         * if gmdebug is enabled, do not remove temp libs
         */
        %IF &gmdebug. = 0 %THEN %DO;
          %LET end_temp = %QSYSFUNC(LIBNAME(&end_lib.));
        %END;
      %END;
      %LET end_idx=%EVAL(&end_idx.+1);
    %END;
    /*
     * Last call in Macro, only delete if gmdebug is not enabled
     */
    %IF ~&gmdebug. %THEN %DO;
      %SYMDEL gmStartCount;
      %SYMDEL gmLibsCreated;
      %SYMDEL gmLibCount;
    %END;
  %END;
%MEND gmEnd;

