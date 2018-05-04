%macro AHGuncompress(string,char);
  %sysfunc(compress(&string,%sysfunc(compress(&string,&char))  ))
%mend;

