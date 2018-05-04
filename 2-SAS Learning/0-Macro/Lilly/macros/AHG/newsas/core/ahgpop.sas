%macro AHGpop(arrname,mac,dlm=%str( ),global=0);
  %if &global %then %global &mac;
  %local stack;
  %let stack=%sysfunc(reverse(%str(&&&arrname)));
  %AHGleft(stack,&mac,dlm=&dlm);
  %let  &arrname=%sysfunc(reverse(%str(&stack)));
  %let  &Mac=%sysfunc(reverse(%str(&&&Mac)));


%mend;

