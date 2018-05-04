%macro AHGprt(dsn=_last_,label=label);
proc print data=&dsn noobs &label;run;
%mend;
