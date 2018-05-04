%macro AHGsubsetdsn(dsn);
    data &dsn;
        set &dsn;
        where %unquote(&wherestr);
    run;
%mend;
