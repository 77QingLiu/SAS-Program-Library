/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : page_break.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : H3E-GH-B015|LY231514

DESCRIPTION               : create the variable "_page" for break page

SOFTWARE/VERSION#         : SAS/Version 9
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a
BROAD-USE MODULES         : n/a

INPUT                     : n/a
OUTPUT                    : n/a

PROGRAM PURPOSE           : create table of freq of SOC PT
VALIDATION LEVEL          : 4
REQUIREMENTS              : n/a
ASSUMPTIONS               : n/a
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name                 Type     Default    Description and Valid Values
---------            -------- ---------- --------------------------------------------------
_ds	                  required                Input dataset
_out                  required                Output dataset
_bygroup           required                Analysis group
_soc                  required                High level item
_pt                   not required            Low level item
_order               required                Sort order
_reverse           not required           Calculate the raw/reverse
_spec           not required          		 Define the special variable which should be located at the bottom, e.g. Uncoded

USAGE NOTES: n/a

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0  Thomas Guo          Original version of the code
     Weishan Shi
  **eoh************************************************************************/

*******************************************************************************;
* Macro *;
*******************************************************************************;
%macro page_break(_dsin=,_dsout=,_var=,_linenum=);
proc sql noprint;
	create table page_break as
	select &_var., count(1) as __subnum
	from &_dsin.
	group by &_var.
	;
quit;

data page_break;
	retain _page _sum 0;
	set page_break;
	by &_var.;
/*	create page */
	if _sum<=&_linenum. and (_sum+__subnum)<=&_linenum. then do;
		_sum = _sum+__subnum;
	end;
	else if _sum<=&_linenum. and (_sum+__subnum)>&_linenum. then do;
		_sum = __subnum;
		_page = _page+1;
	end;
	else if _sum>&_linenum. then do;
		_sum = __subnum;
		_page = _page+1;
	end;
run;

data &_dsout.(drop=_sum __subnum _temp_ _addpage);
	merge &_dsin. page_break;
	by &_var.;
	retain _temp_  _addpage 0;
	if _subnum>&_linenum. then do;
		_temp_=_temp_+1;
		if _temp_>&_linenum. then do;
			_addpage=_addpage+1;
			_temp_=1;
		end;
	end;
	_page=_page+_addpage;
run;


%mend page_break;

/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="bc56a2:13f5a47a3ec:-7545" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_DS" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_OUT" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_BYGROUP" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_SOC" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_PT" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_ORDER" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_REVERSE" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_CATG" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_CATG_SQL" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="GRPNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_N" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BIG_N_" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/