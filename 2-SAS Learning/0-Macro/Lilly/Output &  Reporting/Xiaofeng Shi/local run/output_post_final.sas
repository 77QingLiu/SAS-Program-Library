/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : output_post_final.sas
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
                            meatadata as the input dataset
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name          Type         Default            Description and Valid Values
---------     ------------ ------------------ ----------------------------------
POR_DEBUG     not required NO                 if run as debug model

USAGE NOTES:
   Users may call the output_post macro to get final output. But this macro must be
   called together with output_pre. Before doing this, please create proper
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

%macro output_post_final(por_debug=no);

%PUT NOTE: (&SYSMACRONAME) -----------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME starts here.;
%PUT NOTE: (&SYSMACRONAME) -----------------------------;

%local prp_odsnm_;
%** set macro variable to the last dataset **;
%LET prp_odsnm_=&syslast;


** capture the current users options and stroe so they can be put back after;
PROC OPTSAVE OUT=work._proptn_;
RUN;

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
	%if %upcase(%substr(&csv_phoenix,1,1))=F %then %do;
        ods listing;
	%end;

	%** Close ods rtf if intext output **;
	%else %if (%upcase(%substr(&csv_phoenix,1,1))=T or %upcase(%substr(&csv_phoenix,1,1))=L) and %length(&ifmt2) gt 0 %then %do;
		ods rtf close;
        ods listing;
	%end;

 	%** Close ods rtf if non-intext output **;
	%else %if (%upcase(%substr(&csv_phoenix,1,1))=T or %upcase(%substr(&csv_phoenix,1,1))=L) and %length(&ifmt2) eq 0 %then %do;
        proc printto ;
        run;
        %a_out2rtf(in = tmpfile, out = rtfout ,_o2r_PrpPgFMT  = %bquote(Page XXXX of YYYY), 	_o2r_PrpPgFMTC = %bquote(XXXX), _o2r_PrpPgFMTM = %bquote(YYYY),_o2r_PrpMdYN=Y ,_o2r_PrpMd=&referenc.);
		filename tmpfile clear;
        filename rtfout clear;
	%end;

%if %upcase(%substr(&csv_phoenix,1,1))=F or ((%upcase(%substr(&csv_phoenix,1,1))=T or %upcase(%substr(&csv_phoenix,1,1))=L) and %length(&ifmt2) gt 0) %then %do;
** reset the orignal options of the user;
PROC OPTLOAD DATA=work._proptn_;
RUN;
%end;

%if %sysfunc(exist(&prp_odsnm_.,data)) %then %do;

  %*************************************************************************************************************************************;
			%PUT NOTE: (&SYSMACRONAME)  Setting original dataset back into most recent history - i.e. syslast can be used outside &SYSMACRONAME;
  %*************************************************************************************************************************************;

			DATA &prp_odsnm_;
			set &prp_odsnm_;
			run;
%end;


%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    The programming section specific for (&csv_progtype) stops here.;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------------;


%mend output_post_final;
%***********************************************************************;
%***********    END OF MACRO       *************************************;
%***********************************************************************;


