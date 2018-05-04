%macro AHGanySlash(dir,toSlash,compress=1);    
%local fromslash;
%if %AHGblank(&toslash) %then 
%do;
%if %index(&dir,/) %then %do;%let fromSlash=%str(/); %let toSlash=\; %end;
%if %index(&dir,\) %then %do;%let fromSlash=\; %let toSlash=%str(/); %end;

%end;


%if &toSlash=\ %then %let fromSlash=%str(/);
%else %let fromSlash=%str(\);
%if not &compress %then %sysfunc(tranwrd(&dir,&fromSlash,&toSlash));
%else %sysfunc(compress(%sysfunc(tranwrd(&dir,&fromSlash,&toSlash))));

%mend;

