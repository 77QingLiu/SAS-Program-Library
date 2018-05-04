/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

 Sponsor / Protocol No: Janssen Research & Development, LLC / VAC89220HPX2004
  PXL Study Code:        227542

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:              Jane Liu $LastChangedBy: liuc5 $
  Creation Date:         14Mar2016 / $LastChangedDate: 2016-08-29 03:54:05 -0400 (Mon, 29 Aug 2016) $

Program Purpose: Preprocess to deal with logline in raw dataset
                 
Macro Parameters: NA
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 42 $
-----------------------------------------------------------------------------*/

/************************************************************
*  MACRO: jjqclogline                                         *
*  - Preprocess to deal with logline in raw dataset         *
************************************************************/
%macro jjqclogline(in_=);

proc sort data = raw.&in_ out = &in_;
    by SITENUMBER SUBJECT INSTANCENAME DATAPAGENAME RECORDPOSITION;
run;

data &in_;
     set raw.&in_;
     by SITENUMBER SUBJECT INSTANCENAME DATAPAGENAME RECORDPOSITION;
     if first.DATAPAGENAME;
run;
%mend jjqclogline;