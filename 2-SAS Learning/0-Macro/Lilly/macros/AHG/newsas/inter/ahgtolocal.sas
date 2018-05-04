%macro AHGtoLocal(from,to=,open=0,where=);

%if %AHGblank(&to) %then %let to=%AHGtempdir;
%if not %sysfunc(fileexist(&to)) %then %AHGmkdir(&to);
%local filename;
%let filename=%AHGfilename(&from);
option xsync;
systask command "copy &from &to  /y" wait;
 
%if &open=1 %then %AHGopenfile(&to\&filename,&where);



%mend;
