%macro AHGindex(full,sub,dlm=%str( ),case=0,lastone=0);
	%local index i;
	%if not &case %then
		%do;
		%let full=%upcase(&full);
		%let sub=%upcase(&sub);
		%end;
	%let  index=0;
	%do i=1 %to %AHGcount(&full,dlm=&dlm);
	%if %scan(&full,&i,&dlm)=&sub %then 
		%do;
		%let index=&i;
		%if not &lastone %then %goto indexExit;
		%end;
	%end;
	%indexExit:
	&index
%mend;
