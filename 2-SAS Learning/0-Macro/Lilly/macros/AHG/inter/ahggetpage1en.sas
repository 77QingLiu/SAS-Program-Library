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
	
	%macro AHGgetpage1en(n=,mask=0,sometot=);
        %local alltot i;
        %if %length(&sometot) %then %let rcrpipe=&sometot;
        %else %AHGrpipe(ordtot.pl --dir &root3,rcrpipe);
        
        %let alltot=%sysfunc(tranwrd(&rcrpipe,.tot,.rpt)); 

        %AHGpm(alltot);
        %AHGrpipe(test -e &userhome/temp/&prot._ts.txt %nrstr(&&)rm -f &userhome/temp/&prot._ts.txt,q);
        %AHGrpipe(echo Table shell >&userhome/temp/&prot._ts.txt,q);
        %AHGrpipe(test -e &userhome/temp/&prot._alltitles.txt %nrstr(&&)rm -f &userhome/temp/&prot._alltitles.txt,q);
        %if &n eq %then %let n=%AHGcount(&alltot); 

        %do  i=1 %to   &n;
             %LOCAL TOT TOTNAME;
             %let tot=%qscan(&alltot,&i,%str( )) ;
             %LET TOTNAME=%scan(&tot,1).tot;
             %let cmdstr=%str( page1and2.pl --file &root3/table/&tot --rand &prot ; sed -n "1,3p" &userhome/temp/&prot.page1.txt | sed "s/ *Page x of n/               &totNAME/">>&userhome/temp/&prot._alltitles.txt;);
             %let cmdstr=%str( &cmdstr  cat &userhome/temp/&prot.page1.txt|grep -i 'source *data:'|sed  "s/.*\(Source Data: [^\s]* \)Date.*/\1/" >>&userhome/temp/&prot._alltitles.txt ;);
             %let cmdstr=%str( &cmdstr  echo ' ' >>&userhome/temp/&prot._alltitles.txt ;);
             %let cmdstr=%str( &cmdstr  cat  /home/liu04/pagebreak.txt &userhome/temp/&prot.page1.txt >>&userhome/temp/&prot._ts.txt ;);
             
             %AHGsubmitRcommand(cmd=&cmdstr);    
        %end;

        %let cmdstr=%str( cat &userhome/temp/&prot._alltitles.txt  &userhome/temp/&prot._ts.txt >&userhome/temp/&prot._ts_draft.txt ;mv -f &userhome/temp/&prot._ts_draft.txt &userhome/temp/&prot._ts.txt ;);
             %AHGsubmitRcommand(cmd=&cmdstr); 
              
        %if &mask=1 %then %AHGsubmitRcommand(cmd=%str(masknum.pl --file &userhome/temp/&prot._ts.txt --out &userhome/temp/&prot._maskts.txt ));
        %AHGrdown(rpath=&userhome/temp/*Remote path*/
        ,filename=%if &mask=1 %then &prot._maskts.txt; %else &prot._ts.txt;
        ,locpath=&projectpath\analysis
        ,open=1
        ,binary=);        
        %exitdoor:
	%mend;

