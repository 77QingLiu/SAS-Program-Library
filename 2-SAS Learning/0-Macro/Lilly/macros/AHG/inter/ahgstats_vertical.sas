%macro AHGstats_vertical(dsn,var,out=stats,print=0,by=,alpha=0.05
,stats=n mean median  min max,split=\
,byfmts=
,split2=#
,bigby=

);

%local statN single %AHGwords(mystat,20)
	%AHGwords(myformat,20) %AHGwords(IsStat,20);
%local i sortdsn mystats;

%AHGgettempname(sortdsn);

%AHGdatasort(data = &dsn,out=&sortdsn, by =&bigby &by);
%do i =1 %to %AHGcount(&stats);
	%let single=%scan(&stats,&i,%str( ));
	%let isStat&i=0;
	%if not %index(&single,%str(%")) %then
	%do;
	%let isStat&i=1;
	%let mystats=&mystats &single ;
	%end;
%end;

%put I am fine out=&out;
%AHGsetstatfmt(statfmt=&mystats);
%let statN=%AHGcount(&stats);

%do i=1 %to &statN;
	%let single=%scan(&stats,&i,%str( ));
	%let mystat&i=%scan(&single,1,&split);
	%let myformat&i=%scan(&single,2,&split);
	%if %AHGblank(&&myformat&i) and %str(&&isStat&i) %then %let myformat&i=&&&&formatof&&mystat&i;
	%if &&isStat&i %then %AHGpm(mystat&i myformat&i);
%end;
%put I am fine 2;

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
		format ahuigeby $50.;
		if %AHGequaltext(input(&by,$100.),"%scan(%scan(&byfmts,&i,&split),1,&split2)")
		then ahuigeby="%scan(%scan(&byfmts,&i,&split),2,&split2)";
		%end;


	run;

%if &orie=hori %then	
	%do;
	proc sql;
		%if not &print %then create table &out as ;
		select
/*		%if not %AHGblank(&bigby) %then %str(&bigby,);*/
		ahuigeby/* %sysfunc(tranwrd(&by,%str( ),%str(,)))*/
		%do i=1 %to  %AHGcount(&stats);
			%if &&isStat&i %then ,put(&&mystat&i, &&myformat&i) as  &&mystat&i ;
			%else  ,&&mystat&i;
		%end;
		from &out
		;quit;

	%end;

%if &orie=vert %then	
	%do;

	data ahuigeprint;
		set  &out ;
		%do i=1 %to  %AHGcount(&stats);
			%if &&isStat&i %then ,put(&&mystat&i, &&myformat&i) as  &&mystat&i ;
			%else  ,&&mystat&i;
		%end;
		from &out
		;quit;

	%end;



%mend;

