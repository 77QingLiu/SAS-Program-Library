%macro ut_printest(LIB     = _default_,
                    DATASET = _default_,
                    MODE    = _default_,
                    OBS     = _default_,
						  BY      = _default_,
						  VAR     = _default_,
						  TITLE   = _default_,
						  FOOT    = _default_,
						  UNIFORM = _default_,
						  DEBUG   = _default_);

/*soh************************************************************************************************
  	Eli Lilly and Company - Global Statistical Sciences - Broad-Use Module
   BROAD-USE MODULE NAME   : ut_printest.sas
   TYPE                    : user utility
   DESCRIPTION             : This macro produces a proc contents of the name of the data
                             set passed in only when MODE = TD or PD
   DOCUMENT LIST           : U:\SPREE\DEXTR\QA\BROAD_USE_MODULES\UT_CONTENTEST\QA_DOCUMENTATION
   SOFTWARE/VERSION#       : SAS Version 9.1.3 (Unix)
   INFRASTRUCTURE          : SDD Version 3.2
   BROAD-USE MODULES       : ut_paramdef, ut_logical, ut_titlstrt from the location
                             \\lillyce\prd\general\bums_stat\macro_library
   INPUT                   : none
   OUTPUT                  : none
   VALIDATION LEVEL        : Level 6
   REGULATORY STATUS       : GCP
   TEMPORARY OBJECT PREFIX : N/A
  ------------------------------------------------------------------------------------------------------------------------
  Parameters:
   Name     		Type     	Default  		Description
  --------- 		-------- 	-------- 		--------------------------------------------------
  LIB             optional    WORK           Refrence Name of Library in which dataset is present.
  DATASET         required                   Name of data set,to be printed.
  MODE            optional    PP             Program mode. Data set will be printed if value is TD or PD.
  OBS             optional                   Number of observations to be printed, if uninitialized,
                                             all of the observations will be printed.
  BY              optional                   List of variables to be used in the BY statement.
                                             NOTE : data must be sorted in this order before ut_printest
                                             is called. If uninitialized, no BY statement will be used.
  VAR             optional                   List of variables to be used in the VAR statement,if
                                             uninitialized, no VAR statement will be used.
  TITLE           optional                   Descriptive TITLE statement.
  FOOT            optional                   Descriptive FOOTNOTE statement.
  UNIFORM         optional    N              PROC PRINT option for uniform placement of columns across
                                             multiple pages. Default is UNIFORM=N. To turn ON, add UNIFORM=Y to call.
  DEBUG           required    0              %logical value specifying whether debug mode is on or off

  ------------------------------------------------------------------------------------------------------------------------
  Usage Notes:
  ------------------------------------------------------------------------------------------------------------------------
  Assumptions:

  ------------------------------------------------------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    %ut_printest(Lib     =  outlib,
	              Dataset =  &OUT, 
					  Mode    =  TD, 
					  Obs     = 10,
                 Title   = user specified title);

------------------------------------------------------------------------------------------------
                     BROAD-USE MODULE HISTORY
------------------------------------------------------------------------------------------------
  Ver#  Author &
        Peer Reviewer           Request #         Description
  ----  ---------------         ----------------  ----------------------------------------------
  1.0   Sunil Panghal           BMRNRR20OCT2004a  Original version of the broad-use module
        Michelle Barrick
  
  1.1   Gaurav Vashisht         CR04985918        Only the following change was made to this version 
                                                  of the BUM in SDD:
                                                    Updated the BUM header as per new BUM template
                                                    Updated version of the BUM

                                                  BUM Code is tested in SPREE and SDD environments as
                                                  per testplan Versions # 1.0 & 1.1 in SPREE and Version
                                                  # 1.2 and 1.3 in SDD.
       <Peer Reviewer>                            See Peer reviewer's name and signature in the completed Quality 
                                                  Review Tool and Test Plan

 **eoh*************************************************************************************************************/

   %ut_parmdef(mode,PP);

   %IF &MODE = TD OR &MODE = PD %THEN %DO;
     %put (ut_printest Version 1.1) macro starting;
     %ut_parmdef(lib,WORK);
     %ut_parmdef(dataset,_pdrequired=1);
     %ut_parmdef(obs);
     %ut_parmdef(by);
     %ut_parmdef(var);
     %ut_parmdef(title);
     %ut_parmdef(foot);
     %ut_parmdef(uniform,N);
     %ut_parmdef(debug,0);
     %ut_logical(debug);

%*==============================================================================;
%* EXECUTE THE PROGRAM ONLY WHEN ALL THE REQUIRED PARMS ARE SUPPLIED            ;
%*==============================================================================;

     %IF %LENGTH(&DATASET) NE 0 %THEN %DO;
       %IF &debug = 1 %THEN %DO;
         options mprint symbolgen mlogic;
       %END;

       %LOCAL _DATASET titlstrt;
       %ut_titlstrt(debug=&debug);
       %LET titlnum = &titlstrt;

       %IF &LIB = %THEN
         %LET _DATASET = &DATASET;
       %ELSE
         %LET _DATASET = &LIB..&DATASET;

       PROC PRINT DATA = &_DATASET

%*-------------------------------------------------------------------------------;
%* GENERATE CODE TO RESTRICT NUMBER OF OBS IF SELECTED                           ;
%*-------------------------------------------------------------------------------;

         %IF &OBS ^= %THEN
           %STR((OBS=&OBS));

%*-------------------------------------------------------------------------------;
%* GENERATE UNIFORM OPTION IF SELECTED                                           ;
%*-------------------------------------------------------------------------------;

         %IF (&UNIFORM EQ Y) %THEN %STR(UNIFORM);
           %STR(;);

%*-------------------------------------------------------------------------------;
%* GENERATE BY STATEMENT IF SELECTED                                             ;
%*-------------------------------------------------------------------------------;

         %IF &BY ^= %THEN
           %STR(BY &BY;);

%*-------------------------------------------------------------------------------;
%* GENERATE VAR STATEMENT IF SELECTED                                            ;
%*-------------------------------------------------------------------------------;

         %IF &VAR ^= %THEN
           %STR(VAR &VAR;);

%*-------------------------------------------------------------------------------;
%* GENERATE APPROPRIATE TITLE DEPENDING ON MODE                                  ;
%*-------------------------------------------------------------------------------;
      
         %IF &MODE = TD %THEN
           %STR(TITLE&titlnum "TEST PRINTOUT OF DATASET &_DATASET";);

         %ELSE
           %STR(TITLE&titlnum "PRINTOUT OF DATASET &_DATASET";);

%*-------------------------------------------------------------------------------;
%* GENERATE TITLE STATEMENT IF SELECTED                                          ;
%*-------------------------------------------------------------------------------;
	  
         %IF %LENGTH(&TITLE) ^=0 %THEN %DO;
           %LET titlnum=%eval(&titlnum + 1);
           %STR(TITLE&titlnum "&TITLE");
         %END;

%*-------------------------------------------------------------------------------;
%* GENERATE FOOT STATEMENT IF SELECTED, OTHERWISE PRINT BLANK FOOTNOTE           ;
%*-------------------------------------------------------------------------------;

         %IF %LENGTH(&FOOT) ^=0 %THEN
           %STR(FOOTNOTE1 "&FOOT";);
         %ELSE
           %STR(FOOTNOTE1 " ";);

%*-------------------------------------------------------------------------------;
%* IF NUMBER OF OBS RESTRICTED, PRINT THE NUMBER IN A TITLE                      ;
%*-------------------------------------------------------------------------------;

         %IF &OBS ^= %THEN %DO;
           %LET titlnum=%eval(&titlnum + 1);
           %STR(TITLE&titlnum "FIRST &OBS OBS";);
         %END;

       RUN;
       
%*==============================================================================;
%* CLEAR THE TITLE NUMBERS USED BY THE PROGRAM                                  ;
%*==============================================================================;

       title&titlstrt;
	 
     %END;
	  
     %put Macro ut_printest ending;

   %END;

     options nomprint nosymbolgen nomlogic;

%mend ut_printest;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******
<?xml version="1.0" encoding="UTF-8"?>
<process sessionid="1837697:10f0c7d0357:-4e11" sddversion="3.1" cdvoption="N">
  <parameters hideinvalidparms="N">
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LIB" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="1" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DATASET" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="2" />
    <parameter obfuscate="N" dependsaction="ENABLE" label="Text field" multiline="N" usecdv="N" tabname="Parameters" cdvquote="N" cdvrequired="N" cdvenable="Y" advanced="N" id="MODE" order="3" cdvmultiline="N" canlinktobasepath="N" protect="N" maxlength="256" quote="N" required="N" resolution="INPUT" enable="N" type="TEXT" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OBS" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="4" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="VAR" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="5" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="TITLE" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="6" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="FOOT" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="7" />
    <parameter obfuscate="N" dependsaction="ENABLE" label="Text field" multiline="N" usecdv="N" tabname="Parameters" cdvquote="N" cdvrequired="N" cdvenable="Y" advanced="N" id="UNIFORM" order="8" cdvmultiline="N" canlinktobasepath="N" protect="N" maxlength="256" quote="N" required="N" resolution="INPUT" enable="N" type="TEXT" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DEBUG" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="9" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_DATASET" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="10" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="TITLSTRT" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="11" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="TITLNUM" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="12" />
    <parameter canlinktobasepath="N" dependsaction="ENABLE" id="BY" cdvenable="Y" cdvrequired="N" enable="N" advanced="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT" order="13" />
  </parameters>
</process>

******PACMAN******************************************PACMAN******/