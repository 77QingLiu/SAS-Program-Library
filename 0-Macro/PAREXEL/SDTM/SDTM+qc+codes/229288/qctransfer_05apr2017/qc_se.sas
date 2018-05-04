/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         28Jun2016 / $LastChangedDate: 2016-11-02 23:10:29 -0400 (Wed, 02 Nov 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_se.sas $

  Files Created:         qc_SE.log
                         SE.sas7bdat

  Program Purpose:       To QC Subject Elements Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 57 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=SE;
%jjqcvaratt(domain=SE);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier site sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid pagerepeatnumber recorddate recordid 
             mincreated maxupdated savets ;
data DM_GL_900;
    set raw.DM_GL_900(where=(&raw_sub));
    if ^missing(RFICDAT);
    drop &dropvar;
run;

data raw_sv;
    set qtrans.sv;
run;

data raw_ex;
    set raw.EX_ONC_001B(where=(&raw_sub))
        raw.EX_ONC_001B_1(where=(&raw_sub));
    %jjqcdate2iso(in_date =EXSTDAT, in_time=EXSTTIM, out_date=EXSTDTC);
    keep PROJECT site subject instancename foldername folderseq EXCAT EXSTDTC EXAMONT_ADA;
run;

data DS_GL_900;
    set raw.DS_GL_900(where=(&raw_sub));
    %jjqcdate2iso(in_date =DSSTDAT, in_time=, out_date=DSSTDTC);
    drop &dropvar;
run;    

data DS_GL_908;
    set raw. DS_GL_908(where=(&raw_sub));
    %jjqcdate2iso(in_date =DSSTDAT_TDD, in_time=, out_date=DSSTDTC);
    drop &dropvar;
run;

data CM_ONC_003_;
    set raw.CM_ONC_003(where=(&raw_sub));
    drop &dropvar;
    %jjqcdate2iso(in_date =CMSTDAT, in_time=, out_date=CMSTDTC);
run;
proc sql;
    create table CM_ONC_003 as /* Flag unique log line */
    select distinct subject,CMSTDTC
    from  CM_ONC_003_
    group by subject
    having CMSTDTC=min(CMSTDTC);
quit;

data CE_ONC_003_;
    set raw.CE_ONC_003(where=(&raw_sub));
    %jjqcdate2iso(in_date =CESTDAT, in_time=, out_date=CESTDTC);
    if ^missing(CESTDTC);
run;
proc sql;
    create table CE_ONC_003 as 
    select distinct PROJECT,subject,CESTDTC
    from CE_ONC_003_
    group by subject
    having CESTDTC=min(CESTDTC);
quit;

*------------------- Mapping --------------------;
/* DM */
data SE_dm_;
    set DM_GL_900;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    ETCD    ='SCRN';
    ELEMENT = 'SCREENING';
    %jjqcdate2iso(in_date =RFICDAT, in_time=, out_date=SESTDTC);
    TAETORD =1;
    epoch   ='SCREENING';
    call missing(of SEENDTC SESTDY SEENDY SESEQ);
    drop SEENDTC SESTDY SEENDY SESEQ;
run;
proc sql;
    create table SE_dm as 
    select a.*,
            case when ^missing(b.subject) then scan(b.SVSTDTC,1,'T') 
                 else c.DSSTDTC end as SEENDTC length=19, b.SVSTDTC, c.DSSTDTC
    from SE_dm_ as a 
        left join qtrans.sv(where=(VISITNUM=201001)) as b 
            on a.subject=b.subject
        left join DS_GL_900 as c 
            on a.subject=c.subject;
quit;

/* EX */
%macro ex(i=,ETCD=,ELEMENT=,where=);
proc sql;
    create table EX as 
    select *
    from raw_ex(where=(&where))
    group by subject
    having folderseq=min(folderseq);
quit;
proc sql;
    create table SE_ex_&i as 
    select distinct a.*, b.SVSTDTC as SVSTDTC_end, c.DSSTDTC as DSSTDTC,d.SVSTDTC as SVSTDTC_follow,e.SVSTDTC, f.RFXENDTC
    from EX(drop=EXSTDTC EXAMONT_ADA) as a 
        left join qtrans.sv(where=(VISITNUM=300000)) as b /* End of Treatment */
            on a.subject=b.subject
        left join DS_GL_900 as c  /* Trial Disposition */
            on a.subject=c.subject
        left join (select * from qtrans.sv(where=(VISITNUM in (401001,402001))) group by subject having VISITNUM=min(VISITNUM)) as d 
            on a.subject=d.subject /* Follow up visit */
        left join qtrans.sv(where=(VISITNUM=201001)) as e
            on a.subject=e.subject
        left join qtrans.dm as f 
            on a.subject=f.subjid; 
quit;
data SE_ex&i;
    set SE_ex_&i;
    where ^missing(SVSTDTC);
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    ETCD    ="&ETCD";
    ELEMENT = "&ELEMENT";
    SESTDTC = SVSTDTC;
    SEENDTC = scan(coalescec(SVSTDTC_end,RFXENDTC),1,'T');
    TAETORD =2;
    epoch   ='TREATMENT';
    call missing(of SESTDY SEENDY SESEQ);
    drop SESTDY SEENDY SESEQ;
run;
%mend;
%ex(i=1,ETCD   =VELIV,
        ELEMENT=VELCADE IV TREATMENT,
        where  =%str(upcase(EXCAT)='VELCADE IV'));
%ex(i=2,ETCD   =VELSC,
        ELEMENT=VELCADE SC TREATMENT,
        where  =%str(upcase(EXCAT)='VELCADE SC'));

/* SV */
proc sql;
    create table SE_follow1_ as 
    select a.subject,a.STUDYID,coalescec(a.SVSTDTC,d.RFXENDTC) as SVSTDTC length=19,
          case when ^missing(b.subject) then b.CESTDTC
                else c.DSSTDTC end as SEENDTC length=19
            ,c.DSSTDTC
    from qtrans.sv(where=(VISITNUM=300000)) as a 
        left join CE_ONC_003 as b
            on a.subject=b.subject 
        left join DS_GL_900 as c 
            on a.subject=c.subject
        left join qtrans.dm as d 
            on a.subject=d.subjid;

    create table SE_follow2_ as 
    select a.PROJECT as STUDYID length=40,a.subject, a.CESTDTC as SVSTDTC length=19, c.DSSTDTC as SEENDTC length=19 ,c.DSSTDTC
    from CE_ONC_003 as a 
        left join (select subject, SVSTDTC from qtrans.sv(where=(VISITNUM=402001))) as b
            on a.subject=b.subject 
        left join DS_GL_900 as c 
            on a.subject=c.subject;
quit;

%macro SV(i=,ETCD=,ELEMENT=,EPOCH=,TAETORD=,VISITNUM=);
data SE_follow&i.;
    set SE_follow&i._;
    attrib &&&domain._varatt_;
    STUDYID =STUDYID;
    DOMAIN  ="&domain";
    USUBJID =catx("-",STUDYID,SUBJECT);
    ETCD    ="&ETCD";
    ELEMENT = "&ELEMENT";
    SESTDTC = SVSTDTC;
    TAETORD =&TAETORD;
    EPOCH   ="&EPOCH";
    call missing(of  SESTDY SEENDY SESEQ);
    drop  SESTDY SEENDY SESEQ;
run;  
%mend;
%SV(i=1, ETCD    =FU1
        ,ELEMENT =PRE-PD FOLLOW-UP
        ,EPOCH   =FOLLOW-UP
        ,TAETORD =3
        ,VISITNUM=401001);
%SV(i=2, ETCD    =FU2
        ,ELEMENT =POST-PD FOLLOW-UP
        ,EPOCH   =FOLLOW-UP
        ,TAETORD =4
        ,VISITNUM=402001);

/* Join all */
data SE_2;
    set SE_dm SE_ex1 SE_ex2 SE_follow1 SE_follow2;
run;
*------------------- SESTDY & SEENDY --------------------;
%jjqccomdy(in_data=SE_2,out_data=SE_3, in_var=SESTDTC, out_var=SESTDY);
%jjqccomdy(in_data=SE_3,out_data=SE_4, in_var=SEENDTC, out_var=SEENDY);

*------------------- SESEQ --------------------;
%jjqcseq(in_data=SE_4, out_data=SE_5, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
proc sort data =SE_5 out =&domain(Label = "&&&domain._dlabel_" keep = &&&domain._varlst_);
    by &&&domain._keyvar_;
run;

data qtrans.&domain(Label = "&&&domain._dlabel_" &keep_sub);
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
