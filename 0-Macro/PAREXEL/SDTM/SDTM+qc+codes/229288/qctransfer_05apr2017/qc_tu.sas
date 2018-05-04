/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         27Jun2016 / $LastChangedDate: 2016-08-25 05:09:30 -0400 (Thu, 25 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_tu.sas $

  Files Created:         qc_TU.log
                         TU.sas7bdat

  Program Purpose:       To QC Tumor Identification

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 28 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=TU;
%jjqcvaratt(domain=TU);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
proc sql;
    create table TR_MMY_001 as /* Flag unique log line */
    select * ,case when RECORDPOSITION=min(RECORDPOSITION) then 1 else . end as unique_flag 
    from  raw.TR_MMY_001(where=(&raw_sub) drop=&dropvar TRLOC TRLOC_STD)
    group by SITENUMBER,SUBJECT,INSTANCENAME,DATAPAGENAME;
quit;

proc sql;
    create table TR_ONC_004_1 as /* Flag unique log line */
    select * ,case when RECORDPOSITION=min(RECORDPOSITION) then 1 else . end as unique_flag 
    from  raw.TR_ONC_004_1(where=(&raw_sub) drop=&dropvar TRLOC TRLOC_STD)
    group by SITENUMBER,SUBJECT,INSTANCENAME,DATAPAGENAME;
quit;

proc sql;
    create table TR_ONC_001 as /* Flag unique log line */
    select * ,case when RECORDPOSITION=min(RECORDPOSITION) then 1 else . end as unique_flag 
    from  raw.TR_ONC_001(where=(&raw_sub)  rename=(TULNKID=TULNKID_ TUCAT=TUCAT_)
                         keep=site sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername
                              TUCAT TUMIDENT TUMIDENT_STD TULOC_STD TULNKID TULOCO TUSUBLOC TUPATHPF TUPATHPF_STD) 
    group by SITENUMBER,SUBJECT,INSTANCENAME,DATAPAGENAME;
quit;

*------------------- Mapping --------------------;
/* Form: Baseline Lytic Bone Lesion Assessment */
data TU_1a;
    set TR_MMY_001;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    TUSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    TUCAT   = 'LYTIC BONE LESIONS';
    TUEVAL  = 'INVESTIGATOR';
    if ^missing(TRSCAT) then do;
            TUTESTCD = 'TUMIDENT ';
            TUTEST   = put(TUTESTCD,$TU_TESTCD.);
            TUORRES  = strip(upcase( TRSCAT));
            TUSTRESC = TUORRES;
            %jjqcdate2iso(in_date =TRDAT, in_time=, out_date=TUDTC);
            Output;
    end;
    call missing(of TUSEQ TULOC TUMETHOD TULNKID  TUBLFL VISITNUM VISIT VISITDY EPOCH TUDY);
    drop TUSEQ TUBLFL TUMETHOD VISITNUM VISIT VISITDY EPOCH TUDY;
run;

/* Form: Lytic Bone Lesion Assessment */
data TU_1b;
    set TR_ONC_004_1;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    TUSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    TUCAT   = 'LYTIC BONE LESIONS';
    TUEVAL  = 'INVESTIGATOR';
    if ^missing(TRSCAT) then do;
            TUTESTCD = 'TUMIDENT ';
            TUTEST   = put(TUTESTCD,$TU_TESTCD.);
            TUORRES  = strip(upcase( TRSCAT));
            TUSTRESC = TUORRES;
            %jjqcdate2iso(in_date =TRDAT, in_time=, out_date=TUDTC);
            Output;
    end;
    call missing(of TUSEQ TULOC TUMETHOD TULNKID  TUBLFL VISITNUM VISIT VISITDY EPOCH TUDY);
    drop  TUSEQ TUBLFL TUMETHOD VISITNUM VISIT VISITDY EPOCH TUDY;
run;

/* Form: Extramedullary (Soft Tissue) Plasmacytomas Assessment */
data TU_1c;
    set TR_ONC_001;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    TUSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    TUCAT   = TUCAT_;
    TULNKID = put(TULNKID_,best. -l);
    TUEVAL  = 'INVESTIGATOR';
    if unique_flag=1 and ^missing(TUMIDENT) then do;
        TUTESTCD = 'TUMIDENT';
        TUTEST   = put(TUTESTCD,$TU_TESTCD.);
        TUORRES  = TUMIDENT_STD;
        TUSTRESC = TUMIDENT_STD;
        TULOC    = TULOC_STD;
        Output;
    end;
    call missing(of TUDTC TUMETHOD TUSEQ TUBLFL VISITNUM VISIT VISITDY EPOCH TUDY);
    drop TUDTC TUSEQ TUBLFL VISITNUM VISIT VISITDY EPOCH TUDY;
run;

/* Join All */
data TU_2;
    set TU_1a TU_1b TU_1c(in=c);
    flag = c;
run;
*------------------- Visit --------------------;
proc sql;
    create table TU_3 as
        select a.*, b.VISITNUM, b.VISIT, b.VISITDY, UNSV ,
               case when flag = 1 then b.svstdtc
                    else a.TUDTC_ end as TUDTC length=19
        from TU_2(rename=TUDTC=TUDTC_ &where_raw_lab) a
        left join
        qtrans.sv b
        on a.usubjid=b.usubjid and a.sitenumber=b.sitenumber and a.foldername=b.foldername and a.instancename=b.instancename
        order by a.STUDYID, a.USUBJID;
quit;
*------------------- DY --------------------;
%jjqccomdy(in_data=TU_3,out_data=TU_4, in_var=TUDTC, out_var=TUDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=TU_4,out_data=TU_5, in_date=TUDTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=TU_5,out_data=TU_6,dtc=TUDTC);

*------------------- TUSEQ --------------------;
%jjqcseq(in_data=TU_6, out_data=TU_7, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =TU_7 );

*------------------- Compare --------------------;
%let gmpxlerr=0;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

***********************************SUPPTU*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPTU;
%jjqcvaratt(domain=SUPPTU);

*------------------- Mapping --------------------;
data SUPPTU_1;
    set TU_7;
    attrib &&&domain._varatt_;
    RDOMAIN  ="TU";
    IDVAR    ='TUSEQ';
    IDVARVAL =put(TUSEQ,best. -l);
    QEVAL    ='';    
    QORIG    ='CRF';
    if flag=1 and unique_flag=1 and ^missing(TULOCO ) then do;
        QNAM   ='TULOCO';
        QLABEL =put(QNAM,TU_QL.);
        QVAL   =compbl(strip(upcase(TULOCO)));
        Output;
    end;
    if flag=1 and unique_flag=1 and ^missing(TUSUBLOC) then do;
        QNAM   ='TUSUBLOC';
        QLABEL =put(QNAM,TU_QL.);
        QVAL   =compbl(strip(upcase(TUSUBLOC)));
        Output;
    end;
    if flag=1 and unique_flag=1 and ^missing(TUPATHPF) then do;
        QNAM   ='TUPATHPF';
        QLABEL =put(QNAM,TU_QL.);
        QVAL   =strip(upcase(TUPATHPF_STD));
        Output;
    end;    
run;

*------------------- Output --------------------;
%qcoutput(in_data =SUPPTU_1 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );