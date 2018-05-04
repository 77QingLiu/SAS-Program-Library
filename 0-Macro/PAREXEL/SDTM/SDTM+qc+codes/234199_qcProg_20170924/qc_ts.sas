/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: wangfu $
  Last Modified:     2017-06-09    $LastChangedDate: 2017-07-20 03:52:22 -0400 (Thu, 20 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_ts.sas $

  Files Created:         ts.sas7bdat

  Program Purpose:       Produce and QC TS domain.

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

%jjqcgfname;

/*TA*/
%let domain=TS;

*** Derive attributes for variables from attr macro ***;
%jjqcvaratt(domain=&domain.);

%macro charvar();
informat _all_; format _all_;
array chars {*} _char_;
do i = 1 to dim(chars );
    chars (i)= translate(chars (i),repeat('',161),compress(collate(0),,'w')); 

    chars (i)=strip(compbl(chars(i)));
end;
drop i;
%mend charvar;

/*Deriving variables*/
proc import datafile = "&SPECPATH.&fname..xlsx"
    out = ta1 dbms = XLSX replace;
    getnames = yes;
    range="&domain.$B24:M88";
run;

data &domain;
    attrib &&&domain._varatt_;
    set ta1(rename=(tsgrpid=tsgrpid_ tsvcdver=tsvcdver_ tsval=tsval_ tsval1=tsval1_ tsseq=tsseq_));
    domain='TS';
    studyid='CNTO1959PSA3001';
    %charvar;
    tsgrpid=cats(tsgrpid_);
    tsvcdver=/* put(tsvcdver_,is8601da.) */tsvcdver_;
	tsseq=/* input(tsseq_,??Best.) */tsseq_;
/*        %gmModifySplit(var=tsval_ ,width=200)
         tsval=scan(tsval_,1,'~');
        tsval1=scan(tsval_,2,'~'); */
tsval=strip(tsval_);
length tsval1 $200;
label tsval1="Parameter Value 1";
tsval1=strip(tsval1_);
    if tsvcdver='.' then tsvcdver='';
run;

/*Sort*/
proc sort data=&domain;
    by &&&domain._keyvar_;
run;

/*Output dataset TS*/
data qtrans.&domain(label="&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain.;
    keep &&&domain._varlst_ tsval1;
run;



************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;

%GMCOMPARE( pathOut = &_qtransfer., dataMain = transfer.&domain,checkVarOrder =1,libraryQC = qtrans);
