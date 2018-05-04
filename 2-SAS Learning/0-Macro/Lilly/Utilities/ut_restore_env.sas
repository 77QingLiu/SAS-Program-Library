%macro ut_restore_env(prefixlist = _default_,
                      optds      = _default_,
                      optlist    = _default_,
                      debug      = _default_);
/*soh****************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_restore_env
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Restore the SAS system environment using info supplied by
                    : the user:
                    :   (1) Delete datasets with names beginning with a specified
                    :       prefix from the SAS work library
                    :   (2) Delete formats and informats with names beginning with
                    :       a specified prefix from the SAS work library
                    :   (3) Reset system options as specified
                    :
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : /lilly/prd/general/bums/macro_library/ut_chk_ds
                      /lilly/prd/general/bums/macro_library/ut_chk_var
                      /lilly/prd/general/bums/macro_library/ut_dupword
                      /lilly/prd/general/bums/macro_library/ut_errmsg
                      /lilly/prd/general/bums/macro_library/ut_logical
                      /lilly/prd/general/bums/macro_library/ut_marray
                      /lilly/prd/general/bums/macro_library/ut_numobs
                      /lilly/prd/general/bums/macro_library/ut_numwords
                      /lilly/prd/general/bums/macro_library/ut_parmdef
                      /lilly/prd/general/bums/macro_library/ut_quote_token
INPUT               : N/A
OUTPUT              : N/A
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_restore_env/documentation/ut_restore_env_rd.doc
ASSUMPTIONS         : 1. The module does not have any method of determining which
                         dataset, formats, and informats were created during
                         execution of the calling program.  It relies on the
                         user-specified prefixes as being sufficient information
                         to identify which objects should be deleted.
                      2. The module does not have any method of determining which
                         system options were altered during execution of the calling
                         program.  It simply sets the system options contained in the
                         dataset passed in (see USAGE NOTES below).
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _AF

PARAMETERS:

Name       Type      Default   Description and Valid Values
---------- --------  --------  ---------------------------------------------------
PREFIXLIST optional    (none)  a list of prefixes used to identify the SAS
                               datasets to delete from the SAS work library
                               and

OPTDS      optional    (none)  a SAS dataset created by PROC OPTSAVE containing
                               data needed to reset system options

OPTLIST    optional    (none)  the list of options to be restored

DEBUG      required        0   a %ut_logical value specifying whether
                               debug mode is on or off.

--------------------------------------------------------------------------------
USAGE NOTES:

This macro is to be used outside of a DATA Step/Procedure.

To properly use this module to restore system options, the user must run
PROC OPTSAVE in the calling program prior to changing any SAS system options,
and pass the resulting dataset into this module via parameter OPTDS.

--------------------------------------------------------------------------------
TYPICAL MACRO CALL AND DESCRIPTION:

%ut_restore_env(prefixlist = xy xz,
                optds      = optsaveds,
                optlist    = MPRINT MLOGIC SYMBOLGEN,
                debug      = 0);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen       BMRCSH09NOV2009C     Original version of the code
       Melinda Rodgers

 2.0   Craig Hansen       BMRMKC03SEP2010      Revisions:
       Melinda Rodgers                         1. Add parameter OPTLIST to
                                                  specify the list of options to
                                                  restore.
                                               2. Default the value of OPTLIST
                                                  if the value of PREFIXLIST
                                                  identifies the calling module
                                                  as one that was already in
                                                  production at the time of this
                                                  revision.
                                               3. Display the values of all
                                                  system options found in the
                                                  input options dataset before
                                                  and after restoring options.

 3.0   Chuck Bininger &   BMRCB24MAR2011A      Update header to reflect code validated
       Shong Demattos                          for SAS v9.2.  Modified header to maintain
                                               compliance with current SOP Code Header.

 4.0   Richard Schneck    BMRRLS30MAR2011      Revised so that the module executes its 
       Shong Demattos                          primary functionality as described in 
                                               Section 3.5: Other Functionality Requirements 
                                               in the requirements document, regardless of
                                               the pre-existing value of the global error-
                                               status macrovariable ERROR_STATUS, if no
                                               errors are detected within this module as
                                               described in Section 3.1: Utility Requirements
                                               in the requirements document.

**eoh***************************************************************************/

%*==============================================================================;
%* Declare local and initialize macro variables                                 ;
%*==============================================================================;
%local i sdd _pda _pfx _catlist _dslist _xoptlist sdd
       save_errstat;

%*==============================================================================;
%* Set prefix assigned to this module                                           ;
%*==============================================================================;
%let _pfx = _af;

%*==============================================================================;
%*                                                                              ;
%*                          Begin parameter checks                              ;
%*                                                                              ;
%*==============================================================================;

%*===========================================================================;
%* Get Platform information for which BUM is executing                       ;
%*===========================================================================;
%if %symglobl(_sddusr_) | %symglobl(_sddprc_) | %symglobl(sddparms) %then %let sdd = 1;
                                                                    %else %let sdd = 0;
%if %upcase(%nrbquote(&sysscp)) = WIN %then %let _pda = 0;
                                      %else %let _pda = 1;

%*============================================================;
%* Process parameters                                         ;
%* ------------------                                         ;
%* ADDED FOR VERSION 3: If ERROR_STATUS=1 prior to execution  ;
%* of this module, set it to zero. First save the value and   ;
%* reset at the end of this module.                           ;
%*============================================================;
%if ^%symglobl(error_status) %then %do;
  %global error_status;
  %let error_status = 0;
%end;
%else %do;
  %if %bquote(&error_status)= %then %let error_status = 0;
%end;

%let save_errstat = &error_status;  %** Added for Version 3 **;
%let error_status = 0;              %** Added for Version 3 **;

%ut_parmdef(prefixlist,,,_pdrequired=0,_pdmacroname=ut_restore_env, _pdabort=&_pda)
%ut_parmdef(optds,,,     _pdrequired=0,_pdmacroname=ut_restore_env, _pdabort=&_pda)
%ut_parmdef(optlist,,,   _pdrequired=0,_pdmacroname=ut_restore_env, _pdabort=&_pda)
%ut_parmdef(debug,0,,    _pdrequired=1,_pdmacroname=ut_restore_env, _pdabort=&_pda)
%ut_logical(debug)
;
%if &debug^=0 and &debug^=1 %then %let error_status = 1;

%** Verify none of the prefixes included in the value of PREFIXLIST **;
%**   include the prefix reserved for this BUM                      **;
%if %bquote(&prefixlist)^= %then %do;
  %do i = 1 %to %ut_numwords(&prefixlist);
    %if %qupcase(%qscan(&prefixlist,&i,%str( )))=_AF %then %do;
       %ut_errmsg(msg=%sysfunc(compbl("The value specified for PREFIXLIST cannot include
         the reserved prefix _AF.")),
                  type=error,print=0,macroname=ut_restore_env);
       %let error_status = 1;
       %return;
    %end;
  %end;
%end;

%** Verify the value of OPTDS does not begin with the prefix reserved for this BUM **;
%if %bquote(&optds)^= %then %do;
  %if %qupcase(%substr(&optds,1,3))=_AF %then %do;
     %ut_errmsg(msg=%sysfunc(compbl("The value specified for OPTDS cannot begin with
       the reserved prefix _AF.")),
                type=error,print=0,macroname=ut_restore_env);
     %let error_status = 1;
     %return;
  %end;
%end;

%** Create a series of macrovariables containing the prefixes **;
%local _marraylist _numpfx;
%ut_marray(invar=prefixlist, outvar=_prefx, outnum=_numpfx, varlist=_marraylist)
%local &_marraylist;
%ut_marray(invar=prefixlist, outvar=_prefx, outnum=_numpfx)   %**;

%** Verify the object prefixes: Valid SAS names <= 5 characters **;
%do i = 1 %to &_numpfx;
  %if ^%sysfunc(nvalid(&&_prefx&i)) %then %do;
     %ut_errmsg(msg=%sysfunc(compbl("At least one prefix specified on parameter PREFIXLIST
                                      is not a valid SAS name.")),
                type=error,print=0,macroname=ut_restore_env);
      %let error_status = 1;
      %return;
  %end;
  %else %if %length(&&_prefx&i)>5 %then %do;
     %ut_errmsg(msg=%sysfunc(compbl("A prefix specified on parameter PREFIXLIST exceeds the
                                      maximum length of five characters.")),
                type=error,print=0,macroname=ut_restore_env);
      %let error_status = 1;
     %return;
  %end;
%end;

%** Verify none of the prefixes are repeated **;
%if %ut_dupword(&prefixlist) %then %do;
   %ut_errmsg(msg=%sysfunc(compbl("A duplicate prefix was entered on parameter PREFIXLIST.")),
              type=error,print=0,macroname=ut_restore_env);
   %let error_status = 1;
   %return;
%end;

%** Verify an options dataset is specified if an options list is specified **;
%if %bquote(&optlist)^= %then %do;
  %if %bquote(&optds)= %then %do;
     %ut_errmsg(msg=%sysfunc(compbl("OPTLIST was specified but OPTDS has a null value.
        No system options will be restored.")),
                type=note,print=0,macroname=ut_restore_env);
     %let optlist=;
  %end;
%end;

%** Verify existence and structure of options dataset **;
%if %qscan(&optds,2,%str( ))^= %then %do;
   %ut_errmsg(msg=%sysfunc(compbl("Only one dataset name can be specified on parameter OPTDS.")),
                  type=error,print=0,macroname=ut_restore_env);
   %return;
%end;
%if ^&error_status %then %do;
  %ut_chk_ds (dslist=&optds, required_yn=Y, debug=&debug);
%end;
%if ^&error_status %then %do;
  %ut_chk_var(dslist=&optds, varlist=OPTNAME OPTVALUE, type=C, debug=&debug);
%end;

%** Exit on error **;
%if %bquote(&error_status) = 1 %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("An invalid condition has been detected. The macro will
                                  stop executing.")),
                  type=error,print=0,macroname=ut_restore_env);
  %return;
%end;

%** Conditionally default OPTLIST for specific BUMs already in production **;
%if %bquote(&optds)^= and %bquote(&optlist)= %then %do;
  %if %bquote(&prefixlist)^= %then %do;
    %if %qupcase(&prefixlist)=_AL or %qupcase(&prefixlist)=_AR or
        %qupcase(&prefixlist)=_AV or %qupcase(&prefixlist)=_AX
    %then %do;
       %ut_errmsg(msg=%sysfunc(compbl("The value of OPTLIST will default to
           MPRINT MLOGIC SYMBOLGEN based on the value of PREFIXLIST.")),
                  type=note,print=0,macroname=ut_restore_env);
       %let optlist = MPRINT MLOGIC SYMBOLGEN;
    %end;
    %else %if %qupcase(&prefixlist)=_AQ %then %do;
       %ut_errmsg(msg=%sysfunc(compbl("The value of OPTLIST will default to
           MPRINT MLOGIC SYMBOLGEN FORMCHAR CENTER LINESIZE based on the value of
           PREFIXLIST.")),
                  type=note,print=0,macroname=ut_restore_env);
       %let optlist = MPRINT MLOGIC SYMBOLGEN FORMCHAR CENTER LINESIZE;
    %end;
  %end;
  %** Print note if OPTLIST is still null after conditional default logic **;
  %if %bquote(&optlist)= %then %do;
     %ut_errmsg(msg=%sysfunc(compbl("OPTDS was specified but OPTLIST has a null value.
        No system options will be restored.")),
                type=note,print=0,macroname=ut_restore_env);
  %end;
%end;

%** Create a list of quoted option names **;
%if %bquote(&optlist)^= %then %do;
  %ut_quote_token(inmvar=optlist,outmvar=_xoptlist,debug=&debug);
%end;
%let _xoptlist = %qupcase(&_xoptlist);

%** Verify the options listed on OPTLIST are found in the options dataset **;
%if %bquote(&optds)^= and %bquote(&optlist)^= %then %do;
  data &_pfx.optlst;
    length optname $100;
    %do i = 1 %to %ut_numwords(&optlist);
      optname = upcase(strip("%qscan(&optlist,&i)")); output;
    %end;
  run;
  proc sort data=&_pfx.optlst;
    by optname;
  run;
  data &_pfx.optnames;
    length optname $100;
    set &optds(keep=optname where=(upcase(optname) in(%unquote(&_xoptlist))));
  run;
  proc sort data=&_pfx.optnames;
    by optname;
  run;
  data _null_;
    merge &_pfx.optlst &_pfx.optnames(in=x);
    by optname;
    if ^x then do;
      put optname=;
      %ut_errmsg(msg=%sysfunc(compbl("An option name on OPTLIST is not a value of OPTNAME
    in dataset %qupcase(&optds).")),
                 type=note,print=0,macroname=ut_restore_env);
    end;
  run;
%end;

%*==============================================================================;
%*                                                                              ;
%*                    Begin BUM Main Processing Section                         ;
%*                                                                              ;
%*==============================================================================;

%*==============================================================================;
%* Delete temporary datasets to prevent contamination from previous runs        ;
%*==============================================================================;

%** Create dummy dataset to ensure there is at least one dataset to delete **;
data &_pfx.__x;
run;
proc datasets lib=work nolist;
  delete &_pfx:;
quit;
%** Create dummy format to ensure that the WORK.FORMATS catalog exists **;
proc format;
  value &_pfx.__x
    1='a';
run;

%** Copy dataset &OPTDS to a temporary dataset in case it gets deleted **;
%**   before PROC OPTLOAD runs **;
%if %bquote(&optds)^= %then %do;
  data &_pfx.optds;
    set &optds;
  run;
%end;

%*===========================================================;
%* Save the initial values of the SAS system options         ;
%* Apply standard settings for DEBUG OFF                     ;
%*===========================================================;
proc optsave out=&_pfx.optsave;
run;
%if ^&debug %then %do;
  options nomprint nomlogic nosymbolgen;
%end;

%*========================================================;
%*  Delete the temporary objects as specified             ;
%*========================================================;
%if ^&debug %then %do;
  %if &_numpfx=0 %then %do;
     %ut_errmsg(msg=%sysfunc(compbl("No prefixes were specified.
                                     No datasets, formats, or informats will be deleted.")),
                type=note,print=0,macroname=ut_restore_env);
  %end;
  %else %do;
    %** Create the lists of qualifying objects to delete **;
    data &_pfx.catlist;
      set sashelp.vcatalg;
      where upcase(libname) = 'WORK'    and upcase(memname) = 'FORMATS' and
            upcase(memtype) = 'CATALOG' and upcase(objtype) in('FORMAT','FORMATC','INFMT')
            ;
      %do i = 1 %to &_numpfx;
        %if &i>1 %then %do; else %end;
        if upcase(objname)=:"%qupcase(&&_prefx&i)" then do;
          _object = cats(objname,'.',objtype);
          output;
        end;
      %end;
      keep _object;
    run;
    data &_pfx.dslist;
      set sashelp.vtable;
      where upcase(libname)='WORK';
      %do i = 1 %to &_numpfx;
        %if &i>1 %then %do; else %end;
        if upcase(memname)=:"%qupcase(&&_prefx&i)" then output;
      %end;
      keep memname;
    run;
    %let _catlist = ;
    %let _dslist  = ;
    proc sql noprint;
      select distinct _object into : _catlist separated by ' ' from &_pfx.catlist;
      select distinct memname into : _dslist  separated by ' ' from &_pfx.dslist;
    quit;
    %** Issue note if no objects to delete **;
    %if %bquote(&_catlist)= and %bquote(&_dslist)= %then %do;
     %ut_errmsg(msg=%sysfunc(compbl("No qualifying datasets, formats, or informats were found.
                                     No objects will be deleted.")),
                type=note,print=0,macroname=ut_restore_env);
    %end;
    %** Delete the objects **;
    %if %bquote(&_catlist)^= %then %do;
      %ut_errmsg(msg="Catalog entries matching a specified prefix were found and will be deleted.",
                  type=note,print=0,macroname=ut_restore_env);
      proc catalog cat=work.formats;
        delete &_catlist;
      quit;
    %end;
    %if %bquote(&_dslist)^= %then %do;
      %ut_errmsg(msg="Datasets matching a specified prefix were found and will be deleted.",
                  type=note,print=0,macroname=ut_restore_env);
      proc datasets lib=work nolist;
        delete &_dslist;
      quit;
    %end;
  %end;     %** End of _numpfx > 0 **;
%end;       %** End of Debug OFF   **;
%else %do;  %** Debug ON           **;
  %ut_errmsg(msg="Temporary datasets, formats and informats will NOT be deleted in DEBUG mode.",
             type=note,print=0,macroname=ut_restore_env);
%end;

%*========================================================;
%*  Restore SAS system options changed within this macro  ;
%*========================================================;
proc optload data=&_pfx.optsave(where=(upcase(optname) in('MPRINT','MLOGIC','SYMBOLGEN')));
run;

%*=======================================================;
%*  Restore SAS system options as specified by the user  ;
%*=======================================================;
%if %bquote(&optds)^= and %bquote(&optlist)^= %then %do;
  proc optload data=&_pfx.optds(where=(upcase(optname) in(%unquote(&_xoptlist))));
  run;
  %if &debug %then %do;
    %ut_errmsg(msg="System option values have been restored as contained in dataset %qupcase(&optds).",
               type=note,print=0,macroname=ut_restore_env);
  %end;
%end;
%else %if &debug %then %do;
  %ut_errmsg(msg="A null value was passed for OPTDS or OPTLIST; no system options will be reset.",
             type=note,print=0,macroname=ut_restore_env);
%end;

%*===========================================================;
%*  Display differences between actual system option values  ;
%*  and the values in &OPTDS at the end of the module        ;
%*===========================================================;
%if &debug and %bquote(&optds)^= %then %do;
  proc optsave out=&_pfx.newopts;
  run;
  proc sort data=&_pfx.newopts(keep=optname optvalue rename=(optvalue=newvalue))
    out=&_pfx.newopts;
    by optname;
  run;
  proc sort data=&_pfx.optds;
    by optname;
  run;
  data &_pfx.optds;
    merge &_pfx.newopts(in=x) &_pfx.optds(in=y);
    by optname; if x and y;
    if newvalue ^= optvalue;
  run;
  %if %ut_numobs(&_pfx.optds)=0 %then %do;
    %ut_errmsg(msg="All options settings match the values in dataset %qupcase(&optds).",
               type=note,print=0,macroname=ut_restore_env);
  %end;
  %else %do;
    %ut_errmsg(msg="The following options settings do not match the values in dataset %qupcase(&optds):",
               type=note,print=0,macroname=ut_restore_env);
  %end;
  data _null_;
    set &_pfx.optds;
    put @1 'OPTION                                      : ' optname;
    put @1 'VALUE IN DATASET SPECIFIED BY OPTDS         : ' optvalue;
    put @1 'ACTUAL VALUE AFTER EXECUTING UT_RESTORE_ENV : ' newvalue /;
  run;
%end;

%*==================================================================;
%*  Clean up datasets and catalog entries created within this macro ;
%*==================================================================;
proc datasets library=work;
  delete &_pfx:;
quit;
proc catalog cat=work.formats;
  delete &_pfx.__x.format;
quit;

%** Added for VERSION 3 - restore error status macrovariable **;
%if %bquote(&error_status)^=1 %then %let error_status = &save_errstat;           

%mend ut_restore_env;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="16607fb:12f4f5007ae:-5010" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="PREFIXLIST" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="1">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OPTDS" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="2">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OPTLIST" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="3">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DEBUG" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="4">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="I" maximum="9999999" advanced="N" enable="Y" obfuscate="N" tabname="Parameters" minimum="-9999999" numtype="real" resolution="INPUT" protect="N" label="Numeric field" required="Y"*/
/*   type="NUMERIC" order="5">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="SDD" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="6">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDA" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="7">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PFX" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="8">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_CATLIST" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_DSLIST" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="10">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_XOPTLIST" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="SAVE_ERRSTAT" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="ERROR_STATUS" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_MARRAYLIST" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="14">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_NUMPFX" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="15">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PREFX" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="16">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/