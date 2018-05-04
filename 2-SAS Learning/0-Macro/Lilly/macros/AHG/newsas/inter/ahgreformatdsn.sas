%macro AHGreformatdsn(dsn,fmts=,out=);
%if %AHGblank(&out) %then %let out=%AHGbasename(&dsn);
%local i info fmtdsn fmtcmd numfmt inputcmd;
%AHGgettempname(info);
%AHGvarinfo(&dsn,out=&info,info=name type length num);

%AHGgettempname(fmtdsn);

data &fmtdsn fmt;
	format mylength $20.;
	%do i=1 %to %AHGcount(&fmts);
	num=&i;
	mylength="%scan(&fmts,&i,%str( ))";
	%if %index(%scan(&fmts,&i,%str( )),\) %then
	%do;
	num=%scan(%scan(&fmts,&i,%str( )),1,\);	;
	mylength="%scan(%scan(&fmts,&i,%str( )),2,\)";
	%end;
    cnt+1;
	if not index(mylength,'.') then mylength=trim(mylength)||'.';
	output;

	%end;
run;



proc sql noprint;
	create table &fmtdsn as
	select num, mylength
	from &fmtdsn
	group by num
	having cnt=max(cnt)
	;
quit;

data &info;
	merge &fmtdsn &info(in=ininfo);
	if ininfo;
	by num;
run;

data &info;
	format  fmtcmd inputcmd numfmt $1000.  mylength myformat $20.;

	retain fmtcmd inputcmd numfmt ' ';
	set &info end=end;
	by num;
	fmt=mylength;
	%AHGfullfmt(fmt,type=%AHGequaltext(type,'N'));
	if not missing(mylength) then
		do;
		
		fmtcmd=%AHGmycat(fmtcmd@' format '@ name @fmt@';');
		if %AHGequaltext(type,'C') then	
			do;
			put '@@@@@' name= mylength=;
			rndfmt=0.1**scan(left(mylength),2,'.');
			if 	scan(mylength,2,'.') ne ' '
				then  inputcmd=%AHGmycat(inputcmd@name@'=put(round('@name@','@rndfmt@"),"@mylength@");");
			end;
		else
			do;
			rndfmt=0.1**scan(left(fmt),2,'.');
			inputcmd=%AHGmycat(inputcmd@name@'=round('@name@','@rndfmt@');');
			
			end;
		end;
	else /*if no explicit definition of fmt then use the original fmt*/
		do;
		if %AHGequaltext(type,'C')  then dollar='$';
		fmtcmd=%AHGmycat(fmtcmd@' length '@ name )||compress(dollar||length||';');
		end;

	if end then
	do;
	call symput('inputcmd',inputcmd);
	call symput('fmtcmd',fmtcmd);
	end;
	put _all_;
run;

data &out;
	&fmtcmd ;
	set  &dsn;
	&inputcmd;
run;
%mend;



