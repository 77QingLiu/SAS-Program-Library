*m204s05;

%macro age(dsn);
   %let dsid=%sysfunc(open(&dsn));
   %if &dsid %then 
      %eval(%sysfunc(today())-
      %sysfunc(datepart(%sysfunc(attrn(&dsid,crdte)))))
   %let dsid=%sysfunc(close(&dsid));
%mend age;

%put NOTE: Dataset is %age(orion.staff) days old.;
