%macro AHGrtailor
            (dir=,filename=,finalpages=finalpages.rpt
); 
  
  %local temp;
  %let temp=&localtemp\&sysmacroname.temp.sas;
  data _null_;
  file "&temp";
  length com $200;
  put "rsubmit;";
  com="x 'cp -i &dir/&filename ~/temp/&filename        '  ; ";
  put com;
  com="x 'tailorpages.pl --file ~/temp/&filename  --finalpages  ~/temp/&finalpages     '  ; ";
  put com;
  put "endrsubmit;";
  run;

  %include "&temp";
  %AHGrdowntmp(rpath=&userhome/temp,filename=&finalpages,open=1);

%mend;
