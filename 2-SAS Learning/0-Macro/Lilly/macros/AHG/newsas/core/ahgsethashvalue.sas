%macro AHGsethashvalue(hashid,handle,value);
	%local idx out;
	%let indx=%AHGindex(&&&hashid.list,&handle);
	%let &hashid&indx=&value;
	&out
%mend;
