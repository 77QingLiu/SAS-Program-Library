%macro AHGtrimDsn(dsn,out=,min=3,left=1);
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
%local theN;
%AHGnobs(&dsn,into=theN);
%if &theN>0 %then
    %do;
    %local max charlist i count rdn len varlist;

    %AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
    /*%AHGgettempname(max);*/

    %AHGallchar(&dsn,into=charlist);

    %let count=%AHGcount(&charlist);
    %let rdn=%AHGrdm(20);

    data test _null_;
      retain 
      %do i=1 %to &count;
      &rdn.&i 
      %end;
      &min
      ;
      set &dsn end=end;
      %do i=1 %to &count;
      if length(%scan(&charlist,&i))> &rdn.&i then &rdn.&i=length(%scan(&charlist,&i));
      %end;

      keep &rdn:;
      if end then  call symput('len',compbl(''
      %do i=1 %to &count;
       ||trim(put(&rdn.&i,best.))||' '
      %end;
      ))

      ;
    run;
    %local rdm;
    %let rdm=%AHGrdm(25);
    data &out(rename=(
    %do i=1 %to &count;
      &rdm&i=%scan(&charlist,&i)  
    %end;
    ));
      format
      %do i=1 %to &count;
      &rdm&i $%scan(&len,&i). 
      %end;
      ;
      drop 
      %do i=1 %to &count;
      %scan(&charlist,&i)  
      %end;
      ;
      set &dsn;
      %do i=1 %to &count;
      %if &left %then &rdm&i=left(%scan(&charlist,&i));
      %else &rdm&i=%scan(&charlist,&i);
      ;
      %end;
        
    run;

    %AHGordvar(&out,&varlist,out=&out,keepall=0);
    %end;
%mend;

