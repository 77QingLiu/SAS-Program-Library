/* -------------------------------------------------------------------
                          CDARS System Module
   -------------------------------------------------------------------
   $Source: /Volumes/app/cdars/prod/prjA258/phase3b4/A2581172/saseng/pds1_0/program/RCS/fmd_site_chg.sasdrvr,v $
   $Revision: 1.14 $
   $Author: Hui Liu $
   $Locker:  $
   $State: Exp $

   $Purpose:

   $Assumptions:

   $Inputs:
   $Outputs:

   $Called by:
   $Calls to: lib_temp.sas template.sas

   $Usage notes: Comment header items that end with a trailing '$'
                 are automatically populated by RCS.  The remaining
                 items must be maintained by the developer.

                 DESCRIPTION OF ITEMS

                 Source: The fullname and path of the RCS file.
                 Revision: The RCS version number this file is at.
                 Author: The username of the last person to modify
                         this file.
                 Locker: Which username has this revision reserved?
                 State: Possible future use.  devel, test or prod.

                 Purpose: What does this module do?
                 Assumptions: What needs to exist for this module
                              to fulfill its purpose?
                 Inputs: Data, lookup files, macros variables.
                 Outputs: Data, report, logs, listings.

                 Called by: Which SAS modules call this module?
                 Calls to: Which SAS modules does this module call?

                 Usage notes: Any hints on how to use this module.
                 System archet: Where will this module be used?
                 Log: Who did what when?

   $System archet: UNIX

   -------------------------------------------------------------------
                          Modification History
   -------------------------------------------------------------------

   -------------------------------------------------------------------
*/
%macro AHGfilever(file,outmac=rcrpipe)/secure;
%AHGrpipe(%str(rlog &file  | grep 'head:' |cut -d':' -f2),&outmac);

%mend;


