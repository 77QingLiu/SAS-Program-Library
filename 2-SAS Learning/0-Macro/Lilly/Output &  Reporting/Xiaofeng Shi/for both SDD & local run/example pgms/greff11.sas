/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : greff11.sas
CODE TYPE                 : Program
PROJECT NAME (optional)   : Japan I1F-JE-RHAT 
DESCRIPTION               : Index 2.1.3 PASI 75, PASI 90 and PASI 100 Response Rates
                            at Each Post-Baseline Visit - Induction Dosing Period
                            Index 2.1.18 PASI 75, PASI 90 and PASI 100 Response Rates
                            at Each Post-Baseline Visit - Combined Induction Dosing
                            Period and Maintenance Dosing Period
SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD 3.5
LIMITED-USE MODULES       : \ly2439821\i1f_je_rhat\lums\_SETUP_intrm1.sas
                            \ly2439821\i1f_je_rhat\lums\rpt_pre.sas
                            \ly2439821\i1f_je_rhat\lums\rpt_post.sas
                            \ly2439821\i1f_je_rhat\lums\_create_tf.sas
                            \ly2439821\i1f_je_rhat\lums\copydata.sas
BROAD-USE MODULES         : \lillyce\prd\general\bums\macro_library\ut_saslogcheck.sas
INPUT                     : \ly2439821\I1F-JE-RHAT\intrm1\data\shared\ads\SUBJINFO.sas7bat 
                            \ly2439821\I1F-JE-RHAT\intrm1\data\shared\ads\PASI.sas7bat 
OUTPUT                    : \ly2439821\I1F-JE-RHAT\intrm1\programs_stat\tfl_output\greff111.gif
                            \ly2439821\I1F-JE-RHAT\intrm1\programs_stat\tfl_output\greff113.gif
PROGRAM PURPOSE           : PASI
VALIDATION LEVEL          : 3
REQUIREMENTS              : \ly2439821\I1F-JE-RHAT\study_documentation\
                            RHAT_interimDBL_TFLspec_v2.1_20131106.docx
ASSUMPTIONS               : 
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION:
(If CODE TYPE is Program, leave this section blank)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0   Xiaofeng Shi        Original version of the code
        Bin Zhang
**eoh************************************************************************/

** Programming environment set up **;
%include "D:\lillysdd\lillyce\qa\ly2439821\I1F_JE_RHAT\intrm1\programs_nonsdd\author_component_modules\_SETUP_test.sas";

** Copy the source datasets and prepare for set up the table dataset **;
%copydata(indata=ads.subjinfo,outdata=subjinfo,var=%str(usubjid,psoplatflg,1 as trtn),cond=where subjfas eq 1 and psoplatflg eq 1,seq=%str(usubjid));
%copydata(indata=ads.pasi,outdata=pasi,var=%str(usubjid,visid,pasiqsnum,pasirc),
          cond=where subjfas eq 1 and psoplatflg eq 1 and ((visid in (3,4,5,7,9,10,11,12,13,14,15,16,17,18,19) and pasiqsnum in ("PASI75", "PASI90", "PASI100"))
                    or (visid in (9,19) and pasiqsnum in ("PASI75_NRI", "PASI90_NRI", "PASI100_NRI"))),
          seq=%str(usubjid,pasiqsnum,visid));

** Set up the dataset for tabulation **;
/*Prepare the data for computing the numerator and denominator*/
data comb1;
   merge subjinfo(in=a) pasi(in=b);
   by usubjid;
   if a;
   if pasiqsnum in ("PASI75","PASI75_NRI") then ord = 1;
   else if pasiqsnum in ("PASI90","PASI90_NRI") then ord = 2;
   else if pasiqsnum in ("PASI100","PASI100_NRI") then ord = 3;
   if pasiqsnum in ("PASI75", "PASI90", "PASI100") then do;
      if visid eq 3 then visidn = 1;
      else if visid eq 4 then visidn = 2;
      else if visid eq 5 then visidn = 4;
      else if visid eq 7 then visidn = 8;
      else if visid eq 9 then visidn = 12;
      else if visid eq 10 then visidn = 16;
      else if visid eq 11 then visidn = 20;
      else if visid eq 12 then visidn = 24;
      else if visid eq 13 then visidn = 28;
      else if visid eq 14 then visidn = 32;
      else if visid eq 15 then visidn = 36;
      else if visid eq 16 then visidn = 40;
      else if visid eq 17 then visidn = 44;
      else if visid eq 18 then visidn = 48;
      else if visid eq 19 then visidn = 52;
   end;
   if pasiqsnum in ("PASI75_NRI", "PASI90_NRI", "PASI100_NRI") then do;
      if visid eq 9 then visidn = 12.5;
      else if visid eq 19 then visidn = 55;
   end;
   format visidn id137_3f. ord id137_2f.;
run;

proc sort data = comb1 out = comb2;
   by ord visidn pasiqsnum visid;
run;

/*Calculate the response rate by visits*/
proc freq data = comb2 noprint;
   by ord visidn pasiqsnum visid;
   tables pasirc / out = out_n(rename = (count = num) where=(upcase(pasirc) eq "RESPONDER"));
   where missing(pasirc) eq 0;
run;

proc freq data = comb2 noprint;
   by ord;
   tables visidn / out = out_d(rename = (count = den) drop=percent);
   where missing(pasirc) eq 0;
run;

data dummy;
   do ord = 1 to 3;
      do visidn = 0,1,2,4,8,12,12.25,12.5,16,20,24,28,32,36,40,44,48,52,53,55;
         output;
      end;
   end;
run;

data final;
   merge dummy out_n;
   by ord visidn;
   if visidn not in (12.25,53) and missing(percent) eq 1 then percent = 0;
run;

proc sql;
   create table out_dd as
   select distinct visidn,den from out_d
   order by visidn;
quit;

data out_d2;
   set out_dd;
   length function $8 text $200 position $1;
   function = "label";
   text = strip(put(den,best.));
   position = "5";
   xsys = "2";
   ysys = "3";
   size = 1.5;
   x = visidn;
   y = 27;
run;

data anno_label;
   length function $8 text $200 position $1;
   xsys="2"; ysys="3"; position="4"; size=1.5;
   function = "label"; 
   text= "Nx:"; x=0; y=27; output;
run;

data anno_label2;
   set anno_label(in=a) anno_label(in=b) out_d2(in=c where=(visidn le 12.5)) out_d2(in=d where=(visidn ne 12.5));
   if a then part = 1;
   if b then part = 2;
   if c then part = 1;
   if d then part = 2;
   if part eq 2 then size = 1.2;   
   drop visidn den;
run;

goptions reset=all xmax=12 in ymax=10in hsize=10 in vsize=7 in gunit=percent htext=3.2 ftext=simplex
         ftitle=simplex target=png rotate=landscape
         device=gif gsfmode=replace gsfname=gifout gsfmode=replace;

** Report **;
/*annotate dataset*/
data anno1;
   length function $8. xsys $1. ysys $1. x 8. y 8. size 8. text $30.;
   xsys= "2"; ysys= "3"; line=1;
   function="move" ; x=12.5; y=37; output;
   function="draw" ; x=12.5; y=36.2; output;

   position= "5";
   function = "label";

   size= 2; x= 12.5; y= 35; text= "12"; output;
   size= 2; y= 32.5; text= "(NRI)"; output;
run;

data anno2;
   length function $8. xsys $1. ysys $1. x 8. y 8. size 8. text $30.;
   xsys= "2"; ysys= "3"; line=1;
   function="move" ; x=55; y=37; output;
   function="draw" ; x=55; y=36.2; output;

   position= "5";
   function = "label";

   size= 1.2; x=55; y= 35.3; text= "52"; output;
   size= 1.2; y= 33; text= "(NRI)"; output;
run;

%macro fig_rpt(sel=,sel2=,sel3=);
options maxmemquery=6m;

/*axis X*/
%if %eval(&sel) eq 1 %then %do;
axis1 label=(h=2.5 "Week")
      minor=none
      order=(0 to 13 by 1)
      value=(h=2.5)
      origin=(10, 37) offset=(3, 3) length=85;
%end;

%else %if %eval(&sel) eq 2 %then %do;
axis1 label=(h=2.5 "Week")
      minor=none
      order=(0 to 56 by 1)
      value=(h=1.5)
      origin=(10, 37) offset=(3, 3) length=85;
%end;

/*axis Y*/
axis2 label=(h=2.5 a=90 "Response Rate (%)")
      order=(0 to 100 by 10)
      offset=(3, 3)
      value=(h=2.5)
      minor=none;

/*Legend*/
legend1 label=none
        value=(h=2.5 j=l)
        across= 3
        mode=protect;

symbol1 i=j c=black v=dot h=2.5 l=1 w=1;
symbol2 i=j c=red v=circle h=2.5 l=2 w=1;
symbol3 i=j c=blue v=triangle h=2.5 l=10 w=1;

filename gifout "&prp_tmpfile";
proc gplot data=final anno=anno_label2(where=(part eq &sel));
   where &sel2;
   plot percent*visidn = ord/ skipmiss haxis= axis1 vaxis= axis2 legend= legend1 href=&sel3 lhref=2 annotate=anno&sel;
run;
quit;
%mend fig_rpt;

%rpt_pre(rpt_in=greff111.gif,fig_tltxt=2,fig_fttxt=2);
%fig_rpt(sel=1,sel2=visidn lt 13,sel3=12.5);
%rpt_post;

%rpt_pre(rpt_in=greff113.gif,fig_tltxt=2,fig_fttxt=2);
%fig_rpt(sel=2,sel2=visidn not in (12.25,12.5),sel3=55);
%rpt_post;

/*Check log*/
proc printto print=_ibxout_; 
run;
%ut_saslogcheck;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="181727e5:14230d9952b:-2fe4" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SEL" maxlength="256" tabname="Parameters"*/
/*   processid="P10" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="PRP_TMPFILE" maxlength="256"*/
/*   tabname="Parameters" processid="P10" type="TEXT">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="3" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P10" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="DISABLE" obfuscate="N" label="Input process" tabname="Parameters" baseoption="A" advanced="N" order="4" id="STUDY_SETUP" canlinktobasepath="Y" protect="Y" writefile="N" filetype="SAS" processid="P10" required="Y"*/
/*   resolution="INPUT" enable="N" type="INPROCESS">*/
/*   <default>*/
/*    <file system="RELATIVE" source="RELATIVE" displaypath="../../lums" displayname="_SETUP_intrm1.sas" id="../../lums/_SETUP_intrm1.sas" itemtype="Item" type="sas" fileinfoversion="3.0">*/
/*    </file>*/
/*   </default>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="Process parameter values" resolution="INPUT" type="PARMFILE" baseoption="A" processid="P10" id="SDDPARMS" order="26" protect="N" enable="N" filetype="SAS7BDAT" autolaunch="N" canlinktobasepath="Y"*/
/*   userdefined="S" base="BASE_1" obfuscate="N" systemtype="SDDPARMS" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="sas7bdat">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm1/programs_stat" displayname="system_files" id="intrm1/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="SAS log" resolution="INPUT" type="LOGFILE" baseoption="A" processid="P10" id="&star;LOG&star;" order="27" protect="N" enable="N" filetype="LOG" autolaunch="N" canlinktobasepath="Y" userdefined="S"*/
/*   base="BASE_1" obfuscate="N" systemtype="&star;LOG&star;" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="log">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm1/programs_stat" displayname="system_files" id="intrm1/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="SAS output" resolution="INPUT" type="LSTFILE" baseoption="A" processid="P10" id="&star;LST&star;" order="28" protect="N" enable="N" filetype="LST" autolaunch="N" canlinktobasepath="Y" userdefined="S"*/
/*   base="BASE_1" obfuscate="N" systemtype="&star;LST&star;" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="lst">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm1/programs_stat" displayname="system_files" id="intrm1/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" id="ADS" canlinktobasepath="Y" expandfiletypes="N" protect="N" label="Folder" order="29" processid="P10" dependsaction="ENABLE" baseoption="A" resolution="INPUT" advanced="N" required="N" readfiles="Y" enable="N"*/
/*   type="FOLDER" base="BASE_2" writefiles="N" tabname="Parameters">*/
/*   <fileset setType="1">*/
/*    <sourceContainer system="RELATIVE" source="RELATIVE" displaypath="intrm1/data/shared" displayname="ads" id="intrm1/data/shared/ads" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <fileInfoList>*/
/*     <file system="RELATIVE" source="RELATIVE" displayname="pasi.sas7bdat" id="pasi.sas7bdat" itemtype="Item" type="sas7bdat" version="1" fileinfoversion="3.0">*/
/*     </file>*/
/*     <file system="RELATIVE" source="RELATIVE" displayname="subjinfo.sas7bdat" id="subjinfo.sas7bdat" itemtype="Item" type="sas7bdat" version="1" fileinfoversion="3.0">*/
/*     </file>*/
/*    </fileInfoList>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="30" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SEL2" maxlength="256" tabname="Parameters"*/
/*   processid="P10" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="31" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="SEL3" maxlength="256" tabname="Parameters"*/
/*   processid="P10" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/
