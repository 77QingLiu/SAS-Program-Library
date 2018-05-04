/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Julius Kusserow $LastChangedBy: kolosod $
  Creation Date:         27OCT2011       $LastChangedDate: 2016-04-05 05:06:40 -0400 (Tue, 05 Apr 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmessage.sas $

  Program Purpose:       The macro %gmMessage puts the given text into
                         the log. It harmonizes the log for all SAS macros and
                         preferably SAS scripts. Only NOTE(default), WARNING
                         or ERROR or other valid texts as defined in
                         "Best Programming Practices" (BPP) are allowed.

                         By putting in ABORT as the parameter selectType the
                         macro uses the prefix ERROR and initiates  %ABORT if
                         possible in current context(i.e. not interactive mode
                         in SAS 9.1.3).

                         selectType=ERROR should be used as described in
                         BPP for marking ERRORs that should be
                         removed until DB Lock, where as
                         selectType=ABORT should be used within macros, when
                         inconsistent/wrong parameters are used and the macro
                         is not working correctly.

                         In addition parameters printStdOut, sendEmail,
                         debugOnly allow to further enhance the message

                         This macro is PAREXEL's intellectual property and
                         shall not be used outside of contractual obligations
                         without written consent from PAREXEL's senior
                         management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                codeLocation
      Allowed Values:    Any String
      Default Value:     REQUIRED
      Description:       The name of the macro or script which calls this
                         macro. Could also be a more detailed location
                         description, e.g. "macroname/after calculation".
                         This parameter can be left empty (technically),
                         but shouldn't. It's only used for reporting in the
                         log-message.

    Name:                linesOut
      Allowed Values:    Any String
      Default Value:     REQUIRED
      Description:       The text that is put into the log. Special characters
                         like "," and "()" can be used by quoting.

    Name:                selectType
      Allowed Values:    N|NOTE|W|WARNING|E|ERROR|ABORT case insensitive
      Default Value:     NOTE
      Description:       The prefix that will be put in the beginning of each
                         line and the requirement of ABORT is also specified with
                         this parameter. Use N or NOTE case insensitive for NOTE.
                         Use W or WARNING case insensitive for WARNING. Use E
                         or ERROR case insensitive  for ERROR. Use ABORT case
                         insensitive for ERROR plus initiating an abort of the
                         macro.

    Name:                splitchar
      Allowed Values:    Any single character
      Default Value:     @
      Description:       The character which is used to split lines.

    Name:                printStdOut
      Allowed Values:    0|1
      Default Value:     0
      Description:       Setting to 1 will write the message to StdOut if macro
                         runs in batch mode. In interactive mode no messages
                         will be send to StdOut.

    Name:                sendEmail
      Allowed Values:    0|1
      Default Value:     0
      Description:       Setting to 1 will send an email to the user if macro runs
                         in batch mode. In interactive mode email will not
                         be send. If the email address cannot be found / validated
                         a message will be written to StdOut.

    Name:                debugOnly
      Allowed Values:    0|1
      Default Value:     0
      Description:       Setting this to 1 will enable the gmMessage macro action only
                         if the global macro variable gmDebug is set to 1. (This
                         parameter is to suppress certain messages for normal
                         execution).

  Global Macrovariables:

    Name:                gmDebug
      Usage:             read/create
      Description:       gmMessage only put out that it is called if gmDebug=1
                         to avoid unnecessary and confusing log messages. In
                         addition gmMessage puts out the parameters it was
                         called with if gmDebug=1. The parameter also interacts with
                         the debugOnly parameter as described there.

    Name:                gmPxlErr
      Usage:             read/create
      Description:       gmMessage sets gmPxlErr to 1 if it is called with
                         selectType=ABORT and creates the variable if
                         necessary.

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2005 $
-----------------------------------------------------------------------------*/
%MACRO gmMessage( codeLocation =
                , linesOut     =
                , selectType   = NOTE
                , splitChar    = @
                , printStdOut  = 0
                , sendEmail    = 0
                , debugOnly    = 0
);
 /*
  * Print version and location information
  */
  %IF %SYMEXIST(gmdebug) %THEN %DO;
    %IF &gmdebug.=1 %THEN %DO;
  %PUT NOTE:[PXL] %SYSFUNC(TRANWRD(%QSCAN($HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmessage.sas $
                          , -1,:$), 7070/svnrepo, %STR()))
%STR(,) r%QSCAN($Rev: 2005 $,2);
    %END;
  %END;
  %LOCAL messageOut_idx
         messageOut_outline
         messageOut_type
         messageOut_abort
         messageOut_inittext
         messageOut_text
         messageOut_count
         messageOut_shift
         messageOut_position
         messageOut_format
         messageOut_linecombined
         messageOut_email
         messageOut_emailExistsFlag
         messageOut_validEmailFlag
         messageOut_eMailCmd
         messageOut_stdout
         messageOut_rc
         messageOut_interactive

  ;
  %IF %SYMEXIST(gmDebug) %THEN %DO;
    %IF &gmDebug. %THEN %DO;
      %PUT NOTE:[PXL] Debug(gmMessage) codeLocation = &codeLocation.;
      %PUT NOTE:[PXL] Debug(gmMessage) linesOut     = &linesOut.;
      %PUT NOTE:[PXL] Debug(gmMessage) selectType   = &selectType.;
      %PUT NOTE:[PXL] Debug(gmMessage) splitChar    = &splitChar.;
      %PUT NOTE:[PXL] Debug(gmMessage) printStdOut  = &printStdOut.;
      %PUT NOTE:[PXL] Debug(gmMessage) sendEmail    = &sendEmail.;
      %PUT NOTE:[PXL] Debug(gmMessage) debugOnly    = &debugOnly.;
    %END;
  %END;

 /*
  * This step prepares the starting line. Left alignment needed to avoid
  * additional blanks.
  */
  %LET messageOut_text      = %SUPERQ(linesOut);
  %LET messageOut_idx       = 1;
  %LET messageOut_inittext  = [%SYSFUNC(DATETIME(),IS8601DT.)/&codeLocation.];
  %LET messageOut_splitchar = &splitchar.;
 /*
  * Test splitChar for non missing
  */
  %IF %LENGTH(%SUPERQ(splitchar)) ~= 1 %THEN %DO;
    %LET messageOut_text      = Invalid value for parameter splitChar="%SUPERQ(splitChar)";
    %LET messageOut_type      = ERROR:[PXL];
    %LET messageOut_abort     = 1;
    %LET messageOut_splitchar = @;
  %END;
 /*
  * Test linesOut for non missing
  */
  %ELSE %IF ~%LENGTH(%SUPERQ(linesOut)) %THEN %DO;
    %LET messageOut_text      = Invalid value: Parameter linesOut is empty;
    %LET messageOut_type      = ERROR:[PXL];
    %LET messageOut_abort     = 1;
    %LET messageOut_splitchar = @;
  %END;
 /*
  * Check and harmonize Type
  */
  %ELSE %IF (%QLEFT(%QUPCASE(&selectType.)) = NOTE) OR
            (%QLEFT(%QUPCASE(&selectType.)) = N)       %THEN %DO;
    %LET messageOut_type=NOTE:[PXL];
    %LET messageOut_abort=0;
  %END;
  %ELSE %IF (%QLEFT(%QUPCASE(&selectType.)) = WARNING) OR
            (%QLEFT(%QUPCASE(&selectType.)) = W)       %THEN %DO;
    %LET messageOut_type=WARNING:[PXL];
    %LET messageOut_abort=0;
  %END;
  %ELSE %IF (%QLEFT(%QUPCASE(&selectType.)) = ERROR) OR
            (%QLEFT(%QUPCASE(&selectType.)) = E)       %THEN %DO;
    %LET messageOut_type=ERROR:[PXL];
    %LET messageOut_abort=0;
  %END;
  %ELSE %IF (%QLEFT(%QUPCASE(&selectType.)) = ABORT)   %THEN %DO;
    %LET messageOut_type=ERROR:[PXL];
    %LET messageOut_abort=1;
  %END;
  %ELSE %DO;
    %LET messageOut_text = Invalid option for parameter selectType="%SUPERQ(selectType)";
    %LET messageOut_type=ERROR:[PXL];
    %LET messageOut_abort=1;
  %END;

 /*
  * Check flags;
  */
  %IF 0 NE %SUPERQ(sendEmail) AND 1 NE %SUPERQ(sendEmail) %THEN %DO;
    %LET messageOut_text      = Wrong sendEmail value: %SUPERQ(sendEmail) Valid values: 0/1.;
    %LET messageOut_type      = ERROR:[PXL];
    %LET messageOut_abort     = 1;
    %LET messageOut_splitchar = @;
  %END;
  %IF 0 NE %SUPERQ(printStdOut) AND 1 NE %SUPERQ(printStdOut) %THEN %DO;
    %LET messageOut_text      = Wrong printStdOut value: %SUPERQ(printStdOut) Valid values: 0/1.;
    %LET messageOut_type      = ERROR:[PXL];
    %LET messageOut_abort     = 1;
    %LET messageOut_splitchar = @;
  %END;
  %IF 0 NE %SUPERQ(debugOnly) AND 1 NE %SUPERQ(debugOnly) %THEN %DO;
    %LET messageOut_text      = Wrong debugOnly value: %SUPERQ(debugOnly) Valid values: 0/1.;
    %LET messageOut_type      = ERROR:[PXL];
    %LET messageOut_abort     = 1;
    %LET messageOut_splitchar = @;
  %END;

 /*
  * Handle eMail parameter.
  */
  %LET messageOut_eMail =;

  %IF &sendEmail EQ 1 %then %do;
    %LET messageOut_forward=forward;
    %LET messageOut_rc=%SYSFUNC(FILENAME(messageOut_forward,~/.forward));
    %LET messageOut_fid=%SYSFUNC(FOPEN(&messageOut_forward));
    %IF &messageOut_fid > 0 %THEN %DO;
        %LET messageOut_rc=%SYSFUNC(FREAD(&messageOut_fid));
        %LET messageOut_rc=%SYSFUNC(FGET(&messageOut_fid,messageOut_eMail));
        %LET messageOut_rc=%SYSFUNC(FCLOSE(&messageOut_fid));
    %END;
    %LET messageOut_rc=%SYSFUNC(FILENAME(messageOut_forward));

    %LET messageOut_validEmailFlag = %SYSFUNC(PRXMATCH(%QSYSFUNC(PRXPARSE(/^%BQUOTE([^@]*?@[^@]*$/))),%SUPERQ(messageOut_eMail)));

    %IF &messageOut_validEmailFlag NE 1 %THEN %DO;
      %gmMessage( codeLocation = gmMessage/Parameter checks
                , linesOut     = Cannot get your e-mail address. Please ask IT specialist to update the .forward file in your home directory.
@No email will be send to you.
                , selectType   = N
                , printStdOut  = 1
                );
      %LET sendEmail = 0;
    %END;
  %END;

  %IF %SYMEXIST(gmDebug) %THEN %DO;
    %IF ~&gmDebug. AND &debugOnly.=1 AND &messageOut_type=NOTE:[PXL] %THEN %DO;
        %RETURN;
    %END;
  %END;
  %ELSE %DO;
    %IF &debugOnly.=1 AND &messageOut_type=NOTE:[PXL] %THEN %DO;
        %RETURN;
    %END;
  %END;
  %LET messageOut_interactive = %EVAL(   (%QUOTE(%SUBSTR(&SYSPROCESSNAME.,1,11))=DMS Process)
                                      OR (%QUOTE(&SYSPROCESSNAME.)=Object Server)
                                      OR (%QUOTE(&SYSPROCESSNAME.)=Program __STDIN__)
                                     );

  %IF &messageOut_interactive. %THEN %DO;
    %LET printStdOut = 0;
    %LET sendEmail = 0;
  %END;
 /*
  * Realize the line breaks, given by the splitchar.
  */
  %LET messageOut_count = %EVAL(%SYSFUNC(COUNT(&messageOut_text.,&messageOut_splitchar.))+1);
  %LET messageOut_emailText = ;
  %DO %UNTIL(&messageOut_idx. > &messageOut_count. );
    %LET messageOut_shift = 1;
    %LET messageOut_position = %SYSFUNC(INDEXC(&messageOut_text.,&messageOut_splitchar.));
    %IF &messageOut_position.=0 %THEN %DO;
      %LET messageOut_position = %EVAL(%LENGTH(&messageOut_text.));
      %LET messageOut_shift = 0;
    %END;
    %IF &messageOut_position.<=1 %THEN %DO;
      %IF %LENGTH(&messageOut_text.)=1 AND &messageOut_splitchar. NE &messageOut_text. %THEN %DO;
        %LET messageOut_outline  = &messageOut_text.;
      %END;
      %ELSE %DO;
        %LET messageOut_outline  =;
      %END;
    %END;
    %ELSE %DO;
      %LET messageOut_outline  = %QSUBSTR(&messageOut_text.,1,%EVAL(&messageOut_position.- &messageOut_shift.));
    %END;
    %IF %LENGTH(&messageOut_text.) >= %EVAL(&messageOut_position.+ &messageOut_shift.)
        AND &messageOut_position > 0
    %THEN %DO;
      %LET messageOut_text     = %QSUBSTR(&messageOut_text.,%EVAL(&messageOut_position.+ &messageOut_shift.));
    %END;
    %ELSE %DO;
      %LET messageOut_text     = ;
    %END;
   /*
    * For lines >= 100 use the BEST format, for lines < 100 use Z2
    */
    %IF &messageOut_idx < 100 %THEN %DO;
        %LET messageOut_format = Z2.;
    %END;
    %ELSE %DO;
        %LET messageOut_format = BEST.;
    %END;
    %LET messageOut_linecombined = &messageOut_type.%LEFT(%SYSFUNC(PUTN(&messageOut_idx.,&messageOut_format.)))/&messageOut_inittext. &messageOut_outline. ;
    %LET messageOut_emailText = &messageOut_emailText.\n&messageOut_linecombined.;
    %PUT &messageOut_linecombined.;
    %IF &printStdOut. %THEN %DO;
      %LET messageOut_stdout = echo %NRSTR(%')%QSYSFUNC(TRANWRD(%SUPERQ(messageOut_linecombined),%NRSTR(%'),%NRSTR(%'%"%'%"%')))%NRSTR(%';);
      %SYSCALL SYSTEM(messageOut_stdout);
    %END;
    %LET messageOut_inittext =;
    %LET messageOut_idx      = %EVAL(&messageOut_idx.+1);
  %END;

 /*
  * Realize abort depending on SAS version and execution type.
  */
  %IF NOT &messageOut_abort. %THEN %DO;
    %IF "&sendEmail" = "1" %THEN %DO;
      %SYSEXEC( echo -e %NRSTR(%')&messageOut_emailText.%NRSTR(%') | mailx -m -s %NRSTR(%')[Macro Execution] %SUPERQ(codeLocation)%NRSTR(%') &messageOut_eMail);
    %END;
  %END;
  %ELSE %DO;
    %GLOBAL gmpxlerr;
    %LET gmpxlerr=1;
    %LET messageOut_linecombined = ERROR:[PXL]%LEFT(%SYSFUNC(PUTN(&messageOut_idx.,&messageOut_format.)))/ The %NRSTR(%%ABORT) is called as a result of the error handling procedure;
    %LET messageOut_emailText = &messageOut_emailText.\n&messageOut_linecombined.;
    %PUT %SUPERQ(messageOut_linecombined);
    %IF &printStdOut. %THEN %DO;
      %LET messageOut_stdout = echo %NRSTR(%')%QSYSFUNC(TRANWRD(%SUPERQ(messageOut_linecombined),%NRSTR(%'),%NRSTR(%'%"%'%"%')))%NRSTR(%';);
      %SYSCALL SYSTEM(messageOut_stdout);
    %END;
    %IF "&sendEmail" = "1" %then %do;
      %SYSEXEC(echo -e %NRSTR(%')&messageOut_emailText.%NRSTR(%') | mailx -m -s %NRSTR(%')[Macro Execution] %SUPERQ(codeLocation)%NRSTR(%') &messageOut_eMail);
    %END;
    %IF &messageOut_interactive. %THEN %DO;
      %IF %SYSEVALF(&SYSVER. >= 9.2) %THEN %DO;
        %ABORT CANCEL;
      %END;
      %ELSE %DO;
        %PUT ERROR:[PXL] No %NRSTR(%%ABORT) handling in interactive mode v9.1 and below;
        %RETURN;
      %END;
    %END;
    %ELSE %DO;
      %ABORT ABEND;
    %END;
  %END;
%MEND gmMessage;
