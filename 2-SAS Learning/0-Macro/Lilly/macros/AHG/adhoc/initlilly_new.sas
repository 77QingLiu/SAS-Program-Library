%macro initlilly_new;
%global ls ps statdrive SAdrive  ;

%let statdrive=\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS;
%let SAdrive=&statdrive\sa;
%let ls=256; /*line size*/
%let ps=47; /*page size*/
options ls=&ls ps=&ps;
option lrecl=max;

option formdlim='';
%if %upcase(&sysscp) = WIN %then 
%do;
%global projectpath &datalocations macro1st macro2nd out1st out2nd tfl_output replication_output;
%AHGdefault(projectpath,&pathroot);
%AHGdefault(tfl_output,&projectpath\programs_stat\tfl_output);
%AHGdefault(replication_output,&projectpath\replica_programs\replication_output);
%AHGdefault(macro1st,&projectpath\programs_stat\author_component_modules);
%AHGdefault(macro2nd,&projectpath\replica_programs\validator_component_modules);
%AHGdefault(out1st,&projectpath\programs_stat\tfl_output);
%AHGdefault(out2nd,&projectpath\replica_programs\replication_output);

%AHGmkdir(%mysdd(&out1st));
%AHGmkdir(%mysdd(&out2nd));
%AHGmkdir(%mysdd(&macro1st));
%AHGmkdir(%mysdd(&macro2nd));

%macro defaultdataSetup;
%if %sysfunc(indexw(%upcase(&datalocations),ADAM)) 
  %then %AHGdefault(adam,&projectpath\data\shared\adam);

%if %sysfunc(indexw(%upcase(&datalocations),ADS)) 
  %then %AHGdefault(ads,&projectpath\data\shared\ads);

%if %sysfunc(indexw(%upcase(&datalocations),SDTM)) 
  %then %AHGdefault(sdtm,&projectpath\data\shared\sdtm);

%if %sysfunc(indexw(%upcase(&datalocations),EDS)) 
  %then %AHGdefault(eds,&projectpath\data\shared\eds);

%if %sysfunc(indexw(%upcase(&datalocations),QCADAM)) 
  %then %AHGdefault(qcadam,&projectpath\replica_programs\replication_output\adam);

%if %sysfunc(indexw(%upcase(&datalocations),QCADS)) 
  %then %AHGdefault(qcads,&projectpath\replica_programs\replication_output\ads);


%macro oneLib(lib);
libname r&lib "&&&lib";
%AHGmkdir(%mysdd(&&&lib));
libname l&lib "%mysdd(&&&lib)"  ;
libname &lib (l&lib r&lib);
%mend;

%macro dosomething;
%local i;
%do i=1 %to %AHGcount(&datalocations);
%onelib(%scan(&datalocations,&i));
%end;

%mend;
%doSomething



%mend;

%defaultdataSetup;




options sasautos=(sasautos "d:\newsas\core" "d:\newsas\inter" 
"d:\newsas\adhoc" "d:\bums\"
"%mysdd(&macro1st)"
"%mysdd(&macro2nd) ");





%end;
%mend;
