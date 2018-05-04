%macro AHGhashvalue(hashid,handle);
	%local idx out;
	%let indx=%AHGindex(&&&hashid.list,&handle);
	%let  out=&&&hashid&indx;
	&out
%mend;
