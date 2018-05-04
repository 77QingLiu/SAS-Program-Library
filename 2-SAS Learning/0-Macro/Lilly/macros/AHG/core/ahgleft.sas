%macro AHGleft(arrname,mac,dlm=%str( ),global=0);
  %let &arrname=%sysfunc(left(%str(&&&arrname)));

  %local i count localmac;
  %let count=%AHGcount(&&&arrname,dlm=&dlm);
  %if &count<=1 %then 
    %do;
    %let localmac=&&&arrname;
    %let  &arrname=;
    %end;
  %else
    %do;
    %let localmac=%scan(&&&arrname,1,&dlm);
    %let &arrname=%substr(&&&arrname,%index(&&&arrname,&dlm)+1);
    %end;
  %if &global %then %global &mac;   
  %if %AHGblank(&mac) %then &localmac;
  %else %let &mac=&localmac;
%mend;
