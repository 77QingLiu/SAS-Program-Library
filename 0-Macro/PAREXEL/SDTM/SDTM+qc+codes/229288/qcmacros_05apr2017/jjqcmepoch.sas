/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development, LLC / R033812DYP1002
  PXL Study Code:        228775

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:              Chase Liu $LastChangedBy: wangfu $
  Creation Date:         20Apr2016 / $LastChangedDate: 2016-11-25 03:14:40 -0500 (Fri, 25 Nov 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqcmepoch.sas $

  Files Created:         jjqcmepoch.log

  Program Purpose:       To derive epoch in each domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 81 $
-----------------------------------------------------------------------------*/

%macro jjqcmepoch(in_data=,out_data=, in_date=);
proc transpose data=qtrans.se out=se;
    by USUBJID;
    var SESTDTC;
    id ETCD;
run;
data se;
  length SCRN VELIV VELSC FU1 FU2 $19;
  call missing(SCRN, VELIV, VELSC, FU1, FU2);
  set se;
run;

proc sql;
    create table &out_data as 
    select a.*,
/*           case when cmiss(&in_date,visit) = 2 then ''*/
           case when missing(&in_date) then ''
           /* %if %upcase(&domain) = DS %then when dscat not in ("DISPOSITION EVENT","PROTOCOL MILESTONE") then  ""; */
                when  (scan(&in_date,1,'T') > scan(FU1, 1, 'T') >'' and scan(&in_date,1,'T')>c.SEENDTC>'') 
                        or (scan(&in_date,1,'T') >= scan(FU2, 1, 'T') >'' and scan(&in_date,1,'T')>c.SEENDTC>'') then "FOLLOW-UP"      
                when  (scan(&in_date,1,'T') >= scan(VELSC, 1, 'T') >'') or (scan(&in_date,1,'T') >= scan(VELIV, 1, 'T') >'')  then "TREATMENT"
                when  scan(&in_date,1,'T')  >= scan(SCRN, 1, 'T') >''  then "SCREENING"
           else '' end as EPOCH length=40 label='Epoch'
    from &in_data as a left join se as b 
    on a.USUBJID=b.USUBJID
    left join qtrans.se(where=(ETCD in ('VELSC','VELIV') and ^missing(SEENDTC))) as c
    on a.USUBJID=c.USUBJID;
quit;
%mend jjqcmepoch;
