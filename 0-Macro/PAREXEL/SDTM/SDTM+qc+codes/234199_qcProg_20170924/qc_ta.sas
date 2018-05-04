/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Fu Wang        $LastChangedBy: wangfu $
  Last Modified:     2017-07-17    $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_ta.sas $

  Files Created:         ta.sas7bdat

  Program Purpose:       Produce and QC TA domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 1 $
-----------------------------------------------------------------------------*/

dm 'log' clear;
dm 'output' clear;


/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;
/*Get The Latest Spec. Name*/
%jjqcgfname;

/*TA*/
%let domain=TA;


*** Derive attributes for variables from attr macro ***;
%jjqcvaratt(domain=&domain.);

/*Deriving variables*/
proc import datafile = "&SPECPATH.&fname..xlsx"
    out = ta1 dbms = XLSX replace;
    getnames = yes;
    range="&domain.$B25:K35";
run;

data &domain;
    attrib &&&domain._varatt_;
    set ta1(rename=(taetord=taetord_));
    domain='TA';
	taetord=input(taetord_,??best.);
    studyid='CNTO1959PSA3001';
run;

/*Sort*/
proc sort data=&domain;
    by &&&domain._keyvar_;
run;

%macro charvar();
informat _all_; format _all_;
array chars {*} _char_;
do i = 1 to dim(chars );
    chars (i)=translate(chars (i),repeat('',161),compress(collate(0),,'w'));
    chars (i)=strip(compbl(chars(i)));
end;
drop i;
%mend charvar;

data &domain.;
    set &domain.;
    informat _all_;
    format _all_;
run;


/*Output dataset DM*/
data qtrans.&domain(label="&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain.;
    keep &&&domain._varlst_;
    %charvar;
run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut = &_qtransfer, dataMain = transfer.&domain, libraryQC = qtrans);
