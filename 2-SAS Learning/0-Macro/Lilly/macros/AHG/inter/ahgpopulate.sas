
option mprint;
%macro AHGpopulate(dsn,into=PopulateDSN
,by=,columnby=,columnbyitem=);
%local emp colbyall colbyN i ;
%let colbyall=;
%AHGdistinctValue(&dsn,&columnby,into=colbyall,dlm=@ );
%let colbyN=%AHGcount(&colbyall,dlm=@);
%AHGpm(colbyall colbyn);

%AHGgettempname(emp);
%AHGemptydsn(&dsn,out=&emp);	
%AHGmergePrint(%do i=1 %to &colbyN; &emp %end; ,by=sex age,drop=,out=all,print=1,prefix=ahuigecol);
%local varlist;
%let varlist=;
%AHGvarlist(all,Into=varlist,global=0,print=1);
%let varlist=%AHGremoveWords(&varlist,sex age,dlm=%str( ));
%AHGordvar(all,sex age &varlist,out=allall,keepall=0);
%AHGopendsn(allall);
%mend;
/**/
/*%AHGpopulate(sashelp.class,into=PopulateDSN*/
/*,by=age,columnby=sex,columnbyitem=);*/
