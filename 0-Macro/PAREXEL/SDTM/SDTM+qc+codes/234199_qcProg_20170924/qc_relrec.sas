/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Creation Date:         20Jun2017 / $LastChangedDate: 2017-07-26 03:22:19 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_relrec.sas $

  Files Created:         relrec.log
                         relrec.sas7bdat

  Program Purpose:       To Create Related Records

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 3 $
-----------------------------------------------------------------------------*/
/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

%jjqcdata_type ;

/*RELREC*/
%let domain=RELREC;
%jjqcvaratt(domain=RELREC, flag=1);

/*Deriving variables*/

/*** for derive records on the same form ***/
proc sql;
    
	create table RELREC_BEXZ as
        select a.STUDYID, "BE" as RDOMAIN, a.USUBJID, "BESEQ" as IDVAR length=8, strip(put(BESEQ,best.)) as IDVARVAL length=200,
        "XZ" as RDOMAIN_, "XZSEQ" as IDVAR_ length=8, strip(put(XZSEQ,best.)) as IDVARVAL_ length=200
        from qtrans.BE(WHERE=(not missing(becat))) as a inner join qtrans.xz(WHERE=(not missing(xzcat))) as b
    on a.USUBJID=b.USUBJID and a.BESPID=b.XZSPID and a.BECAT=b.XZCAT
    order by USUBJID, IDVAR, IDVARVAL;

	create table RELREC_CMFA1 as
        select a.STUDYID, "CM" as RDOMAIN, a.USUBJID, "CMSEQ" as IDVAR length=8, strip(put(CMSEQ,best.)) as IDVARVAL length=200,
        "FA" as RDOMAIN_, "FASEQ" as IDVAR_ length=8, strip(put(FASEQ,best.)) as IDVARVAL_ length=200
        from qtrans.CM as a inner join qtrans.FA as b
    on a.USUBJID=b.USUBJID and a.CMSPID=b.FASPID and a.CMTRT=b.FAOBJ
    order by USUBJID, IDVAR, IDVARVAL;

	create table RELREC_MHFA as
        select a.STUDYID, "MH" as RDOMAIN_, a.USUBJID, "MHSPID" as IDVAR_ length=8, strip(MHSPID) as IDVARVAL_ length=200,
        "FA" as RDOMAIN, "FASPID" as IDVAR length=8, strip(FASPID) as IDVARVAL length=200
        from qtrans.MH(where=(index(mhspid,'SCREENING FOR TUBERCULOSIS'))) as a inner join qtrans.FA as b
    on a.USUBJID=b.USUBJID and a.MHSPID=b.FASPID 
    order by USUBJID, IDVAR, IDVARVAL;
    
	create table RELREC_CMFA2 as
        select a.STUDYID, "CM" as RDOMAIN_, a.USUBJID, "CMSPID" as IDVAR_ length=8, strip(CMSPID) as IDVARVAL_ length=200,
        "FA" as RDOMAIN, "FASPID" as IDVAR length=8, strip(FASPID) as IDVARVAL length=200
        from qtrans.CM(where=(index(cmspid,'SCREENING FOR TUBERCULOSIS'))) as a inner join qtrans.FA as b
    on a.USUBJID=b.USUBJID and a.CMSPID=b.FASPID
    order by USUBJID, IDVAR, IDVARVAL;

    create table RELREC_SRFA as
        select a.STUDYID, "SR" as RDOMAIN_, a.USUBJID, "SRSPID" as IDVAR_ length=8, strip(SRSPID) as IDVARVAL_ length=200,
        "FA" as RDOMAIN, "FASPID" as IDVAR length=8, strip(FASPID) as IDVARVAL length=200
        from qtrans.SR(where=(index(srspid,'SCREENING FOR TUBERCULOSIS'))) as a inner join qtrans.FA as b
    on a.USUBJID=b.USUBJID and a.SRSPID=b.FASPID
    order by USUBJID, IDVAR, IDVARVAL;

	create table RELREC_MHSR as
        select a.STUDYID, "MH" as RDOMAIN, a.USUBJID, "MHSPID" as IDVAR length=8, strip(MHSPID) as IDVARVAL length=200,
        "SR" as RDOMAIN_, "SRSPID" as IDVAR_ length=8, strip(SRSPID) as IDVARVAL_ length=200
        from qtrans.MH(where=(index(mhspid,'SCREENING FOR TUBERCULOSIS'))) as a inner join qtrans.SR as b
    on a.USUBJID=b.USUBJID and a.MHSPID=b.SRSPID
    order by USUBJID, IDVAR, IDVARVAL;

	create table RELREC_MHCM as
        select a.STUDYID, "MH" as RDOMAIN, a.USUBJID, "MHSPID" as IDVAR length=8, strip(MHSPID) as IDVARVAL length=200,
        "CM" as RDOMAIN_, "CMSPID" as IDVAR_ length=8, strip(CMSPID) as IDVARVAL_ length=200
        from qtrans.MH(where=(index(mhspid,'SCREENING FOR TUBERCULOSIS'))) as a inner join qtrans.CM as b
    on a.USUBJID=b.USUBJID and a.MHSPID=b.CMSPID
    order by USUBJID, IDVAR, IDVARVAL;

	create table RELREC_SRCM as
        select a.STUDYID, "SR" as RDOMAIN, a.USUBJID, "SRSPID" as IDVAR length=8, strip(SRSPID) as IDVARVAL length=200,
        "CM" as RDOMAIN_, "CMSPID" as IDVAR_ length=8, strip(CMSPID) as IDVARVAL_ length=200
        from qtrans.SR(where=(index(srspid,'SCREENING FOR TUBERCULOSIS'))) as a inner join qtrans.CM as b
    on a.USUBJID=b.USUBJID and a.SRSPID=b.CMSPID
    order by USUBJID, IDVAR, IDVARVAL;
	
	create table RELREC_SRFA2 as
        select a.STUDYID, "SR" as RDOMAIN_, a.USUBJID, "SRSPID" as IDVAR_ length=8, strip(SRSPID) as IDVARVAL_ length=200,
        "FA" as RDOMAIN, "FASPID" as IDVAR length=8, strip(FASPID) as IDVARVAL length=200
        from qtrans.SR(where=(index(srspid,'TUBERCULOSIS TESTING'))) as a inner join qtrans.FA(where=(FATESTCD='TRTREQ')) as b
    on a.USUBJID=b.USUBJID and a.SRSPID=b.FASPID 
    order by USUBJID, IDVAR, IDVARVAL;

quit ;

/*** for derive records on the different forms, i.e. link to AE, MH ***/

%macro mrel(rawdata1=,rawdata2=,domain1=,domain2=,outdata=,invar=) ;

proc sort data=&rawdata1(where=(&raw_sub)) out=_wk1(keep=project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION &invar) ;
by project subject INSTANCENAME DATAPAGENAME RECORDPOSITION PAGEREPEATNUMBER; run ;

proc transpose data =_wk1 out = _wk2 prefix=rec ;
    var &invar ;
    by project subject INSTANCENAME DATAPAGENAME RECORDPOSITION PAGEREPEATNUMBER;
run ;

%let emp=1;

data _null_;
    set _wk2(where=(^ missing(SUBJECT)));
    if _n_=1 then call symputx('emp',0);
run;

%if &emp=0 %then %do;
    data _wk3 ;
        set _wk2(where=(not missing(rec1) and index(_name_,'_STD'))) ;
                rec=substr(rec1,1,4);
                rec2=compress(rec,,'kd');
                recordn=input(rec2,??best.);
                /*if not missing(compress(scan(rec1,1,' '),,'kd') then recordn=input((compress(scan(rec1,1,' '),,'kd'),best.);*/
        usubjid=catx("-", PROJECT, SUBJECT);
        &domain1.SPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),put(RECORDPOSITION,best.));

    run ;
%end;
%else %do;
    data _wk3 ;
        set _wk2;
        recordn=.;
        usubjid=catx("-", PROJECT, SUBJECT);
        &domain1.SPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),put(RECORDPOSITION,best.));

    run ;
%end;

data _temp1  ;
    set &rawdata2(where=(&raw_sub)) ;
    usubjid=catx("-", PROJECT, SUBJECT);
    &domain2.SPID=catx("-","RAVE",upcase(INSTANCENAME),upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.),put(RECORDPOSITION,best.));

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
        select a.STUDYID, "&domain1" as RDOMAIN , a.USUBJID, "&domain1.SEQ" as IDVAR length=8, strip(put(&domain1.SEQ,?best.)) as IDVARVAL length=200,
        b.&domain2.SPID, a.&domain1.SPID
        from qtrans.&domain1 %if &domain1=DD %then %do;(where=(DDTESTCD='PRCDTH')) %end; %if &rawdata1=raw.tbinfo_1 %then %do;(where=(FATESTCD='TRTREQ')) %end;
        as a inner join _wk4 as b
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
%mrel(rawdata1=raw.pr_gl_902,rawdata2=raw.mh_psa_001,domain1=PR,domain2=MH,outdata=RELREC_PRMH1,invar=%str(MHDSL:)) ;
%mrel(rawdata1=raw.fa_ra_007,rawdata2=raw.cm_gl_900,domain1=FA,domain2=CM,outdata=RELREC_FACM1,invar=%str(CMDSL:)) ;
%mrel(rawdata1=raw.tbinfo_1,rawdata2=raw.cm_gl_900,domain1=FA,domain2=CM,outdata=RELREC_FACM2,invar=%str(CMDSL:)) ;
%mrel(rawdata1=raw.ex5,rawdata2=raw.ae_gl_900,domain1=EX,domain2=AE,outdata=RELREC_EXAE1,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.ex4,rawdata2=raw.ae_gl_900,domain1=EX,domain2=AE,outdata=RELREC_EXAE2,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.cm_gl_900,rawdata2=raw.ae_gl_900,domain1=CM,domain2=AE,outdata=RELREC_CMAE1,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.ds_gl_900,rawdata2=raw.ae_gl_900,domain1=DS,domain2=AE,outdata=RELREC_DSAE1,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.ds_gl_903,rawdata2=raw.ae_gl_900,domain1=DS,domain2=AE,outdata=RELREC_DSAE2,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.ds_gl_908_w24,rawdata2=raw.ae_gl_900,domain1=DS,domain2=AE,outdata=RELREC_DSAE3,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.ds_gl_908_w48,rawdata2=raw.ae_gl_900,domain1=DS,domain2=AE,outdata=RELREC_DSAE4,invar=%str(AEDSL:)) ;
%mrel(rawdata1=raw.dd_gl_900,rawdata2=raw.ae_gl_900,domain1=DD,domain2=AE,outdata=RELREC_DDAE1,invar=%str(AEDSL:)) ;


data _relrec ;
    set RELREC_BEXZ RELREC_CMFA1  RELREC_MHFA RELREC_CMFA2 RELREC_SRFA RELREC_SRFA2 RELREC_PRMH1
                RELREC_FACM1 RELREC_FACM2(in=a) RELREC_EXAE1 RELREC_EXAE2 RELREC_CMAE1 RELREC_DSAE1 RELREC_DSAE2 RELREC_DSAE3
        RELREC_DSAE4 RELREC_DDAE1 RELREC_MHSR RELREC_MHCM RELREC_SRCM;
    
run;

proc sort nodupkey data=_relrec;
by USUBJID IDVAR IDVARVAL IDVAR_ IDVARVAL_  ;
run ;

data RELREC1;
    set _relrec;
    by USUBJID IDVAR IDVARVAL;
    if first.usubjid then RELID1 = 1;
    else if first.IDVARVAL then RELID1 + 1;
    flag=cats(rdomain,rdomain_);
   
run;

data &domain (keep = &&&domain._varlst_ label = &&&domain._dlabel_);
    attrib &&&domain._varatt_;
    set RELREC1 RELREC1(in=a);
    by USUBJID IDVAR IDVARVAL;
    RELID   = cats(flag,strip(put(RELID1,z3.)));
    RELTYPE = "";
    if a then do;
        RDOMAIN  = RDOMAIN_;
        IDVAR    = IDVAR_;
        IDVARVAL = IDVARVAL_;
    end;
run;

proc sort nodupkey data = &domain (&keep_sub keep = &&&domain._varlst_) out = qtrans.&domain; by &&&domain._keyvar_;run;

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
