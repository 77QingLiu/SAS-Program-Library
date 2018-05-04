%macro AHGalltochar(dsn,out=%AHGbasename(&dsn),prefix=gha);
%local i info ;
%AHGgettempname(info);
data &info;
	set sashelp.vcolumn(where=(
		%AHGequaltext(libname,"%AHGlibname(&dsn)")
		and  %AHGequaltext(memname,"%AHGbasename(&dsn)")
		and %AHGequaltext(type,'num')
		)
);
%local putcmd renamecmd dropcmd;
data &info;
	format putcmd renamecmd dropcmd $1000. ;
	retain putcmd renamecmd dropcmd ' ';
	set &info end=end;
	putcmd=trim(putcmd)||' '||trim(name)||'='|| "put(" ||"&prefix"||trim(name)||',best8.);';
	renamecmd=trim(renamecmd)||' '||trim(name)||'='|| "&prefix"||trim(name);
	dropcmd=trim(dropcmd)||" &prefix"||trim(name);
	if end then 
	do;
	call symput('putcmd',putcmd);
	call symput('renamecmd',renamecmd);
	call symput('dropcmd',dropcmd);
	end;
run;
%*pm(putcmd renamecmd dropcmd);


data &out(drop=&dropcmd);
	set  &dsn(rename=(&renamecmd));
	%unquote(&putcmd);
run;

%exit:
%mend;




