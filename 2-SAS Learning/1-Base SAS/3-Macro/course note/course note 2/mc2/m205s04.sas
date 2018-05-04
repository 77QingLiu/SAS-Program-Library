*m205s04;

%macro findmdb(dir) / minoperator;
   %local fileref rc did n memname didc;
   %let rc=%sysfunc(filename(fileref,&dir));
   %let did=%sysfunc(dopen(&fileref));
   %if &did=0 %then %do;
      %put ERROR: Directory %upcase(&dir) does not exist.;
      %return;
   %end;
   %do n=1 %to %sysfunc(dnum(&did));
      %let memname=%qsysfunc(dread(&did,&n));
      %if %upcase(%scan(&memname,-1,.)) in MDB ACCDB 
         %then %importmdb(&dir\&memname);
      %else %if %scan(&memname,2,.\)=  
         %then %findmdb(&dir\&memname);
   %end;
   %let didc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(fileref));
%mend findmdb;

%findmdb(&path)
%*findmdb(S:\workshop)
