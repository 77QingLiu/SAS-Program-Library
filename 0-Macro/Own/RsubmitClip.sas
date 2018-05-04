



options mstored sasmstore = sasuser;
%macro RsubmitClip / store;
    options nosource nonotes;
    filename clip clipbrd;
    data _null_;
        infile clip end=last;
        input;
        if _n_ = 1 then call execute('rsubmit grid; ');
        call execute(_INFILE_);
    run;
%mend;
