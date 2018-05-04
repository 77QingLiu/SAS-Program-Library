%macro AHGrdm(length,seed=0);
%local i rdn;
%if %AHGblank(&length) %then %let length=5;
%do i=1 %to &length;
  %let rdn=&rdn%sysfunc(byte(%sysevalf(65+%substr(%sysevalf(%sysfunc(ranuni(&seed))*24),1,2))) ); 
%end;
&rdn
%mend;
