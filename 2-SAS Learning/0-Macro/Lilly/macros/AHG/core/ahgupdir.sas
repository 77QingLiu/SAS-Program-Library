%macro AHGupdir(dir,n=1,dlm=\);%local i;
%do i=1 %to &n;
%let dir=%sysfunc(reverse(%substr(%sysfunc(reverse(&dir)),%eval(%index(%sysfunc(reverse(&dir)),&dlm)+1))));
%end;&dir
%mend;

