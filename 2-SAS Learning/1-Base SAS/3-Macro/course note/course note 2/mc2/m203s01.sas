*m203s01;

%macro company(co);
	%if &co=SAS %then %put SAS Institute;
	%else %if &co=%str(GE) %then %put General Electric;
	%else %put Whatever;
%mend company;

%company(SAS)
%company(%str(GE))
%company(IBM)
