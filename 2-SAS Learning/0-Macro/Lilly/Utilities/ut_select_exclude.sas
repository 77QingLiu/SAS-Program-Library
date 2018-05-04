%macro ut_select_exclude(data=_default_,variable=_default_,select=_default_,
 exclude=_default_,out=_default_,verbose=_default_,debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_select_exclude
CODE TYPE           : Broad-Use Module
PROJECT NAME        :
DESCRIPTION         : Supports the SELECT and EXCLUDE parameters of other macros
                      Subsets a data set to include observations where a
                       specified variable has values as defined in the
                       SELECT and EXCLUDE parameters.
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : ut_parmdef, ut_logical, ut_titlstrt, ut_marray, ut_errmsg
INPUT               : as defined by the parameter DATA
OUTPUT              : as defined by the parameter OUT
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/ut_select_exclude/documentation/ut_select_exclude_rd.doc
ASSUMPTIONS         :
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _sx

PARAMETERS:
Name      Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
DATA      required            1 or  2 level data set name to be subsetted
VARIABLE  required            Name of variable in DATA used to define the
                               subsetting
SELECT    optional            List of values of VARIABLE to select observations
EXCLUDE   optional            List of values of VARIABLE to delete observations
OUT       required DATA       1 or 2 level data set name to write the subsetted
                               DATA data set to.  The default value is DATA,
                               that is the input DATA data set will be replaced.
VERBOSE   required 1          ut_logical value specifying whether verbose mode
                               is on or off
DEBUG     required 0          ut_logical value specifying whether debug mode in
                               on or off.  DEBUG should be turned on only when
                               the macro author is diagnosing a problem with
                               the macro.

USAGE NOTES:

User is required at a minimum to enter a dataset to be subsetted (DATA) and the variable to be
subset on (VARIABLE). Values supplied for SELECT and EXCLUDE determine what values are retained
in the output dataset (OUT). Note that SELECT and EXCLUDE subsets are independent; if the same value(s)
are supplied in both the SELECT and EXCLUDE parameters, the value will be included in the output dataset.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION:
%ut_select_exclude(data=mydata, variable=country, select=USA, exclude=, out=mysubset);
-Selects observations from 'mydata' with a value of 'USA' for the variable 'country' and retains them in the
output dataset 'mysubset'.

  	----------------------------------------------------------------------------------------
    	    Author &                              Broad-Use MODULE History
  	Ver#  Peer Reviewer       Request #  	          Description
  	----  ---------------- -------------------  --------------------------------------------
    1.0   Michael Carter   BMRKC18AUG2009f      Original Version of the code
          Melinda Rodgers

    2.0   Michael Carter   BMRKC08FEB2010       Version 2 of the code
          Melinda Rodgers

    3.0   Chuck Bininger & BMRCB24MAR2011       Update header to reflect code validated
          Shong Demattos                        for SAS v9.2.  Modified header to maintain
                                                compliance with current SOP Code Header.


**eoh****************************************************************************/




%*=============================================================================;
%* Process parameters and initialize;
%*=============================================================================;
%ut_parmdef(data,_pdmacroname=ut_select_exclude,_pdrequired=1)
%ut_parmdef(variable,_pdmacroname=ut_select_exclude,_pdrequired=1)
%ut_parmdef(select,_pdmacroname=ut_select_exclude,_pdrequired=0)
%ut_parmdef(exclude,_pdmacroname=ut_select_exclude,_pdrequired=0)
%ut_parmdef(out,&data,_pdmacroname=ut_select_exclude,_pdrequired=1)
%ut_parmdef(verbose,1,_pdmacroname=ut_select_exclude,_pdrequired=1)
%ut_parmdef(debug,0,_pdmacroname=ut_select_exclude,_pdrequired=1)
%ut_logical(verbose)
%ut_logical(debug)

%local titlstrt elements selnum numsels exclnum numexcls dsid varnum vartype
 varlen num_obs;
%ut_titlstrt
%ut_marray(invar=select,outvar=sel,outnum=numsels,varlist=elements)
%local &elements;
%ut_marray(invar=select,outvar=sel,outnum=numsels)
%ut_marray(invar=exclude,outvar=excl,outnum=numexcls,varlist=elements)
%local &elements;
%ut_marray(invar=exclude,outvar=excl,outnum=numexcls)

%if %bquote(&out) = %then %do;
  %ut_errmsg(msg="terminating ut_select_exclude",
             macroname=ut_select_exclude,type=error,debug=&debug);
  %goto endmac;
%end;

%if %bquote(&select) ^= | %bquote(&exclude) ^= %then %do;
  %*===========================================================================;
  %* Determine the type and length of VARIABLE in DATA;
  %*===========================================================================;
  %let dsid = 0;
  %if %bquote(&data) ^= %then %do;
    %let dsid = %sysfunc(open(&data,i));
  %end;

  %if &dsid > 0 %then %do;
    %let varnum = %sysfunc(varnum(&dsid,&variable));
    %if &varnum > 0 %then %do;
      %let vartype = %upcase(%sysfunc(vartype(&dsid,&varnum)));
      %if &vartype = C %then %let vartype = $;

      %let varlen  = %sysfunc(varlen(&dsid,&varnum));
    %end;
    %else %do;
      %ut_errmsg(msg="variable &variable does not exist in data set &data",
                 macroname=ut_select_exclude,type=warning,debug=&debug);
      %ut_errmsg(msg="terminating ut_select_exclude",
                 macroname=ut_select_exclude,type=warning,debug=&debug);

      %let dsid = %sysfunc(close(&dsid));
      %goto endmac;
    %end;

    %let num_obs = %sysfunc(attrn(&dsid,nobs));
    %let dsid = %sysfunc(close(&dsid));
  %end;
  %else %do;
    %ut_errmsg(msg="cannot open &data to determine type of &variable",
               macroname=ut_select_exclude,type=warning,debug=&debug);
    %ut_errmsg(msg="terminating ut_select_exclude",
               macroname=ut_select_exclude,type=warning,debug=&debug);
    %goto endmac;
  %end;

  %if &vartype ^= $ %then %do;
    ** Verify none of the values in select contain non numeric values **;
    %let curVal =;
    %let val_cnt = 1;
    %do %while (%scan(%bquote(&select), &val_cnt., %str() %str(,)) ^= %str());
      %let curVal = %scan(%bquote(&select), &val_cnt., %str() %str(,));
      %let val_cnt = %eval (&val_cnt. + 1);

      %if %datatyp(&curVal) ^= NUMERIC %then %do;
        %ut_errmsg(msg=The value &curVal supplied for the SELECT parameter contains character values which cannot be applied to the numeric variable &variable,
                   type=warning, macroname=ut_select_exclude,print=0);

        %goto endmac;
      %end;
    %end;

    ** Verify none of the values in exclude contain non numeric values **;
    %let curVal =;
    %let val_cnt = 1;
    %do %while (%scan(%bquote(&exclude), &val_cnt., %str() %str(,)) ^= %str());
      %let curVal = %scan(%bquote(&exclude), &val_cnt., %str() %str(,));
      %let val_cnt = %eval (&val_cnt. + 1);

      %if %datatyp(&curVal) ~= NUMERIC %then %do;
        %ut_errmsg(msg=The value &curVal supplied for the EXCLUDE parameter contains character values which cannot be applied to the numeric variable &variable,
                   type=warning, macroname=ut_select_exclude,print=0);

        %goto endmac;
      %end;
    %end;
  %end;

  %if &verbose %then %do;
    *==========================================================================;
    %bquote(* Report whether &variable is both selected and excluded);
    *==========================================================================;
    data _sx_select_exclude;
      length variable_value &vartype &varlen  select_exclude $ 7;
      %if &numsels > 0 %then %do selnum = 1 %to &numsels;
        variable_value = lowcase("&&sel&selnum");
        select_exclude = "select";
        output;
      %end;
      %if &numexcls > 0 %then %do dsn_num = 1 %to &numexcls;
        variable_value = lowcase("&&excl&dsn_num");
        select_exclude = "exclude";
        output;
      %end;
    run;
    proc sort;
      by variable_value select_exclude;
    run;
    data _sx_selectandexclude_nodups _sx_selectandexclude_dups;
      set _sx_select_exclude;
      by variable_value;
      if first.variable_value + last.variable_value ^= 2 then
       output _sx_selectandexclude_dups;
      if last.variable_value then output _sx_selectandexclude_nodups;
    run;
    proc print data = _sx_selectandexclude_dups;
      title%eval(&titlstrt + 1)
       "(ut_select_exclude) duplicates in select and exclude parameter values";
      title%eval(&titlstrt + 2) "(ut_select_exclude) "
       "Values both selected and excluded will be selected";
    run;
    title%eval(&titlstrt + 1);

    %if ^ &debug %then %do;
      proc datasets lib=work nolist;
       delete _sx:;
      run; quit;
    %end;

  %end;
  *============================================================================;
  * Apply select and exclude list to DATA and write result to OUT;
  *============================================================================;
  %local selectq excludeq condition;
  %if &vartype = $ %then %do;
    %if %bquote(&select) ^= %then %do;
      %ut_quote_token(inmvar=select,outmvar=selectq)
      %let selectq = %sysfunc(lowcase(&selectq));
    %end;
    %if %bquote(&exclude) ^= %then %do;
      %ut_quote_token(inmvar=exclude,outmvar=excludeq)
      %let excludeq = %sysfunc(lowcase(&excludeq));
    %end;

  %if %bquote(&selectq) ^= %then %do;
    %let condition = %str(lowcase(&variable) in) (&selectq);
  %end;
    %if %bquote(&excludeq) ^= %then %do;
    %if %bquote(&selectq) ^= %then %do;
      %let condition = &condition |;
      %end;
    %let condition = &condition %str(lowcase(&variable) ^ in) (&excludeq);
    %end;
  %end;

%*numeric select var;
  %else %do;
    %let selectq = &select;
    %let excludeq = &exclude;

    %if %bquote(&selectq) ^= %then %do;
      %let condition = %str(&variable in) (&selectq);
    %end;
    %if %bquote(&excludeq) ^= %then %do;
      %if %bquote(&selectq) ^= %then %do;
        %let condition = &condition |;
      %end;
      %let condition = &condition %str(&variable ^ in) (&excludeq);
    %end;
  %end;

  data &out;
    set &data (where = (&condition));
  run;
  %ut_errmsg(msg=The number of observations in &data is &num_obs,type=note,
   macroname=ut_select_exclude,print=0)
%end;
%else %do;
  %if %bquote(%upcase(&data)) ^= %bquote(%upcase(&out)) %then %do;
    *==========================================================================;
    * Copy DATA to OUT if SELECT or EXCLUDE are not specified;
    *==========================================================================;
    data &out;
      set &data;
    run;
  %end;
%end;

%endmac:


title&titlstrt;
%mend;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="ac3c11:126b864bcc3:428" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DATA" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VARIABLE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SELECT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="EXCLUDE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OUT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VERBOSE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEBUG" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TITLSTRT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ELEMENTS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SELNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="11" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUMSELS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUMEXCLS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DSID" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VARNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="15" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VARTYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="16" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="VARLEN" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="17" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUM_OBS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="18" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SEL" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="19" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="EXCL" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="20" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DSN_NUM" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="21" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SELECTQ" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="22" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="EXCLUDEQ" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="23" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CONDITION" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="CURVAL" resolution="INTERNAL" type="TEXT" order="24">*/
/*  </parameter>*/
/*  <parameter id="VAL_CNT" resolution="INTERNAL" type="TEXT" order="25">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/