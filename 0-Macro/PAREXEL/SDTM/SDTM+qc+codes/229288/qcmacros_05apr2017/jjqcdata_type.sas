/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development, LLC / VAC89220HPX2004
  PXL Study Code:        227542

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:              Chase Liu $LastChangedBy: liuc5 $
  Creation Date:         14Mar2016 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

 Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/jjqcdata_type.sas $

  Files Created:         none

  Program Purpose:       Keep specific subjects for UAT transfer.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/
/************************************************************
*  MACRO: Keep specific subjects for UAT transfer           *
************************************************************/

%macro jjqcdata_type;
%global keep_sub raw_sub where_raw_lab;
%if &data_ = UAT %then %do;
    %let keep_sub = where=(strip(scan(USUBJID, 2, "-")) in 
      ('106005','106006','106007','106010','106011','106012',
        '106015','106018','106019'));
    %let raw_sub = 
    subject in 
      ('106005','106006','106007','106010','106011','106012',
        '106015','106018','106019')
     and site="106_UAT";

     %let where_raw_lab=%str(where=(not find(instancename,'follow','i')));
%end;
%else %if &data_ = OFFL %then %do;
    %let keep_sub = ;
    %let raw_sub = site="106_UAT";
%end;
%else %do;
    %let keep_sub = ;
    %let raw_sub = 1=1;
     %let where_raw_lab=%str(where=(1=1));    
%end;
%mend jjqcdata_type;
