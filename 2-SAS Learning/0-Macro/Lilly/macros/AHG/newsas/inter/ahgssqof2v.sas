/*
output the total SS and Between SS and within SS of two variables
SS means SUM of squares. sum(x-xbar);
*/
%macro AHGSSQof2V
          (dsn   /*name of dataset*/
          ,varX /*variable X*/
          ,VarY /*variable Y*/
          ,grp  /*variable of group*/
          ,SST=  /*macro variable's name for output raw xy*/
          ,SSB=   /*macro variable's name for output group-adjusted xy*/
          ,SSW=   /*macro variable's name for output average xy*/
          );
  %local SSQ_A SSQ_B SSQ_C ;
  %AHGRecAreaOf2V(&dsn,&varx,&vary,&grp,rawXY=SSQ_A,grpXY=SSQ_B,avgXY=SSQ_C);

  %if %length(&SST) %then %let &SST=%EVAL(&SSQ_A-&SSQ_C);
  %if %length(&SSB) %then %let &SSB=%EVAL(&SSQ_B-&SSQ_C);
  %if %length(&SSW) %then %let &SSW=%EVAL(&&&SST-&&&SSB);
%mend  ;



