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
    %macro AHGsendmsg(receiver,message);
        
        data allstd.msg_&receiver._&theuser;
            format receiver $20. deliverer $20. message $500. datetime datetime20.;
            if _n_<=1 then
                do;
                deliverer="&theuser";
                datetime=datetime();
                receiver="&receiver";
                message="&message";
                output; 
                end;
        ;
            %if %sysfunc(exist(allstd.msg_&receiver._&theuser)) %then %do;  set allstd.msg_&receiver._&theuser;output;%end;
        
        run;
    %mend;
