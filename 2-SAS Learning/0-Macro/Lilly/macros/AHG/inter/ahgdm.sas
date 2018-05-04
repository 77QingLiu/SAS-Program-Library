%macro AHGdm(file,from=1 /*2 3*/,dir=);
%if %AHGblank(&dir) %then 
%do;
%if &from=1 %then %let dir=&kanbox\allover;
%if &from=2 %then %let dir=&kanbox\alloverhome;
%end;
dm "inc &dir\&file";
%mend;
