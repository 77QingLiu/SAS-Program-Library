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

data _null_;
	call symput('ahuigefromtime',put(time(),time8.));
run;

%AHGuse(adam.adae adam.adsl);
%let aeterm=aetox;
%let socterm=aectcsoc;
%let TEAEflag=trtemfl;
%let myadsl=%str(adam.adsl(rename=(trt01an=trtpn)));
%Let myadae=adam.adae;
%let rtf=fqae131;

data adsl;
  set &MYadsl;
  where fasfl='Y'; 
  keep subjid trtpn fasfl;
  output;
  subjid='99'||subjid;
  trtpn=4;
  output;
run;

option nonotes nosource nosource2 nomprint;

/*option source source2 mprint;*/

data adae;
  set  &myADAE  ;
  where (not missing(&aeterm)) and (not missing(&TEAEflag)) 
/*and upcase(&socterm)='CARDIAC DISORDERS' */
  
/*  and (lowcase(&aeterm)<lowcase('G' ))*/
  
;
  output;
  subjid='99'||subjid;
  trtpn=4;output;

run;

%fqaegrd;

data ahuige;
	diff=time()-input("&ahuigefromtime",time8.);
	put '################ time used :' diff time8.;
run;

