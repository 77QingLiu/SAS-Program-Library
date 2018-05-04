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
	
	%macro AHGbugdetails(bugid,studyid,qcdoc=temp.qcdoc&studyid);
        proc sql ; 
        create view nodup as
        select distinct * 
        from &qcdoc
        where not missing(filename)
        group by dateframe, fileid, sortid ,datetime
        ;  
        create view  bugs as
        select * 
        from  nodup
        where status  in (0 2 3)
        ;  
        create view  solutions as
        select nodup.bugid, bugs.filename,bugs.reason as ori_reason, bugs.version as ori_ver
                   ,nodup.reason as action,nodup.version as fixed_ver
        from  nodup left join  bugs
        on nodup.bugid =bugs.bugid
        where nodup.status=1
        ; 	    
        select *
        from solutions
        where upcase(bugid)=upcase("&bugid")
        ;
        quit;
        %local studylink;
        proc sql noprint;
        select value into :studylink
        from allstd.allstudies
        where upcase(studyid)=upcase("&studyid")
        ;
        %local tabno ori_ver fixed_ver;
        select filename, left(trim(ori_ver)), left(trim(fixed_ver)) into :tabno,:ori_ver,:fixed_ver
        from solutions
        where upcase(bugid)=upcase("&bugid")
        ;quit;
        %let tabno=%left(%trim(&tabno));
        %let ori_ver=%left(%trim(&ori_ver));
        %let fixed_ver=%left(%trim(&fixed_ver));
        
        %global rptfile;
        %let rptfile=;
        %AHGrpipe(%str(cd %trim(&studylink); tabnum2rpt &tabno)  ,rptfile)  ;
        %AHGpm(rptfile);
        
        
        %AHGrpipe(co -r&ori_ver -p &rptfile> &userhome/temp/&tabno.v.&ori_ver..rpt  ,rcrpipe)  ;
        %AHGrpipe(co -r&fixed_ver -p &rptfile> &userhome/temp/&tabno.v.&fixed_ver..rpt  ,rcrpipe)  ;
        
        %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&ori_ver..rpt,open=1);
        %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&fixed_ver..rpt,open=1);
        
	    
	%mend;
