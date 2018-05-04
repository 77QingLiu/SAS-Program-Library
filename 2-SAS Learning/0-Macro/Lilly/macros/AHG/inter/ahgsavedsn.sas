%macro AHGsavedsn(dsn,ext=_qc,lib=);
    data &lib&dsn.&ext;
        set &dsn;
    run;
%mend;
