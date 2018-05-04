*m205d09;

%let rc=%sysfunc(filename(fileref,&path\subfolder));
%*let rc=%sysfunc(filename(fileref,S:\workshop\subfolder));

%let did=%sysfunc(dopen(&fileref));
%let count=%sysfunc(dnum(&did));

%put &=fileref &=did &=count memname=%sysfunc(dread(&did,&count));

%let didc=%sysfunc(dclose(&did));
%let rc=%sysfunc(filename(fileref));
