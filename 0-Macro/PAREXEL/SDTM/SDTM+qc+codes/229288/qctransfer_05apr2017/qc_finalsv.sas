/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         22Aug2016 / $LastChangedDate: 2016-08-24 04:46:14 -0400 (Wed, 24 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_finalsv.sas $

  Files Created:         qc_finalsv.log
                         qc_sv.txt
                         sv.sas7bdat

  Program Purpose:       To QC Subject Visits Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 25 $
-----------------------------------------------------------------------------*/
/*clean work dataset*/
%jjqcclean;

%let domain=SV;

%jjqcvaratt(domain=SV, flag=1);
%jjqcdata_type;

/*EPOCH*/
%jjqcmepoch(in_data=qtrans.sv,out_data=sv, in_date=SVSTDTC);
/* Output */
data qtrans.&domain(Label = "&&&domain._dlabel_");
    retain &&&domain._varlst_;
    set sv;
    where ^missing(visit);
    keep &&&domain._varlst_;
    proc sort nodupkey;
    by &&&domain._varlst_;
run;

/*QC*/
%GmCompare( pathOut       = &_qtransfer.
          , dataMain      = transfer.&domain
          , checkVarOrder = 1
          , libraryQC     = qtrans
          );