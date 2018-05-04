*m205e03;

libname myaccess pcfiles path="&path\orionaccess.accdb";
*libname myaccess pcfiles path="S:\workshop\orionaccess.accdb";

options nolabel;

proc sql number;
   select memname
      from dictionary.tables
         where libname="MYACCESS"
		 and dbms_memtype='TABLE';
quit;

options label;

libname myaccess clear;
