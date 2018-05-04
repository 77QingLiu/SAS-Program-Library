%macro AHGexclude(str,rmstr,dlm=%str( ));
%local i;
%do i=1 %to %AHGcount( &str,dlm= &dlm);
	%if not %sysfunc(indexw( &rmstr, %scan( &str,&i, &dlm), &dlm )  )
	%then %scan( &str,&i, &dlm);

%end;

%mend;
