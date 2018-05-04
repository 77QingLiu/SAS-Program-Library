/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : _CREATE_TF.SAS
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : 1. Read in the ARC Tool Metadata
                            2. Set up titles and footnotes.
                            3. Set up program, program type, output and output type                                
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
   Users may call the _CREATE_TF macro to read in the ARC Tool Metadata, 
   set up titles and footnotes, set up program, program type, output and output type.
   But this macro is called by macro output_pre automatically. Users don't need to
   invoke it by themselves.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%_CREATE_TF(arcrptname=1.1.1);
%_CREATE_TF(arcrptname=smdemp11.rtf);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

     Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Bin Zhang
**eoh************************************************************************/

%macro _CREATE_TF(arcmetadata=,arcrptname=);

/*Obtain the parameters for selected TFLs*/
%local _indexfound;
%global num_ttl num_fnt _ls _ps pgm_type rpt_pgm rpt_type rpt_name rpt_fmt;
%let prp_macname = &sysmacroname;

%*****************************************************************************************************************;
%put NOTE: (&prp_macname: &sysmacroname) 1. Separating titles and footnotes;
%*****************************************************************************************************************;

%let _ls=&ls;
%let _ps=&ps;
%let _indexfound = 0; %** set the ERROR detection macro variable **;

%let num_ttl=0; %** initalise number of titles counter to 0 **;
%let num_fnt=0; %** initalise number of footnotes counter to 0 **;
%let linesize=&ls;

data arc_reporting_metadata;
  attrib title1_ title2_ length=$2000;
  set &arcmetadata end=eof;
  if upcase(report_name_) = upcase("&arcrptname") or compress(index___) = compress("&arcrptname");
  call symputx('_indexfound','1','L');
run;

%** error check for output existence **;
%if &_indexfound eq 0 %then %do;
   %put %str(ERR)OR: (&prp_macname: &sysmacroname) &arcrptname not found. ;
   %goto pgm_end;
%end;

data arc_reporting_metadata0;
   set arc_reporting_metadata;
   report_name = scan(report_name_,1,".");
   report_type = scan(report_name_,2,".");
   pgm_name = scan(program_name_,1,".");
   pgm_type = scan(program_name_,2,".");
   keep index___ type__t_f_l__ report_name report_type pgm_name pgm_type;
run;

data arc_reporting_metadata1 (keep=obs_num name);
   length dlim $1 name $2000.;                                                                                                         
   set arc_reporting_metadata;  
   do obs_num = 1 to 7;
      if obs_num = 1 then text = title1_;                        
      else if obs_num = 2 then text = title2_;
      else if obs_num = 3 then text = title3_;
      else if obs_num = 4 then text = title4_;
      else if obs_num = 5 then text = title5_;
      else if obs_num = 6 then text = Abbreviations_Footnote_;
      else if obs_num = 7 then text = Test_Statistic_Footnote_;
      if lowcase(text) not in ('na','n/a',' ') then do;
         word=compress(text);  
         do i = 1 to 10; /* not expecting more than 10 line feed characters per title/footnote */
            start_lf_char=anyspace(word,1);                                  
            wordlen = length(word);
            if start_lf_char >= wordlen then do;
               name=text;
               if name ^=' ' then output;                                                                                                              
               leave;
            end;
            dlim=substr(word,start_lf_char,1);
            call scanq(text,1,position,length,dlim);                                                                                           
            if not position then leave;  
            name=substr(text,position,length);
            if length(text) > position+length+1 then do;
               text = substr(text,position+length+1);
               if substr(text,1,1) = '0B'x then
               text = substr(text,2); /* eliminate this character */
            end;
            else do;
               if name ^=' ' then output;
               leave;                                                                                                              
            end;
            if name ^=' ' then output; 
         end; 
      end;
   end;
run; 

data arc_reporting_metadata2 (keep=obs_num fnote_seq tmpname rename=(tmpname=name));  
   attrib tmpname out length=$2000;
   set arc_reporting_metadata1;
   fnote_seq = 1; 
   str = name; 
   tmpname = ''; 
   if length(str) > &linesize then do;
      do while (scan(str,fnote_seq,' ') ne ' ');
         tmp_len = length(tmpname) + length(scan(str,fnote_seq, ' ')) + 1;
         if tmp_len <= &linesize then do;
            tmpname = left(trim(tmpname)) || ' ' || scan(str,fnote_seq, ' ');
         end;
         else do;
            out = tmpname;
            if tmpname = ' ' then do;
               out = scan(str,fnote_seq, ' ');
               if length(out) > &linesize then do;
                  out = ' ';
               end;
               fnote_seq = 999; /* end loop */
            end;
            output;
            tmpname = scan(str,fnote_seq, ' '); 
         end;
         fnote_seq = fnote_seq + 1;
         if fnote_seq >= 999 then leave; /* halt endless loop */
      end;
      output;
   end;
   else do;
      tmpname = name;
      output;
   end;
run;

data arc_reporting_metadata3;
   set arc_reporting_metadata2;
   name=compbl(name);
   fnote_seq2 + 1;
run;

proc sort data=arc_reporting_metadata3 (where=(obs_num <= 5)) out=arc_reporting_titles;
   by obs_num fnote_seq2;
run;

proc transpose data=arc_reporting_titles out=arc_reporting_titles1 prefix=title;
   var name;
run;

data arc_reporting_titles_cnt (keep=title_cnt);
   set arc_reporting_titles end=eof;
   title_cnt = _n_;
   if eof;
run;

proc sort data=arc_reporting_metadata3 (where=(obs_num > 5)) out=arc_reporting_fnotes;
   by obs_num fnote_seq2;
run;

proc transpose data=arc_reporting_fnotes out=arc_reporting_fnotes1 prefix=fnote;
   var name;
run;

data arc_reporting_fnotes_cnt (keep=fnote_cnt);
   set arc_reporting_fnotes end=eof;
   fnote_cnt = _n_;
   if eof;
run;

%*****************************************************************************************************************;
%put NOTE: (&prp_macname: &sysmacroname) 2. Create macro variables and report results;
%*****************************************************************************************************************;

data outds (drop=_name_);
   merge arc_reporting_metadata0
         arc_reporting_titles1 arc_reporting_fnotes1 
         arc_reporting_titles_cnt arc_reporting_fnotes_cnt;
run;

data arc_tf;
   set outds;
   if title_cnt = . then title_cnt = 0;
   if fnote_cnt = . then fnote_cnt = 0;
run;

data _null_;
   set work.arc_tf;
   call symput('pgm_type',left(trim(pgm_type)));
   call symput('rpt_pgm',left(trim(pgm_name)));
   call symput('rpt_type',left(trim(report_type)));
   call symput('rpt_name',left(trim(report_name)));   
   call symput('num_ttl',compress(put(title_cnt,5.)));   
   call symput('num_fnt',compress(put(fnote_cnt,5.)));
   call symput('rpt_fmt',left(trim(type__t_f_l__)));   
run;

** reset all titles and footnotes to null - this is incase from a previous run there is somthing set;
%do ctf_i=1 %to 10; 
   %global _title&ctf_i; 
   %let _title&ctf_i = ; 
%end;

%do ctf_i=1 %to 10; 
   %global _footnote&ctf_i; 
   %let _footnote&ctf_i = ; 
%end;

%do ctf_i=1 %to %eval(&num_ttl);
   %global _title&ctf_i;
%end;

%do ctf_i=1 %to %eval(&num_fnt);
   %global _footnote&ctf_i;
%end;

data _null_;
   set work.arc_tf;

   %do ctf_t=1 %to %eval(&num_ttl);
      call symput("_title&ctf_t", left(trim(%str(title&ctf_t))));
   %end;

   %do ctf_f=1 %to %eval(&num_fnt);
      call symput("_footnote&ctf_f", trim(%str(fnote&ctf_f)));
   %end;
run;

%PUT NOTE: (&prp_macname: &sysmacroname) ###########################################;
%PUT NOTE: (&prp_macname: &sysmacroname) -------------------------------------------;
%PUT NOTE: (&prp_macname: &sysmacroname) DETAILS FOR OUTPUT &arcrptname:;
%PUT NOTE: (&prp_macname: &sysmacroname) -------------------------------------------;
%PUT NOTE: (&prp_macname: &sysmacroname);

%do ctf_t=1 %to %eval(&num_ttl);
   %let _title&ctf_t=%bquote(&&_title&ctf_t);
   %put Note: (&prp_macname: &sysmacroname) _title&ctf_t=&&_title&ctf_t;
%end;

%do ctf_f=1 %to %eval(&num_fnt);
   %let _footnote&ctf_f=%bquote(&&_footnote&ctf_f);
   %put Note: (&prp_macname: &sysmacroname) _footnote&ctf_f=&&_footnote&ctf_f;
%end;

%PUT Note: (&prp_macname: &sysmacroname) Output Number or Name is &arcrptname;
%PUT Note: (&prp_macname: &sysmacroname) Program name is &rpt_name;
%PUT Note: (&prp_macname: &sysmacroname) Program output type is &rpt_type;
%PUT Note: (&prp_macname: &sysmacroname) Number of titles read from the ARC Tool sheet are &num_ttl;
%PUT Note: (&prp_macname: &sysmacroname) Number of footnotes read from the ARC Tool sheet are &num_fnt;

%PUT NOTE: (&prp_macname: &sysmacroname);
%PUT NOTE: (&prp_macname: &sysmacroname) -------------------------------------------;
%PUT NOTE: (&prp_macname: &sysmacroname) ###########################################;

%pgm_end: %* Macro halted if errors;
%mend _CREATE_TF;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="3f3835db:14008461e25:7ef3" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ARCRPTNAME" maxlength="256"*/
/*   tabname="Parameters" processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_INDEXFOUND" maxlength="256"*/
/*   tabname="Parameters" processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUM_TTL" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="NUM_FNT" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_LS" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_PS" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PGM_TYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_PGM" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_TYPE" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_NAME" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="11" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="RPT_FMT" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_MACNAME" maxlength="256"*/
/*   tabname="Parameters" processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="LS" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="14" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PS" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="15" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="LINESIZE" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="16" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CTF_I" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="17" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CTF_T" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="18" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="CTF_F" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="19" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_TITLE" maxlength="256" tabname="Parameters"*/
/*   processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="20" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_FOOTNOTE" maxlength="256"*/
/*   tabname="Parameters" processid="P95" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="21" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="ARCMETADATA" maxlength="256"*/
/*   tabname="Parameters" processid="P95" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/