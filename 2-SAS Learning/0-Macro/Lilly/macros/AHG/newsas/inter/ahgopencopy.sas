%macro AHGopenCopy(file,where);
  %if %sysfunc(fileexist(&file)) %then
    %do;
    %let file=%bquote(&file);
    %local extension basename fullname;
    %let extension=%scan(&file,-1,.);
    %let basename=%scan(&file,-1,\);
    %if  %AHGblank(&extension) %then 
    %do;
    x "copy ""&file""   ""%AHGtempdir\&basename..txt.txt"" /y  ";;
    %let fullname=%AHGtempdir\&filename..txt.txt;

    %end;
  %else
    %do;
    x "copy ""&file""   ""%AHGtempdir\&basename"" /y  ";;
    %let fullname=%AHGtempdir\&basename;
    %end;
  %AHGpm(fullname);
    %if %lowcase(&where)=sas %then 
    %do;
    %if &sysver=9.1 or &sysver=9.00 %then dm "whostedit; include ""&fullname""  ";;
    %if &sysver=9.2 %then dm "FILEOPEN ""&fullname"" ";
    %end;
    %else x "start call ""&fullname""";
  %end;

%mend;




