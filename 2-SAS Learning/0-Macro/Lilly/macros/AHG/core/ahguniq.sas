%MACRO AHGuniq(mac,into);
%local i uniq;
%AHGgettempname(uniq);
data &uniq;
  format word $100.;
  %do i=1 %to %AHGcount(&mac);
  word="%lowcase(%scan(&mac,&i))";
  i=&i;
  output;
  %end;
run;


%AHGdatasort(data = &uniq, out = , by =word );

data &uniq;
  set &uniq;
  format ord $3.;
  retain ord;
  by word;
  if first.word then ord='1';
  else ord=%AHGputn(input(ord,best.)+1);
run;

%AHGdatasort(data = &uniq, out = , by =i);

data &uniq;
  set &uniq;
  if ord ne '1' then word=compress(word||'_'||ord);
run;

proc sql noprint;
  select trim(word) into :&into separated by ' '
  from &uniq
  ;
  quit;

%mend;
