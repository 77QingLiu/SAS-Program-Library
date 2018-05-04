%macro setMeUp;
  %if not (&sysscp=WIN) %then
    %do;
    libname va "&adam";
    %end;
  %else
    %do;
    dm "clear log";
    dm "clear lst";
    %AHGdatadelete;
    %end;
%mend;

%setmeup;

%AHGuse(adam.adae adam.adsl);
%let aeterm=aetox;
%let socterm=aectcsoc;
%let TEAEflag=trtemfl;
%let myadsl=%str(adam.adsl(rename=(trt01an=trtpn)));
%Let myadae=adam.adae;
%let rtf=fqae111;

data adsl;
  set &MYadsl;
  where fasfl='Y'; 
  keep subjid trtpn fasfl;
  output;
  subjid='99'||subjid;
  trtpn=4;
  output;
run;



data adae;
  set  &myADAE  ;
  where (not missing(&aeterm)) and (not missing(&TEAEflag)) ;
  output;
  subjid='99'||subjid;
  trtpn=4;output;

run;

%fqae;
/* **************************************/

/*%AHGdatasort(data = thedsn, out = outdsn, by = &socterm );*/

