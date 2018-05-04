%macro AHGdistinctvalue(dsn,var,sort=1,into=,dlm=@,quote=0);
%local item varIsNum ;
%let varIsnum=1;

%if   &quote %then %AHGvarisnum(&dsn,&var,into=varIsNum);

%let item=&var;
%if %eval(&quote and not &varIsNum )%then %let item=quote(&var);

%if not &sort %then
  %do;
  data _null_;
    format line&var $32333.;
    retain line&var;
    set &dsn(keep=&var) end=end;
    line&var=catx("&dlm",line&var,&var);
    if end then call symput("&into",line&var);
  run;
  %end;
%else 
    %do;
    proc sql noprint;
    select distinct 

    &item 
    into :&into separated by "&dlm"
    from &dsn
    ;quit;
    %end;
%let &into=%trim(&&&into);

%mend;
