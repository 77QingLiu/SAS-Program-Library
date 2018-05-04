/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         11Oct2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjqcmepoch.log

  Program Purpose:       To derive epoch in each domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro jjqcmepoch(in_data=, in_date=);
data &in_data;
    if _n_=1 then do;
        length USUBJID EPOCH_ $40 SESTDTC SEENDTC $19;
        dcl hash h(dataset:'qtrans.se(rename=EPOCH=EPOCH_)', multidata: 'y');
        h.definekey('USUBJID');
        h.definedata('USUBJID', 'EPOCH_', 'SESTDTC', 'SEENDTC');
        h.definedone();
        call missing(EPOCH_, SESTDTC, SEENDTC);
    end;
    set &in_data;
    attrib EPOCH  length = $40  Label = "Epoch";
    rc=h.find();
    do while(rc=0);
        if "" < scan(SESTDTC, 1, 'T') <= &in_date and prxmatch('/SCREENING/', cats(EPOCH_)) then EPOCH="SCREENING";
        if "" < scan(SESTDTC, 1, 'T') <= &in_date and prxmatch('/TREATMENT/', cats(EPOCH_)) then EPOCH="TREATMENT";
        if "" < scan(SESTDTC, 1, 'T') < &in_date and prxmatch('/POST|FOLLOW/', cats(EPOCH_)) then EPOCH="POST TREATMENT";
        rc=h.find_next();
    end;
run;
%mend jjqcmepoch;