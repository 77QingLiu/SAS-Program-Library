%macro AHGsortnum(mac,into=sortoutmac,dlm=%str( ),nodup=0);

  %local i cnt dsn;

  %AHGgettempname(dsn);

  data &dsn;

  format item $200.;

  %do i=1 %to %AHGcount(&mac,dlm=&dlm);

  item=left("%scan(&mac,&i,&dlm)");
  length=length(compress(item));

  output;

  %end;

  run;

  proc sql noprint;

  select %if &nodup %then distinct; item into :&into separated by "&dlm"

  from &dsn

  order by length,item

  ;quit;

%mend;

