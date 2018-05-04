/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   PAREXEL / Macro and Application Development committee
  PAREXEL Study Code:    80386

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Owner:              Cony Geng   $LastChangedBy: xiaz $
  Last Modified:      2017-06-05  $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcdata_type.sas $
  SVN Revision No:       $Rev: 2 $

  Files Created:         None

  Program Purpose:       Standard autoexec.sas to direct SAS to open the
                         project specific setup program with
                         the appropriate parameters.
-----------------------------------------------------------------------------*/

%macro jjqcdata_type;
%global keep_sub raw_sub;
%if &data_ = UAT %then %do;
    %let keep_sub = where=(scan(USUBJID, -1, "-") in ('20000', '20001',  '20002', '20003','20004','20005','20006'));

    %let raw_sub = subject in ('20000', '20001',  '20002', '20003','20004','20005','20006') and site='106_UAT';

%end;
%else %do;
    %let keep_sub = ;
    %let raw_sub = 1=1;
%end;
%mend jjqcdata_type;

