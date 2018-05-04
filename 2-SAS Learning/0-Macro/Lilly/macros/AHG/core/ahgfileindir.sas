%macro AHGfileInDir(dir,ext=sas7bdat,into=,dlm=%str( ));
filename AHGtmpdr "&dir";
%local ID i count name;
%let id=%sysfunc(dopen(AHGtmpdr));
%let count=%sysfunc(dnum(&id));

%do i=1 %to &count;
%let name=%sysfunc(dread(&id,&i));
%if %index(%upcase(&name),%upcase(&ext)) %then 
%do;
%if %AHGblank(&&&into) %then %let &into=&name;
%else %let &into=&&&into&dlm&name;
%end;

%end;
%mend;




