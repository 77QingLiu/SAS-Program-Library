/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO1275SLE2001
  PXL Study Code:        221689

  SAS Version:           9.3
  Operating System:      UNIX
  ---------------------------------------------------------------------------------------

  Author:                Ran Liu $LastChangedBy: liuc5 $
  Creation Date:         07Sep2015 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/qcoutput.sas $

  Files Created:         output.log

  Program Purpose:       To create the final dataset in the transfer lib.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/
%macro qcoutput(in_data = ,linguistic= );
data _&in_data;
    retain &&&domain._varlst_;
    attrib &&&domain._varatt_;
    set &in_data;
    keep &&&domain._varlst_;
run;

proc sort data = _&in_data out=qtrans.&domain(Label = "&&&domain._dlabel_") %if &linguistic ne %then sortseq=linguistic(numeric_collation=on) ;;
    by &&&domain._keyvar_;
run;

proc sort data = _&in_data  nodupkey out =nodup(Label = "&&&domain._dlabel_") dupout = dup;
   by  &&&domain._keyvar_;
run;

%put &&&domain._keyvar_;
%let obs = 0;
data _null_;
    set dup end = endof;
    if endof then call symputx('obs',_n_);	
run;

%if &obs >0 %then %do;
    %put  The &in_data has duplicate records, please check it.;
    proc sort data = _&in_data nouniquekey out =dup;
        by &&&domain._keyvar_;
    run;
%end;
%mend qcoutput;
