%macro AHGopenbystr(dir=&projectpath,keyword=);

x "dir && c:\perl\bin\perl C:\studies\perl\func\openfilebystr.pl --dirname=&dir --keyword=&keyword --filter=*.sas ";

%mend;
