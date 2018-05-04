*m205d05;

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

%macro findcsv(dir);
 
   filename filelist pipe "dir /b /s &dir\*.csv";

   options nonotes nosource;

   data _null_;
   	infile filelist truncover;
     	input filename $100.;
   	call execute(cats('%importcsv(', filename, ')' ));
   run;

   options notes source;

%mend findcsv;

%findcsv(&path)
%*findcsv(S:\workshop)

*If the directory name contains spaces, use this program;

%macro findcsv;

   data _null_;
      infile filelist truncover;
      input filename $100.;
      call execute(cats('%importcsv(', filename, ')' ));
   run;

%mend findcsv;

filename filelist pipe 'dir /b /s "c:\my documents\*.csv" ';

%findcsv