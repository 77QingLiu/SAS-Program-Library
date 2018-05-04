%macro AHGmyput(var,fmt);
%local digital roundto;
%let digital=%scan(&fmt,2,.);
%let roundto=%substr(0.00000000000000,1,%eval(&digital+1))1; 
put(round(&var,&roundto),&fmt)
%mend;
