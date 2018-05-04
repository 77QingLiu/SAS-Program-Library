%macro ut_varlist(ds,type);
/*soh****************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_varlist
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Function-style macro that returns a list of variables
                      found in a specified dataset
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : ut_parmdef
INPUT               : N/A
OUTPUT              : Macro returns a list of variable names
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_varlist/documentation/ut_varlist_rd.doc
ASSUMPTIONS         : none
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION: Returns a list of variables in a dataset.

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: N/A

PARAMETERS:
Name       Type      Default   Description and Valid Values
---------- --------  --------  ---------------------------------------------------
DS         Optional  n/a       The dataset from which to obtain a list of
                               variables

TYPE       Optional  n/a       Enter N for numeric or C for character to restrict
                               list by variable type
--------------------------------------------------------------------------------
USAGE NOTES:

This macro can be used inside or outside of a DATA step or procedure.
The macro returns a list of variable names, so it must be called in a program
location where this constitutes valid syntax.

If the dataset specified on DS does not exist, or if the value passed for DS is
invalid or null, or if the dataset contains zero variables, then the macro
returns a null.

If TYPE is specified as N or C, and no variables of the specified type are in
the dataset, then the macro returns a null.

This macro does not include calls to UT_PARMDEF or UT_LOGICAL for the
following reasons:

- Because of the context in which this module is typically used, UT_PARMDEF
  output in the SAS log would appear within SAS	statements and make the log
  difficult to read
- This module does not have any on/off parameters to be processed by UT_LOGICAL

--------------------------------------------------------------------------------
TYPICAL MACRO CALL AND DESCRIPTION:

Example - The following step sets the length of all character variables
          in dataset TEST to $50, even if the list of variables is unknown:

          DATA TEST;
            LENGTH %ut_varlist(test,C) $50;
            SET TEST;
          RUN;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen       BMRCSH05NOV2009E    Original version of the code
       Melinda Rodgers

 2.0   Chuck Bininger &   BMRCB23MAR2011      Update header to reflect code validated
       Shong Demattos                         for SAS v9.2.  Modified header to maintain
                                              compliance with current SOP Code Header.

**eoh***************************************************************************/

%local i dsid varlist;

%*==============================================================================;
%*                                                                              ;
%*                          Begin parameter checks                              ;
%*                                                                              ;
%*==============================================================================;
%if %bquote(&type)^= %then %do;
        %if %sysfunc(indexw(N NUM NUMERIC,   %qupcase(&type))) %then %let type=N;
  %else %if %sysfunc(indexw(C CHAR CHARACTER,%qupcase(&type))) %then %let type=C;
  %else %do;
    %put UWARNING (UT_VARLIST): Invalid value specified for TYPE.;
    %return;
  %end;
%end;

%*==============================================================================;
%*                                                                              ;
%*                       Begin BUM Main Processing Logic                        ;
%*                                                                              ;
%*==============================================================================;
%let varlist=;
%if %bquote(&ds)^= %then %do;
  %if %sysfunc(exist(&ds)) %then %do;
    %let dsid=%sysfunc(open(&ds,i));
    %do i=1 %to %sysfunc(attrn(&dsid,nvars));
      %if &type= %then %do;
        %let varlist = &varlist %qupcase(%sysfunc(varname(&dsid,&i)));
      %end;
      %else %do;
        %if %sysfunc(vartype(&dsid,&i)) = %qupcase(&type) %then %do;
          %let varlist = &varlist %qupcase(%sysfunc(varname(&dsid,&i)));
        %end;
      %end;
    %end;
    %let dsid = %sysfunc(close(&dsid));
  %end;
%end;
&varlist

%mend ut_varlist;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="c0e18b:124e37a05a3:-49aa" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter id="DS" resolution="INTERNAL" type="TEXT" order="1">*/
/*  </parameter>*/
/*  <parameter id="TYPE" resolution="INTERNAL" type="TEXT" order="2">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="3">*/
/*  </parameter>*/
/*  <parameter id="DSID" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="VARLIST" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/