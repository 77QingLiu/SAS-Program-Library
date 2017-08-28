*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %pv_Start declare the start of macro

    Macro Parameters:

        Name:                MacroName
            Allowed Values:    Any valid macro name
            Default Value:     REQUIRED
            Description:       The name of a dataset (or view) that should be used for reporting its number of logical observations.

*--------------------------------------------------------------------------------------------------;

%MACRO pv_Start(MacroName);
    %put ----------------------------------------------------------------------------------------------;
    %put NOTE: &MacroName: Start of Macro;
    %put ----------------------------------------------------------------------------------------------;
    %put ;
%MEND pv_Start;
