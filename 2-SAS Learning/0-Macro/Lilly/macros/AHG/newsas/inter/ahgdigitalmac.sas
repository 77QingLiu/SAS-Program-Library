%macro AHGdigitalmac(var,digital=,zero=0,times=1000000000);
%local out;
%let out=%sysfunc(floor(%sysevalf(&var*&times)));

%local left right;
%let left=%substr(&out,1,&digital);
%let right=%substr(&out,%eval(&digital+1));
%if %substr(&right,1,1)>=5 %then %let left=%eval(&left+1);
%let right=%sysfunc(translate(&right,000000000,123456789));
%let out=%sysevalf(%sysfunc(compress(&left&right))/&times);

%if %sysfunc(max(&var,1%sysfunc(repeat(0,%eval(&digital-1)))))=&var %then
%do;
%put &var  @@  1%sysfunc(repeat(0,%eval(&digital-1)));
%let out=&var;
%end;
&out

%mend;
