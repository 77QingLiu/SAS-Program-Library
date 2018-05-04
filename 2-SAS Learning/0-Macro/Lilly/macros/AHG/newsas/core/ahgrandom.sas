%macro AHGrandom;
  %local  rdn ;
  %let rdn=%sysfunc(normal(0));
	%let rdn=%sysfunc(translate(&rdn,00,.-));
  &rdn
  %put random=&rdn;
%mend;
