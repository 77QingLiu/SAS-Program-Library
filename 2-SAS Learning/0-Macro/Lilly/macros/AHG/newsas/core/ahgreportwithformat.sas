%macro AHGreportwithformat(dsn,fmts=,groupvar=,split=#,order=data);
	%local varlist info nobs i;
	%local %AHGwords(defstr,50);
	%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
	%AHGgettempname(info);
	%AHGvarinfo(&dsn,out=&info,info=name type length num);
	data _null_;
		set &info;
		format defstr $500.;
		group='       ';
		%do i=1 %to %AHGcount(&fmts);
		if _n_=scan(scan("&fmts",&i,' '),1,'\') then length=scan(scan("&fmts",&i,' '),2,'\') ;
		%end;
		%do i=1 %to %AHGcount(&groupvar);
		if %AHGequaltext("%scan(&groupvar,&i)",name) then group=' group ';
		%end;
		defstr='define '||name||' /display width='||left(length)||group||" flow order=&order;";
		put defstr;
		call symput('defstr'||left(_n_),defstr);
		call symput('nobs',_n_);
	run;

	proc report data=&dsn nowindows headline split="&split" ;
		column &varlist;
		%do i=1 %to &nobs;
		&&defstr&i
		%end;
	run;
%mend;
