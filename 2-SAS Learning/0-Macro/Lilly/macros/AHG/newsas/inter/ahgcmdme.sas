%macro AHGcmdme;
  %local pgmname execpath currentpath; %local up;
  %let execpath=%sysfunc(GetOption(SYSIN));
  %IF %length(&execpath)=0 %then %let execpath=%sysget(SAS_EXECFILEPATH);
  %let pgmname=%qscan(%bquote(&execpath),-2,/\.);
  %let currentpath=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&execpath));
  %let up=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&currentpath));





 x " ""C:\Program Files\SAS\SASFoundation\9.2(32-bit)\sas.exe"" ""&currentpath\&pgmname..sas""  
-PRINT ""%AHGtempdir\&pgmname..lst"" -LOG ""%AHGtempdir\&pgmname..log""   ";

 %AHGopenfile(%AHGtempdir\&pgmname..lst,sas);
 %AHGopenfile(%AHGtempdir\&pgmname..log,sas);

%mend ;
