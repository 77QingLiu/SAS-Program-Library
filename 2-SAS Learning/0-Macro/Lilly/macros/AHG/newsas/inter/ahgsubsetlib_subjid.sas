%macro AHGsubsetlib_subjid(inlib=,outlib=,wstr=10011001,wherevar=subjid pt pid enrlid);
%local i j dsnlist dsnlistraw datalist varlist;
%AHGdsnInLib(lib=&inlib,list=dsnlistraw);
%if %AHGblank(&wherevar) %then  %let dsnlist=&dsnlistraw;
%else
%do;
		%do i=1 %to %AHGcount(&dsnlistraw);
		%AHGvarlist(%scan(&dsnlistraw,&i,%str( )),Into=varlist,dlm=%str( ),global=0);
		%local ifstr;
		%let ifstr=0 ;
		%do  j=1 %to  %AHGcount(&wherevar);
			%let ifstr=&ifstr or	%sysfunc(indexw(%upcase(&varlist),%upcase(%scan(&wherevar,&j)))) ;
		%end;
		%if   &ifstr %then  %let dsnlist=&dsnlist  %scan(&dsnlistraw,&i,%str( )); 
		%end;

%end;

%let datalist=%sysfunc(tranwrd(&dsnlist,&inlib..,&outlib..));
%AHGpm(dsnlist datalist);

%macro AHGsubsetlibdoit;
	%local i j;
	%do i=1 %to %AHGcount(&dsnlist);
		data %scan(&datalist,&i,%str( ));
			format &wherevar $10.;
			set %scan(&dsnlist,&i,%str( )) ;
			label subjid='subjid' pt='pt' pid='pid';
			if 0
			%do  j=1 %to  %AHGcount(&wherevar);
			or 
			not missing(%scan(&wherevar,&j)) and
			 upcase(%scan(&wherevar,&j))  %upcase(&wstr)   
			%end;
			;
			
		run;
	%end;
%mend;
%AHGsubsetlibdoit;


%mend;


