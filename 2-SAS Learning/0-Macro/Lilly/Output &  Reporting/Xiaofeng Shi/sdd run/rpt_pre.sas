/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : rpt_pre.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : This code should be run just before the output part
                            of a program that generates an output (table,
                            listing or a graph). This file has four separate
                            macros
                            1. _CREATE_TF (to read in metadata file)                            
                            2. RPT_PRE (to coordinate the correct output style)                            

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.5

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to create the
                            meatadata as the input dataset
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name          Type         Default            Description and Valid Values
---------     ------------ ------------------ ----------------------------------
RPT_IN        required                        ARC metadata
RPT_OUT       required     replib             output location
ARCDATA       not required arcmeta.arc_repor  input ARC metadata
                           ting_metadata
FIG_TLTXT     not required 2.5                title font size for figure
FIG_FTTXT     not required 2.5                footnote font size for figure
RPT_CURPG     not required 1                  output current page number(ODS RTF)
RPT_TOTPG     not required 1                  output total page number(ODS RTF)
RPT_DEBUG     not required NO                 if run as debug model
OUT_FT        not required YES                if show footnote

USAGE NOTES:
   Users may call the output_pre macro to get final output. But this macro must be
   called together with output_post. Before doing this, please create proper
   metadata as input dataset.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%rpt_pre(rpt_in=smdemp11.rtf);
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
      Bin Zhang 
**eoh************************************************************************/

%macro rpt_pre(rpt_in=,
               rpt_out=rptlib,
               arcdata=arcmeta.arc_reporting_metadata,
               fig_tltxt=2.5,
               fig_fttxt=2.5,
               rpt_curpg=1,
               rpt_totpg=1,
               pgm_debug=no,
               out_ft=yes
               );
%global sep;
** define environment;
%if &sysscp = SUN 4 | &sysscp = SUN 64 | &sysscp = RS6000 | &sysscp = ALXOSF |
    &sysscp = HP 300 | &sysscp = HP 800 | &sysscp = LINUX | &sysscp = RS6000 | 
    &sysscp = SUN 3 | &sysscp = ALXOSF %then %let os = unix;
%else %let os = %sysfunc(lowcase(&sysscp));

%if &os=unix %then %let sep=/;
%else %let sep=\;

%if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
   %let _pda = 0;
%end;
%else %do;
   %let _pda = 1;
%end;

%*=============================================================================;
%* Process parameters                                                          ;
%*=============================================================================;
%ut_parmdef(rpt_in,,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)
%ut_parmdef(rpt_out,rptlib,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)
%ut_parmdef(fig_tltxt,2.5,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)
%ut_parmdef(fig_fttxt,2.5,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)
%ut_parmdef(rpt_curpg,1,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)
%ut_parmdef(rpt_totpg,1,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)
%ut_parmdef(pgm_debug,no,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)
%ut_parmdef(out_ft,yes,,_pdrequired=1,_pdmacroname=rpt_pre,_pdabort=&_pda)

%PUT NOTE: (&SYSMACRONAME) ------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME starts.;
%PUT NOTE: (&SYSMACRONAME) ------------------------;
%PUT NOTE: (&SYSMACRONAME);
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME: VERSION 1.0 ;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);

%local rpt_rundate prp_macname;
%let prp_macname = &sysmacroname;

** capture the current users options and stroe so they can be put back after;
proc optsave out=work._proptn_;
run;

%if %upcase(&pgm_debug) = %str(Y) or %upcase(&pgm_debug) = %str(YES) %then %do;
   options symbolgen mlogic mprint;
%end;
%else %if %upcase(&pgm_debug) = %str(N) or %upcase(&pgm_debug) = %str(NO) %then %do;
   options nosymbolgen nomlogic nomprint;
%end;

%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Section 1 Retrieving information of;
%PUT NOTE: (&SYSMACRONAME)           dataset used, program running and calling _CREATE_TF macro;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

%** retreive details fro the given id variable from metadata **;
%_CREATE_TF(arcmetadata=&arcdata,arcrptname=&rpt_in);

%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Section 2 Retrieving information of running program;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

%PUT NOTE: (&SYSMACRONAME) OUTPUT NAME or INDEX NUMBER is &rpt_in;

%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) Creating last footnote;
%*****************************************************************************************************************;
%let rpt_rundate=%str(&systime &sysdate9);

/*%if &num_fnt=7 %then %do; */
/*   %let prp_j=%eval(&num_fnt+1);*/
/*   %let prp_2j=%eval(&num_fnt+2);*/
/*   %let prp_3j=%eval(&num_fnt+3);*/
/*   %global _footnote%eval(&num_fnt+1) _footnote%eval(&num_fnt+2) _footnote%eval(&num_fnt+3);*/
/*%end;*/
%if %eval(&num_fnt) gt 6 %then %do; 
   %let out_ft=no;
   %let prp_j=%eval(&num_fnt+1);
   %let prp_2j=%eval(&num_fnt+2);
   %let prp_3j=%eval(&num_fnt+3);
   %global _footnote%eval(&num_fnt+1) _footnote%eval(&num_fnt+2) _footnote%eval(&num_fnt+3);
%end;
%else %do;
   %let prp_j=%eval(&num_fnt+2);
   %let prp_2j=%eval(&num_fnt+3);
   %let prp_3j=%eval(&num_fnt+4);
   %global _footnote%eval(&num_fnt+2) _footnote%eval(&num_fnt+3) _footnote%eval(&num_fnt+4);
%end;

**create directory name for final footnote;
data _null_;
   length fotnot&prp_j $&_ls fotnot&prp_2j $&_ls fotnot&prp_2j $&_ls fotnot&prp_3j $&_ls;
   fotnot&prp_j="Program Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.programs_stat&sep.&rpt_pgm..&pgm_type";
   fotnot&prp_2j="Output Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.programs_stat&sep.tfl_output&sep.&rpt_name..&rpt_type";	
   fotnot&prp_3j="Dataset Location: &sep.&sep.&dir_root.&sep.&dev_phase.&sep.&compound.&sep.&study.&sep.&analy_phase.&sep.data&sep.shared&sep.ads";
   call symput("_footnote&prp_j",left(fotnot&prp_j));
   call symput("_footnote&prp_2j",left(fotnot&prp_2j));    
   call symput("_footnote&prp_3j",left(fotnot&prp_3j));
run;

%PUT NOTE: (&SYSMACRONAME) last footnote is "&&_footnote&prp_j";
%PUT NOTE: (&SYSMACRONAME) last footnote is "&&_footnote&prp_2j";
%PUT NOTE: (&SYSMACRONAME) last footnote is "&&_footnote&prp_3j";

%** Remove old titles and footnotes **;
title;footnote;

%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Section 3 Creating titles, footnotes and output stream;
%PUT NOTE: (&SYSMACRONAME)            specific for (&pgm_type);
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

%if %upcase(&rpt_fmt)=F %then %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) 3.1 Options for Graph;
%*****************************************************************************************************************;

   %** General options for figures**;
   %let prp_tmpfile=%sysfunc(pathname(&rpt_out))&sep%lowcase(%sysfunc(compress(&rpt_name..&rpt_type)));

   %** Define titles **;
   %if %eval(&num_ttl) eq 2 %then %do; 
      title1 j=l h=&fig_tltxt "&_title1" j=r h=&fig_tltxt "Page &rpt_curpg of &rpt_totpg";
      title2 j=l h=&fig_tltxt "&_title2" j=r h=&fig_tltxt "&rpt_rundate";
      title3 j=r h=&fig_tltxt "&referenc";
   %end;

   %if %eval(&num_ttl) eq 3 %then %do; 
      title1 j=l h=&fig_tltxt "&_title1" j=r h=&fig_tltxt "Page &rpt_curpg of &rpt_totpg";
      title2 j=l h=&fig_tltxt "&_title2" j=r h=&fig_tltxt "&rpt_rundate";
      title3 j=l h=&fig_tltxt "&_title3" j=r h=&fig_tltxt "&referenc";
   %end;

   %if %eval(&num_ttl) eq 4 %then %do; 
      title1 j=l h=&fig_tltxt "&_title1" j=r h=&fig_tltxt "Page &rpt_curpg of &rpt_totpg";
      title2 j=l h=&fig_tltxt "&_title2" j=r h=&fig_tltxt "&rpt_rundate";
      title3 j=l h=&fig_tltxt "&_title3" j=r h=&fig_tltxt "&referenc";
      title4 j=l h=&fig_tltxt "&_title4";
   %end;

   %if %eval(&num_ttl) eq 5 %then %do; 
      title1 j=l h=&fig_tltxt "&_title1" j=r h=&fig_tltxt "Page &rpt_curpg of &rpt_totpg";
      title2 j=l h=&fig_tltxt "&_title2" j=r h=&fig_tltxt "&rpt_rundate";
      title3 j=l h=&fig_tltxt "&_title3" j=r h=&fig_tltxt "&referenc";
      title4 j=l h=&fig_tltxt "&_title4";
      title5 j=l h=&fig_tltxt "&_title5";
   %end;

   %** Define the report footnotes, ensuring that they are left-aligned *;
   %do prp_f = 1 %to &num_fnt;
      footnote%eval(&prp_f) j=l h=&fig_fttxt "&&_footnote&prp_f";
   %end;

   footnote&prp_j j=l h=&fig_fttxt "&&_footnote&prp_j";
   footnote&prp_2j j=l h=&fig_fttxt "&&_footnote&prp_2j";
   footnote&prp_3j j=l h=&fig_fttxt "&&_footnote&prp_3j";
   %goto end_prp;
%end; %*graph output;

%if %upcase(&rpt_fmt)=T or %upcase(&rpt_fmt)=L %then %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) 3.2 Options for tables or listings;
%*****************************************************************************************************************;

   %** General options for tables or listings**;
   %let prp_tmpfile=%sysfunc(pathname(&rpt_out))&sep%lowcase(%sysfunc(compress(&rpt_name..&rpt_type)));

   %** if it is the first page of the output then open output destination **;
   %if %eval(&rpt_curpg) eq 1 %then %do;
      filename rtfout "&prp_tmpfile";
      ods listing;
	   filename tmpfile temp;
      proc printto new print=tmpfile;
      run;
   %end;

   %** Define titles **;
   %if %eval(&num_ttl) eq 1 %then %do; 
      title1 j=l "&_title1";
      title2 j=l "";
      title3 j=l "";
   %end;

   %if %eval(&num_ttl) eq 2 %then %do; 
      title1 j=l "&_title1";
      title2 j=l "&_title2";
      title3 j=l "";
   %end;

   %if %eval(&num_ttl) eq 3 %then %do; 
      title1 j=l "&_title1";
      title2 j=l "&_title2";
      title3 j=l "&_title3";
   %end;

   %if %eval(&num_ttl) eq 4 %then %do; 
      title1 j=l "&_title1";
      title2 j=l "&_title2";
      title3 j=l "&_title3";
      title4 j=l "&_title4";
   %end;

   %if %eval(&num_ttl) eq 5 %then %do; 
      title1 j=l "&_title1";
      title2 j=l "&_title2";
      title3 j=l "&_title3";
      title4 j=l "&_title4";
      title5 j=l "&_title5";
   %end;

   %** Define the report footnotes, ensuring that they are left-aligned *;
   %if %upcase(&out_ft) = %str(Y) or %upcase(&out_ft) = %str(YES) %then %do;
      %do prp_f = 1 %to &num_fnt;
         footnote%eval(&prp_f) j=l "&&_footnote&prp_f";
      %end;

      footnote&prp_j j=l "&&_footnote&prp_j";
      footnote&prp_2j j=l "&&_footnote&prp_2j";
      footnote&prp_3j j=l "&&_footnote&prp_3j";
   %end;

   %else %if %upcase(&out_ft) = %str(N) or %upcase(&out_ft) = %str(NO) %then %do;
      footnote;
   %end;

   %goto end_prp;

%end; %*non-intext output;
		

%end_prp: %*End of titles footnotes and output stream section;

%if %upcase(&rpt_fmt)=T or %upcase(&rpt_fmt)=L or %upcase(&rpt_fmt)=F %then %do;

** remove the date and number options as these cause errors if reset when using ODS RTF;
data work._proptn_;
   set work._proptn_;
   if compress(upcase(OPTNAME))="DATE" or compress(upcase(OPTNAME))="NUMBER" then delete;
run;

** reset the orignal options of the user;
proc optload data=work._proptn_;
run;

**-- Remove unwanted temporary data sets --**;
proc datasets ddname=work nolist nodetails;
	delete _proptn_; 
run;
quit;

%end;

%PUT NOTE: (&SYSMACRONAME) ---------------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    The programming section specific for (&pgm_type) ends here.;
%PUT NOTE: (&SYSMACRONAME) ---------------------------------------------------------------------;

%mend rpt_pre;

***********************************************************************;
***********    END OF RPT_PRE MACRO   **********************************;
***********************************************************************;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="-3a581569:1400b60e1ff:-3f72" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_IN" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_OUT" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="FIG_TLTXT" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="FIG_FTTXT" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_CURPG" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_TOTPG" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PGM_DEBUG" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OUT_FT" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="OS" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_PDA" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="11" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_RUNDATE" maxlength="256"*/
/*   tabname="Parameters" processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_MACNAME" maxlength="256"*/
/*   tabname="Parameters" processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUM_FNT" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_J" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="15" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_2J" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="16" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_3J" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="17" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_LS" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="18" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DIR_ROOT" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="19" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="DEV_PHASE" maxlength="256"*/
/*   tabname="Parameters" processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="20" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="COMPOUND" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="21" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="STUDY" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="22" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ANALY_PHASE" maxlength="256"*/
/*   tabname="Parameters" processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="23" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_PGM" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="24" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PGM_TYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="25" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_NAME" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="26" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_FOOTNOTE" maxlength="256"*/
/*   tabname="Parameters" processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="27" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_FMT" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="28" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_TMPFILE" maxlength="256"*/
/*   tabname="Parameters" processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="29" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SEP" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="30" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUM_TTL" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="31" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_TITLE1" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="32" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_TITLE2" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="33" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="REFERENC" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="34" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_TITLE3" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="35" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_TITLE4" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="36" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_TITLE5" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="37" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_F" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="38" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_TYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="39" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ARCDATA" maxlength="256" tabname="Parameters"*/
/*   processid="P12" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/