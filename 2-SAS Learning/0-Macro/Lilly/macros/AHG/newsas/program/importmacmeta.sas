data sasuser.macmeta;
  filename thein 'C:\Users\C187781\Downloads\mac.meta' ;
  infile  thein dsd delimiter='^';
  format drvr $30. macros $500.;
  input drvr macros;
  if drvr=:'ahg';
run;

%AHGopendsn();
