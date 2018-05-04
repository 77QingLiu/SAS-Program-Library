%macro AHGopenwork(dir=);
	%local workdir;
	%if &dir=t %then %let  dir=%AHGtempdir;
	%if &dir=p %then %let  dir=&projectpath;
  %if %AHGblank(&dir) %then 
  %do;
  data _null_;
    work=getoption('work');
    put work=;
    call symput('workdir',work);
  run;
  %end;
  %else %let workdir=""&dir"";
  option noxwait noxsync;
  x "explorer.exe &workdir";
  option  xsync;
%mend;
