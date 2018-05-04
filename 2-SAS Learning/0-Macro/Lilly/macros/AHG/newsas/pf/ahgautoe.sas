%macro AHGautoe(ver);
  %local file;
  %let file="&autodir\autoexec&ver..sas";
  %put &file;
  %include &file;
%mend;

 
