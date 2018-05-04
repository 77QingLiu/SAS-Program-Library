/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         27Jun2016 / $LastChangedDate: 2017-03-03 02:21:22 -0500 (Fri, 03 Mar 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_presv.sas $

  Files Created:         qc_presv.log
                         sv.sas7bdat

  Program Purpose:       To QC Subject Visits Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 136 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=SV;
%jjqcvaratt(domain=SV);
%jjqcdata_type;

*------------------- Read raw data --------------------;
%let dropvar=projectid studyid environmentname subjectid studysiteid sdvtier site sitegroup instanceid 
             instancerepeatnumber folderid targetdays datapageid pagerepeatnumber recorddate recordid 
             mincreated maxupdated savets coder_hierarchy ;
data SV_GL_900;
    set raw.SV_GL_900(where=(&raw_sub));
    %jjqcdate2iso(in_date=VISDAT,out_date=SVDTC);
    if ^missing(SVDTC);
    keep SITENUMBER subject PROJECT SVDTC FOLDERNAME INSTANCENAME folderseq; 
run;
proc sort;by subject SVDTC;run;

data EX_ONC_001B_2;
    set raw.EX_ONC_001B_2(where=(&raw_sub));
    %jjqcdate2iso(in_date=EXSTDAT,out_date=EXDTC);
    drop &dropvar;
    keep SITENUMBER subject PROJECT EXDTC FOLDERNAME INSTANCENAME folderseq; 
run;

*------------------- Mapping --------------------;
/* SV Cycle visit */
data sv_1a;
    attrib &&&domain._varatt_;
    set SV_GL_900(in=a);
    by subject SVDTC;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    SVSTDTC =SVDTC;
    SVENDTC =SVDTC;
    if first.subject then NUM=0;
    if FOLDERNAME = 'Screening' then do;
        VISIT    = 'SCREENING';
        VISITNUM = 100000;
        VISITDY  = .;  
    end; 
    else if FOLDERNAME='End of Treatment' then do;
        VISIT    = 'END OF TREATMENT';
        VISITNUM = 300000;
        VISITDY  = .;  
    end;   
    else if FOLDERNAME='Disease Evaluation' then do;
        NUM + 1;
        VISIT    = 'DISEASE EVALUATION '||put(NUM,best. -l);
        VISITNUM = 500000 +NUM;
        VISITDY  = .;  
    end;          
    else if find(FOLDERNAME,'CYCLE','i') then do;
        CYCLE    = input(substr(FOLDERNAME,7,2),best.);
        DAY      = input(substr(FOLDERNAME,14,2),best.);
        VISIT    = upcase(prxchange('s/0(\d)/$1/io',1,FOLDERNAME));
        VISITNUM = 200000+CYCLE*1000+DAY;
        VISITDY  = (CYCLE-1)*28+ifn(missing(DAY),1,DAY);
    end;
    call missing(of SVSTDY SVENDY EPOCH);
    drop SVSTDY SVENDY NUM;
run;

/* EX Cycle visit */
proc sql;
    create table ex_1 as 
    select a.*, b.EXDTC_max
    from (select distinct *,EXDTC as EXDTC_min from EX_ONC_001B_2 group by subject,FOLDERNAME having EXDTC=min(EXDTC)) as a 
         left join 
         (select distinct *,EXDTC as EXDTC_max from EX_ONC_001B_2 group by subject,FOLDERNAME having EXDTC=max(EXDTC)) as b 
         on a.subject=b.subject and a.FOLDERNAME=b.FOLDERNAME;
quit;
data sv_1b;
    attrib &&&domain._varatt_;
    set ex_1;
    STUDYID =strip(PROJECT);
    DOMAIN  ="&domain";
    USUBJID =catx("-",PROJECT,SUBJECT);
    SVSTDTC =EXDTC_min;
    SVENDTC =EXDTC_max;
    if find(FOLDERNAME,'CYCLE','i') then do;
        CYCLE    = input(substr(FOLDERNAME,7,2),best.);
        VISIT    = 'CYCLE '||strip(put(CYCLE,best. -l))||" PERIOD";
        VISITNUM = 200000+CYCLE*1000+99;
        VISITDY  = .;
    end;
    if ^missing(SVSTDTC);
    call missing(of SVSTDY SVENDY EPOCH);
    drop SVSTDY SVENDY ;
run;


/* follow up and unscheduled visit */
proc sort data=sv_1a;by subject folderseq SVSTDTC FOLDERNAME ;run;

data sv_1c;
    set sv_1a;
    by subject folderseq SVSTDTC FOLDERNAME ;
    /* Follow up */
    length visit_follow $40;
    retain visit_follow visitdy_follow visitdy_until;
    if first.subject then call missing(of num_until num_after visit_follow visitdy_follow visitdy_until);
    if find(VISIT,'cycle','i') then visitdy_follow=visitdy;
    if FOLDERNAME='Follow Up Until PD' then do;
        num_until+1;
        VISIT    ='FOLLOW UP UNTIL PD '||put(num_until,best. -l);
        VISITNUM = 800000+num_until;
        if missing(visitdy_until) then visitdy_until =  visitdy_follow;
        if visitdy_until <= 158 then  VISITDY  = visitdy_follow+21*num_until; /* if subject discontinue before complete(cycle9)*/
        else VISITDY = visitdy_follow+56*num_until; /* if subject complete */
        visitdy_until = VISITDY;        
    end;
    if FOLDERNAME='Follow Up After PD' then do;
        num_after+1;
        VISIT    ='FOLLOW UP AFTER PD '||put(num_after,best. -l);
        VISITNUM = 900000+num_after;     
        VISITDY  = visitdy_follow+84*num_after;   
    end;
    if FOLDERNAME='End of Treatment' then do;
        VISITDY  = visitdy_follow+30;   
    end;
    run;

proc sort data=sv_1c out=sv_1d;by SUBJECT SVSTDTC;run;
data sv_1d;set sv_1d;by SUBJECT SVSTDTC;    
    /* Unscheduled */
    length VISIT_sch $40 SVSTDTC_sch $19;
    retain VISIT_sch  VISITNUM_sch SVSTDTC_sch VISITDY_sch ;
    if first.subject then call missing(of VISIT_sch VISITNUM_sch SVSTDTC_sch VISITDY_sch num_unsch);
    if ^missing(VISIT) and FOLDERNAME ne "Disease Evaluation" then do;
        VISIT_sch    = VISIT;
        VISITNUM_sch = VISITNUM;
        num_unsch    = .;
        SVSTDTC_sch  = SVSTDTC;
        VISITDY_sch  = VISITDY;
    end;
    if FOLDERNAME='Unschedule Visit' then do;
        if SVSTDTC = SVSTDTC_sch then do;
            UNSV = 1;
            VISIT=VISIT_sch;VISITNUM=VISITNUM_sch;VISITDY=VISITDY_sch;
        end;
        else do;
            num_unsch +1;
            VISIT    = strip(VISIT_sch)||' '||"UNSCHEDULED "||strip(put(num_unsch,z2.));
            VISITNUM = VISITNUM_sch+0.01*num_unsch;
        end;
    end;        
run;


/* Join all */
data sv_2;
    set sv_1b sv_1d;
run;

/*svstdy and svendy*/
%jjqccomdy(in_data=sv_2,out_data=sv_3, in_var=SVSTDTC, out_var=SVSTDY);
%jjqccomdy(in_data=sv_3,out_data=sv_4, in_var=SVENDTC, out_var=SVENDY);

*------------------- Output --------------------;
proc sort data =sv_4 out =&domain(Label = "&&&domain._dlabel_" keep = &&&domain._varlst_ SITENUMBER SUBJECT INSTANCENAME FOLDERNAME UNSV);
    by &&&domain._keyvar_ SVSTDTC INSTANCENAME;
run;

data qtrans.&domain(Label = "&&&domain._dlabel_" &keep_sub drop=EPOCH);
    retain &&&domain._varlst_ SITENUMBER SUBJECT INSTANCENAME FOLDERNAME UNSV;
    attrib &&&domain._varatt_;
    set &domain;
    format _all_;
    informat _all_;
run;

*------------------- Compare --------------------;
%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
