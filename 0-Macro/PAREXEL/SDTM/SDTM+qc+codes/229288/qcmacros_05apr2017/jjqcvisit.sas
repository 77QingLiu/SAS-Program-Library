/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 61610588LUC1001
  PXL Study Code:        227857

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: liuc5 $
  Creation Date:         11Nov2014 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqcvisit.sas $

  Files Created:         jjqcvisit.log

  Program Purpose:       To add VISIT/VISITNUM/VISITDY

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/

%macro jjqcvisit(in_data=, out_data=, date=, time=);
proc sql;
    create table m_visit as
        select a.*, b.VISITNUM, b.VISIT, b.VISITDY, UNSV 
        %if &date^= and &time^= %then , catx('T', b.SVSTDTC, &time) as &date length=19;
        %else %if &date^= and &time= %then , cats(b.SVSTDTC) as &date length=19;
        from &in_data a
        left join
        qtrans.sv b
        on a.usubjid=b.usubjid and a.sitenumber=b.sitenumber and a.foldername=b.foldername and a.instancename=b.instancename
        order by a.STUDYID, a.USUBJID;
quit;

data &out_data;
    set m_visit;
    if UNSV=1 then &domain.SPID=cats(&domain.SPID,'-UNSCHED');
run;
%mend jjqcvisit;

