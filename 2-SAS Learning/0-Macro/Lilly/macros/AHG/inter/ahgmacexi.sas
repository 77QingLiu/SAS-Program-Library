
%macro AHGmacexi(mac,flag=flag);
  proc sql noprint;
     SELECT 'YES' INTO :&flag
       FROM DICTIONARY.MACROS
       WHERE UPCASE(TRIM(NAME)) = UPCASE("&mac");
  quit;
%mend;
