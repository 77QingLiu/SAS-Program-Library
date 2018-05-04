%macro AHGcopylib(inlib,tolib,n=99999999999);
  %if %AHGblank(&tolib) %then %let tolib=work;
  %local i alldsn onedsn;
  %AHGdsnInLib(lib=&inlib,list=alldsn,lv=1);
  %do i=1 %to %AHGcount(&alldsn)
;
  %let onedsn= %scan(&alldsn,&i,%str( ));
  data &tolib..&onedsn;
    set  &inlib..&onedsn(obs=&n);
  run;
  %end;

%mend;


