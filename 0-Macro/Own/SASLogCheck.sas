
%macro SASLogCheck;
    data _null_;
        infile LogFile truncover lrecl=30000;
        input;
        put _infile_;
    run;

    ** Input log file **;
    /* filename LogFile "&LogFile"; */
    options nosource nonotes;
    data _check_a;
        infile LogFile truncover lrecl=30000;
        input;
        length content$30000;
        content=_infile_;
        if ^missing(content) and not prxmatch('/^(-+|\d+)$/o',strip(content));
        keep content;
    run;

    ** Clean log file **;
    data _check_b;
        set _check_a;
        length num num_last $20 content_last $30000;
        retain num ;
        if prxmatch('/^(\d+)\D+.+/o',content) then num= prxchange('s/^(\d+)\D+.+/$1/o',1,content);
        if prxmatch('/^(NOTE:|WARNING:|ERROR) /o', content) or prxmatch('/^\d+!? +/o', content) then isline = 'Y';
        num_last     = lag(num);
        content_last = lag(content);
        N + 1;
    run;
    proc sort; by descending N; run;

    data _check_c;
        set _check_b;
        by descending N;
        length txt $30000;
        retain txt;
        txt = catx('||||',content,txt);
        if isline = 'Y' then do;
            Output;
            txt = '';
        end;
    run;
    proc sort;by N; run;

    ** Define Log check content **;
    %let __NOTE_CHECK__ = uninitialized|Invalid|MERGE statement has more than one data set|values have been converted|Input data set is empty|W.D format|Missing values were generated|Unknown|will be overwritten by;

    data _check_d;
        set _check_c;
        length CheckContent $200;
        pattern = prxparse("/(?<=^NOTE:).+\b(&__NOTE_CHECK__)\b/o");

        if prxmatch('/(?<=^ERROR).+/o', txt) then CheckContent = 'ERROR';
        if prxmatch('/(?<=^WARNING:).+/o', txt) then CheckContent = 'WARNING';
        if prxmatch(pattern, txt) then CheckContent = prxposn(pattern, 1, txt);

        if ^missing(CheckContent);
        num_1 = num + 1;
    run;
    data _check_d;
        set _check_d;
        CheckContent_lag = lag(CheckContent);
        num_lag          = lag(num);
        num_last_lag     = lag(num_last);
        if CheckContent = CheckContent_lag and num = num_lag and num_last = num_last_lag then delete;
        keep CheckContent num num_1 num_last;
    run;

    ** Output Log message **;
    data _null_;
        if 0 then set _check_d nobs=n;
        if n ne 0 then set _check_d;

        if _n_ =1 and n ne 0 then do;
            put @10'-------------------------------------------------------------------------------------------';
            put @10'| The following suspicious lines were found when scanning the log:                        |';
            put @10'-------------------------------------------------------------------------------------------';
            put @10' ';

        end;
        if n ne 0 and missing(num) and missing(num_last) then put 'WARNING:' @20 CheckContent @60 '[ Occured on Set-Up]' ;
        if n ne 0 and ^missing(num) then put 'WARNING:' @20 CheckContent @60 '[ Occured Between Line ' num '-' num_1 ']';
        if n eq 0 then do;
            put /@10'-----------------------------------------------------';
            put @10'| No suspicious lines were discovered in the log.  |';
            put @10'----------------------------------------------------';
        end;
    run;

    ** Clean library **;
    proc datasets nolist lib=work memtype=data ;
        delete _check_a _check_b _check_c _check_d ;
    run;
    quit;

%mend;