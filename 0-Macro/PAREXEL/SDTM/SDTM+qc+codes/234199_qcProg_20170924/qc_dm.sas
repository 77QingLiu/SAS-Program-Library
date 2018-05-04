/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: < Janssen Research & Development, LLC > / <54767414MMY1006>
  PXL Study Code:        <228657>

  SAS Version:           <9.3>
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         25Jun2015 / $LastChangedDate: 2017-07-26 23:32:40 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_dm.sas $

  Files Created:        qc_dm.log
                         dm.sas7bdat
                         suppdm.sas7bdat

  Program Purpose:       To qcq 1. Demographics Dataset
                                   2. Supplemental Qualifiers for DM Dateset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 11 $
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
        where LIBNAME='QTRANS' and prxmatch('/(DTC)$/',cats(NAME)) and MEMNAME^='DM'
        ;
quit;

/*Datases loop*/
%macro dtloop(i=, in=, date=);
data temp&i;
    set qtrans.&in(keep=STUDYID USUBJID &date);
    _DATE_=&date;
    keep STUDYID USUBJID /*ASSDAT*/ _DATE_;
run;
%mend dtloop;

data _null_;
    set datetime;
    call execute('%nrstr(%dtloop(in='||cats(MEMNAME)|| ', i='||cats(_n_)||', date='||cats(NAME)||'))');
run;

data temp_all;
    set temp:;
    proc sort nodupkey;
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
        if a;
        informat studyid;
run;

/*Output dataset DM*/
data qtrans.&domain(label="&&&domain._dlabel_" &keep_sub);
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set dm;
    keep &&&domain._varlst_;
run;


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
