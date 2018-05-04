%macro ut_contentest(LIB      = _default_,
                      DATASET  = _default_,
                      MODE     = _default_,
                      TITLE    = _default_,
                      FOOT     = _default_,
							 DEBUG    = _default_);

/*soh*********************************************************************************************
  Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME   : ut_contentest.sas
   TYPE                    : user utility
   DESCRIPTION             : This macro produces a proc contents of the name of the data
                             set passed in only when MODE = TD or PD
   DOCUMENT LIST           : U:\SPREE\DEXTR\QA\BROAD_USE_MODULES\UT_CONTENTEST\QA_DOCUMENTATION
   SOFTWARE/VERSION#       : SAS Version 9.1.3 (Unix)
   INFRASTRUCTURE          : SDD Version 3.2
   BROAD-USE MODULES       : ut_paramdef, ut_logical, ut_titlstrt from the location
                             \\lillyce\prd\general\bums_stat\macro_library
   INPUT                   : none
   OUTPUT                  : none
   VALIDATION LEVEL        : Level 6
   REGULATORY STATUS       : GCP
   TEMPORARY OBJECT PREFIX : N/A
--------------------------------------------------------------------------------
  Parameters:
   Name     Type     Default  Description and Valid Values
   -------- -------- -------- --------------------------------------------------
   LIB      optional WORK     Refrence Name of Library in which dataset is present.
   DATASET  optional _LAST_   Name of the dataset, input to the proc contents procedure.
                              If a null value is passed, the last data set created will be
                              processed. Valid values: null, valid sas data set name.
   MODE     optional PP       Program mode of execution.
                              VALID VALUES: TD, TT, TP, PD, PP. ONLY VALUES TD OR PD WILL 
                              PRODUCE A PROC CONTENTS
   TITLE    optional          A title that will be used with the proc contents.
                              valid values: a character string up to 200 chars long.
   FOOT     optional          A footnote that will be used with the contents.
                              valid values: a character string up to 200 chars long.
                              The default is 'ut_contentest-001'.
   DEBUG    required  0       %logical value specifying whether debug mode is on or off.

--------------------------------------------------------------------------------
  Usage Notes:
--------------------------------------------------------------------------------
  Assumptions:
--------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %ut_contentest(Lib     = inlib,
	                Dataset = &DATA, 
						 Mode    = TD,
                   Title   = Contents of Input CDMS_Lab_Dlta_Ref Dataset);

------------------------------------------------------------------------------------------------
                     BROAD-USE MODULE HISTORY
------------------------------------------------------------------------------------------------
  Ver#  Author &
        Peer Reviewer           Request #         Description
  ----  ---------------         ----------------  ----------------------------------------------
  1.0   Dhirendra Kumar Singh   BMRNRR20OCT2004b  Original version of the broad-use module
        Michelle Barrick
  1.1   Gaurav Vashisht         CR04985921        Only the following change was made to this version 
                                                  of the BUM in SDD:
                                                    Updated the BUM header as per new BUM template
                                                    Updated version of the BUM

                                                  BUM Code is tested in SPREE and SDD environments as
                                                  per testplan Versions # 1.0 & 1.1 in SPREE and Version
                                                  # 1.2 and 1.3 in SDD.
       <Peer Reviewer>                            See Peer reviewer's name and signature in the completed Quality 
                                                  Review Tool and Test Plan

**eoh*******************************************************************************************/

   %ut_parmdef(mode,PP)

   %IF &MODE = TD OR &MODE = PD %THEN %DO;

     %put (ut_contentest version 1.1) macro starting;

     %ut_parmdef(dataset);
     %ut_parmdef(lib,WORK);
     %ut_parmdef(title);
     %ut_parmdef(foot);
     %ut_parmdef(debug,0);
     %ut_logical(debug);

%*==============================================================================;
%* INITIALIZE THE LOCAL MACRO VARIABLES THAT WILL BE USED IN MACRO PROCESSING.  ;
%*==============================================================================;

     %IF &debug=1 %THEN %DO;
       options mprint symbolgen mlogic;
     %END;
		
     %LOCAL _DATASET _TITLE _FOOT titlstrt;
     %ut_titlstrt(debug=&debug);
		
%*-------------------------------------------------------------------------------;
%*  DEFAULT THE DATA SET NAME IF A NULL VALUE WAS PASSED IN                      ;
%*-------------------------------------------------------------------------------;

     %IF &DATASET = %THEN
       %LET _DATASET = _LAST_;
     %ELSE
       %IF &LIB= %THEN
         %LET _DATASET = &DATASET;
       %ELSE
         %LET _DATASET = &LIB..&DATASET;
			
%*-------------------------------------------------------------------------------;
%*  DEFAULT THE TITLE TEXT IF A NULL VALUE WAS PASSED IN                         ;
%*-------------------------------------------------------------------------------;

     %IF %LENGTH(&TITLE) = 0 %THEN
       %LET _TITLE = Contents of Dataset &_DATASET;
     %ELSE
       %LET _TITLE = &TITLE;

%*-------------------------------------------------------------------------------;
%*  DEFAULT THE FOOTNOTE TEXT IF A NULL VALUE WAS PASSED IN                      ;
%*-------------------------------------------------------------------------------;

     %IF %LENGTH(&FOOT) = 0 %THEN
       %LET _FOOT = Contents of Dataset &_DATASET ends;
     %ELSE
       %LET _FOOT = &FOOT;

     PROC CONTENTS DATA = &_DATASET;
       title&titlstrt "&_TITLE";
       FOOTNOTE1 "&_FOOT";
     RUN;

     title&titlstrt;
     %put Macro ut_contentest ending;

   %END;

     options nomprint nosymbolgen nomlogic;

%mend ut_contentest;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******
<?xml version="1.0" encoding="UTF-8"?>
<process sessionid="1837697:10f0c7d0357:-4e11" sddversion="3.1" cdvoption="N">
  <parameters hideinvalidparms="N">
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LIB" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="1" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DATASET" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="2" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="MODE" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="3" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="TITLE" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="4" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="FOOT" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="5" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DEBUG" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="6" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_DATASET" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="7" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_TITLE" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="8" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_FOOT" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="9" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="TITLSTRT" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="10" />
  </parameters>
</process>

******PACMAN******************************************PACMAN******/