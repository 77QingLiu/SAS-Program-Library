*m204d01a;

%macro print(data=&syslast,obs=5);
   proc print data=&data(obs=&obs); 
      title "&data"; 
   run;
%mend print;

%print(data=orion.country)
