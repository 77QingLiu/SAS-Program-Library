*m205e01;

%macro importdata(file);

   %let dsn=%scan(&file,-2,\.);

   data &dsn;
		infile "&file";
		input Order_ID Order_Type Order_Date : date9.;
		format Order_Date date9.;
   run;

%mend importdata;
 
%importdata(&path\rawdata\orders03.dat)
%*importdata(S:\workshop\rawdata\orders03.dat)
