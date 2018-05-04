%macro AHGmergeprint(dsns,by=,drop=,label=label
,out=mergeprintout,print=1
,prefix=
,clean=1
,z=3
,keep=0
,length=500
);
%if %AHGblank(&prefix) %then %let prefix=%AHGrdm(9);
%local i dsnN   ;
%let dsnN=%AHGcount(&dsns);
%local %AHGwords(Printing,&dsnN);


%do i=1 %to &dsnN;
%let printing&i=;
%AHGgettempName(printing&i);
%end;

%local allvar;
%do i=1 %to &dsnN;
%local varlist charlist;
%let varlist=;
%let charlist=;
%AHGvarlist(%scan(&dsns,&i,%str( )),Into=varlist);
%let allvar=&allvar &varlist;

%AHGallchar(%scan(&dsns,&i,%str( )),into=charlist);
%AHGpm(printing&i);
data &&printing&i;

%do j=1 %to %AHGcount(&varlist);
%if %sysfunc(indexw(&charlist,%scan(&varlist,&j))) %then format &prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))   $&length.. ;
%else length &prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))   8;
;
%end;    

    set %scan(&dsns,&i,%str( ))
(
%do j=1 %to %AHGcount(&varlist);
%if not %sysfunc(indexw(%upcase(&by),%upcase(%scan(&varlist,&j))  )  )
   and  %lowcase(%scan(&varlist,&j)) ne ahuigebylabel
  %then rename=(%scan(&varlist,&j)=&prefix._%sysfunc(putn(&i,z&z..))_%sysfunc(putn(&j,z&z..))    ) ;
%end;
);


run;

%end;


data &out;
    merge  %do i=1 %to &dsnN; &&printing&i  %end;   ;
run;

%AHGuniq(&allvar,allvar);

%local dropstat;
%if not %AHGblank(&drop) %then %let dropstat=( drop= &drop) ;

%if &keep %then %AHGrenamekeep(&out,out=&out&dropstat ,names=&allvar,keepall=0);

%if &clean %then %AHGdatadelete(data=%do i=1 %to &dsnN; &&printing&i  %end;);

%if &print %then
%do;
proc print &label noobs width=min
;
run;
%end;


%mend;

