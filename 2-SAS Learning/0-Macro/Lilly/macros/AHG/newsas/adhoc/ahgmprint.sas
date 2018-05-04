%macro AHGmprint;
%global ahgmprintflag;
%let ahgmprintflag=%eval(&ahgmprintflag-1);
%if &ahgmprintflag<=0 %then option mprint;;    
%put &sysmacroname;
%mend;
