/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275CRD1001
  PXL Study Code:        234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Deborah Liu $LastChangedBy: xiaz $
  Creation Date:         14JUL2017 / $LastChangedDate: 2017-09-18 07:49:06 -0400 (Mon, 18 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_cm.sas $

  Files Created:         qc_cm.log
                         cm.sas7bdat
                         suppcm.sas7bdat

  Program Purpose:       To QC Concomitant Medications dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 34 $
-----------------------------------------------------------------------------*/
title;footnote;
dm "log; clear; out; clear;";
options nomprint;

************************************************************
*  GENERAL MACROS
************************************************************;
***MACRO FUNCTION: USED TO CHANGE THE LENGTH OF A SPECIFIC CHARACTER VARIABLE;
%macro changelen(varname=,tarlen=,type=);
  **varname: variable name;
  **tarlen:  target length;
  %IF &type.=char %THEN %DO; length &varname._ $&tarlen.; %END;
  %IF &type.=num %THEN %DO; length &varname._ &tarlen.; %END;
  &varname._=&varname;
  drop &varname;
  rename &varname._=&varname;
%mend changelen;

************************************************************
*  BASIC SETTINGS
************************************************************;
***Cleaning WORK library ;
%jjqcclean;
***Do not use threaded processing;
options nothreads;
***Domain name:CM;
%let domain=CM;
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

************************************************************
*  IMPORT SPEC ("0A0D00"x)
************************************************************;
%jjqcgfname(fname=Mapping Specification, type=xlsx);
%let specname=%str(&fname);


proc import out=work.VALDEF
     datafile="&specpath.&specname..xlsx" dbms=xlsx replace;
     getnames=YES;
     sheet="VALDEF";
run;

************************************************************
*  COPY RAW DATASETS
************************************************************;
proc sort data=raw.DM_GL_900 out=DM_GL_900;by SITEID SUBJECT;run;

proc sort data=raw.CM_PS_002 out=CM_PS_002;by SITEID SUBJECT;run;
proc sort data=raw.FA_RA_006 out=FA_RA_006;by SITEID SUBJECT;run;
proc sort data=raw.CM_RA_005 out=CM_RA_005;by SITEID SUBJECT;run;


proc sort data=raw.CM_GL_900 out=CM_GL_900;by SITEID SUBJECT;run;
proc sort data=raw.CM_RA_001 out=CM_RA_001;by SITEID SUBJECT;run;

data &domain._raw_1_;
    merge DM_GL_900(keep=SUBJECT RFICDAT RFICDAT_YY RFICDAT_MM RFICDAT_DD SITEID) CM_PS_002;
    by SITEID SUBJECT;
    %changelen(varname=CMTRT,tarlen=200,type=char);
    /*%changelen(varname=CMDOSU,tarlen=50,type=char);
    %changelen(varname=CMDOSFRQ,tarlen=40,type=char);
    %changelen(varname=CMROUTE,tarlen=100,type=char);
    %changelen(varname=CMDOSFRM,tarlen=100,type=char); */
run;

PROC IMPORT OUT= work.cm_dropdownlist
            DATAFILE= "&_raw.CM_dropdownlist_coding.xls"
            DBMS=xls REPLACE;
     GETNAMES=yes;
RUN;

data cm_dropdownlist_1;
     length CMTRT_STD $30 CMLVL1 CMLVL2 CMLVL3 CMLVL4 $200 CMLVL1CD CMLVL2CD CMLVL3CD CMLVL4CD $20;
     set cm_dropdownlist;
     CMTRT_STD=TERM;
	 keep CMTRT_STD CMDECOD CMCLAS CMCLASCD CMLVL1 CMLVL1CD CMLVL2 CMLVL2CD CMLVL3 CMLVL3CD CMLVL4 CMLVL4CD;
	 rename CMDECOD=_CMDECOD CMCLAS=_CMCLAS CMCLASCD=_CMCLASCD
            CMLVL1=CMTRT_ATC1 CMLVL1CD=CMTRT_ATC1_CODE
            CMLVL2=CMTRT_ATC2 CMLVL2CD=CMTRT_ATC2_CODE
            CMLVL3=CMTRT_ATC3 CMLVL3CD=CMTRT_ATC3_CODE
            CMLVL4=CMTRT_ATC4 CMLVL4CD=CMTRT_ATC4_CODE
			;
run;

proc sort data=cm_dropdownlist_1;
    by CMTRT_STD;
run;

proc sort data=&domain._raw_1_;
    by CMTRT_STD;
run;

data &domain._raw_1;
   merge &domain._raw_1_(in=a) cm_dropdownlist_1;
   by CMTRT_STD;
   if a;
run;

data &domain._raw_2; set raw.CM_PS_003; %changelen(varname=CMTRT,tarlen=200,type=char); run;
data &domain._raw_3;
     merge DM_GL_900(keep=SUBJECT RFICDAT RFICDAT_YY RFICDAT_MM RFICDAT_DD SITEID) FA_RA_006;
     by SITEID SUBJECT;
run;
data &domain._raw_4;
    merge DM_GL_900(keep=SUBJECT RFICDAT RFICDAT_YY RFICDAT_MM RFICDAT_DD SITEID) CM_RA_005;
    by SITEID SUBJECT;
    %changelen(varname=CMTRT,tarlen=200,type=char);
    %changelen(varname=CMCAT,tarlen=200,type=char);
run;
data &domain._raw_5; set raw.TBINFO_1; run;
data &domain._raw_6;
     merge  DM_GL_900(keep=SUBJECT RFICDAT RFICDAT_YY RFICDAT_MM RFICDAT_DD SITEID) CM_GL_900;
     by SITEID SUBJECT;
     %changelen(varname=CMTRT,tarlen=200,type=char);
     %changelen(varname=CMCAT,tarlen=200,type=char);
     /*%changelen(varname=CMINDC,tarlen=200,type=char);*/
run;
data &domain._raw_7;
     merge  DM_GL_900(keep=SUBJECT RFICDAT RFICDAT_YY RFICDAT_MM RFICDAT_DD SITEID) CM_RA_001;
     by SITEID SUBJECT;
     %changelen(varname=CMINDC,tarlen=200,type=char);
run;
/* Below: corresponding to column Y Z in spec */
data &domain._raw_8; set raw.CM_RA_006; 
%changelen(varname=CMTRT,tarlen=200,type=char);
%changelen(varname=CMOCCUR_STD,tarlen=2,type=char); run;
data &domain._raw_9; set raw.CM_RA_007; 
%changelen(varname=CMTRT,tarlen=200,type=char);
%changelen(varname=CMOCCUR_STD,tarlen=2,type=char); run;
************************************************************
*  DOMAIN SPECIFIC MACROS
************************************************************;
***assign_1;
%macro assign_1;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain.";
    USUBJID=catx("-",PROJECT,SUBJECT);
    CMSPID=catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),
        put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
%mend assign_1;

***assign_2;
%macro assign_2(QNAM=,QVAL=);
    QNAM="&QNAM.";
    QVAL=&QVAL.;
    output;
%mend assign_2;
***assign_STD;
%macro assign_STD(VAL=);
    &VAL.=strip(&VAL._STD);
%mend assign_STD;

************************************************************
*  PREPERATION FOR FINAL
************************************************************;
*****RAW DATA 1******
*****CM_PS_002 ****************;

data &domain._pre_1;
    attrib &&&domain._varatt_;
    set &domain._raw_1(drop=STUDYID CMOCCUR CMTRT_STD DURCUM DURCUM_STD );
    %assign_1;
    SOURCE=1;

    *%jjqccmcoding(PRETXT_=CMTRT);
    *VARIABLE=CM_01_1;

    if ^missing(CMTRT) then do;

        CMTRT=upcase(CMTRT);

		CMDECOD=_CMDECOD;
        CMCLAS=_CMCLAS;
        CMCLASCD=_CMCLASCD;
		
        CMINDC="";
        CMPRESP='Y';
        %assign_STD(VAL=CMOCCUR);

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC="";
        CMDOSFRQ="";
        CMROUTE="";
        CMSTDTC="";
        CMENDTC="";
        CMENRF="";
        if CMOCCUR_STD ="Y" then CMSTRF="BEFORE";
        CMSTRTPT="";
        %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=CMSTTPT);
        output;
    end;

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY ;
run;

*****RAW DATA 2******
*****CM_PS_003 ****************;
data &domain._pre_2;
    attrib &&&domain._varatt_;
    set &domain._raw_2(drop=STUDYID /*where=(RECORDPOSITION=1)*/ );
    %assign_1;
    SOURCE=2;
    *%jjqccmcoding(PRETXT_=CMTRT);
    *VARIABLE=CM_02_1;
    if ^missing(CMTRT) then do;

        CMTRT=upcase(CMTRT);

        CMDECOD=CMTRT_RXPREF;
        CMCLAS=coalescec(CMTRT_ATC4,CMTRT_ATC3,CMTRT_ATC2,CMTRT_ATC1);
        CMCLASCD=coalescec(CMTRT_ATC4_CODE,CMTRT_ATC3_CODE,CMTRT_ATC2_CODE,CMTRT_ATC1_CODE);
        CMINDC="";
        CMPRESP='';
        CMOCCUR="";

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC="";
        CMDOSFRQ="";
        CMROUTE="";
        CMSTDTC="";
        CMENDTC="";
        CMENRF="";
        CMSTRF="";
        CMSTRTPT="";
        CMSTTPT="";
        output;
    end;

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY,CMSTTPT);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY CMSTTPT;

run;

*****RAW DATA 3******
*****FA_RA_006 ****************;
data &domain._pre_3;
    attrib &&&domain._varatt_;
    set &domain._raw_3(drop=STUDYID );
    %assign_1;
    SOURCE=3;

    *%jjqccmcoding(PRETXT_=CMTRT);
    *VARIABLE=CM_03_1;

    if ^missing(FAOBJ) then do;

        CMTRT=upcase(FAOBJ);
        CMCAT=FACAT;

        CMDECOD="";
        CMCLAS="";
        CMCLASCD="";

        CMINDC="";
        CMPRESP='Y';
        CMOCCUR=METYN_STD;

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC="";
        CMDOSFRQ="";
        CMROUTE="";
        CMSTDTC="";
        CMENDTC="";
        if FAEXYNSM_STD ='Y' then CMENRF='AFTER';
        if METYN_STD  ="Y" then CMSTRF="BEFORE";
        CMSTRTPT="";
        %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=CMSTTPT);
        output;
    end;

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY;
run;

*****RAW DATA 4******
*****CM_RA_005 ****************;
data &domain._pre_4;
    attrib &&&domain._varatt_;
    set &domain._raw_4(drop=STUDYID CMOCCUR  DURCUM DURCUM_STD );
    %assign_1;
    SOURCE=4;

    *%jjqccmcoding(PRETXT_=CMTRT);
    *VARIABLE=CM_04_1;

    if ^missing(CMTRT) then do;

        CMTRT=upcase(CMTRT);
        CMDECOD=CMTRT_RXPREF;
        CMCLAS=coalescec(CMTRT_ATC4,CMTRT_ATC3,CMTRT_ATC2,CMTRT_ATC1);
        CMCLASCD=coalescec(CMTRT_ATC4_CODE,CMTRT_ATC3_CODE,CMTRT_ATC2_CODE,CMTRT_ATC1_CODE);


        CMINDC="";
        CMPRESP='Y';
        %assign_STD(VAL=CMOCCUR);

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC="";
        CMDOSFRQ="";
        CMROUTE="";
        CMSTDTC="";
        CMENDTC="";
        if FAEXYNSM_STD ='Y' then CMENRF='AFTER';
        CMSTRF="";
        CMSTRTPT="";
        %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=CMSTTPT);
        output;
    end;

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY;
run;

*****RAW DATA 5******
*****TBINFO_1  ****************;
data &domain._pre_5;
    attrib &&&domain._varatt_;
    set &domain._raw_5(drop=STUDYID );
    %assign_1;
    SOURCE=5;

    *%jjqccmcoding(PRETXT_=CMTRT);
    *VARIABLE=CM_05_1;


    if ^missing(TBBCG_STD) then do;

        CMTRT='PREVIOUS BCG VACCINATION';

        CMCAT='PREVIOUS BCG VACCINATION';

        CMDECOD="";
        CMCLAS="";
        CMCLASCD="";

        CMINDC="";
        CMPRESP='Y';
        CMOCCUR=TBBCG_STD;

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC="";
        CMDOSFRQ="";
        CMROUTE="";
        CMSTDTC="";
        CMENDTC="";
        CMENRF='';
        CMSTRF="";
        CMSTRTPT="";

        output;
    end;

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY,CMSTTPT);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY CMSTTPT;
run;

*****RAW DATA 6******
*****CM_GL_900 ****************;
data &domain._pre_6;
    attrib &&&domain._varatt_;
    set &domain._raw_6(drop=STUDYID CMINDC CMROUTE CMDOSFRQ CMDOSU );
    %assign_1;
    SOURCE=6;
    length YY_ $200. /*CMTRT_RXPREF_CODE CMTRT_TRADE_NAME_CODE $200.*/;
    *%jjqccmcoding(PRETXT_=CMTRT);

    /*%jjqccmcoding(PRETXT_=CMTRT);*/
    *VARIABLE=CM_06_1;


    if ^missing(CMTRT) then do;


        CMTRT=upcase(CMTRT);
	    CMDECOD=CMTRT_RXPREF;
        CMCLAS=coalescec(CMTRT_ATC4,CMTRT_ATC3,CMTRT_ATC2,CMTRT_ATC1);
        CMCLASCD=coalescec(CMTRT_ATC4_CODE,CMTRT_ATC3_CODE,CMTRT_ATC2_CODE,CMTRT_ATC1_CODE);

        CMPRESP="";
        CMOCCUR="";
        /*CMINDC=upcase(CMINDC);*/
        %assign_STD(VAL=CMINDC)
        %assign_STD(VAL=CMROUTE)
        %assign_STD(VAL=CMDOSFRQ);

        if upcase(CMDOSFRQ_STD)^="FID" then CMDOSFRQ=CMDOSFRQ_STD;
        else if upcase(CMDOSFRQ_STD)="FID" then CMDOSFRQ="5 TIMES PER DAY";

        CMINDC=upcase(CMINDC);

        if ^missing(input(CMDSTXT,??best.)) then CMDOSE=input(CMDSTXT,??best.);
        if missing(input(CMDSTXT,??best.)) then CMDOSTXT=CMDSTXT;
        if ^missing(CMDSTXT) then CMDOSU=CMDOSU_STD;
        CMLOC="";

        %jjqcdate2iso(in_date=CMSTDAT, in_time=CMSTTIM, out_date=CMSTDTC);
        %jjqcdate2iso(in_date=CMENDAT, in_time=CMENTIM, out_date=CMENDTC);
        %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=CMSTTPT);

        if CMONGO=1 then CMENRF='AFTER';
        else CMENRF='';
        CMSTRF="";
        if CMPRIOR_STD ='Y' THEN CMSTRTPT='BEFORE';
        else if CMPRIOR_STD='N' then CMSTRTPT='AFTER';

        output;
    end;

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY  CMINDC_STD;
run;

*****RAW DATA 7******
*****CM_RA_001 ****************;
data &domain._pre_7;
    attrib &&&domain._varatt_;
    set &domain._raw_7(drop=STUDYID );
    %assign_1;
    SOURCE=7;
    length YY_ $200.;
    *%jjqccmcoding(PRETXT_=CMTRT);
    *VARIABLE=CM_07_1;


        if index(upcase(CMTRT),'OTHER')>0 and ^missing(CMTRTO) then  CMTRT=upcase(CMTRTO);
        else if index(upcase(CMTRT),'OTHER')=0 and ^missing(CMTRT_STD) then CMTRT=upcase(CMTRT_STD);

	    CMDECOD="";
        CMCLAS=/* coalescec(CMTRT_ATC4,CMTRT_ATC3,CMTRT_ATC2,CMTRT_ATC1); */"";
        CMCLASCD=/* coalescec(CMTRT_ATC4_CODE,CMTRT_ATC3_CODE,CMTRT_ATC2_CODE,CMTRT_ATC1_CODE); */"";
        CMPRESP='';
        CMOCCUR="";
        /*%assign_STD(VAL=CMINDC);*/
/*        CMINDC=upcase(CMINDC);*/
		if CMINDC = "Psoriatic Arthritis" then CMINDC= "TRIAL INDICATION";
		else if CMINDC = "Non-Psoriatic Arthritis" then CMINDC = "OTHER";

        CMROUTE="";
        CMDOSFRQ="";

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC=CMLOC_JNT_STD;

        %jjqcdate2iso(in_date=CMSTDAT, in_time=, out_date=CMSTDTC);
        CMENDTC="";
        %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=CMSTTPT);

        CMENRF='';
        CMSTRF="";
        if CMPRIOR_PS_STD ='Y' THEN CMSTRTPT='BEFORE';
        else if CMPRIOR_PS_STD='N' then CMSTRTPT='AFTER';

        if ^missing(cmtrt);

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY CMTRT_STD ;
run;

*****RAW DATA 8******
*****CM_RA_006 ****************;
data &domain._pre_8;
    attrib &&&domain._varatt_;
    set &domain._raw_8(drop=STUDYID CMOCCUR rename=(CMCAT=_CMCAT));
    %assign_1;
    SOURCE=8;
    *%jjqccmcoding(PRETXT_=CMTRT);


        CMTRT=upcase(CMTRT);
		CMCAT=strip(_CMCAT);

        /* CMDECOD=strip(CMTRT_PREFER_TEXT); */
	    CMDECOD=CMTRT_RXPREF;
        CMCLAS=coalescec(CMTRT_ATC4,CMTRT_ATC3,CMTRT_ATC2,CMTRT_ATC1);
        CMCLASCD=coalescec(CMTRT_ATC4_CODE,CMTRT_ATC3_CODE,CMTRT_ATC2_CODE,CMTRT_ATC1_CODE);
        CMPRESP='Y';
        CMOCCUR=strip(CMOCCUR_STD);
        %changelen(varname=CMOCCUR,tarlen=2,type=char);
        /*%assign_STD(VAL=CMINDC);*/
        CMINDC="";
        CMROUTE="";
        CMDOSFRQ="";

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC="";
        CMSTDTC="";
        CMSTRF="";
        CMENRF="";
        CMSTRTPT="";
        CMSTTPT="";
        CMTRTO="";
        /* %jjqcdate2iso(in_date=CMENDAT_TNF, in_time=, out_date=CMENDTC); */
        if CMTRT = "GOLIMUMAB IV" then do;
		  CMTRT   = "GOLIMUMAB";
		  CMROUTE = "INTRAVENOUS";
		end;

        if CMTRT = "GOLIMUMAB SC" then do;
		  CMTRT   = "GOLIMUMAB";
		  CMROUTE = "SUBCUTANEOUS";
		end;

        if ^missing(cmtrt);

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY,CMENDTC);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY ;
run;

*****RAW DATA 9******
*****CM_RA_007 ****************;
data &domain._pre_9;
    attrib &&&domain._varatt_;
    set &domain._raw_9(drop=STUDYID CMOCCUR rename=(CMCAT=_CMCAT));
    %assign_1;
    SOURCE=9;
    *%jjqccmcoding(PRETXT_=CMTRT);


        CMTRT=upcase(CMTRT);
		CMCAT=strip(_CMCAT);
        /* CMDECOD=strip(CMTRT_PREFER_TEXT); */
	    CMDECOD=CMTRT_RXPREF;
        CMCLAS=coalescec(CMTRT_ATC4,CMTRT_ATC3,CMTRT_ATC2,CMTRT_ATC1);
        CMCLASCD=coalescec(CMTRT_ATC4_CODE,CMTRT_ATC3_CODE,CMTRT_ATC2_CODE,CMTRT_ATC1_CODE);
        CMPRESP=' ';
        CMOCCUR=" ";
        %changelen(varname=CMOCCUR,tarlen=2,type=char);
        CMINDC="";
        CMROUTE="";
        CMDOSFRQ="";

        CMDOSE=.;
        CMDOSTXT="";
        CMDOSU="";
        CMLOC="";
        CMENDTC="";
        /* %jjqcdate2iso(in_date=CMENDAT_BT, in_time=, out_date=CMENDTC); */
        CMSTDTC="";
        CMSTTPT="";
        CMSTRTPT="";
        CMENRF='';
        CMSTRF="";

        if ^missing(cmtrt);

    call missing(&domain.SEQ,VISITNUM,EPOCH,&domain.STDY,&domain.ENDY);
    drop &domain.SEQ VISITNUM EPOCH &domain.STDY &domain.ENDY ;
run;
************************************************************
*  PILE UP ALL THE DATASETS ABOVE
************************************************************;
data &domain._base(&keep_sub);
    length CMTRT_ATC4 CMTRT_ATC3 CMTRT_ATC2 CMTRT_ATC1 CMTRT_ATC4_CODE CMTRT_ATC3_CODE CMTRT_ATC2_CODE CMTRT_ATC1_CODE $600;
    set &domain._pre_1 
        &domain._pre_2
        &domain._pre_3
        &domain._pre_4
        &domain._pre_5
        &domain._pre_6
        &domain._pre_7
        &domain._pre_8
        &domain._pre_9
    ;
	informat _all_;
	format _all_;

    if missing(CMDOSE) then call missing(CMDOSU);
    if  &raw_sub;
run;

%macro changeunit(var=,origin=,target=);
    if upcase(&var.)="&origin." then &var.="&target.";
%mend changeunit;

/*data &domain._base;
    set &domain._base;
    ***USE INTERNATIONAL UNIT INSTEAD;
    %changeunit(var=CMDOSU,origin=CAPSULE,target=CAPSULE)
    %changeunit(var=CMDOSU,origin=DROP,target=DROPS)
    %changeunit(var=CMDOSFRQ,origin=EVERY OTHER WEEK,target=QOS)
    %changeunit(var=CMDOSU,origin=GRAM,target=g)
    %changeunit(var=CMDOSU,origin=IMPLANT,target=IMPLANT)
    %changeunit(var=CMDOSU,origin=INTERNATIONAL UNIT,target=IU)
    %changeunit(var=CMDOSU,origin=MICROGRAM,target=ug)
    %changeunit(var=CMDOSU,origin=MILLIGRAM,target=mL)
    %changeunit(var=CMDOSU,origin=PATCH,target=PATCH)
    %changeunit(var=CMDOSFRQ,origin=Q4W,target=Q4S)
    %changeunit(var=CMDOSU,origin=TABLET,target=TABLET)
    %changeunit(var=CMDOSU,origin=VIAL,target=VIAL)
    %changeunit(var=CMDOSFRQ,origin=WEEKLY,target=QS)
run; */


************************************************************
*  ADD VISIT EPOCH DTC DY AND SEQ ETC.
************************************************************;
%jjqcvisit(in_data=&domain._base, out_data=&domain._1, date=, time=);
%jjqcmepoch(in_data=&domain._1,in_date=&domain.STDTC);

*ADD DY;
%jjqccomdy(in_data=&domain._1, in_var=&domain.STDTC, out_var=&domain.STDY);
%jjqccomdy(in_data=&domain._1, in_var=&domain.ENDTC, out_var=&domain.ENDY);

data &domain._1;
    set &domain._1;
    if CMSTDTC="" then epoch="";
    /*if CMDOSFRM="CAPSULE DELAYED RELEASE" then CMDOSFRM="CAPSULE, DELAYED RELEASE";
    else if CMDOSFRM="CAPSULE EXTENDED RELEASE" then CMDOSFRM="CAPSULE, EXTENDED RELEASE";
    else if CMDOSFRM="TABLET DELAYED RELEASE" then CMDOSFRM="TABLET, DELAYED RELEASE";*/
run;


proc sort data=&domain._1 nodup; by &&&domain._keyvar_; run;
/*%put &&&domain._keyvar_;  */
*KEY VAR ARE: STUDYID USUBJID CMTRT CMSTDTC CMGRPID CMSPID

*add seqnum;
%jjqcseq(in=&domain._1, out=&domain, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

************************************************************
*  FOR FINAL DATASETS OUTPUT AND COMPARATION,
   AS WELL AS CREATE PREREQUISITE DATASET FOR SUPP DOMAIN
************************************************************;
data supp&domain._raw; set &domain.; run;
data main_&domain.;set transfer.&domain.; run;
data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )

************************************************************
*  PREPARE FOR SUPP DOMAIN.
************************************************************;
%let domain=SUPP&domain.;
%let rdomain=%substr(&domain.,5,2);
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

data &domain._pre;
    attrib &&&domain._varatt_;
    set &domain._raw;
    RDOMAIN="&rdomain.";
    IDVAR="&rdomain.SEQ";
    IDVARVAL=strip(put(&rdomain.SEQ,best.));
    QEVAL="";
    QORIG="CRF";
    call missing(QLABEL);
    drop QLABEL;

    *VARIABLE CM_01_01;
    if ^missing(TBBCGPR) and SOURCE=5 then do;
       IDVAR="&rdomain.SPID";
       IDVARVAL=strip(&rdomain.SPID);
       QORIG="CRF";
       QNAM='TBBCGPR';QVAL=upcase(TBBCGPR_STD); output;
    end;
    *VARIABLE CM_02_01;
    if ^missing(CMINDDSC) and SOURCE=6 then do;
        IDVAR="&rdomain.SEQ";
        IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QORIG="CRF";
        QNAM='CMINDDSC';QVAL=upcase(CMINDDSC); output;
    end;
    *VARIABLE CM_03_01;
    if ^missing(CMLAT) and SOURCE=7 then do;
       IDVAR="&rdomain.SEQ";
       QORIG="CRF";
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLAT';QVAL=upcase(CMLAT); output;
    end;
    *VARIABLE CM_03_02;
    if ^missing(CMLOCO) and SOURCE=7 then do;
       IDVAR="&rdomain.SEQ";
       QORIG="CRF";
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLOCO';QVAL=upcase(CMLOCO); output;
    end;

    if ^missing(CMTRT_ATC1) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL1';QVAL=upcase(CMTRT_ATC1); output;
    end;

    if ^missing(CMTRT_ATC1_CODE) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL1CD';QVAL=upcase(CMTRT_ATC1_CODE); output;
    end;

    if ^missing(CMTRT_ATC2) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL2';QVAL=upcase(CMTRT_ATC2); output;
    end;

    if ^missing(CMTRT_ATC2_CODE) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL2CD';QVAL=upcase(CMTRT_ATC2_CODE); output;
    end;

    if ^missing(CMTRT_ATC3) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL3';QVAL=upcase(CMTRT_ATC3); output;
    end;

    if ^missing(CMTRT_ATC3_CODE) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL3CD';QVAL=upcase(CMTRT_ATC3_CODE); output;
    end;

    if ^missing(CMTRT_ATC4) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL4';QVAL=upcase(CMTRT_ATC4); output;
    end;

    if ^missing(CMTRT_ATC4_CODE) then do;
       IDVAR="&rdomain.SEQ";
       QORIG="ASSIGNED";
       
       IDVARVAL=strip(put(&rdomain.SEQ,best.));
       QNAM='CMLVL4CD';QVAL=upcase(CMTRT_ATC4_CODE); output;
    end;
run;

proc sql;
    create table &domain._base as
        select a.*,b.QLABEL
        from &domain._pre as a
        left join  (select VALUEOID,VALVAL,strip(compress(VALLABEL,"0A0D00"x)) as QLABEL length=40
                    from VALDEF
                    where strip(compress(VALUEOID,"0A0D00"x))="&domain..QNAM") as b
        on a.QNAM=strip(compress(b.VALVAL,"0A0D00"x));
quit;

proc sort data=&domain._base; by &&&domain._keyvar_; run;
/*%put &&&domain._keyvar_;*/

************************************************************
*  FOR OUTPUTING SUPP DATASET AND COMPARATION.
************************************************************;
data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain._base;
    if  &raw_sub;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
