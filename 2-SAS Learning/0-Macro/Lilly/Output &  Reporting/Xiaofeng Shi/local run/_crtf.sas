/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : _CRTF.SAS
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : 1. Read in and check the Metadata
                            2. Set up and check titles and footnotes.
                            3. Set up table number, program, program type, 
                               reference id and table reference.
SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.4

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
OUTID         Required     &prp_id            Unique reference ID

USAGE NOTES:
   Users may call the _CRTF macro to read in and check the Metadata, set up and
   check titles and footnotes, set up table number, program, program type, 
   reference id and table reference. But this macro is called by macro output_pre
   automatically. Users don't need to invoke it by themselves.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

%_crtf(outid=&prp_id);

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi
**eoh************************************************************************/

%macro _crtf(outid=);

/*Obtain the parameters for selected TFLs*/
%local ctf_errttl ctf_errfnt ctf_misserr /*ctf_poptil ctf_popnum crt_nopopttl*/;
%global csv_numttl csv_numfnt _ls _ps csv_orient csv_tabno csv_prog csv_type csv_progtype csv_phoenix csv_outgrp csv_outnm csv_study;

%let prp_macname = &sysmacroname;

%*****************************************************************************************************************;
%put NOTE: (&prp_macname: &sysmacroname) 1. Checking number of titles and footnotes;
%*****************************************************************************************************************;
%let ctf_errttl = 0; %** set the ERROR detection macro variable **;
%let ctf_errfnt = 0; %** set the ERROR detection macro variable **;

%let csv_numttl=0; %** initalise number of titles counter to 0 **;
%let csv_numfnt=0; %** initalise number of footnotes counter to 0 **;
%let ctf_misserr=0; %** initalise missing data check counter to 0 **;

data work.ctf_ttlfnt1;
   set work.loa;
   length titles $1000 footnts $1000;
   titles = trim(left(output_description)) || "|" || trim(left(population)) || "|" || trim(left(sub_title));
   footnts = footnote;
   if out_id lt 10 and missing(out_id) eq 0 then out_idc = cat("000",put(out_id,1.));
   else if out_id ge 10 and out_id lt 100 then out_idc = cat("00",put(out_id,2.));
   else if out_id ge 100 and out_id lt 1000 then out_idc = cat("0",put(out_id,3.));
   else if out_id ge 1000 and out_id lt 10000 then out_idc = put(out_id,4.);
   ctf_id = upcase(compress(cat(tfl,orientation,out_idc)));
   where out_id eq &outid;
   drop out_idc;
run;

data work.ctf_ttlfnt2;
   set work.ctf_ttlfnt1;

   * Titles section;
   dumtitle=compress(titles);
   fullent1=length(dumtitle);
   dumtitle=compress(tranwrd(dumtitle,"|"," "));
   fullent2=length(dumtitle);
   numttl=(fullent1-fullent2)+1;

   if numttl=1 and missing (titles) then numttl=0;
   if missing (output_description) then do;
      put "NOTE: (&prp_macname: &sysmacroname) No titles have been added to the tracking sheet for this output.";
   end;
   call symput("csv_numttl",compress(put(numttl,5.)));
   if numttl gt 7 then do;
      call symput("ctf_errttl","1");
   end;

   * Footnotes section;
   dumfootn=compress(footnote);
   fullenf1=length(dumfootn);
   dumfootn=compress(tranwrd(dumfootn,"|"," "));
   fullenf2=length(dumfootn);
   numfnt=(fullenf1-fullenf2)+1;

   if numfnt=1 and missing (footnote) then numfnt=1;
   if missing (footnote) then do;
      put "NOTE: (&prp_macname: &sysmacroname) No footnotes have been added to the tracking sheet for this output.";
   end;
   call symput("csv_numfnt",compress(put(numfnt,5.)));
   if numfnt gt 9 then do;
      call symput("ctf_errfnt","1");
   end;

   *drop fullent1 fullent2 dumtitle fullenf1 fullenf2 dumfootn;
run;

%** error check for too many titles or footnotes **;
%if &ctf_errttl ne 0 %then %do;
   %put %str(ERR)OR: (&prp_macname: &sysmacroname) too many titles (&csv_numttl.) given. - Only 7 is allowed. ;
   %goto pgm_end;
%end;

%if &ctf_errfnt ne 0 %then %do;
   %put %str(ERR)OR: (&prp_macname: &sysmacroname) too many footnotes (&csv_numfnt.) given. - Only 9 allowed;
   %goto pgm_end;
%end;

%*****************************************************************************************************************;
%put NOTE: (&prp_macname: &sysmacroname) 2. Separating titles and footnotes;
%*****************************************************************************************************************;
data work.ctf_ttlfnt3;
   set work.ctf_ttlfnt2;

   %if &csv_numttl=1 %then %do;
      format title4 $char140. ;
      array _titles {&csv_numttl} $140 title1;
      do i=1 to &csv_numttl;
         _titles{i}=scan(titles,i,"|");
      end;
      drop i;
   %end;

   %else %if &csv_numttl ne 0 %then %do;
      format title1-title%eval(&csv_numttl) $char140. ;
      array _titles {&csv_numttl} $140 title1-title%eval(&csv_numttl);
      do i=1 to &csv_numttl;
         _titles{i}=scan(titles,i,"|");
      end;
      drop i;
   %end;

   %if &csv_numfnt=1 %then %do;
      format footnt1 $char140. ;
      array footns {&csv_numfnt} $140 footnt1 ;
      do j=1 to &csv_numfnt;
         footns{j}=scan(footnts,j,"|");
      end;
      drop j;
   %end;

   %else %if &csv_numfnt ne 0 %then %do;
      format footnt1-footnt%eval(&csv_numfnt) $char140. ;
      array footns {&csv_numfnt} $140 footnt1-footnt%eval(&csv_numfnt) ;
      do j=1 to &csv_numfnt;
         footns{j}=scan(footnts,j,"|");
      end;
      drop j;
   %end;

   ** check to see if no population is defined;
   tempttl=compress(titles);
   pospttl=length(tempttl);
   if substr(tempttl,pospttl,1)="|" then nopopttl=1;
   else nopopttl=0;
   if nopopttl=1 then do;
      put "NOTE: (&prp_macname: &sysmacroname): No population title has been defined for this report";
   end;
   call symput("crt_nopopttl",compress(put(nopopttl,5.)));

   *drop titles footnts tempttl pospttl nopopttl;
run;

proc sort data=work.ctf_ttlfnt3 out = work.ctf_ttlfnt4;
   by out_id;
run;

%*****************************************************************************************************************;
%put NOTE: (&prp_macname: &sysmacroname) 3. Retrieving orientation and checking length of titles and footnotes;
%*****************************************************************************************************************;
data _null_;
   set work.ctf_ttlfnt4;
   call symput("ctf_id", compress(ctf_id));
run;

%** set-up the Orientation macro variable from the Ref ID **;
%let csv_orient=%substr(&ctf_id,2,1);

%if %upcase("&csv_orient")=%str("L") %then %do;
   %let csv_orient=landscape;
   %let _ls=133;
   %let _ps=47;
   %put NOTE: (&prp_macname: &sysmacroname) - Orientation for the output is defined as &csv_orient;
%end;

%else %if %upcase("&csv_orient")=%str("P") %then %do;
   %let csv_orient=portrait;
   %let _ls=95;
   %let _ps=66;
   %put NOTE: (&prp_macname: &sysmacroname) - Orientation for the output is defined as &csv_orient;
%end;

%else %do;
   %put %str(WARN)ING: (&prp_macname: &sysmacroname) Third letter of ID does not indicate orientation - P or L - orientation will default to L;
   %let csv_orient=landscape;
   %let _ls=133;
   %let _ps=47;
%end;

%** Check the lengths of titles and footnotes**;
%let ctf_err = 0; %** set the ERROR detection macro variable **;

data _null_;
   set work.ctf_ttlfnt4;

%** titles section;
%if &csv_numttl=1 %then %do;
   array _titles_ {&csv_numttl} title1;
%end;
%else %if &csv_numttl ne 0 %then %do;
   array _titles_ {&csv_numttl} title1-title%eval(&csv_numttl);
%end;
%if &csv_numttl ne 0 %then %do;
   retain chkttl 0;
   do ctf_crei=1 to &csv_numttl;
      if not missing(_titles_{ctf_crei}) then chkttl=1;
         if length(trim(_titles_{ctf_crei})) gt 133 and %upcase("&csv_orient")="LANDSCAPE" then do;
			if upcase(substr(compress(ctf_id),1,1))="F" then do;
               put "NOTE: (&prp_macname: &sysmacroname) title" ctf_crei " may be too long for orientation &csv_orient " _titles_{ctf_crei}; 
            end;
            else do;
               put "WARN" "ING: (&prp_macname: &sysmacroname) title" ctf_crei " is too long for orientation &csv_orient " _titles_{ctf_crei}; 
            end;
         end;			
         if length(trim(_titles_{ctf_crei})) gt 95 and %upcase("&csv_orient")="PORTRAIT" then do;
            if upcase(substr(compress(ctf_id),1,1))="F" then do;
               put "NOTE: (&prp_macname: &sysmacroname) title" ctf_crei " may be too long for orientation &csv_orient " _titles_{ctf_crei}; 
            end;
            else do;
               put "WARN" "ING: (&prp_macname: &sysmacroname) title" ctf_crei " is too long for orientation &csv_orient " _titles_{ctf_crei}; 
            end;
         end;
   end;

	if chkttl=0 then do;
		PUT "ERR" "OR: (&prp_macname: &sysmacroname) No titles given for id: " ctf_id "processing of this file will stop";
        call symput("ctf_err","1");
	end;
	drop chkttl ctf_crei;
%end;

%** Footnotes section;
%if &csv_numfnt=1 %then %do;
   array _foots_ {&csv_numfnt} footnt1 ;
%end;
%else %if &csv_numfnt ne 0 %then %do;
   array _foots_ {&csv_numfnt} footnt1-footnt%eval(&csv_numfnt) ;
%end;

%if &csv_numfnt ne 0 %then %do;
   do ctf_crej=1 to &csv_numfnt;
      if length(trim(_foots_{ctf_crej})) gt 133 and %upcase("&csv_orient")="LANDSCAPE" then do;
         if upcase(substr(compress(ctf_id),1,1))="F" then do;
            put "NOTE: (&prp_macname: &sysmacroname) Footnote" ctf_crej " may be too long for orientation &csv_orient " _foots_{ctf_crej};
         end;
         else do;
            put "WARN" "ING: (&prp_macname: &sysmacroname) Footnote" ctf_crej " is too long for orientation &csv_orient " _foots_{ctf_crej};
         end;
      end;
      if length(trim(_foots_{ctf_crej})) gt  95 and %upcase("&csv_orient")="PORTRAIT" then do;
         if upcase(substr(compress(ctf_id),1,1))="F" then do;
            put "NOTE: (&prp_macname: &sysmacroname) footnote" ctf_crej " may be too long for orientation &csv_orient " _foots_{ctf_crej};
         end;
         else do;
            put "WARN" "ING: (&prp_macname: &sysmacroname) footnote" ctf_crej " is too long for orientation &csv_orient " _foots_{ctf_crej};
         end;
      end;
   end;
   drop ctf_crej;
%end;

run;

%if &ctf_err ne 0 %then %goto pgm_end; %** Check the ERROR detection macro variable **;

%*****************************************************************************************************************;
%put NOTE: (&prp_macname: &sysmacroname) 4. Create macro variables and report results;
%*****************************************************************************************************************;
data _null_;
   set work.ctf_ttlfnt4;

   call symput( 'csv_tabno', left(trim(put(out_id,3.))));
   call symput( 'csv_type', left(trim(tfl)));
   call symput('csv_outgrp', left(trim(%str(run_group))));
   call symput( 'csv_prog'   , left(trim(pgm_name)));
   call symput( 'csv_progtype', left(trim(output_type)));
   call symput('csv_phoenix', left(trim(ctf_id)));
   call symput('csv_outnm',left(trim(output_name)));
   call symput('csv_study',left(trim(study)));
run;

%let csv_outgrp=%bquote(&csv_outgrp);

** reset all titles and footnotes to null - this is incase from a previous run there is somthing set;
%do ctf_i=1 %to 10; 
   %global _footnote&ctf_i; 
   %let _footnote&ctf_i = ; 
%end;

%do ctf_i=1 %to 10; 
   %global _title&ctf_i; 
   %let _title&ctf_i = ; 
%end;

%do ctf_i=1 %to %eval(&csv_numttl);
   %global _title&ctf_i;
%end;

%do ctf_i=1 %to %eval(&csv_numfnt);
   %global _footnote&ctf_i;
%end;

data _null_;
   set work.ctf_ttlfnt3;

   %do ctf_t=1 %to %eval(&csv_numttl);
      call symput("_title&ctf_t", left(trim(%str(title&ctf_t))));
   %end;

   %do ctf_f=1 %to %eval(&csv_numfnt);
      call symput("_footnote&ctf_f", trim(%str(footnt&ctf_f)));
   %end;
run;

%PUT NOTE: (&prp_macname: &sysmacroname) ###########################################;
%PUT NOTE: (&prp_macname: &sysmacroname) -------------------------------------------;
%PUT NOTE: (&prp_macname: &sysmacroname) DETAILS FOR REFERENCE ID %UPCASE(&ctf_id):;
%PUT NOTE: (&prp_macname: &sysmacroname) -------------------------------------------;
%PUT NOTE: (&prp_macname: &sysmacroname);

%do ctf_t=1 %to %eval(&csv_numttl);
   %let _title&ctf_t=%bquote(&&_title&ctf_t);
   %put Note: (&prp_macname: &sysmacroname) _title&ctf_t=&&_title&ctf_t;
%end;

%do ctf_f=1 %to %eval(&csv_numfnt);
   %let _footnote&ctf_f=%bquote(&&_footnote&ctf_f);
   %put Note: (&prp_macname: &sysmacroname) _footnote&ctf_f=&&_footnote&ctf_f;
%end;

%PUT Note: (&prp_macname: &sysmacroname) Output Number is &csv_type &csv_tabno;
%PUT Note: (&prp_macname: &sysmacroname) Output reference is &csv_phoenix;
%PUT Note: (&prp_macname: &sysmacroname) Program name is &csv_prog;
%PUT Note: (&prp_macname: &sysmacroname) Program output type  is &csv_progtype;
%PUT Note: (&prp_macname: &sysmacroname) Number of titles read from the tracking sheet are &csv_numttl;
%PUT Note: (&prp_macname: &sysmacroname) Number of footnotes read from the tracking sheet are &csv_numfnt;

%PUT NOTE: (&prp_macname: &sysmacroname);
%PUT NOTE: (&prp_macname: &sysmacroname) -------------------------------------------;
%PUT NOTE: (&prp_macname: &sysmacroname) ###########################################;

**-- Remove unwanted temporary data sets --**;
/*proc datasets ddname=work nolist nodetails;*/
/*   delete ctf_ttlfnt1 ctf_ttlfnt2 ctf_ttlfnt3 ctf_ttlfnt4; */
/*quit;*/

%pgm_end: %* Macro halted if errors;
%mend _crtf;
