%macro AHGtime(id,pre=ahuigetimePoint);
%if %AHGblank(&id) %then %let ID=0;
%global &pre&id;
data _null_;
  call symput("&pre&id",put(time(),time8.));
run;
%mend;
