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
	
	%macro AHGRemoveFromMeta(tot);
	%global alreadyhave;
	%let alreadyhave=;
	    %AHGrpipe( grep ""^ *&tot *$"" &rootgui/reports.meta,alreadyhave);

	    %if  %length(&alreadyhave) %then 
    	    %do;
    	    %AHGrpipe( %str(cd &rootgui; chkout &rootgui/reports.meta),q);
    	    %AHGrpipe( mv -f &rootgui/reports.meta &rtemp/reportsmeta,q); 
    	    %AHGrpipe(  %str(grep -v ""^ *&tot *$"" &rtemp/reportsmeta > &rootgui/reports.meta),q);
    	    %AHGrpipe( chkin &rootgui/reports.meta remove tot,q);

    	    %end;
    	%else %put  there is no such tot;
 
	%mend;
