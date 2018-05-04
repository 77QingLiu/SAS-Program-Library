	/* -------------------------------------------------------------------
	                          CDARS System Module
	   -------------------------------------------------------------------
	   $Source: $
	   $Revision: 1.1 $
	   $Author: Hui Liu $
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

	   $System archet: 

	   -------------------------------------------------------------------
	                          Modification History
	   -------------------------------------------------------------------
	   $Log:$


	   -------------------------------------------------------------------
	*/
	
%macro AHGsearchallqcdoc(issues,strict=0,studies=,related=0,fields=%str(bugid filename reason studyname datetime),refresh=1);
    %local macroname;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 
    %local allusers  i;
    %AHGfindusers(&preadandwrite\allusers,outusers=allusers);
    %if not %length(&studies) %then %AHGfindusers(&preadandwrite\allstudies,outusers=studies);
    
    %AHGpm(allusers studies);
    /*
    %if &refresh=1 %then 
        %do i=1 %to %AHGcount(&studies);
         
            %put Iamdoing study %scan(&studies,&i) the number is &i;
            %AHGrelib(%scan(&studies,&i));
        %end;
    */
        
    %do i=1 %to %AHGcount(&studies);
        %put ahuige n=&i;
        %if &refresh=1 or not %sysfunc(exist(temp.qcdoc%scan(&studies,&i))) %then %AHGrelib(%scan(&studies,&i));
        %if %sysfunc(exist(temp.qcdoc%scan(&studies,&i))) %then %AHGsearchqcdoc(&issues,related=&related,strict=&strict,dsn=temp.qcdoc%scan(&studies,&i));;
        data searchresult%scan(&studies,&i);
            set searchresult;
        run;
    %end;        
            
        
            
%mend;



