/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3001
  PAREXEL Study Code:    234199

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Last Modified:     2017-09-07    $LastChangedDate: 2017-09-11 02:42:49 -0400 (Mon, 11 Sep 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/transfer/qc_zr.sas $

  Files Created:         zr.log
                         zr.sas7bdat

  Program Purpose:       To QC ZR Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 27 $
-----------------------------------------------------------------------------*/
%let gmpxlerr = 0;
/*Cleaning WORK library */
proc datasets nolist lib=work memtype=data kill;
run;

/*Do not use threaded processing*/
options NOTHREADS;

%let domain=ZR;
%jjqcvaratt(domain=&domain,flag=0)
%jjqcdata_type;



data ZR;
  attrib &&&domain._varatt_;
  call missing(of _all_);
run;

%jjqcseq(retainvar_=STUDYID DOMAIN USUBJID &domain.SEQ &&&domain._varlst_);

data qtrans.zr(Label = "&&&domain._dlabel_");
  set qtrans.zr;
  if usubjid ^='';
run;

%GMCOMPARE( pathOut         =  &_qtransfer
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          , allowWorkLibrary=  1
          , debug           =  0
          );



