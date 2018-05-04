*m204s01;

data _null_;
   if weekday(today())=6 
      then call execute('proc means data=orion.orders; run;');
      else call execute('proc print data=orion.orders(obs=10); run;');
run;
