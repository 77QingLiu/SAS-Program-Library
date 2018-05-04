/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : output_pre_final.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : This code should be run just before the output part
                            of a program that generates an output (table,
                            listing or a graph). This file has four separate
                            macros
                            1. READXLS_FINAL (to import the study metadata)
                            2. _CRTF (to read in metadata file)
                            3. _RTFSTYLE (to generate RTF shell for intext tables)
                            4. OUTPUT_PRE_FINAL (to coordinate the correct output style)                            

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.4

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
PRP_ID        required                        OUTPUT ID
PRP_DATIN     not required &SYSLAST           last dataset in the macro
PRP_FIGTLTXT  not required 2.5                title font size for figure
PRP_FIGFTTXT  not required 2.5                footnote font size for figure
PRP_CURPG     not required 1                  output current page number(ODS RTF)
PRP_TOTPG     not required 1                  output total page number(ODS RTF)
PRP_ODSSTYLE  not required custom             ODS RTF style
PRP_BODYTITLE not required BODYTITLE          ODS RTF BODYTITLE option
PRP_DEBUG     not required NO                 if run as debug model
ANALY_POP     required                        analysis phase(interim,final DBL)
IFMT          not required missing(plain txt) output RTF format(ODS RTF/plain txt)
OUTFT         not required missing            if show footnote
                           (show footnote)

USAGE NOTES:
   Users may call the output_pre macro to get final output. But this macro must be
   called together with output_post. Before doing this, please create proper
   metadata as input dataset.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%output_pre(prp_id=28,analy_pop=primary);
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
**eoh************************************************************************/

%macro output_pre_final(
prp_id=,
prp_datin=&syslast,
prp_figtltxt=2.5,
prp_figfttxt=2.5,
prp_curpg=1,
prp_totpg=1,
prp_odsstyle=,
prp_bodytitle=,
prp_debug=no,
analy_pop=,
ifmt=,
outft=
);

%PUT NOTE: (&SYSMACRONAME) ------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME starts.;
%PUT NOTE: (&SYSMACRONAME) ------------------------;
%PUT NOTE: (&SYSMACRONAME);
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME: VERSION 1.0 ;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);

%global irpathu dirpath outpath ifmt2 prp_pdir stlin outloc;
%local prp_odsnm_ prp_rundate prp_macname;

%let prp_macname = &sysmacroname;
%let irpathu = &prp_root.\&prp_phase;
%let dirpath = &prp_proj.\&prp_analy.\programs_nonsdd;
%let outpath = tfl_output;
%let ifmt2 = &ifmt;

%** set macro variable to the last dataset **;
%let prp_odsnm_ = &prp_datin;

** capture the current users options and stroe so they can be put back after;
proc optsave out=work._proptn_;
run;

%if %upcase(&prp_debug) = %str(Y) or %upcase(&prp_debug) = %str(YES) %then %do;
	options symbolgen mlogic mprint;
%end;
%else %if %upcase(&prp_debug) = %str(N) or %upcase(&prp_debug) = %str(NO) %then %do;
	options nosymbolgen nomlogic nomprint;
%end;

%readxls_final(metadata=metadata_final);

%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Section 1 Retrieving information of;
%PUT NOTE: (&SYSMACRONAME)           dataset used, program running and calling _CRTF macro;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

%** retreive details fro the given id variable from metadata **;
%_CRTF(outid=&prp_id);

%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Section 2 Retrieving information of running program;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

%PUT NOTE: (&SYSMACRONAME) Reference id is &prp_id;

%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) Creating last footnote;
%*****************************************************************************************************************;
%let prp_rundate=%str(&systime &sysdate9);
%put &prp_rundate &csv_numfnt;

%if &csv_numfnt=7 %then %do; 
   %let prp_j=%eval(&csv_numfnt+1);
   %let prp_2j=%eval(&csv_numfnt+2);
   %let prp_3j=%eval(&csv_numfnt+3);
   %global _footnote%eval(&csv_numfnt+1) _footnote%eval(&csv_numfnt+2) _footnote%eval(&csv_numfnt+3);
%end;
%else %do;
   %let prp_j=%eval(&csv_numfnt+2);
   %let prp_2j=%eval(&csv_numfnt+3);
   %let prp_3j=%eval(&csv_numfnt+4);
   %global _footnote%eval(&csv_numfnt+2) _footnote%eval(&csv_numfnt+3) _footnote%eval(&csv_numfnt+4);
%end;

**create directory name for final footnote;
data _null_;
   text1 = "&prp_phase";
   text2 = "&dirpath";
   text3 = "&csv_prog..sas";
   text4 = "&outpath";
   text5 = "&prp_phase_p";
   call symput("prp_pdir",compress(cat("\\lillyce\",text1)));
   call symput("prp_pdir_p",compress(cat("\\lillyce\",text5)));
   call symput("stlin",compress(cat(text2,"\",text3)));
   call symput("outdir",compress(text4));
run;

%if &referenc=PDTM or &referenc=PDPM %then %do;
   %let outloc = &prp_pdir_p;
%end;
%else %do;
   %let outloc = &prp_pdir;
%end;

data _null_;
	length fotnot&prp_j $&_ls fotnot&prp_2j $&_ls gfotnot&prp_2j $&_ls fotnot&prp_3j $&_ls;
    fotnot&prp_j="Program Location: &outloc.\&stlin.";
	fotnot&prp_2j="Output Location: &outloc.\&dirpath.\&outpath.\&csv_outnm..rtf";
	gfotnot&prp_2j="Output Location: &outloc.\&dirpath.\&outpath.\&csv_outnm..gif";
	fotnot&prp_3j="Dataset Location: &outloc.\&prp_proj.\&prp_analy.\data\shared\ads";
	call symput("_footnote&prp_j",left(fotnot&prp_j));
	call symput("_footnote&prp_2j",left(fotnot&prp_2j));
    call symput("_gfootnote&prp_2j",left(gfotnot&prp_2j));
	call symput("_footnote&prp_3j",left(fotnot&prp_3j));
run;

%PUT NOTE: (&SYSMACRONAME) last footnote is "&&_footnote&prp_j";

%** Remove old titles and footnotes **;
title;footnote;

%if %upcase("&csv_progtype")= "RTF" or %upcase("&csv_progtype")= "GIF"%then %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME) Section 3 Creating titles, footnotes and output stream;
%PUT NOTE: (&SYSMACRONAME)            specific for (&csv_progtype);
%PUT NOTE: (&SYSMACRONAME) -------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME);
%*****************************************************************************************************************;

%** Temporary output directory **;
%global prp_tmpfile;

%if %upcase(%substr(&csv_phoenix,1,1))=F %then %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) 3.1 Options for Graph;
%*****************************************************************************************************************;

   %** General options for Graph**;
   %let prp_tmpfile=&irpathu.\&dirpath.\&outpath\%sysfunc(lowcase(&csv_outnm)).gif;
  
   %** Define titles **;
   %let titnot1 = &_title1;
   %let titnot2 = &_title2;
   %let titnot3 = &_title3;

   data _null_;
      call symput("_title1", compress("&titnot1","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
      call symput("_title2", compress("&titnot2","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
	  call symput("_title3", compress("&titnot3","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
   run;

   %if %eval(&csv_numttl) eq 3 %then %do; 
      title1 j=l h=&prp_figtltxt "&_title1" j=r h=&prp_figtltxt "Page &prp_curpg of &prp_totpg";
      title2 j=l h=&prp_figtltxt "&_title2" j=r h=&prp_figtltxt "&prp_rundate";
      title3 j=l h=&prp_figtltxt "&_title3" j=r h=&prp_figtltxt "&referenc";
   %end;

   %if %eval(&csv_numttl) eq 4 %then %do; 
      title1 j=l h=&prp_figtltxt "&_title1" j=r h=&prp_figtltxt "Page &prp_curpg of &prp_totpg";
      title2 j=l h=&prp_figtltxt "&_title2" j=r h=&prp_figtltxt "&prp_rundate";
      title3 j=l h=&prp_figtltxt "&_title3" j=r h=&prp_figtltxt "&referenc";
      title4 j=l h=&prp_figtltxt "&_title4";
   %end;

   %** Define the report footnotes, ensuring that they are left-aligned *;
   %do prp_f = 1 %to &csv_numfnt;
      footnote%eval(&prp_f) j=l h=&prp_figfttxt "&&_footnote&prp_f";
   %end;

   footnote&prp_j j=l h=&prp_figfttxt "&&_footnote&prp_j";
   footnote&prp_2j j=l h=&prp_figfttxt "&&_gfootnote&prp_2j";
   footnote&prp_3j j=l h=&prp_figfttxt "&&_footnote&prp_3j";
   %goto end_prp;
%end; %*graph output;

%if (%upcase(%substr(&csv_phoenix,1,1))=T or %upcase(%substr(&csv_phoenix,1,1))=L) and %length(&ifmt) gt 0 %then %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) 3.2 Options for intext tables or listings;
%*****************************************************************************************************************;

   %** General options for intext tables or listings**;
   %let prp_tmpfile=&irpathu.\&dirpath.\&outpath\%sysfunc(lowcase(&csv_outnm)).rtf;

   %** if it is the first page of the output then open output destination **;
   %if %eval(&prp_curpg) eq 1 %then %do;
      ods listing close;
      %** if no ODS style given in macro call then produce a temporary style **;
      %if &prp_odsstyle= %then %do;
         %_RTFSTYLE;
         %let prp_odsstyle=rtf_temp;
      %end;

      %if %upcase("&csv_orient")="LANDSCAPE" or %upcase("&csv_orient")="PORTRAIT" %then %do;
         %PUT NOTE: (&SYSMACRONAME) ORIENTATION DEFINED AS &csv_orient;
      %end;
      %else %do;
         %PUT %str(WARN)ING: (&SYSMACRONAME): No orientation defined in &SYSMACRONAME (macro variable CSV_ORIENT) - Default for intext will be used (portrait);
         %let csv_orient=LANDSCAPE;
      %end;

      %** Control where titles are printed **;
      %if %upcase(&prp_bodytitle)=YES or %upcase(&prp_bodytitle)=BODYTITLE or %upcase(&prp_bodytitle)= %then %do;
         %let prp_bodytitle=BODYTITLE;
      %end;
      %else %if %upcase(&prp_bodytitle)=NO %then %do;
         %let prp_bodytitle= ;
      %end;
      %else %do;
         %let prp_bodytitle= ;
         %PUT NOTE (&SYSMACRONAME): Macro variable prp_bodytitle option is illegal - (options: YES or NO); 
      %end;

      options number nodate orientation=&csv_orient ;
      ods rtf file = "&prp_tmpfile" style=&prp_odsstyle &prp_bodytitle;

   %end;

	** determine how much blank space is required in last footnote to right align Draft/Final Version;
   data _null_;
      ftfirst1 = length(compress("&_title1","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
      ftfirst2 = length(compress("&_title2","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
      ftfirst3 = length(compress("&_title3","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
      lenver1 = length("Page &prp_curpg of &prp_totpg");
      lenver2 = length("&prp_rundate");
	  lenver3 = length("&referenc");
      totspc1 = &_ls - ftfirst1 - lenver1;
	  totspc2 = &_ls - ftfirst2 - lenver2;
	  totspc3 = &_ls - ftfirst3 - lenver3;
	  if totspc1 > 0 then call symput('prp_blankspca', repeat(' ', &_ls - ftfirst1 - lenver1));
      else call symput('prp_blankspca', '1');
      if totspc2 > 0 then call symput('prp_blankspcb', repeat(' ', &_ls - ftfirst2 - lenver2));
      else call symput('prp_blankspcb', '1');
      if totspc3 > 0 then call symput('prp_blankspcc', repeat(' ', &_ls - ftfirst3 - lenver3));
      else call symput('prp_blankspcc', '1');
   run;

   %** Define titles **;
   %if %upcase(&csv_type) = T %then %do;
      %global csv_typef;
      %let csv_typef = Table;
   %end;

   %if %upcase(&csv_type) = L %then %do;
      %global csv_typef;
      %let csv_typef = Listing;
   %end;
   
   %let titnot1 = &_title1;
   %let titnot2 = &_title2;
   %let titnot3 = &_title3;

   data _null_;
      call symput("_title1", compress("&titnot1","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
      call symput("_title2", compress("&titnot2","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
	  call symput("_title3", compress("&titnot3","ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890-+%()\/[]{}', ","k"));
   run;

   %if %eval(&csv_numttl) eq 3 %then %do; 
      title1 j=l "&_title1" "&prp_blankspca" "Page &prp_curpg of &prp_totpg";
      title2 j=l "&_title2" "&prp_blankspcb" "&prp_rundate";
      title3 j=l "&_title3" "&prp_blankspcc" "&referenc";
   %end;

   %if %eval(&csv_numttl) eq 4 %then %do; 
      title1 j=l "&_title1" "&prp_blankspca" "Page &prp_curpg of &prp_totpg";
      title2 j=l "&_title2" "&prp_blankspcb" "&prp_rundate";
      title3 j=l "&_title3" "&prp_blankspcc" "&referenc";
      title4 j=l "&_title4";
   %end;

   %** Define the report footnotes, ensuring that they are left-aligned *;
   %do prp_f = 1 %to &csv_numfnt;
      footnote%eval(&prp_f) j=l "&&_footnote&prp_f";
   %end;

   footnote&prp_j j=l "&&_footnote&prp_j";
   footnote&prp_2j j=l "&&_footnote&prp_2j";
   footnote&prp_3j j=l "&&_footnote&prp_3j";
   %goto end_prp;
%end; %*intext output;

%if (%upcase(%substr(&csv_phoenix,1,1))=T or %upcase(%substr(&csv_phoenix,1,1))=L) and %length(&ifmt) eq 0 %then %do;
%*****************************************************************************************************************;
%PUT NOTE: (&SYSMACRONAME) 3.3 Options for non-intext tables or listings;
%*****************************************************************************************************************;

   %** General options for non-intext tables or listings**;
   %let prp_tmpfile=&irpathu.\&dirpath.\&outpath\%sysfunc(lowcase(&csv_outnm)).rtf;

   %** if it is the first page of the output then open output destination **;
   %if %eval(&prp_curpg) eq 1 %then %do;
      filename rtfout "&prp_tmpfile";
      ods listing;
	  filename tmpfile temp;
      proc printto new print=tmpfile;
      run;
   %end;

   %** Define titles **;
   %if %eval(&csv_numttl) eq 3 %then %do; 
      title1 j=l "&_title1";
      title2 j=l "&_title2";
      title3 j=l "&_title3";
   %end;

   %if %eval(&csv_numttl) eq 4 %then %do; 
      title1 j=l "&_title1";
      title2 j=l "&_title2";
      title3 j=l "&_title3";
      title4 j=l "&_title4";
   %end;

   %** Define the report footnotes, ensuring that they are left-aligned *;
   %if %length(&outft) eq 0 %then %do;
   %do prp_f = 1 %to &csv_numfnt;
      footnote%eval(&prp_f) j=l "&&_footnote&prp_f";
   %end;

   footnote&prp_j j=l "&&_footnote&prp_j";
   footnote&prp_2j j=l "&&_footnote&prp_2j";
   footnote&prp_3j j=l "&&_footnote&prp_3j";
   %end;

   %else %if %length(&outft) gt 0 %then %do;
      footnote;
   %end;
   %goto end_prp;

%end; %*non-intext output;
		
%end; %*RTF section;

%end_prp: %*End of titles footnotes and output stream section;

%if %upcase(%substr(&csv_phoenix,1,1))=F or ((%upcase(%substr(&csv_phoenix,1,1))=T or %upcase(%substr(&csv_phoenix,1,1))=L) and %length(&ifmt) gt 0) %then %do;
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
%PUT NOTE: (&SYSMACRONAME)    The programming section specific for (&csv_progtype) ends here.;
%PUT NOTE: (&SYSMACRONAME) ---------------------------------------------------------------------;

%mend output_pre_final;

***********************************************************************;
***********    END OF OUTPUT_PRE MACRO   **********************************;
***********************************************************************;






