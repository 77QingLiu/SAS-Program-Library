%macro ut_dupword(string);
/*soh****************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_dupword
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Function-style macro that returns a 1 if any duplicate
                    : words are found in a string, 0 otherwise
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : N/A
INPUT               : N/A
OUTPUT              : Macro returns a 0 or 1
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_dupword/documentation/ut_dupword_rd.doc
ASSUMPTIONS         : none
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------

BROAD-USE MODULE SPECIFIC INFORMATION: Check for duplicate words in a string

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: N/A

PARAMETERS:

Name       Type      Default   Description and Valid Values
---------- --------  --------  ---------------------------------------------------
STRING     Optional  n/a       The string to be searched for duplicates

--------------------------------------------------------------------------------
USAGE NOTES:

This macro can be used inside or outside of a DATA step or procedure. The macro
returns a single character, either a 0 or 1, so it must be called in a program
location where this constitutes valid syntax.

The macro searches for duplicate words, where a "word" is defined as a string
of characters uninterrupted by a space.  E.g., if the string contains words
ABC and AB, this would not be considered a duplicate.

The search for duplicates is not case sensitive, e.g., if the string contains
words ABC and Abc, this WOULD be considered a duplicate.

This macro does not include calls to UT_PARMDEF or UT_LOGICAL for the
following reasons:

- This module does not have any parameters that need to be checked for possible
  invalid values
- This module does not have any on/off parameters to be processed by UT_LOGICAL

--------------------------------------------------------------------------------
TYPICAL MACRO CALL AND DESCRIPTION:

%if %ut_dupword(AAA AA AB ABC AA) %then %put AT LEAST ONE DUPLICATE FOUND;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen      BMRCSH05NOV2009A     Original version of the code
       Melinda Rodgers

 2.0   Chuck Bininger &  BMRCB29MAR2011D      Update header to reflect code validated
       Shong Demattos                         for SAS v9.2.  Modified header to maintain
                                              compliance with current SOP Code Header.
**eoh***************************************************************************/

%local i newstring currword dupfound;
%let string = %qupcase(&string);
%let dupfound  = 0;
%let newstring = ;
%let i = 1;
%do %while(%qscan(%bquote(&string),&i,%str( ))^=);
  %let currword = %qscan(%bquote(&string),&i,%str( ));
  %if %sysfunc(indexw(&newstring,&currword)) %then %let dupfound = 1;
  %let newstring = &newstring &currword;
  %let i = %eval(&i+1);
%end;
&dupfound

%mend ut_dupword;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="d12df7:124de9d1358:-5d68" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="STRING" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="I" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NEWSTRING" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CURRWORD" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DUPFOUND" maxlength="256" tabname="Parameters"*/
/*   processid="P1" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/