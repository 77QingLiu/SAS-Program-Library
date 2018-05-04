/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Zeng $LastChangedBy: $
  Creation Date:         08Oct2016 / $LastChangedDate: $

  Program Location/name: $HeadURL: $

  Files Created:         NA

  Program Purpose:       run the selected code and open the last created dataset 

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/
%macro markcode();
store;
gsubmit "%nrstr(%%let) clip_c=%nrstr(%%nrstr%()";
gsubmit buf=default;
gsubmit ");";

gsubmit "&clip_c";
gsubmit 'dm "vt &syslast;" continue;';
%mend markcode;