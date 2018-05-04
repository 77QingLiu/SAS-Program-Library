%macro ut_numwords(string);
/*soh****************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME           : ut_numwords
CODE TYPE           : Broad-use Module
PROJECT NAME        :
DESCRIPTION         : Function-style macro that returns the number of words
                      in a string
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows
LIMITED-USE MODULES : N/A
BROAD-USE MODULES   : N/A
INPUT               : N/A
OUTPUT              : Macro returns a number
VALIDATION LEVEL    : 6
REQUIREMENTS        : https://sddchippewa.sas.com/webdav/lillyce/qa/general/bums/
                    : ut_numwords/documentation/ut_numwords_rd.doc
ASSUMPTIONS         : None
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION: Returns the number of words in a string.

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: N/A

PARAMETERS:
Name       Type      Default   Description and Valid Values
---------- --------  --------  ---------------------------------------------------
STRING     Optional  n/a       The string containing the words to be counted

--------------------------------------------------------------------------------
USAGE NOTES:

This macro can be used inside or outside of a DATA step or procedure. The macro
returns a single number, so it must be called in a program location where this
constitutes valid syntax.

The macro counts the number of words, where a "word" is defined as a string
of characters uninterrupted by a space.  E.g., the string AAA AB ABC results
in a value of 3.

This macro does not include calls to UT_PARMDEF or UT_LOGICAL for the
following reasons:

- This module does not have any parameters that need to be checked for possible
  invalid values
- This module does not have any on/off parameters to be processed by UT_LOGICAL

--------------------------------------------------------------------------------
TYPICAL MACRO CALL AND DESCRIPTION:

%put THE NUMBER OF WORDS IN STRING "AB ABC AA" IS %ut_numwords(AB ABC AA);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
 Ver#  Peer Reviewer     Request #            Code History Description
 ----  ----------------  -------------------  --------------------------------
 1.0   Craig Hansen      BMRCSH05NOV2009D     Original version of the code
       Melinda Rodgers

 2.0   Chuck Bininger &  BMRCB28MAR2011B      Update header to reflect code validated
       Shong Demattos                         for SAS v9.2.  Modified header to maintain
                                              compliance with current SOP Code Header.
**eoh***************************************************************************/
%local nwords;
%let nwords=0;
%do %while(%qscan(&string,%eval(&nwords+1),%str( ))^=);
  %let nwords=%eval(&nwords+1);
%end;
&nwords

%mend ut_numwords;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="d12df7:124de9d1358:-5d68" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="STRING" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="1">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="NWORDS" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="2">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/