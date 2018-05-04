/* -------------------------------------------------------------------
                          CDARS System Module
   -------------------------------------------------------------------
   $Source: /home/liu04/bin/macros/batchQC.sas,v $
   $Revision: 1.2 $
   $Author: liu04 $
   $Locker:  $
   $State: Exp $

   $Purpose:

   $Assumptions:

   $Inputs:
   $Outputs:

   $Called by:
   $Calls to:

   $Usage notes: Comment header items that end with a trailing '$'
                 are automatically populated by RCS.  The remaining


   $System archet: UNIX

   -------------------------------------------------------------------
                          Modification History
   -------------------------------------------------------------------
   $Log: batchQC.sas,v $






**********************************/
%macro AHGremotelyruntot(obj)/secure;
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 
    option nomprint nosymbolgen nomacrogen NONOTES;
    rsubmit;
    option nomprint nosymbolgen nomacrogen NONOTES;
    endrsubmit;

    
    %if not %index(&obj,.tot) %then 
    %DO;
    %AHGrpipe(%str( totfile=$(tabnum2tot &obj &root3/tools) ;basename $totfile  ),totfile)  ;
    %let obj=&totfile;
    %END;
    %AHGrpipe( /Volumes/app/cdars/prod/bin/run_reports.pl &root3/tools/&obj ,totfile)  ;
    rsubmit;
    option mprint notes ;
    %put TOT was run ######################################;
    endrsubmit;
%mend;
