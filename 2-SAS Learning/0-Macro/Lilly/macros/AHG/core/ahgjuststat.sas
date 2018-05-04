%Macro AHGjuststat(dsn,var,out,by=);

%IF not %AHGblank(&by) %then %AHGdatasort(data =&dsn , out =&dsn , by =&by );
proc means data=&dsn n mean std median max min;
  output out=&out 
n=n mean=mean median=median std=std max=max min=min;
;
  var &var;
  by &by;
run;

%mend;
