/*-----------------------------------------------------------------------------
    Program Purpose:       The macro %stat_Freq create a frequent statistics

    Macro Parameters:

    Name:                MacroName
        Allowed Values:    Any valid macro name
        Default Value:     REQUIRED
        Description:       The name of a dataset (or view) that should be
                         used for reporting its number of logical observations.

-----------------------------------------------------------------------------*/
%macro stat_Freq(data=, where=1=1, tabfmt=, var=ID, class= , order1=, format=);
    %if &format = %then %let format = &class.;

    proc means data = &data. n completetypes missing NWAY noprint;
        where &where;
        class &class/preloadfmt exclusive;
        var &var;
        format &class &format..;
        output out=freq_&order1 n=n / autoname;
    run;

    %let SubN = 0;
    proc sql;
        select count(distinct ID) into :SubN from &data. where &where and ^missing(&class);
        select count(distinct ID) into :SubMissN from &data. where &where and missing(&class);
    quit;

    data freq_&order1;
        set freq_&order1;
        length item1 item2 col1 $200;

        order1 = &order1;
        order2 = &class; 

        item1  = put(order1, &tabfmt..);
        item2  = put(order2, &format..);
        
        if &SubN = 0 and missing(order2) then col1 = "&SubMissN";
        else if &SubN = 0 then col1 = 'NA';
        else if n = 0 then col1 = '  0';
        else if n = &SubN then col1 = put(n,3.)||' ('||'100%)';
        else col1 = put(n,3.)||' ('||strip(put((n/&SubN)*100,round1_.))||'%)'; 
        keep item1 item2 order1 order2 col1;        
    run;
%mend;