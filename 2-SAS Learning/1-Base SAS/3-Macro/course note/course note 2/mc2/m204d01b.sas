*m204d01b;

%macro print(data=&syslast,obs=5);
   proc print data=&data(obs=&obs); 
      title "&data"; 
   run;
%mend print;

%macro printlib(libname);

   proc sql noprint;
	select "&libname.." || memname
	   into :dsn1-
		from dictionary.tables
		   where libname="%upcase(&libname)";
   quit;

   %do i=1 %to &sqlobs;
      %print(data=&&dsn&i)   
   %end;

%mend printlib;

%printlib(orion)

