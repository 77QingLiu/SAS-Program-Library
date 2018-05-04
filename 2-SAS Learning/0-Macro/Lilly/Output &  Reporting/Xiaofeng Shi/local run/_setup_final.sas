/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : _SETUP.SAS
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : Standard output macro for Lilly China internal use 

DESCRIPTION               : This code is used to set up the programming
                            environment for the output generationg programs.                            

SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a

BROAD-USE MODULES         : n/a
INPUT                     : n/a
OUTPUT                    : n/a
 
VALIDATION LEVEL          : 3
REQUIREMENTS              : n/a
ASSUMPTIONS               : Prior to using this macro, users need to check if
                            the folders are set up
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name          Type         Default            Description and Valid Values
---------     ------------ ------------------ ----------------------------------

USAGE NOTES:
   Users may call the _setup macro to set up the programming environment. But this macro
   could be modified to change the output status after DBL. In addition, this macro should
   be called at the begining of the outputs generating programs.

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

filename subm 'D:\lillysdd\lillyce\qa\ly3009104\i4v_je_jadn\lums';
options mautosource sasautos=(subm,sasautos);

%_setup;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
      Weishan Shi
**eoh************************************************************************/

%macro _setup_final(phase=);

%global ls ps;
%let ls = 133;
%let ps = 46;

options ls = &ls ps = &ps;
 
%***************************************************************************;
%*** Clear out log, output;
%***************************************************************************;
 
DM 'out; clear;'; 
DM 'log; clear;'; 
run;

%***************************************************************************;
%*** Set up directory macro variables and ADS library;
%***************************************************************************;

%global prp_root prp_phase prp_phase_p prp_proj prp_analy referenc;

/*%let prp_root=D:\lillysdd\lillyce;*/
%let prp_root=G:\lillyce;
%let prp_phase=qa;
%let prp_phase_p=qa;
%let prp_proj=ly3009104\i4v_je_jadn;
%let prp_analy=&phase;
%let referenc=TDTM;

libname ads "&prp_root\&prp_phase\&prp_proj\&prp_analy\data\shared\ads" /*access=readonly*/;
libname tflout "&prp_root\&prp_phase\&prp_proj\&prp_analy\programs_nonsdd\tfl_output" /*access=readonly*/;
libname custom "&prp_root\&prp_phase\&prp_proj\&prp_analy\data\shared\custom";

%***************************************************************************;
%*** Set up study programming environment;
%***************************************************************************;

options errorcheck = strict serror mprint mlogic mlogicnest symbolgen notes source nosource2 nocenter nodate nonumber fmtsearch = (work ads tflout);

/*proc datasets lib = work kill nolist nodetails memtype = data;*/
/*run; quit;*/

/*proc datasets lib=work;*/
/*   save ads: / memtype=data;*/
/*run;*/
/*quit;*/

%***************************************************************************;
%*** Set up compound and treatment macro variables;
%***************************************************************************;

%global studyid studyid2 comb trt1 trt2 trt3 trt4 trt5 trt6 trt7 trt14 trt24 trt34 trt44 trt54 trt15 trt25 trt35 trt45 trt55
        trtpa trtpb site patnum tmpoint;

%let studyid=LY3009104;
%let studyid2=Part A LY3009104 or Placebo treatment -> Part B LY3009104 treatment;
%let comb=Combined;
%let trt1=Placebo;
%let trt2=1 mg;
%let trt3=2 mg;
%let trt4=4 mg;
%let trt5=8 mg;
%let trt6=Combined LY;
%let trt7=All Groups;

%let trt14=Placebo->4mg;
%let trt24=1mg->4mg;
%let trt34=2mg->4mg;
%let trt44=4mg->4mg;
%let trt54=Combined 4mg;

%let trt15=Placebo->8mg;
%let trt25=1mg->8mg;
%let trt35=2mg->8mg;
%let trt45=8mg->8mg;
%let trt55=Combined 8mg;

/*For listing*/
%let trtpa=Treatment Part A;
%let trtpb=Treatment Part B;
%let site=Site;
%let patnum=Patient Number;
%let tmpoint=Time Point;

%***************************************************************************;
%*** Create superscript macro variables;
%***************************************************************************;
   
%global sup_f1;      %*** holds the character superscript 1;
%global sup_f2;      %*** holds the character superscript 2;
%global sup_f3;      %*** holds the character superscript 3;
%global sup_pct;     %*** holds the character %;
%global sup_com;     %*** holds the character ,;
%global sup_sem;     %*** holds the character ;;
%global sup_eq;      %*** holds the character =;
%global sup_lb;      %*** holds the character (;
%global sup_rb;      %*** holds the character );
%global plusminus;      %*** holds the character +/-;

data _null_;
   CALL SYMPUT( "sup_f1", "B9"x );
   CALL SYMPUT( "sup_f2", "B2"x );
   CALL SYMPUT( "sup_f3", "B3"x );
   CALL SYMPUT( "sup_pct", "25"x );
   CALL SYMPUT( "sup_com", "2C"x );
   CALL SYMPUT( "sup_eq", "3D"x );
   CALL SYMPUT( "sup_sem", "3B"x );
   CALL SYMPUT( "sup_lb", "28"x );
   CALL SYMPUT( "sup_rb", "29"x );
   CALL SYMPUT( "plusminus", "B1"x );
run;

%***************************************************************************;
%*** Including output formatting;
%***************************************************************************;

%include "&prp_root\&prp_phase\&prp_proj\&prp_analy\programs_nonsdd\format_final.sas";
/*%include "&prp_root\&prp_phase\&prp_proj\&prp_analy\programs_nonsdd\format_weishan.sas";*/

%mend _setup_final;
