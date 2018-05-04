*m205d13;

%macro importdriver(type=,dir=.);

   %local rc did didc;
   
   %let rc=%sysfunc(filename(fileref,&dir));
   %let did=%sysfunc(dopen(&fileref));
   %let didc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(fileref));

   %if &did=0 %then %do;
      %put ERROR: Directory %upcase(&dir) does not exist.;
      %return;
   %end;

   %let type=%upcase(&type);

   %if       &type=CSV %then %findcsv(&dir);
   %else %if &type=XLS %then %findxls(&dir);

   %else %do;
      %put ERROR: Valid Types are: CSV, XLS.;
      %put ERROR- XLS includes XLS and XLSX.;
    %end;

%mend importdriver;

%importdriver(type=xls, dir=&path)
%*importdriver(type=xls, dir=S:\workshop)
