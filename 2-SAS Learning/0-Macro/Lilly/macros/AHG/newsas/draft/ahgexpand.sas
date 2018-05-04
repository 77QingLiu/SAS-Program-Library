%macro AHGexpand;
filename ahgclip clear;
filename ahgclip clipbrd;
%local clip dsn;
data _null_;
  infile ahgclip;
  format clip    $500.;
  input clip;
  call symput('clip',strip(clip));   
run;

%AHGgettempname(dsn);
data &dsn;
  set sasuser.actions;
  where prxmatch("/&clip/i",action);
run;

%AHGvar2arr(&dsn,action,ahgactionArr);

%mend;
