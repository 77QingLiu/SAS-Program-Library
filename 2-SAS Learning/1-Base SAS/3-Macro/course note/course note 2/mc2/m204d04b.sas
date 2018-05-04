*m204d04b;

%macro numobs(dsn);
   %let dsid=%sysfunc(open(&dsn));
   %sysfunc(attrn(&dsid,nlobs))
   %let rc=%sysfunc(close(&dsid));
%mend numobs;
