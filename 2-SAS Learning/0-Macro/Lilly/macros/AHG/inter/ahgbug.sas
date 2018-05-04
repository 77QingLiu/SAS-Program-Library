	/* -------------------------------------------------------------------
	                          CDARS System Module
	   -------------------------------------------------------------------
	   $Source: /home/liu04/bin/macros/bug.sas,v $
	   $Revision: 1.3 $
	   $Author: liu04 $
	   $Locker:  $
	   $State: Exp $

	   $Purpose:

	   $Assumptions:



	   -------------------------------------------------------------------
	                          Modification History
	   -------------------------------------------------------------------
	   $Log: bug.sas,v $
	   Revision 1.3  2009/11/10 06:03:18  liu04
	   save for later change of adding flexibility of handling multiple tot files



	   -------------------------------------------------------------------
	*/
	
	%macro AHGbug(studyid,bugid,qcdoc=temp.qcdoc&studyid,findall=0);
        proc sql ;
        create table nodup as
        select distinct *
        from &qcdoc
        where not missing(filename)
        group by dateframe, fileid, sortid ,datetime
        ;
        create table bugs as
        select *
        from  nodup
        where status  in (0 2 3)
        ;
        create table  solutions as
        select bugs.bugid, bugs.filename,bugs.reason as ori_reason, bugs.version as ori_ver
                   ,nodup.reason as action,nodup.version as fixed_ver
        from  nodup(where=(status=1)) right join  bugs
        on nodup.bugid =bugs.bugid
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
        /*
        %AHGrpipe(%str(cd %trim(&studylink); tabnum2rpt &tabno)  ,rptfile)  ;
        %AHGpm(rptfile);
        |tr -d '\012' '\040'
        */
        %AHGrpipe(%str(cd %trim(&studylink); echo $(tabnum2allrpt &tabno) )  ,rcrpipe)  ;

        %AHGpm(rcrpipe);
        /*execute only when there is one instance for a single table number*/
        %if %AHGcount(%bquote(&rcrpipe),dlm=@)=1 %then
            %do;

            %let rptfile=%qsysfunc(tranwrd(%bquote(&rcrpipe),.tot,.rpt));
            %let rptfile=%qsysfunc(tranwrd(%bquote(&rcrpipe),@,));
            %AHGrpipe(co -r&ori_ver -p &rptfile> &userhome/temp/&tabno.v.&ori_ver..rpt  ,rcrpipe)  ;
            %if &fixed_ver ne %then %AHGrpipe(co -r&fixed_ver -p &rptfile> &userhome/temp/&tabno.v.&fixed_ver..rpt  ,q)  ;
            %else %AHGrpipe(%str(echo no solution ;cp /home/liu04/nosolu.rpt &userhome/temp/&tabno.v.&fixed_ver..rpt  ),q)  ;
    
            %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&ori_ver..rpt,open=1);
            %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&fixed_ver..rpt,open=1);        
            %end;
        /*if do not asked explicitly for all instances*/
        %else %if %AHGcount(%bquote(&rcrpipe),dlm=@)>1 and &findall=0 %then
            %do;
    
            %AHGrpipe(%str(cd %trim(&studylink); tabnum2rpt &tabno)  ,rptfile)  ;
            %AHGpm(rptfile);
            %AHGrpipe(co -r&ori_ver -p &rptfile> &userhome/temp/&tabno.v.&ori_ver..rpt  ,q)  ;
            %if &fixed_ver ne %then %AHGrpipe(co -r&fixed_ver -p &rptfile> &userhome/temp/&tabno.v.&fixed_ver..rpt  ,q)  ;
            %else %AHGrpipe(%str(echo no solution ;cp /home/liu04/nosolu.rpt &userhome/temp/&tabno.v.&fixed_ver..rpt  ),q)  ;
    
            %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&ori_ver..rpt,open=1);
            %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&fixed_ver..rpt,open=1);        
            %end;
        
        %else /*execute only when there were multiple instance for a single table number*/
        %do i=1 %to %AHGcount(%bquote(&rcrpipe),dlm=@);

        %let rptfile=%qscan(%bquote(&rcrpipe),&i,@);
        %AHGpm(rptfile);

        %let rptfile=%sysfunc(tranwrd(%bquote(&rptfile),.tot,.rpt));
        %AHGrpipe(co -r&ori_ver -p %bquote(&rptfile)> &userhome/temp/&tabno.v.&ori_ver..&i..rpt  ,rcrpipe)  ;
        %if &fixed_ver ne %then %AHGrpipe(co -r&fixed_ver -p %bquote(&rptfile)> &userhome/temp/&tabno.v.&fixed_ver..&i..rpt  ,rcrpipe)  ;
        %else %AHGrpipe(%str(echo no solution ;cp /home/liu04/nosolu.rpt &userhome/temp/&tabno.v.&fixed_ver..&i..rpt  ),rcrpipe)  ;

        %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&ori_ver..&i..rpt,open=1);
        %AHGrdowntmp(rpath=&userhome/temp,filename=&tabno.v.&fixed_ver..&i..rpt,open=1);
      
        %end;





	
	%mend;
