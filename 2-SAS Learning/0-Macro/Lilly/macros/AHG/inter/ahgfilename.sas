%macro AHGfilename(file);
  %local filename i;
  %let filename=%scan(&file,%AHGcount(&file,dlm=/),/);
  %let filename=%scan(&filename,%AHGcount(&filename,dlm=\),\);
  &filename
%mend;
