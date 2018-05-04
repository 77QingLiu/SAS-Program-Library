/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : rpt_post.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : This code should be run just after the output part
                            of a program that generates an output (table,
                            listing or a graph).                             

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to create the
                            ARC meatadata as the input dataset
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name          Type         Default            Description and Valid Values
---------     ------------ ------------------ ----------------------------------
POR_DEBUG     not required NO                 if run as debug model
PGNUM         not required 1                  1 - pages less and equal than 999
                                              2 - pages less and equal than 9999
                                              3 - pages less and equal than 99999

USAGE NOTES:
   Users may call the output_post macro to get final output. But this macro must be
   called together with output_pre. Before doing this, please create proper
   metadata as input dataset.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%rpt_pre(rpt_in=smdemp11.rtf,pgnum=1);
proc report data = final;
...
run;
quit;
%rpt_post;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi
**eoh************************************************************************/

%macro rpt_post(por_debug=no,pgnum=1);

%PUT NOTE: (&SYSMACRONAME) -----------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME starts here.;
%PUT NOTE: (&SYSMACRONAME) -----------------------------;

/*options ls=&ls ps=&ps;*/

/*** capture the current users options and stroe so they can be put back after;*/
/*proc optsave out=work._proptn_;*/
/*run;*/

%if %upcase(&por_debug) = %str(Y) or %upcase(&por_debug) = %str(YES) %then %do;
   options symbolgen mlogic mprint;
%end;
%else %if %upcase(&por_debug) = %str(N) or %upcase(&por_debug) = %str(NO) %then %do;
   options nosymbolgen nomlogic nomprint;
%end;

%************************************************************************************************************;
%**          Section 3   Output closing for RTF (START)                                                   ***;
%************************************************************************************************************;

%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    The programming section specific for RTF closing starts here.;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;

	%** close ods rtf if plot/figure and reset back to listing **;
	%if %upcase(&rpt_fmt)=F %then %do;
        ods listing;
	%end;

 	%** Close ods rtf if non-intext output **;
	%else %if %upcase(&rpt_fmt)=T or %upcase(&rpt_fmt)=L %then %do;
        proc printto ;
        run;
        %if %eval(&pgnum) eq 1 %then %do;
           %a_out2rtf(in = tmpfile, out = rtfout ,_o2r_PrpMdYN=Y ,_o2r_PrpMd=&referenc.);
        %end;
        %else %if %eval(&pgnum) eq 2 %then %do;
           %a_out2rtf(in = tmpfile, out = rtfout ,_o2r_PrpPgFMT  = %bquote(Page XXXX of YYYY), 	_o2r_PrpPgFMTC = %bquote(XXXX), _o2r_PrpPgFMTM = %bquote(YYYY),_o2r_PrpMdYN=Y ,_o2r_PrpMd=&referenc.);;
        %end;
        %else %if %eval(&pgnum) eq 3 %then %do;
           %a_out2rtf(in = tmpfile, out = rtfout ,_o2r_PrpPgFMT  = %bquote(Page XXXXX of YYYYY), 	_o2r_PrpPgFMTC = %bquote(XXXXX), _o2r_PrpPgFMTM = %bquote(YYYYY),_o2r_PrpMdYN=Y ,_o2r_PrpMd=&referenc.);;
        %end;
		  filename tmpfile clear;
        filename rtfout clear;
	%end;

/*%if %upcase(&rpt_fmt)=F or %upcase(&rpt_fmt)=T or %upcase(&rpt_fmt)=L %then %do;*/
/*** reset the orignal options of the user;*/
/*proc optload data=work._proptn_;*/
/*run;*/
/*%end;*/

** delete the summary datasets;
/*check if dataset exists*/
proc datasets memtype=data;
   contents data=_all_;
   ods output Members=obs_outt;
run;

proc sql;
   select name from obs_outt where index(upcase(name),"OUT_T") gt 0;
quit;

%if &sqlobs gt 0 %then %do;
proc datasets library=work;
   delete out_t: obs_outt;
run;
quit;
%end;

%else %if &sqlobs eq 0 %then %do;
proc datasets library=work;
   delete obs_outt;
run;
quit;
%end;

%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    The programming section specific for (&pgm_type) stops here.;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------------;

%mend rpt_post;
%***********************************************************************;
%***********    END OF MACRO       *************************************;
%***********************************************************************;


/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="46842d63:144aeb7fdee:-4146" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="POR_DEBUG" maxlength="256" tabname="Parameters"*/
/*   processid="P6" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_FMT" maxlength="256" tabname="Parameters"*/
/*   processid="P6" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="REFERENC" maxlength="256" tabname="Parameters"*/
/*   processid="P6" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PGM_TYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P6" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PGNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P6" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/
