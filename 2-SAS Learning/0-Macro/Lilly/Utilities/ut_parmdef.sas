%macro ut_parmdef(_pdparmname,_pddefault,_pdallowed,_pdrequired=0,_pdverbose=1,
 _pdmacroname=,_pdignorecase=1,_pdabort=1);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences                    
CODE NAME           :  ut_parmdef  
CODE TYPE           :  Broad-use Module   
PROJECT NAME        : 
DESCRIPTION         :  Called by macros to assign a default value to each
                       parameter of the calling macro and the verify
                       that the parameter's value is in the list of
                       allowed values.
SOFTWARE/VERSION#   :  SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      :  SDD v3.4 and MS Windows 
LIMITED-USE MODULES :  N/A                
BROAD-USE MODULES   :  N/A
INPUT               :  N/A
OUTPUT              :  N/A 
VALIDATION LEVEL    :  6                  
REQUIREMENTS        :  /lillyce/qa/general/bums/validation_pilot/ut_parmdef_validation/
                       documentation/ut_parmdef_sdd_dl.doc                   
ASSUMPTIONS         :  N/A
--------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:                       
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _PD                       
                      
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
_PDPARMNAME required          Positional parmeter whose value is the name of
          positional           the parameter of the calling macro to which 
                               the default value will be assigned
_PDDEFAULT  optional          Positional parameter whose value is the value 
          positional           assigned to PARMNAME when PARMNAME has the 
                               value of _default_ assigned to it. If PARMNAME
                               has a value other than _default_ then the
                               value if PARMNAME is not changed. If the value
                               of PARMNAME has the value of _default_ then
                               the value of DEFAULT is assigned to PARMNAME.
                               The actual and default values are printed to
                               the log file.
_PDALLOWED  optional          A blank-delimited list of allowd values for 
          positional           PARMNAME
_PDREQUIRED required 0        A logical value specifying whether PARMNAME
                               is a required parameter and does not accept a
                               null value.  %ut_logical is not called - only 
                               the values 1 and 0 are supported (for yes/no)
_PDMACRONAME optional         The name of the macro calling ut_parmdef - this
                               macro name is included in the verbose output 
                               messages of ut_parmdef so that the user knows
                               to which macro the message applies.
_PDVERBOSE  required 1        A logical value specifying whether verbose
                               mode is on or off.  If true then lines are
                               listed in the log file that describe _PDPARMNAME
                               (its name, actual value and default value)
                               %ut_logical is not called - only  the values
                               1 and 0 are supported (for yes/no)
 _PDIGNORECASE required 1     A logical value specifying whether or not to 
                               ignore the case of the values when comparing 
                               _PDPARMNAME to the list of allowed values in
                               _PDALLOWED.
                               %ut_logical is not called - only  the values
                                1 and 0 are supported (for yes/no)
 _PDABORT      required 1     A logical value specifying whether or not to 
                               abort the program when _PDPARMNAME is not in 
                               the list of allowed values in _PDALLOWED.
                              If _pdabort is true the SAS session is aborted if:
                               1.) a required parameter has a null value
                               2.) a parameter has an invalid value
                               3.) and the global variable max_error_type is 
                                   not equal to "error".
                              %ut_logical is not called - only  the values
                               1 and 0 are supported (for yes/no)
  -----------------------------------------------------------------------------
  Usage Notes:

   Every other macro should call PARMDEF to assign default values to each of
   its parameters.  This will print the parameter list with actual and 
   default values to the SAS log file for documentation.  This method also 
   facilitates calling macros specifying to called macros to use the called
   macro defaults.  The calling macro does not need to specify the acutal 
   default value - it just tells the called macro to use its defaults.  This
   facilitates maintenance of macros since calling macros need not change if
   a decision is made to change the defaults of called macros.

   The parameters of the parmdef macro begin with "_pd" in order to avoid 
   problems with the scope of macro variables.  If a calling macro has a
   parameter name in common with parmdef then parmdef cannot assign a value
   to the calling macro's parameter.  So, the prefix is added to the 
   parameters of parmdef to ensure no other macro has a parameter of the same
   name.

  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

   %ut_parmdef(type,data,data view,_pdrequired=1,_pdmacroname=caller)
                           assigns a default value of "data" to the parameter
                            TYPE and makes this a required parameter.  Allowed
                            values are either "data" or "view".  Used the 
                            recommended parameter "_pdmacroname" to specify
                            the name of the macro that calls ut_parmdef as
                            "caller".

   %ut_parmdef(outdlib,r)  assigns the default value of "r" to the parameter
                           OUTDLIB

   %ut_parmdef(data)       assigns the default value of null to the parameter
                           DATA

   %ut_parmdef(ok,0,0 1)   assigns a default value of "0" to the parameter OK
                           if no value is specified in the call, but checks 
                           a value specified in the call to verify it is either
                           0 or 1.
  -----------------------------------------------------------------------------
REVISION HISTORY SECTION:                 
                      
        Author &      
  Ver#   Peer Reviewer   Request #          Code History Description
  ----  ---------------- ---------------      ---------------------------------
  1.0   Greg Steffens    BMRGCS23Jun2004B     Original version of the broad-use
         Hui-Ping Chen                         module 23Jun2004
  2.0   Greg Steffens    BMRKW26JAN2006A      Added _pdignorecase parameter
          Vijay Sharma                         (deliberately not backward
                                               compatible with version 1)
                                              Added _pdabort parameter
                                               (deliberately not backward
                                               compatible with version 1).  If
                                               _pdabort is true and the global
                                               macro variable max_error_type is
                                               not equal to ERROR then
                                               ut_parmdef will abort SAS if
                                               _PDPARMNAME has a null value and
                                               _PDREQUIRED is true or if
                                               _PDPARMNAME has a value not
                                               allowed by _PDALLOWED.
                                              If _pdrequired is false then a
                                               null value is added to the
                                               allowed values of the parameter.
                                              Changed header commment to refer
                                               to ut_logical instead of logical
                                               macro
                                              Added some section macro comments
                                               for clarity
  3.0   Greg Steffens   BMRMSR08MAY2007       Do not abort when executing in SDD
  4.0   Craig Hansen    BMRCSH01DEC2010c      Updated header to reflect code 
         Keyi Wu                               validated for SAS v9.2.  Modified
                                               header to maintain compliance with
                                               current SOP Code Header.
  **eoh************************************************************************/
%global max_error_type;
%local valid max_error_type_original;
%if %bquote(&_pdparmname) = %then %do;
  %put (parmdef) required first positional parameter is missing - ending macro;
  %goto endmac;
%end;
%* ============================================================================;
%* If executing in SDD then do not allow abort - SDD does not support abort;
%* ============================================================================;
%if &sysver ^= 8.2 %then %do;
  %if %symglobl(_sddusr_) |  %symglobl(_sddprc_) |  %symglobl(sddparms)
   %then %do;
    %if %bquote(%upcase(&max_error_type)) ^= ERROR %then %do;
      %let max_error_type_original = &max_error_type;
      %let max_error_type = ERROR;
    %end;
  %end;
%end;
%*=============================================================================;
%* Assign default value to parameter when it has the value _default_;
%*=============================================================================;
%if %bquote(%upcase(&&&_pdparmname)) = _DEFAULT_ %then
 %let &_pdparmname = &_pddefault;
%*=============================================================================;
%* Write the parameter information to the log when verbose mode is on;
%*=============================================================================;
%if &_pdverbose %then %put (ut_parmdef &_pdmacroname)
 &_pdparmname=&&&_pdparmname    default=&_pddefault;
%if &_pdrequired & %bquote(&&&_pdparmname) = %then %do;
  %*===========================================================================;
  %* If the parameter is required and has a null value then write a message;
  %*  to the log file.;
  %* If _pdabort is true and max_error_type is not error then abort SAS session;
  %*===========================================================================;
  %put UWARNING: (ut_parmdef &_pdmacroname) &_pdparmname is a required parameter
   but has not been specified;
  %if &_pdabort & %upcase(&max_error_type) ^= ERROR %then %do;
    %put UERROR(ut_parmdef): -- Aborting Program;
    ;
    data _null_;
      abort abend;
    run;
  %end;
%end;
%else %if %bquote(&_pdallowed) ^= %then %do;
  %*===========================================================================;
  %* If the value of the parameter is not in the list of allowed values;
  %*  then write a message to the log file.;
  %* If _pdabort is true and max_error_type is not error then abort SAS session;
  %*===========================================================================;
  %if ^ &_pdrequired & %bquote(&&&_pdparmname) = %then %let valid = 1;
  %else %if ^ &_pdignorecase & %sysfunc(indexw(&_pdallowed,&&&_pdparmname)) = 0
   %then %let valid = 0;
  %else %if &_pdignorecase &
   %sysfunc(indexw(%upcase(&_pdallowed),%upcase(&&&_pdparmname))) = 0 %then
   %let valid = 0;
  %else %let valid = 1;
  %if ^ &valid %then %do;
    %put UWARNING: (ut_parmdef &_pdmacroname) invalid value of parameter:
     &_pdparmname = &&&_pdparmname  (Valid: &_pdallowed);
    %if &_pdabort & %upcase(&max_error_type) ^= ERROR %then %do;
      %put UERROR(ut_parmdef): -- Aborting Program;
      ;
      data _null_;
        abort abend;
      run;
    %end;
  %end;
%end;
%*=============================================================================;
%* end of macro label;
%*=============================================================================;
%endmac:
%if &max_error_type_original ^= %then
 %let max_error_type = &max_error_type_original;
%mend;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******
<?xml version="1.0" encoding="UTF-8"?>
<process sessionid="1837697:10e18ba3b88:2735" sddversion="3.1" cdvoption="N">
  <parameters hideinvalidparms="N">
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDPARMNAME" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="1" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDDEFAULT" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="2" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDALLOWED" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="3" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDREQUIRED" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="4" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDVERBOSE" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="5" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDMACRONAME" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="6" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDIGNORECASE" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="7" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_PDABORT" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="8" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="MAX_ERROR_TYPE" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="9" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="VALID" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="10" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="MAX_ERROR_TYPE_ORIGINAL" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="11" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="SYSVER" cdvenable="Y" cdvrequired="Y" enable="Y" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT" order="12" />
  </parameters>
</process>

******PACMAN******************************************PACMAN******/
