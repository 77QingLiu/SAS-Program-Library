%macro AHGsetprint(dsns,out=setprint,print=0,prefix=,by=,ord=,keep=0,length=500);
%local i dsnN item onedsn alldsn; 
%if %AHGblank(&prefix) %then %let prefix=%AHGrdm(9);
%let dsnN=%AHGcount(&dsns);
%local allvar varlist;
%do i=1 %to  &dsnN;
  %let item=%scan(&dsns,&i,%str( ));
  %AHGgettempname(onedsn);
  %let alldsn=&alldsn &onedsn;
  data &onedsn;
    %if %AHGnonblank(&ord) %then  &ord=&i;;
    %if %AHGnonblank(&by) %then 
    %do;
    format &by $40.; &by="&item";
    %end;
    set &item;
  run;
  %AHGalltocharnew(&onedsn,out=&onedsn);
  %AHGvarlist(%scan(&dsns,&i,%str( )),Into=varlist);
  %if %AHGcount(&varlist)> %AHGcount(&allvar) %then 
        %let allvar=&allvar %AHGscansubstr( &varlist,%eval(%AHGcount(&allvar)+1),%eval(%AHGcount(&varlist)-%AHGcount(&allvar)));
  %AHGmergeprint(&onedsn,out=&onedsn,print=0,prefix=&prefix,length=&length);

%end;

data &out;
  set &alldsn;
run;

%if &keep %then %AHGrenamekeep(&out,names=&allvar,keepall=0);
%else  %AHGrenamekeep(&out,keepall=0);
%AHGtrimdsn(&out);

%if  &print %then %AHGprt;
%mend;
