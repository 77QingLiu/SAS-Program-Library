%macro AHGDJrdown
            (folder=,
             filename=,
             rpath=&&unix&folder ,
             locpath=&&local&folder,
             cmt=2  ,
             binary=,
             temp=&localtemp\&sysmacroname.temp.sas
); 
 
  /*if rpath is not set explicitly then decide rpath by rlevel*/

  %put &rpath;
  data _null_;
  
  file "&temp";
  put "filename locpath ""&locpath"" ; ";
  put "rsubmit;";

  put "filename rlib   ""&rpath/&filename"" ; ";

  put "proc download infile=rlib &binary  " ;
  put "            outfile=locpath(""&filename"") ; ";
  put "run ; ";
  put "endrsubmit;";
  run;

  %put _user_;
  %include "&temp";


%mend;
