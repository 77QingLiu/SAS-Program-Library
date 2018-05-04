%macro AHGwt(file,str=%str());
data _null_;
  file "&file";
  put "&str";
run;
%mend;


