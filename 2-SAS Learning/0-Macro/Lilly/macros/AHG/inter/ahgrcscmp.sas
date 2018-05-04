%macro AHGRCScmp(
             folder=macros,
             filename=,
             path=&projectpath,
             rpath=&userhome/temp ,
             v1=1.1,
             v2=1.1,
             studyname=,
             sys=0,
             log=0,
             rlevel=3,
             extract=0,
             temp=&localtemp\temprcs.sas);

    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 

  data _null_;
  file "&temp";
  put "rsubmit;";

  %local fld;
  %let fld=&folder;
  %if &extract=1 %then %let fld=macros;
  %if &sys=1 %then put " x "" co -p /Volumes/app/saseng/prod/pds1_0/&fld/&filename  > ~/temp/rcs1.sas"" ; ";
  %else put " x "" co -p&v1 &&root&rlevel/&folder/&filename  > ~/temp/rcs1.sas"" ; ";   ;
  put " x "" co -p&v2 &&root&rlevel/&folder/&filename  > ~/temp/rcs2.sas"" ; ";

  put "endrsubmit;";
  run;

  %include "&temp";  
  
  %AHGrdown(folder=&folder, filename=rcs1.sas, rpath=&rpath,locpath="&localtemp",save=0);
  %AHGrdown(folder=&folder, filename=rcs2.sas, rpath=&rpath,locpath="&localtemp",save=0);
  x "&localtemp\rcs1.sas";
  x "&localtemp\rcs2.sas";
  
  %if &log=1 %then %AHGQCDoc(&filename,studyname=&studyname,datetime=%sysfunc(date(),date9.) %sysfunc(time(),time8.),version=&v2);
%mend;
