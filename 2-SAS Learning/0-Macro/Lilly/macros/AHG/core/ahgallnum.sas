%macro AHGallnum(dsn,into=);

/*data _null_;*/
/*  set &dsn;*/
/*  array into{1} $32000.   _temporary_;*/
/*  array allnum  _numeric_;*/
/*  do over allnum;*/
/*    into(1)=catx(' ',into(1),vname(allnum));*/
/*  end;*/
/*  call symput("&into",into(1));*/
/*  stop;*/
/*run;*/
%local allnum ;
%AHGgettempname(allnum);
%AHGvarinfo(&dsn,out=&allnum,info= name  type );

data &allnum;
  set &allnum(where=(type='N'));
run;

%AHGdistinctValue(&allnum,name,into=&into,dlm=%str( ));



%mend;
