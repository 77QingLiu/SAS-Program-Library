*create a macro variable of SSQ ;

%macro AHGSSQ(dsn,var,ssq);/*�����ƽ����*/
   data _null_;
   set &dsn (keep=&var) end=end;
      sum+&var**2;
   if end then call symput("&ssq",sum);
   run;
%mend;
