/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : read_xls.sas
CODE TYPE                 : Program
PROJECT NAME (optional)   : Japan I1F-JE-RHAT

DESCRIPTION               : this program is used to get title footnote from ARC tool Excel sheet TFL Req

SOFTWARE/VERSION#         : SAS/Version 9
INFRASTRUCTURE            : SDD version 3.5

LIMITED-USE MODULES       : 
BROAD-USE MODULES         : \lillyce\prd\general\bums\macro_library\ut_saslogcheck.sas
                            \lillyce\prd\general\bums\macro_library\dt_excel2sas.sas
INPUT                     : \ly2439821\I1F-JE-RHAT\intrm1\data\shared\arc_reporting_metadata\RHAT_interimDBL_ARCtool_v2.1_20131106.xlsx
OUTPUT                    : \ly2439821\I1F-JE-RHAT\intrm1\data\shared\arc_reporting_metadat\arc_reporting_metadata.sas7bdat

PROGRAM PURPOSE           : Convert the ARC metadata spreadsheet to SAS dataset
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : n/a
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:
(If CODE TYPE is Program, leave this section blank)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Jiashu Li
      
**eoh************************************************************************/

** Programming environment set up **;
%include &study_setup;

** Excel to SAS **;
%dt_excel2sas(outlib=arcmeta,
              select=ARC_Reporting_Metadata,
              excel_file=&excel,
              method=import,
              debug=0);
                                                                                                 
** Check log **;
%ut_saslogcheck;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="173b848a:144d6ca8365:6bd8" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="1" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P1" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="DISABLE" obfuscate="N" label="Input process" tabname="Parameters" baseoption="A" advanced="N" order="2" id="STUDY_SETUP" canlinktobasepath="Y" protect="Y" writefile="N" filetype="SAS" processid="P1" required="Y"*/
/*   resolution="INPUT" enable="N" type="INPROCESS">*/
/*   <default>*/
/*    <file system="SDD" source="DOMAIN" displaypath="/lillyce/qa/ly2439821/i1f_je_rhat/intrm2/programs_stat/author_component_modules" displayname="_SETUP_intrm2.sas"*/
/*     id="/lillyce/qa/ly2439821/i1f_je_rhat/intrm2/programs_stat/author_component_modules/_SETUP_intrm2.sas" itemtype="Item" type="sas" fileinfoversion="3.0">*/
/*    </file>*/
/*   </default>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="Process parameter values" resolution="INPUT" type="PARMFILE" baseoption="A" processid="P1" id="SDDPARMS" order="32" protect="N" enable="N" filetype="SAS7BDAT" autolaunch="N" canlinktobasepath="Y"*/
/*   userdefined="S" base="BASE_1" obfuscate="N" systemtype="SDDPARMS" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="sas7bdat">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm2/programs_stat" displayname="system_files" id="intrm2/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="SAS output" resolution="INPUT" type="LSTFILE" baseoption="A" processid="P1" id="&star;LST&star;" order="33" protect="N" enable="N" filetype="LST" autolaunch="N" canlinktobasepath="Y" userdefined="S"*/
/*   base="BASE_1" obfuscate="N" systemtype="&star;LST&star;" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="lst">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm2/programs_stat" displayname="system_files" id="intrm2/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="SAS log" resolution="INPUT" type="LOGFILE" baseoption="A" processid="P1" id="&star;LOG&star;" order="34" protect="N" enable="N" filetype="LOG" autolaunch="N" canlinktobasepath="Y" userdefined="S"*/
/*   base="BASE_1" obfuscate="N" systemtype="&star;LOG&star;" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="log">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm2/programs_stat" displayname="system_files" id="intrm2/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter base="BASE_1" obfuscate="N" label="Input file" tabname="Parameters" baseoption="A" advanced="N" order="35" id="EXCEL" canlinktobasepath="Y" writefile="Y" protect="N" filetype="TXT" processid="P1" required="N" enable="N"*/
/*   resolution="INPUT" type="INFILE">*/
/*   <default>*/
/*    <file system="RELATIVE" source="RELATIVE" displaypath="intrm2/data/shared/arc_reporting_metadata" displayname="RHAT_interimDBL2_ARCtool_v1.0_20140319.xlsx" id="intrm2/data/shared/arc_reporting_metadata/RHAT_interimDBL2_ARCtool_v1.0_20140319.xlsx"*/
/*     itemtype="Item" type="xlsx" fileinfoversion="3.0">*/
/*    </file>*/
/*   </default>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/