*m205d06;

%macro findsas(dir);
 
   filename filelist pipe "dir /b /s &dir\*.sas";

   data _null_;
      infile filelist truncover;
      input filename $100.;
      call execute(cats('%include ', quote(trim(filename)), ';'));
   run;

%mend findsas;

%findsas(&path\mysaspgms)
%*findsas(S:\workshop\mysaspgms)
