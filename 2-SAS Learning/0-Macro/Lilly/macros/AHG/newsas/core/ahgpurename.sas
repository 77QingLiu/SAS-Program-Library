%macro AHGpureName(dsn);
	%if %index(&dsn,%str(%()) %then %scan(&dsn,1,%str(%());
	%else &dsn;
%mend;
