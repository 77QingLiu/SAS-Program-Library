/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : output_pre.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : This code should be run just before the output part
                            of a program that generates an output (table,
                            listing or a graph). The macro is primarily used to define title 
                            and footnote. Besides, if figure=N(table/listing), it also prepare
                            for ods listing  

SOFTWARE/VERSION#         : SAS/Version 9.1
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : UT_DFMAC

BROAD-USE MODULES         : 
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to create the
                            meatadata as the input dataset (&inds)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name          Type         Default            Description and Valid Values
---------     ------------ ------------------ ----------------------------------
PRP_ID        required                        OUTPUT ID
PRP_DATIN     not required &SYSLAST           last dataset in the macro
PRP_FIGTLTXT  not required 2.5                title font size for figure
PRP_FIGFTTXT  not required 2.5                footnote font size for figure
PRP_CURPG     not required 1                  output current page number(ODS RTF)
PRP_TOTPG     not required 1                  output total page number(ODS RTF)
PRP_BODYTITLE not required BODYTITLE          ODS RTF BODYTITLE option
PRP_DEBUG     not required NO                 if run as debug model
INDS          required                              Metadata set with title footnote                       
NAMECOL not required    _NAME_           name variable e.g. title1 title2 
VALUECOL  not required   COL1              value variable for title/footnote
FIGURE  not required  N                         option Y/N for figure or not (table/listing) missing same to N
OUTRPTLIB not required  RPTLIB            output library used to retrieve the directory of output
TITADD    not required  Y                       option Y/N for showing PRP_ID in the first line of title missing same to N

USAGE NOTES:
   Users may call the output_pre macro to get final output. But this macro must be
   called together with output_post. Before doing this, please create proper
   metadata as input dataset.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%output_pre(prp_id=table 4,inds=t4_tf, figure=N);
proc report data = final;
...
run;
quit;
%output_post;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi

2.0   Ella Cheng           Use the macro in SDD
                                        Add: 1) INDS/NAMECOL/VALUECOL for combining using BUMS dt_title_fnote in SDD
                                                    to retrieve title footnote from arc tool.
                                                2) FIGURE: to choose if for table/listing or figure. 
                                                3) OUTRPTLIB: the location of output file, file name is from metadata
                                                4) ADDTITLE: the option controling whether prp_id be added as title1
                                        
                                        Disable: original in-text rtf section and keep only non-in-text section
                                                    readxls and _crtf
                                        
**eoh************************************************************************/

%macro output_pre(
prp_id=,
prp_datin=&syslast,
prp_figtltxt=2.5,
prp_figfttxt=2.5,
prp_curpg=1,
prp_totpg=1,
prp_bodytitle=,
prp_debug=no,
inds=,   
namecol=_name_,  
valuecol=col1,
figure=N,
outrptlib=rptlib,
titadd=Y
);
%*define macro variables;
%local prp_odsnm_  prp_filename out os sep i j k char1 char2;
%global data_mode;
%*define environment;
%if &sysscp = SUN 4 | &sysscp = SUN 64 | &sysscp = RS6000 | &sysscp = ALXOSF |
 &sysscp = HP 300 | &sysscp = HP 800 | &sysscp = LINUX | &sysscp = RS6000 | 
 &sysscp = SUN 3 | &sysscp = ALXOSF %then %let os = unix;
%else %let os = %sysfunc(lowcase(&sysscp));
%if &os=unix %then %let sep=/;
%else %let sep=\;
%*==============================================================================;
%* Note: Global macrovariable _Ad_RC is used to determine error conditions      ;
%*==============================================================================;

%if %upcase(%nrbquote(&sysscp)) = WIN %then %do;
  %let _pda = 0;
%end;
%else %do;
  %let _pda = 1;
%end;

%*=============================================================================;
%* Process parameters                                                          ;
%*=============================================================================;
%ut_parmdef(prp_id,,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(prp_datin,&syslast,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(prp_figtltxt,2.5,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(prp_figfttxt,2.5,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(prp_curpg,1,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(prp_totpg,1,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(prp_bodytitle,,,_pdrequired=0,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(prp_debug,no,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(inds,,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(namecol,_name_,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(valuecol,col1,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(figure,N,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(outrptlib,rptlib,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)
%ut_parmdef(titadd,Y,,_pdrequired=1,_pdmacroname=output_pre,_pdabort=&_pda)

%PUT NOTE: (&SYSMACRONAME) ------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME starts.;
%PUT NOTE: (&SYSMACRONAME) ------------------------;
%PUT NOTE: (&SYSMACRONAME);
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME: VERSION 1.0 ;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);


%** set macro variable to the last dataset **;
%let prp_odsnm_ = &prp_datin;

* capture the current users options and stroe so they can be put back after;
proc optsave out=work._proptn_;
run;

%if %upcase(&prp_debug) = %str(Y) or %upcase(&prp_debug) = %str(YES) %then %do;
  options symbolgen mlogic mprint;
%end;
%else %if %upcase(&prp_debug) = %str(N) or %upcase(&prp_debug) = %str(NO) %then %do;
  options nosymbolgen nomlogic nomprint;
%end;
 

%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)          Retrieving information of;
%PUT NOTE: (&SYSMACRONAME)           title footnote from &inds;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;
%do i=1 %to 10;
  %local title&i fnote&i title_cnt fnote_cnt;
  %let title&i=;
  %let fnote&i=;
%end;

%ut_dfmac(inds=&inds,namecol=&namecol,valuecol=&valuecol,allnum=,location=F);

%do i=1 %to &fnote_cnt;
    %if "&&fnote&i"^="" %then %do;
    %if %qleft(%qupcase(%qsubstr(&&fnote&i,1,6)))=REPORT %then %let  prp_filename=%qscan(&&fnote&i,-1,%str(/));
  %end;
%end;
   %let out=%sysfunc(pathname(&outrptlib))&sep%lowcase(%sysfunc(compress(&prp_filename)));

* Remove old titles and footnotes ;
title;footnote;

%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Section Creating titles, footnotes and output stream;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

%** Temporary output directory **;

%if %upcase(%substr(&figure,1,1))=Y %then %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Titles for Graph;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;
* title/footnote for Graph;
%if %upcase(%substr(&titadd,1,1))=Y  %then %do;
%do i=1 %to %eval(&title_cnt+1);
  %let j=%eval(&i-1);
  %if &i=1 %then %do;
     %let char1=%sysfunc(propcase(&prp_id));
     %let char2=Page &prp_curpg of &prp_totpg;
  %end;
  %else %if &i=2 %then %do;
     %let char1=&&title&j;
     %let char2=&systime &sysdate9;
  %end;
  %else %if &i=3 %then %do;
     %let char1=&&title&j;
     %let char2=&data_mode;
  %end;
  %else %do;
     %let char1=&&title&j;
     %let char2=;
  %end;
 %if "&char1"^="" and &char2^= %then %do;
  title&i j=l h=&prp_figtltxt  "&char1" j=r h=&prp_figtltxt "&char2";
  %end;
  %if "&char1"^="" and "&char2"="" %then %do;
  title&i j=l h=&prp_figtltxt  "&char1" ;
  %end;
%end;
%end;
%else %do;
  %if &i=1 %then %do;
     %let char1=&&title&i;
     %let char2=Page &prp_curpg of &prp_totpg;
  %end;
  %else %if &i=2 %then %do;
     %let char1=&&title&i;
     %let char2=&systime &sysdate9;
  %end;
  %else %if &i=3 %then %do;
     %let char1=&&title&i;
     %let char2=&data_mode;
  %end;
  %else %do;
     %let char1=&&title&i;
     %let char2=;
  %end;
  %if "&char1"^="" and "&char2"^="" %then %do;
  title&i j=l h=&prp_figtltxt  "&char1" j=r h=&prp_figtltxt "&char2";
  %end;
  %if "&char1"^="" and "&char2"="" %then %do;
  title&i j=l h=&prp_figtltxt  "&char1" ;
  %end;


%end;

%do i=1 %to %eval(&fnote_cnt+1);
  %if "&&fnote&i"^="" %then %do;
    footnote&i j=l h=&prp_figfttxt "&&fnote&i";
  %end;
%end;
  %goto end_prp;
%end; 


%else %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)  Titles for tables or listings;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

   * if it is the first page of the output then open output destination ;
   %if %eval(&prp_curpg) eq 1 and %upcase(%substr(&figure,1,1))^=Y %then %do;
      filename rtfout "&out";
      ods listing;
      filename tmpfile temp;
      proc printto new print=tmpfile;
      run;
   %end;

   * Title/footnote for tables or listings;
%if %upcase(%substr(&titadd,1,1))=Y  %then %do;
%do i=1 %to %eval(&title_cnt+1);
  %let j=%eval(&i-1);
  %if &i=1 %then %do;
     %let char1=%sysfunc(propcase(&prp_id));
  %end;
  %else %do;
     %let char1=&&title&j;
  %end;
   %if "&char1"^="" %then %do;
     title&i j=l "&char1";
  %end;
%end;
%end;
%else %do;
%do i=1 %to %eval(&title_cnt);
   %if "&&title&i"^="" %then %do;
     title&i j=l "&&title&i";
  %end;
%end;
%end;


%do i=1 %to %eval(&fnote_cnt);
  %if "&&fnote&i"^="" %then %do;
    footnote&i j=l "&&fnote&i";
  %end;
%end;

%goto end_prp;
%end; 
    
%end_prp: 

%if  %upcase(%substr(&figure,1,1))=Y %then %do;
* remove the date and number options as these cause errors if reset when using ODS RTF;
data work._proptn_;
   set work._proptn_;
   if compress(upcase(OPTNAME))="DATE" or compress(upcase(OPTNAME))="NUMBER" then delete;
run;

* reset the orignal options of the user;
proc optload data=work._proptn_;
run;

*-- Remove unwanted temporary data sets --**;
proc datasets ddname=work nolist nodetails;
  delete _proptn_; 
run;
quit;
%end;

%mend output_pre;

***********************************************************************;
***********    END OF OUTPUT_PRE MACRO   **********************************;
***********************************************************************;






/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="f5f6dc:13f04344755:-607b" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter id="PRP_ID" resolution="INTERNAL" type="TEXT" order="1">*/
/*  </parameter>*/
/*  <parameter id="PRP_DATIN" resolution="INTERNAL" type="TEXT" order="2">*/
/*  </parameter>*/
/*  <parameter id="PRP_FIGTLTXT" resolution="INTERNAL" type="TEXT" order="3">*/
/*  </parameter>*/
/*  <parameter id="PRP_FIGFTTXT" resolution="INTERNAL" type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter id="PRP_CURPG" resolution="INTERNAL" type="TEXT" order="5">*/
/*  </parameter>*/
/*  <parameter id="PRP_TOTPG" resolution="INTERNAL" type="TEXT" order="6">*/
/*  </parameter>*/
/*  <parameter id="PRP_BODYTITLE" resolution="INTERNAL" type="TEXT" order="7">*/
/*  </parameter>*/
/*  <parameter id="PRP_DEBUG" resolution="INTERNAL" type="TEXT" order="8">*/
/*  </parameter>*/
/*  <parameter id="INDS" resolution="INTERNAL" type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter id="NAMECOL" resolution="INTERNAL" type="TEXT" order="10">*/
/*  </parameter>*/
/*  <parameter id="VALUECOL" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter id="FIGURE" resolution="INTERNAL" type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter id="OUTRPTLIB" resolution="INTERNAL" type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter id="TITADD" resolution="INTERNAL" type="TEXT" order="14">*/
/*  </parameter>*/
/*  <parameter id="SYSLAST" resolution="INTERNAL" type="TEXT" order="15">*/
/*  </parameter>*/
/*  <parameter id="PRP_ODSNM_" resolution="INTERNAL" type="TEXT" order="16">*/
/*  </parameter>*/
/*  <parameter id="PRP_FILENAME" resolution="INTERNAL" type="TEXT" order="17">*/
/*  </parameter>*/
/*  <parameter id="OS" resolution="INTERNAL" type="TEXT" order="18">*/
/*  </parameter>*/
/*  <parameter id="SEP" resolution="INTERNAL" type="TEXT" order="19">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="20">*/
/*  </parameter>*/
/*  <parameter id="J" resolution="INTERNAL" type="TEXT" order="21">*/
/*  </parameter>*/
/*  <parameter id="K" resolution="INTERNAL" type="TEXT" order="22">*/
/*  </parameter>*/
/*  <parameter id="CHAR1" resolution="INTERNAL" type="TEXT" order="23">*/
/*  </parameter>*/
/*  <parameter id="CHAR2" resolution="INTERNAL" type="TEXT" order="24">*/
/*  </parameter>*/
/*  <parameter id="DATA_MODE" resolution="INTERNAL" type="TEXT" order="25">*/
/*  </parameter>*/
/*  <parameter id="SYSSCP" resolution="INTERNAL" type="TEXT" order="26">*/
/*  </parameter>*/
/*  <parameter id="SYSMACRONAME" resolution="INTERNAL" type="TEXT" order="27">*/
/*  </parameter>*/
/*  <parameter id="TITLE_CNT" resolution="INTERNAL" type="TEXT" order="28">*/
/*  </parameter>*/
/*  <parameter id="FNOTE_CNT" resolution="INTERNAL" type="TEXT" order="29">*/
/*  </parameter>*/
/*  <parameter id="FNOTE" resolution="INTERNAL" type="TEXT" order="30">*/
/*  </parameter>*/
/*  <parameter id="TITLE" resolution="INTERNAL" type="TEXT" order="31">*/
/*  </parameter>*/
/*  <parameter id="SYSTIME" resolution="INTERNAL" type="TEXT" order="32">*/
/*  </parameter>*/
/*  <parameter id="SYSDATE9" resolution="INTERNAL" type="TEXT" order="33">*/
/*  </parameter>*/
/*  <parameter id="OUT" resolution="INTERNAL" type="TEXT" order="34">*/
/*  </parameter>*/
/*  <parameter id="_PDA" resolution="INTERNAL" type="TEXT" order="35">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/