/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : ut_dfmac.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : H3E-GH-B015|LY231514

DESCRIPTION               : generate global macro variable from a dataset
SOFTWARE/VERSION#         : SAS/Version 9
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a
BROAD-USE MODULES         : n/a

INPUT                     : n/a
OUTPUT                    : n/a

PROGRAM PURPOSE           : generate macro variable 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : n/a
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name                 Type     Default    Description and Valid Values
---------            -------- ---------- --------------------------------------------------
INDS                  Required  Null       Input dataset 
NAMECOL               Requored  Null       Name column in the input dataset
VALUECOL              Required  Null       Value column in the input dataset
ALLNUM                Optional  __total    The name of macrovariable for total number of records in input dataset
CATCOL                Optional  Null       Category column in the input dataset
LOCATION              Optional  G          The location used in call symputx 
VERBOSE               Required  1          Verbose mode is on or off.
DEBUG                 Required  0          Debug mode is on or off.

USAGE NOTES: n/a

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:
%ut_dfmac(inds=t4_count,namecol=_label,valuecol=trt, allnum=,location=G);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0  Ella Cheng          Original version of the code
2.0  Ella Cheng          Modify the code to comply BUMS development rule
  **eoh************************************************************************/
%macro ut_dfmac(inds=_default_,namecol=_default_,valuecol=_default_, allnum=_default_,
catcol=_default_,location=_default_,verbose=_default_,debug=_default_);
%*=============================================================================;
%* Declare local and initialize macro variables                                ;
%*=============================================================================;
%local dsid rc nobs namenum valuenum catnum nametyp valuetyp cattyp namefmt valuefmt catfmt
       options i j k tempds  viewoutputon viewoutputoff _pda;
%let nobs=0;
%let namenum=0;
%let valuenum=0;
%let catnum=0;
%*==============================================================================;
%* Note: macrovariable  used to determine error conditions      ;
%*==============================================================================;
%local __er_ut_dfmac;
%let __er_ut_dfmac = 0;

%if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
  %let _pda = 0;
%end;
%else %do;
  %let _pda = 1;
%end;
%*=============================================================================;
%* Process parameters                                                          ;
%*=============================================================================;
%ut_parmdef(inds,,,_pdrequired=1,_pdmacroname=ut_dfmac,_pdabort=&_pda)
%ut_parmdef(namecol,,,_pdrequired=1,_pdmacroname=ut_dfmac,_pdabort=&_pda)
%ut_parmdef(valuecol,,,_pdrequired=1,_pdmacroname=ut_dfmac,_pdabort=&_pda)
%ut_parmdef(allnum,___total,,_pdrequired=0,_pdmacroname=ut_dfmac,_pdabort=&_pda)
%ut_parmdef(catcol,,,_pdrequired=0,_pdmacroname=ut_dfmac,_pdabort=&_pda)
%ut_parmdef(location,G,,_pdrequired=0,_pdmacroname=ut_dfmac,_pdabort=&_pda)
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=ut_dfmac,_pdabort=&_pda)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=ut_dfmac,_pdabort=&_pda)

%if &debug %then %do;
    %put (df_mac) macro starting;
    %let viewoutputon = ;
    %let viewoutputoff  = ;
%end;

%if ^ &debug %then %do;
    %let viewoutputon = %str(ODS LISTING;);
    %let viewoutputoff  = %str(ODS LISTING CLOSE;);
%end;

%*=============================================================================;
%* Macro to delete the temporary datasets									   ;
%*=============================================================================;
%macro delete_temp;

  proc sql noprint;
    select count(memname) into :tempds
    from dictionary.tables
    where libname='WORK' and substr(memname,1,3)="_AD";
  quit;

  %if &tempds > 0 and ^ &debug %then %do;
    proc datasets lib=work nolist;
      delete _AD:;
    quit;
  %end;

%mend delete_temp;
%*=============================================================================;
%* Save the initial values of the user specified SAS Macro options             ;
%*=============================================================================;

%let options = %sysfunc(getoption(mprint)) %sysfunc(getoption(mlogic)) %sysfunc(getoption(symbolgen));

%if ^ &debug %then %do;
  options nomprint nomlogic nosymbolgen;
%end;

%macro restore_env;
	%delete_temp;
	options &options;
%mend restore_env;

%restore_env;
%ut_titlstrt;
%*=============================================================================;
%* Macro ut_dfmac: Check the logic of macro variabls               ;
%*=============================================================================;/*Check required macro variable*/

%if &catcol^= and &catcol=&namecol %then %do;
      %ut_errmsg(msg="CATCOL could not be equal to NAMECOL. Please do not add CATCOL if not needed.;",
                 type=error,print=0,macroname=ut_dfmac);
      %let  __er_ut_dfmac=1;
%end;
%*Check number of observations and variables;
%let dsid=%sysfunc(open(&inds,i));
%if &dsid %then
   %do;
      %let nobs=%sysfunc(attrn(&dsid,nobs));
        %if &nobs<=0 %then %do;
           %ut_errmsg(msg="There is not observation is dataset: &inds..",
                 type=error,print=0,macroname=ut_dfmac);
            %let  __er_ut_dfmac=1;
        %end;
      %let namenum=%sysfunc(varnum(&dsid,&namecol));
        %if &namenum <= 0 %then %do;
           %ut_errmsg(msg="&namecol is not in the dataset: &inds.",
                 type=error,print=0,macroname=ut_dfmac);
             %let  __er_ut_dfmac=1;
        %end;
      %let valuenum=%sysfunc(varnum(&dsid,&valuecol));
        %if &valuenum <= 0 %then %do;
           %ut_errmsg(msg="&valuecol is not in the dataset: &inds..",
                 type=error,print=0,macroname=ut_dfmac);
            %let  __er_ut_dfmac=1;
        %end;
      %if &catcol^= %then %let catnum=%sysfunc(varnum(&dsid,&catcol));
        %if &catcol^= and &catnum <= 0 %then %do;
           %ut_errmsg(msg="&catcol is not in the dataset: &inds..",
                 type=error,print=0,macroname=ut_dfmac);
            %let  __er_ut_dfmac=1;
        %end;
    %if &__er_ut_dfmac=1 %then %do;
       %let rc=%sysfunc(close(&dsid));
       %goto ut_stop;
    %end;
    %else %do;
       %let nametyp=%sysfunc(vartype(&dsid,&namenum))  ;
       %let valuetyp=%sysfunc(vartype(&dsid,&valuenum))  ;
       %if &catcol^= %then %let cattyp=%sysfunc(vartype(&dsid,&catnum))  ;
       %if &nametyp = N %then %do;
           %let namefmt=%sysfunc(varfmt(&dsid,&namenum))  ;
           %if &namefmt= %then %let namefmt=%str(best.);
       %end;
       %if &valuetyp = N %then %do;
            %let valuefmt=%sysfunc(varfmt(&dsid,&valuenum))  ;
            %if &valuefmt= %then %let valuefmt=%str(best.);
       %end;
       %if &catcol^= and &cattyp = N %then %do;
            %let catfmt=%sysfunc(varfmt(&dsid,&catnum))  ;  
            %if &catfmt= %then %let catfmt=%str(best.);
       %end;
       %let rc=%sysfunc(close(&dsid));
    %end;
%end;
*handling dataset;
proc sort data=&inds out=__ut_stop__;
   by &catcol &namecol &valuecol;
run;

data _null_;
  %if &nametyp=C %then %do;
    length &namecol $200;
  %end;
  set __ut_stop__ nobs=nobs end=eof;
  by &catcol &namecol &valuecol;
  %if &catcol^=%then %do;
  retain __nobs;
  if first.&catcol then __nobs=0;
  __nobs+1;
  %end;
  %if &nametyp=C %then %do;
     if anydigit(&namecol)=1 then &namecol='_'||left(&namecol);
  %end;
  %if &nametyp=N and &valuetyp=N %then %do;
    call symputx('_'||put(&namecol,&namefmt -l),put(&valuecol,&valuefmt),"&location");
  %end;
  %if &nametyp=N and &valuetyp=C %then %do;
    call symputx('_'||put(&namecol,&namefmt -l),&valuecol,"&location");
  %end;
  %if &nametyp=C and &valuetyp=N %then %do;
    call symputx(&namecol,put(&valuecol,&valuefmt),"&location");
  %end;
  %if &nametyp=C and &valuetyp=C %then %do;
    call symputx(&namecol,&valuecol,"&location");
  %end;
  %if &allnum^= %then %do;
     if eof then call symputx("&allnum",put(nobs,best. -l),"&location");
  %end;
   %if &catcol^=  %then %do;
     %if &cattyp=N %then %do;
         if last.&catcol then call symputx('_tot'||put(&catcol,&catfmt -l),put(__nobs,best. -l),"&location");
     %end;
     %if &cattyp=C %then %do;
        if last.&catcol then call symputx('_tot'||trim(left(&catcol)),put(__nobs,best. -l),"&location");
     %end;
  %end; 
run;
*post processing;
proc datasets nolist lib=work;
  delete __ut_stop__;
run;
quit;
%ut_stop:;
%restore_env;

%mend ut_dfmac;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="eb2756:13e17128f43:-470d" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter id="INDS" resolution="INTERNAL" type="TEXT" order="1">*/
/*  </parameter>*/
/*  <parameter id="NAMECOL" resolution="INTERNAL" type="TEXT" order="2">*/
/*  </parameter>*/
/*  <parameter id="VALUECOL" resolution="INTERNAL" type="TEXT" order="3">*/
/*  </parameter>*/
/*  <parameter id="ALLNUM" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="CATCOL" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/*  <parameter id="DSID" resolution="INTERNAL" type="TEXT" order="6">*/
/*  </parameter>*/
/*  <parameter id="RC" resolution="INTERNAL" type="TEXT" order="7">*/
/*  </parameter>*/
/*  <parameter id="NOBS" resolution="INTERNAL" type="TEXT" order="8">*/
/*  </parameter>*/
/*  <parameter id="NAMENUM" resolution="INTERNAL" type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter id="VALUENUM" resolution="INTERNAL" type="TEXT" order="10">*/
/*  </parameter>*/
/*  <parameter id="CATNUM" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter id="NAMETYP" resolution="INTERNAL" type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter id="VALUETYP" resolution="INTERNAL" type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter id="CATTYP" resolution="INTERNAL" type="TEXT" order="14">*/
/*  </parameter>*/
/*  <parameter id="NAMEFMT" resolution="INTERNAL" type="TEXT" order="15">*/
/*  </parameter>*/
/*  <parameter id="VALUEFMT" resolution="INTERNAL" type="TEXT" order="16">*/
/*  </parameter>*/
/*  <parameter id="CATFMT" resolution="INTERNAL" type="TEXT" order="17">*/
/*  </parameter>*/
/*  <parameter id="LOCATION" resolution="INTERNAL" type="TEXT" order="18">*/
/*  </parameter>*/
/*  <parameter id="VERBOSE" resolution="INTERNAL" type="TEXT" order="19">*/
/*  </parameter>*/
/*  <parameter id="DEBUG" resolution="INTERNAL" type="TEXT" order="20">*/
/*  </parameter>*/
/*  <parameter id="SYSSCP" resolution="INTERNAL" type="TEXT" order="21">*/
/*  </parameter>*/
/*  <parameter id="_PDA" resolution="INTERNAL" type="TEXT" order="22">*/
/*  </parameter>*/
/*  <parameter id="OPTIONS" resolution="INTERNAL" type="TEXT" order="23">*/
/*  </parameter>*/
/*  <parameter id="VIEWOUTPUTON" resolution="INTERNAL" type="TEXT" order="24">*/
/*  </parameter>*/
/*  <parameter id="VIEWOUTPUTOFF" resolution="INTERNAL" type="TEXT" order="25">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="26">*/
/*  </parameter>*/
/*  <parameter id="J" resolution="INTERNAL" type="TEXT" order="27">*/
/*  </parameter>*/
/*  <parameter id="K" resolution="INTERNAL" type="TEXT" order="28">*/
/*  </parameter>*/
/*  <parameter id="TEMPDS" resolution="INTERNAL" type="TEXT" order="29">*/
/*  </parameter>*/
/*  <parameter id="__ER_UT_DFMAC" resolution="INTERNAL" type="TEXT" order="30">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/