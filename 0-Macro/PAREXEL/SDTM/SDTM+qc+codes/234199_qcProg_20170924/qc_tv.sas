/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         FU WANG        $LastChangedBy: wangfu $
  Last Modified:     2017-07-17    $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_tv.sas $

  Files Created:         tv.sas7bdat

  Program Purpose:       Produce and QC TV domain.

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

/*TV*/
%let domain=TV;

*** Derive attributes for variables from attr macro ***;
%jjqcvaratt(domain=&domain.);

/*Deriving variables*/
proc import datafile = "&SPECPATH.&fname..xlsx"
    out = ta1 dbms = XLSX replace;
    getnames = yes;
    range="&domain.$B25:J76";
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

data &domain;
    attrib &&&domain._varatt_;
    set ta1(rename=( visitnum=visitnum_ visitdy=visitdy_));
    domain='TV';
    %charvar;
    studyid='CNTO1959PSA3001';
  visitdy=input(visitdy_,??best.);
	visitnum=input(visitnum_,??best.);
run;

/*Sort*/
proc sort data=&domain;
    by &&&domain._keyvar_;
run;

/*data sv;
    set qtrans.sv;
    if not index(visit,'UNS') and visit^='SCREENING' and not index(visit,'DISEASE');
    keep visit visitdy visitnum;
run;

proc sort nodupkey data=sv;by visit  visitdy visitnum;run;
proc sort data=tv;by visit visitdy visitnum;run;

data tv;
    merge tv sv;
    by visit visitdy visitnum;
    studyid='CNTO1959PSA3002';
    domain='TV';
    visitc=visit;
    if index(visitc,'CYCLE') and not index(visitc,'DAY') then visitc=strip(visitc)||' DAY 1';
    if index(visitc,'CYCLE') and missing(tvstrl) then tvstrl=strip(visitc)||" OF TREATMENT EPOCH";
    /*if index(visitc,'FOLLOW') then tvstrl="8 WEEKS AFTER LAST ADMINISTRATION";*/
    /*if index(visitc,'DISEASE') then tvstrl='EVERY 28 DAYS UNTIL DISEASE PROGRESSION';*/
/*run;

proc sort nodupkey data=tv;by _all_;run;

/*Output dataset TV*/
data qtrans.&domain(label="&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain.;
    keep &&&domain._varlst_;
run;



************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut = &_qtransfer., dataMain = transfer.&domain, libraryQC = qtrans);
