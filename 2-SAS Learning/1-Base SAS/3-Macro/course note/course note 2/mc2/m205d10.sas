*m205d10;

%macro findxls(dir) / minoperator;
   %local fileref rc did n memname didc;
   %let rc=%sysfunc(filename(fileref,&dir));
   %let did=%sysfunc(dopen(&fileref));

   %if &did=0 %then %do;
      %put ERROR: Directory %upcase(&dir) does not exist;
      %return;
   %end;
   
   %do n=1 %to %sysfunc(dnum(&did));
      %let memname=%sysfunc(dread(&did,&n));
      %if %upcase(%scan(&memname,-1,.)) in XLS XLSX %then %put &dir\&memname;	
   %end;

   %let didc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(fileref));
%mend findxls;
 
%findxls(&path)
%*findxls(S:\workshop)
