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

  Program Purpose:       open the dataset selected

  Macro Parameters       NA

-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: $
-----------------------------------------------------------------------------*/
%macro markdsn();
gsubmit "
dm 'wcopy';
 
filename clip clipbrd;
 
data _null_;
   infile clip;
   input;
   call execute('dm ""vt '||_INFILE_||' colheading=name execcmd = qing.goto.goto.scl:execcmd ;"" continue ;');
run;
 
filename clip clear;";
%mend markdsn;

