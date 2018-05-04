*m205s03;

%macro importmdb(access);

   libname myaccess pcfiles path="&access";

   proc sql noprint;
      select memname into :table1-
         from dictionary.tables
            where libname="MYACCESS"
		    		and dbms_memtype='TABLE';
   quit;

   %do i=1 %to &sqlobs;        	
      data &&table&i;
         set myaccess.&&table&i;
      run;
   %end;

   libname myaccess clear;

%mend importmdb;

%importmdb(&path\orionaccess.accdb)
%*importmdb(S:\workshop\orionaccess.accdb)
