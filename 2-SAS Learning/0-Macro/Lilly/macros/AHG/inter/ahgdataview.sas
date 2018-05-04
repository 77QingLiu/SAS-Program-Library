%macro AHGdataview(dsin=,dsout=,order=original
,SameVal=noDelete,open=1
);
    %local content vardsn one;
    %AHGgettempname(content);
    proc contents data=&dsin out=&content;
    run;
    %if %AHGblank(&dsout) %then %let dsout=%AHGbarename(&dsin)_uniq;
    %local onedsn mydsn onevar;
    %local fn rdm;
    %let rdm=%AHGrdm(20)_;
    %let fn=ahg9xsadfxeeqfz;
    %macro ahg9xsadfxeeqfz(var,loop);
        proc sql noprint;
            create table &rdm&loop as
            select distinct &var
            from &dsin(keep=&var)
            order by &var ;
            %let onedsn=;
            select "&rdm&loop" into :onedsn
            from  &rdm&loop
            %if %AHGequalmactext(&SameVal,delete) %then having count(*)>1; ;
            quit;

        %let mydsn=&mydsn  &onedsn;
        
    %mend;

    %if &order~=alpha %then 
        %do;
        proc sort  data=&content;
            by varnum;
        run;
        %end;

    %local i varlist;
    proc sql noprint;
      select name into :varlist separated by ' '
      from &content
      ;
      quit;
    %do i=1 %to %AHGcount(&varlist);
    %&fn(%scan(&varlist,&i),&i);
    %end;


    data &dsout;
        merge   &mydsn;
    run;
    %AHGdatadelete(data=&rdm:);
    %if &open %then dm "vt &dsout" viewtable:&dsout;
%mend ;

