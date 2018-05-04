      rc=rc;

init:
   *** TURN OFF SOURCE AND NOTES ***;
   rc=optsetn('source',0);
   rc=optsetn('notes',0);


   *** START SAS SUBMIT BLOCK ***;
   submit continue;
      ** START MACRO DEFINITION **A;


%macro logsum;

    ** SAVE THE CURRENT MACRO TRACING OPTIONS SO THEY CAN BE RESTORED LATER ***;
    %let option_mprint    = %sysfunc(getoption(mprint));
    %let option_mlogic    = %sysfunc(getoption(mlogic));
    %let option_symbolgen = %sysfunc(getoption(symbolgen));

    options nosource nonotes nomprint nomlogic nosymbolgen;

    ** Input log file **;
    filename temp_lo temp ;
    dm 'log;file temp_lo;nums on;';

    data _check_a;
        infile temp_lo truncover lrecl=30000;
        input;
        length a$30000;
        a=_infile_;
        if ^missing(a) and not prxmatch('/^(-+|\d+)$/o',strip(a));
    run;

    ** Clean log file **;
    data _check_b;

        set _check_a;
        length num num_last $20 a_last $30000;
        retain num ;
        if prxmatch('/^(\d+)\D+.+/o',a) then num= prxchange('s/^(\d+)\D+.+/$1/o',1,a);
        num_last =lag(num);
        a_last   =lag(a);
    run;

    data _check_c;
        set _check_b;
        length txt $30000;
        by num  notsorted;
        retain txt;
        if first.num then txt='';
        if not prxmatch('/^(\d+)\D+.+/o',a)
           and not (prxmatch('/^where/io',strip(a)) and prxmatch('/missing/io',a)) then  txt=catx('||||',txt,a);
        if last.num then output;
    run;

    ** Define Log check content **;
    data _core;
        length chktext $50;
        chktext="ABNORMALLY TERMINATED"; output;
        chktext="ANNOTATION"; output;
        chktext="APPARENT"; output;
        chktext="CONVERSION"; output;
        chktext="CONVERTED"; output;
        chktext="ERROR"; output;
        chktext="EXTRANEOUS"; output;
        chktext="HARD CODE"; output;
        chktext="HARD-CODE"; output;
        chktext="HARDCODE"; output;
        chktext="IN ANNOTATE"; output;
        chktext="INVALID"; output;
        chktext="MERGE STATEMENT"; output;
        chktext="MISSING"; output;
        chktext="MULTIPLE"; output;
        chktext="NOT EXIST"; output;
        chktext="NOT RESOLVED"; output;
        chktext="NOTE: THE SAS SYSTEM"; output;
        chktext="OUTSIDE"; output;
        chktext="REPLACED"; output;
        chktext="SAS SET OPTION OBS=0"; output;
        chktext="SAS WENT"; output;
        chktext="STOPPED"; output;
        chktext="TOO LONG"; output;
        chktext="TRUNCATED"; output;
        chktext="UNINIT"; output;
        chktext="UNKNOWN"; output;
        chktext="W.D FORMAT"; output;
        chktext="WARNING"; output;
        chktext="WHERE CLAUSE"; output;
        chktext="WILL BE OVERWRITTEN"; output;
        chktext="_ERROR_"; output;
    run;
        data _null_;
            set _core end=eof;
            call symputx('_chktext'||put(_n_,best. -l),strip(chktext));
            if eof then call symputx("_nchktxt", compress(put(_n_, 8.)));
        run;

    ** Check the log using value above **;
    %macro check;
        data _check_d;
            set _check_c ;
            where ^missing(txt);
            length message $200;
            %do i=1 %to &_nchktxt;

            if prxmatch("/&&_chktext&i/oi",txt)  then message=catx(';
 ',message,"&&_chktext&i");
            %end;
           if ^missing(message) then
             message= catx(' ',message,'Occured Between Line',strip(num),'-',put((input(num,best.)+1),best. -l));
           if ^missing(message);
        keep message;
        run;
    %mend check;
    %check;


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
        if n ne 0 then put 'WARNING:' @20 message;
        if n eq 0 then do;
            put /@10'-----------------------------------------------------';
            put @10'| No suspicious lines were discovered in the log.  |';
            put @10'----------------------------------------------------';
        end;

    run;

    ** Clean library **;
    proc datasets nolist lib=work memtype=data ;
        delete _check_a _check_b _check_d _check_c _core;
    run;
    quit;


    ** RESTORE MACRO TRACING OPTIONS TO THEIR ORIGINAL VALUES ***;
    options &option_mprint;
    options &option_mlogic;
    options &option_symbolgen;
%mend;
%logsum;


   *** END SAS SUBMIT BLOCK ***;
   endsubmit;

    rc=optsetn('source',1);
    rc=optsetn('notes',1);
return;
