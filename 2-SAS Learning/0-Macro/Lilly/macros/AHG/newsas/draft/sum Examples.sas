%AHGkill;
%AHGclearlog;
option nobyline;
%let dsn=sashelp.shoes ;
%let var=sales;
%let by=Subsidiary  ;
%global sortout stats;
%AHGgettempname(sortout);
%AHGgettempname(stats);

%AHGdatasort(data =&dsn, out =&sortout , by =&by );

/*
  Subsidiary    label      stat
  ------------------------------------------------
  Addis Ababa   n          8
  Addis Ababa   mean       58429
  Addis Ababa   median     65030.50
  Addis Ababa   min - max  1690.00    -  108942.00
  Al-Khobar     n          8
  Al-Khobar     mean       144208
  Al-Khobar     median     146655.00
  Al-Khobar     min - max  449.00     -  340201.00

*/
%AHGsum(&sortout,&var,&by ,out=&stats
,stats=n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2 
,orie=vert

);


%AHGalltocharnew(&stats);

%AHGtrimdsn(&stats);

%AHGreportby(&stats,0,which=2,whichlength=8); 

/*******************************************
********************************************/* */* */%AHGkill;
%AHGclearlog;
%AHGfakeft;
option nobyline;
%let dsn=sashelp.class;
%let var=height;
%let by=sex age ;
%global sortout stats;
%AHGgettempname(sortout);
%AHGgettempname(stats);

%AHGdatasort(data =&dsn , out = &sortout, by =&by );

/*

*/
%AHGsum(&sortout,&var,&by ,out=&stats,print=0,alpha=0.05
,stats=n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2 
,orie=vert

);

%AHGalltocharnew(&stats);

%AHGtrimdsn(&stats);

%AHGreportby(&stats,0,which=2,whichlength=8); 





%AHGclearlog;
%AHGfakeft;
option nobyline;
%let dsn=sashelp.class;
%let var=height;
%let by=sex age ;
%global sortout stats;
%AHGgettempname(sortout);
%AHGgettempname(stats);

%AHGdatasort(data =&dsn , out = &sortout, by =&by );

/*

*/
%AHGsum(&sortout,&var,&by ,out=&stats,print=0,alpha=0.05
,stats=n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2 
,orie=vert

);

%AHGalltocharnew(&stats);

%AHGtrimdsn(&stats);

%AHGreportby(&stats,0,which=2,whichlength=8); 



%AHGkill;
%AHGclearlog;
%AHGfakeft;
option nobyline;
data shoes;
   set sashelp.shoes(where=(region<'D')) ;
run;

libname pf "C:\kanbox\baiduyun\studies\prjA900\a9001403\A9001403\pds1_0\data";



%let dsn=SASHelp.class;
%let trtvar=sex;
%let var=weight;
%let by=age ;
%global sortout stats;

%AHGgettempname(stats);

/*

*/
%AHGsumtrt(&dsn,&var,&by,&trtvar ,out=&stats,print=0,alpha=0.05
,stats=n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2 
,orie=vert
,statord=ord

);

%AHGalltocharnew(&stats);

%AHGtrimdsn(&stats);

%AHGreportby(&stats,0); 


