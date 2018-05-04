*m204s04;

%macro crdate(dsn);
   %let dsid=%sysfunc(open(&dsn));
   %sysfunc(attrn(&dsid,crdte),datetime.)
   %let dsid=%sysfunc(close(&dsid));
%mend crdate;

%put NOTE: Dataset created %crdate(orion.staff);