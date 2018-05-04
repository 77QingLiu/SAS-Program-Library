/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : freq_ctc.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : H3E-GH-B015|LY231514

DESCRIPTION               : an integration of small macros for freq of CTCAE calculation

SOFTWARE/VERSION#         : SAS/Version 9
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a
BROAD-USE MODULES         : n/a

INPUT                     : n/a
OUTPUT                    : n/a

PROGRAM PURPOSE           : create table of freq of CTCAE
VALIDATION LEVEL          : 4
REQUIREMENTS              : n/a
ASSUMPTIONS               : n/a
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
BROAD-USE MODULE/LIMITED-USE MODULE SPECIFIC INFORMATION: n/a

BROAD-USE MODULE TEMPORARY OBJECT PREFIX: n/a

PARAMETERS:

Name                 Type     Default    Description and Valid Values
---------            -------- ---------- --------------------------------------------------
_ds	                  required                Input dataset
_out                  required                Output dataset
_bygroup           required                Analysis group
_ctcae                  required                High level item
_grade                   required            Low level item

USAGE NOTES:
(1) &&big_n_&i. are required for macro to run
(2) columns[label1 label2 $200. & colt2-colt(2i+1) $30.] are created

TYPICAL WAYS TO EXECUTE THIS CODE AND DESCRIPTION, if applicable:

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
REVISION HISTORY SECTION:

       Author &
Ver# Peer Reviewer        Code History Description
---- ----------------     ------------------------------------------------
1.0  Thomas Guo          Original version of the code
     Weishan Shi
  **eoh************************************************************************/

*******************************************************************************;
* Macro *;
*******************************************************************************;
%macro freq_ctc(_ds=,_out=,_bygroup=,_ctcae=,_grade=);
/*******count the number of groups********/;
proc sql noprint;
	select count(distinct &_bygroup.) into: grpnum from &_ds.;
quit;

/*******get the count of CTCAE and Grade********/;
%let _catg = %str(&_ctcae. &_grade.);
%if &_grade. =  %then %do;
	%let _catg_sql = &_ctcae.;
%end;
%else %do;
	%let _catg_sql = %str(&_ctcae.,&_grade.);
%end;

proc sort data = &_ds. out = &_ds.1(keep=&_catg. &_bygroup. USUBJID);
    by &_bygroup. &_catg. USUBJID;
run;

proc sql noprint;
    create table &_ds.2 as
	    select &_bygroup., &_catg_sql., count(distinct USUBJID) as cnt
	    from &_ds.1
	    group by &_bygroup., &_catg_sql.
		order by &_bygroup., &_catg_sql.
	;
quit;

/*******set dataset by SOC and by SOC&PT********/;
data &_ds.4;
	length var1 var2 $200.;
	set &_ds.2;
	var1 = upcase(&_ctcae.);
	var2 = upcase(&_grade.);
run;

/*******sort by alphabetically ********/;

proc sort data = &_ds.4 out = &_ds.5 nodupkey;
	by var1 var2 &_catg. &_bygroup.;
run;


/*******transpose the dataset********/;
proc transpose data = &_ds.5 out = &_ds.6 prefix=group;
	var cnt;
	id &_bygroup.;
	by var1 var2 &_catg.;
run;

proc sql noprint;
	create table dummy1 as
	select distinct var1, &_ctcae. from &_ds.6
	;
quit;

data dummy2;
	length var2 &_grade. $200.;
	set dummy1;
	var2="GRADE 1"; &_grade.="Grade 1"; output;
	var2="GRADE 2"; &_grade.="Grade 2"; output;
	var2="GRADE 3"; &_grade.="Grade 3"; output;
	var2="GRADE 4"; &_grade.="Grade 4"; output;
	var2="GRADE 4/3"; &_grade.="Grade 4/3"; output;
	var2="GRADE 5"; &_grade.="Grade 5"; output;
	var2="OVERALL"; &_grade.="Overall"; output;
run;

data &_ds.7;
	merge &_ds.6(drop=&_grade. &_ctcae. in=a) dummy2(in=b);
	by var1 var2;
	if b and not a then do;
	%do i=1 %to &grpnum.;
		colt%sysfunc(strip(%sysevalf(2*&i.))) = put(0,3.);
		colt%sysfunc(strip(%sysevalf(2*&i.+1))) =  "(  0.0%)";
	%end;		
	end;
run;

data &_out.(keep=colt: label:);
	length label1 label2 $200. colt2-colt%sysfunc(strip(%sysevalf(&grpnum.*2+1))) $20.;
	set &_ds.7;
	by var1 var2;
	if first.var1 then label1 = &_ctcae.;
	else label1 = "";

	label2 = "  "||&_grade.;

	%do i=1 %to &grpnum.;
			if group%sysfunc(strip(&i.)) = . then group%sysfunc(strip(&i.)) = 0;
			colt%sysfunc(strip(%sysevalf(2*&i.))) = put(group%sysfunc(strip(&i.)),3.);
			colt%sysfunc(strip(%sysevalf(2*&i.+1))) =  "("||put(group%sysfunc(strip(&i.))/&&big_n_&i..*100,5.1)||"%)";
	%end;
run;

%mend freq_ctc;

/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="197fb2b:13f0455c877:63e5" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_DS" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_OUT" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_BYGROUP" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_CTCAE" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_GRADE" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_CATG" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_CATG_SQL" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="GRPNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BIG_N_" maxlength="256" tabname="Parameters"*/
/*   processid="P8" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/