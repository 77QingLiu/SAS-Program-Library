/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         11Nov2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjqcvisit.log

  Program Purpose:       To add VISIT/VISITNUM/VISITDY

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro jjqcvisit(in_data=, out_data=, date=, time=);
proc sql;
    create table vs as
        select a.*, b.VISITNUM, b.VISIT, b.VISITDY, UNSV 
        %if &date^= and &time^= %then , catx('T', b.SVSTDTC, &time) as &date length=19;
        %else %if &date^= and &time= %then , cats(b.SVSTDTC) as &date length=19;
        from &in_data a
        left join
        qtrans.sv b
        on a.usubjid=b.usubjid and a.sitenumber=b.sitenumber and a.folder=b.folder and a.instancename=b.instancename
        order by a.STUDYID, a.USUBJID;
quit;

data &out_data;
    set vs;
    if UNSV=1 then &domain.SPID=cats(&domain.SPID,'-UNSCHED');
run;
%mend jjqcvisit;

