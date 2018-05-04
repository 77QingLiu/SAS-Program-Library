/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : smpvl11.sas
CODE TYPE                 : Program
PROJECT NAME (optional)   : Japan I1F-JE-RHAT 
DESCRIPTION               : Index 1.2.1 Important Protocol Deviations
SOFTWARE/VERSION#         : SAS/Version 9.2
INFRASTRUCTURE            : SDD 3.5
LIMITED-USE MODULES       : \ly2439821\i1f_je_rhat\lums\_SETUP_intrm1.sas
                            \ly2439821\i1f_je_rhat\lums\rpt_pre.sas
                            \ly2439821\i1f_je_rhat\lums\rpt_post.sas
                            \ly2439821\i1f_je_rhat\lums\_create_tf.sas
                            \ly2439821\i1f_je_rhat\lums\copydata.sas
BROAD-USE MODULES         : lillyce\prd\general\bums\macro_library\ut_saslogcheck.sas
INPUT                     : \ly2439821\I1F-JE-RHAT\intrm1\data\shared\ads\PROTVI.sas7bat
                            \ly2439821\I1F-JE-RHAT\intrm1\data\shared\ads\SUBJINFO.sas7bat 
OUTPUT                    : \ly2439821\I1F-JE-RHAT\intrm1\programs_stat\tfl_output\smpvl111.rtf
PROGRAM PURPOSE           : Baseline
VALIDATION LEVEL          : 3
REQUIREMENTS              : \ly2439821\I1F-JE-RHAT\study_documentation\
                            RHAT_interimDBL_TFLspec_v2.0_20131022.docx
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
*%include &study_setup;
*libname ads "&ads";

%include "D:\lillysdd\lillyce\qa\ly2439821\I1F_JE_RHAT\intrm1\programs_nonsdd\author_component_modules\_SETUP_test.sas";

** Copy the source datasets and prepare for set up the table dataset **;
%copydata(indata=ads.subjinfo,outdata=subjinfo,var=%str(usubjid,psoplatflg,psoerytflg,psopustflg),cond=where subjfas eq 1,seq=%str(usubjid));
%copydata(indata=ads.protvi,outdata=protvi,dist=Y,var=%str(usubjid, psoplatflg,psoerytflg,psopustflg,protvicat,protvicatsnm),cond=where subjfas eq 1 and visid le 19,seq=%str(usubjid));

** Set up the dataset for tabulation **;
/*Prepare the data for computing the numerator and denominator*/
data subjinfo2;
   set subjinfo(in=a where=(psoplatflg eq 1)) subjinfo(in=b where=(psoerytflg eq 1)) subjinfo(in=c where=(psopustflg eq 1)) subjinfo(in=d);
   if a then trtn = 1;
   if b then trtn = 2;
   if c then trtn = 3;
   if d then trtn = 5;
run;

data protvi2;
   set protvi(in=a where=(psoplatflg eq 1)) protvi(in=b where=(psoerytflg eq 1)) protvi(in=c where=(psopustflg eq 1)) protvi(in=d);
   if a then trtn = 1;
   if b then trtn = 2;
   if c then trtn = 3;
   if d then trtn = 5;
run;

proc sql;
   create table total as
   select trtn,10001 as protvicat,"TOTAL" as protvicatsnm,count(distinct usubjid) as num from protvi2 where missing(protvicat) eq 0 group by trtn;
quit;

/*Compute the numerator and denominator*/
proc freq data = protvi2 noprint;
   tables protvicat*protvicatsnm / out = out_n(drop = percent rename = (count = num));
   by trtn;
   where missing(protvicat) eq 0;
run;

data out_n2;
   set out_n total;
run;

proc sort data = out_n2;
   by trtn protvicat;
run;

proc freq data = subjinfo2 noprint;
   tables trtn / out = out_m(drop = percent rename = (count = den));
run;

/*Prepare the dataset for tabulation*/
data out_t;
   merge out_n2 out_m;
   by trtn;
   if num gt 0 then do;
      pct = (num/den)*100;
      val = right(put(num,4.)) || " (" || right(put(pct,5.1)) || ")";
   end;
   else do;
      val = right(put(0,4.)) || repeat(" ",8);
   end;      
run;

proc sort data = out_t;
   by protvicat trtn;
run;

proc transpose data = out_t out = out_t2(drop=_name_ where=(missing(protvicatsnm) eq 0)) prefix = v;
   by protvicat protvicatsnm;
   id trtn;
   var val;
run;

/*dummy*/
data dummy;
   do protvicat = 1 to 5,10001;
      output;
   end;
run;

data final;
   merge dummy(in=a) out_t2;
   by protvicat;
   if protvicat eq 1 then protvicatsnm = "Drug compliance";
   else if protvicat eq 2 then protvicatsnm = "Informed consent";
   else if protvicat eq 3 then protvicatsnm = "Prohibited concomitant medications";
   else if protvicat eq 4 then protvicatsnm = "Protocol inclusion/exclusion criteria";
   else if protvicat eq 5 then protvicatsnm = "Protocol - specific";

   array char_val{4} $ v1 v2 v3 v5;
   do i = 1 to 4;
      if char_val{i} eq "" then char_val{i} = right(put(0,4.)) || repeat(" ",8);
   end;
   mypage = 1;
   drop i;
run;

/*Compute big N for each treatment groups*/
proc sql noprint;
   select den into :bign1-:bign4 from out_m;
quit;

** Report **;
%rpt_pre(rpt_in=smpvl111.rtf);
proc report data = final nowindows split="#" headline spacing = 0;
   column ("--" mypage protvicat protvicatsnm v1 v2 v3 v5);   
   define mypage / noprint order;
   define protvicat / noprint order order=data;
   define protvicatsnm / width=53 left "Important Protocol Deviations"; 
   define v1 / width=20 center "&trt1#(N = &bign1)#n (%)";
   define v2 / width=20 center "&trt2#(N = &bign2)#n (%)";
   define v3 / width=20 center "&trt3#(N = &bign3)#n (%)";
   define v5 / width=20 center "&trt5#(N = &bign4)#n (%)";

   compute before mypage;
      line " ";
   endcomp;

   compute after protvicat;
      line " ";
   endcomp;

   compute after mypage;
      line @1 &ls.*"-";
   endcomp;
run;
quit;
%rpt_post;

/*Check log*/
proc printto print=_ibxout_; 
run;
%ut_saslogcheck;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="-69f519b2:142066c5602:23c8" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BIGN1" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="2" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P32" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BIGN2" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BIGN3" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BIGN4" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter dependsaction="DISABLE" obfuscate="N" label="Input process" tabname="Parameters" baseoption="A" advanced="N" order="6" id="STUDY_SETUP" canlinktobasepath="Y" protect="Y" writefile="N" filetype="SAS" processid="P32" required="Y"*/
/*   resolution="INPUT" enable="N" type="INPROCESS">*/
/*   <default>*/
/*    <file system="RELATIVE" source="RELATIVE" displaypath="../../lums" displayname="_SETUP_intrm1.sas" id="../../lums/_SETUP_intrm1.sas" itemtype="Item" type="sas" fileinfoversion="3.0">*/
/*    </file>*/
/*   </default>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="SAS log" resolution="INPUT" type="LOGFILE" baseoption="A" processid="P32" id="&star;LOG&star;" order="28" protect="N" enable="N" filetype="LOG" autolaunch="N" canlinktobasepath="Y" userdefined="S"*/
/*   base="BASE_1" obfuscate="N" systemtype="&star;LOG&star;" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="log">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm1/programs_stat" displayname="system_files" id="intrm1/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="Process parameter values" resolution="INPUT" type="PARMFILE" baseoption="A" processid="P32" id="SDDPARMS" order="29" protect="N" enable="N" filetype="SAS7BDAT" autolaunch="N" canlinktobasepath="Y"*/
/*   userdefined="S" base="BASE_1" obfuscate="N" systemtype="SDDPARMS" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="sas7bdat">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm1/programs_stat" displayname="system_files" id="intrm1/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" label="SAS output" resolution="INPUT" type="LSTFILE" baseoption="A" processid="P32" id="&star;LST&star;" order="30" protect="N" enable="N" filetype="LST" autolaunch="N" canlinktobasepath="Y" userdefined="S"*/
/*   base="BASE_1" obfuscate="N" systemtype="&star;LST&star;" required="N" tabname="System Files" advanced="N">*/
/*   <target rootname="" extension="lst">*/
/*    <folder system="RELATIVE" source="RELATIVE" displaypath="intrm1/programs_stat" displayname="system_files" id="intrm1/programs_stat/system_files" itemtype="Container" fileinfoversion="3.0">*/
/*    </folder>*/
/*   </target>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" id="ADS" canlinktobasepath="Y" expandfiletypes="N" protect="N" label="Folder" order="31" processid="P32" baseoption="A" resolution="INPUT" advanced="N" required="N" readfiles="Y" enable="N" type="FOLDER" base="BASE_2"*/
/*   tabname="Parameters" writefiles="N">*/
/*   <fileset setType="1">*/
/*    <sourceContainer system="RELATIVE" source="RELATIVE" displaypath="intrm1/data/shared" displayname="ads" id="intrm1/data/shared/ads" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <fileInfoList>*/
/*     <file system="RELATIVE" source="RELATIVE" displayname="protvi.sas7bdat" id="protvi.sas7bdat" itemtype="Item" type="sas7bdat" version="1" fileinfoversion="3.0">*/
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
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="32" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TRT1" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="33" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TRT2" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="34" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TRT3" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="35" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="TRT5" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="36" cdvrequired="Y" enable="Y" resolution="INPUT" required="Y" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="LS" maxlength="256" tabname="Parameters"*/
/*   processid="P32" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/
