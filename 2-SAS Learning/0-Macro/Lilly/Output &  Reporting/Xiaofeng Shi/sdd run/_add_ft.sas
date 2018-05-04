/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : _ADD_FT.SAS
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : Output footnotes when the number of footnotes gt 6
                            
SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.5

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to check if
                            the metadata is set up
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name          Type         Default            Description and Valid Values
---------     ------------ ------------------ ----------------------------------
arcrptname    Required                        Unique Index Number or Output Name

USAGE NOTES:
   Users may call the _ADD_FT macro to add the footnotes when the number of foonotes
   is greater than 6. Users should manually add this macro in case the footnotes are too
   many to display.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

proc report data = final;
...
...
...
%_ADD_FT;
run;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Bin Zhang
**eoh************************************************************************/

      line @1 "";
      %macro loop_ft;
      %do prp_f = 1 %to &num_fnt;
         line @1 "%quote(&&_footnote&prp_f)";
      %end;
      %mend loop_ft;
      %loop_ft;
      line @1 " ";
      line @1 "Program Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.programs_stat&sep.&rpt_pgm..&pgm_type";
      line @1 "Output Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.programs_stat&sep.tfl_output&sep.&rpt_name..&rpt_type";	
      line @1 "Dataset Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.data&sep.shared&sep.ads";
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="-420f9462:1400e965071:-68a6" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS log" systemtype="&star;LOG&star;" tabname="System Files" baseoption="A" advanced="N" order="1" id="&star;LOG&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LOG"*/
/*   processid="P20" required="N" resolution="INPUT" enable="N" type="LOGFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS output" systemtype="&star;LST&star;" tabname="System Files" baseoption="A" advanced="N" order="2" id="&star;LST&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LST"*/
/*   processid="P20" required="N" resolution="INPUT" enable="N" type="LSTFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="Process parameter values" systemtype="SDDPARMS" tabname="System Files" baseoption="A" advanced="N" order="3" id="SDDPARMS" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS7BDAT"*/
/*   processid="P20" required="N" resolution="INPUT" enable="N" type="PARMFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="4" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P20" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_F" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUM_FNT" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_FOOTNOTE" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SEP" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DIR_ROOT" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEV_PHASE" maxlength="256"*/
/*   tabname="Parameters" processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="11" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="COMPOUND" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="STUDY" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ANALY_PHASE" maxlength="256"*/
/*   tabname="Parameters" processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_PGM" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="15" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PGM_TYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="16" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_NAME" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="17" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_TYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P20" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/