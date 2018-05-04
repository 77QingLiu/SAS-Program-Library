/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : output_post.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : This code should be run just after the output part
                            of a program that generates an output (table,
                            listing or a graph).                             

SOFTWARE/VERSION#         : SAS/Version 9.1
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : a_out2rtf

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
FIGURE  not required N      option Y/N for figure or not (table/listing) missing same to N

USAGE NOTES:
   Users may call the output_post macro to get final output. But this macro must be
   called together with output_pre. Before doing this, please create proper
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

2.0   Ella Cheng           Disable intext table section and add FIGURE option
**eoh************************************************************************/

%macro output_post(por_debug=no,figure=N);

%PUT NOTE: (&SYSMACRONAME) -----------------------------;
%PUT NOTE: (&SYSMACRONAME)    &SYSMACRONAME starts here.;
%PUT NOTE: (&SYSMACRONAME) -----------------------------;

* capture the current users options and stroe so they can be put back after;
proc optsave out=work._proptn_;
run;

%if %upcase(&por_debug) = %str(Y) or %upcase(&por_debug) = %str(YES) %then %do;
  options symbolgen mlogic mprint;
%end;
%else %if %upcase(&por_debug) = %str(N) or %upcase(&por_debug) = %str(NO) %then %do;
  options nosymbolgen nomlogic nomprint;
%end;

%************************************************************************************************************;
%**            Output closing for RTF (START)                                                   ***;
%************************************************************************************************************;

%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    The programming section specific for RTF closing starts here.;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------;

  %** close ods rtf if plot/figure and reset back to listing **;
  %if %upcase(%substr(&figure,1,1))=Y  %then %do;
        ods listing;
  %end;

  %** Close ods rtf if non-intext output **;
  %else %if %upcase(%substr(&figure,1,1))=N  %then %do;
        proc printto ;
        run;
        %a_out2rtf(in = tmpfile, out = rtfout ,_o2r_PrpMdYN=Y ,_o2r_PrpMd=&data_mode,  _o2r_DebugYN=Y );
        filename tmpfile clear;
        filename rtfout clear;
  %end;

  %if %upcase(%substr(&figure,1,1))=Y  %then %do;
  ** reset the orignal options of the user;
proc optload data=work._proptn_;
run;
%end;

%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------------;
%PUT NOTE: (&SYSMACRONAME)    The programming section stops here.;
%PUT NOTE: (&SYSMACRONAME) ----------------------------------------------------------------------;


%mend output_post;
%***********************************************************************;
%***********    END OF MACRO       *************************************;
%***********************************************************************;


