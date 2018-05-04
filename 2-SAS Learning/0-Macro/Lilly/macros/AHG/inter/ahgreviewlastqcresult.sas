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
	
%macro AHGreviewLastQCresult(tableno,tailor=0,version=);
    %local macroname ;
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname);  
    %let tableno=%lowcase(&tableno);
    %if not %length(&version) %then
    %do;
    %AHGrpipe(%str(cd &root3/analysis; ls -t &tableno.v*lst |sed -n 1,1p|sed  's/.*v\.//' |sed 's/\.lst//')  ,rcrpipe)  ;
    %let version=&rcrpipe;
    %AHGpm(version);
    %end;



    
    %AHGrdown(folder=analysis,filename=&tableno.v.&version..log,open=1,save=0) ;
    %AHGrdown(folder=analysis,filename=&tableno.v.&version..lst,open=1,save=0) ;
    
    %global rptfile;
    %let rptfile=;
    %AHGrpipe(%str(cd &root3; tabnum2rpt &tableno)  ,rptfile)  ;
    %AHGrpipe(%str(echo delete file;test -e &userhome/temp/&tableno.v.&version..rpt && rm -f &userhome/temp/&tableno.v.&version..rpt)  ,q)  ;
    %AHGrpipe(%str(echo delete file;test -e &root3/analysis/&tableno.v.&version..rpt && rm -f &root3/analysis/&tableno.v.&version..rpt)  ,q)  ;
    
    
    %AHGrpipe(co -r&version -p &rptfile>&userhome/temp/&tableno.v.&version..rpt  ,q)  ;  
    %if &tailor=1 %then %AHGrpipe(%str( tailorpages.pl --file &userhome/temp/&tableno.v.&version..rpt --finalpages &root3/analysis/&tableno.v.&version..rpt) ,q); 
    %else %AHGrpipe(cp &userhome/temp/&tableno.v.&version..rpt  &root3/analysis/&tableno.v.&version..rpt ,q); 
    
    %AHGrdown(folder=analysis,filename=&tableno.v.&version..rpt,open=1,save=0) ;
    

          
%mend;
