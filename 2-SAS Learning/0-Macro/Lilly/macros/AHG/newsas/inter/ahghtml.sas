%macro AHGhtml(dsn,option=label);
%local html;
%let html=%sysfunc(compress(%AHGtempdir%str(\)%AHGrdm.HTML));
    ods html file="&html";  
    %AHGreportby(&dsn,0,which=,whichlength=,sort=0,groupby=0,groupto=0,topline=,showby=0,option=nowd,labelopt=%str( ;));
    ods html close;   
    x "start &html";
%mend;
