%macro AHGfreesplit(dsn,byvars,outPref=,bydsn=);
%AHGdatadelete(data=&outpref:);
%AHGdel(&outpref,like=1);
%global &outPref.N;


proc sql;
	create table &bydsn as
	select distinct %AHGaddcomma(&byvars)
	from &dsn
	group by  %AHGaddcomma(&byvars)
	;quit;
%local i byn;



%AHGnobs(&bydsn,into=&outPref.N);


data
%do i=1 %to &&&outPref.N;
&outpref&i
%end;
;
	set &bydsn;
	%do i=1 %to &&&outPref.N;
	if _n_=&i then output &outpref&i ;
	%end;
	run;

%do i=1 %to &&&outPref.N;
%AHGmergedsn(&outpref&i,&dsn,&outpref&i,by=&byvars,joinstyle=left/*left right full matched*/);
%end;


%mend;
