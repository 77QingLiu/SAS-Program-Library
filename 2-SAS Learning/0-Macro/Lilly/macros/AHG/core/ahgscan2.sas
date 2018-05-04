%macro AHGscan2(mac,i,j,dlm=\,dlm2=#);
	%scan(%scan(&mac,&i,&dlm),&j,&dlm2)
%mend;
