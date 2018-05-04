%macro AHGbareName(dsn);
	%ahgbasename(%ahgpurename(&dsn))
%mend;
