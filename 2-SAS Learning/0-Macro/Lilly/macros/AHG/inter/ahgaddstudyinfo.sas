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
	
	%macro AHGaddstudyinfo(studyid,property=link,value=);
	    %let studyid=%upcase(&studyid);
	    %let property=%upcase(&property);
	    libname allstd "&preadandwrite\allstudies";
	    %if %sysfunc(exist(allstd.allstudies)) %then
    	    %do;
    	    data property;
    	        format studyid $50. property $50. value $500.;
    	        studyid="&studyid";
    	        property="&property";
    	        value="&value";
    	    run;  
            data allstd.allstudies;
    	        set allstd.allstudies(where=(upcase(studyid) ne "&studyid" or upcase(property) ne "&property" )) property;    	    
    	    run;
    	    %end;
    	%else
    	    %do;
    	    data allstd.allstudies;
    	        format studyid $50. property $50. value $500.;
    	        studyid="&studyid";
    	        property="&property";
    	        value="&value";
             run;
    	    %end;
			data allstd.allstudies;
				set allstd.allstudies;
				proj=scan(value,5,'/');
				subm=scan(value,6,'/');
				prot=scan(value,7,'/');
    	    run;    	  
    	    proc sort data=allstd.allstudies out=allstd.allstudies(keep=studyid property value) ;
				by proj subm prot  ;
    	    run;     
	%mend;
