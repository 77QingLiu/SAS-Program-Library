%macro AHGstudyday(dt1,dt2);
data _null_;
	fromdate="&dt1"d;
	todate="&dt2"d;
	studyday=todate-fromdate+1;
	put  fromdate= todate= studyday=;
run;
%mend;
