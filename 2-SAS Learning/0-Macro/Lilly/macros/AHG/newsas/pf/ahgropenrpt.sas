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
   Revision 1.2  2009/05/20 09:05:09  liu04
   add auto version option





**********************************/
%macro AHGropenrpt(obj);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 


    %if not %index(&obj,.tot) %then 
    %DO;
    %AHGrpipe(%str( totfile=$(tabnum2tot &obj &root3/tools) ;basename $totfile  ),totfile)  ;
    %let obj=%sysfunc(tranwrd(&totfile,.tot,.rpt));
    %END;
        
        %AHGrdown(folder=table,filename=&obj,save=0) ;       
        x "%bquote(&projectpath)\table\&obj";


%mend;
