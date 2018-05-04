/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / 32765LYM1002
  PXL Study Code:        221316

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         11Nov2014 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         jjqcclean.log

  Program Purpose:       To clean work dataset and reset domain.

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro jjqcclean();
%let DOMAIN = ;
proc datasets nolist lib = work memtype = data kill;
quit;
%mend jjqcclean;
