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
	
%macro AHGreadmsg;
    %macro showmessage(message);
        %let star=%str(***********************************************************);
        option xwait;
        x " echo &star & echo &star  &message &echo &star & echo please type exit to close this window & echo &star ";
        option noxwait;
    %mend;
    
    


    %if not %sysfunc(exist(psascall.readmsgdate)) %then    
        %do;
        data psascall.readmsgdate;
            lastdatetime=datetime();
        run;
        %end;
    %if not %sysfunc(exist(psascall.allstd.msg_&theuser)) %then    
            %do;
            data allstd.msg_&theuser;
            run;
            %end;        
            



    data  psascall.mymessage(drop=allmsg);
        p=1;
        set psascall.readmsgdate point=p;
        set allstd.msg_&theuser: end=end;
        format allmsg $32767.;
        retain allmsg '';
        fullmessage=' &  echo '||trim(deliverer)||' send a message to  you '||' at '||put(datetime,datetime20.)||' & echo ********** & echo Message Body: '||trim(message);
        if datetime>=lastdatetime then allmsg=trim(allmsg)||' '||fullmessage;
        if end then put allmsg;
        if end and allmsg ne '' then call execute('%showmessage(%str('||substr(left(trim(allmsg)),1)||'));');

    run;
    
    data psascall.readmsgdate;
        format lastdatetime datetime20.;
        lastdatetime=datetime();
    run;
    
%mend;

