%macro AHGselectvar(dsn,keep=name label);
%local out;
%AHGgettempname(out);
proc contents data=&dsn out=&out(keep= &keep);
run;

data &out; 
  ord=0;
  set &out;

run;

%AHGopendsn();
/*proc sql;*/
/*  select **/
/*  from _last_*/
/*  where ord>0*/
/*  order by ord*/
/*  ;quit;*/

%mend;

