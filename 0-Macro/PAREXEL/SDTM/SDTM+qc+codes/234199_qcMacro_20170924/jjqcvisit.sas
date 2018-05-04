/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   Janssen Research and Development LLC / CNTO1959PSA3002
  PAREXEL Study Code:    234200

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:         Cony Geng        $LastChangedBy: xiaz $
  Creation Date:         11Nov2014 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcvisit.sas $

  Files Created:         jjqcvisit.log

  Program Purpose:       To add VISIT/VISITNUM/VISITDY

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%macro jjqcvisit(in_data=, out_data=, date=, time=);
/** 14JUN2017: Hyland comment rave_flag as rave_folder not included in SV **/  
%if &domain^=LB and &domain^=QS %then %do;

proc sql;
    create table vs as
        select a.*, b.VISITNUM, b.VISIT, b.VISITDY/* , rave_flag */
        %if &date^= and &time^= %then , catx('T', b.SVSTDTC, &time) as &date length=19;
        %else %if &date^= and &time= %then , cats(b.SVSTDTC) as &date length=19;
        from &in_data a
        left join
        qtrans.sv b
        on a.subject=b.subject and a.sitenumber=b.sitenumber and a.folder=b.folder and a.instancename=b.instancename
        order by a.STUDYID, a.subject;
quit;

data &out_data;
    set vs;
    /** 14JUN2017: Hyland comment rave_flag and add folder as rave_folder not included in SV **/ 
    if /* not missing(rave_flag) */ folder="UNS" and index(visit,"UNSCHEDULED")=0 and visit^='' then &domain.SPID=cats(&domain.SPID,'-UNSCHED');
run;

%end;

%else %do;

data &in_data;
   set &in_data;
   if length(&domain.DTC)>10 then _&domain.DTC=substr(&domain.DTC, 1, 10);
   else _&domain.DTC=&domain.DTC;
   rename visit=_visit visitnum=_visitnum;
run;


proc sql;
    create table vs as
        select a.*, b.VISITNUM, b.VISIT, b.VISITDY/* , rave_flag */
        from &in_data a
        left join
        qtrans.sv b
        on a.usubjid=b.usubjid and a._&domain.DTC=b.SVSTDTC
        order by a.usubjid, a.&domain.DTC;
quit;

data &out_data;
    set vs;
    /** 14JUN2017: Hyland comment rave_flag and add folder as rave_folder not included in SV **/ 
/*    if folder="UNS" and index(visit,"UNSCHEDULED")=0 and visit^='' then &domain.SPID=cats(&domain.SPID,'-UNSCHED');*/
	if _visitnum=2098 and index(visit,"UNSCHEDULED")=0 and visit^='' then &domain.SPID=cats(&domain.SPID,'-UNSCHED');
run;


%end;



%mend jjqcvisit;

