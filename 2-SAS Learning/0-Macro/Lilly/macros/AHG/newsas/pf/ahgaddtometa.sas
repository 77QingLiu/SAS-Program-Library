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
	
	%macro AHGaddToMeta(tot);
	%global alreadyhave;
	%let alreadyhave=;
	    %AHGrpipe( grep ""^ *&tot *$"" &rootgui/reports.meta,alreadyhave);
	    %AHGpm(alreadyhave);
	    %put %str(cd &rootgui; chkout &rootgui/reports.meta);
	    %if not %length(&alreadyhave) %then 
    	    %do;
    	    %AHGrpipe( %str(cd &rootgui; chkout &rootgui/reports.meta),q);
    	    %put ok;
    	    %AHGrpipe( mv -f &rootgui/reports.meta &rtemp/reportsmeta,q);
    	    %AHGrpipe( %str(echo &tot > &rtemp/onetot),q);
    	    %AHGrpipe( %str(cat &rtemp/reportsmeta &rtemp/onetot> &rootgui/reports.meta),q);
    	    %AHGrpipe( chkin &rootgui/reports.meta add tot,q);
    	    %*rpipe( chkout &root3/&tot,q);
    	    %end;
    	%else %put  this tot is already there;
	 %backdoor:;   
	%mend;
