%macro am_count_bb(inds=_default_, freqvar=_default_, subjds=_default_, 
                   gen_spf=_default_, subgrp=_default_, outds=_default_,
                   verbose=_default_,debug=_default_);

/*soh***************************************************************************                                                        
Eli Lilly and Company - Global Statistical Sciences                                                                                     
CODE NAME           : am_count_bb                                                                                                   
CODE TYPE           : Broad-use Module                                                                                                  
PROJECT NAME        :                                                                                                                   
DESCRIPTION         : Calculate N,n and % for each category of categorical variable                                 
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows 
LIMITED-USE MODULES : N/A                                                                                                               
BROAD-USE MODULES   : ut_parmdef, ut_logical, ut_titlstrt, ut_errmsg                                                                    
INPUT               : SAS data set with categorical data                                                                   
OUTPUT              : SAS data set with the analysis results                                                            
VALIDATION LEVEL    : 6                                                                                                                 
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/                                                            
                      bums/am_count_bb/documentation/am_count_bb_rd.doc                                                         
ASSUMPTIONS         : input datasets complied with ADS  
--------------------------------------------------------------------------------                                                        
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:                                                                               
                                                                                                                                        
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _am                                                                                          
                                                                                                                                        
PARAMETERS:                                                                                                                             
Name       Type      Default   Description and Valid Values
---------- --------- --------- -------------------------------------------------
inds       required            input SAS data set, such as EVENTS                    
freqvar    required            list of categotical variables, such as PTERM. 
                               Frequency will be counted for each level of the 
                                combination of these variables. 
subjds     required            input SAS data set for obtaining total number of  
                                subjects, such as SUBJINFO
gen_spf    optional            A flag variable in input data (inds) to indicate  
                                gender specific events. Default is null.
subgrp     optional            list of subgroup variables, such as SEX. Frequency
                                will be counted within each level of the combination
                                of these variables. Default is null.   
outds      required            user defined name of an output SAS data set. 
VERBOSE    optional  1         %ut_logical value specifying whether verbose mode
                                is on or off. 1 for on and 0 for off.
                               Default is 1.
DEBUG      optional  0         %ut_logical value specifying whether debug mode 
                                is on or off. 1 for on and 0 for off.
                               Default is 0.
--------------------------------------------------------------------------------
Usage Notes: N/A

--------------------------------------------------------------------------------
Typical Macro Call(s) and Description:
  %am_count_bb(inds=events, freqvar=pterm, subjds=subjinfo,   
               gen_spf=gs_flag, subgrp=, outds=result);
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:                                                                                                               
                                                                                                                                        
     Author &                                                                                                                           
Ver# Peer Reviewer             Code History Description                                                                                       
---- ------------------------  -------------------------------------------------                                             
1.0  Shan Bai                  Original version of the broad-use module.
      Poonam Gulia                          
1.1  Shan Bai                  SAS version 9 migration  
      Michael Fredericksen  
2.0  Shan Bai                  Adding parameter description in header 
      Piruthiviraj Loganathan   for VERBOSE and DEBUG; 
                               Rename variable GEN_SPF to &gen_spf, 
                                then drop GEN_SPF;  
                               Adding step to delete all dataset
                                with name starting with _am at the
                                begining of the macro main logic;
                               Remove following statement:
                                "if trt=' ' then trtsort=0;" ;
                               Updated header.
2.1  Javeed Parrey             The Broad-use module is validated in SDD.
      Sanjay Kumar             Header updated.  
3.0  Craig Hansen              Updated header to reflect code validated for SAS v9.2.  
      Keyi Wu                   Modified header to maintain compliance with                                
                                current SOP Code Header.

4.0   Ella Cheng               Only updated for QA LUMS. Update proc datasets procedure to
      Thomas Guo               avoid "Not found" in log.BUMS ticket submitted. So after 
                               BUMS updates, this LUMS should be delted from QA/LUMS folder
                               02AUG2013 

                               The decision is to put it in LUMS because the following reply from BUMS supporting team on 07AUG2013
                                   "I agree the logic is not equal.  Instead of contains ?_AM? it should have been like ?_AM%?,
                                   however because of higher priority tasks currently going on I have been informed that we do not have the capacity or time 
                                   to go through the process of updating and validating this bum."
                               12AUG2013
**eoh**************************************************************************/

%ut_parmdef(inds,,_pdrequired=1,
            _pdmacroname=am_count_bb)
%ut_parmdef(freqvar,,_pdrequired=1,
            _pdmacroname=am_count_bb)
%ut_parmdef(subjds,,_pdrequired=1,
            _pdmacroname=am_count_bb)
%ut_parmdef(gen_spf,,_pdrequired=0,
            _pdmacroname=am_count_bb)
%ut_parmdef(subgrp,,_pdrequired=0,
            _pdmacroname=am_count_bb)
%ut_parmdef(outds,,_pdrequired=1,
            _pdmacroname=am_count_bb)
%ut_parmdef(verbose,1,_pdrequired=0,
            _pdmacroname=am_count_bb)
%ut_parmdef(debug,0,_pdrequired=0,
            _pdmacroname=am_count_bb)

%local titlstrt;
%ut_logical(verbose) 
%ut_logical(debug)
%ut_titlstrt

%if &debug %then %put (am_count_bb) macro starting;

%local option option1 option2;
%let option  = %sysfunc(getoption(mprint));
%let option1 = %sysfunc(getoption(mlogic));
%let option2 = %sysfunc(getoption(symbolgen));

options nomprint nomlogic nosymbolgen;
%if &verbose %then options mprint mlogic symbolgen;;

%*=============================================================================;
%* Inline macros to perform certain paramter validations:                      ;
%* Macro chk_ds: Checks that the dataset exists in the work library.           ;
%* Macro chk_var: Checks that the variable passed is present in the dataset.   ;
%*=============================================================================;

%*=============================================================================;
%* Macro chk_ds : Check for the existence of the required dataset              ;
%*=============================================================================;

%macro chk_ds(ds=);
  %let chk = %sysfunc(exist(&ds));
  %if &chk=0 %then 
    %ut_errmsg(msg=%sysfunc(compbl("The dataset %upcase(&ds) does not exist 
                   in the current SAS data library")),
               type=warning,print=0,macroname=am_count_bb);
%mend chk_ds;

%*=============================================================================;
%* Macro chk_var : Check for the existence of a variable in dataset            ;
%*=============================================================================;

%macro chk_var(ds=,var=);
  %local openid openrc closerc;
  %let openid=%sysfunc(open(&ds));
  %let openrc=%sysfunc(varnum(&openid,&var));
  %let closerc=%sysfunc(close(&openid));
  %if &openrc = 0 or &openrc = . %then
    %ut_errmsg(msg=%sysfunc(compbl("The variable %upcase(&var) does not exist
                   in the dataset %upcase(&ds)")),
               type=warning,print=0,macroname=am_count_bb);
%mend chk_var; 

%*=============================================================================;
%* Check if the required dataset exists in the SAS data library.               ;
%*=============================================================================;

%chk_ds(ds=&inds);

%chk_ds(ds=&subjds);

%*=============================================================================;
%* Check if the frequency variable exists in the dataset.                      ;
%*=============================================================================;
%local n i;

%* decide how many variables in &freqvar list;
%let n=1;
%do %while (%scan(&freqvar, &n) ne );
  %let n=%eval(&n + 1);
%end;

%do i=1 %to %eval(&n - 1);
  %let var=%scan(&freqvar, &i); 
  %chk_var(ds=&inds,var=&var);
%end;

%*=============================================================================;
%* Check if the subgrp variable exists in the dataset.                      ;
%*=============================================================================;
%if &subgrp ne %then %do;
  %local m k;
  %*------------------------------------------------------------------;
  %* decide how many variables in &subgrp list.                       ;
  %*------------------------------------------------------------------;
  %let m=1;
  %do %while (%scan(&subgrp, &m) ne );
   %let m=%eval(&m + 1);
  %end;

  %do k=1 %to %eval(&m - 1);
   %let varsub=%scan(&subgrp, &k); 
   %chk_var(ds=&inds,var=&varsub);
  %end;
%end;

%*=============================================================================;
%* Check if the trtsort variable exists in the dataset.                        ;
%*=============================================================================;

%chk_var(ds=&inds,var=trtsort);

%*=============================================================================;
%* Check if the gen_spf variable exists in the dataset.                        ;
%*=============================================================================;

%if &gen_spf ne %then %do;
  %chk_var(ds=&inds,var=&gen_spf);
%end;

%*=============================================================================;
%* BUM main processing logic follows                                           ;
%*=============================================================================;

%*=============================================================================;
%*   Delete temporary data sets if any                                         ;
%*=============================================================================;

proc sql noprint;
  select count(memname) into : dscount
  from dictionary.columns
  where libname='WORK' and 
  (substr(upcase(memname),1,3)="_AM");
quit;

%if &dscount > 0 %then %do;

 proc datasets lib=work nolist;
  delete _am:;
 run; 
quit;

%end;

%*===================================================================;
%* create local macro variables GENSPF, SUBGRPS and SUBGRP_SQL to    ;
%* pass value of parameters GEN_SPF and SUBGRP;                      ;
%* SUBGRPS and SUBGRP_SQL are in a format aimed for use in PROC SQL  ;
%*===================================================================;

%local genspf subgrps subgrp_sql;

%if &gen_spf= %then %let genspf=;
%else %let genspf=&gen_spf,;

%if &subgrp= %then %do;
 %let subgrps=;
 %let subgrp_sql=;
%end;

%else %do; 
 %let subgrps=%sysfunc(translate(&subgrp, ',',' '));
 %let subgrp_sql=&subgrps,;
%end;

%*===================================================================;
%* get denominator (N) for calculating percentage (%), including N   ;
%* for calculating gender specific event percentage                  ;
%*===================================================================;

%*-------------------------------------------------------------------;
%* create a data set with flag (GENSPFLG): A for all patient, M      ;
%* and F for each gender (when &gen_spf specified).                  ;
%*-------------------------------------------------------------------;

%if &gen_spf= %then %do; 
 data _am_subjds;
  set &subjds;
  genspflg='A';
 run;
%end;

%else %do;
 data _am_subjds;
  set &subjds(in=a) &subjds(in=b);
  if a then genspflg='A';
  if b then genspflg=sexsnm;
 run;
%end;

%*-------------------------------------------------------------------;
%* count big n (N)                                                   ;              
%*-------------------------------------------------------------------;
 proc sql;
   create table _am_trt_bn as
     select distinct &subgrp_sql trt, trtsort, genspflg, 
            count(distinct usubjid) as big_n
       from _am_subjds
     group by &subgrp_sql trt, genspflg;

   create table _am_total_bn as
    select &subgrp_sql "Total" as trt, genspflg, sum(big_n) as big_n
    from _am_trt_bn
    where trtsort < 99 
    group by &subgrp_sql genspflg;
 quit;

 data _am_bign;
  set _am_trt_bn _am_total_bn;
  if trt='Total' then trtsort=99;
 run;

%*==================================================================;
%* count frequency (n) of patients with event.                      ;
%*==================================================================;

%*-------------------------------------------------------------------;
%* create a master dataset with all events and therapy codes         ;
%* accounted for within all categories.                              ;
%*-------------------------------------------------------------------;
 %let freqvars=%sysfunc(translate(&freqvar, ',',' '));

 proc sql;
   create table _am_all as
     select distinct &freqvars, a.*
       from &inds, _am_bign as a;
 quit;

 proc sort data=_am_all;
   by &freqvar trt &subgrp genspflg;
 run;

%*------------------------------------------------------------------;
%* count frequency (n) in eventds                                   ;                    
%*------------------------------------------------------------------; 
 proc sql;
   create table _am_trt_sn as
     select distinct &freqvars, &subgrp_sql trt, trtsort, &genspf 
            count(distinct usubjid) as small_n 
       from &inds
       group by &freqvars, &subgrp_sql trt;

   create table _am_total_sn as
   select distinct &freqvars, &subgrp_sql "Total" as trt, &genspf 
            sum(small_n) as small_n 
     %if &subgrp= %then %do;
        from _am_trt_sn
        where trtsort < 99 
        group by &freqvars;
     %end;
     %else %do;
         from _am_trt_sn
         where trtsort < 99 
         group by &freqvars, &subgrps;
     %end;
 quit;

  data _am_cnt;
    set _am_trt_sn _am_total_sn;
    if trt='Total' then trtsort=99;
  run;

  proc sort data=_am_cnt;
    by &freqvar trt &subgrp;
  run;

 %if &gen_spf= %then %do; 
  data &outds;
    merge _am_all(where=(genspflg='A')) _am_cnt(in=a);
    by &freqvar trt &subgrp;
    if not a then small_n=0;
    pct=(small_n/big_n)*100;
    drop genspflg;
  run; 
 %end;

 %else %do;
  proc sort data=_am_cnt out=_am_cnt_1(keep=&freqvar &gen_spf) nodupkey;
    by &freqvar;
  run;

  data _am_all;
   merge _am_all _am_cnt_1(rename=(&gen_spf=gen_spf));
   by &freqvar;
   if genspflg=gen_spf;
  run;

  proc sort data=_am_all;
    by &freqvar trt &subgrp;
  run;

  data _am_final;
    merge _am_all _am_cnt(in=a);
    by &freqvar trt &subgrp;
    if not a then small_n=0;
    pct=(small_n/big_n)*100;
  drop genspflg &gen_spf;
  run; 

  data &outds;
    set _am_final;
    rename gen_spf=&gen_spf;
  run;

 %end;

%*=============================================================================;
%* Restoring the original environment                                          ;
%*=============================================================================;

options &option &option1 &option2;
 
%if ^ &debug %then %do;  
  proc datasets lib=work nolist;
    delete _am:;
  run; 
  quit;
%end;

%mend am_count_bb;



/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="29a34107:1406fe2f962:-1fbe" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="INDS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="FREQVAR" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SUBJDS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="GEN_SPF" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SUBGRP" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OUTDS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VERBOSE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEBUG" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OPTION" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OPTION1" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="11" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OPTION2" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="CHK" resolution="INTERNAL" type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VAR" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="15" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OPENID" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="16" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OPENRC" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="17" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CLOSERC" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="18" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="N" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Numeric field" protect="N" obfuscate="N" minimum="-9999999" maximum="9999999" order="19" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="I" tabname="Parameters"*/
/*   processid="P1" numtype="real" type="NUMERIC">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="20" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="M" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Numeric field" protect="N" obfuscate="N" minimum="-9999999" maximum="9999999" order="21" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="K" tabname="Parameters"*/
/*   processid="P1" numtype="real" type="NUMERIC">*/
/*  </parameter>*/
/*  <parameter id="VARSUB" resolution="INTERNAL" type="TEXT" order="22">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="23" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DSCOUNT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="24" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="GENSPF" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="25" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SUBGRPS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="26" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SUBGRP_SQL" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="FREQVARS" resolution="INTERNAL" type="TEXT" order="27">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/