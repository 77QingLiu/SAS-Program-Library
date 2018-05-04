/* -------------------------------------------------------------------
                          Author: Hui Liu
   -------------------------------------------------------------------
   $Source: /Volumes/app/cdars/prod/prjB377/b3771001/B3771001_Cohort1s/saseng/pds1_0/macros/RCS/template.sas,v $
   $Revision: 1.1 $
   $Author: Liuh04 $
   $Locker:  $
   $State: Exp $
   Hui Liu. ahuige's macro
   $Purpose:

   $Assumptions:

   $Inputs:
   $Outputs:

   $Called by: template.sasdrvr
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
   $Log: template.sas,v $
   -------------------------------------------------------------------
*/


%macro AHGmodtot(tots,f=,t=,k=);
	%local tot i cmd paraf;
	%let k=%upcase(&k);
	%do i=1 %to %AHGcount(&tots);
	%let tot=%scan(&tots,&i,%str( ));
	%if not %index(&tot,.tot) %then %let tot=&tot..tot;
	%if %AHGblank(&f) %then %let paraf=;
	%else %let paraf=-f &f;
	%let cmd=modrcstot -k &k  &paraf -t &t -w &root3/tools/&tot;
	%AHGpm(cmd);
	%AHGsubmitRcommand(cmd=&cmd);
	%end;
%mend;
