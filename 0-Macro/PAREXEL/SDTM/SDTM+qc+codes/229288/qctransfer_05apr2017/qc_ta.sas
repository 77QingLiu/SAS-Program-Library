/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         27Oct2016 / $LastChangedDate: 2016-10-28 04:04:26 -0400 (Fri, 28 Oct 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_ta.sas $

  Files Created:         qc_ta.log
                         ta.sas7bdat

  Program Purpose:       To QC Trial Arms Dataset

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 50 $
-----------------------------------------------------------------------------*/
%jjqcclean;
*------------------- Get meta data --------------------;
%let domain=TA;
%jjqcvaratt(domain=TA);
%jjqcdata_type;

/*Get The Latest Spec. Name*/
%jjqcgfname;

/*Deriving variables*/
proc import datafile = "&SPECPATH.&fname..xlsx"
    out = ta1 dbms = XLSX replace;
    getnames = yes;
    range="&domain.$B22:K30";
run;

data &domain;
    set ta1/*(rename=(taetord=taetord_))*/;
    %charvar;
    *taetord=input(taetord_,best.);
run;

/*Sort*/
proc sort data=&domain;
    by &&&domain._keyvar_;
run;

/*Output dataset TA*/
data qtrans.&domain(label="&&&domain._dlabel_");
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &domain;
    ARM = compbl(ARM);
    keep &&&domain._varlst_;
run;

************************************************************
*  Compare Main domain and QC domain                       *
************************************************************;


%GmCompare( pathOut        =  &_qtransfer.
          , dataMain        =  transfer.&domain
          , checkVarOrder   =  1
          , libraryQC       =  qtrans
          );
