%macro AHGmacAndvalue(pairs,global=1,dlm=%str( ),dlm2=|);
%local one i;
%do i=1 %to %AHGcount(&pairs,dlm=&dlm);
  %let one=%scan(&pairs,&i,&dlm);
  %if &global %then %global %scan(&one,1,&dlm2);;
  %let %scan(&one,1,&dlm2)=%scan(&one,2,&dlm2);
%end;
%mend;
