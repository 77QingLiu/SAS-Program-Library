*m205d07;

libname myexcel pcfiles path="&path\custfm.xls";
*libname myexcel pcfiles path="S:\workshop\custfm.xls";

options nostimer;

proc sql noprint;
   select memname into :sheet1-
      from dictionary.tables
         where libname="MYEXCEL";
quit;

%put _user_;