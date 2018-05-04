*m205s02;

filename filelist pipe "dir /b /s &path\m204s0*.sas";
*filename filelist pipe "dir /b /s S:\workshop\m204s0*.sas";

data _null_;
   infile filelist truncover;
   input filename $100.;
   if '3'<=substr(filename,19,1)<='5';
   call execute(cats('%include ', quote(trim(filename)), ';'));
run;
