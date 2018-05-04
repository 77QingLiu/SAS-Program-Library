/**************************************************************************************************************************************************
Eli Lilly and Company - GSS (required)
CODE NAME (required)                : /lillyce/prd/ly2835219/i3y_mc_jpbm/dmc_blinded3/programs_stat/setup.sas
PROJECT NAME (required)             : I3Y_MC_JPBM
DESCRIPTION (required)              : Library/default option setup for TFL programs
SPECIFICATIONS(required)            : N/A
VALIDATION TYPE (required)          : N/A This is a component modeule 
INDEPENDENT REPLICATION (required)  : N/A
ORIGINAL CODE (required)            : N/A, it is original code
COMPONENT CODE MODULES              : N/A
SOFTWARE/VERSION# (required)        : SAS Version 9.2
INFRASTRUCTURE                      : 
DATA INPUT                          : N/A
OUTPUT                              : N/A
SPECIAL INSTRUCTIONS                : N/A
-------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
DOCUMENTATION AND REVISION HISTORY SECTION (required):

       Author &
Ver# Validator            Code History Description
---- ----------------     -----------------------------------------------------------------------------------------------------------------------
1.0  Hui Liu             Original version of the code
**eoh***********************************************************************************************************************************************/
 
%macro setup;

DM 'log;clear;output;clear;';

proc datasets memtype=data nolist nodetails kill;
run;quit;


%local proj dataArea allmac pathmac one ;
%let allmac=__snapshot execpath outfile currentpath production_status consol pgmname  bumlib batchmode 
eds sdtm adam  log logname prg specs timepts  spec1 _ls_ maclib _lstot_ _pstot_  _ls_ refreshmac
spec2 design ftimepts gls dict  tfl_output  execpath rptfile  rptindat lstname logOrfile cutoff trash;

%let pathmac=__snapshot execpath currentpath  bumlib  eds sdtm adam  log   specs     tfl_output  execpath ;

%global  &allMac;

%if %index(&currentpath,:) and %sysfunc(PRXCHANGE(s/.*\\SDDEXT(\d{3})(.*)/\1/,-1,&currentpath))>=100  %then %let currentpath=\\mango\awe.grp%scan(&currentpath,2,:);
%else %if %index(&currentpath,:) and %sysfunc(PRXCHANGE(s/.*\\SDDEXT(\d{3})(.*)/\1/,-1,&currentpath))<100  %then %let currentpath=\\mango\sddext.grp%scan(&currentpath,2,:);

%macro up(dir,n=1,dlm=\);%local i;
%do i=1 %to &n;
%let dir=%sysfunc(reverse(%substr(%sysfunc(reverse(&dir)),%eval(%index(%sysfunc(reverse(&dir)),&dlm)+1))));
%end;&dir
%mend;
%let __snapshot=%up(&currentpath,n=2);

%let proj=%scan(&currentpath,6,/\);
%let dataArea=%scan(&currentpath,9,/\);
%let bumlib=\\mango\sddext.grp\SDDGENERAL\bums\macro_library;
%let eds=&__snapshot\data\eds;
%let sdtm= &__snapshot\data\sdtm;
%let adam= &__snapshot\data\adam;
%let log=&currentpath\system_files;
%let logname=&log\&pgmname..log;
%let lstname=&log\&pgmname..lst;
%let prg=&currentpath\;
%let outfile=&pgmname;
%let specs=&__snapshot\data\custom;

%let timepts=&__snapshot\data\custom\&proj._timepoint.xlsx;
%let spec1=&specs\&proj._&dataArea._SST1.xlsx;
%let spec2=&specs\&proj._&dataArea._studyspec2.xlsx;
%let design=&__snapshot\data\custom\&proj._trial_design_domains.xlsx;
%let ftimepts=&proj._trial_design_domains.xlsx;
%let gls=\\mango\sddext.grp\SDDGENERAL\cdisc\sdtm\metadata;
%let dict=\\mango\sddext.grp\SDDGENERAL\dictionaries\current;
%let tfl_output=&__snapshot\programs_stat\tfl_output;
%let consol=%sysfunc(PRXCHANGE(s/(.*\\SDDEXT\d{3})(.*)/\1/,-1,&currentpath))\prd\data\custom;
%let trash=%up(&__snapshot,n=4)\trash;

libname eds "&eds" access=readonly;
libname sdtm "&sdtm"  ;
libname sdtmr "&sdtm"  access=readonly;
libname specs "&specs"  ;
libname dict "&dict" access=readonly;
libname _meddra_ "&dict" access=readonly;
libname custom "&specs" ;
libname adam "&adam";
libname adamr "&adam" access=readonly;
libname tfl "&tfl_output";
libname irtfl "&log";
libname gls "&gls";
libname _cdisc_ "\\Mango\sddext.grp\SDDGENERAL\cdisc\adam\metadata"  access=readonly;
libname library "\\Mango\sddext.grp\SDDGENERAL\cdisc\global_library\metadata" access=readonly;

%if %sysfunc(exist(sdtm.ts)) %then
%do;
proc sql noprint;
  /*select put(input(TSVAL,date11.),yymmdd10.) into :cutoff*/
/*select input(TSVAL,date11.) into :cutoff*/
select input(TSVAL,yymmdd10.) into :cutoff
from sdtm.ts
  where TSPARMCD='DCUTDTC'
  ;
  quit;
%end;

%let execpath=&prg;
%let rptfile=&tfl_output\;
%let rptindat=&adam;

%let maclib="&currentpath";

%if %sysfunc(fileexist(%up(&currentpath)\sdtm\author_component_modules)) %then %let maclib=&maclib "%up(&currentpath)\sdtm\author_component_modules";
%if %sysfunc(fileexist(&currentpath\author_component_modules)) %then %let maclib=&maclib "&currentpath\author_component_modules";
%if %sysfunc(fileexist(&currentpath\validator_component_modules)) %then %let maclib=&maclib "&currentpath\validator_component_modules";

options mprint nocenter nosymbolgen orientation=landscape nodate nonumber nobyline missing = ' ' nomlogic 
         formchar='|----|+|---+=|-/\<>*'  validvarname=upcase 
         mrecall noxwait source source2 sasautos=( &MacLib "&bumlib" '!SASROOT/sasautos' sasautos  ) mautosource;

%let production_status=;

%if %upcase(%scan(&currentpath,4,/\))=PRD %then %let  production_status=PDPM;
%else %let  production_status=TDTM;

%let _lstot_=133;
%let _pstot_=47;

options ls=&_lstot_ ps=&_pstot_ nocenter nodate fmtsearch=(work library) missing='' 
         source notes nonumber nobyline;
options formchar="|____|+|___+=|-/\<>*" ;

%let _ls_=%sysfunc(getoption(ls));

%if %length(%sysfunc(GetOption(SYSIN))) %then %let batchmode=1;
%else %let  batchmode=0;

%put batchmode=&batchmode;

%do i=1 %to 100;
  %let one=%scan(&pathmac,&i);
  %IF &one ne %then 
  %do;
  %let &one=%sysfunc(prxchange(s/(.*[^\\])[\\]?/\1/,-1,&&&one))\;
/*  %if %index(&&&one,\\) and not %index(%scan(&&&one,-1,\),.) %then %let &one=&&&one\;*/
  %put &one=&&&one;
  %end;
%end;

%if &batchmode %then %let logOrfile=&logname;
%else 
  %do;
  %let logOrfile=;
  %macro Chn;
  %if %sysfunc(fileexist(\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\sasmacr.sas7bcat)) 
      %then 
        %do;
        
        %macro fdt(filename);                                                                                                           
         %local rc fid fidc;                                                                                                                   
         %local Bytes CreateDT ONEFILE DATE TIME;                                                                                                       
         %let rc=%sysfunc(filename(onefile,&filename));    
         %IF %SYSFUNC(FILEEXIST(&FILENAME)) %THEN
         %DO; 
         %let fid=%sysfunc(fopen(&onefile)); 
         %let DATE=%sysfunc(inputn(%sysfunc(finfo(&fid,Last Modified) ),datetime20.) );
          &DATE            
         %let fidc=%sysfunc(fclose(&fid));   
         %END; 
        %mend  ;   

        %local tempCat stored;
          option  noxwait mprint mrecall; 
          %let tempCat=&trash\&sysuserid\temp\tempcat&sysjobid;
          %put tempcat=&tempcat;
          %if %sysfunc(fileexist(&trash\&sysuserid))=0 %then x "mkdir &trash\&sysuserid";;
          %if %sysfunc(fileexist(&trash\&sysuserid\temp))=0 %then x "mkdir &trash\&sysuserid\temp";;          
          %if %sysfunc(fileexist(&tempCat))=0 %then x "mkdir &tempCat";;
          /*
          %if %sysfunc(fileexist(%sysfunc(getoption(sasuser))\sasmacr.sas7bcat)) %then 
          %do;
          proc datasets library=sasuser kill force memtype=catalog;
          run;
          quit;
          %end;
          */
          
          %put user=&tempCat;
          %let stored=&tempCat;
        option NOmstored ;
         %IF %sysfunc(LIBref(stored)) = 0 %THEN libname stored clear;
        %if (not %sysfunc(fileexist(&stored\sasmacr.sas7bcat))) 
              or (%fdt(\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\sasmacr.sas7bcat)>%fdt(&stored\sasmacr.sas7bcat))
        %then x copy "\\gh3nas01\gh3nas_sales.grp\LCDDMAC\STATS\SA\Macro library\sasmacr.sas7bcat"    "&stored" /y;;
/*        %IF %sysfunc(LIBref(stored)) ne 0 %THEN*/
        libname stored "&stored";  ;
        option mstored SASMSTORE=stored noxwait mprint mrecall;  
       
        %end;
    %mend;;      
  %end;


%if %length(&logOrfile) %then 
  %do;
  proc printto log="&logOrfile" new; 
  run;
  %end;
%mend;


%setup ;

%macro thePostProc;

proc printto log=log  ; run;
%ut_saslogcheck(logfile=%STR(&logOrFile));
proc printto;run;

%mend;
