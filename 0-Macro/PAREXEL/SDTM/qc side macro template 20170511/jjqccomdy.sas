/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 32765LYM1002
  PXL Study Code:        220316

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         11Nov2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjqccomdy.log

  Program Purpose:       To compute dy variables

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro jjqccomdy(in_data=, in_var=, out_var=);
data &in_data(drop=RFSTDTC);
    if _n_=1 then do;
        if 0 then set sdtmpri.dm(keep=USUBJID RFSTDTC);
        dcl hash h(dataset:'sdtmpri.dm(keep=USUBJID RFSTDTC)');
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
