%macro AHGdsntofile(dsn,file,var=);
%local i;
%if %AHGblank(&var) %then %AHGvarlist(&dsn,Into=var,dlm=%str( ),global=0);


  data _null_;
    file "&file";
    
    %do i=1 %to %AHGcount(&var);
    put "%scan(&var,&i)";
    %end;
    ;
  run;
%mend;



%AHGdsntofile(ladam.adsl,&localtemp\class.txt,var=);

x "&localtemp\class.txt";


%macro AHGdsntofile(dsn,file,var=);
%local i;
%if %AHGblank(&var) %then %AHGvarlist(&dsn,Into=var,dlm=%str( ),global=0);

%AHGDataView(dsin=&dsn,dsout=,order=original,SameVal=noDelete);

  data _null_;
    file "&file";
    
    %do i=1 %to %AHGcount(&var);
    put "%scan(&var,&i)";
    %end;
    ;
  run;
%mend;

%AHGdsntofile(ladam.adsl,&localtemp\class.txt,var=);
