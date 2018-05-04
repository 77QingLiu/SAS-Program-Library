%let thedsn=adam.adex;
%AHGtime(1);
%AHGDataView(dsin=&thedsn,dsout=adsl,order=original,SameVal=noDelete,open=0);

%let file=&localtemp\class.txt;
data _null_;
    set adsl;
    file "&file";
    array allnum _numeric_;
    array allchar _char_;
    array nullchar(1) $500 _temporary_;
    do over allnum;
      if index(vformat(allnum),'DATE') and not index(vformat(allnum),'DATET') then nullchar(1)= '.'||vname(allnum)||'    '''||put( allnum,date9.)||'''d';
      else nullchar(1)= '.'||vname(allnum)||'    '||put( allnum,best.);
      if not missing(allnum) then put nullchar(1);
    end;
    do over allchar;
      nullchar(1)='.'||vname(allchar)||'      "'||trim(allchar)||'"';
      if not missing(allchar) then put nullchar(1);
    end;
    ;
  run;


%macro AHGdsntofile(dsn,file,var=);
%local i myallchar myallnum allvar;
%if %AHGblank(&var) %then %AHGvarlist(&dsn,Into=var,dlm=%str( ),global=0);

%AHGallchar(&dsn,into=myallchar);
%AHGallnum(&dsn,into=myallnum);

  data _null_;
    file "&file" mod;
    set &dsn;
    array zen(1) $200. _temporary_; 
    %do i=1 %to %AHGcount(&var);
    zen(1)="..%scan(&var,&i)  "||vformat(%scan(&var,&i));
    put zen(1);
    zen(1)="%scan(&var,&i)  /*"||vlabel(%scan(&var,&i))||'*/';
    put zen(1);
    %end;
    ;

    put "...allchar    &myallchar";
    put "...allnum     &myallnum";
    put "...allvar     %sysfunc(trim(&var))";
    %macro dosomething;
    %local i str;
    %let str=data  proc set run merge put ;
    %do i=1 %to %AHGcount(%str(&str));
    put "%scan(&str,&i)"  ;
    %end;

    %mend;
/*    %doSomething*/
    stop;
  run;
%mend;



%AHGdsntofile(&thedsn,&localtemp\class.txt,var=);

%AHGtime(2);

%AHGinterval(1,2);

x "&localtemp\class.txt";
 
