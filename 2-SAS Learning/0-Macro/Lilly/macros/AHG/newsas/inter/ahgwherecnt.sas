/*select count number into a macro variable by a where clause*/
%macro AHGWhereCnt(dsn,Where,sumVar);
  %global &sumVar;
  proc sql noprint;
    select count(*) into :&sumVar
    from &dsn
    where &where
    ;
  quit;
%mend;
