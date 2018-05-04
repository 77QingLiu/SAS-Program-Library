x 'del c:\temp\mynew.sas';
x 'del c:\temp\my.sas';
%let mfile=c:\temp\my.sas;
filename mprint "&mfile";
option mprint mfile;
proc printto ;
run;

%macro haha;
 %AHGsumextrt(sashelp.class,
height,by=age,trt=sex,print=1,out=sum,alpha=);

%AHGreportby(sum,0);

%mend;

%haha;


%AHGindent(&mfile);
