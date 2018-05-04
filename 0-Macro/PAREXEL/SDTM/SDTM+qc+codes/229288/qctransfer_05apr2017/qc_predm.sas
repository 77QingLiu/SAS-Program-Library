/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: JANSEEN RESEARCH and DEVELOPMENT / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         27Jun2016 / $ $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_predm.sas $

  Files Created:         dm.log
                         dm.sas7bdat
                         suppdm.sas7bdat

  Program Purpose:       To Create 1. Demographics Dataset
                                   2. Supplemental Qualifiers for DM Dateset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 145 $
-----------------------------------------------------------------------------*/
/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;
options NOTHREADS;

proc format;
    value $ACTARM   'SCRNFAIL'  ='SCREEN FAILURE'
                    'NOTASSGN'  ='NOT ASSIGNED'
                    'NOTTRT'    ='NOT TREATED'
                    'VELSC'     ='VELCADE SC'
                    'VELIV'     ='VELCADE IV'
                    ;
            
run;

*------------------- Get meta data --------------------;
%let domain=DM;
%jjqcvaratt(domain=&domain)
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitenumber sitegroup instanceid 
             instancerepeatnumber folderid folder folderseq targetdays datapageid pagerepeatnumber recorddate recordid 
             mincreated maxupdated savets ;
data DM_GL_900;
    set raw.DM_GL_900(where=(&raw_sub));
    rename siteid=siteid_ AGEU=AGEU_ SEX=SEX_ ETHNIC=ETHNIC_;
    drop &dropvar; 
run;
proc sort;by subject;run;

data DM_GL_901;
    set raw.DM_GL_901(where=(&raw_sub) drop=siteid_ SUBJID);
    rename siteid=siteid_;
    drop &dropvar; 
run;
proc sort;by subject;run;

data raw_sv;
    set raw.SV_GL_900(where=(&raw_sub));
    %jjqcdate2iso(in_date =VISDAT, in_time=, out_date=SVSTDTC);  
    /* if not prxmatch('/disease|unsch/io',foldername); */
    drop &dropvar; 
run;
proc sort;by subject;run;

data DS_GL_900;
    set raw.DS_GL_900(where=(&raw_sub));
    %jjqcdate2iso(in_date =DSSTDAT, in_time=, out_date=DSDTC);    
    keep subject foldername instancename DSDTC; 
run;
proc sort;by subject;run;    

data DS_GL_902;
    set raw.DS_GL_902(where=(&raw_sub));
    keep subject foldername instancename REGIME_NAME REGIME_DESCRIPTION; 
run;
proc sort;by subject;run; 

data SV_GL_900;
    set raw.SV_GL_900(where=(&raw_sub));
    %jjqcdate2iso(in_date =VISDAT, in_time=, out_date=SVSTDTC);    
    keep subject foldername instancename SVSTDTC; 
run;
proc sort;by subject;run;    

*------------------- Mapping --------------------;
/* Variable no need derived */
data DM_1_;
    attrib &&&domain._varatt_;
    set DM_GL_900(in=a) DM_GL_901(in=b);
    flag = a+b*10;
    STUDYID = strip(project);
    DOMAIN  = "&domain";
    USUBJID = catx('-', project, subject);
    SUBJID  = strip(subject);
    %jjqcdate2iso(in_date =RFICDAT, in_time=, out_date=RFICDTC);
    SITEID = scan(SITE,1,'-_');
    INVID  = put(siteid_,best. -l);
    %jjqcdate2iso(in_date =BRTHDAT, in_time=, out_date=BRTHDTC);
    AGE  = AGE;
    AGEU = ifc(^missing(AGE),AGEU_STD,'');
    SEX  = substr(SEX_,1,1);
    if not (missing(RACEAIAN) and missing(RACEA) and missing(RACEBA) and missing(RACENHOP) and missing(RACEW) and missing(RACEOTHR)) then do;
        if RACEAIAN+RACEA+RACEBA+RACENHOP+RACEW+RACEOTHR>1 then RACE='MULTIPLE';
        else if RACEW    =1 then RACE='WHITE';
        else if RACEBA   =1 then RACE='BLACK OR AFRICAN AMERICAN';
        else if RACEA    =1 then RACE='ASIAN';
        else if RACEAIAN =1 then RACE='AMERICAN INDIAN OR ALASKA NATIVE';
        else if RACENHOP =1 then RACE='NATIVE HAWAIIAN OR OTHER PACelse IFIC ISLANDER';
        else if RACEOTHR =1 then RACE='OTHER';
        else if RACEUNK  =1 then RACE='UNKNOWN';
        else if RACENR   =1 then RACE='NOT REPORTED';
    end;
    ETHNIC  = upcase(strip(ETHNIC_));
    COUNTRY = 'CHN';
    call missing(of RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFPENDTC DTHDTC DTHFL INVNAM ARMCD ARM ACTARMCD ACTARM DMDTC DMDY);
    drop RFSTDTC RFENDTC RFXSTDTC RFXENDTC DTHDTC DTHFL  ACTARMCD ACTARM DMDTC DMDY ARMCD ARM INVNAM;
run;
proc sql;
    create table DM_1 as 
    select * 
    from DM_1_
    group by USUBJID
    having flag=min(flag);
quit;

/* RFSTDTC & RFENDTC & RFXSTDTC &RFXENDTC*/
%macro DTC(DTC=,where=,timepoint=,TimeFlag=);
data EX_&DTC._;
    set raw.EX_ONC_001B_2(where=(&raw_sub) in=a)
        raw.EX_ONC_001B(where=(&raw_sub) in=b)
        raw.EX_ONC_001B_1(where=(&raw_sub) in=c);
    %jjqcdate2iso(in_date =EXSTDAT, in_time=EXSTTIM, out_date=EXSTDTC);
    if find(EXSTDTC,'T') then TimeFlag = %scan(&TimeFlag,1,|); else TimeFlag= %scan(&TimeFlag,2,|);
    if &where;
    EXSTDTC_ = scan(EXSTDTC,1,'T');
    keep site subject instancename foldername EXCAT EXSTDTC EXSTDTC_ TimeFlag;
run;
proc sort;by subject EXSTDTC_ TimeFlag EXSTDTC;run;
data EX_&DTC.;
    set EX_&DTC._;
    by subject EXSTDTC_ TimeFlag EXSTDTC;
    if &timepoint..subject;
run;
%mend;
%DTC(DTC=RFSTDTC,timepoint=first,TimeFlag=0|1,where=upcase(EXCAT) ne "DEXAMETHASONE" AND EXSTDTC NE "");
%DTC(DTC=RFXSTDTC,timepoint=first,TimeFlag=0|1,where=EXSTDTC NE "");
%DTC(DTC=RFXENDTC,timepoint=last,TimeFlag=0|1,where=EXSTDTC NE "");


proc sql;
    create table RFENDTC as 
    select coalescec(a.subject,b.subject) as subject,case when ^missing(a.DSDTC) then a.DSDTC 
                           else b.SVSTDTC end as RFENDTC length=19
    from DS_GL_900 as a full join (select distinct subject,max(SVSTDTC) as SVSTDTC from raw_sv group by subject) as b 
    on a.subject=b.subject;
quit;

/* DTHDTC & DTHFL*/
data DS_raw;
    set raw.DD_GL_900(where=(&raw_sub));
    %jjqcdate2iso(in_date =DTHDAT, in_time=, out_date=DTHDTC);
    keep subject DTHDTC;
run;

data AE_raw;
    set raw.AE_GL_900(where=(&raw_sub));
    if upcase(AESDTH) = 'YES';
run;

/* ACTARMCD */
proc sql;
    create table ACTARMCD as 
    select distinct d.subject,/*  a.DSRANDYN ,b.DSDECOD_REAS, c.EXCAT, */
            case when find(b.DSDECOD_REAS,'Screen failure','i') then 'SCRNFAIL'
                 when a.DSRANDYN_STD = 'N' then 'NOTASSGN'
                 when a.DSRANDYN_STD = 'Y' and missing(c.EXCAT) then 'NOTTRT'
                 when upcase(EXCAT)  = 'VELCADE SC' then 'VELSC'
                 when upcase(EXCAT)  = 'VELCADE IV' then 'VELIV'
                 else 'NOTASSGN' end as ACTARMCD length=20,
            put(calculated ACTARMCD,$ACTARM.) as ACTARM length =60,a.DSRANDYN_STD,c.EXCAT
    from raw.DM_GL_901(where=(&raw_sub)) as d 
        left join raw.DS_GL_900(where=(&raw_sub)) as b 
            on d.subject=b.subject
        left join raw.DS_GL_902(where=(&raw_sub)) as a
            on d.subject = a.subject
        left join (select distinct subject,EXCAT from EX_RFSTDTC_(where=(EXCAT ne 'Dexamethasone' and &raw_sub))) as c
            on d.subject = c.subject
        where ^missing(calculated ACTARMCD);
quit;

/* Join All */
proc sql;
    create table DM_2 as 
    select DISTINCT a.*,
           g.EXSTDTC as RFSTDTC length=19,
           b.EXSTDTC as RFXSTDTC length=19,
           case when missing(g.EXSTDTC) then "" when missing(b.EXSTDTC) then '' else f.RFENDTC end as RFENDTC length=19,
           h.EXSTDTC as RFXENDTC length=19,
           c.DTHDTC as DTHDTC length=19,
           case when upcase(d.AESDTH) ='YES' then 'Y' else '' end as DTHFL,
           e.REGIME_NAME as ARMCD length=20,e.REGIME_DESCRIPTION as ARM length=60,
           i.ACTARMCD,i.ACTARM
    from DM_1 as a 
         left join DS_raw as c 
            on a.subject=c.subject
         left join AE_raw as d 
            on a.subject=d.subject
         left join DS_GL_902 as e 
            on a.subject=e.subject
         left join RFENDTC as f 
            on a.subject=f.subject
         left join EX_RFXSTDTC as b 
            on a.subject=b.subject 
         left join EX_RFXENDTC as h 
            on a.subject=h.subject                        
         left join EX_RFSTDTC as g 
            on a.subject=g.subject
         left join ACTARMCD as i 
            on a.subject=i.subject;
quit;

*------------------- Derive SV related variable --------------------;
proc sql;
    create table DM_3 as 
    select a.*, b.SVSTDTC as DMDTC length=19,
               case when prxmatch('/(\d{4}-\d{2}-\d{2})/',cats(b.SVSTDTC)) and prxmatch('/(\d{4}-\d{2}-\d{2})/',cats(a.RFSTDTC)) 
                         then input(scan(b.SVSTDTC,1,'T'),e8601da.) - input(scan(a.RFSTDTC,1,'T'),e8601da.)
                         + (input(scan(b.SVSTDTC,1,'T'),e8601da.) ge input(scan(a.RFSTDTC,1,'T'),e8601da.))
                    else . end as DMDY
    from DM_2 as a 
        left join SV_GL_900 as b
            on a.subject=b.subject and a.instancename=b.instancename and a.foldername=b.foldername;
quit;

/* FW Updated on 03Mar2017 */
proc sql noprint;
  create table dm_4 as
  select a.*,b.ivname as INVNAM
  from dm_3 a
  left join
  rawcust.pi b
  on input(a.invid,best.)=b.siteid;
quit;
proc sort data=dm_4;by USUBJID;run;
/* End of Updating */
*------------------- Output --------------------;
data qtrans.&domain(label="&&&domain._dlabel_" &keep_sub);
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set DM_4;
    if missing(ACTARMCD) then do;
        ACTARMCD = "NOTASSGN";
        ACTARM   = "NOT ASSIGNED";
    end;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

*------------------- Compare --------------------;

%GMCOMPARE( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.dm
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );


************************************SUPPDM********************************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPDM;
%jjqcvaratt(domain=&domain)

*------------------- Mapping --------------------;
data SUPPDM_1a;
    attrib &&&domain._varatt_;
    set DM_4;
    RDOMAIN  ='DM';
    IDVAR    ='';
    IDVARVAL ='';
    QORIG    ='CRF';
    QEVAL    ='';
/* FW Updated on 20Mar2017 due to migration */
if ^missing(psubjid) then do;
  qnam="PSUBJID";
  qval=strip(psubjid);
  qlabel=put(QNAM,$DM_QL.);
  output;end;
/* End of Updating */
    array RACE_(*) RACEAIAN RACEA RACEBA RACENHOP RACEW RACEOTHR;
    if not (missing(RACEAIAN) and missing(RACEA) and missing(RACEBA) and missing(RACENHOP) and missing(RACEW) and missing(RACEOTHR)) then do;

    if RACE='OTHER' and sum(RACEAIAN,RACEA,RACEBA,RACENHOP,RACEW,RACEOTHR) <1 then do;
        QNAM   ='RACEOTH';
        QVAL   =strip(RACEOTH);
        QLABEL =put(QNAM,$DM_QL.);
        output;
    end;
    else if RACE='MULTIPLE' then do;
         if RACEW    =1 then do;QNAM='RACEW';  QVAL='WHITE';QLABEL=put(QNAM,$DM_QL.);output;end;
         if RACEBA   =1 then do;QNAM='RACEBA'; QVAL='BLACK OR AFRICAN AMERICAN';QLABEL=put(QNAM,$DM_QL.);output;end;
         if RACEA    =1 then do;QNAM='RACEA';  QVAL='ASIAN';QLABEL=put(QNAM,$DM_QL.);output;end;
         if RACEAIAN =1 then do;QNAM='RACEAIAN'; QVAL='AMERICAN INDIAN OR ALASKA NATIVE';QLABEL=put(QNAM,$DM_QL.);output;end;
         if RACENHOP =1 then do;QNAM='RACENHOP'; QVAL='NATIVE HAWAIIAN OR OTHER PACIFIC ISLANDER';QLABEL=put(QNAM,$DM_QL.);output;end;
         if RACEOTHR =1 then do;QNAM='RACEOTHR'; QVAL='OTHER';QLABEL=put(QNAM,$DM_QL.);output;end;
         if ^missing(RACEOTH) then do;QNAM='RACEOTH'; QVAL=strip(RACEOTH);QLABEL=put(QNAM,$DM_QL.);output;end;
    end;
    end;
run;

data SUPPDM_1b;
    attrib &&&domain._varatt_;
    set raw.DS_GL_905(drop=studyid siteid where=(&raw_sub));
    USUBJID = catx('-', project, subject);
    STUDYID=strip(project);
    RDOMAIN  ='DM';
    IDVAR    ='';
    IDVARVAL ='';
    QORIG    ='CRF';
    QEVAL    ='';
    QNAM     ='DMSBSTD';
    QVAL     =strip(DSSTUDYN_STD);
    QLABEL   =put(QNAM,$DM_QL.);
run;

*------------------- Output --------------------;
data SUPPDM_2;
    set SUPPDM_1b SUPPDM_1a;
run;
%qcoutput(in_data =SUPPDM_2 );

*------------------- Compare --------------------;
%GMCOMPARE( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );
