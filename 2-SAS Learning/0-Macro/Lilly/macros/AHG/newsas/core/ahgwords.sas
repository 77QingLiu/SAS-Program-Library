%macro AHGwords(word,n,base=1);
%local AHG4I;
%if not %index(&word,@) %then %let word=&word@;
%if %AHGcount(&n)=1 %then
  %do AHG4I=%eval(&base) %to %eval(&n+&base-1);
  %sysfunc(tranwrd(&word,@,&AHG4i))
  %end;
%else 
  %do AHG4i=1 %to %AHGcount(&n) ;
  %sysfunc(tranwrd(&word,@,%scan(&n,&AHG4i))) 
  %end;

%mend;





