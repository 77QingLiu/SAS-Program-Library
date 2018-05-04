%macro AHGropen
            (folder=macros,
             path=&projectpath,
             filename=,
             rpath=&rsubm/&folder ,
             temp=&localtemp\ropen.sas
); 


  data _null_;
  file "&temp";
  put "filename llib    ""&localtemp\"" ; ";

  put "rsubmit;";
  put "filename rlib    ""&rpath/&filename"" ; ";


  put "proc download infile=rlib " ;
  put "            outfile=llib('tmp.sas') ; ";
  put "run ; ";
  put "endrsubmit;";
  run;

  %include "&temp";
  
%mend;
