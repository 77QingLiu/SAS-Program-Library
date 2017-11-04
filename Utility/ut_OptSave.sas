*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_OptSave Saves current options settings to a SAS Dataset.

    Macro Parameters:

        Name:                DATA
            Allowed Values:    Any valid SAS dataset
            Default Value:     _options_
            Description:       The name of SAS dataset
          
--------------------------------------------------------------------------------------------------;

%macro ut_OptSave(DATA = _options_);

    %pv_Start(ut_OptSave)

    %local  ut_VarList_macroname;
    %let    ut_VarList_macroname  = &SYSMACRONAME;

    %* Parameter validation %*;
    %pv_Define( &ut_VarList_macroname ,DATA ,_pmRequired = 1 ,_pmAllowed = DATASET)

    %* save current SAS system options, ;
    proc optsave out=&DATA;
    run;

    %pv_End(ut_OptSave)

%mend;