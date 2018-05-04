/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Tim Schwarz, Dmitry Kolosov $LastChangedBy: kolosod $
  Creation Date:         07SEP2012  $LastChangedDate: 2015-11-10 04:07:33 -0500 (Tue, 10 Nov 2015) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmreplacetext.sas $

  Files Created:         &dataOut dataset.

  Program Purpose:       The macro looks for the specified text within all character
                         variables in &dataIn. It can produce a report of found values or replaces them 
                         with the specified replace string. It is possible to use
                         regular expressions for search and replace.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                dataIn
      Description:       Input dataset 

    Name:                excludeVars
      Default Value:     
      Description:       User input SAS variable names to be excluded from processing. 
                         Regular expressions can be used to specify rules for variables to be exclude.
                         By default is separated by @.

    Name:                includeVars
      Default Value:     
      Description:       User input SAS variable names to be included for processing. 
                         If left missing, then all variables are included by default.
                         Regular expressions can be used to specify rules for variables to be include.
                         By default is separated by @.

    Name:                dataOut
      Description:       Output dataset

    Name:                selectType
      Allowed Values:    QUIET|N|NOTE|E|ERROR|ABORT
      Default Value:     N
      Description:       Message type printed to the log in case the character was found.
                         In case QUIET is selected, no message is printed to the log.

    Name:                textSearch
      Description:       Text to search for. 
                         Double quotes, should be repeated: "" as the value is surrounded with double quotes.


    Name:                textReplace
      Description:       Text to replace with. 
                         Double quotes, should be repeated: "" as the value is surrounded with double quotes.

    Name:                useRegex
      Allowed Values:    0|1
      Default Value:     0 
      Description:       Flag to specify whether textSearch and textReplace are used as regular expressions.
                         1 - enabled, 0 - disabled.
      
    Name:                replace
      Allowed Values:    0|1
      Default Value:     1 
      Description:       Flag to specify whether replacement should occur. 1 - enabled, 0 - disabled.

    Name:                dataReport
      Default Value:     
      Description:       Name of the dataset, where the report will be generated.

    Name:                idReportVars 
      Default Value:     
      Description:       List of ID variables, kept in the report dataset. By default is separated by @.

    Name:                splitChar
      Default Value:     @ 
      Description:       Separator used for includeVars, excludeVars, idReportVars parameters.

    Name:                varPrefix
      Default Value:     gmrt_
      Description:       Prefix used for variables in the report dataset and temporary data step variables.

    Name:                maxLen
      Default Value:     200
      Description:       The length of report variables, containing original and matched values.

  Macro Returnvalue:     N/A

  Macro Dependencies:    gmCheckValueExists (called)
                         gmMessage (called)
                         gmStart (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1334 $
-----------------------------------------------------------------------------*/

%macro gmReplaceText(
                      dataIn        =,
                      includeVars   =,
                      excludeVars   =,
                      dataOut       =,
                      selectType    = N,
                      textSearch    =,
                      textReplace   =,
                      useRegex      = 0,
                      replace       = 1,
                      dataReport    =,
                      idReportVars  =,
                      splitChar     = @,
                      varPrefix     = gmrt_,
                      maxLen        = 200
                     );
                    
    %* Initialized the macro;
    %gmStart(headURL   = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmreplacetext.sas $
    , revision  = $Rev: 1334 $
    , checkMinSasVersion=9.2
    );


    %local gmrt_dsId
           gmrt_nVar
           gmrt_i
           gmrt_j
           gmrt_rc
           gmrt_currentVar
           gmrt_includeFl
           gmrt_includeVar
           gmrt_includeMatch
           gmrt_excludeFl
           gmrt_excludeVar
           gmrt_excludeMatch
           gmrt_varList
           gmrt_varListSize
           gmrt_abortFl
    ;
    
    %* Check parameters;
    %* Check the replace value;
    %if "%qLeft(&replace)" ne "1" and "%qLeft(&replace)" ne "0"  %then %do;
        %gmMessage( codeLocation = gmReplaceText/Parameter checks
                  , linesOut     = %str(Parameter replace = &replace. has an invalid value, please choose 1 or 0.)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;
    %* Check the useRegex value;
    %if "%qLeft(&useRegex)" ne "1" and "%qLeft(&useRegex)" ne "0"  %then %do;
        %gmMessage( codeLocation = gmReplaceText/Parameter checks
                  , linesOut     = %str(Parameter useRegex = &useRegex. has an invalid value, please choose 1 or 0.)
                  , selectType   = ABORT
                  , splitChar    = @
                  );
    %end;
    %* Check selectType is QUIET, N, NOTE, E, ERROR or ABORT;
    %if %qSysFunc(prxMatch(/^(QUIET|N|E|ERROR|NOTE|ABORT)$/,%superQ(selectType))) ~= 1 %then %do;
      %gmMessage( codeLocation = gmReplaceText/Parameter checks
                , linesOut     = %str(Parameter selectType= &selectType. has an invalid value.
                                      @Please choose QUIET,N,NOTE,E,ERROR or ABORT.)
                , selectType   = ABORT
                , splitChar    = @
                )
    %end;
    %* Check for non-missing value;
    %gmCheckValueExists( codeLocation = textSearch, value = &textSearch., 
                         selectMethod = EXISTS );
    %if &replace = 1 %then %do;
        %gmCheckValueExists( codeLocation = dataOut, value = &dataOut., 
                             selectMethod = EXISTS );
    %end;

    %* Check the input dataset exist;
    %if not %sysFunc(exist(&dataIn.)) %then %do;
        %gmMessage(codeLocation = Parameter checks, 
                   linesOut = The &dataIn. dataset does not exist.,
                   selectType = ABORT
                  )
    %end;

    * If regex is not requested, quote metacharacters;
    %if &useRegex = 0 %then %do;
        %let textSearch = %qSysFunc(prxChange(s/([\Q{}[]()^\$.|+?\/\\*\@\E])/\\$1/,-1,&textSearch.));
        %let textReplace = %qSysFunc(prxChange(s/([\$\/\\\@])/\\$1/,-1,&textReplace.));
    %end;

    %let selectType = %upcase(&selectType.);

    %* Form a list of variables from &dataIn;
    %let gmrt_dsId = %sysFunc(open(&dataIn,i));  
    %let gmrt_nVar = %sysFunc(attrn(&gmrt_dsId,nVars));
    %let gmrt_varListSize = 0;

    %* Quote includeVars/excludeVars;
    %let includeVars = %bQuote(&includeVars);
    %let excludeVars = %bQuote(&excludeVars);

    %do gmrt_i=1 %to &gmrt_nVar;
        %* Keep only character variables;
        %if %sysFunc(vartype(&gmrt_dsId,&gmrt_i)) = C %then %do;    

            %* Current variable name;
            %let gmrt_currentVar = %sysFunc(varname(&gmrt_dsId, &gmrt_i));

            %* Initialize flags;
            %let gmrt_includeFl = 0;
            %let gmrt_excludeFl = 0;

            %* If includeVars is not missing, include only those which are specified;
            %if %bQuote(&includeVars.) ne %then %do;
                %let gmrt_j = 1;
                %let gmrt_includeVar = %qScan(&includeVars,&gmrt_j,%bQuote(&splitChar.));
                %do %while(%bQuote(&gmrt_includeVar.) ne );
                    %if %sysFunc(prxMatch(/^&gmrt_includeVar.$/i,&gmrt_currentVar.)) %then %do;
                        %let gmrt_includeFl = 1;
                        %* Keep the matches for inclusion rules in a separate variable, to identify
                        %* values which did not match any variable;
                        %let gmrt_includeMatch = &gmrt_includeMatch.#&gmrt_j#;
                    %end;
                    %let gmrt_j = %eval(&gmrt_j + 1);
                    %let gmrt_includeVar = %qScan(&includeVars,&gmrt_j,%bQuote(&splitChar.));
                %end;
            %end;
            %else %do;
                %let gmrt_includeFl = 1;
            %end;

            %* If excludeVars is not missing, exclude those which are specified;
            %if %bQuote(&excludeVars.) ne %then %do;
                %let gmrt_j = 1;
                %let gmrt_excludeVar = %qScan(&excludeVars,&gmrt_j,%bQuote(&splitChar.));
                %do %while(%bQuote(&gmrt_excludeVar.) ne );
                    %if %sysFunc(prxMatch(/^&gmrt_excludeVar.$/i,&gmrt_currentVar.)) %then %do;
                        %let gmrt_excludeFl = 1;
                        %* Keep the matches for exclusion rules in a separate variable, to identify
                        %* values which did not match any variable;
                        %let gmrt_excludeMatch = &gmrt_excludeMatch.#&gmrt_j#;
                    %end;
                    %let gmrt_j = %eval(&gmrt_j + 1);
                    %let gmrt_excludeVar = %qScan(&excludeVars,&gmrt_j,%bQuote(&splitChar.));
                %end;
            %end;

            %* Form the list of processed varibles;
            %if &gmrt_includeFl = 1 and &gmrt_excludeFl = 0 %then %do;
                %let gmrt_varList = &gmrt_varList. &gmrt_currentVar.;
                %let gmrt_varListSize = %eval(&gmrt_varListSize. + 1);
            %end;
        %end;
    %end;

    %let gmrt_rc = %sysFunc(close(&gmrt_dsId.));

    %* Check if there are inclusion/exclusion rules which did not match any variables;
    %if &excludeVars. ne %then %do;
        %do gmrt_i = 1 %to %eval(1+%sysFunc(countC(&excludeVars,%bQuote(&splitChar.))));
            %if not %index(&gmrt_excludeMatch.,#&gmrt_i.#) %then %do;
                %gmMessage(linesOut= ExcludeVars item #&gmrt_i.:%qScan(&excludeVars.,&gmrt_i.,%bQuote(&splitChar.)) did not match any character variable.,selectType=E);
                %let gmrt_abortFl = 1;
            %end;
        %end;
    %end;
    %if &includeVars. ne %then %do;
        %do gmrt_i = 1 %to %eval(1+%sysFunc(countC(&includeVars,%bQuote(&splitChar.))));
            %if not %index(&gmrt_includeMatch.,#&gmrt_i.#) %then %do;
                %gmMessage(linesOut= IncludeVars item #&gmrt_i.:%qScan(&includeVars.,&gmrt_i.,%bQuote(&splitChar.)) did not match any character variable.,selectType=E);
                %let gmrt_abortFl = 1;
            %end;
        %end;
    %end;

    %if &gmrt_abortFl eq 1 %then %do;
        %gmMessage(linesOut=Update includeVars/excludeVars values,selectType=ABORT);
    %end;

    %* Process the data;
    %if &gmrt_varListSize > 0 %then %do;

        %* Create a report dataset, if it was requested;
        %if &dataReport. ne %then %do;
            %* Replace splitChar with spaces in the ID variable;
            %if %bQuote(&idReportVars.) ne %then %do;
                %let idReportVars = %sysFunc(tranWrd(%bQuote(&idReportVars.),%bQuote(&splitChar),%str( )));
            %end;
            data &dataReport.;
                %* Set the variable order;
                informat &idReportVars &varPrefix.recordNum &varPrefix.variable 
                         &varPrefix.value &varPrefix.position &varPrefix.match;
                %* Add labels;
                label
                    &varPrefix.variable = "Variable Name"
                    &varPrefix.recordNum = "Record Number"
                    &varPrefix.value = "Variable Value"
                    &varPrefix.position = "Match Position"
                    &varPrefix.match = "Match Value"
                ;
                set &dataIn.;
                %* Create unique names for temporary variables;
                length &varPrefix.match &varPrefix.value $&maxLen. &varPrefix.variable $32;
                keep &idReportVars &varPrefix.variable &varPrefix.recordNum &varPrefix.value 
                     &varPrefix.position &varPrefix.match;
                %do gmrt_i = 1 %to &gmrt_varListSize.;
                    %let gmrt_currentVar = %qScan(&gmrt_varList.,&gmrt_i.);
                    %* Search for the pattern;
                    &varPrefix.position = 1;
                    &varPrefix.expressionID = prxParse("/&textSearch./");
                    &varPrefix.start = 1;
                    &varPrefix.stop = length(&gmrt_currentVar.);
                    call prxNext(&varPrefix.expressionID,&varPrefix.start,&varPrefix.stop,&gmrt_currentVar.,&varPrefix.position,&varPrefix.length);
                    %* In case match occured, report to the log and replace;
                    if &varPrefix.position > 0 then do;
                        &varPrefix.variable = "&gmrt_currentVar.";
                        &varPrefix.recordNum = _n_;
                        do while (&varPrefix.position > 0);
                            &varPrefix.match = subStr(&gmrt_currentVar.,&varPrefix.position,&varPrefix.length);
                            &varPrefix.value = &gmrt_currentVar.;
                            output;
                            call prxnext(&varPrefix.expressionID, &varPrefix.start, &varPrefix.stop, &gmrt_currentVar., &varPrefix.position, &varPrefix.length);
                        end;
                    end;
                %end;
            run;
        %end;

        %if (&selectType ne QUITE) or (&replace ne 0) %then %do;
            %*Update the data;
            data
            %if &replace = 1 %then %do;
                &dataOut.
            %end;
            %else %do;
                _null_
            %end;
            ;
                set &dataIn.;
                %* Temporary variables;
                length &varPrefix.resolveResponse $200 &varPrefix.resultValue $32767;
                drop &varPrefix.resolveResponse &varPrefix.matchPosition &varPrefix.resultValue;
                %do gmrt_i = 1 %to &gmrt_varListSize.;
                    %let gmrt_currentVar = %qScan(&gmrt_varList.,&gmrt_i.);
                    %* Search for the pattern;
                    &varPrefix.matchPosition = prxMatch("/&textSearch./",trim(&gmrt_currentVar.));
                    %* In case match occured, report to the log and replace;
                    if &varPrefix.matchPosition > 0 then do;
                        %* Report to the log if QUIET was not specified;
                        %if &selectType ne QUIET %then %do;
                            &varPrefix.resolveResponse = resolve('%gmMessage(linesOut= Match found in variable '
                                                          ||"&gmrt_currentVar. for record " || strip(put(_n_,best.)) || '%str(,)'
                                                          ||"@with the first occurrence at position " || strip(put(&varPrefix.matchPosition,best.))
                                                          ||".,selectType=&selectType.)");
                        %end;
                        %* Replace if was not specified otherwise;
                        %if &replace eq 1 %then %do;
                            &varPrefix.resultValue = prxChange("s/&textSearch./&textReplace./",-1,trim(&gmrt_currentVar.));
                            %* Check if the variable length is sufficient for the result;
                            if vLength(&gmrt_currentVar.) < length(&varPrefix.resultValue) then do;
                                &varPrefix.resolveResponse = resolve('%gmMessage(linesOut='||"&gmrt_currentVar length is not sufficient for the "
                                                               ||"replaced text for record " || strip(put(_n_,best.))
                                                               ||".,selectType=ABORT)");
                            end;
                            &gmrt_currentVar = &varPrefix.resultValue;
                        %end;
                        %else %do;
                            * Initialize the values, to avoid uninitialized message;
                            &varPrefix.resolveResponse = "";
                            &varPrefix.resultValue = "";
                        %end;
                    end;
                %end;
            run;
        %end;
    %end;
    %else %do;
        %gmMessage(linesOut=There are no variables to process.);
    %end;

    %gmEnd( headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmreplacetext.sas $ )
%mend gmReplaceText;
