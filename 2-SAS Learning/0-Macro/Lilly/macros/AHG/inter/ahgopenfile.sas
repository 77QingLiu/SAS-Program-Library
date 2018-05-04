%macro AHGopenfile(file,where);
  %if %sysfunc(fileexist(&file)) %then
  %do;
  %let file=%bquote(&file);
  %local extension basename fullname;
  %let extension=%scan(&file,-1,.);
  %let basename=%scan(&file,-1,\);
  %if  %AHGblank(&extension) %then 
  %do;
  x "copy ""&file""   ""%AHGtempdir\&basename..txt.txt""   ";;
  %let fullname=%AHGtempdir\&filename..txt.txt;

  %end;
  %else %let fullname=&file;
  %AHGpm(fullname);
    %if %lowcase(&where)=sas %then 
    %do;
    %if &sysver=9.1 or &sysver=9.00 %then dm "whostedit; include ""&fullname""  ";;
    %if &sysver=9.2 %then dm "FILEOPEN ""&fullname"" ";
    %end;
    %else x """&fullname""";
  %end;

%mend;



