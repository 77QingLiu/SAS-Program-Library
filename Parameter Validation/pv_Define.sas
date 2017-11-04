*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %pv_Define is used to paramater validation only

    Macro Parameters:

        Name:                MacroName
            Allowed Values:    Any valid macro name
            Default Value:     REQUIRED
            Description:       The name of a dataset (or view) that should be used for reporting its number of logical 

*--------------------------------------------------------------------------------------------------;

%macro pv_Define( _pmMacroName
                  ,_pmName
                  ,_pmRequired   = 0                  
                  ,_pmAllowed    = any
                  ,_pmIgnorecase = 1
                  ,_messageType  = ABORT)/minoperator;
%if &_pmIgnorecase = 1 %then %let _pmValue = %bquote(%qupcase(&&&_pmName));
%else %let _pmValue = %bquote(&&&_pmName);

%local  pv_Define_macroname;

%let    pv_Define_macroname = &SYSMACRONAME;      

%*---------------------------------------------- Self parameter checking ------------------------------------------------;
%* Abort macro when pmName is missing %*;
%if %bquote(&_pmName) = %then %do;
    %pv_Message( MessageLocation = MACRO:  &pv_Define_macroname - check parameter[_pmName]
                , MessageDisplay = @required first positional parameter is missing - ending macro;
                , MessageType   = ABORT
                )
%end;

%* Abort macro when _messageType is not in WARNING|ERROR|ABORT %*;
%if not (%bquote(&_messageType) in WARNING ERROR ABORT) %then %do;
    %pv_Message( MessageLocation = MACRO: &pv_Define_macroname - validate macro parameter[_messageType]
                , MessageDisplay =  @Parameter[_messageType] not in ("WARNING" "ERROR" "ABORT") - ending macro;
                , MessageType   = ABORT
                )
%end;

%*---------------------------------------------- Parameter checking ------------------------------------------------;
%* Chech parameter is missing when required %*;
%if &_pmRequired & %bquote(&_pmValue) = %then %do;
    %pv_Message( MessageLocation = MACRO: &_pmMacroName - check required macro parameter[&_pmName]
                , MessageDisplay = %str(@Parameter[&_pmName] is missing, it is a required parameter - ending macro);
                , MessageType   = ABORT
                )
%end;

%* Check valid types %*;
%else %if %bquote(&_pmAllowed) ^= any %then %do;
    %if %qupcase(%bquote(&_pmAllowed)) = SASNAME  %then %do;
        %if %sysfunc(prxmatch(/[^A-z0-9_ ]/ , %bquote(&_pmValue))) %then %do;
            %pv_Message( MessageLocation = MACRO: &_pmMacroName - Check parameter[&_pmName] values
                        , MessageDisplay = @value(%bquote(&_pmValue)) is not a valid SAS Name - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;
    %else %if %qupcase(%bquote(&_pmAllowed)) = DATASET  %then %do;
        %if not %sysfunc(prxmatch(/^ *(\w+\.)?\w+ *$/ , %bquote(&_pmValue))) %then %do;
            %pv_Message( MessageLocation = MACRO: &_pmMacroName - Check parameter[&_pmName] values
                        , MessageDisplay = @value(%bquote(&_pmValue)) is not a valid SAS dataset name - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;    
    %else %if %qupcase(%bquote(&_pmAllowed)) = NUM  %then %do;
        %if %sysfunc(prxmatch(/[^0-9]/ , %bquote(&_pmValue))) %then %do;
            %pv_Message( MessageLocation = MACRO: &_pmMacroName - Check parameter[&_pmName] values
                        , MessageDisplay = @value(%bquote(&_pmValue)) is not all numeric - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;  
    %else %if %qupcase(%bquote(&_pmAllowed)) = CHAR  %then %do;
        %if %sysfunc(prxmatch(/[^A-z]/ , %bquote(&_pmValue))) %then %do;
            %pv_Message( MessageLocation = MACRO: &_pmMacroName - Check parameter[&_pmName] values
                        , MessageDisplay = @value(%bquote(&_pmValue)) is not all character - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;
    %* Check the value of the parameter is not in the list of allowed values %*;     
    %else %if not (&_pmValue in %bquote(&_pmAllowed)) %then %do;
        %pv_Message( MessageLocation = MACRO: &_pmMacroName - Check parameter[&_pmName] values
                    , MessageDisplay = @value is not in the list of allowed values(&_pmAllowed) - ending macro;
                    , MessageType   = ABORT
                    )    
    %end;
%end;

%mend;
