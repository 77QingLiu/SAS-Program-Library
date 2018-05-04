*m204d04a;

%macro numobs(dsn);
   %let dsid=%sysfunc(open(&dsn));
   %let nobs=%sysfunc(attrn(&dsid,nlobs));
   %let rc=%sysfunc(close(&dsid));
   %put &=nobs;
%mend numobs;

%numobs(orion.order_fact)
