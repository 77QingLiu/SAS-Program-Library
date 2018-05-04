/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 547674141006
  PXL Study Code:        228657

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         10Aug2016 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqccomdy.sas $

  Files Created:         jjqccomdy.log

  Program Purpose:       To compute dy variables

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%macro jjqccomdy(in_data=, in_var=, out_var=);
data &in_data(drop=RFSTDTC);
    if _n_=1 then do;
        if 0 then set qtrans.dm(keep=USUBJID RFSTDTC);
        dcl hash h(dataset:'qtrans.dm(keep=USUBJID RFSTDTC)');
        h.definekey('USUBJID');
        h.definedata(all:'Y');
        h.definedone();
    end;
    set &in_data;
    if h.find()=0 then do;
	   REFDT_=input(substr(RFSTDTC,1,10),yymmdd10.);
	   if prxmatch('/(\d{4}-\d{2}-\d{2})/',cats(&in_var)) then DT_=input(substr(&in_var,1,10),yymmdd10.);
       else DT_=.;
       if nmiss(REFDT_, DT_)=0 then &out_var = DT_ - REFDT_ + (DT_ ge REFDT_);
       else &out_var = .;
       if prxmatch('/(--)/',&in_var) or prxmatch('/(--)/',RFSTDTC) then &out_var=.;
       if cmiss(&in_var, RFSTDTC)^=0 then &out_var=.;
       output;
    end;
    if h.find() then output;
run;
%mend jjqccomdy;
