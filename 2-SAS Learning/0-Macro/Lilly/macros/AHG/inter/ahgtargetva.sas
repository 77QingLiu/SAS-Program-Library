%macro AHGtargetva(vaname);
	%global qcvadsn &vaname;
	%if %index(&qcvadsn,&vaname) %then
	%do;
	%put @@@@@@@@@@@@double programming VA is used;
	%va_&vaname;
	%end;
	%else
	%do;
	%put @@@@@@@@@@@@CDARS VA is used;
	data va_&vaname;
		set datvprot.&vaname;
	run;

	%end;
	
%mend;
