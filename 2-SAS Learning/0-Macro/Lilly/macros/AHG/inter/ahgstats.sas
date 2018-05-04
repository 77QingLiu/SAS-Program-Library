%macro AHGstats(dsn,var,out=stats,print=0,by=,alpha=0.05
,stats=n mean median  min max
,statlabels=
,split=\
,byfmts=
,split2=#
,bigby=
,bigbyfmts=
,bigbypos=none/*Top first all none*/
,orie=/*vert*/
,bylength=50
,bigbylength=8

);

%local i;
%do i=1 %to %AHGcount(bigbyfmts);
	%let bigbylength=%sysfunc(max(&bigbylength,%length(%AHGscan2(&bigbyfmts,&i,2))));
%end;
%AHGpm(bylength);
%do i=1 %to %AHGcount(byfmts);
	%let bylength=%sysfunc(max(&bylength,%length(%AHGscan2(&byfmts,&i,2))));
%end;
%AHGpm(bylength);




/*if no explicit definition of orientation then use @ as criteria*/
%if   %AHGblank(&orie)  %then 	%if %index(&stats,@) %then %let orie=vert ;%else  %let orie=hori;
%local localstats;
%let localstats=&stats;
%let stats=%sysfunc(tranwrd(&stats,@,%str( )));
%local statN single %AHGwords(mystat,20)
	%AHGwords(myformat,20) %AHGwords(IsStat,20);
%local i sortdsn mystats;

%AHGgettempname(sortdsn);

%if %AHGblank(&by) %then
	%do;
	%let by=ahuigedummyby;
	%let byfmts=1#"" ;
	data  &sortdsn;
		set &dsn;
		ahuigedummyby=1;
	run;
	%end;
%else
	%do;
	data  &sortdsn;
		set &dsn;
	run;
	%end;

%AHGdatasort(data = &sortdsn,out=&sortdsn, by =&bigby &by);
%do i =1 %to %AHGcount(&stats);
	%let single=%scan(&stats,&i,%str( ));
	%let isStat&i=0;
	%if not  (%index(&single,%str(%")) or %index(&single,%str(%'))) %then
	%do;
	%let isStat&i=1;
	%let mystats=&mystats &single ;
	%end;
%end;


%AHGsetstatfmt(statfmt=&mystats);
%let statN=%AHGcount(&stats);

%do i=1 %to &statN;
	%let single=%scan(&stats,&i,%str( ));
	%let mystat&i=%scan(&single,1,&split);
	%let myformat&i=%scan(&single,2,&split);
	%if %AHGblank(&&myformat&i) and %str(&&isStat&i) %then %let myformat&i=&&&&formatof&&mystat&i;
	%if &&isStat&i %then %AHGpm(mystat&i myformat&i);
%end;


	proc means data=&sortdsn noprint alpha=&alpha;;
		var	&var;
		output out=&out	
		%do i=1 %to  &statN;
		%if &&isStat&i %then &&mystat&i%str(=)&&mystat&i;
		%end;
		;
		%if not %AHGblank(&bigby&by) %then by &bigby &by;;
	run;


	data &out;
		set &out;

		%do i=1 %to %AHGcount(&byfmts,dlm=&split);
		format ahuigeby $&bylength..;
		if %AHGequaltext(input(&by,$100.),"%AHGscan2(&byfmts,&i,1)")
		then ahuigeby="%AHGscan2(&byfmts,&i,2)";
		%end;


	run;

%local keepbigby;
%if not %AHGblank(&bigby) %then %let keepbigby=&bigby;
	proc sql;
		create table &out as
		select
		%if not %AHGblank(&bigby) %then %AHGaddcomma(&bigby) ,;
		ahuigeby
		%do i=1 %to  %AHGcount(&stats);
			%if &&isStat&i %then ,put(&&mystat&i, &&myformat&i) as  &&mystat&i ;
			%else  ,put(&&mystat&i,  $%eval(%length(&&mystat&i)-2).);
		%end;
		from &out
		;quit;


%if &orie=vert %then	
%do;

%local varlist varN bigsingle statement;
%AHGvarlist(&out,Into=varlist,dlm=%str( ),global=0);
%local  num indx	;
%let indx=1;
%let varN=%AHGcount(&localstats,dlm=@);
%do i=1 %to &varN;
	%let bigsingle=%scan(&localstats,&i,@);
	%do num=1 %to %AHGcount(&bigsingle);
	%let indx=%eval(&indx+1);
	%if &num=1 %then %let statement=&statement 	%str(theVerticalvar&i=) %scan(&varlist,&indx);
	%else  %let statement= &statement ||'  '|| %scan(&varlist,&indx);
	%if &num=%AHGcount(&bigsingle) %then  %let  statement= &statement %str(;);
	%end;
%end;

%local vertdsn;
%AHGgettempname(vertdsn);

data &vertdsn;
	set &out;
	keep &keepbigby ahuigeby %do i=1 %to  &varN; theVerticalvar&i  %end;  ;
    %unquote(&statement);
run;

data hori&out;
	set &out;
run;

data &out;
	set &vertdsn;
	keep  &keepbigby ahuigeby label stat;
	array allvar(1:&varN) theVerticalvar1-theVerticalvar&varN;
	do i=1 to dim(allvar);

	label=input(scan("&statlabels",i,'\'),$50.);
	stat=input(allvar(i),$50.);
	output;
	end;

	
run;
%end;

%if &by=ahuigedummyby %then
%do;
data &out;
	set &out(drop=ahuigeby);
run;
%end;

%if %AHGequalMacText(&bigbypos,none) %then
%do;
data &out;set &out(drop=&bigby);run;
%end;
%if %AHGequalMactext(&bigbypos,first) %then
%do;
data &out;set &out ; by &bigby; if not first.&bigby then &bigby=.; run;
%end;
%if %AHGequalMactext(&bigbypos,top) %then
%do;
data &out small&out(keep=ahuigebigbyorder ahuigeoriginalorder &bigby);
	ahuigebigbyorder=1;
	set &out ;
	by &bigby;
	ahuigeoriginalorder=_n_;
	output &out;
	if first.&bigby then
	do;
    ahuigebigbyorder=0;
	ahuigeoriginalorder=_n_;
	output small&out;
	end;
run;

data &out;
	set &out small&out(in=insmall);
	if not insmall then &bigby='';
run;

%AHGdatasort(data =&out , out =&out(drop=ahuigeoriginalorder ahuigebigbyorder) , by =ahuigeoriginalorder ahuigebigbyorder);




%end;

%if not %AHGblank(&bigbyfmts) %then
%do;
data &out(rename=(ahuigebigby=&bigby));
	format ahuigebigby $&bigbylength..;
	set &out;
	%do i=1 %to %AHGcount(&bigbyfmts,dlm=\);
		if &bigby=%AHGscan2(&bigbyfmts,&i,1) then ahuigebigby=put("%AHGscan2(&bigbyfmts,&i,2)",$&bigbylength..);
	%end;
	drop &bigby;
run;
%end;
data &out;
  set &out;
  array allchar _character_;
  do over allchar;
  if compress(allchar)='-0.0' then allchar='0.0';
  end;

run;
%if &print %then
%do;
proc print data=&out noobs;
run;
%end;
%theexit:
%mend;

