*m204d01d;

%macro print(data=&syslast,obs=5);
   proc print data=&data(obs=&obs); 
      title "&data"; 
   run;
%mend print;

%macro printlib(libname);

   data _null_;
      set sashelp.vstabvw(keep=libname memname);
      where libname="%upcase(&libname)";
      call execute(cats('%print(data=', "&libname..", memname, ')' ));
   run;

%mend printlib;

%printlib(orion)
