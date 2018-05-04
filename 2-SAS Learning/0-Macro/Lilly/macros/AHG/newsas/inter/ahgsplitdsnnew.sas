%macro AHGsplitdsnNew(dsn,by,prefix=,into=,intoby=,nofmt=0);
%if %AHGblank(&prefix) %then %let prefix=splitdsn;
%local byN i dsns mydsn;
%AHGgettempname(mydsn);

%if &nofmt %then
%do;
data &mydsn;
	format &by best.;
	set &dsn;
run;	
%end;
%else
%do;
data &mydsn;
	set &dsn;
run;	
%end;


proc sql noprint;
	select count(distinct &by) into :byN
	from &mydsn
	;
	%if not %AHGblank(&intoby) %then
	%do;
	proc sql noprint;
	select distinct &by into :&intoby separated by '@'
	from &mydsn
	order by &by
	;
	%end;
	quit;


proc sort data=&mydsn ;
	by &by;
run;

%AHGsomeTempName(dsns,&byN,start=&prefix);
%if not %AHGblank(&into) %then %let &into=&dsns;

data &dsns;
	set &mydsn;
	by &by;
	if first.&by then ahuigebycount4352+1;
	drop ahuigebycount4352;
	%do i=1 %to &byN;
	if 	ahuigebycount4352=&i then output %scan(&dsns,&i);
	%end;
run;

%mend;

