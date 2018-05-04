	/* -------------------------------------------------------------------
	                          CDARS System Module
	   -------------------------------------------------------------------
	   $Source: $
	   $Revision: 1.1 $
	   $Author: Hui Liu $
	   $Locker:  $
	   $State: Exp $

	   $Purpose: Refresh words relationship from a txt file for future search

	   $Assumptions:



	   -------------------------------------------------------------------
	                          Modification History
	   -------------------------------------------------------------------
	   $Log:$


	   -------------------------------------------------------------------
	*/
	
	%macro AHGwordtowords(word1,word2);
	
	    data allstd.wordtowords;
	        format word1 $500.;
	        format word2 $500. user $20.;
	        if _n_=1 then
    	        do;
    	        word1="&word1";
    	        word2="&word2";
    	        user="&theuser";
    	        output;
	            end;	        
	        %if %sysfunc(exist(allstd.wordtowords)) %then %do;  set allstd.wordtowords;output;%end;

	        
	    run;
	    
	    proc sort data=allstd.wordtowords nodup;
	        by word1 word2;
	    run;
	        
	%mend;
