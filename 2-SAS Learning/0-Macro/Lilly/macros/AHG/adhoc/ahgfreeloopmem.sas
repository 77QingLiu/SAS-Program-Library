%macro AHGfreeloopmem(dsn,byvars
,cmd=
,out=outAhuige
,in=Ahuige
,url=
,bydsn=&url.BY
,execute=1
,del=1
,addLoopVar=0
,low=0
,up=99999999
,outlib=work
,print=dataset:&dsn @cmd:&cmd @ by:&byvars);
/*
1 New dsn: &url.by(1)  &url&outone.&i	(N*O)
2  New Mac: &url.N

*/
%if %AHGblank(&url) %then %let url=_%substr(%AHGrandom,1,3);
%if %AHGblank(&cmd) %then %let cmd= put abc ;
%let cmd=%nrstr(%%)&cmd;
%AHGdatadelete(data=&url:);
%symdel &url.N;
%global &url.N;


proc sql noprint;
	create table &bydsn as
	select distinct %AHGaddcomma(&byvars)
	from &dsn
	order by  %AHGaddcomma(&byvars)
	;quit;
%local i byn;

%AHGnobs(&bydsn,into=&url.N);

data
%do i=1 %to &&&url.N;
&url&i
%end;
;
	set &bydsn;
	%do i=1 %to &&&url.N;
	if _n_=&i then output &url&i ;
	%end;
run;

%do i=1 %to &&&url.N;

%if &del %then
	%do;
	%AHGmergedsn(&url&i,&dsn,&in,by=&byvars,joinstyle=left/*left right full matched*/);
	%end;
%else
	%do;
	/* if not del then the temp &url&i dsn is there */
	%AHGmergedsn(&url&i,&dsn,&url&i,by=&byvars,joinstyle=left/*left right full matched*/);
	data &in ;
		set  &url&i;
	run;
	%end;


%AHGpm(cmd);
%if &execute=1 %then
	%do;
	%put ######################freeloopNo&i;
  %put &print;
	%if %eval(&low<=&i) and %eval(&i<=&up) %then
		%do;
		%unquote(&cmd);
		%local j OneOut;
			%do j=1 %to %AHGcount(&out);
				%let OneOut=%scan(&out,&j);
				data &outlib..&url&OneOut&i;
				  set  &OneOut;
				  %if &addLoopVar %then
				  %do;
				  point=&i;
				  set &bydsn point=point;
				  %end;
				run;
			%end;
		%end;
	
	
	%end;
	
	
%end;


%AHGdatadelete(data=&in &out  %if &del %then %do i=1 %to &&&url.N; &url&i %end;);

%mend;

