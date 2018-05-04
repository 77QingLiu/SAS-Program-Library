/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / MMY1006
  PXL Study Code:        228657

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Qingjie Zeng $LastChangedBy: xiaz $
  Creation Date:         10Aug2016 / $LastChangedDate: 2017-07-26 03:18:49 -0400 (Wed, 26 Jul 2017) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS234199_STATS/tabulate/qcprog/macros/jjqcdate2iso.sas $

  Files Created:         jjqcdate2iso.log

  Program Purpose:       To convert a SAS date, time or datetime variable to ISO8601 format

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 2 $
-----------------------------------------------------------------------------*/

%macro jjqcdate2iso(in_date=, in_time=, out_date=);
%if &in_date^= %then %do;
    if &in_date._YY^=. then YY_=cats(&in_date._YY);
    else YY_="-"; 
    if &in_date._MM^=. then MM_=put(&in_date._MM,z2.);
    else MM_="-";
    if &in_date._DD^=. then DD_=put(&in_date._DD,z2.);
    else DD_="-";
%end;
%if &in_time^= %then %do;
    &in_time.H=input(scan(&in_time,1,":"),??best.);
    &in_time.M=input(scan(&in_time,2,":"),??best.);
    if &in_time.H^=. then H_=put(&in_time.H,z2.); 
    else H_="-";
    if &in_time.M^=. then M_=put(&in_time.M,z2.); 
    else M_="-";
%end;
%if &in_date^= and &in_time^= %then %do;
    &out_date=catx("-", YY_, MM_, DD_)||"T"||catx(":", H_, M_);
%end;
%else %if &in_date^= %then %do;
    &out_date=catx("-", YY_, MM_, DD_);
%end;
%else %if &in_time^= %then %do;
    &out_date=catx(":", H_, M_);
%end;
if ^ prxmatch('/\d/', cats(&out_date)) then &out_date="";
&out_date=prxchange('s/(T-\:-|----)$//',-1,cats(&out_date));
&out_date=prxchange('s/(--)$//',-1,cats(&out_date));
&out_date=prxchange('s/(--)//',-1,cats(&out_date));
&out_date=prxchange('s/(:-)$//',-1,cats(&out_date));
%mend jjqcdate2iso;
