*get a macro for by group ssq;
%macro AHGarea_grp(indset,vname,gname,vout);/*�������ƽ����*/
  proc sql noprint;
    select sum(sums/c) into :&vout
    from (
            select sum(&vname)**2 as sums,count(*) as c
            from &indset
            group by &gname
         )
    ;
  quit;
%mend;
