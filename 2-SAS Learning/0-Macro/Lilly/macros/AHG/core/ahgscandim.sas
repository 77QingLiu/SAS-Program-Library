%macro AHGscanDim(str,dimNum,by=2,dlm=%str( ));
	%scan(&str,%eval(( &dimNum-1)*&by +1)) %scan(&str,%eval(( &dimNum-1)*&by +2)) %scan(&str,%eval(( &dimNum-1)*&by +3))
%mend;
