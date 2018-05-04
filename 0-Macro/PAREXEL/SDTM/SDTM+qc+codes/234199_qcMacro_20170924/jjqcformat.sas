
/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 54767414MMY1006
  PXL Study Code:        228657

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         10Aug2016 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcformat.sas $

  Files Created:         format.log

  Program Purpose:       To prepare format.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
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
        from qmeta.valdef where reverse(substr(reverse(strip(valueoid)), 1, 6)) = "TESTCD" and valueoid^='TI.IETESTCD';
    create table spec_fmt1 as
        select distinct FMTNAME, '' as START, '' as LABEL, 'C' as TYPE, 'O' as HLO
        from spec_fmt union
        select * from spec_fmt
    order by FMTNAME;
quit;

proc format library=fmtq cntlin=spec_fmt1;
run;

*format for each codelist;

/*proc sql;
    create table spec_fmt as
        select codelst as FMTNAME, codeval as START,
        decod as LABEL, 'C' as TYPE, '' as HLO
        from qmeta.cd where ^missing(codelst) and codelst^="ISO 8601";
    create table spec_fmt1 as
        select distinct FMTNAME, '' as START, '' as LABEL, 'C' as TYPE, 'O' as HLO
        from spec_fmt union
        select * from spec_fmt
    order by FMTNAME;
quit;

data spec_fmt1;
    set spec_fmt1;
    if fmtname='TOXGRV4' then fmtname='TOXGRV';
    if fmtname='TOXV4' then fmtname='TOXV';
run;

proc format library=fmtq cntlin=spec_fmt1;
run;*/
