/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: Janssen Research Development / CNTO148AKS3001
  PXL Study Code:        218185

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Allen Wei $LastChangedBy:  $
  Creation Date:         25 Nov 2015 / $LastChangedDate:  $

  Program Location/name: $HeadURL:  $

  Files Created:         lsidem03.log
                         lsidem03.sas7bdat

  Program Purpose:       To create List of Subjects Requiring Treatment for Latent TB Through Week 28

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev:  $
-----------------------------------------------------------------------------*/

*----------------------------------------------------------------------------*;
* Cleaning log & work library;
*----------------------------------------------------------------------------*;
dm "log; clear; out; clear;";
proc datasets nolist lib=work memtype=data kill;run;

/* -------------Program body--------------------- */
%LET PGID=LSIDEM03;

/***Your program to generate tables.tsidem01 here.***/

%REPORT ( COLUMN    = GRPX1 COL1 GRPX2 COL2 COL3 COL4 COL5
         ,WIDTH     = 20 25 20 15 18
         ,COLLBL    = Treatment Group|Subject ID|Treatment Required$(Baseline/ Postbaseline)|Study Day of$Treatment$Initiation|Treatment Initiated
         ,LINE_VAR  = COL2
         ,ORDVAR    = GRPX1 COL1 GRPX2 COL2 COL3
         ,PGVAR     = GRPX99 );
