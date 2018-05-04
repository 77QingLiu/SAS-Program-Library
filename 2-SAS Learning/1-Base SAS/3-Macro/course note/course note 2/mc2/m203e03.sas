*m203e03;

%macro company(co);
	%if &co=SAS %then %put SAS Institute;
	%else %if &co=GE %then %put General Electric;
	%else %if &co=H-P %then %put Hewlett-Packard;
	%else %put Whatever;
%mend company;

%company(SAS)
%company(GE)
%company(H-P)
%company(IBM)
