%macro AHGNum2date(dateNo,format=date9.);
 %sysfunc(putn(&dateNo,&format))
%mend;
