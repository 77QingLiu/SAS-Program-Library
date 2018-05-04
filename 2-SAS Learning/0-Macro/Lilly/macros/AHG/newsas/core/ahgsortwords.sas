%macro AHGsortWords(words,into=,dlm=%str( ),length=100,nodup=1);
  %local i sortdsn;
  %AHGgettempname(sortdsn);
  option nomprint;
  data &sortdsn;
    length word $&length.;
    %do i=1 %to %AHGcount(&words,dlm=&dlm);
    word=scan("&words",&i,"&dlm");
    output;
    %end;
  run;

  proc sql noprint;
  select %if &nodup %then distinct; trim(word) as word into :&into separated by "&dlm"
  from &sortdsn
  order by word
  ;
  quit;

  %AHGdatadelete(data=&sortdsn);
  option mprint;

%mend;


