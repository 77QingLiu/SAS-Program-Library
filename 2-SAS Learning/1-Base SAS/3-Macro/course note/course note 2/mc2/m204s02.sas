*m204s02;

data _null_;
   set sashelp.vstabvw(keep=libname memname);
   where memname contains "STAFF";
   call execute(cats('%contents(data=', libname, ".", memname, ')' ));
run;
