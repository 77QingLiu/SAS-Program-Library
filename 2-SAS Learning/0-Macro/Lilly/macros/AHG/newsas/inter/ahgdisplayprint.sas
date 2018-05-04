/* -------------------------------------------------------------------

                          CDARS System Module

   -------------------------------------------------------------------

   $Source: /Volumes/app/cdars/prod/prjA319/a3191348/A3191348_Eff/saseng/pds1_0/analysis/RCS/displayprint.sas,v $

   $Revision: 1.1 $

   $Author: liux43 $

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

   $Log: displayprint.sas,v $
   Revision 1.1  2010/04/19 08:08:31  liux43
   Updated

   Revision 1.1  2010/04/06 10:12:10  liux43
   update


**********************************/

%macro AHGdisplayprint(data = );
	proc print 
    %if %length(&data) %then
      %do;
        data = &data
      %end;
    noobs
    width = minimum
  ; 
	run;
%mend ;
