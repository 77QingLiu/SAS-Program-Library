%macro ahgarr(id,dlm,Arr=ahgarr);
	%if %AHGblank(&dlm) %then %let dlm=@;
	%scan(&&&Arr,&id, &dlm)
%mend;
