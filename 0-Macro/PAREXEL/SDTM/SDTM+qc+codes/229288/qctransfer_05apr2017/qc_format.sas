/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 26866138MMY3037
  PXL Study Code:        229288

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         27Jun2016 / $LastChangedDate: 2016-07-17 08:57:45 -0400 (Sun, 17 Jul 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/transfer/qc_format.sas $

  Files Created:         qc_format.log

  Program Purpose:       To prepare format.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 14 $
-----------------------------------------------------------------------------*/

*format for QNAM;

proc sql;
    create table spec_fmt as
        select substr(valueoid,5,2)||"_QL" as FMTNAME, valval as START, vallabel as LABEL, 'C' as TYPE,
        '' as HLO
        from qmeta.valdef where substr(valueoid, 1, 4) = "SUPP";
    create table spec_fmt1 as
        select distinct FMTNAME, '' as START, '' as LABEL, 'C' as TYPE, 'O' as HLO
        from spec_fmt union
        select * from spec_fmt
    order by FMTNAME;
quit;

proc format library=fmtq cntlin=spec_fmt1;
run;

*format for TESTCD;
proc sql;
    create table spec_fmt as
        select substr(valueoid,1,2)||"_TESTCD" as FMTNAME,
        valval as START, strip(vallabel) as LABEL, 'C' as TYPE, '' as HLO
        from qmeta.valdef where reverse(substr(reverse(strip(valueoid)), 1, 6)) = "TESTCD";
    create table spec_fmt1 as
        select distinct FMTNAME, '' as START, '' as LABEL, 'C' as TYPE, 'O' as HLO
        from spec_fmt union
        select * from spec_fmt
    order by FMTNAME;
quit;

proc format library=fmtq cntlin=spec_fmt1;
run;

*format for each codelist;

proc sql;
    create table spec_fmt as
        select codelst as FMTNAME, codeval as START,
        decod as LABEL, 'C' as TYPE, '' as HLO
        from qmeta.cd where ^missing(codelst);
    create table spec_fmt1 as
        select distinct FMTNAME, '' as START, '' as LABEL, 'C' as TYPE, 'O' as HLO
        from spec_fmt union
        select * from spec_fmt
    order by FMTNAME;
quit;

data spec_fmt1;
    set spec_fmt1;
    if fmtname='TOXGRV3' then fmtname='TOXGRV';
    if fmtname='TOXV3' then fmtname='TOXV';
run;

proc format library=fmtq cntlin=spec_fmt1;
run;
