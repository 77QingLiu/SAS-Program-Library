%macro AHGprintToLog(dsn,n=20);
proc printto print="%AHGtempdir\log.txt" new;

proc print data=&dsn(obs=&n);
run;

proc printto;run;

data _null_;
  infile "%AHGtempdir\log.txt" truncover;
  format line $200.;
  input line     1-200;
  put line;
run;

%mend;

