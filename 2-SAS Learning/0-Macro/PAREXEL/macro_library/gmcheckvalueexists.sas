/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Julius Kusserow $LastChangedBy: kolosod $
  Creation Date:         27OCT2011       $LastChangedDate: 2016-06-06 04:32:52 -0400 (Mon, 06 Jun 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcheckvalueexists.sas $

  Files Created:         N/A

  Program Purpose:       The macro %gmCheckValueExists checks whether the given
                         value is null(empty). Depending on the selected method
                         the outcome will be either a return value or a check
                         that will abort the macro flow.

                         The aborting functionality allows an easy stopping
                         criteria when expected values in a script or macro are
                         not present, while the BOOLEAN functionality allows
                         easy if-else decisions. The benefit over a simple
                         "" EQ "&value." is that the internal code of
                         %gmCheckValueExists is quoted in a way, that all
                         kind of special values can be handled, e.g. value="
                         will lead to a proper result.

                         To avoid confusion it should be noted, that this macro
                         works only with macro variables.

                         This macro is PAREXEL's intellectual property and
                         shall not be used outside of contractual obligations
                         without written consent from PAREXEL's senior
                         management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                codeLocation
      Description:       The name of the macro or script which calls this
                         macro as well as information about the tested value.
                         This parameter is used for identification of the
                         checked value.

    Name:                value
      Description:       The value that will be checked. If value is not given,
                         value will be interpreted as empty.

    Name:                selectMethod
      Allowed Values:    BOOLEAN|EXISTS|NOTEXISTS
      Default Value:     BOOLEAN
      Description:       * BOOLEAN:   returns 1 if not empty, 0 if empty.
                         * EXISTS:    calls gmMessage(ABORT) if value does not
                                      exist.
                         * NOTEXISTS: calls gmMessage(ABORT) if value exists.

  Macro Returnvalue:     1 if value is not empty when BOOLEAN is selected
                         0 otherwise when BOOLEAN is selected

  Macro Dependencies:    gmMessage (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2279 $
-----------------------------------------------------------------------------*/
%MACRO gmCheckValueExists( codeLocation   =
                         , value          =
                         , selectMethod   = BOOLEAN
);
 /*
  * Print version and location information
  */
  %PUT NOTE:[PXL] %SYSFUNC(TRANWRD(%QSCAN($HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcheckvalueexists.sas $
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
  %IF %SYMEXIST(gmDebug) %THEN %DO;
    %IF &gmDebug. %THEN %DO;
      %PUT NOTE:[PXL] Debug(gmCheckValueExists) codeLocation = &codeLocation.;
      %PUT NOTE:[PXL] Debug(gmCheckValueExists) value        = &value.;
      %PUT NOTE:[PXL] Debug(gmCheckValueExists) selectMethod = &selectMethod.;
    %END;
  %END;
  /* checking select method */
  %IF ~ (    %QUPCASE(&selectMethod.) = BOOLEAN
          OR %QUPCASE(&selectMethod.) = EXISTS
          OR %QUPCASE(&selectMethod.) = NOTEXISTS
        ) %THEN %DO;
      %gmMessage( codeLocation = gmCheckValueExists
                , linesOut     = Parameter selectMethod="%SUPERQ(selectMethod)"
has to be BOOLEAN or EXISTS or NOTEXISTS.
                , selectType   = ABORT
      )
  %END;
  %IF %SYSFUNC(LENGTH(%SUPERQ(value)#))>1 %THEN %DO;
    %IF %UPCASE(&selectMethod.)=NOTEXISTS %THEN %DO;
      %gmMessage( codeLocation = gmCheckValueExists
                , linesOut     = Parameter &codeLocation.="%SUPERQ(value)" has to be empty but is filled.
                , selectType   = ABORT
      )
    %END;
    %ELSE %DO;
      %gmMessage( codeLocation = gmCheckValueExists
                , linesOut     = Parameter &codeLocation.="%SUPERQ(value)" is verified as not null.
                , debugOnly    = 1
      )
      %IF %UPCASE(&selectMethod.)=BOOLEAN %THEN %DO;
        1
      %END;
    %END;
  %END;
  %ELSE %DO;
    %IF %UPCASE(&selectMethod.)= EXISTS %THEN %DO;
      %gmMessage( codeLocation = gmCheckValueExists
                , linesOut     = Parameter &codeLocation. is empty but required.
                , selectType   = ABORT
      )
    %END;
    %ELSE %DO;
      %gmMessage( codeLocation = gmCheckValueExists
                , linesOut     = Parameter &codeLocation. is verified as null.
                , debugOnly    = 1
      )
      %IF %UPCASE(&selectMethod.)=BOOLEAN %THEN %DO;
        0
      %END;
    %END;
  %END;
%MEND gmCheckValueExists;