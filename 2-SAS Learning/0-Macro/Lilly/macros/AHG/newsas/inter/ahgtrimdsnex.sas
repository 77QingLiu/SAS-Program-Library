%macro AHGtrimDsnEx(dsn,out=,min=3,left=1);
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
%local max charlist i count rdn len varlist;

%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
/*%AHGgettempname(max);*/

%if &left %then
  %do;
  data &out;
    set &dsn;
    array allchar _character_;
    do over allchar;
      allchar=left(allchar);
    end;
  run;
  %end;
%else 
  %do;
  data &out;
    set &dsn;
  run;
  %end;



%AHGallchar(&out,into=charlist);


%let count=%AHGcount(&charlist);
%let rdn=%AHGrdm(20);

data _null_;
  retain 
  %do i=1 %to &count;
  &rdn.&i 
  %end;
  &min
  ;
  set &out end=end;
  %do i=1 %to &count;
  if length(%scan(&charlist,&i))> &rdn.&i then &rdn.&i=length(%scan(&charlist,&i));
  %end;

  keep &rdn:;
  if end then  call symput('len',compbl(''
  %do i=1 %to &count;
   ||&rdn.&i
  %end;
  ))

  ;
run;

data &out;
  format
  %do i=1 %to &count;
  %scan(&charlist,&i) $%scan(&len,&i). 
  %end;
  ;
  set &out;
run;
/*%if &left %then*/
/*  %do;*/
/*  data &out;*/
/*  set &out;*/
/*  array allchar _character_;*/
/*    do over allchar;*/
/*      allchar=left(allchar);*/
/*    end;*/
/*  run;*/
/*  %end;*/
%AHGordvar(&out,&varlist,out=,keepall=0);

%mend;

