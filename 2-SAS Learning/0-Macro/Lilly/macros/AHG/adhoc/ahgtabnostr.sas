%macro AHGtabnoStr(tabnostr=&tabno);
	%sysfunc(translate(&tabnostr,__,.%str( )))
%mend;
