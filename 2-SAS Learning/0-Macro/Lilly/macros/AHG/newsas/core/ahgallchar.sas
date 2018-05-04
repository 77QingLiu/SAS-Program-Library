%macro AHGallchar(dsn,into=);
%local allchar ;
%AHGgettempname(allchar);
data _null_;deletefromithere=1;run;
%AHGvarinfo(&dsn,out=&allchar,info= name  type );

data &allchar;
  set &allchar(where=(type='C'));
run;

%AHGdistinctValue(&allchar,name,into=&into,dlm=%str( ));


%mend;
