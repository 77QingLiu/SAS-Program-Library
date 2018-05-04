*m205d04;

%macro fixname(badname); 
	%if %datatyp(%qsubstr(&badname,1,1))=NUMERIC 
		%then %let badname=_&badname;
   %let badname=
		%sysfunc(compress(
			%sysfunc(translate(&badname,_,%str( ))),,kn));
	%substr(&badname,1,32)
%mend fixname;  

%macro importcsv(file);
   options nonotes nosource;
   proc import 
      datafile="&file" 
      out=%fixname(%scan(&file,-2,.\)) replace
	dbms=csv;
   run;
   options notes source;
%mend importcsv;

filename filelist pipe "dir /b /s &path\*.csv";
*filename filelist pipe "dir /b /s S:\workshop\*.csv";

data _null_;
   infile filelist truncover;
   input filename $100.;
   call execute(cats('%importcsv(', filename, ')' ));
run;
