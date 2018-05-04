/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         FU WANG        $LastChangedBy: xiaz $
  Last Modified:     2017-06-06    $LastChangedDate: 2017-09-13 02:15:40 -0400 (Wed, 13 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_predm.sas $

  Files Created:         qc_dm.log
                         dm.sas7bdat
                         suppdm.sas7bdat

  Program Purpose:       To QC 1. Demographics Dataset
                                   2. Supplemental Qualifiers for DM Dateset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 28 $
-----------------------------------------------------------------------------*/

/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

/*DM*/
%let domain=DM;
%jjqcvaratt(domain=&domain)
/*Keep Subject*/
%jjqcdata_type;

/*Deriving variables*/
/*RFSTDTC*/
/*RFENDTC*/
data dm5;
    set raw.DS_GL_900(drop=STUDYID where=(&raw_sub));
    length STUDYID USUBJID $40 RFENDTC $19;
    STUDYID=strip(PROJECT);
    USUBJID=catx("-", PROJECT, SUBJECT);
    %jjqcdate2iso(in_date=DSSTDAT, out_date=RFENDTC);
    keep STUDYID USUBJID RFENDTC;
    proc sort;
    by STUDYID USUBJID;
run;

/*RFXSTDTC RFXENDTC*/


options nomprint;
/*EX Loop*/
%macro loop(update=,i=,ind=,ind1=,int1=,typ1=);
data exst&i;
    set &ind(drop=STUDYID);
    *** Updated for RFSTDTC to just consider Daratumumab treatment ***;
    %if &update.=Y %then where upcase(extrt)='DARATUMUMAB';;

    length STUDYID USUBJID $40 RFXSTDTC $19;
    STUDYID=strip(PROJECT);
    USUBJID=catx("-", PROJECT, SUBJECT);
    format TIME datetime19.;
    TIME=.;
    %if &ind1^= and &int1^= %then %do;
        if missing(&int1) or prxmatch('/(UN|UK)/i',&int1) then do;&int1='00:00';flag=1;end;
                if prxmatch('/^(\d{2})$/i', cats(&int1)) then do; &int1=cats(&int1, ':00'); flag=2; end;
        if not missing(&ind1) then
           TIME=input(catx(':',put(input(scan(put(&ind1,is8601dt.),1,'T'),yymmdd10.),date9.),&int1),datetime19.);
    %end;
    %else %if &ind1^= and &int1= %then %do;
        flag=1;
        if not missing(&ind1) then
           TIME=input(catx(':',put(input(scan(put(&ind1,is8601dt.),1,'T'),yymmdd10.),date9.),'00:00'),datetime19.);
    %end;
    %if &typ1=c %then %do;
        %jjqcdate2iso(in_date=&ind1, in_time=&int1, out_date=RFXSTDTC);
    %end;
    %else %if &typ1=d %then %do;
        %jjqcdate2iso(in_date=&ind1,out_date=RFXSTDTC);
    %end;
    %else %if &typ1= %then RFXSTDTC='';;
    

    keep STUDYID USUBJID TIME RFXSTDTC flag;
run;


%mend;

%loop(update=,i=1,ind=raw.ex4,ind1=EXSTDT,int1=EXSTTM,typ1=c);
%loop(update=,i=2,ind=raw.ex5,ind1=EXSTDT5,int1=EXSTTM,typ1=c);

data ex_all;
    set exst:(rename=(rfxstdtc=dtc));
    if FLAG=2 then DTC=prxchange('s/(.+)(:00)/\1/', -1, DTC);
run;

proc sort data=ex_all;by studyid usubjid time;run;

data texst;
    set ex_all(where=(TIME^=.));
    by STUDYID USUBJID TIME;
    if first.USUBJID;
    rfxstdtc=dtc;
    drop dtc;
run;

data texen;
    set ex_all(where=(TIME^=.));
    by STUDYID USUBJID TIME;
    if last.USUBJID;
    rfxendtc=dtc;
    drop dtc time;
run;



data dm6;
    merge texst texen;
    by STUDYID USUBJID;
    keep STUDYID USUBJID RFXSTDTC RFXENDTC;
run;


/*RFICDTC SITEID BRTHDTC AGE AGEU_STD SEX_STD ETHINIC_STD*/
data dm7;
    set raw.DM_GL_900(drop=STUDYID AGEU SEX ETHNIC rename=(age=age_) where=(&raw_sub));
    length STUDYID USUBJID $40 RFSTDTC_ BRTHDTC_ RFICDTC_ $19 AGEU $6 SEX $2 ETHNIC $22 INVID $20 RACE $41;
    format AGE;
    informat AGE;
    STUDYID=strip(PROJECT);
    DOMAIN="&domain";
    USUBJID=catx("-", PROJECT, SUBJECT);
    /*if nmiss(rficdat,brthdat)=0 then age=int(((rficdat-brthdat)/(24*60*60)+1)/365.25);*/
	AGE=AGE_;
    if AGE^=. then AGEU=AGEU_STD;
    SEX=SEX_STD;
    if RACEW=1 then RACE='WHITE';
    if RACEBA=1 then RACE='BLACK OR AFRICAN AMERICAN';
    if RACEA=1 then RACE='ASIAN';
    if RACEAIAN=1 then RACE='AMERICAN INDIAN OR ALASKA NATIVE';
    if RACENHOP=1 then RACE='NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER';
    
    array rac(*) RACEW RACEBA RACEA RACEAIAN RACENHOP ;
    do i=1 to dim(rac);
        if rac(i)=. then rac(i)=0;
    end;

    if sum(RACEW,RACEBA,RACEA,RACEAIAN,RACENHOP)>1 then RACE = 'MULTIPLE';
    %jjqcdate2iso(in_date=RFICDAT, out_date=RFSTDTC_);
    %jjqcdate2iso(in_date=BRTHDAT, out_date=BRTHDTC_);
    %jjqcdate2iso(in_date=RFICDAT, in_time=, out_date=RFICDTC_);
    ETHNIC=ETHNIC_STD;
	if ETHNIC='NOT REPORTED' then ETHNIC='';
    INVID=cats(SITEID);
    call missing(rfstdtc_);
run;

/*DMDTC*/
proc sql;
    create table dm8 as
        select a.*, RFSTDTC_ as RFSTDTC
                  , BRTHDTC_ as BRTHDTC
                  , RFICDTC_ as RFICDTC
                  , VISDAT,VISDAT_YY,VISDAT_MM,VISDAT_DD
        from dm7 a
        left join
        raw.SV_GL_900 b
        on a.SITE=b.SITE and a.SUBJECT=b.SUBJECT and a.INSTANCENAME=b.INSTANCENAME;
quit;

data dm9;
    set dm8;
    length DMDTC $19;
    %jjqcdate2iso(in_date=VISDAT, out_date=DMDTC);
    proc sort;
    by STUDYID USUBJID;
run;

/*Subject*/
data dm10_;
    set raw.DM_GL_901(drop=STUDYID rename=SUBJID=SUBJID_);
    length STUDYID USUBJID $40 SUBJID INVID $20;
    STUDYID=strip(PROJECT);
    USUBJID=catx("-", PROJECT, SUBJECT);
    SUBJID=cats(SUBJID_);
    INVID=cats(SITEID);
    keep STUDYID USUBJID SUBJID INVID SITEID SITENUMBER SITE SITEGROUP;
run;

proc sort data=dm10_;
   by SITEID;
run;

proc sort data=rawcust.pi out=pi;
  by SITEID;
run;

data dm10;
  merge dm10_(in=a) pi(in=b);
  by SITEID;
  if a;
run;

    proc sort;
    by STUDYID USUBJID;
run;

 
/*Combine All*/

/*Remove Dup*/
%macro rdup(ind=);
proc sort data=&ind nodupkey;
    by STUDYID USUBJID;
run;
%mend rdup;

%rdup(ind=dm10)
%rdup(ind=dm5)
%rdup(ind=dm6)
%rdup(ind=dm9)

data comb;
    merge dm10(in=a) dm5 dm6 dm9 ;
    by STUDYID USUBJID;
    if a;
    subject=scan(usubjid,2,'-');
run;

/*RFSTDTC*/
data dm11;
    set comb;
    if missing(domain) then domain='DM';
      RFSTDTC=RFXSTDTC;
    /*if RFSTDTC2 not in ('','-----') then RFSTDTC=RFSTDTC2;*/
run;

proc sort data=dm11;by subject;run;

/*actual arm and armcd*/

data zr;
  set dummy.zr(keep=usubjid zrtestcd zrorres);
  if zrtestcd='TXPCD';
run;

data arm;
    set zr;
    length armcd actarmcd $20 arm actarm $60 subject $20;
    if zrorres="GUSE_DUM" then do; 
      armcd="GUS";
      arm='Guselkumab 100 mg';
	end;
    if zrorres="GUSP_DUM" then do;
      armcd="GUSPBO";
      arm='Guselkumab 100 mg and Placebo Alternate';
    end;
    if zrorres="PCBO_DUM" then do;
      armcd="PBO-GUS";
	  arm='Placebo to Guselkumab 100 mg';
	end;

	actarm=arm;
	actarmcd=armcd;
    subject=scan(usubjid,2,'-');
    
    
    keep arm armcd actarm actarmcd subject;
run;

proc sort nodupkey data=arm;by subject;run;

data dm11;
    merge dm11(in=a) arm;
    by subject;
    /*if not missing(subject);*/
run;

/*INVID INVNAM COUNTRY*/
data dm12;
    set dm11;
    length INVNAM $120 COUNTRY $3;
/*    call missing(INVNAM,COUNTRY);*/
    INVNAM=strip(IVNAME);
	COUNTRY=strip(SITEGROUP);

    proc sort nodupkey;
    by STUDYID USUBJID;
run;

/*DTHDTC DTHFL*/
data dm13;
    set raw.DD_GL_900(drop=STUDYID where=(&raw_sub));
    length STUDYID USUBJID $40 DTHDTC $19;
    STUDYID=strip(PROJECT);
    USUBJID=catx("-", PROJECT, SUBJECT);
    %jjqcdate2iso(in_date=DTHDAT, in_time=DTHTIM, out_date=DTHDTC);
    if not missing(subject) then DTHFL='Y';
    keep STUDYID USUBJID DTHDTC DTHFL;
    proc sort nodupkey;
    by STUDYID USUBJID;
run;

/*RFPENDTC*/
data dm14;
    set raw.DS_GL_900(drop=STUDYID where=(&raw_sub));
    length STUDYID USUBJID $40 RFPENDTC $19;
    STUDYID=strip(PROJECT);
    USUBJID=catx("-", PROJECT, SUBJECT);
    %jjqcdate2iso(in_date=DSSTDAT, out_date=RFPENDTC);
    keep STUDYID USUBJID RFPENDTC DSDECOD_REAS_STD;
    proc sort nodupkey;
    by STUDYID USUBJID;
run;

data dm16;
    merge dm12 dm13 dm14;
    by STUDYID USUBJID;
run;

/*ARM ARMCD*/

data dm16;
    set dm16;
    if prxmatch('/(SCREEN FAILURE)/',DSDECOD_REAS_STD) then do;
        ACTARMCD='SCRNFAIL';
        ARMCD='SCRNFAIL';
        ACTARM='Screen Failure';
        ARM='Screen Failure';
    end;
        
run;

/*Remove FORMAT and INFORMAT*/
proc datasets lib=work nolist;
    modify dm16;
    attrib STUDYID format= informat=
           ARM     format= informat=
           ARMCD   format= informat=
    ;
quit;


/*SITEID DMDY*/
data dm17;
    set dm16(drop=SITEID);
    length SITEID $10;
    SITEID=scan(SITE,1,'-');
    if arm='Screen Failure' then rfstdtc='';
    if RFSTDTC='' then RFENDTC='';
    if cmiss(DMDTC,RFSTDTC)=0 then do;
        DMDTC1=input(prxchange('s/(\d{4}-\d{2}-\d{2})T?(.+?)/\1/',-1,DMDTC),yymmdd10.);
        RFSTDTC1=input(prxchange('s/(\d{4}-\d{2}-\d{2})T?(.+?)/\1/',-1,RFSTDTC),yymmdd10.);
        DMDY=DMDTC1-RFSTDTC1 + (DMDTC1>=RFSTDTC1);
    end;
run;

/* [FW 13JUL2017] */
/* data pi;
    set rawcust.pi;
run;

proc sort data=pi;by siteid ivname;run;
proc sort nodupkey data=pi;by siteid;run;

proc sql;
    create table dm18 as
        select a.*
             , upcase(SITEGRP) as COUNTRY length=3
             , b.SITEID as SITEID_
        from dm17(drop=COUNTRY INVNAM) a
        left join
        rawcust.site b
        on cats(a.SITENUMBER)=cats(b.SITENUM)
        ;

    create table dm19 as
        select a.*
             , upcase(IVNAME) as INVNAM length=120
        from dm18 a
        left join
        pi c
        on cats(a.SITEID_)=cats(c.SITEID)
        order by STUDYID, USUBJID
        ;
quit; */

data dm19;
        set dm17;
        if prxmatch('/(SCREEN FAILURE)/',DSDECOD_REAS_STD)=0 then do;
		  if missing(ARMCD) then do;
            arm='Not Assigned';
            armcd="NOTASSGN";
            actarm='Not Assigned';
            actarmcd="NOTASSGN";
		  end;
          else if missing(rfxstdtc) then do;
             actarm="Not Treated";
             actarmcd="NOTTRT";
          end;
		  else if not missing(rfxstdtc) then do;
		     actarm=arm;
             actarmcd=armcd;
		  end;
        end;
run;


/*Output dataset DM*/
data qtrans.&domain(label="&&&domain._dlabel_" &keep_sub);
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set dm19;
    if not missing(usubjid);
        call missing(rfpendtc);
    keep &&&domain._varlst_;
run;

/*SUPPDM*/
%let domain=SUPPDM;
%jjqcvaratt(domain=&domain)

/*Deriving variables*/
%macro suppdm(i=,qnam=);
data suppdm&i;
    set dm19;
    length STUDYID USUBJID QLABEL $40 IDVARVAL QVAL $200 QNAM $8;
    RDOMAIN='DM';
    IDVAR='';
    IDVARVAL='';
    &qnam;;

    QLABEL=put(QNAM,$DM_QL.);
    QORIG='CRF';
    QEVAL='';
    if RACE='MULTIPLE' then do;
        %if &i=1 %then QVAL='WHITE';
        %else %if &i=2 %then QVAL='BLACK OR AFRICAN AMERICAN';
        %else %if &i=3 %then QVAL='ASIAN';
        %else %if &i=4 %then QVAL='AMERICAN INDIAN OR ALASKA NATIVE';
        %else %if &i=5 %then QVAL='NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER';;
       
        output;
    end;
run;
%mend suppdm;

data qnam;
    infile cards truncover;
    input qnam $100.;
    i=_n_;
cards;
if RACEW=1 then QNAM= 'RACEW'
if RACEBA=1 then QNAM = 'RACEBA'
if RACEA=1 then QNAM = 'RACEA'
if RACEAIAN=1 then QNAM = 'RACEAIAN'
if RACENHOP=1 then QNAM = 'RACENHOP'
;
run;

data _null_;
    set qnam;
    call execute('%nrstr(%suppdm(i='||cats(i)||',qnam=%str('||cats(qnam)||')))');
run;

data suppdm6;
    set dm19;
    length STUDYID USUBJID QLABEL $40 IDVARVAL QVAL $200 QNAM $8;
    RDOMAIN='DM';
    IDVAR='';
    IDVARVAL='';
    IF NOT MISSING(PSUBJID) THEN DO;QNAM="PSUBJID";QVAL=strip(PSUBJID);END;

    QLABEL=put(QNAM,$DM_QL.);
    QORIG='CRF';
    QEVAL='';
run;

data suppdm10;
    set suppdm1-suppdm6;
    if not missing(QNAM);
run;

/*Sort*/
proc sort data=suppdm10 nodupkey;
    by &&&domain._keyvar_;
run;

/*Output dataset SUPPDM*/
data qtrans.&domain(label="&&&domain._dlabel_" &keep_sub);
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set suppdm10;
    keep &&&domain._varlst_;
run;

%let domain=DM;
%let gmpxlerr=0;
************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );

%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.supp&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );
/*EOP*/
