*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_OptVal Saves current options settings to a SAS Dataset.

    Macro Parameters:

        Name:                OPTNAME 
            Allowed Values:    Any valid option name
            Default Value:     REQUIRED
            Description:       The name of a SAS option name
 
         Name:                KEYWORD 
            Allowed Values:    Return value options
            Default Value:     
            Description:       The name of a value option 
--------------------------------------------------------------------------------------------------;

%macro ut_OptVal(OPTNAME =
                 ,KEYWORD = );

    %pv_Start(ut_OptVal)

    %local  ut_VarList_macroname;
    %let    ut_VarList_macroname  = &SYSMACRONAME;

    %* Parameter validation %*;
    %pv_Define( &ut_VarList_macroname ,OPTNAME ,_pmRequired = 1 ,_pmAllowed = SASNAME)
    %pv_Define( &ut_VarList_macroname ,KEYWORD ,_pmRequired = 0 ,_pmAllowed = SASNAME)

    %if (&KEYWORD) %then %do;
       %sysfunc(getoption(&OPTNAME,KEYWORD))
    %end;
    %else %do;
       %sysfunc(getoption(&OPTNAME))
    %end;

    %pv_End(ut_OptVal)

%mend;