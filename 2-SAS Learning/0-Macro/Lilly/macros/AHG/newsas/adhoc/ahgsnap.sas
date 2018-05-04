%macro AHGsnap(file,to,into=snapdt,dtfmt=yymmdd10.,tmfmt=time5.);
  %local tofile ext filename;
  %let filename=%AHGfilename(&file);
  %let ext=%scan(&filename,2,.);
  %AHGfiledt(&file,into=&into,dtfmt=&dtfmt,tmfmt=&tmfmt);
  x "copy &file %AHGremoveslash(&to)\&filename..&&&into...&ext";

%mend;

