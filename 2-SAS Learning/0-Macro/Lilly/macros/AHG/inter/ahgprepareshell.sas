
%macro AHGprepareshell(file=,out=,length=200);
%if %sysfunc(fileExist(&file)) %then
%do;
data &out;
  filename myfile "&file";
  infile myfile truncover;
  input line $char&length..;
  len=length(line);
  put line $varying. len;

run;
%end;

%mend;
