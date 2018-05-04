/* -------------------------------------------------------------------

                          CDARS System Module

   -------------------------------------------------------------------

   $Source: /home/liu04/macros/RCS/datanodupkey.sas,v $

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

   $Log: datanodupkey.sas,v $
   Revision 1.2  2012/02/07 03:55:32  liu04
   update

   copy from liux43



**********************************/

%macro AHGdatanodupkey(data = , out = , by = );
	%if %AHGblank(&out) %then %let out=%AHGbasename(&data);

  proc sort data = &data out = &out nodupkey;
    by &by;
  run;
%mend ;
