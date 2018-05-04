%macro AHGrdowncleanlog(log);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 

  %AHGsubmitrcommand(cmd=%str(cleanlog -f &log ));
  %AHGrdowntmp(rpath=&userhome/temp,filename=temp.log);
  x "&localtemp\temp.log";
%mend;
