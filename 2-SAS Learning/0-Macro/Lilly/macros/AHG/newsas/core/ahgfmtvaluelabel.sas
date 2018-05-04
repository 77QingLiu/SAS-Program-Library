%macro AHGfmtValueLabel(fmt,ValueMac, LabelMac,dlm=@,out=);
%if %AHGblank(&out) %then %let out=&fmt.fmt;
proc format CNTLOUT=&out(where=(fmtname=upcase("&fmt")) keep=fmtname start label);
run;


proc sql noprint;
  select start,Label into :&valueMac  separated by "&dlm", :&labelMac separated by "&dlm"
  from &out
  order by start
  ;

quit;
%mend;

