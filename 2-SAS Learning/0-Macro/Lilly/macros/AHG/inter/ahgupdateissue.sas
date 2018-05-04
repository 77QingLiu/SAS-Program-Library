%macro AHGupdateissue;
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 
filename comtxt "&localtemp\&sysmacroname.txt";

data qclib.Issues;
    set qclib.Issues;
    file comtxt;
    format command $550.;
    drop command;
    command='%AHGreQCpassed('||bugid||',version=curr,comment=%str('||trim(comment)||'));';
    if not missing(comment) then do ; put command;end;
    if missing(comment) then output;
run;

%include comtxt;
%mend;
