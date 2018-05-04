/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : am_desc_sum.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : H3E-GH-B015|LY231514

DESCRIPTION               : generate global macro variable from a dataset
SOFTWARE/VERSION#         : SAS/Version 9
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a
BROAD-USE MODULES         : n/a

INPUT                     : n/a
OUTPUT                    : n/a

PROGRAM PURPOSE           : descriptive summary 
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
OUTDS               Required  Null       Output dataset
VAR                   Required  Null       variables to be analyzed
BYCLASS            Optional   Null       By variable except treatment group
TRTSORT           Required  Null       treatment group
DECIMAL            Optional   Null     The format of the variables(with decimal original value)--separate  by   if more than one analysis variable set to _auto_ if by default
VERBOSE             Required  1          Verbose mode is on or off.
DEBUG                 Required  0          Debug mode is on or off.

USAGE NOTES: n/a

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:


--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0  Ella Cheng          Original version of the code
  **eoh************************************************************************/
%macro am_desc_sum(inds=_default_,outds=_default_,var=_default_, byclass=_default_,
trtsort=_default_,decimal=_default_,verbose=_default_,debug=_default_);
%*=============================================================================;
%* Declare local and initialize macro variables                                ;
%*=============================================================================;
%local  options i j k _pda  dsid rc nobs numvar numdec numby  trtnum  __byclass;

%*==============================================================================;
%* Note: macrovariable  used to determine error conditions      ;
%*==============================================================================;
%local __er_am_desc_sum;
%let __er_am_desc_sum= 0;

%if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
  %let _pda = 0;
%end;
%else %do;
  %let _pda = 1;
%end;
%*=============================================================================;
%* Process parameters                                                          ;
%*=============================================================================;
%ut_parmdef(inds,,,_pdrequired=1,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%ut_parmdef(outds,,,_pdrequired=1,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%ut_parmdef(var,,,_pdrequired=1,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%ut_parmdef(byclass,,,_pdrequired=0,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%ut_parmdef(trtsort,,,_pdrequired=1,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%ut_parmdef(decimal,,,_pdrequired=0,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%ut_parmdef(verbose,1,_pdrequired=1,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%ut_parmdef(debug,0,_pdrequired=1,_pdmacroname=am_desc_sum,_pdabort=&_pda)
%*=============================================================================;
%* Save delete temporary datasets ;
%*=============================================================================;
%macro delete_temp;

  proc sql noprint;
    select count(memname) into :tempds
    from dictionary.tables  
    where libname='WORK' and substr(upcase(memname),1,4)="__AM";
  quit;

  %if &tempds > 0 and ^ &debug %then %do;
    proc datasets lib=work nolist;
      delete __am:;
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
%else %do;
  options mprint mlogic symbolgen;
%end;

%macro restore_env;
  %delete_temp;
  options &options;
%mend restore_env;

%restore_env;

%*=============================================================================;
%* Macro am_desc_sum: Check the logic of macro variabls               ;
%*=============================================================================;
%local nwords;
%let nwords=0;
%do %while(%qscan(&var,%eval(&nwords+1),%str( ))^=);
  %let nwords=%eval(&nwords+1);
  %local var&nwords;
  %let var&nwords=%qscan(&var,%eval(&nwords),%str( ));
%end;
%let numvar=&nwords;
%let nwords=0;
%do %while(%qscan(&decimal,%eval(&nwords+1),%str( ))^=);
  %let nwords=%eval(&nwords+1);
  %local dec&nwords;
  %let dec&nwords=%qscan(&decimal,%eval(&nwords),%str( ));
%end;
%let numdec=&nwords;
%if &numdec=0 %then %do;
%do i=1 %to &numvar;
   %local dec&i;
   %let dec&i=_auto_;
%end;
%let numdec=&numvar;
%end;
%if &numvar^=&numdec  and &numdec^=0 %then %do;
           %ut_errmsg(msg="The number of decimal is not equal to the number of variable",
                 type=error,print=0,macroname=am_desc_sum);
            %let  __er_am_desc_sum=1;
%end;

%let nwords=0;
%do %while(%qscan(&byclass,%eval(&nwords+1),%str( ))^=);
  %let nwords=%eval(&nwords+1);
  %local by&nwords;
  %let by&nwords=%qscan(&byclass,%eval(&nwords),%str( ));
%end;
%let numby=&nwords;

%*Check number of observations and variables;
%let dsid=%sysfunc(open(&inds,i));

%if &dsid %then
   %do;
      %let nobs=%sysfunc(attrn(&dsid,nobs));
        %if &nobs<=0 %then %do;
           %ut_errmsg(msg="There is not observation is dataset: &inds..",
                 type=note,print=0,macroname=am_desc_sum);
        %end;

      %do i=1 %to &numvar;
      %local __varnum&i;
      %let __varnum&i=%sysfunc(varnum(&dsid,&&var&i));
        %if &&__varnum&i <= 0 %then %do;
           %ut_errmsg(msg="&&var&i is not in the dataset: &inds.",
                 type=error,print=0,macroname=am_desc_sum);
             %let  __er_am_desc_sum=1;
        %end;
      %end;

      %let trtnum=%sysfunc(varnum(&dsid,&trtsort));
        %if &trtnum <= 0 %then %do;
           %ut_errmsg(msg="&trtsort is not in the dataset: &inds..",
                 type=error,print=0,macroname=am_desc_sum);
            %let  __er_am_desc_sum=1;
        %end;

    %if &byclass^= %then %do;
     %do i=1 %to &numby;
        %local __bynum&i;
        %let __bynum&i=%sysfunc(varnum(&dsid,&&by&i));
        %if &&__bynum&i <= 0 %then %do;
           %ut_errmsg(msg="&&by&i is not in the dataset: &inds..",
                 type=error,print=0,macroname=am_desc_sum);
            %let  __er_am_desc_sum=1;
        %end;
      %end;
     %end;


    %if &__er_am_desc_sum=1 %then %do;
       %let rc=%sysfunc(close(&dsid));
       %goto ut_stop;
    %end;
    %else %do;
     %do i=1 %to  &numvar; 
       %local num&i typ&i origfmt&i;
      %let num&i=%sysfunc(varnum(&dsid,&&var&i));
       %let typ&i=%sysfunc(vartype(&dsid,&&num&i))  ;
       %if &&typ&i = N %then %do;  %let origfmt&i=%sysfunc(varfmt(&dsid,&&num&i))  ; %end;
     %end;
     %let rc=%sysfunc(close(&dsid));
    %end;


%end;

*handling dataset;
%let __byclass  = %str( by &byclass &trtsort;);

proc sort data=&inds out=__am_desc_00;
  &__byclass;
run;

%do i=1 %to &numvar;
%local nfmt&i meanfmt&i medianfmt&i stdfmt&i minfmt&i maxfmt&i int&i decimal&i;
%if %upcase(&&dec&i)=_AUTO_ %then %do;
  %let dec&i=&&origfmt&i;
    %if &&dec&i=%then %do;
           %ut_errmsg(msg="&&var&i is not assigned a decimal format and it is not with a original format in the &inds",
                 type=error,print=0,macroname=am_desc_sum);
             %let  __er_am_desc_sum=1;  
             %goto ut_stop; 
    %end;
%end;
  %if %index(&&dec&i,%str(.))= %then %let dec&i=&&dec&i%str(.0);
  %let decimal&i=%qscan(&&dec&i,2,%str(.));
  %local alllen&i;
  %let alllen&i=%eval(8+1+&&decimal&i+2);
%let nfmt&i=%str(8.0);
%let meanfmt&i=%sysfunc(compress(%eval(8+(&&decimal&i^=0)+&&decimal&i+1)%str(.)%eval(&&decimal&i+1) ));
%let stdfmt&i=%sysfunc(compress(%eval(8+(&&decimal&i^=0)+&&decimal&i+2)%str(.)%eval(&&decimal&i+2) ));
%let medianfmt&i=%sysfunc(compress(%eval(8+(&&decimal&i^=0)+&&decimal&i+1)%str(.)%eval(&&decimal&i+1) ));
%let minfmt&i=%sysfunc(compress(%eval(8+(&&decimal&i^=0)+&&decimal&i)%str(.)&&decimal&i ));
%let maxfmt&i=%sysfunc(compress(%eval(8+(&&decimal&i^=0)+&&decimal&i)%str(.)&&decimal&i ));

proc means data=__am_desc_00 noprint;
  &__byclass;
  var &&var&i;
  output out=__am_desc_1_&i n=_n mean=_mean median=_median std=_std min=_min max=_max;
run;

data __am_desc_2_&i;
  set __am_desc_1_&i;
  attrib n format =$200. label='Number of patients'
          mean format= $200. label='Mean'
          median format=$200. label='Median'
          std format=$200. label='Standard deviation'
          min format=$200. label='Minimum'
          max format=$200. label='Maximum'
  ;
  n=put(_n,  &&nfmt&i);
  mean=put(_mean,&&meanfmt&i);
  median=put(_median,&&medianfmt&i);
  std=put(_std,&&stdfmt&i);
  min=put(_min,&&minfmt&i);
  max=put(_max,&&maxfmt&i);
  n=substr(n,1,&&alllen&i)||'  ';
  mean=substr(mean,1,&&alllen&i)||'  ';
  median=substr(median,1,&&alllen&i)||'  ';
  std=substr(std,1,&&alllen&i)||'  ';
  min=substr(min,1,&&alllen&i)||'  ';
  max=substr(max,1,&&alllen&i)||'  ';
  drop _freq_ _type_ _n _mean _median _std _max _min;
run;

proc transpose data=__am_desc_2_&i out=__am_desc_3_&i;
  %if &byclass^= %then %do; by &byclass; %end;
   id &trtsort;
   var n mean median std min max;
  run;
  data __am_desc_3_&i;
    set __am_desc_3_&i;
    length _var_ $20;
    _var_="&&var&i";
 run;
%end;
data &outds;
  length _var_ $20;
  set 
  %do i=1 %to &numvar; __am_desc_3_&i   %end;
  ;
run;

*post processing;
%ut_stop:;
%restore_env;
%mend am_desc_sum;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="34ec52c3:1403d721bb6:116a" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter id="INDS" resolution="INTERNAL" type="TEXT" order="1">*/
/*  </parameter>*/
/*  <parameter id="DSID" resolution="INTERNAL" type="TEXT" order="2">*/
/*  </parameter>*/
/*  <parameter id="RC" resolution="INTERNAL" type="TEXT" order="3">*/
/*  </parameter>*/
/*  <parameter id="NOBS" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="VERBOSE" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/*  <parameter id="DEBUG" resolution="INTERNAL" type="TEXT" order="6">*/
/*  </parameter>*/
/*  <parameter id="_PDA" resolution="INTERNAL" type="TEXT" order="7">*/
/*  </parameter>*/
/*  <parameter id="OPTIONS" resolution="INTERNAL" type="TEXT" order="8">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter id="J" resolution="INTERNAL" type="TEXT" order="10">*/
/*  </parameter>*/
/*  <parameter id="K" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter id="TEMPDS" resolution="INTERNAL" type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter id="__ER_am_desc_sum" resolution="INTERNAL" type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OUTDS" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="15" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VAR" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="16" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BYCLASS" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="17" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TRTSORT" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="18" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DECIMAL" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="19" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUMVAR" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="20" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUMDEC" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="21" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUMBY" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="22" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TRTNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="23" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__BYCLASS" maxlength="256"*/
/*   tabname="Parameters" processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="24" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NWORDS" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="25" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__VARNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="26" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BY" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="27" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__BYNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="28" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUM" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="29" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TYP" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="30" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEC" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="31" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ORIGFMT" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="32" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NFMT" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="33" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="MEANFMT" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="34" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="MEDIANFMT" maxlength="256"*/
/*   tabname="Parameters" processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="35" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="STDFMT" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="36" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="MINFMT" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="37" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="MAXFMT" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="38" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ALLLEN" maxlength="256" tabname="Parameters"*/
/*   processid="P2" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/