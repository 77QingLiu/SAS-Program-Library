%macro AHGalign(allvar);
  %local var i;
  %do i=1 %to %AHGcount(&allvar);
  %let var=%scan(&allvar,&i);
  &var=PRXCHANGE('s/\s*(\d+)\s*\((\S*)\s*\)/\1 (\2)/',-1,&var);
  &var=PRXCHANGE('s/(\b\d\b)/  \1/',-1,&var);
  &var=PRXCHANGE('s/(\b\d\d\b)/ \1/',-1,&var);
  &var=PRXCHANGE('s/(\.\s*)/./',-1,&var);
  %end;
%mend;
