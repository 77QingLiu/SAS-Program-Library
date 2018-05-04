*m205d01;

%macro fixname(badname); 
	%if %datatyp(%substr(&badname,1,1))=NUMERIC 
		%then %let badname=_&badname;
   %let badname=
		%sysfunc(compress(
			%sysfunc(translate(&badname,_,%str( ))),,kn));
	%substr(&badname,1,32)
%mend fixname;  

%put %fixname(Bad na!@#&$*-%^me);
%put %fixname(123Bad na!@#&$*-%^me);
%put %fixname(123456789a123456789b123456789c123456789);

%put %fixname(Bad na!@#&a$*-%^me);
%put %fixname(Bad na!@#&$*-%a^me);
