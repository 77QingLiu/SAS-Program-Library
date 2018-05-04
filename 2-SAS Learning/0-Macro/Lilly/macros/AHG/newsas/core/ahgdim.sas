%macro AHGdim(str,by=2,dlm=%str( ));
	%sysfunc(ceil(%sysevalf(%AHGcount(&str)/&by )))
%mend;
