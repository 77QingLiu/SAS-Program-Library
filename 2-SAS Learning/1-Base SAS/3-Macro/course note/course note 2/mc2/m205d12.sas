*m205d12;

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

   %do i=1 %to &sqlobs;        	
      data %fixname(&&sheet&i);
         set myexcel."&&sheet&i"n;
      run;
   %end;

   libname myexcel clear;

%mend importxls;

%macro findxls(dir) / minoperator;
   %local fileref rc did n memname didc;
   %let rc=%sysfunc(filename(fileref,&dir));
   %let did=%sysfunc(dopen(&fileref));

   %if &did=0 %then %do;
      %put ERROR: Directory %upcase(&dir) does not exist.;
      %return;
   %end;
   
   %do n=1 %to %sysfunc(dnum(&did));
      %let memname=%sysfunc(dread(&did,&n));
      %if %upcase(%scan(&memname,-1,.)) in XLS XLSX %then %importxls(&dir\&memname);
      %else %if %scan(&memname,2,.)= %then %findxls(&dir\&memname);
   %end;

   %let didc=%sysfunc(dclose(&did));
   %let rc=%sysfunc(filename(fileref));
%mend findxls;

%findxls(&path)
%*findxls(S:\workshop)
