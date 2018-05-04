%macro AHGopenfile(file,where,copy=0);
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
    %else 
      %DO;
      %IF &COPY=0 %THEN  %let fullname=&file;
      %ELSE 
        %DO;
        x "copy ""&file""   ""%AHGtempdir\copy_&BASENAME..&extension"" /y  ";;
        %let fullname=%AHGtempdir\copy_&BASENAME..&extension;
        %END;
      %END;
    %AHGpm(fullname);
    %if %lowcase(&where)=sas %then 
    %do;
    %if &sysver=9.1 or &sysver=9.00 %then dm "whostedit; include ""&fullname""  ";;
    %if &sysver>=9.2 %then dm "FILEOPEN ""&fullname"" ";;
    %end;
    %else x "start &fullname";
    %end;

%mend;
