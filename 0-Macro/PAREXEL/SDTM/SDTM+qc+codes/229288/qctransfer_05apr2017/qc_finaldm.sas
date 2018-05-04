/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: JANSEEN RESEARCH and DEVELOPMENT / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: wangfu $
  Creation Date:         27Jun2016 / $ $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_finaldm.sas $

  Files Created:         dm.log
                         dm.sas7bdat
                         suppdm.sas7bdat

  Program Purpose:       To Create 1. Demographics Dataset
                                   2. Supplemental Qualifiers for DM Dateset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 90 $
-----------------------------------------------------------------------------*/

/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

/*DM*/
%let domain=DM;
%jjqcvaratt(domain=&domain)
%jjqcdata_type;

/*Deriving variables*/
/*RFPENDTC*/
/*Datasets with Assessment Date*/
proc sql;
    create table datetime as
        select MEMNAME '', NAME
        from dictionary.columns
        where LIBNAME='TRANSFER' and prxmatch('/(DTC)$/',cats(NAME)) and MEMNAME^='DM' and NAME ne "_SV_SVSTDTC"
        ;
quit;

/*Datases loop*/
%macro dtloop(i=, in=, date=);
data temp&i;
    set qtrans.&in(keep=STUDYID USUBJID &date);
    _DATE_=&date;
    /*
    format ASSDAT datetime20. TIME time5.;
    if length(&date)>=10 then
    DATE=input(catx(':', put(input(scan(_DATE_, 1, 'T'), yymmdd10.), date9.), '00:00'), datetime20.);
    TIME_=scan(_DATE_, 2, 'T');
    if TIME_='' then TIME_='00:00';
    TIME=input(TIME_, time5.);
    ASSDAT=sum(DATE, TIME);
    */
    keep STUDYID USUBJID /*ASSDAT*/ _DATE_;
run;
%mend dtloop;

data _null_;
    set datetime;
    call execute('%nrstr(%dtloop(in='||cats(MEMNAME)|| ', i='||cats(_n_)||', date='||cats(NAME)||'))');
run;

data temp_all;
    set temp:;
    proc sort;
    by STUDYID USUBJID descending _DATE_;
run;

data dm_en;
    set temp_all;
    by STUDYID USUBJID descending _DATE_;
    if first.USUBJID;
    length RFPENDTC $19;
    RFPENDTC=_DATE_;
run;

/*Combine All*/
/*Remove Dup*/
%macro rdup(ind=);
proc sort data=&ind nodupkey;
    by STUDYID USUBJID;
run;
%mend rdup;

%rdup(ind=dm_en)

data dm;
    merge qtrans.dm(drop=RFPENDTC in=a) dm_en;
    by STUDYID USUBJID;
*if RFSTDTC='' then RFPENDTC='';
if a;
run;

/*Output dataset DM*/
data qtrans.&domain(label="&&&domain._dlabel_" &keep_sub);
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set dm;
    keep &&&domain._varlst_;
    format _all_;
    informat _all_;
run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut         =  &_qtransfer.
          , dataMain        =  transfer.dm
    /*    , VarsId          =  &&&domain._varid_;*/
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );
