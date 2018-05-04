%macro AHGmergedsn(dsn1,dsn2,outdsn,by=,rename=1,joinstyle=full/*left right full matched*/);
%local mergedsn1 mergedsn2;
%if &rename %then
%do;
%AHGGetTempName(mergedsn1,start=%sysfunc(tranwrd(%scan(&dsn1,1,%str(%()),.,_))_);
%AHGGetTempName(mergedsn2,start=%sysfunc(tranwrd(%scan(&dsn2,1,%str(%()),.,_))_);
%end;
%else
%do;
%let mergedsn1=&dsn1;
%let mergedsn2=&dsn2;
%end;
%AHGdatasort(data =&dsn1 , out =&mergedsn1 , by =&by );
%AHGdatasort(data =&dsn2 , out =&mergedsn2 , by =&by );
%local ifstr;
%if %lowcase(&joinstyle)=full %then %let ifstr=%str(ind1 or ind2);
%if %lowcase(&joinstyle)=matched %then %let ifstr=%str(ind1 and ind2);
%if %lowcase(&joinstyle)=left %then %let ifstr=%str(ind1 );
%if %lowcase(&joinstyle)=right %then %let ifstr=%str(ind2 );
data &outdsn;
    merge  &mergedsn1(in=ind1) &mergedsn2(in=ind2) ;
    by &by;
    if &ifstr;
run;
%AHGdatadelete(data=&mergedsn1 &mergedsn2);
/*
%local i;
%if %lowcase(&joinstyle)=matched %then %let joinstyle=;
proc sql noprint;
    create table &outdsn as
    select *
    from &dsn1 as l &joinstyle join &dsn2 as r
    on 1 %do i=1 %to %AHGcount(&by);
       %bquote( and L.%scan(&by,&i)=r.%scan(&by,&i)   )
       %end;
       ;quit;
 */
%mend;
