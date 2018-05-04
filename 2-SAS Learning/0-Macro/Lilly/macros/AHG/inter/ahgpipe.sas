%macro AHGpipe(command,rcmac=rcpipe,start=1,end=999999999,dsn=_null_,global=0);
    %if &global %then %global &rcmac;;
    %let &rcmac=;
    data &dsn;
    FORMAT outstr $1000.;
    RETAIN OUTSTR '';
    filename pip  pipe "&command " ;
    infile pip truncover lrecl=32767 end=eof;
    length line $32767;
    input line 1-32767;
    if &end>=_n_>=&start then outstr=trim(line)||' '||outstr;
    if eof then call symput("&rcmac",compbl(outstr));
    run;

%mend;
