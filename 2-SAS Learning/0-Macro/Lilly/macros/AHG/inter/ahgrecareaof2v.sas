/*
output the interim variables for calculate SS of two variables
rawXY means the sum of original rectangles' areas
grpXY means the sum of group adjusted rectangles' areas
avgXY means the area of single rectangle

*/
%macro AHGRecAreaOf2V
         (dsn   /*name of dataset*/
          ,varX /*variable X*/
          ,VarY /*variable Y*/
          ,grp  /*variable of group*/
          ,rawXY=  /*macro variable's name for output raw xy*/
          ,grpXy=   /*macro variable's name for output group-adjusted xy*/
          ,avgXy=   /*macro variable's name for output average xy*/
          );
  %local RecArea_A RecArea_B RecArea_C ;
  PROC sql noprint; /*caculate xy's interim var*/
    select sum(&varx*&vary) into :RecArea_A /*macro &rawXY  : sum of single x*y */
    from &dsn
    ;
  %if %length(&rawXY) %then %let &rawXY=&RecArea_A;

  proc sql noprint;
    select sum(RecArea_B) into :RecArea_B  /*macro &grpXY :sum of group-adjusted x*y  */
    from
      (select count(*)*avg(&varX)*avg(&varY) as RecArea_B 
      from &dsn
      group by &grp)
    ;

  %if %length(&grpXY) %then %let &grpXY=&RecArea_B;

  proc sql noprint;
    select count(*)*avg(&VarX)*avg(&VarY) into :RecArea_C /*macro C: sum of squares of (grand average y)*/
    from &dsn
    ;

  %if %length(&avgXY) %then %let &avgXY=&RecArea_C;

%mend  ;
