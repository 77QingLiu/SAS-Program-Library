%macro AHGprocMeansBy(dsn,var,out=stats,print=0,alpha=0.05
,stats=n mean median  min max /*n @ min '-' max*/
,split=\
,by=
,byord=
,byorie=
,orie=
,labels=
);
%local i byitems onedsn bydsns;
%AHGdistinctValue(&dsn,&by,into=byitems,dlm=@);
%AHGpm(byitems);
%if %AHGblank(&byord) %then %let byord=%AHGwords(%str(),%AHGcount(&byitems,dlm=@));
%AHGpm(byord);
%AHGsplitdsn(&dsn,&by,into=bydsns);
%do i=1 %to  %AHGcount(&byord);
	%let onedsn=%scan(&bydsns,%scan(&byord,&i));
	%AHGpm(onedsn);
	%AHGprocMeans(&onedsn,&var,out=&out%scan(&byord,&i),print=0,alpha=&alpha
	,stats=&stats  
	,orie=&orie
	,labels=&labels
	);
%end;

%if  %AHGequalmactext(&byorie,vert) %then
%do;
data &out;
	set
	%do i=1 %to  %AHGcount(&byord);
		 &out%scan(&byord,&i)
	%end;
	;
run;
%end;

%if  %AHGequalmactext(&byorie,hori) %then
%do;
%AHGmergePrint(
%do i=1 %to  %AHGcount(&byord);
		 &out%scan(&byord,&i)
%end;
%if not %AHGblank(&labels) %then ,by=label;
,drop=,out=&out,print=0,prefix=ahuigecol);

%end;

%if &print %then
%do;
proc print data=&out noobs;
run;
%end;
%mend;

