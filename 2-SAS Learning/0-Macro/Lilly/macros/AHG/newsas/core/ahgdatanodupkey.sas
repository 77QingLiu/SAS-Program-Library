

%macro AHGdatanodupkey(data = , out = , by = );
	%if %AHGblank(&out) %then %let out=%AHGbasename(&data);

  proc sort data = &data out = &out nodupkey;
    by &by;
  run;
%mend ;
