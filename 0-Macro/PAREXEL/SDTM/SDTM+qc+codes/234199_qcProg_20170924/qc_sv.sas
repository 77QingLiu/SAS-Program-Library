/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Last Modified:     2017-06-07    $LastChangedDate: 2017-07-26 23:32:40 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_sv.sas $

  Files Created:         qc_sv.log
                         sv.sas7bdat

  Program Purpose:       To qc Subject Visits Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 11 $
-----------------------------------------------------------------------------*/

/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

%let domain=SV;
%jjqcvaratt(domain=&domain,flag=1)

data qtrans.&domain;
    set qtrans.&domain;
    *if not missing(visit_rave) and flags^='S' then delete;
    *if (not missing(rave_flag) and flags^='S' and folder1^='UNS') or not missing(dup) then delete;
    if visit='SCREENING' and missing(subject)  and folder^='SCRN' then delete;
run;

data qtrans.&domain(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    set qtrans.&domain;
    keep &&&domain._varlst_;
    format domain;
    informat domain;
run;

proc sort nodupkey data=qtrans.sv;by _all_;run;

%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );
