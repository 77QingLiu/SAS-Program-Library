%macro AHGassocfiles(files=txt rpt sas log lst lis tot diff meta,prog=C:\Program Files\UltraEdit\uedit32.exe);
    %local i ext;
    %do i=1 %to %AHGcount(&files);
    %let ext=%qscan(&files,&i);
    x assoc .&ext=&ext.file;
    x ftype &ext.file="&prog" %1;
    %end;

%mend;
