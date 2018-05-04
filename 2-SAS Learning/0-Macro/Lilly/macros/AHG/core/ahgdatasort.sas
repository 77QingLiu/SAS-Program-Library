
%macro AHGdatasort(data = , out = , by = );
  %if %AHGblank(&out) %then %let out=%AHGbarename(&data);
  proc sort 
    %if %length(&data) %then data = &data;
    %if %length(&out) %then out = &out;
  ;
    by &by;


  run;
%mend ;
