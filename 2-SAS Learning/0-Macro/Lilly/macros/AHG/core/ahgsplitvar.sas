%macro AHGsplitVar(dsn,inVar,toVars,out=,dlm=@,drop=1);
  %if %AHGblank(&out) %then %let out=%AHGbarename(&dsn);
  data &out;
    set &dsn;
    %local i;
    %do i=1 %to %AHGcount(&toVars);
    %scan(&ToVars,&i)=scan(&inVar,&i,"&dlm");
    %end;
    %if &drop %then drop &invar;;
  run; 
                    
%mend;

