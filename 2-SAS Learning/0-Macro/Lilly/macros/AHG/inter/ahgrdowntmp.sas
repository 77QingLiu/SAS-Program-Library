%macro AHGrdowntmp
            (
             filename=,
             rpath=&rsubm/&folder ,
             temp=&localtemp\&sysmacroname.sas,
			 binary=,
			 open=0
); 


  data _null_;
  
  file "&temp";
  put "rsubmit;";

  put "filename rlib   ""&rpath/&filename"" ; ";

  put "proc download infile=rlib &binary  " ;
  put "            outfile=""&localtemp\&filename"" ; ";
  put "run ; ";
  put "endrsubmit;";
  run;

  %include "&temp";
  
  %if &open %then x "&localtemp\&filename";

%mend;
