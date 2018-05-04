%macro AHGcatchall(dsn,ALLvalue,DLM=@,out=,strict=1,open=1);
%LOCAL n i hash;
%let hash=%AHGrdm(10)_;
%do i=1 %to %AHGcount(%bquote(&allvalue),dlm=&dlm);
  %AHGcatch(&dsn,%scan(%bquote(&allvalue),&i,&dlm),out=&hash.&i,strict=1,open=0);  
%end;

data big&hash;
  set &hash:;
run;

proc sql noprint;
  create table all&hash as
  select distinct *
  from big&hash
  ;quit;

%if &open %then %AHGopendsn(all&hash);

%mend;
