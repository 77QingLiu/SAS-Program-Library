*m204d01c;

%macro print(data=&syslast,obs=5);
   proc print data=&data(obs=&obs); 
      title "&data"; 
   run;
%mend print;

%macro printlib(libname);

   proc sql noprint;
      select cats('%print(data=', "&libname..", memname, ')' )
         into :printall separated by ' '
	     from dictionary.tables
		 where libname="%upcase(&libname)";
   quit;

   %put %superq(printall);

   &printall

%mend printlib;

%printlib(orion)

