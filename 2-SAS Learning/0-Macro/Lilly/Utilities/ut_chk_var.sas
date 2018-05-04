%macro ut_chk_var( dslist=, varlist=, type=, debug=0 );
/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME            : ut_chk_var.sas
CODE TYPE            : Broad Use Module
PROJECT              :
DESCRIPTION          : Verify 1) that variables, if specified, have valid names,
                       2) that variables, if specified, exist in the specified
                       datasets, and 3) that the variable, if specified, is of the
                       specified type.
SOFTWARE/VERSION#    : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE       : SDD v3.4 and MS Windows
LIMITED-USE MODULES  : N/A
BROAD-USE MODULES    : /lillyce/prd/general/bums/macro_library/ut_parmdef
                       /lillyce/prd/general/bums/macro_library/ut_logical
                       /lillyce/prd/general/bums/macro_library/ut_errmsg
                       /lillyce/prd/general/bums/macro_library/ut_dupword
                       /lillyce/prd/general/bums/macro_library/ut_chk_ds
                       /lillyce/prd/general/bums/macro_library/ut_findvar
INPUT                : N/A
OUTPUT               : N/A
VALIDATION LEVEL     : 6
REQUIREMENTS         : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums
                       ut_chk_var/documentation/ut_chk_var_rd.doc
ASSUMPTIONS          : N/A
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _AK
PARAMETERS:
Name      Type     Default    Description and Valid Values
--------- -------- ---------- --------------------------------------------------
DSLIST   optional  null       space-delimited list of datasets in which to
                              verify the existence of the VARLIST variables, if
                              specified.
VARLIST  optional  null       space-delimited list of variables.
TYPE     optional  null       type for variables in the list, if specified. Valid
                              values are null, N, NUM, NUMERIC, C, CHAR, or
                              CHARACTER (not case-sensitive). If non-null, the
                              variable must be in the dataset and match the type.
                              If null, the variable must simply be in the dataset.
DEBUG    required  0          A valid value to %ut_logical, to indicate whether or
                              not to produced DEBUG output.
--------------------------------------------------------------------------------
USAGE NOTES:

This macro is to be used outside of a data step or procedure.

The purpose of UT_CHK_VAR is to check 1) that variables, if specified, have valid
names, 2) that variables, if specified, exist in the all of the specified
datasets, and 3) that the variable, if specified, is of the specified type.

If any violations are detected, the module sets global macro variable ERROR_STATUS
to 1, regardless of the value or existence of the macro variable prior to
execution, and issues an appropriate message. If no violations are detected,
the value of global macro variable ERROR_STATUS remains unchanged if it exists,
or is created with a value of 0 if it does nto exist prior to execution.

There cannot be a local macro variable called ERROR_STATUS when the module is called.

To allow maximum flexibility in the calling program, the user is not required to
specify any dataset names, variable names, or type. If these parameters are not
specified, the macro will run without errors, and no error condition will result.
--------------------------------------------------------------------------------
TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION

%u_chk_var( dslist=inds.ecg subjds, varlist=usubjid treatment, type=char, debug=0);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen      BMRCSH09NOV2009B     Original version of the code
       Melinda Rodgers

 2.0   Craig Hansen      BMRMKC07SEP2010B     Limit the restoration of system
       Melinda Rodgers                        options to only those options that
                                              are potentially altered during the
                                              execution of the module, namely,
                                              MPRINT, MLOGIC, and SYMBOLGEN.

 3.0   Chuck Bininger &  BMRCB29MAR2011C      Update header to reflect code validated
       Shong Demattos                         for SAS v9.2.  Modified header to maintain
                                              compliance with current SOP Code Header.

**eoh************************************************************************/


%*==============================================================================;
%* Declare local and initialize macro variables                                 ;
%*==============================================================================;
%local _pfx _flag_overall _flagi __ak_temp __i __j __ds __var __result
      ds ds_lib ds_ds sdd ;
%local i _pda ;
%*==============================================================================;
%* Set prefix assigned to this module                                           ;
%*==============================================================================;
%let _pfx = _ak;

%*==============================================================================;
%* Delete temporary datasets to prevent contamination from previous runs        ;
%*==============================================================================;
data &_pfx.dummy;
run;
proc datasets lib=work nolist;
  delete &_pfx:;
run;

%*=============================================================================;
%* Save the initial values of the SAS system options                           ;
%*=============================================================================;
proc optsave out=&_pfx.optsave;
run;

%*==========================================================================;
%*                                                                          ;
%*                         BEGIN PARAMETER CHECKS                           ;
%*                                                                          ;
%*==========================================================================;

%*===========================================================================;
%* Get Platform information for which BUM is executing                       ;
%*===========================================================================;
%if %symglobl(_sddusr_) | %symglobl(_sddprc_) | %symglobl(sddparms) %then %let sdd = 1;
                                                                    %else %let sdd = 0;
%if %upcase(%nrbquote(&sysscp)) = WIN %then %let _pda = 0;
                                      %else %let _pda = 1;

%*==============================================================================;
%* Process parameters                                                           ;
%*==============================================================================;
%ut_parmdef(dslist,,,      _pdrequired=0, _pdmacroname=ut_chk_var, _pdabort=&_pda)
%ut_parmdef(varlist,,,     _pdrequired=0, _pdmacroname=ut_chk_var, _pdabort=&_pda)
%ut_parmdef(type,,C CHAR CHARACTER N NUM NUMERIC,
                           _pdrequired=0, _pdmacroname=ut_chk_var, _pdabort=&_pda)
%ut_parmdef(debug,0,,      _pdrequired=1, _pdmacroname=ut_chk_var, _pdabort=&_pda)
;
%if %symglobl(error_status) %then %do;
  %if %bquote(&error_status) = 1 %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("An invalid condition has been detected. The macro will
                                    stop executing.")),
                    type=error,print=0,macroname=ut_chk_ds);
    %return;
  %end;
%end;

%let _ak_type = %upcase( &type );
%if &_ak_type=C or &_ak_type=CHAR %then %let _ak_type = CHARACTER ;
%else %if &_ak_type=N or &_ak_type=NUM %then %let _ak_type = NUMERIC ;

%** Verify there are no duplicate variable names **;
%if %ut_dupword(&varlist)=1 %then %do;
  %ut_errmsg(msg="The value passed in for VARLIST contains a duplicate variable name.",
                  type=warning, print=0, macroname=ut_chk_var);
%end;

%* check for valid values of DEBUG. null gives message *;
%ut_logical( debug );
%if &debug^=1 and &debug^=0 %then %return ;
%if &debug=0 %then %do;
  options nomprint nomlogic nosymbolgen;
%end;

%* %ut_chk_var will check DSLIST, set ERROR_STATUS to 1 and produce a             *;
%* note/warning/error message,  if at least one of the datasets does not exist.   *;
%* Also if at least one of the dataset names is invalid. And if there are any     *;
%* duplicates in DSLIST. ---------------------------------------------------------*;
%ut_chk_ds( dslist=&dslist, required_YN=Y, debug=&debug );

%** Verify ERROR_STATUS does not exist as a local macrovariable **;
%if %symlocal(error_status) %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("ERROR_STATUS cannot exist as a local macrovariable
                                  when UT_CHK_VAR is executed.")),
                  type=error,print=0,macroname=ut_chk_var);
  %return;
%end;

%*==========================================================================;
%*                                                                          ;
%*                    BEGIN BUM MAIN PROCESSING SECTION                     ;
%*                                                                          ;
%*==========================================================================;

%* Look for all the variables in all the datasets. --------------------------------*;
%let _flag_overall = 0 ;
%let __j = 1 ;
%let __var = %qscan( &varlist,1,%str( ) );
%do %while (&__var^=) ;
    %* is this a valid variable name? *;
    %* not valid *;
    %if ^%sysfunc(nvalid(&__var)) %then %do ;
        %ut_errmsg( msg="%qupcase(&__var) is an invalid SAS variable name.",
                    type=error, print=0, macroname=ut_chk_var );
        %let _flag_overall = 0 ;
    %end ;
    %else %do ;
        %* valid, go through all the datasets *;
        %let __i = 1 ;
        %let __ds = %qscan( &dslist,1,%str( ) );
        %do %while (&__ds^=) ;
            %let __result = %ut_findvar( &__ds,&__var,&type );
            %if &__result=0 %then %let __notype = %ut_findvar( &__ds,&__var );
            %if &__result=0 %then %do ;
                %if &__notype=0 %then %do ;
                    %ut_errmsg(msg="Variable %qupcase(&__var) is not found in dataset %qupcase(&__ds).",
                               type=error, print=0, macroname=ut_chk_var );
                %end ;
                %else %do ;
                    %ut_errmsg(msg=%sysfunc(compbl("Variable %upcase(&__var) is found in dataset %qupcase(&__ds)
                               but is not a %qupcase(&_ak_type) variable.")), type=error, print=0, macroname=ut_chk_var );
                %end ;
                %let _flag_overall = 1 ;
            %end ;
            %let __i = %eval( &__i+1 );
            %let __ds = %qscan( &dslist,&__i,%str( ) );
        %end ; %* datasets *;
    %end ; %* valid variable *;
    %let __j = %eval( &__j+1 );
    %let __var = %qscan( &varlist,&__j,%str( ) );
%end ;



%** Set error status macrovariable **;
%if &_flag_overall=1 %then %do;  %** condition found **;
  %if ^%symglobl(error_status) %then %global error_status;
  %let error_status=1;
%end;
%else %do;  %** no error condition found **;
  %if ^%symglobl(error_status) %then %do;
    %global error_status;
    %let error_status = 0;
  %end;
  %if &debug=1 %then %do;
    %if &varlist^= %then %do ;
      %ut_errmsg(msg="No invalid variable names were detected.",
                 type=note,print=0,macroname=ut_chk_var);
    %end ;
    %else %do ;
      %ut_errmsg(msg="No variable names were passed for detection.",
                 type=note,print=0,macroname=ut_chk_var);
    %end ;
    %if %bquote(&dslist)= %then %do;
      %ut_errmsg(msg="No dataset names were provided.",
                 type=note,print=0,macroname=ut_chk_var);
    %end;
    %else %do;
      %if &type= %then %do ;
        %ut_errmsg(msg="All specified variables were found in all datasets.",
                   type=note,print=0,macroname=ut_chk_var);
      %end ;
      %else %do ;
        %ut_errmsg(msg="All specified variables were found in all datasets as %qupcase(&_ak_type) variables.",
                   type=note,print=0,macroname=ut_chk_var);
      %end ;
    %end;
  %end;
%end;

%*=======================;
%* Reset system options  ;
%*=======================;
proc optload data=&_pfx.optsave
  (where=(upcase(optname) in('MPRINT','MLOGIC','SYMBOLGEN')))  /* This line added for Version 2 */
  ;
run;


%*===========================;
%* Delete temporary datasets ;
%*===========================;
data &_pfx.dummy;
run;
proc datasets lib=work nolist;
  delete &_pfx:;
run;

%mend ut_chk_var ;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="843edc:12b0d39d93b:-7d80" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS log" systemtype="&star;LOG&star;" tabname="System Files" baseoption="A" advanced="N" order="1" id="&star;LOG&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LOG"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="LOGFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS output" systemtype="&star;LST&star;" tabname="System Files" baseoption="A" advanced="N" order="2" id="&star;LST&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LST"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="LSTFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="Process parameter values" systemtype="SDDPARMS" tabname="System Files" baseoption="A" advanced="N" order="3" id="SDDPARMS" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS7BDAT"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="PARMFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="4" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter cdvquote="N" multiline="N" usecdv="N" dependsaction="ENABLE" resolution="INPUT" label="Text field" type="TEXT" processid="P1" id="DSLIST" order="5" cdvmultiline="N" protect="N" quote="N" enable="N" maxlength="256" canlinktobasepath="N"*/
/*   obfuscate="N" required="N" tabname="Parameters" advanced="N" cdvenable="Y" cdvrequired="N">*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter cdvquote="N" multiline="N" usecdv="N" dependsaction="ENABLE" resolution="INPUT" label="Text field" type="TEXT" processid="P1" id="VARLIST" order="6" cdvmultiline="N" protect="N" quote="N" enable="N" maxlength="256" canlinktobasepath="N"*/
/*   obfuscate="N" required="N" tabname="Parameters" advanced="N" cdvenable="Y" cdvrequired="N">*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter cdvquote="N" multiline="N" usecdv="N" dependsaction="ENABLE" resolution="INPUT" label="Text field" type="TEXT" processid="P1" id="TYPE" order="7" cdvmultiline="N" protect="N" quote="N" enable="N" maxlength="256" canlinktobasepath="N"*/
/*   obfuscate="N" required="N" tabname="Parameters" advanced="N" cdvenable="Y" cdvrequired="N">*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter cdvquote="N" multiline="N" usecdv="N" dependsaction="ENABLE" resolution="INPUT" label="Text field" type="TEXT" processid="P1" id="DEBUG" order="8" cdvmultiline="N" protect="N" quote="N" enable="N" maxlength="256" canlinktobasepath="N"*/
/*   obfuscate="N" required="N" tabname="Parameters" advanced="N" cdvenable="Y" cdvrequired="N">*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_PFX" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_FLAG_OVERALL" maxlength="256"*/
/*   tabname="Parameters" processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="11" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_FLAGI" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter cdvquote="N" multiline="N" usecdv="N" dependsaction="ENABLE" resolution="INPUT" label="Text field" type="TEXT" processid="P1" id="__AK_TEMP" order="12" cdvmultiline="N" protect="N" quote="N" enable="N" maxlength="256"*/
/*   canlinktobasepath="N" obfuscate="N" required="N" tabname="Parameters" advanced="N" cdvenable="Y" cdvrequired="Y">*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__I" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__J" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="15" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__DS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="16" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__VAR" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="17" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__RESULT" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="ERROR_STATUS" resolution="INTERNAL" type="TEXT" order="18">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="19" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="__NOTYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="_AK_TYPE" resolution="INTERNAL" type="TEXT" order="20">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="21" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="22" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DS_LIB" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="23" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DS_DS" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="24" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SDD" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="25" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="I" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="26" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_PDA" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/