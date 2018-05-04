%macro AHGdsn(dsn,out=,where=1);
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
    data &out;
        set &dsn;
        if &where;
    run;
%mend;
