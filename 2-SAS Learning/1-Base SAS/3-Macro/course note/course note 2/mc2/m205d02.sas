*m205d02;

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
      datafile="%superq(file)" 
      out=%fixname(%scan(&file,-2,.\)) replace
	 	dbms=csv;
   run;
   options notes source;
%mend importcsv;
 
%importcsv(&path\bad name #1.csv)
%*importcsv(S:\workshop\bad name #1.csv)

