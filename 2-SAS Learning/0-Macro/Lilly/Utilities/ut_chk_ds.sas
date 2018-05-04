%macro ut_chk_ds(dslist      = _default_,
                 required_yn = _default_,
                 debug       = _default_)
                 ;
/*soh****************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_chk_ds
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Verify the validity of a list of dataset names, and verify
                    : that the datasets exist if they are required to exist.
                    :
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : /lillyce/prd/general/bums/macro_library/ut_parmdef
                      /lillyce/prd/general/bums/macro_library/ut_logical
                      /lillyce/prd/general/bums/macro_library/ut_errmsg
                      /lillyce/prd/general/bums/macro_library/ut_marray
                      /lillyce/prd/general/bums/macro_library/ut_dupword
                      /lillyce/prd/general/bums/macro_library/ut_numwords
INPUT               : N/A
OUTPUT              : N/A
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_chk_ds/documentation/ut_chk_ds_rd.doc
ASSUMPTIONS         : N/A

---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _AH

PARAMETERS:

Name         Type      Default   Description and Valid Values
----------   --------  --------  ---------------------------------------------------
DSLIST       optional   (none)   a list of datasets to verify

REQUIRED_YN  optional   (none)   whether the datasets on the list are required to
                                 exist, or if the macro is only checking the
                                 validity of the dataset names

DEBUG        required      0     a %ut_logical value specifying whether
                                 debug mode is on or off

--------------------------------------------------------------------------------
USAGE NOTES:

This macro is to be used outside of a DATA Step/Procedure.

The purpose of UT_CHK_DS is to check the validity of a SAS dataset or list of
SAS datasets.  The module verifies that

  (1) if specified, the datasets have valid names
  (2) if any of the datasets are listed as two-level dataset names, the libref
      portion of each name is a valid SAS libref and is associated with an
      existing SAS library
  (3) if REQUIRED_YN has a TRUE value recognized by UT_LOGICAL, the datasets
      exist.

If any violations are detected, the module sets global macrovariable
ERROR_STATUS to 1, regardless of the value or existence of the macrovariable
prior to execution, and issues an appropriate message.  If no violations are
detected, the value of global macrovariable ERROR_STATUS remains unchanged
if it exists, or is created with a value of 0 if it does not exist prior to
execution.

There cannot be a local macrovariable called ERROR_STATUS when the module is
called.

To allow maximum flexibility in the calling program, the user is not required
to specify any dataset names.  If no dataset names are specified, the macro will
run without errors, and no error condition will result.

--------------------------------------------------------------------------------
TYPICAL MACRO CALL AND DESCRIPTION:

%u_chk_ds(dslist      = inds.ecg subjds,
          required_yn = On,
          debug       = Off);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen      BMRCSH09NOV2009A     Original version of the code
       Melinda Rodgers

 2.0   Craig Hansen      BMRMKC07SEP2010A     Limit the restoration of system
       Melinda Rodgers                        options to only those options that
                                              are potentially altered during the
                                              execution of the module, namely,
                                              MPRINT, MLOGIC, and SYMBOLGEN.

 3.0   Chuck Bininger &  BMRCB29MAR2011B      Update header to reflect code validated
       Shong Demattos                         for SAS v9.2.  Modified header to maintain
                                              compliance with current SOP Code Header.


**eoh***************************************************************************/

%*==============================================================================;
%* Declare local and initialize macro variables                                 ;
%*==============================================================================;
%local i _pda _pfx _flag_overall _flagi ds ds_lib ds_ds sdd;

%*==============================================================================;
%* Set prefix assigned to this module                                           ;
%*==============================================================================;
%let _pfx = _ah;

%*==============================================================================;
%* Delete temporary datasets to prevent contamination from previous runs        ;
%*==============================================================================;
data &_pfx.dummy;
run;
proc datasets lib=work nolist;
  delete &_pfx:;
quit;

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
%ut_parmdef(dslist,,,      _pdrequired=0, _pdmacroname=ut_chk_ds, _pdabort=&_pda)
%ut_parmdef(required_yn,,, _pdrequired=0, _pdmacroname=ut_chk_ds, _pdabort=&_pda)
%ut_parmdef(debug,0,,      _pdrequired=1, _pdmacroname=ut_chk_ds, _pdabort=&_pda)
%if %bquote(&required_yn)^= %then %do;
  %ut_logical(required_yn)
%end;
%ut_logical(debug)
;
%if %symglobl(error_status) %then %do;
  %if %bquote(&error_status) = 1 %then %do;
    %ut_errmsg(msg=%sysfunc(compbl("An invalid condition has been detected. The macro will
                                    stop executing.")),
                    type=error,print=0,macroname=ut_chk_ds);
    %return;
  %end;
%end;

%*=============================================================================;
%* Save the initial values of the SAS system options                           ;
%*=============================================================================;
proc optsave out=&_pfx.optsave;
run;
%if ^&debug %then %do;
  options nomprint nomlogic nosymbolgen;
%end;

%** Verify there are no duplicate dataset names **;
%if %ut_dupword(&dslist) %then %do;
  %ut_errmsg(msg="The value passed in for DSLIST contains a duplicate dataset name.",
                  type=warning,print=0,macroname=ut_chk_ds);
%end;

%** Verify REQUIRED_YN is not null when DSLIST is not null **;
%if %bquote(&dslist)^= and %bquote(&required_yn)= %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("REQUIRED_YN must be specified when DSLIST is not null.
                                  A value of TRUE will be assumed.")),
                  type=warning,print=0,macroname=ut_chk_ds);
  %let required_yn=1;
%end;

%** Verify ERROR_STATUS does not exist as a local macrovariable **;
%if %symlocal(error_status) %then %do;
  %ut_errmsg(msg=%sysfunc(compbl("ERROR_STATUS cannot exist as a local macrovariable
                                  when UT_CHK_DS is executed.")),
                  type=error,print=0,macroname=ut_chk_ds);
  %return;
%end;

%*==========================================================================;
%*                                                                          ;
%*                    BEGIN BUM MAIN PROCESSING SECTION                     ;
%*                                                                          ;
%*==========================================================================;
%let _flag_overall=0;

%** Check datasets on list **;
%if %bquote(&dslist)^= %then %do;
  %do i = 1 %to %ut_numwords(&dslist);
    %let _flagi = 0;
    %let ds = %qscan(%bquote(&dslist),&i,%str( ));
    %if %index(%bquote(&ds),%str(.)) %then %do; %** two level dataset name **;
      %if %sysfunc(countc(&ds,%str(.))) > 1 %then %do; %** multiple periods **;
        %ut_errmsg(msg="%qupcase(&ds) is an invalid SAS data set name.",
                   type=error,print=0,macroname=ut_chk_ds);
        %let _flagi=1;
      %end;
      %else %if %substr(%bquote(&ds),1,1)=%str(.) %then %do; %** begins with period **;
        %ut_errmsg(msg="%qupcase(&ds) is an invalid SAS data set name.",
                   type=error,print=0,macroname=ut_chk_ds);
        %let _flagi=1;
      %end;
      %else %if %substr(%qsysfunc(reverse(%bquote(&ds))),1,1)=%str(.) %then %do; %** ends with period **;
        %ut_errmsg(msg="%qupcase(&ds) is an invalid SAS data set name.",
                   type=error,print=0,macroname=ut_chk_ds);
        %let _flagi=1;
      %end;
      %let ds_lib = %scan(%bquote(&ds),1,%str(.));       %** libref portion of name **;
      %let ds_lib = %qsysfunc(compbl(%bquote(&ds_lib)));
      %let ds_ds  = %scan(%bquote(&ds),2,%str(.));       %** dataset portion of name **;
      %if ^&_flagi %then %do;
        %if %bquote(&ds_lib)^= %then %do;
          %if ^%qsysfunc(nvalid(&ds_lib)) or %length(&ds_lib)>8 %then %do;  %** invalid libref name **;
            %ut_errmsg(msg="The libref %qupcase(&ds_lib) in %qupcase(&ds) is invalid.",
                       type=error,print=0,macroname=ut_chk_ds);
            %let _flagi=1;
          %end;
          %else %if %qsysfunc(libref(&ds_lib))^=0 %then %do;  %** libref not assigned **;
            %ut_errmsg(msg="The libref %qupcase(&ds_lib) in %qupcase(&ds) is not assigned.",
                       type=error,print=0,macroname=ut_chk_ds);
            %let _flagi=1;
          %end;
        %end;
      %end;
    %end;       %** end of two-level dataset name **;
    %else %do;  %** one-level dataset name **;
      %let ds_ds = &ds;
    %end;
    %if ^&_flagi %then %do;
      %if %bquote(&ds_ds)^= %then %do;
        %if ^%sysfunc(nvalid(&ds_ds)) %then %do;  %** invalid dataset name **;
          %ut_errmsg(msg="%qupcase(&ds) is an invalid SAS data set name.",
                     type=error,print=0,macroname=ut_chk_ds);
          %let _flagi=1;
        %end;
        %else %if &required_yn %then %do;
          %if ^%sysfunc(exist(&ds)) %then %do;  %** nonexistent dataset **;
            %ut_errmsg(msg=%sysfunc(compbl("Dataset %qupcase(&ds) %str(d)oes not exist.")),
                       type=error,print=0,macroname=ut_chk_ds);
            %let _flagi=1;
          %end;
        %end;
      %end;
    %end;
    %if &_flagi %then %let _flag_overall=1;
  %end;  %** End of loop through dataset list **;
%end;    %** End of DSLIST not null **;

%** Set error status macrovariable **;
%if &_flag_overall %then %do;  %** condition found **;
  %if ^%symglobl(error_status) %then %global error_status;
  %let error_status=1;
%end;
%else %do;  %** no error condition found **;
  %if ^%symglobl(error_status) %then %do;
    %global error_status;
    %let error_status = 0;
  %end;
  %if &debug %then %do;
    %if %bquote(&dslist)^= %then %do;
      %ut_errmsg(msg="No invalid dataset names were detected.",
                 type=note,print=0,macroname=ut_chk_ds);
    %end;
    %else %do;
      %ut_errmsg(msg="No dataset names were provided to check.",
                 type=note,print=0,macroname=ut_chk_ds);
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
quit;

%mend ut_chk_ds;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="843edc:12b0d39d93b:-7d80" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter userdefined="S" obfuscate="N" id="&star;LOG&star;" canlinktobasepath="Y" protect="N" label="SAS log" systemtype="&star;LOG&star;" order="1" processid="P2" dependsaction="ENABLE" baseoption="A" resolution="INPUT" advanced="N" required="N"*/
/*   enable="N" type="LOGFILE" autolaunch="N" filetype="LOG" tabname="System Files">*/
/*   <target rootname="" extension="log">*/
/*    <folder system="RELATIVE" source="RELATIVE" displayname="." id="." itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="Process parameter values" systemtype="SDDPARMS" tabname="System Files" baseoption="A" advanced="N" order="2" id="SDDPARMS" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS7BDAT"*/
/*   processid="P2" required="N" resolution="INPUT" enable="N" type="PARMFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="3" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P2" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter id="DSLIST" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="REQUIRED_YN" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/*  <parameter id="DEBUG" resolution="INTERNAL" type="TEXT" order="6">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="7">*/
/*  </parameter>*/
/*  <parameter id="_PFX" resolution="INTERNAL" type="TEXT" order="8">*/
/*  </parameter>*/
/*  <parameter id="DS" resolution="INTERNAL" type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter id="DS_LIB" resolution="INTERNAL" type="TEXT" order="10">*/
/*  </parameter>*/
/*  <parameter id="DS_DS" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter id="ERROR_STATUS" resolution="INTERNAL" type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter id="_FLAG_OVERALL" resolution="INTERNAL" type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter id="_FLAGI" resolution="INTERNAL" type="TEXT" order="14">*/
/*  </parameter>*/
/*  <parameter id="_PDA" resolution="INTERNAL" type="TEXT" order="15">*/
/*  </parameter>*/
/*  <parameter id="SDD" resolution="INTERNAL" type="TEXT" order="16">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/