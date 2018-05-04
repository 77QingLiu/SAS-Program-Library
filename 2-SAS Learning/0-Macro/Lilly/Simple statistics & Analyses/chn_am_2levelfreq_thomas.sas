/*soh*************************************************************************
Eli Lilly and Company - Global Statistical Sciences
CODE NAME                 : freq_soc_pt.sas
CODE TYPE                 : Limited-use Module
PROJECT NAME (optional)   : H3E-GH-B015|LY231514

DESCRIPTION               : an integration of small macros for freq of SOC_PT calculation

SOFTWARE/VERSION#         : SAS/Version 9
INFRASTRUCTURE            : SDD version 3.4

LIMITED-USE MODULES       : n/a
BROAD-USE MODULES         : n/a

INPUT                     : n/a
OUTPUT                    : n/a

PROGRAM PURPOSE           : create table of freq of SOC PT
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
_soc                  required                High level item
_pt                   not required            Low level item
_order               required                Sort order
_reverse           not required           Calculate the raw/reverse
_spec           not required          		 Define the special variable which should be located at the bottom, e.g. Uncoded

USAGE NOTES: n/a

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
%macro freq_soc_pt(_ds=,_out=,_bygroup=,_soc=,_pt=,_order=,_reverse=,_spec=);
/*******count the number of groups********/;
proc sql noprint;
	select max( &_bygroup.) into: grpnum from &_ds.;
quit;

/*******get the count of SOC and PT********/;
%let _catg = %str(&_soc. &_pt.);
%if &_pt. =  %then %do;
	%let _catg_sql = &_soc.;
%end;
%else %do;
	%let _catg_sql = %str(&_soc.,&_pt.);
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
    create table &_ds.3 as
	    select &_bygroup., &_soc., count(distinct USUBJID) as cnt
	    from &_ds.1
	    group by &_bygroup., &_soc.
		order by &_bygroup., &_soc.
    ;
quit;

/*******set dataset by SOC and by SOC&PT********/;
data &_ds.4;
	length var1 %if &_pt. ^= %then var2; $200.;
	set &_ds.2(in=a) &_ds.3(in=b);
	if b and &_bygroup.=&grpnum. then inds=1;
	else if a and &_bygroup.=&grpnum. then inds=2;
	else inds=3;
	var1 = upcase(&_soc.);
	%if &_pt. ^=  %then %do;
		var2 = upcase(&_pt.);
	%end;
run;

%put &grpnum.=;

/*******sort by alphabetically or by percentage********/;
%if &_order.=1 %then %do;
		proc sort data = &_ds.4(drop=inds) out = &_ds.5 nodupkey;
			by %if &_pt. ^=  %then var1 var2 &_catg.; %else var1 &_catg.; &_bygroup.;
		run;
%end;
%else %if &_order.=2 %then %do;
		proc sort data = &_ds.4 out = &_ds.4_1 ;
			by %if &_pt. ^=  %then var1 var2 &_catg.; %else var1 &_catg.; descending &_bygroup. inds;
		run;

		data &_ds.4_2;
			retain ord1 ord2;
			set &_ds.4_1;
			if inds=1 then do;
				ord1 = cnt;
				ord2 = cnt;
			end;
			else if inds=2 then do;
				ord2 = cnt;
			end;
		run;

		proc sort data = &_ds.4_2 out = &_ds.5 nodupkey;
			by %if &_pt. ^=  %then descending ord1 var1 descending ord2 var2 &_catg.; %else descending ord1 var1 &_catg.; &_bygroup.;
		run;
%end;

/*******transpose the dataset********/;
proc transpose data = &_ds.5 out = &_ds.6 prefix=group;
	var cnt;
	id &_bygroup.;
	%if &_order.=1 %then %do;
	by  %if &_pt.^=  %then var1 var2 &_catg.; %else var1 &_catg.;;
	%end;
	%else %if &_order.=2 %then %do;
	by  %if &_pt.^=  %then descending ord1 var1 descending ord2 var2 &_catg.; %else descending ord1 var1 &_catg.;;
	%end;
run;

data &_ds.7(keep=colt: level _ord);
	length colt1 $200. colt2-colt%sysfunc(strip(%sysevalf(&grpnum.*2+1))) $20.;
	retain _ord 0;
	set &_ds.6;
	_ord = _n_;
	%if &_pt.=  %then %do;
		colt1 = &_soc.;
		level = 1;
	%end;
	%else %do;
		if &_pt. = "" then do;
			colt1 = &_soc.;
			level = 1;
		end;
		else do;
			colt1 = "  "||&_pt.;
			level = 2;
		end;
	%end;
	%do i=1 %to &grpnum.;
		%if &_reverse = Y %then %do;
			if &&big_n_&i.^=0 then do;
				if group%sysfunc(strip(&i.)) = . then group%sysfunc(strip(&i.)) = 0;
				colt%sysfunc(strip(%sysevalf(2*&i.))) = put(&&_n&i.-group%sysfunc(strip(&i.)),3.);
				if group%sysfunc(strip(&i.)) ^= 0 then colt%sysfunc(strip(%sysevalf(2*&i.+1))) =  "("||put((&&_n&i..-group%sysfunc(strip(&i.))/&&big_n_&i..*100,5.1))||"%)";
				else colt%sysfunc(strip(%sysevalf(2*&i.+1))) =  "";
			end;
		%end;
		%else %do;
			if &&big_n_&i.^=0 then do;
				if group%sysfunc(strip(&i.)) = . then group%sysfunc(strip(&i.)) = 0;
				colt%sysfunc(strip(%sysevalf(2*&i.))) = put(group%sysfunc(strip(&i.)),3.);
				if group%sysfunc(strip(&i.)) ^= 0 then colt%sysfunc(strip(%sysevalf(2*&i.+1))) =  "("||put(group%sysfunc(strip(&i.))/&&big_n_&i..*100,5.1)||"%)";
				else colt%sysfunc(strip(%sysevalf(2*&i.+1))) =  "";
			end;
		%end;
	%end;
run;

data &_out.1(drop=_temp_);
	set _ds.7;
	retain _temp_ 0;
	%if %str(&_spec.)^= %then %do;
	if level=1 and strip(upcase(colt1))=strip(upcase("&_spec.")) then do;
		_temp_=99999;
		_ord=_ord+_temp_;
	end;
	else if level=1 and strip(upcase(colt1))^=strip(upcase("&_spec.")) then do;
		_temp_=0;
	end;
	else if level=2 and strip(upcase(colt1))=strip(upcase("&_spec.")) then do;
		_ord = _ord+_temp_+0.1;
	end;
	else do;
		_ord=_ord+_temp_;
	end;
	%end;
run;

proc sort data = &_out.1 out = &_out.;
	by _ord;
run;

%mend freq_soc_pt;

/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="bc56a2:13f5a47a3ec:-7545" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="1" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_DS" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="2" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_OUT" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="3" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_BYGROUP" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="4" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_SOC" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="5" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_PT" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="6" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_ORDER" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="7" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_REVERSE" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="8" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_CATG" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="9" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_CATG_SQL" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="10" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="GRPNUM" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter id="I" resolution="INTERNAL" type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="12" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="_N" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/*  <parameter label="Text field" protect="N" obfuscate="N" cdvenable="Y" order="13" cdvrequired="N" enable="N" resolution="INPUT" required="N" canlinktobasepath="N" advanced="N" dependsaction="ENABLE" id="BIG_N_" maxlength="256" tabname="Parameters"*/
/*   processid="P57" type="TEXT">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/