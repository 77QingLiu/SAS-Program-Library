/*-----------------------------------------------------------------------------
    Program Purpose:       The macro %ut_HideMOpt disable open the mprint mlogic symbogen option unless the GDebug macro parameter is set to Y

    Macro Parameters:

    Name:                MacroName
        Allowed Values:    Any valid macro name
        Default Value:     REQUIRED
        Description:       The name of a dataset (or view) that should be
                         used for reporting its number of logical observations.

-----------------------------------------------------------------------------*/
%Macro ut_HideMOpt(GDebug);
    %let _saveOptions = %sysfunc(getoption(MPRINT)) %sysfunc(getoption(SYMBOLGEN)) %sysfunc(getoption(MLOGIC)) %sysfunc(getoption(MLOGICNEST));
    %if &debugOnly ne Y %then options NOMPRINT NOSYMBOLGEN NOMLOGIC NOMLOGICNEST;

    options &_saveOptions;
%Mend;
