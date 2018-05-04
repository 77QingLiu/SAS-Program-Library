/*Print Macro variables;*/
%macro AHGpmlike(Ms,start=1);
   %local oneStr onetype  j;
   %let ms=%upcase(&ms);
   %do j=1 %to %AHGcount(&ms);
       %let  oneStr=%scan(&ms,&j,%str( ));  
       %let oneType=;
       proc sql noprint;
        select name into :onetype separated by ' '
        from sashelp.vmacro
        %if &start eq 1 %then where upcase(name) like  "&oneStr%";
        %else where upcase(name) like "%"||"&oneStr%";

        order by name
        ;quit;
      %if &start=1 %then %AHGsortnum(&onetype,into=onetype);
      %local i mac;
      %do i=1 %to %AHGcount(&onetype);
        %let mac=%scan(&onetype,&i,%str( ));
        %put &mac=&&&mac;
      %end;
  %end;
%mend;

