%macro AHGbang;
  %GLOBAL AHGCLIP AHG_DSN  AHG_str AHG_result AHG_N AHG_I;
  %local themax;
  %let themax=5;
  %AHGdel(ahg_result,like=1);
  %GLOBAL %AHGWORDS(AHG_RESULT,&themax);
  
  %macro dosomething;
  %local i;
  %do i=1 %to &themax;
  %let AHG_RESULT&i=;
  %end;

  %mend;
  %doSomething
  %let AHG_DSN=;
  %LET ahg_n=0;
  %LET AHG_I=0;

  filename ahgclip clear;
  filename ahgclip clipbrd;

  data _null_;
    infile ahgclip truncover;
    format line $500.;
    input line 1-500 ;
    IF INDEX(line,'`') then call symput('AHG_DSN',TRIM(SCAN(LINE,1,'`')));
    IF INDEX(line,'`') then call symput('AHG_STR',TRIM(SCAN(LINE,2,'`')));
    else call symput('AHG_STR',TRIM(SCAN(LINE,2,'`')));
  RUN;

  %AHGpm(ahg_dsn ahg_str);


%macro ___catch(dsn,value,out=,strict=1);
data bang;
  RETAIN dummyASDFJSALFJSA 0;
  DROP dummyASDFJSALFJSA;
  set &dsn;
  array allchar _character_;

    do over allchar;
    if 
    %if &strict %then  upcase(allchar)=%upcase(&value);
    %else index(upcase(allchar),%upcase(&value)); 
    then do;
    put _all_;
    dummyASDFJSALFJSA=dummyASDFJSALFJSA+1;
    call symput('AHG_RESULT'||left(put(dummyASDFJSALFJSA,best.)),trim(allchar));
    call symput('AHG_n',TRIM(PUT(dummyASDFJSALFJSA,BEST.)));
    end;
/*    else do;put 'nonono' _all_;end;*/
    if  dummyASDFJSALFJSA>=&themax then stop;
    end;
run;

%mend;

%LOCAL NODUP;
%AHGgettempname(nodup);

%AHGDataView(dsin=&AHG_dsn,dsout=&nodup,order=original,SameVal=noDelete,open=0);

%___catch(&nodup,"&AHG_str",strict=0);


%mend;


%AHGkill;
%AHGclearlog;
%AHGbang;
