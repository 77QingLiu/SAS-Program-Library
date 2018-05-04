*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %pv_Define is used to paramater validation only

    Macro Parameters:

        Name:                MacroName
            Allowed Values:    Any valid macro name
            Default Value:     REQUIRED

        Name:                paramName
            Allowed Values:    Any valid macro parameter name
            Default Value:     REQUIRED

        Name:                Required
            Allowed Values:    0|1
            Default Value:     0
            Description:       Determine is macro parameter values is required, 0 is not required while 1 is required

        Name:                Allowed
            Allowed Values:    any|SASNAME|DATASET|NUM|CHAR
            Default Value:     any
            Description:       Determine macro parameter values' data type

        Name:                Ignorecase
            Allowed Values:    0|1
            Default Value:     1(insensitive)
            Description:       If case is sensitive when checking parameter values

        Name:                messageType
            Allowed Values:    WARNING|ERROR|ABORT
            Default Value:     ABORT
            Description:       Action when mismatch found
*--------------------------------------------------------------------------------------------------;

%macro pv_Define( MacroName
                  ,paramName
                  ,Required   = 0                  
                  ,Allowed    = any
                  ,Ignorecase = 1
                  ,messageType  = ABORT)/minoperator;
%if &Ignorecase = 1 %then %let Value = %bquote(%qupcase(&&&paramName));
%else %let Value = %bquote(&&&paramName);

%local  pv_Define_macroname;

%let    pv_Define_macroname = &SYSMACRONAME;      

%*---------------------------------------------- Self parameter checking ------------------------------------------------;
%* Abort macro when pmName is missing %*;
%if %bquote(&paramName) = %then %do;
    %pv_Message( MessageLocation = MACRO:  &pv_Define_macroname - check parameter[paramName]
                , MessageDisplay = @required first positional parameter is missing - ending macro;
                , MessageType   = ABORT
                )
%end;

%* Abort macro when messageType is not in WARNING|ERROR|ABORT %*;
%if not (%bquote(&messageType) in WARNING ERROR ABORT) %then %do;
    %pv_Message( MessageLocation = MACRO: &pv_Define_macroname - validate macro parameter[messageType]
                , MessageDisplay =  @Parameter[messageType] not in ("WARNING" "ERROR" "ABORT") - ending macro;
                , MessageType   = ABORT
                )
%end;

%*---------------------------------------------- Parameter checking ------------------------------------------------;
%* Chech parameter is missing when required %*;
%if &Required & %bquote(&Value) = %then %do;
    %pv_Message( MessageLocation = MACRO: &MacroName - check required macro parameter[&paramName]
                , MessageDisplay = %str(@Parameter[&paramName] is missing, it is a required parameter - ending macro);
                , MessageType   = ABORT
                )
%end;

%* Check valid types %*;
%else %if %bquote(&Allowed) ^= any %then %do;
    %if %qupcase(%bquote(&Allowed)) = SASNAME  %then %do;
        %if %sysfunc(prxmatch(/[^A-z0-9_ ]/ , %bquote(&Value))) %then %do;
            %pv_Message( MessageLocation = MACRO: &MacroName - Check parameter[&paramName] values
                        , MessageDisplay = @value(%bquote(&Value)) is not a valid SAS paramName - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;
    %else %if %qupcase(%bquote(&Allowed)) = DATASET  %then %do;
        %if not %sysfunc(prxmatch(/^ *(\w+\.)?\w+ *$/ , %bquote(&Value))) %then %do;
            %pv_Message( MessageLocation = MACRO: &MacroName - Check parameter[&paramName] values
                        , MessageDisplay = @value(%bquote(&Value)) is not a valid SAS dataset paramName - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;    
    %else %if %qupcase(%bquote(&Allowed)) = NUM  %then %do;
        %if %sysfunc(prxmatch(/[^0-9]/ , %bquote(&Value))) %then %do;
            %pv_Message( MessageLocation = MACRO: &MacroName - Check parameter[&paramName] values
                        , MessageDisplay = @value(%bquote(&Value)) is not all numeric - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;  
    %else %if %qupcase(%bquote(&Allowed)) = CHAR  %then %do;
        %if %sysfunc(prxmatch(/[^A-z]/ , %bquote(&Value))) %then %do;
            %pv_Message( MessageLocation = MACRO: &MacroName - Check parameter[&paramName] values
                        , MessageDisplay = @value(%bquote(&Value)) is not all character - ending macro;
                        , MessageType   = ABORT
                        ) 
        %end;  
    %end;
    %* Check the value of the parameter is not in the list of allowed values %*;     
    %else %if not (&Value in %bquote(&Allowed)) %then %do;
        %pv_Message( MessageLocation = MACRO: &MacroName - Check parameter[&paramName] values
                    , MessageDisplay = @value is not in the list of allowed values(&Allowed) - ending macro;
                    , MessageType   = ABORT
                    )    
    %end;
%end;

%mend;
