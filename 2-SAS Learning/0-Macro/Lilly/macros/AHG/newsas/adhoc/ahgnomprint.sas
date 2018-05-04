%macro AHGnomprint;
%global ahgmprintflag;
%let ahgmprintflag=%AHGincr(ahgmprintflag);   
%put &sysmacroname;
option nomprint;
%mend;
