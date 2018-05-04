%macro AHGfindmeta(sas,out=meta,into=meta);
  data &out;
    set sasuser.macmeta(where=(index("&sas",trim(left(drvr)))));
  run;
  proc sql noprint;
    select trim(macros) into :&into separated by ' '
    from &out
    ;
    quit;
%mend;

