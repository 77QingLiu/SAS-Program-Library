%macro AHG2arr(prefix);
  data _null_;
    infile datalines truncover;
    format line $1000.;
    input line 1-1000;
    call symput(compress("&prefix"||put(_n_,best.)),line);
%mend;
