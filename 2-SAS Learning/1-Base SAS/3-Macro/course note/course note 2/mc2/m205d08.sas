*m205d08;

%macro fixname(badname); 
	%if %datatyp(%qsubstr(&badname,1,1))=NUMERIC 
		%then %let badname=_&badname;
   %let badname=
		%sysfunc(compress(
			%sysfunc(translate(&badname,_,%str( ))),,kn));
	%substr(&badname,1,32)
%mend fixname;  

%macro importxls(excel);

   options nostimer;
   libname myexcel pcfiles path="&excel";

   proc sql noprint;
      select memname into :sheet1-
         from dictionary.tables
            where libname="MYEXCEL";
   quit;

   %put _local_;

   %do i=1 %to &sqlobs;        	
      data %fixname(&&sheet&i);
         set myexcel."&&sheet&i"n;
      run;
   %end;

   libname myexcel clear;

%mend importxls;

%importxls(&path\custfm.xls)
%*importxls(S:\workshop\custfm.xls)
