/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         27Jun2016 / $LastChangedDate: 2017-03-03 03:13:27 -0500 (Fri, 03 Mar 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_tr.sas $

  Files Created:         qc_TR.log
                         TR.sas7bdat

  Program Purpose:       To QC Tumor Results Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 137 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=TR;
%jjqcvaratt(domain=TR);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier sitegroup instanceid 
             instancerepeatnumber folderid folder targetdays datapageid recorddate recordid 
             mincreated maxupdated savets ;
proc sql;
    create table TR_MMY_001 as /* Flag unique log line */
    select * ,case when RECORDPOSITION=min(RECORDPOSITION) then 1 else . end as unique_flag 
    from  raw.TR_MMY_001(where=(&raw_sub) drop=&dropvar TRCAT TRSCAT TRLOC TRMETHOD)
    group by SITENUMBER,SUBJECT,INSTANCENAME,DATAPAGENAME;
quit;

proc sql;
    create table TR_ONC_004_1 as /* Flag unique log line */
    select * ,case when RECORDPOSITION=min(RECORDPOSITION) then 1 else . end as unique_flag 
    from  raw.TR_ONC_004_1(where=(&raw_sub) drop=&dropvar TRCAT TRSCAT TRLOC TRMETHOD)
    group by SITENUMBER,SUBJECT,INSTANCENAME,DATAPAGENAME;
quit;

proc sql;
    create table TR_ONC_001 as /* Flag unique log line */
    select * ,case when RECORDPOSITION=min(RECORDPOSITION) then 1 else . end as unique_flag 
    from  raw.TR_ONC_001(where=(&raw_sub) rename =(TRSTAT=TRSTAT_ TRREASND=TRREASND_)
                         keep=site sitenumber project subject INSTANCENAME DATAPAGENAME PAGEREPEATNUMBER RECORDPOSITION foldername
                              TRSTAT TRREASND TRDAT_: TRMETHOD_STD DIAMETE1 DIAMETE1U DIAMETE2 DIAMETE2U TUMRMEAS 
                              TUCAT TULNKID TSTMEAS1 TSTMEAS2 TRREASNE)
    group by SITENUMBER,SUBJECT,INSTANCENAME,DATAPAGENAME;
quit;

*------------------- Mapping --------------------;
/* Form: Baseline Lytic Bone Lesion Assessment */
data TR_1a;
    set TR_MMY_001;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    TRSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    TRCAT   = 'LYTIC BONE LESIONS';
    TREVAL  = 'INVESTIGATOR';
    if unique_flag = 1 then do;
        if ^missing(LESNUM) then do;
            TRTESTCD = 'LESNUM';
            TRTEST   = put(TRTESTCD,$TR_TESTCD.);
            TRORRES  = compbl(LESNUM_STD);
            TRSTRESC = TRORRES;
            call missing(of TRSCAT TRSTRESN TRORRESU TRSTRESU TRSTAT TRREASND TRLOC TRMETHOD);
            Output;
        end;
        if ^missing(PRESOST) then do;
            TRTESTCD = 'PRESOST';
            TRTEST   = put(TRTESTCD,$TR_TESTCD.);
            TRORRES  = compbl(PRESOST_STD);
            TRSTRESC = TRORRES;
            call missing(of TRSCAT TRSTRESN TRORRESU TRSTRESU TRSTAT TRREASND TRLOC TRMETHOD);
            Output;
        end;
    end;
    if ^missing(OTHRADIM) then do;
            unique_flag=.;
            TRSCAT   = TRSCAT_STD;
            TRTESTCD = 'OTHRADIM ';
            TRTEST   = put(TRTESTCD,$TR_TESTCD.);
            TRORRES  = strip(compbl(upcase(OTHRADIM)));
            TRSTRESC = TRORRES;
            TRMETHOD = TRMETHOD_STD;
            %jjqcdate2iso(in_date =TRDAT, in_time=, out_date=TRDTC);
            call missing(of TRSTRESN TRORRESU TRSTRESU TRSTAT TRREASND TRLOC);
            Output;
    end;
    call missing(of TRSEQ TRLNKID TRORRESU TRBLFL VISITNUM VISIT VISITDY EPOCH TRDY);
    drop TRSEQ TRLNKID TRORRESU TRBLFL VISITNUM VISIT VISITDY EPOCH TRDY;
run;

/* Form:  Lytic Bone Lesion Assessment*/
data TR_1b;
    set TR_ONC_004_1;
    attrib &&&domain._varatt_;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    TRSPID  =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    TRCAT   = 'LYTIC BONE LESIONS';
    TREVAL  = 'INVESTIGATOR';
    if unique_flag = 1 then do;
        if ^missing(INCNUMB) then do;
            TRTESTCD = 'INCNUMB';
            TRTEST   = put(TRTESTCD,$TR_TESTCD.);
            TRORRES  = compbl(INCNUMB_STD);
            TRSTRESC = TRORRES;
            call missing(of TRSCAT TRSTRESN TRORRESU TRSTRESU TRSTAT TRREASND TRLOC);
            Output;
        end;
        if ^missing(INCSIZE) then do;
            TRTESTCD = 'INCSIZE';
            TRTEST   = put(TRTESTCD,$TR_TESTCD.);
            TRORRES  = compbl(INCSIZE_STD);
            TRSTRESC = TRORRES;
            call missing(of TRSCAT TRSTRESN TRORRESU TRSTRESU TRSTAT TRREASND TRLOC);
            Output;
        end;
    end;
    if ^missing(OTHRADIM) then do;
            unique_flag=.;
            TRSCAT   = TRSCAT_STD;
            TRTESTCD = 'OTHRADIM ';
            TRTEST   = put(TRTESTCD,$TR_TESTCD.);
            TRORRES  = strip(compbl(upcase(OTHRADIM)));
            TRSTRESC = TRORRES;
            TRMETHOD = TRMETHOD_STD;
            %jjqcdate2iso(in_date =TRDAT, in_time=, out_date=TRDTC);
            TRLOC    = TRLOC_STD;
            call missing(of TRSTRESN TRORRESU TRSTRESU TRSTAT TRREASND);
            Output;
    end;
    call missing(of TRSEQ TRLNKID TRORRESU TRBLFL VISITNUM VISIT VISITDY EPOCH TRDY);
    drop TRSEQ TRLNKID TRORRESU TRBLFL VISITNUM VISIT VISITDY EPOCH TRDY;
run;

/* Form: Extramedullary (Soft Tissue) Plasmacytomas Assessment */
data TR_1c;
    set TR_ONC_001;
    attrib &&&domain._varatt_;
    STUDYID     =strip(PROJECT);
    DOMAIN      ="&domain";
    USUBJID     =catx("-",PROJECT,SUBJECT);
    TRSPID      =catx("-", "RAVE", upcase(INSTANCENAME), upcase(DATAPAGENAME),put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    TRCAT       = TUCAT;
    TRLNKID     = put(TULNKID,best. -l);
    TREVAL      = 'INVESTIGATOR';
    unique_flag =.;
    if TRSTAT_ =1 then do;
        TRTESTCD ='TUMRMEAS';
        TRTEST   = put(TRTESTCD,$TR_TESTCD.);
        TRSTAT   ='NOT DONE';
        TRREASND =strip(compbl(upcase(TRREASND_)));
        call missing(of TRSCAT TRLOC TRORRES TRSTRESN TRORRESU TRSTRESU);
        Output;
    end;
    %jjqcdate2iso(in_date =TRDAT, in_time=, out_date=TRDTC);
    TRMETHOD = TRMETHOD_STD;
    if ^missing(DIAMETE1) or TSTMEAS1=1 then do;
        TRTESTCD = 'DIAMETE1';
        TRTEST   = put(TRTESTCD,$TR_TESTCD.);
        TRORRES  = ifc(TSTMEAS1=1,'TOO SMALL TO MEASURE',put(DIAMETE1,??best. -l));
        TRORRESU = ifc(TSTMEAS1=1,'',DIAMETE1U);
        TRSTRESC = TRORRES;
        TRSTRESU = TRORRESU;
        TRSTRESN = input(TRORRES,??best.);
        call missing(of TRSCAT TRSTATTRREASND TRSTAT TRREASND);
        Output;
    end;
    if ^missing(DIAMETE2) or TSTMEAS2=1 then do;
        TRTESTCD = 'DIAMETE2';
        TRTEST   = put(TRTESTCD,$TR_TESTCD.);
        TRORRES  = ifc(TSTMEAS2=1,'TOO SMALL TO MEASURE',put(DIAMETE2,??best. -l));
        TRORRESU = ifc(TSTMEAS2=1,'',DIAMETE2U);        
        TRSTRESC = TRORRES;
        TRSTRESN = input(TRORRES,??best.);
        TRSTRESU = TRORRESU;
        call missing(of TRSCAT TRSTATTRREASND TRSTAT TRREASND);
        Output;
    end;  
    if TUMRMEAS=1 then do;
        TRTESTCD = 'TUMRMEAS';
        TRTEST   = put(TRTESTCD,$TR_TESTCD.);
        TRSTAT   ='NOT DONE';
        TRREASND ='NOT EVALUABLE';
        call missing(of TRSCAT TRORRES TRSTRESN TRSTRESC TRORRESU TRSTRESU );
        Output;
    end;  
    call missing(of TRSEQ TRBLFL VISITNUM VISIT VISITDY EPOCH TRDY);
    drop TRSEQ TRBLFL VISITNUM VISIT VISITDY EPOCH TRDY;
run;

/* Join All */
data TR_2;
    set TR_1a(in=a) TR_1b(in=b drop=TRLOC_STD) TR_1c(in=c);
    flag = a+10*b+100*c;
    if TRMETHOD = 'X-RAY' then TRMETHOD='XRAY';
run;
*------------------- Visit --------------------;
proc sql;
    create table TR_3 as
        select a.*, b.VISITNUM, b.VISIT, b.VISITDY, UNSV ,
               case when unique_flag = 1 then b.svstdtc
                    else a.TRDTC_ end as TRDTC length=19
        from TR_2(rename=TRDTC=TRDTC_ &where_raw_lab) a
        left join
        qtrans.sv b
        on a.usubjid=b.usubjid and a.sitenumber=b.sitenumber and a.foldername=b.foldername and a.instancename=b.instancename
        order by a.STUDYID, a.USUBJID;
quit;
*------------------- DY --------------------;
%jjqccomdy(in_data=TR_3,out_data=TR_4, in_var=TRDTC, out_var=TRDY);

*------------------- Epoch --------------------;
%jjqcmepoch(in_data=TR_4,out_data=TR_5, in_date=TRDTC);

*------------------- BLFL --------------------;
%jjqcblfl(in_data=TR_5,out_data=TR_6,dtc=TRDTC);

*------------------- TRSEQ --------------------;
%jjqcseq(in_data=TR_6, out_data=TR_7, idvar_=USUBJID, retainvar_=STUDYID DOMAIN USUBJID);

*------------------- Output --------------------;
%qcoutput(in_data =TR_7 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );

***********************************SUPPTR*******************************************;
*------------------- Get meta data --------------------;
%let domain=SUPPTR;
%jjqcvaratt(domain=SUPPTR);

*------------------- Mapping --------------------;
data SUPPTR_1;
    set TR_7;
    attrib &&&domain._varatt_;
    RDOMAIN  ="TR";
    IDVAR    ='TRSEQ';
    IDVARVAL =put(TRSEQ,best. -l);
    QEVAL    ='';    
    QORIG    ='CRF';
    if ^missing(TRMETHDO) and TRTESTCD='OTHRADIM' then do;
        QNAM     ='TRMETHDO ';
        QLABEL   =put(QNAM,TR_QL.);
        QVAL=strip(upcase(TRMETHDO ));
        Output;
    end;
    if ^missing(TRLOCO) and TRTESTCD='OTHRADIM' then do;
        QNAM     = 'TRLOCO';
        QLABEL   =put(QNAM,TR_QL.);
        QVAL=strip(upcase(TRLOCO));
        Output;
    end;    
    if flag=100 and ^missing(TRREASNE) and TRTESTCD='TUMRMEAS' then do;
        QNAM     ='TRREASNE ';
        QLABEL   =put(QNAM,TR_QL.);
        QVAL=strip(upcase(TRREASNE ));
        Output;        
    end;
run;
%put &&&domain._varatt_;

*------------------- Output --------------------;
%qcoutput(in_data =SUPPTR_1 );

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );