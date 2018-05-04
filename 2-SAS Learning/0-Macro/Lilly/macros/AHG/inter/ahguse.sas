%macro AHGuse(ALLdsn);
  %local lib onedsn i barename;
  %do i=1 %to %AHGcount(&alldsn);
    %let onedsn=%scan(&alldsn,&i,%str( ));
    %let lib=%scan(&onedsn,1);
    %let barename=%scan(&onedsn,2);
    %AHGpm(lib barename);
    %if not %sysfunc(exist(l&lib..&barename)) %then 
    %do;
     data l&lib..&barename;
      set r&lib..&barename;
     run;
    %end;
  %end;
%mend;
