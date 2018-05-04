/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3001
  PAREXEL Study Code:    234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Creation Date:         12Jun2017 / $LastChangedDate: 2017-09-11 02:42:25 -0400 (Mon, 11 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_pc.sas $

  Files Created:         pc.sas7bdat
                         qc_pc.txt

  Program Purpose:       Produce and QC PC domain
  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 26 $
-----------------------------------------------------------------------------*/

/*Cleaning WORK library */
%jjqcclean;

/*Do not use threaded processing*/
options NOTHREADS;

%jjqcdata_type ;

/*TR*/
%let domain=PC;
%jjqcvaratt(domain=PC, flag=1);


data pc_01 ;
    set raw.pc_gl_901(drop = studyid  where=(&raw_sub));

    attrib &&&domain._varatt_;

    pcrefid='';
    pcrftdtc='';

    STUDYID=strip(PROJECT);
    DOMAIN   = "&domain";
    USUBJID=catx("-",PROJECT,SUBJECT);
    PCSPID=catx('-', 'RAVE', upcase(INSTANCENAME), upcase(DATAPAGENAME), put(PAGEREPEATNUMBER,best.), put(RECORDPOSITION,best.));
    if PCYN_STD='N' then do ; PCTESTCD='PCALL' ; PCTEST=put(pctestcd,$pc_testcd.); end;
        if PCYN_STD='Y' then do ; PCTESTCD='PCST' ; PCTEST=put(pctestcd,$pc_testcd.); end;
    PCCAT='PK SAMPLING TRACKING' ;
    PCORRES='' ;
    PCORRESU='' ;
    PCSTRESC='' ;
    PCSTRESN=. ;
    PCSTRESU='' ;
    if PCYN_STD='N' then do ;
      PCSTAT='NOT DONE' ;
      PCREASND='SAMPLE NOT COLLECTED' ;
    end ;
        if PCYN_STD='Y' then do ;
      PCSTAT='' ;
      PCREASND='' ;
    end ;
    PCNAM='' ;
    PCSPEC='' ;
    PCBLFL='' ;
    PCMETHOD='' ;
    PCLLOQ=. ;
    VISITNUM=. ;
    VISIT='' ;
    visitdy=.;
    EPOCH='' ;
    %jjqcdate2iso(in_date=PCDAT, in_time=, out_date=PCDTC);
    PCDY=. ;
    pcseq=.;



    drop pcseq visit visitnum visitdy pcblfl ;
run ;


/*Visit Information*/
proc sql;
    create table pc as
        select a.*
         ,b.visitnum
         ,b.visit
         ,b.visitdy

        from pc_01 as a
        left join
        qtrans.sv as b
        on a.usubjid=b.usubjid and a.sitenumber=b.sitenumber and a.folder=b.folder and a.instancename=b.instancename
        order by a.STUDYID, a.USUBJID;
quit;

/*data st;
    set rawlab.samptrac(rename=(usubjid=usubjid_ visit=visit_raw));
    attrib &&&domain._varatt_;
    domain='PC';
    if not missing(shipdate);
    if sttest='PHARM SERUM';
    pcmethod=sttest;
    usubjid=usubjid_;
    pcrefid=strefida;
    pcspid='CONTTRAC-'||strip(visit_raw);
    pctestcd='DARA';
    pctest=put(pctestcd,$&domain._TESTCD.);
    pccat='ANALYTE';
    call missing(pcorres,pcstresc,pcstat,pcreasnd,pcmethod,PCTPTREF,PCRFTDTC);
    pcstat=ststat;
    pcstresn=.;
    pclloq=.;
    pcorresu='ug/mL';
    pcstresu='ug/mL';
    pcnam='Janssen BDS';
    pcspec=STSPEC;
    pcdtc=stdtc;
    pctpt=sttpt;
    if sttpt='PREDOSE' then pctptnum=-0.001;
    if sttpt='POSTDOSE' then pctptnum=0.001;
    visitnum=.;
    visit='';
    visitdy=.;
    pcdy=.;
    pcblfl='';
    epoch='';
    informat domain studyid;
    drop visitnum visit visitdy pcdy pcblfl epoch;
    if visit_raw='POST-DARA WEEK 8' then visit_raw='POST DARA WEEK 8';
run;

data sv;
    set qtrans.sv;
    keep visitnum visit visitdy;
run;
proc sort nodupkey data=sv;by _all_;run;

proc sql;
    create table st_sv as
    select distinct a.*,b.visitnum,b.visit,b.visitdy
    from st as a left join sv as b
    on a.visit_raw=b.visit;
quit;

data st_sv;
    set st_sv;
    svstdtc=scan(pcdtc,1,'T');
run;

proc sort data=qtrans.sv(where=(index(visit,'REACTION')))
OUT=SV(KEEP=USUBJID SVSTDTC VISITNUM VISIT);BY USUBJID SVSTDTC;RUN;

PROC SORT DATA=ST_SV;BY USUBJID SVSTDTC;RUN;

DATA ST_SV;
    merge st_sv(in=a) sv(rename=(visit=visit_ visitnum=visitnum_));
    by usubjid svstdtc;
    if a;
run;

data pc;
    set st_sv;
    if visit_raw='INFUSION REACTION' then do;
      visit=visit_;
      visitnum=visitnum_;
    end;
    drop visit_ visitnum_;
run;

proc sort data=qtrans.sv(where=(domain2='PC' and not index(visit,'REACTION')))
 out=sv2(KEEP=USUBJID SVSTDTC VISITNUM VISIT visitdy rave_flag);BY USUBJID SVSTDTC;RUN;

proc sql;
     create table all as
     select a.*,b.visit as visit_s,b.visitdy as visitdys,b.visitnum as visitnums,b.rave_flag
     from pc as a left join sv2 as b
     on a.usubjid=b.usubjid and a.svstdtc=b.svstdtc;
quit;

data all;
     set all;
     if index(visit_raw,'UNS') then do;
       visit=visit_s;
       visitdy=visitdys;
       visitnum=visitnums;
     end;
     drop visit_s visitdys visitnums;
run;

data ex;
    set qtrans.ex;
    if extrt='DARATUMUMAB' and exdose^=0;
    keep usubjid visit extrt exstdtc exendtc exdose;
run;

proc sort data=pc_rave;by usubjid visit;run;
proc sort data=all;by usubjid visit;run;
proc sort data=ex;by usubjid visit;run;

data pc;
    merge all(in=a) ex;
    by usubjid visit;
    if a;
    if pctpt='PREDOSE' then do;
    pcrftdtc=exstdtc;
    pctptref=catx(', ','START OF INFUSION');
    end;
    if pctpt='POSTDOSE' then do;
    pcrftdtc=exendtc;
    pctptref=catx(', ','END OF INFUSION');
    end;
run;

data pc;
    set pc_rave pc(in=a);
    if not missing(rave_flag) then pcspid=strip(pcspid)||'-UNSCHED';
    if pcstat='NOT DONE' then call missing(pcorresu,pcstresu);
    if a then aa='test';
    format _all_;
    informat _all_;
    drop pcblfl;
run;*/

/*need resort the datasets to give the right seq*/
%macro check;
%if %sysfunc(fileexist("/project39/janss234200/stats/tabulate/data/rawrand/pc.sas7bdat"))=1 %then %do;

data edtpc;
        set rawrand.pc;
        if index(pcspid,'RAVE') then delete;
        drop pcblfl pcseq;
run;

proc sql;
    alter table edtpc
        modify pccat char(65), pcorresu char(25), pcstresu char(25),
                pcnam char(80), pcmethod char(30), pcspec char(60);
quit;

data new;
        set pc(where=(missing(aa))) edtpc;
run;

data pc;
        set new;
run;
%end;
%mend;

%check;

*---Derived PCDY,EPOCH;
*---Calculate PCDY;
%jjqccomdy(in_data=PC, in_var=PCDTC, out_var=PCDY);

*---Add epoch;
%jjqcmepoch(in_data=PC, in_date=PCDTC);

/*baseline flag*/
%jjqcblfl(sortvar=%str(STUDYID, USUBJID, PCTESTCD, PCCAT, PCSPEC, PCDTC, PCORRES))

proc sort data=pc;by &&&domain._keyvar_ pcspid;run;

/*proc sort data=pc;by usubjid pctestcd pcspec visitnum pctptnum pcrefid;run;*/

*---Add seqnum;
%jjqcseq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

proc sort data =qtrans.&domain (&keep_sub keep = &&&domain._varlst_ &domain.SEQ); by &&&domain._keyvar_; run;


************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut = &_qtransfer, dataMain = transfer.&domain, libraryQC = qtrans);

************************************************************
*  SUPP domain                                             *
************************************************************;


data supp&domain._raw; set transfer.pc; if usubjid="" then delete;run;

%let domain=SUPP&domain.;
%let rdomain=%substr(&domain.,5,2);
***To create attributes for SDTM datasets;
%jjqcvaratt(domain=&domain);
%jjqcdata_type;

data &domain._pre;
    attrib &&&domain._varatt_;
    /*set &domain._raw;
    RDOMAIN="&rdomain.";
    IDVAR="&rdomain.SEQ";
    IDVARVAL=strip(put(&rdomain.SEQ,best.));
    QORIG="EDT";
    QEVAL="";
    QNAM="";
    QVAL="";
    QLABEL=put(QNAM,$PC_QL.);
    call missing(QLABEL);
    drop QLABEL;
 */

     call missing(of _all_);

run;

proc sort data=&domain._pre nodupkey;
    by &&&domain._keyvar_ QVAL;
run;

************************************************************
*  FOR OUTPUTING SUPP DATASET AND COMPARATION.
************************************************************;
data &domain(Label = "&&&domain._dlabel_") qtrans.&domain.(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain._pre;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
    if usubjid="" then delete;
    call missing(of _all_);
run;

data main_&domain.; set transfer.&domain.; run;
%let gmpxlerr=0;
%gmcompare( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.&domain.
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          )
