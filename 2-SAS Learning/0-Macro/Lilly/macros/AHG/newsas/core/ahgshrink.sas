%macro AHGshrink(dsn,vars,lengths,out=,pre=z487);
%if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
%local i;
data &out;
  format
  %do i=1 %to %AHGcount(&vars);
  %scan(&vars,&i) 
  %scan(&lengths,&i,%str( ))  
  %end;
  ;
  set &dsn
  (
  rename=(
  %do i=1 %to %AHGcount(&vars);
  %scan(&vars,&i)=&pre%scan(&vars,&i)
  %end;
  )
  );
  %do i=1 %to %AHGcount(&vars);
  %scan(&vars,&i)=put(&pre%scan(&vars,&i),%scan(&lengths,&i,%str( )));
  %end;

  drop
  %do i=1 %to %AHGcount(&vars);
   &pre%scan(&vars,&i) 
  %end;
  ;

run;
%mend;
