%macro AHGreadline(file=,out=readlineout);
data &out;
  filename inf   "&file" ;
  infile inf truncover;;
  format  line $800.;
  input line 1-800 ;
run;
%mend;
