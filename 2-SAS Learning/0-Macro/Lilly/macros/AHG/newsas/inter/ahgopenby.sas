%macro AHGopenby(mask,where=sas,from=3,exe=1);
  %local location;
  %let location=&from;
  %if &location=3 %then %let location=&projectpath;

  %local extension folder dir;
  %local fullname;
  %let extension=%qscan(%sysfunc(compress(&mask,%nrstr(%'%%))),-1,.);
	  %if &extension=tot  %then %let folder=tools;
	  %if &extension=sas  %then %let folder=macros analysis;
	  %if &extension=sasdrvr  %then %let folder=program;
	  %if &extension=rpt %then %let folder=table;
	  %if &extension=log %then %let folder=logs;
	  %if &extension=meta %then %let folder=tools ;
    %if &extension=pdf  %then %let folder=table rpt;
    %local i j dir allfile ;
    %if &location=0 %then 
    %do;
    %let location=&kanbox;
    %let folder=allover alloverhome;
    %end;
    %do i=1 %to %AHGcount(&folder);
    %let dir=&location\%scan(&folder,&i);

    %AHGfilesindir(&dir,dlm=@,fullname=0,mask=&mask,into=allfile,case=0,print=0);    
    %do j=1 %to %AHGcount(&allfile,dlm=@);
    %AHGpm(j);
    %if &exe=1 %then %AHGopenfile(&dir\%scan(&allfile,&j,@),&where); 
    %else %put &dir\%scan(&allfile,&j,@); ;
    %end;
    %end;
%mend;


