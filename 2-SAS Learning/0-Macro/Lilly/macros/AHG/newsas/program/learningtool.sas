%macro LearningTool;
    %global localtemp;
    %let localtemp=d:\temp;
    option noxwait xsync;
    %if not %sysfunc(fileexist(&localtemp)) %then x "mkdir &localtemp";
    data _null_;
        file "&localtemp\macro_learning_tool.sas";
        put "/*dummy file, Do not save code in it*/";
    run;

    dm "wedit ""&localtemp\macro_learning_tool.sas"" use";

    data _null_; 
    call execute('dm wedit ''Keydef "F5" gsubmit buf=default'' wedit;');   
    run;

    %if  %sysfunc(fileexist('\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\saspal.exe')) %then x "copy '\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\Macro learning tool\saspal.exe' &localtemp";

    x "&localtemp\saspal.exe   ""SAS - [macro_learning_tool.sas]""   ";
%mend;
%learningtool;
