%macro AHGlibname(dsn);
	%if %index(&dsn,.) %then %scan(&dsn,1,.);
	%else work;
%mend;
