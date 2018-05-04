%macro AHGwild(string,word);
  %local i wordN;
  %let wordN=%AHGcount(&word,dlm=@);

  %local finalstr pos item notFound;
    %let finalstr=&string;
    %let i=0;
    %let notfound=0;
    %do %until( (&i=&wordN) or &NotFound) ;
      %AHGincr(i)
      %let item=%scan(&word,&i,@);
      %let pos=%AHGpos(&finalstr,&item);
      %if &pos>0 %then   %let finalstr=%substr(&finalstr,%eval(&pos+%length(&item)));
      %else %let notFound=1;

    %end;
    %if (not &notFound) %then &string;
%mend;  
