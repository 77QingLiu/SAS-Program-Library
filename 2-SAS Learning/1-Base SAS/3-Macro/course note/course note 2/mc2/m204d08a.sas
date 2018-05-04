*m204d08a;

%macro wherobs(dsn,mywhere);
   %let dsid=%sysfunc(open(&dsn(where=(&mywhere))));
   %sysfunc(attrn(&dsid,nlobsf))
   %let rc=%sysfunc(close(&dsid));
%mend wherobs;

%put **** %wherobs(orion.order_fact, %str(order_type=3)) ****;
