%macro AHGdataset(data = , out = , by = , condition = );
	%if %AHGblank(&out) %then %let out=%AHGbasename(&data);

  data &out;
    set &data;
    %if %length(&by) %then %do; by &by; %end;
    &condition;
  run;
%mend  ;
