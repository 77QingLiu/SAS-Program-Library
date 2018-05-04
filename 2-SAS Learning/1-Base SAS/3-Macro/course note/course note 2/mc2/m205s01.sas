*m205s01;

%macro importdata(file);

   %let dsn=%scan(&file,-2,\.);

   data &dsn;
		infile "&file";
		input Order_ID Order_Type Order_Date : date9.;
		format Order_Date date9.;
   run;

%mend importdata;

%macro findraw(dir);

   filename filelist pipe "dir /b /s &dir\*.dat";

   data _null_;
   	infile filelist truncover;
     	input filename $100.;
   	call execute(cats('%importdata(', filename, ')' ));
   run;

%mend findraw;

%findraw(&path\rawdata)
%*findraw(S:\workshop\rawdata)

