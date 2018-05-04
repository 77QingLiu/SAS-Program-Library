%macro ut_findvar(ds,var,type);
/*soh****************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_findvar
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Function-style macro that returns a 1 if a specified
                    : variable is found in a specified dataset, 0 otherwise
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : N/A
INPUT               : N/A
OUTPUT              : Macro returns a 0 or 1
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_findvar/documentation/ut_findvar_rd.doc
ASSUMPTIONS         : none
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION: Determine whether a variable exists
                                       in a dataset.

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: N/A

PARAMETERS:
Name       Type      Default   Description and Valid Values
---------- --------  --------  ---------------------------------------------------
DS         Optional  n/a       The dataset in which to search for the variable

VAR        Optional  n/a       The variable to search for

TYPE       Optional  n/a       Enter N for numeric or C for character to restrict
                               search by variable type
--------------------------------------------------------------------------------
USAGE NOTES:

This macro can be used inside or outside of a DATA step or procedure. The macro
returns a single character, either a 0 or 1, so it must be called in a program
location where this constitutes valid syntax.

The macro returns a 1 if the variable specified on VAR is found in the dataset
specified on DS, 0 otherwise.  If the dataset specified on DS does not exist, or
if a null or invalid value is passed for DS or VAR, then the macro returns a 0.

If TYPE is specified as N or C, and the variable is found in the dataset but
does not match the specified type, then the macro returns a 0.

This macro does not include calls to UT_PARMDEF or UT_LOGICAL for the
following reasons:

- Because of the context in which this module is typically used, UT_PARMDEF
  output in the SAS log would appear within SAS	statements and make the log
  difficult to read
- This module does not have any on/off parameters to be processed by UT_LOGICAL

--------------------------------------------------------------------------------
TYPICAL MACRO CALL AND DESCRIPTION:

Example - Conditionally generate code if and only if variable SORTBY is a
          numeric variable in dataset TEST:

          %if %ut_findvar(test,sortby,N) %then %do;
            <conditional code>
          %end;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen      BMRCSH05NOV2009B     Original version of the code
       Melinda Rodgers

 2.0   Chuck Bininger &  BMRCB29MAR2011A      Update header to reflect code validated
       Shong Demattos                         for SAS v9.2.  Modified header to maintain
                                              compliance with current SOP Code Header.
**eoh***************************************************************************/

%local dsid varnum;

%*==============================================================================;
%*                                                                              ;
%*                          Begin parameter checks                              ;
%*                                                                              ;
%*==============================================================================;
%if %bquote(&var)^= %then %do;
  %if ^%sysfunc(nvalid(&var)) %then %let var=;
%end;

%if %bquote(&type)^= %then %do;
        %if %sysfunc(indexw(N NUM NUMERIC,   %qupcase(&type))) %then %let type=N;
  %else %if %sysfunc(indexw(C CHAR CHARACTER,%qupcase(&type))) %then %let type=C;
  %else %do;
    %put UWARNING (UT_FINDVAR): Invalid value specified for TYPE.;
    %return;
  %end;
%end;

%*==============================================================================;
%*                                                                              ;
%*                       Begin BUM Main Processing Logic                        ;
%*                                                                              ;
%*==============================================================================;
%if %bquote(&ds)^= and %bquote(&var)^= %then %do;
  %if %sysfunc(exist(&ds)) %then %do;
    %let dsid   = %sysfunc(open(&ds,i));
    %let varnum = %sysfunc(varnum(&dsid,&var));
    %if %sysfunc(varnum(&dsid,&var)) %then %do;
      %if &type= %then %do; 1 %end;
      %else %do;
        %if %sysfunc(vartype(&dsid,&varnum)) = %qupcase(&type) %then %do; 1 %end;
                                                               %else %do; 0 %end;
      %end;
    %end;
    %else %do; 0 %end;
    %let dsid = %sysfunc(close(&dsid));
  %end;
  %else %do; 0 %end;
%end;
%else %do; 0 %end;

%mend ut_findvar;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="c0e18b:124e37a05a3:-49aa" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter id="DS" resolution="INTERNAL" type="TEXT" order="1">*/
/*  </parameter>*/
/*  <parameter id="VAR" resolution="INTERNAL" type="TEXT" order="2">*/
/*  </parameter>*/
/*  <parameter id="TYPE" resolution="INTERNAL" type="TEXT" order="3">*/
/*  </parameter>*/
/*  <parameter id="DSID" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="VARNUM" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/