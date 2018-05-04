*create a macro variable of SSQ ;

%macro AHGSSQ(dsn,var,ssq);/*输出总平方和*/
   data _null_;
   set &dsn (keep=&var) end=end;
      sum+&var**2;
   if end then call symput("&ssq",sum);
   run;
%mend;
