%macro DefaultFormat(vars);
  %local count i temp ;
  format 
  %do i=1 %to %AHGcount(&vars);
    %let temp=att_format_%scan(&vars,&i);
    %if %symexist(&temp) %then %scan(&vars,&i)  &&&temp ;
   
  %end;
  ;
%mend;
