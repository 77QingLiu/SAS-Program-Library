%macro AHGfillshell(dsn,out=%AHGbasename(&dsn),width=);
%local i j nobs varlist;
%AHGnobs(&dsn,into=nobs);
%let varlist=;
%AHGvarlist(&dsn,Into=varlist,dlm=%str( ),global=0);
%do i=1 %to %AHGcount(&varlist);
%local %AHGwords(%scan(&varlist,&i),&nobs);
%end;

%local i %AHGwords(line,&nobs);
data _null_;
  set &dsn;
  %do i=1 %to %AHGcount(&varlist);
  call symput("%scan(&varlist,&i)"||left(_n_),%scan(&varlist,&i));
  %end;
run;

data &out;
  %do j=1 %to &Nobs;
  %do i=1 %to %AHGcount(&varlist);
  %local string;
  %let  string=%scan(&varlist,&i)&j;
  %scan(&varlist,&i)=left(put("&&&string",%scan(&width,&i).));
  %end;
  output;
  %end;
run;  

%mend;

