

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
/*<process sessionid="-5823c51f:14409a3ee8c:5691" sddversion="3.5" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="SAS log" filetype="LOG" protect="N" obfuscate="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="Y" advanced="N" dependsaction="ENABLE" id="&star;LOG&star;" systemtype="&star;LOG&star;" tabname="System Files"*/
/*   baseoption="A" userdefined="S" type="LOGFILE" order="1">*/
/*  </parameter>*/
/*  <parameter label="SAS output" filetype="LST" protect="N" obfuscate="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="Y" advanced="N" dependsaction="ENABLE" id="&star;LST&star;" systemtype="&star;LST&star;" tabname="System Files"*/
/*   baseoption="A" userdefined="S" type="LSTFILE" order="2">*/
/*  </parameter>*/
/*  <parameter label="Process parameter values" filetype="SAS7BDAT" protect="N" obfuscate="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="Y" advanced="N" dependsaction="ENABLE" id="SDDPARMS" systemtype="SDDPARMS"*/
/*   tabname="System Files" baseoption="A" userdefined="S" type="PARMFILE" order="3">*/
/*  </parameter>*/
/*  <parameter label="SAS program" filetype="SAS" protect="N" obfuscate="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="Y" advanced="N" dependsaction="ENABLE" id="&star;PGM&star;" systemtype="&star;PGM&star;" tabname="System Files"*/
/*   baseoption="A" userdefined="S" type="PGMFILE" order="4">*/
/*  </parameter>*/
/*  <parameter obfuscate="N" writefiles="N" label="Folder" tabname="Parameters" baseoption="A" readfiles="Y" advanced="N" id="core" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" resolution="INPUT" enable="N" type="FOLDER"*/
/*   order="5">*/
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
/*  <parameter obfuscate="N" writefiles="N" label="Folder" tabname="Parameters" baseoption="A" readfiles="Y" advanced="N" id="RAW" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" resolution="INPUT" enable="N" type="FOLDER"*/
/*   order="6">*/
/*   <fileset setType="0">*/
/*    <sourceContainer system="SDD" source="DOMAIN" displaypath="/lillyce/prd/ly231514/h3e_cr_jmit/safety_review9/data/shared" displayname="empty" id="/lillyce/prd/ly231514/h3e_cr_jmit/safety_review9/data/shared/eds" itemtype="Container" fileinfoversion="3.0">*/
/*    </sourceContainer>*/
/*    <filterList>*/
/*     <item name="ALL">*/
/*     </item>*/
/*    </filterList>*/
/*   </fileset>*/
/*   <description>*/
/*   </description>*/
/*  </parameter>*/
/*  <parameter obfuscate="N" writefiles="N" label="Folder" tabname="Parameters" baseoption="A" readfiles="Y" advanced="N" id="INDIR3" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" resolution="INPUT" enable="N" type="FOLDER"*/
/*   order="7">*/
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
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="INDIR4" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="8">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="INDIR5" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="9">*/
/*  </parameter>*/
/*  <parameter obfuscate="N" writefiles="N" label="Folder" tabname="Parameters" baseoption="A" readfiles="Y" advanced="N" id="OUTDIR1" canlinktobasepath="Y" protect="N" expandfiletypes="N" required="N" enable="N" resolution="INPUT" type="FOLDER"*/
/*   order="10">*/
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
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OUTDIR2" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="11">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OUTDIR3" cdvenable="Y" cdvrequired="N" advanced="N" enable="N" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="N" type="TEXT"*/
/*   order="12">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/