%macro AHGdigital(dsn,var,outvar,digital=,zero=0);
%local rand;
%let rand=sfdjskaf43534;
data &dsn;
	set  &dsn;
	drop  orivar&rand  outorivar&rand   i&rand digitalnum&rand;
    orivar&rand=put(&var,20.10);
	format outorivar&rand  $20.;
	do i&rand=1 to 20 ;
    outorivar&rand=compress(outorivar&rand||substr(orivar&rand,i&rand,1));
	if 	digitalnum&rand>0 and substr(orivar&rand,i&rand,1) in ('1' '2' '3' '4' '5' '6' '7' '8' '9' '0') then digitalnum&rand=digitalnum&rand+1;
	
	if 	digitalnum&rand<1 and substr(orivar&rand,i&rand,1) in ('1' '2' '3' '4' '5' '6' '7' '8' '9') then digitalnum&rand=1;/*start to count*/
	

	if 	digitalnum&rand=&digital then leave;
	end;
	&outvar=outorivar&rand;
	if &var=0 then &outvar="&zero";
run;	
%mend;
