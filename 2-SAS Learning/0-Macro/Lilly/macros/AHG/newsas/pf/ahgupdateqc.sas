%MACRO AHGUPDATEQC;
  %AHGQCDocEN(TEST,user=&theuser,users=&users,studyname=&prot,version=,
datetime=%sysfunc(date(),date9.) %sysfunc(time(),time8.),status=1,bugids=NOBUG);



  DATA QCLIB.qcdoc;
    set QCLIB.qcdoc;
    where not (missing(filename) or upcase(FILENAME)='TEST');
  run;

  data network.qcdoc;
    set QCLIB.qcdoc;
  run;


%MEND;

