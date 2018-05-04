%macro AHGupdownABC
            (folder=,
             path=&lpath,
             filename=,
             cmt=1  ,
             temp=&localtemp\temp.sas
); 
  %local comment;
  %if &cmt=2 %then %let comment=update;
  %else %if &cmt=1 %then %let comment=Initial Version;
  %else %let comment=&cmt;

  %if &folder=pgm %then %let rpath=&rfsr;
  %if &folder=sys %then %let rpath=&rdata;
  data _null_;
  file "&temp";
  put "filename locpath ""&lpath\&folder"" ; ";
  put "rsubmit;";

  put "x ""chkout &rpath/&filename"" ; ";
  put "x ""  rm -f &rpath/&filename"" ; ";
  

  put "filename rlib    ""&rpath/&filename"" ; ";
  put "proc upload infile=locpath(""&filename"") " ;
  put "            outfile=rlib ; ";
  put "run ; ";
  put "x ""chkin &rpath/&filename &comment"" ; ";

  put "proc download infile=rlib " ;
  put "            outfile=locpath(""&filename"") ; ";
  put "run ; ";
  put "endrsubmit;";
  run;

  %include "&temp";

%mend;
