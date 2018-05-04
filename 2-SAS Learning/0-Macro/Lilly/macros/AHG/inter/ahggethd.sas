/*get a temporary dataset with header merged*/
%macro AHGgethd(dsn,lib=dataprot);
proc sort data=&lib..&dsn out=&dsn;
  by subjid;
run;

proc sort data= dataprot.popn out=popn;
  by subjid;
run;
 
data &dsn;
  merge &dsn popn;
  by subjid;
run;
%mend;



  
