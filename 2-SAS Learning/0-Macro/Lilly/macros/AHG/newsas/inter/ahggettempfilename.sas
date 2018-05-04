%macro AHGgettempfilename(tempname,dir=%AHGtempdir,start=&tempname,ext=txt);
  %local  rdn ;
  %do %until (not %sysfunc(fileExist(&&&tempName))  );
  %let rdn=%sysfunc(normal(0));
	%let rdn=%sysfunc(translate(&rdn,00,.-));
	%let &tempname=T_&start.._%substr(&rdn,1,5).&ext;
  %end;
  %put &tempname=&&&tempname;    
%mend;
