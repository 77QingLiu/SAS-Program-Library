*m204s03;

%macro nvars(dsn);
   %let dsid=%sysfunc(open(&dsn));
   %sysfunc(attrn(&dsid,nvars))
   %let dsid=%sysfunc(close(&dsid));
%mend nvars;

%put NOTE: %nvars(orion.staff) variables in dataset;
