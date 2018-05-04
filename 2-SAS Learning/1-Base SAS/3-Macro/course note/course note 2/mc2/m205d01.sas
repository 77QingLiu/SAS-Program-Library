*m205d01;

%macro fixname(badname); 
	%if %datatyp(%qsubstr(&badname,1,1))=NUMERIC 
		%then %let badname=_&badname;
   %let badname=
		%sysfunc(compress(
			%sysfunc(translate(&badname,_,%str( ))),,kn));
	%substr(&badname,1,32)
%mend fixname;  

%put %fixname(bad name #1);
%put %fixname(123Bad na!@#&$*-%^me);
%put %fixname(123456789a123456789b123456789c123456789);

*eliminate WARNING in log: method 1;

%macro fixname(badname); 
	%if %datatyp(%qsubstr(&badname,1,1))=NUMERIC 
		%then %let badname=_&badname;
   %let badname=
		%sysfunc(compress(
			%sysfunc(translate(&badname,_,%str( ))),,kn));
	%if %length(&badname)>32
		%then %substr(&badname,1,32);
		%else &badname;
%mend fixname;  

%put %fixname(bad name #1);
%put %fixname(123Bad na!@#&$*-%^me);
%put %fixname(123456789a123456789b123456789c123456789);

*eliminate WARNING in log: method 2;

%macro fixname(badname); 
	%if %datatyp(%qsubstr(&badname,1,1))=NUMERIC 
		%then %let badname=_&badname;
   %let badname=
		%sysfunc(compress(
			%sysfunc(translate(&badname,_,%str( ))),,kn));
	%substr(&badname,1,%sysfunc(min(%length(&badname),32)))
%mend fixname;  

%put %fixname(bad name #1);
%put %fixname(123Bad na!@#&$*-%^me);
%put %fixname(123456789a123456789b123456789c123456789);

