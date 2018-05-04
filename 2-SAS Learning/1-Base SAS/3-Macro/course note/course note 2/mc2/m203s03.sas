*m203s03;

%macro company(co);
   %if %superq(co)=SAS %then %put SAS Institute;
   %else %if %superq(co)=%str(GE) %then %put General Electric;
   %else %if %superq(co)=%str(H-P) %then %put Hewlett-Packard;
   %else %put Whatever;
%mend company;

%company(SAS)
%company(GE)
%company(H-P)
%company(IBM)
