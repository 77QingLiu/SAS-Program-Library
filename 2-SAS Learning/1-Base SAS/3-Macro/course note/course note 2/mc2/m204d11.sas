*m204d11;

%let dsid=%sysfunc(open(orion.customer));
%let rc1=%sysfunc(fetch(&dsid));
%let rc2=%sysfunc(close(&dsid));
%put _user_;

%let dsid=%sysfunc(open(orion.customer));
%syscall set(dsid);	*<=====;
%let rc1=%sysfunc(fetch(&dsid));
%let rc2=%sysfunc(close(&dsid));
%put _user_;

%let dsid=%sysfunc(open(orion.customer
	(keep=customer_ID customer_name gender birth_date)));  *<=====;
%syscall set(dsid);
%let rc1=%sysfunc(fetch(&dsid));
%let rc2=%sysfunc(close(&dsid));
%put _user_;

%let dsid=%sysfunc(open(orion.customer
	(where=(customer_ID=63))));	*<=====;
%let rc1=%sysfunc(fetch(&dsid));
%let rc2=%sysfunc(close(&dsid));
%put _user_;

*fun and games;
%macro cust_info;
	%let dsid=%sysfunc(open(orion.customer
		(keep=customer_ID customer_name gender birth_date)));
	%syscall set(dsid);
	%do i=1 %to 3;
		%let rc1=%sysfunc(fetch(&dsid));
		%put >>>> &customer_ID %trim(&customer_name) &gender &birth_date;
	%end;
	%let rc2=%sysfunc(close(&dsid));
%mend cust_info;

%cust_info