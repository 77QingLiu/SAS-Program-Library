
%macro AHGstatscol(dsn,var,out=stats,print=0,by=,alpha=0.05
,stats=n mean median  min max
,statlabels=
,split=\
,byfmts=
,split2=#
,bigby=
,orie=/*vert*/
,colby=
);

%local inttostr i singlecol colN colAll;
%let inttostr=;
%AHGgettempname(inttostr);

data &intToStr;
	set &dsn;
	ahuigeSTR_&colby=input(&colby,$50.);
run;

%let colby=ahuigeSTR_&colby;
proc sql noprint;
	select distinct(&colby) into :colAll separated by '@'
	from &intToStr
	; quit;
%AHGpm(colall);
%let colN=%AHGcount(&colAll,dlm=@);

%local alloutdsn;
%local %AHGwords(colDsn,&coln);
%do i=1 %to &coln ;
	%let  colDSN&i=;
	%AHGgettempname(colDsn&i);
	data  &&colDsn&i;
		set &intToStr(where=(&colby="%scan(&colAll,&i,@)"));
	run;
%AHGstats(&&colDsn&i,&var,out=&out&i,print=0,by=&by,alpha=&alpha
,stats=&stats
,statlabels=&statlabels
,split=&split
,byfmts=&byfmts
,split2=&split2
,bigby=&bigby
,orie=&orie

);
%let alloutdsn=&alloutdsn &out&i;
%end;

%AHGpm(alloutdsn);
%AHGmergeprint(&alloutdsn,by=label);
%mend;
