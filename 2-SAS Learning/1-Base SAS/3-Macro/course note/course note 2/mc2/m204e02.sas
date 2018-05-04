*m204e02;

%macro contents(data=&syslast);
   proc contents data=&data; 
      title "&data"; 
   run;
%mend contents;

%contents(data=orion.staff)
