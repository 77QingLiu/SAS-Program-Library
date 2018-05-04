	/* -------------------------------------------------------------------
	                          CDARS System Module
	   -------------------------------------------------------------------
	   $Source: /home/liu04/bin/macros/whathappened.sas,v $
	   $Revision: 1.1 $
	   $Author: liu04 $
	   $Locker:  $
	   $State: Exp $

	   $Purpose:

	   $Assumptions:



	   -------------------------------------------------------------------
	                          Modification History
	   -------------------------------------------------------------------
	   $Log: whathappened.sas,v $
	   Revision 1.1  2009/12/08 02:45:53  liu04
	   add from to date



	   -------------------------------------------------------------------
	*/
%macro AHGwhathappened(study=&prot,thedate=/*2008/11/13*/,
fromdate=&thedate 00:00:00,todate=&thedate 23:59:59,
folders=macros.sas analysis.sas program.sasdrvr table.rpt,
morefolders=,
searchfiles=,
open=1,save=0,fullpath=) /secure;

    %if %symexist(batchcompare) %then
        %if &batchcompare=1 %then 
            %do;
           
            %let save=str;
            %let open=0;
            %end;
        

         
    
    %let macroname=&sysmacroname;
    %AHGsavecommandline(&macroname); 
    
    %let study=&study;
    %if %length(%trim(&fromdate))=10 %then %let fromdate=&fromdate 00:00:00;
    %if %length(%trim(&todate))=10 %then %let todate=&todate 23:59:59;
    %AHGstddttm(%str(&fromdate),shift=-8,outdate=fromdate);
    %AHGstddttm(%str(&todate),shift=-8,outdate=todate);
    %let thedate=%sysfunc(compress(&thedate,/));
    %local protlink;
    %let protlink=;
    %AHGreadstudyinfo(&study,outmac=protlink);
    %if %length(&fullpath) %then %let protlink=&fullpath;


    %local i folder ext rstring;
    %do i=1 %to %AHGcount(&folders &morefolders);
        %let folder=%qscan(%qscan(&folders &morefolders,&i,%str( )),1,.);
        %let ext=%qscan(%qscan(&folders &morefolders,&i,%str( )),2,.);
        %AHGpm(folder ext study);
        %if %bquote(&searchfiles) eq %then %let globstr=*.&ext;
        %else  %let globstr=&searchfiles;
        %let globstr=%sysfunc(tranwrd(&globstr,*,\*));
        %let globid=%sysfunc(tranwrd(&searchfiles,*,any));
        
        %let rstring=%str(cmpversionsuper.pl --dir &protlink/&folder --dtfrom "&fromdate" --dtto "&todate" --globstr &globstr  --exclude stoutput.rpt --prefix &study._&thedate&folder._&ext..&globid --checkdt no --checkblank no --collapse no);
        
        
        %AHGrpipe(
        &rstring
        ,
        q
        );
    %if &open=1 %then %AHGrdowntmp(rpath=&userhome/temp,filename=&study._&thedate&folder._&ext..&globid.old.txt,open=&open);;

    %if &open=1 %then %AHGrdowntmp(rpath=&userhome/temp,filename=&study._&thedate&folder._&ext..&globid.new.txt,open=&open);;
    
    %if &save ne 0 %then %AHGrpipe(%str( cat ~/temp/&study._&thedate&folder._&ext..&globid.old.txt >>~/temp/&prot..old.sas),q);;
    %if &save ne 0 %then %AHGrpipe(%str( cat ~/temp/&study._&thedate&folder._&ext..&globid.new.txt >>~/temp/&prot..new.sas),q);;
    %end;
%mend;
