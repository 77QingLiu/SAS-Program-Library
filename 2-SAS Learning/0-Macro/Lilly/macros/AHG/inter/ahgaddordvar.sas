%macro AHGaddordvar(var,ordVar);
    %local i;
    if  anydigit(&var) then
    do;
    &ordvar='..'||trim(substr(tranwrd(&var,'.','..'),anydigit(&var)))||'..';
   
    %do i=0 %to 9;
    &ordvar=tranwrd(&ordvar,".&i..",".0&i..");
    %end;
    &ordvar=substr(&var,1,anydigit(&var)-1)||&ordvar;
    end;
%mend;
