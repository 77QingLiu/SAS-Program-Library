%macro AHGgetgsun81pw(id,pw);
%if %sysfunc(exist(sasuser.gsun81)) %then
%do;
data _null_;
    set sasuser.gsun81(pw=hcEE3B32);
    call symput("&id",userid);
    call symput("&pw",password);
run;  
%end;
%mend;
