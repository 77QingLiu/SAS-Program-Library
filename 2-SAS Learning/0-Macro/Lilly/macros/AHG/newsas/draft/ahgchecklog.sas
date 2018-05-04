%macro AHGchecklog(log,L12=1,dir=);
%if %AHGblank(&dir) %then 
%do;
%if &L12=1 %then %let dir=&TFL;
%else %let dir=&pgm2\system_files;
%end;
%if not %index(&log,.) %then %let log=&log..log;
%put &dir\&log;
%Local logdsn;
%AHGgettempname(logdsn);
%ahgtolocal(&dir\&log,to=%mysdd(&dir)\,open=1);
%AHGreadline(file=%mysdd(&dir\&log),out=&logdsn);
/*%AHGtime(1);*/
/*%local i*/

data _null_;
  set &logdsn;
  if index(lowcase(line),lowcase('SAS Drug Development Domain dated Thu')) then put line;
  if index(lowcase(line),lowcase('warning')) then put line;
  if index(lowcase(line),lowcase('error')) then put line;

run;

%mend;

%AHGchecklog(ir_smmh111);




