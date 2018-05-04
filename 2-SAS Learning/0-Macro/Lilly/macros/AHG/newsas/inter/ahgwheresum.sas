/*select sum into a macro variable by a where clause. test ahuige*/
%macro AHGwheresum(dsn,value,Where,sumVar);
  proc sql noprint;
    select sum(&value) into :&sumVar
    from &dsn
    where &where
    ;
  quit;
%mend;
