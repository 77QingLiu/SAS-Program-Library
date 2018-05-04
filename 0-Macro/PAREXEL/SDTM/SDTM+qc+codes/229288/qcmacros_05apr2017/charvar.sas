/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 54767414LYM2001
  PXL Study Code:        220664

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: liuc5 $
  Creation Date:         25JUN2015 / $LastChangedDate: 2016-10-28 04:04:39 -0400 (Fri, 28 Oct 2016) $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS229288_STATS/transfer/qcprog/macros/charvar.sas $

  Files Created:         charvar.log

  Program Purpose:       To remove special character.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 51 $
-----------------------------------------------------------------------------*/

%macro charvar();
informat _all_; format _all_;
array chars {*} _char_;
do i = 1 to dim(chars );
    chars (i)=prxchange('s/[^\x20-\x7F]//o',-1,compbl(chars (i)));
    chars (i)=strip(compbl(chars(i)));
end;
drop i;
%mend charvar;
