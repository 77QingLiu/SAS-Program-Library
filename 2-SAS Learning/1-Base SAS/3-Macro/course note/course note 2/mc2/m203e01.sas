*m203e01;

%macro company(co);
   %if &co=SAS %then %put SAS Institute;
   %else %if &co=GE %then %put General Electric;
   %else %put Whatever;
%mend company;

%company(SAS)
%company(GE)
%company(IBM)
