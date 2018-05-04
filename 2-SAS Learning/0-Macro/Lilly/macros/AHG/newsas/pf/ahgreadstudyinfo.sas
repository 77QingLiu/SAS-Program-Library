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



	   -------------------------------------------------------------------
	                          Modification History
	   -------------------------------------------------------------------
	   $Log:$


	   -------------------------------------------------------------------
	*/
	
	%macro AHGreadstudyinfo(studyid,property=link,outmac=);
	    %let studyid=%upcase(&studyid);
	    %let property=%upcase(&property);
	    
	    %if %sysfunc(exist(allstd.allstudies)) %then
    	    %do;
    	    data _null_;
    	        set allstd.allstudies(where=(  upcase(studyid) eq "&studyid" and upcase(property) eq "&property" ));    	    
    	        call symput("&outmac",trim(left(value)));
    	    run;
    	    %end;
	%mend;
