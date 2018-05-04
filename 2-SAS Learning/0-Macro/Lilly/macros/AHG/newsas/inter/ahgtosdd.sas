%macro AHGtoSDD(from,to,rename=);

%local filename toname;
%let filename=%AHGfilename(&from);


%if %sysfunc(fileexist(&from)) %then  x "copy &from &to\&rename/y";

%mend;
