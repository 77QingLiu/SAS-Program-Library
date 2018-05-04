/* -------------------------------------------------------------------

                          CDARS System Module

   -------------------------------------------------------------------

   $Source: /Volumes/app/cdars/prod/prjA319/a3191348/A3191348_Eff/saseng/pds1_0/analysis/RCS/datasort.sas,v $

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

   $Log: datasort.sas,v $

   

**********************************/

%macro AHGzipdown(folder=,mask=%str(*.sas7bdat),ziprtemp=&root3,rdir=&root3,ldir=&projectpath);
    %AHGrpipe(test -e &ziprtemp/&folder..tar %nrstr(&&) rm -f &ziprtemp/&folder..tar,q);
    %AHGrpipe(test -e &ziprtemp/&folder..tar.gz %nrstr(&&) rm -f &ziprtemp/&folder..tar.gz,q);

	%AHGrpipe(cd &rdir/ %nrstr(;) tar -cvf &ziprtemp/&folder..tar &folder/&mask,q);
	%AHGrpipe(cd &rdir/ %nrstr(;) test -e &ziprtemp/&folder..tar %nrstr(&&) gzip &ziprtemp/&folder..tar ,q);
	%AHGrdown(rpath=&ziprtemp 
            ,filename=&folder..tar.gz
            ,locpath=&ldir
            ,open=0
            ,binary=binary); 

    %AHGrpipe(test -e &ziprtemp/&folder..tar %nrstr(&&) rm -f &ziprtemp/&folder..tar,q);
    %AHGrpipe(test -e &ziprtemp/&folder..tar.gz %nrstr(&&) rm -f &ziprtemp/&folder..tar.gz,q);


%mend ;
