%macro AHGsubsetlib(inlib=,outlib=,wstr=,wherevar=);
%local i dsnlist dsnlistraw datalist varlist;
%AHGdsnInLib(lib=&inlib,list=dsnlistraw);
%if %AHGblank(&wherevar) %then  %let dsnlist=&dsnlistraw;
%else
%do i=1 %to %AHGcount(&dsnlistraw);
%AHGvarlist(%scan(&dsnlistraw,&i,%str( )),Into=varlist,dlm=%str( ),global=0);
%if  %sysfunc(indexw(%upcase(&varlist),%upcase(&wherevar))) %then  %let dsnlist=&dsnlist  %scan(&dsnlistraw,&i,%str( ));
%end;

%let datalist=%sysfunc(tranwrd(&dsnlist,&inlib..,&outlib..));
%AHGpm(dsnlist datalist);

%macro AHGsubsetlibdoit;
	%local i;
	%do i=1 %to %AHGcount(&dsnlist);
		data %scan(&datalist,&i,%str( ));
			set %scan(&dsnlist,&i,%str( ))&wstr;
		run;
	%end;
%mend;
%AHGsubsetlibdoit;
%mend;

