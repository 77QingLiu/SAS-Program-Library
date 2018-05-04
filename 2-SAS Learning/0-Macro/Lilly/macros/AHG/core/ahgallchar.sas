%macro AHGallchar(dsn,into=);
%local allchar ;
%AHGgettempname(allchar);
data deletefromithere;
%AHGvarinfo(&dsn,out=&allchar,info= name  type );

data &allchar;
  set &allchar(where=(type='C'));
run;

%AHGdistinctValue(&allchar,name,into=&into,dlm=%str( ));
data writetofilefromithere;


%mend;
