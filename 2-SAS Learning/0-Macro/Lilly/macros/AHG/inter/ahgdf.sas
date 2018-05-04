%macro AHGdf(indset,gname,vout);
   proc sql noprint;
    select count(*)-1 into :&vout
    from (
            select distinct &gname as c
            from &indset
            group by &gname
         )
    ;
  quit;
%mend;
