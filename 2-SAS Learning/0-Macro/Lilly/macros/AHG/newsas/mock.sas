%put &indir1 &indir2 &indir3 &indir4 &indir5;
%put &outdir1 &outdir2 &outdir3;

%macro setMeUp;
  %global localtemp;
  %if &sysscp=WIN %then
    %do;
    dm "clear log";
    dm "clear lst";
    options sasautos=(sasautos "d:\allover"  );
    options nobyline mprint mrecall;
    %let localtemp=d:\temp;
    libname raw 'D:\ly231514\Raw';
    libname theout "D:\ly231514\jmitqc";
    libname subraw "D:\ly231514\subraw";
    libname  view 'D:\ly231514\Raw';
    %AHGfontsize(15);
/*    %AHGsubsetlib_subjid(inlib=raw,outlib=subraw,wstr=1003,wherevar=subjid );*/

    %PUT I am on WINDOWS;
    %AHGdatadelete;
    %end;
  %else
    %do;
    %LET core=&indir1;
    %let raw=&indir2;
    %let theout=&outdir1;
	 option sasautos=(sasautos "&core");
    libname raw "&raw";
    libname theout "&theout";

    %put I am on UNIX;
    %AHGdatadelete(lib=theout);
    %local i  one dsns;
    %AHGdsnInLib(lib=raw,list=dsns,lv=1);
    %do i=1 %to %AHGcount(&dsns);
    %let one=%scan(&dsns,&i);
    data theout.&one(compress=yes);
      set raw.&one;
    run;
    
    %end;


    %end;


%mend;

%setMeUp;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="-5823c51f:1440dde4721:2a27" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS log" systemtype="&star;LOG&star;" tabname="System Files" baseoption="A" advanced="N" order="1" id="&star;LOG&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LOG"*/
/*   processid="P3" required="N" resolution="INPUT" enable="N" type="LOGFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS output" systemtype="&star;LST&star;" tabname="System Files" baseoption="A" advanced="N" order="2" id="&star;LST&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="LST"*/
/*   processid="P3" required="N" resolution="INPUT" enable="N" type="LSTFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="Process parameter values" systemtype="SDDPARMS" tabname="System Files" baseoption="A" advanced="N" order="3" id="SDDPARMS" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS7BDAT"*/
/*   processid="P3" required="N" resolution="INPUT" enable="N" type="PARMFILE">*/
/*  </parameter>*/
/*  <parameter dependsaction="ENABLE" obfuscate="N" label="SAS program" systemtype="&star;PGM&star;" tabname="System Files" baseoption="A" advanced="N" order="4" id="&star;PGM&star;" canlinktobasepath="Y" protect="N" userdefined="S" filetype="SAS"*/
/*   processid="P3" required="N" resolution="INPUT" enable="N" type="PGMFILE">*/
/*  </parameter>*/
/*  <parameter tabname="Parameters" id="INDIR1" expandfiletypes="N" obfuscate="N" label="Folder" required="N" order="5" baseoption="A" processid="P3" type="FOLDER" enable="N" canlinktobasepath="Y" readfiles="Y" protect="N" advanced="N"*/
/*   dependsaction="ENABLE" writefiles="N" resolution="INPUT">*/
/*   <fileset setType="0">*/
/*    <sourceContainer system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="core" id="/lillyce/non_study/users_sandbox/hui_liu/core" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter tabname="Parameters" id="INDIR2" expandfiletypes="N" obfuscate="N" label="Folder" required="N" order="6" baseoption="A" processid="P3" type="FOLDER" enable="N" canlinktobasepath="Y" readfiles="Y" protect="N" advanced="N"*/
/*   dependsaction="ENABLE" writefiles="N" resolution="INPUT">*/
/*   <fileset setType="0">*/
/*    <sourceContainer system="SDD" source="DOMAIN" displaypath="/lillyce/prd/ly231514/h3e_cr_jmit/safety_review9/data/shared" displayname="eds" id="/lillyce/prd/ly231514/h3e_cr_jmit/safety_review9/data/shared/eds" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter tabname="Parameters" id="INDIR3" expandfiletypes="N" obfuscate="N" label="Folder" required="N" order="7" baseoption="A" processid="P3" type="FOLDER" enable="N" canlinktobasepath="Y" readfiles="Y" protect="N" advanced="N"*/
/*   dependsaction="ENABLE" writefiles="N" resolution="INPUT">*/
/*   <fileset setType="0">*/
/*    <sourceContainer system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="empty" id="/lillyce/non_study/users_sandbox/hui_liu/empty" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" writefiles="N" label="Folder" tabname="Parameters" baseoption="A" readfiles="Y" advanced="N" id="INDIR4" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" resolution="INPUT" enable="N" type="FOLDER"*/
/*   order="8">*/
/*   <fileset setType="0">*/
/*    <sourceContainer system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="empty" id="/lillyce/non_study/users_sandbox/hui_liu/empty" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" writefiles="N" label="Folder" tabname="Parameters" baseoption="A" readfiles="Y" advanced="N" id="INDIR5" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" resolution="INPUT" enable="N" type="FOLDER"*/
/*   order="9">*/
/*   <fileset setType="0">*/
/*    <sourceContainer system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="empty" id="/lillyce/non_study/users_sandbox/hui_liu/empty" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" id="OUTDIR1" canlinktobasepath="Y" expandfiletypes="N" protect="N" label="Folder" order="10" processid="P3" baseoption="A" resolution="INPUT" advanced="N" required="N" readfiles="N" enable="N" type="FOLDER" writefiles="Y"*/
/*   tabname="Parameters">*/
/*   <file system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="subset" id="/lillyce/non_study/users_sandbox/hui_liu/subset" itemtype="Container" fileinfoversion="3.0">*/
/*   </file>*/
/*   <fileset setType="0">*/
/*    <sourceContainer system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="temp" id="/lillyce/non_study/users_sandbox/hui_liu/temp" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" writefiles="Y" label="Folder" tabname="Parameters" baseoption="A" readfiles="N" advanced="N" id="OUTDIR2" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" resolution="INPUT" enable="N" type="FOLDER"*/
/*   order="11">*/
/*   <file system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="temp" id="/lillyce/non_study/users_sandbox/hui_liu/temp" itemtype="Container" fileinfoversion="3.0">*/
/*   </file>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" writefiles="Y" label="Folder" tabname="Parameters" baseoption="A" readfiles="N" advanced="N" id="OUTDIR3" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" resolution="INPUT" enable="N" type="FOLDER"*/
/*   order="12">*/
/*   <file system="SDD" source="DOMAIN" displaypath="/lillyce/non_study/users_sandbox/hui_liu" displayname="temp" id="/lillyce/non_study/users_sandbox/hui_liu/temp" itemtype="Container" fileinfoversion="3.0">*/
/*   </file>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LOCALTEMP" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N"*/
/*   type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="CORE" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="14">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="RAW" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="15">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="THEOUT" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="16">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="I" maximum="9999999" advanced="N" enable="N" obfuscate="N" tabname="Parameters" minimum="-9999999" numtype="real" resolution="INPUT" protect="N" label="Numeric field" required="N"*/
/*   type="NUMERIC" order="17">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="ONE" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="18">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DSNS" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="19">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/