%macro AHGquickcheck;
%AHGkill;
%AHGclearlog;
option ls= 255;
%AHGps(%str( select-string '(erro)|(warning)' *lst),%str(&__snapshot.programs_stat\adam\system_files),out=adam1st);
%AHGps(%str( select-string '(erro)|(warning)' *lst),%str(&__snapshot.programs_stat\sdtm\system_files),out=sdtm1st);
%AHGps(%str( select-string '(erro)|(warning)' *lst),%str(&__snapshot.programs_stat\tfl\system_files),out=tfl1st);

%AHGps(%str( select-string '(erro)|(warning)|(equal)' *lst),%str(&__snapshot.replica_programs\adam\system_files),out=adam2nd);
%AHGps(%str( select-string '(erro)|(warning)|(equal)' *lst),%str(&__snapshot.replica_programs\sdtm\system_files),out=sdtm2nd);
%AHGps(%str( select-string '(erro)|(warning)|(equal)' *lst),%str(&__snapshot.replica_programs\tfl\system_files),out=tfl2nd);

%local outfile;
%let outfile=\\%scan(&__snapshot,1,\)\%scan(&__snapshot,2,\)\%scan(&__snapshot,3,\)\trash\&sysuserid..check.txt;
x "del &outfile /y";

data _null_;
  set adam1st sdtm1st tfl1st adam2nd sdtm2nd tfl2nd;
  file "&outfile";
  put text;
run;

x "start &outfile";




%mend;
