%macro AHGcopypath;
  %local pgmname execpath currentpath; %local up;
  %let execpath=%sysfunc(GetOption(SYSIN));
  %IF %length(&execpath)=0 %then %let execpath=%sysget(SAS_EXECFILEPATH);
  %let pgmname=%qscan(%bquote(&execpath),-2,/\.);
  %let currentpath=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&execpath));
  %let up=%sysfunc(PRXCHANGE(s/(.*)\\.*/\1/,-1,&currentpath));

filename ahgclip clear;
filename ahgclip clipbrd;
 
data _null_;
  file ahgclip;
  put "&currentpath";
run;

%mend;
