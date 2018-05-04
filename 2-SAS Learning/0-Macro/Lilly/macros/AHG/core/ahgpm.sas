%macro AHGpm(Ms);
  %local Pmloop2342314314 mac;
  %do Pmloop2342314314=1 %to %AHGcount(&Ms);
    %let mac=%scan(&Ms,&Pmloop2342314314,%str( ));
    %put &mac=&&&mac;
  %end;
%mend;

