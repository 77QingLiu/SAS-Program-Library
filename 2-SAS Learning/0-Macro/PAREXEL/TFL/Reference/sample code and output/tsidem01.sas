/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research & Development / CNTO148PSA3001
  PXL Study Code:        218184

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Wei $LastChangedBy:  $
  Creation / modified:   13Jan2016 / $LastChangedDate:  $

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_JANSS218184_STATS/primary/prog/tables/tsidem01.sas $

  Files Created:         tsidem01.sas7bdat
                         tsidem01.log

  Program Purpose:       To Create Summary of Demographics at Baseline
  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 85 $
-----------------------------------------------------------------------------*/

dm "log; clear; out; clear;";
proc datasets nolist lib=work memtype=data kill;run;

/* -------------Program body--------------------- */
%LET PGID=TSIDEM01;

/***Your program to generate tables.tsidem01 here.***/

%REPORT ( COLUMN   = GRPX1 item1 COL1 COL2 COL3
         ,WIDTH    = 30 10 15 10
         ,COLLBL   = |Placebo|Golimumab 2~{unicode 00A0}mg/kg|Total
         ,LINE_VAR = GRPX1
         ,PGVAR    = GRPX2
         );
