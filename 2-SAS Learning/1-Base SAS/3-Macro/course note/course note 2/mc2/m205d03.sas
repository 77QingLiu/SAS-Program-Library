*m205d03;

filename filelist pipe "dir /b /s  &path\*.csv";
*filename filelist pipe "dir /b /s  S:\workshop\*.csv";

data _null_;
   infile filelist truncover;
   input filename $100.;
   put filename=;
run;
