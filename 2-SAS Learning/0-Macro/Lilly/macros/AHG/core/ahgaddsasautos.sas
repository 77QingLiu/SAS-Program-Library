%macro AHGaddsasautos(dir,clear=0);
%local nowdir;
%let nowdir=%sysfunc(getoption(sasautos));
%if not %index(&dir,%str(%()) %then %let nowdir=(&nowdir);
%if not %index(&dir,%str(%'))  and not %index(&dir,%str(%"))  %then %let dir="&dir";
%let nowdir=&dir %substr(&nowdir,2,%eval(%length(&nowdir)-2));
%if &clear %then option sasautos=(&dir);
%else option sasautos=(&nowdir);
;

proc options option=sasautos;run;
%mend;

