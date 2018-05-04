%macro AHGaddline(dsn,lines=%str(),position=0);
%local struct line;
%AHGgettempname(struct);
%AHGgettempname(line);
data &struct;
	set &dsn;
	if 0;
run;

data &line;
	%unquote(&lines);
run;

data &line;
	set &struct &line;
run;

data &dsn;
	set 
	%if &position=0 %then &line &dsn;
	%else &dsn &line ;
	;
run;

%AHGdatadelete(data=&struct);
%AHGdatadelete(data=&line);

%mend;
