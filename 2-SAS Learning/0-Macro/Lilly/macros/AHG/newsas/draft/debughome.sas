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
%AHGgettempname(sortout);

%AHGdatasort(data =&dsn , out =&sortout , by = &by);
%AHGsumex(&sortout,&var,&by ,out=&stats,print=0,alpha=0.05
,stats=n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2 
,orie=vert
,statord=ord

);

%AHGalltocharnew(&stats);

%AHGtrimdsn(&stats);

%AHGreportby(&stats,0); 

%AHGdsntofile(&thedsn,&localtemp\class.txt,var=);

%AHGtime(2);

%AHGinterval(1,2);

x "&localtemp\class.txt";

%AHGexe(%str(Z:\Downloads\code completion\code.exe));

%AHGopenmac(AHGlookinto);

%AHGopenmac(ahgcodecompletion);

ahgdsnfilename
ahgcodecompletion

%let stats=;
%put %AHGname(n @ p25 '-' p75,but=@ );


%let f=SDALFKAJDSF;
%macro SDALFKAJDSF(single);
  not  (%index(&single,%str(%")) or %index(&single,%str(%'))) 
%mend;

%PUT %&F;

%macro ISS(single);
  not  (%index(&single,%str(%")) or %index(&single,%str(%'))) 
%mend;

%ahgcodecompletion(setprint);


 ;*';*";*/;quit;run;



%AHGwt(&localtemp\SAS_session_%substr(&SYSPROCESSID,6,20).sas.txt,
str=changehintFile sashelp\cityday.meta.txt);
/*%AHGOPENFILE(&localtemp\SAS_session_%substr(&SYSPROCESSID,6,20).sas.txt,sas);*/

%AHGprt(dsn=sashelp.class);

%put %AHGindex2(n @ mean\9. @ median\9.2 @ min\9.2 '-' max\9.2 );

 
%AHGkill;
option nobyline ls=255;

%summary1(sashelp.class,age,trt=sex,by=,out=age
,stats=n @ mean\9.  @ '[' min\9.2 '--' max\9.2 ']' @ median\9.2
,orie=vert
,labels=n @ average @ minimam - maximam @ median
);

%summary1(sashelp.class,weight,trt=sex,by=,out=wt
,stats=n @ mean\9.  @ '[' min\9.2 '--' max\9.2 ']' @ median\9.2
,orie=vert
,labels=n @ average @ minimam - maximam @ median
);

%AHGsetprint(age wt,out=setprint,by=from);

%AHGtrimdsn(setprint);

%AHGreportby(setprint);

%AHGopenmac(ahgmergeprintex);



data one;
 length region $80.;
  set sales;
   region='<A '||compress('HREF="'||region||'.html')
         ||'">'||trim(region)||'</A>';
run;
%AHGclearlog;
%AHGsetprint(sashelp.class sashelp.shoes,out=ok,keep=1);
%AHGopendsn(ok);
