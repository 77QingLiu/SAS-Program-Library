%macro AHGcypher(var,tovar,mod=0);
%local i;
%let i=%AHGrdm;
&tovar=&var;
do &i=1 to Length(&var);
/*if mod(rank(substr(&var,&i,1)),2)=&mod then*/
if (65<=rank(substr(&var,&i,1))<=90) then substr(&tovar,&i,1)=byte(155-rank(substr(&var,&i,1)));
else if (48<=rank(substr(&var,&i,1))<=57) then substr(&tovar,&i,1)=byte(105-rank(substr(&var,&i,1)));
else if (97<=rank(substr(&var,&i,1))<=122) then substr(&tovar,&i,1)=byte(219-rank(substr(&var,&i,1)));
end;
%mend;
