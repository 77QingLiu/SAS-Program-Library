%macro AHGDJupDown
            (folder=,
             filename=,
             rpath=&&unix&folder ,
             lpath=&&local&folder,
             cmt=2  ,
             binary=,
             temp=&localtemp\&sysmacroname.temp.sas
); 
  %local comment;
  %if &cmt=2 %then %let comment=update;
  %else %if &cmt=1 %then %let comment=Initial Version;
  %else %let comment=&cmt;

  data _null_;
  file "&temp";
  put "filename locpath ""&lpath"" ; ";
  put "rsubmit;";

  put "x ""chkout &rpath/&filename"" ; ";
  put "x ""  rm -f &rpath/&filename"" ; ";
  

  put "filename rlib    ""&rpath/&filename"" ; ";
  put "proc upload infile=locpath(""&filename"") "  ;
  put "            outfile=rlib &binary; ";
  put "run ; ";
  put "x ""chkin &rpath/&filename &comment"" ; ";

  put "proc download infile=rlib &binary " ;
  put "            outfile=locpath(""&filename"") ; ";
  put "run ; ";
  put "endrsubmit;";
  run;

  %include "&temp";

%mend;
