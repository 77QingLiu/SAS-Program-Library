/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Julius Kusserow, Matthias Lehrkamp $LastChangedBy: kolosod $
  Creation Date:         19OCT2015       $LastChangedDate: 2016-10-03 04:53:09 -0400 (Mon, 03 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmparseparameters.sas $

  Files Created:         dataOut

  Program Purpose:       Macro gmParseParameters is used to parse a string with
                         parameters and their options into a dataset and to perform
                         a simple validation of option values.

                         # Strings that have a form like
                         # <code>
                           subjid \LABEL=Subject \WIDTH=5
                         @ age    \LABEL=Age
                         </code>
                         # are transformed into a dataset containing the
                         information by a parsing request like
                         # <code>
                           LABEL
                         @ WIDTH  [0-9]+(-[0-9]+)?
                         </code>

                         The macro aborts, if provided options cannot be
                         verified against OptionNames values, or option values
                         given after "=" in the input value do not match with a
                         regular expression specified in OptionNames.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters:

    Name:                parameters
      Description:       String to parse written in the following form:
                         #param1 \OPTION1=VALUE11 \OPTION2=VALUE12 ...
                         #@param2 \OPTION1=VALUE21 \OPTION2=VALUE22 ...

                         # In case it is empty an empty table is created.
                         # Parameter splits and option splits separators are
                         defined by the splitCharParameter/splitCharOption macro
                         parameters accordingly.


    Name:                optionsDefinition
      Allowed Values:    Option names must be valid SAS variable names
                         and not exceed 26 characters
      Default Value:     REQUIRED
      Description:       Defines the options and check rules to parse parameters
                         written in the following form:
                         #OPTION1 ValidationRegex1
                         #@OPTION2 ValidationRegex2
                         #Where the validation regex is optional. In case it is provided, option value
                         is validated using this regex.


    Name:                dataOut
      Allowed Values:    Any valid SAS dataset name
      Default Value:     REQUIRED
      Description:       Resulting dataset with  the parsed information of parameters.
                         The dataset variable lengths are trimmed to their contents length.

    Name:                selectType
      Allowed Values:    E|ERROR|ABORT case insensitive
      Default Value:     ABORT
      Description:       Behaviour of the macro when the validation of options fails.



    Name:                splitCharParameter
      Allowed Values:    A single character excluding "="
      Default Value:     @
      Description:       The character to split parameters from the parameters input
                         value and options in the OptionsDefinition values.

    Name:                splitCharOption
      Allowed Values:    A single character not equal to splitCharParameter and not "="
      Default Value:     \
      Description:       The character to split  options in the parameter input value.

  Macro Dependencies:    gmCheckValueExists (called)
                         gmEnd (called)
                         gmMessage (called)
                         gmStart (called)
                         gmTrimVarLen (called)
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2686 $
-----------------------------------------------------------------------------*/
%MACRO gmParseParameters( parameters         =
                        , optionsDefinition  =
                        , dataOut            =
                        , selectType         = ABORT
                        , splitCharParameter = @
                        , splitCharOption    = \
                        );
  %LOCAL parseParams_templib;           /* The Templib */

  /* create temporary library */
  %LET parseParams_templib= %gmStart( headURL            = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmparseparameters.sas $
                                    , revision           = $Rev: 2686 $
                                    , librequired        = 1
                                    , splitcharDebug     = `
                                    , checkMinSasVersion = 9.2
                                    )
  ;
  %LOCAL parseParams_OptionNames;       /* All Options in Upcase */
  %LOCAL parseParams_OptionNamesN;      /* Number of OPtions */
  %LOCAL parseParams_idx;               /* The Index for all variables */
  %LOCAL parseParams_errorflag;         /* Where the Error happens */
  %LOCAL parseParams_ActualOption;      /* Loop value */
  %LOCAL parseParams_ActualOptionName;  /* Loop value */
  %LOCAL parseParams_parametersN;       /* Loop boundary */
  %LOCAL parseParams_quoteLenMax;       /* Stores old option value */
  %LET parseParams_quoteLenMax =%SYSFUNC(GETOPTION(QUOTELENMAX));
  OPTION noQuoteLenMax;

  /*
   * Checking input parameters
   */
  %gmCheckValueExists( codeLocation   = gmParseParameters/optionsDefinition
                     , value          = &optionsDefinition.
                     , selectMethod   = EXISTS
  )
  %gmCheckValueExists( codeLocation   = gmParseParameters/dataOut
                     , value          = &dataOut.
                     , selectMethod   = EXISTS
  )

  %gmCheckValueExists( codeLocation   = gmParseParameters/splitCharParameter
                     , value          = &splitCharParameter.
                     , selectMethod   = EXISTS
  )
  %gmCheckValueExists( codeLocation   = gmParseParameters/selectType
                     , value          = &selectType.
                     , selectMethod   = EXISTS
  )
  %IF %LENGTH(%SUPERQ(splitCharParameter)) ~= 1 %THEN %DO;
    %gmMessage( codeLocation = gmParseParameters/splitCharParameter
              , linesOut     = The parameter splitCharParameter =
%SUPERQ(splitCharParameter) has invalid length.
@ Length is %LENGTH(%SUPERQ(splitCharParameter)) but only 1 is permitted.
              , selectType   = ABORT
              , splitChar    = @
              )
  %END;
  %IF %SUPERQ(splitCharParameter) = %NRSTR(=) %THEN %DO;
    %gmMessage( codeLocation = gmParseParameters/splitCharParameter
              , linesOut     = "=" not allowed for parameter splitCharParameter.
              , selectType   = ABORT
              , splitChar    = @
              )
  %END;


  %gmCheckValueExists( codeLocation   = gmParseParameters/splitCharOption
                     , value          = &splitCharOption.
                     , selectMethod   = EXISTS
  )
  %IF %LENGTH(%SUPERQ(splitCharOption)) ~= 1 %THEN %DO;
    %gmMessage( codeLocation = gmParseParameters/splitCharOption
              , linesOut     = The parameter splitCharOption =
%SUPERQ(splitCharOption) has a not allowed length.
@ Length is %LENGTH(%SUPERQ(splitCharOption)) but only 1 is permitted.
              , selectType   = ABORT
              , splitChar    = @
              )
  %END;
  %IF %SUPERQ(splitCharOption) = %NRSTR(=) %THEN %DO;
    %gmMessage( codeLocation = gmParseParameters/splitCharOption
              , linesOut     = "=" not allowed for parameter splitCharOption.
              , selectType   = ABORT
              , splitChar    = @
              )
  %END;

  %IF %SUPERQ(splitCharOption) = %SUPERQ(splitCharParameter) %THEN %DO;
    %gmMessage( codeLocation = gmParseParameters/splitCharOption
              , linesOut     = The parameters splitCharParameter and
splitCharOption cannot be the same
              , selectType   = ABORT
              , splitChar    = @
              )
  %END;

  %IF %QSYSFUNC(PRXMATCH(/^\s*(E|ERROR|ABORT)\s*$/i, %BQUOTE(&selectType.))) = 0 %THEN %DO;
    %gmMessage( codeLocation=&gmGetNObs_macroname./Parameter check
              , linesOut= selectType=%SUPERQ(selectType) macro parameter has an invalid value.
               @ Please choose E or ERROR or ABORT as values.
              , selectType=ABORT
              );
  %END;


  /*
   * Number of expected Options.
   */
  %LET parseParams_OptionNamesN =
     %EVAL( %SYSFUNC(COUNT( &optionsDefinition. , &splitCharParameter.)) + 1);
  /*
   * Extra Loop to check option is a valid sas name
   */
  %DO parseParams_idx=1 %TO &parseParams_OptionNamesN.;
    %LET parseParams_ActualOption= %QSCAN( &optionsDefinition.
                                         , &parseParams_idx.
                                         , &splitCharParameter.
                                         );
    %IF %QSYSFUNC(PRXMATCH(%NRBQUOTE(/^[a-z_][a-z0-9_]{0,25}$/i)
                          , %QTRIM(%QLEFT(%QSCAN( &parseParams_ActualOption.
                                                , 1
                                                , %STR( )))))) ~= 1 %THEN %DO;
      %gmMessage( codeLocation = gmParseParameters/parseParams_ActualOption
                , linesOut     = The option parseParams_ActualOption=
%QTRIM(%QLEFT(%QSCAN(&parseParams_ActualOption.,1,%STR( )))) is not a valid
SAS name or more than 26 chars long.
                , selectType   = ABORT
                , splitChar    = @
                )
    %END;
  %END;

  %* Create variables with length ;
  DATA &parseParams_templib..pp01OptionPrep;
    LENGTH splitcharoption     $2;
    splitcharoption = "&splitcharoption.";
    IF INDEX("\().+*[]@{}|?$^/", STRIP(splitcharoption)) THEN DO;
      splitcharoption= "\" !! splitcharoption;
    END;
    %DO parseParams_idx=1 %TO &parseParams_OptionNamesN.;
      %LET parseParams_ActualOption      = %QSCAN( &optionsDefinition.
                                                 , &parseParams_idx.
                                                 , &splitCharParameter.
                                                 );
      %LET parseParams_ActualOptionName  =
          %UPCASE(%QSCAN(&parseParams_ActualOption.,1,%STR( )));
      LENGTH
        &parseParams_ActualOptionName.name    $26
        &parseParams_ActualOptionName.value   $%EVAL(%LENGTH(&parameters.)+1)
        &parseParams_ActualOptionName.exists  8
        &parseParams_ActualOptionName.check   $200
        &parseParams_ActualOptionName.ok      8
      ;
      &parseParams_ActualOptionName.name   =
         STRIP("%UPCASE(&parseParams_ActualOptionName.)");
      &parseParams_ActualOptionName.value  = "";
      &parseParams_ActualOptionName.exists = .;
      %IF %LENGTH(%LEFT(&parseParams_ActualOptionName.)) =
          %LENGTH(%LEFT(&parseParams_ActualOption.))     %THEN %DO;
        &parseParams_ActualOptionName.check  = "";
      %END;
      %ELSE %DO;
        &parseParams_ActualOptionName.check  =
           STRIP("%QSUBSTR(&parseParams_ActualOption.,%LENGTH(&parseParams_ActualOptionName.)+2)");
      %END;
      &parseParams_ActualOptionName.ok     = .;
    %END;
    OUTPUT;
  RUN;

  %LET parseParams_parametersN =
     %EVAL( %SYSFUNC(COUNT(&parameters.,&splitCharParameter.)) + 1 );

  DATA &parseParams_templib..pp02ParamPrep;
    LENGTH number              8
           parameter           $%EVAL(%LENGTH(&parameters.)+1)
           string              $%EVAL(%LENGTH(&parameters.)+1)
    ;
    %DO parseParams_idx=1 %TO &parseParams_parametersN.;
      number    = &parseParams_idx.;
      parameter = "";
      string    = STRIP(SCAN(RESOLVE('&parameters.')
                            , &parseParams_idx.
                            , "&splitCharParameter."
                            ));
      OUTPUT;
    %END;
  RUN;

  PROC SQL;
    CREATE TABLE &parseParams_templib..pp03join AS
      SELECT *
      FROM &parseParams_templib..pp02ParamPrep
      JOIN &parseParams_templib..pp01OptionPrep
        ON 1
     ;
  QUIT;

  DATA &parseParams_templib..dataOut
    (DROP=string splitcharoption regexp errflag
          parsedPregexp replacePregexp returnval);
    SET &parseParams_templib..pp03join END=last;
    LENGTH
      regexp $210
      errflag 8
      returnval $200
    ;
    RETAIN errflag 0;
    IF INDEX(string,"&splitCharOption.")=1 THEN DO;
      parameter = " ";
    END;
    ELSE DO;
      parameter = STRIP(SCAN(string,1,"&splitCharOption."));
      IF LENGTHN(string)>0 THEN DO;
        string = SUBSTR(string, LENGTH(parameter)+1);
      END;
    END;
    %DO parseParams_idx=1 %TO &parseParams_OptionNamesN.;
      %LET parseParams_ActualOption      =
         %QSCAN(&optionsDefinition.,&parseParams_idx.,&splitCharParameter.);
      %LET parseParams_ActualOptionName  =
         %UPCASE(%QSCAN(&parseParams_ActualOption.,1,%STR( )));
      regexp= "/(" !! STRIP(splitcharoption) !!
              "&parseParams_ActualOptionName.\s*=)"!!
              "([^"!! STRIP(splitcharoption) !! "]*)/";
      parsedPregexp = PRXPARSE(STRIP(regexp)!!"i");
      replacePregexp = PRXPARSE("s"!!STRIP(regexp)!!" /i");
      %UNQUOTE(&parseParams_ActualOptionName.exists) =
         IFN(PRXMATCH(parsedPregexp,string),1,0);
      /* save value of OptionName */
      %UNQUOTE(&parseParams_ActualOptionName.value)=
         PRXPOSN(parsedPregexp,2,string);
      /* remove the detected option and value */
      string = PRXCHANGE(replacePregexp,1,string);
      IF 1=%UNQUOTE(&parseParams_ActualOptionName.exists) AND
        ~MISSING(STRIP(%UNQUOTE(&parseParams_ActualOptionName.check))) THEN DO;
        regexp = CATS("/^"
                     , STRIP(%UNQUOTE(&parseParams_ActualOptionName.check))
                     , "$/i"
                     );
        parsedPregexp = PRXPARSE(regexp);
        IF PRXMATCH(parsedPregexp
                   , STRIP(%UNQUOTE(&parseParams_ActualOptionName.value)))
                                                                       THEN DO;
          %UNQUOTE(&parseParams_ActualOptionName.ok)=1;
        END;
        ELSE DO;
          %UNQUOTE(&parseParams_ActualOptionName.ok)=0;
          errflag = errflag+1;
          returnval = RESOLVE(
'%gmMessage( codeLocation = gmParseParameters/valueChecks' !!
', linesOut     = The option '!! STRIP(&parseParams_ActualOptionName.name) !!' has an' !!
               '@ invalid value for the regular expression given.' !!
               '@ value=  ' !! STRIP(&parseParams_ActualOptionName.value) !!
                ' check= ' !! STRIP(&parseParams_ActualOptionName.check) !!
', selectType   = ERROR' !!
', splitChar    = @'!!
')' );
        END;
      END;
      ELSE DO;
        %UNQUOTE(&parseParams_ActualOptionName.ok)=.;
      END;
    %END;
    IF ~MISSING(COMPRESS(string)) THEN DO;
      errflag = errflag+1;
      returnval = RESOLVE(
          '%gmMessage( codeLocation = gmParseParameters/parseCheck' !!
          ', linesOut     = The following option(s) @' !! STRIP(string) !!
                         '@ were repeated or not identified.' !!
          ', selectType   = ERROR' !!
          ', splitChar    = @'!!
          ')' );
    END;
    IF last THEN DO;
      CALL SYMPUT('parseParams_errorflag' ,PUT(errflag,best.));
    END;
    IF %LENGTH(%QCMPRES(&parameters))=0 THEN DO;
      DELETE;
    END;
  RUN;

  %IF &parseParams_errorflag. %THEN %DO;
    %gmMessage( codeLocation = gmParseParameters/EndEvaluation
              , linesOut     = One or more errors were reported above.
              , selectType   = &selectType.
              , splitChar    = @
              )
  %END;
  %gmTrimVarLen( dataIn = &parseParams_templib..dataOut )

  OPTION &parseParams_quoteLenMax.;

  DATA &dataOut.;
    SET &parseParams_templib..dataOut;
  RUN;

  /* close temporary library */
  %gmEnd( headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmparseparameters.sas $ )

%MEND gmParseParameters;

