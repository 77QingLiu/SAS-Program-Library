*m204d02;

data _null_;
   myvar='proc print data=sashelp.class; run;';
   call execute(myvar);
run;

data _null_;
   call execute('proc print data=sashelp.class; run;');
run;
