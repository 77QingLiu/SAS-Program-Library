%macro ut_numobs(ds);
/*soh****************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_numobs
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Function-style macro that returns the number of observations
                      in a specified dataset
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : N/A
INPUT               : N/A
OUTPUT              : Macro returns a number
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_numobs/documentation/ut_numobs_rd.doc
ASSUMPTIONS         : None
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION: Returns the number of observations in a
                                       dataset.

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: N/A

PARAMETERS:
Name       Type      Default   Description and Valid Values
---------- --------  --------  ---------------------------------------------------
DS         Optional  n/a       The dataset in which to determine the number of
                               observations
--------------------------------------------------------------------------------
USAGE NOTES:

This macro can be used inside or outside of a DATA step or procedure.
The macro returns the number of observations in the specified dataset.

If the dataset specified on DS does not exist, or if the value passed in for DS
is null or invalid, or if the dataset contains zero variables, then the macro
returns 0.

This macro does not include calls to UT_PARMDEF or UT_LOGICAL for the
following reasons:

- This module does not have any parameters that need to be checked for possible
  invalid values
- This module does not have any on/off parameters to be processed by UT_LOGICAL

--------------------------------------------------------------------------------
TYPICAL MACRO CALL AND DESCRIPTION:

Example - Print a message if there are zero observations in a dataset:

          %if %ut_numobs(data1)=0 %then %put NOTE: Dataset DATA1 has zero obs;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen      BMRCSH05NOV2009C     Original version of the code
       Melinda Rodgers

 2.0   Chuck Bininger &  BMRCB28MAR2011A      Update header to reflect code validated
       Shong Demattos                         for SAS v9.2.  Modified header to maintain
                                              compliance with current SOP Code Header.

**eoh***************************************************************************/
%local nobs dsid;

%*==============================================================================;
%*                                                                              ;
%*                          Begin parameter checks                              ;
%*                                                                              ;
%*==============================================================================;

%** N/A **;

%*==============================================================================;
%*                                                                              ;
%*                       Begin BUM Main Processing Logic                        ;
%*                                                                              ;
%*==============================================================================;
%let nobs=0;
%if %bquote(&ds)^= %then %do;
  %if %sysfunc(exist(&ds)) %then %do;
    %let dsid = %sysfunc(open(&ds));
    %if &dsid %then %do;
      %let nobs = %sysfunc(attrn(&dsid,nobs));
      %let dsid = %sysfunc(close(&dsid));
    %end;
  %end;
%end;
&nobs

%mend ut_numobs;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="d12df7:124de9d1358:-5d68" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DS" maxlength="256" tabname="Parameters"*/
/*   processid="P13" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NOBS" maxlength="256" tabname="Parameters"*/
/*   processid="P13" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DSID" maxlength="256" tabname="Parameters"*/
/*   processid="P13" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/