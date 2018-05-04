/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development, LLC / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Pengfei Lu $LastChangedBy: liuc5 $
  Creation / modified:   08Jul2016 / $LastChangedDate: 2016-08-24 04:46:14 -0400 (Wed, 24 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_relrec.sas $

  Files Created:         qc_relrec.log
                         relrec.sas7bdat
                         /projects/janss229288/stats/transfer/data/qtransfer/relrec.sas7bdat

  Program Purpose:       To QC Related Records

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 25 $
-----------------------------------------------------------------------------*/
%jjqcclean;
options NOTHREADS;

*------------------- Get meta data --------------------;
%jjqcdata_type ;
%let domain=RELREC;
%jjqcvaratt(domain=RELREC, flag=1);

*------------------- Mapping --------------------;
/*** for derive records on the same form ***/

** Extramedullary (Soft Tissue) Plasmacytomas Assessment;
proc sql;
    create table RELREC_TUTR as
        select distinct a.STUDYID, "TU" as RDOMAIN, a.USUBJID, "TULNKID" as IDVAR length=8, cats(TULNKID) as IDVARVAL length=200,
        "TR" as RDOMAIN_, "TRLNKID" as IDVAR_ length=8, cats(TRLNKID) as IDVARVAL_ length=200
        from qtrans.TU as a inner join qtrans.TR as b
    on a.USUBJID=b.USUBJID and a.TULNKID=b.TRLNKID and ^missing(a.TULNKID)
    order by USUBJID, IDVAR, IDVARVAL
    ;
quit ;

** Prior Systemic Therapy & Subsequent Systemic Therapy;
proc sql;
    create table RELREC_CECM as
        select a.STUDYID, "CE" as RDOMAIN, a.USUBJID, "CESEQ" as IDVAR length=8, strip(put(CESEQ,?best.)) as IDVARVAL length=200,
        "CM" as RDOMAIN_, "CMSEQ" as IDVAR_ length=8, strip(put(CMSEQ,?best.)) as IDVARVAL_ length=200
        from qtrans.CM as b inner join qtrans.CE as a
    on a.USUBJID=b.USUBJID and b.CMSPID=a.CESPID
    order by USUBJID, IDVAR, IDVARVAL
    ;
    create table RELREC_PRCM as
        select a.STUDYID, "PR" as RDOMAIN, a.USUBJID, "PRSEQ" as IDVAR length=8, strip(put(PRSEQ,?best.)) as IDVARVAL length=200,
        "CM" as RDOMAIN_, "CMSEQ" as IDVAR_ length=8, strip(put(CMSEQ,?best.)) as IDVARVAL_ length=200
        from qtrans.CM as b inner join qtrans.PR as a
    on a.USUBJID=b.USUBJID and b.CMSPID=a.PRSPID
    order by USUBJID, IDVAR, IDVARVAL
    ;
    create table RELREC_FACM as
        select a.STUDYID, "FA" as RDOMAIN, a.USUBJID, "FASEQ" as IDVAR length=8, strip(put(FASEQ,?best.)) as IDVARVAL length=200,
        "CM" as RDOMAIN_, "CMSEQ" as IDVAR_ length=8, strip(put(CMSEQ,?best.)) as IDVARVAL_ length=200
        from qtrans.CM as b inner join qtrans.FA as a
    on a.USUBJID=b.USUBJID and b.CMSPID=a.FASPID
    order by USUBJID, IDVAR, IDVARVAL
    ;
quit ;

** Disease Progression;
proc sql;
    create table RELREC_CEFA as
        select a.STUDYID, "FA" as RDOMAIN, a.USUBJID, "FASEQ" as IDVAR length=8, strip(put(FASEQ,?best.)) as IDVARVAL length=200,
        "CE" as RDOMAIN_, "CESEQ" as IDVAR_ length=8, strip(put(CESEQ,?best.)) as IDVARVAL_ length=200
        from qtrans.FA as a inner join qtrans.CE as b
    on a.USUBJID=b.USUBJID and b.CESPID=a.FASPID and a.FACAT='DISEASE PROGRESSION' and b.CECAT='DISEASE PROGRESSION'
    order by USUBJID, IDVAR, IDVARVAL
    ;
quit ;

/*** for derive records on the different forms, i.e. link to AE, MH ***/
%macro mrel(rawdata1=,rawdata2=,domain1=,domain2=,outdata=,invar=) ;
proc sort data=&rawdata1 out=_wk1(keep=project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION &invar) ;
    by project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION;
run ;

proc transpose data =_wk1 out = _wk2 prefix=rec ;
    var &invar ;
    by project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION ;
run ;

%let emp=1;

data _null_;
    set _wk2(where=(^ missing(SUBJECT)));
    if _n_=1 then call symputx('emp',0);
run;

%if &emp=0 %then %do;
    data _wk3 ;
        set _wk2(where=(not missing(rec1) and index(_name_,'_STD'))) ;
        if not missing(compress(rec1,compress(rec1,'0123456789'))) then recordn=input(compress(scan(rec1,1),'#'),best.) ;
		length USUBJID $40 &domain1.SPID $200;
        usubjid=catx("-", PROJECT, SUBJECT);
        &domain1.SPID=upcase(catx("-","RAVE", INSTANCENAME, DATAPAGENAME, cats(PAGEREPEATNUMBER), cats(RECORDPOSITION)));
    run ;
%end;
%else %do;
    data _wk3 ;
        set _wk2;
        recordn=.;
 		length USUBJID $40 &domain1.SPID $200;
        usubjid=catx("-", PROJECT, SUBJECT);
        &domain1.SPID=upcase(catx("-","RAVE", INSTANCENAME, DATAPAGENAME, cats(PAGEREPEATNUMBER), cats(RECORDPOSITION)));
    run ;
%end;

data _temp1  ;
    set &rawdata2 ;
 	length USUBJID $40 &domain2.SPID $200;
    usubjid=catx("-", PROJECT, SUBJECT);
    &domain2.SPID=upcase(catx("-","RAVE", INSTANCENAME, DATAPAGENAME, cats(PAGEREPEATNUMBER), cats(RECORDPOSITION)));
run ;

proc sql ;
    create table _wk4 as
        select  a.USUBJID, a.&domain2.SPID,a.RECORDPOSITION, b.&domain1.SPID, b.recordn
        from _temp1 as a inner join _wk3 as b
        on a.USUBJID=b.USUBJID and a.RECORDPOSITION=b.recordn
        order by USUBJID;
quit ;

proc sql ;
    create table _wk5 as
        select a.STUDYID, "&domain1" as RDOMAIN, a.USUBJID, "&domain1.SEQ" as IDVAR length=8, strip(put(&domain1.SEQ,?best.)) as IDVARVAL length=200,
        b.&domain2.SPID, a.&domain1.SPID
        from qtrans.&domain1 as a inner join _wk4 as b
        on a.USUBJID=b.USUBJID and a.&domain1.SPID=b.&domain1.SPID
        order by USUBJID, IDVAR, IDVARVAL;
quit ;

proc sql ;
    create table &outdata as
        select a.STUDYID, "&domain2" as RDOMAIN_, a.USUBJID, "&domain2.SEQ" as IDVAR_ length=8, strip(put(&domain2.SEQ,?best.)) as IDVARVAL_ length=200,
        b.RDOMAIN, b.IDVAR, b.IDVARVAL
        from qtrans.&domain2 as a inner join _wk5 as b
        on a.USUBJID=b.USUBJID and a.&domain2.SPID=b.&domain2.SPID
        order by USUBJID, IDVAR, IDVARVAL;
quit ;

%mend ;
*CYCLE DELAY;
%mrel(rawdata1=raw.FA_ONC_002,rawdata2=raw.AE_GL_900,domain1=FA,domain2=AE,outdata=RELREC_FAAE1,invar=%str(AEDSL:)) ;
*Echocardiogram/MUGA Results;
%mrel(rawdata1=raw.MO_GL_902,rawdata2=raw.MH_GL_900,domain1=MO,domain2=MH,outdata=RELREC_MOMH,invar=%str(MHDSL:)) ;
%mrel(rawdata1=raw.MO_GL_902,rawdata2=raw.AE_GL_900,domain1=MO,domain2=AE,outdata=RELREC_MOAE,invar=%str(AEDSL:)) ;
*Dexamethasone Administration & Velcade Administration SC & Velcade Administration IV;
%mrel(rawdata1=raw.EX_ONC_001B_2,rawdata2=raw.AE_GL_900,domain1=EX,domain2=AE,outdata=RELREC_EXAE1,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.EX_ONC_001B,rawdata2=raw.AE_GL_900,domain1=EX,domain2=AE,outdata=RELREC_EXAE2,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.EX_ONC_001B_1,rawdata2=raw.AE_GL_900,domain1=EX,domain2=AE,outdata=RELREC_EXAE3,invar=%str(AEDSL:)) ;
*Procedures;
%mrel(rawdata1=raw.PR_GL_900,rawdata2=raw.AE_GL_900,domain1=PR,domain2=AE,outdata=RELREC_PRAE1,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.PR_GL_900,rawdata2=raw.MH_GL_900,domain1=PR,domain2=MH,outdata=RELREC_PRMH,invar=%str(MHDSL:)) ;
*Transfusions;
%mrel(rawdata1=raw.PR_GL_901,rawdata2=raw.AE_GL_900,domain1=PR,domain2=AE,outdata=RELREC_PRAE2,invar=%str(AEDSL:)) ;
*Concomitant Therapy;
%mrel(rawdata1=raw.CM_GL_900,rawdata2=raw.AE_GL_900,domain1=CM,domain2=AE,outdata=RELREC_CMAE1,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.CM_GL_900,rawdata2=raw.MH_GL_900,domain1=CM,domain2=MH,outdata=RELREC_CMMH1,invar=%str(MHDSL:)) ;
*Death Information;
%mrel(rawdata1=raw.DD_GL_900,rawdata2=raw.AE_GL_900,domain1=DD,domain2=AE,outdata=RELREC_DDAE1,invar=%str(AEDSL:)) ;
*Treatment Disposition & Trial Disposition;
%mrel(rawdata1=raw.DS_GL_908,rawdata2=raw.AE_GL_900,domain1=DS,domain2=AE,outdata=RELREC_DSAE1,invar=%str(AEDSL:)) ;
/* %mrel(rawdata1=raw.DS_GL_900,rawdata2=raw.AE_GL_900,domain1=DS,domain2=AE,outdata=RELREC_DSAE2,invar=%str(AEDSL:)) ;
 */ 
/* FW Updated on 20Mar2017 Due to migration */
data _relrec ;
    set RELREC:;
    /*if IDVARVAL only contained the numerical value, sort the numerical value instead of character value*/  
    if prxmatch('/^\d+$/', cats(IDVARVAL)) then IDVARVAL1=input(IDVARVAL, ??best.);
    if prxmatch('/^\d+$/', cats(IDVARVAL_)) then IDVARVAL2=input(IDVARVAL_, ??best.);
run;

proc sort;
    by USUBJID IDVAR IDVARVAL1 IDVARVAL IDVAR_ IDVARVAL2 IDVARVAL_ ;
run ;

data RELREC1;
    set _relrec;
    by USUBJID IDVAR IDVARVAL1 IDVARVAL IDVAR_ IDVARVAL2 IDVARVAL_ ;
    if first.USUBJID then RELID1 = 1;
    else if first.IDVARVAL then RELID1 + 1;
run;

data &domain;
    attrib &&&domain._varatt_;
    set RELREC1 RELREC1(in=a);
    by USUBJID IDVAR IDVARVAL1 IDVARVAL IDVAR_ IDVARVAL2 IDVARVAL_ ;
    RELID=cats(RDOMAIN, RDOMAIN_, put(RELID1, z3.));
    RELTYPE = "";
    if a then do;
        RDOMAIN  = RDOMAIN_;
        IDVAR    = IDVAR_;
        IDVARVAL = IDVARVAL_;
        IDVARVAL1= IDVARVAL2;
    end;
    proc sort nodupkey;
    by STUDYID RDOMAIN USUBJID IDVAR IDVARVAL RELID;

    proc sort;
    by STUDYID RDOMAIN USUBJID IDVAR IDVARVAL1 IDVARVAL RELID;
run;

%qcoutput(in_data =&domain);

/*QC*/
%let gmpxlerr=0;

%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
