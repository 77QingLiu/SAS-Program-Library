/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 32765LYM1002
  PXL Study Code:        220316

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         26Jun2016 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqccomdy.sas $

  Files Created:         jjqccomdy.log

  Program Purpose:       To compute dy variables

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/

%macro jjqccomdy(in_data=,out_data=, in_var=, out_var=);
    proc sql;
        create table &out_data as 
        select a.*,
               case when prxmatch('/(\d{4}-\d{2}-\d{2})/',cats(&in_var)) and prxmatch('/(\d{4}-\d{2}-\d{2})/',cats(b.RFSTDTC)) 
                         then input(scan(&in_var,1,'T'),e8601da.) - input(scan(b.RFSTDTC,1,'T'),e8601da.)
                         + (input(scan(&in_var,1,'T'),e8601da.) ge input(scan(b.RFSTDTC,1,'T'),e8601da.))
                    else . end as &out_var
        from &in_data as a left join qtrans.dm as b 
        on a.USUBJID=b.USUBJID;
    quit;
%mend jjqccomdy;
