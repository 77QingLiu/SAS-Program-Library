	/* -------------------------------------------------------------------
	                          CDARS System Module
	   -------------------------------------------------------------------
	   $Source: /home/liu04/bin/macros/rdown.sas,v $
	   $Revision: 1.4 $
	   $Author: liu04 $
	   $Locker:  $
	   $State: Exp $

	   $Purpose:

	   $Assumptions:



	   -------------------------------------------------------------------
	                          Modification History
	   -------------------------------------------------------------------
	   $Log: rdown.sas,v $
	   Revision 1.4  2011/09/21 06:02:47  liu04
	   update

	   Revision 1.2  2009/12/07 01:44:12  liu04
	   add option for open and iteration



	   -------------------------------------------------------------------
	*/
%macro AHGrdown
            (folder=macros,
             path=&projectpath,
             filename=,
             excludedfiles=,
             rlevel=3,
             rpath=&&root&rlevel%str(/)&folder ,
             type=  ,
             temp=&localtemp\&sysmacroname.&prot..sas,
	         binary=,
	         locpath=&projectpath\&folder,
	         open=0,
	         save=1,
	         version=,
             verOffset=,
             tailor=0,
	         downfirst=yes 
			 ,wash=0
			 ,rename=0
);
  /*if rpath is not set explicitly then decide rpath by rlevel*/

    %local macroname;
    %let macroname=&sysmacroname;
    %if &save=1 %then %AHGsavecommandline(&macroname);

  %macro inner(filename);
  %local isDSN ext;

  %if %index(%str( )%upcase(&excludedfiles)%str( ),%str( )%upcase(&filename)%str( )) %then %goto InnerExit;
  %if %length(&verOffset) %then
      %do;
      %AHGfilever(%str(&rpath/&filename),outmac=currversion);
      %AHGpm(currversion);
      %let version=%AHGverCalc(&currversion,&verOffset);
      %AHGpm(version);

      %end;
  %AHGrpipe(%str(test -e &rtemp/&filename,v    %nrstr(&&)  rm -f &rtemp/&filename,v )  ,q )  ;
  %AHGrpipe(%str(test -e &rtemp/&filename    %nrstr(&&)  rm -f &rtemp/&filename )  ,q )  ;
  %AHGrpipe(%str(test -e &rpath/RCS/&filename,v    %nrstr(&&)  cp -f &rpath/RCS/&filename,v &rtemp/ )  ,q )  ;
  %AHGrpipe(%str(test -e &rpath/&filename    %nrstr(&&)  cp -f &rpath/&filename &rtemp/ )  ,q )  ;
   %if &version ne %then %AHGrpipe(%str(co -r%left(&version)    &rtemp/&filename )   ,q)  ;
 
  

  data _null_;

  %local rfinalpath;
  %let rfinalpath=&rtemp;
/*  %if &version ne %then %let rfinalpath=&rtemp;*/
/*  %else  %let rfinalpath=&rpath;*/

  %if %index(&filename,.rpt)  and &tailor=1 %then
  %do;

  %AHGrpipe(%str(cp -f &rfinalpath/&filename &rtemp/&filename.tmp) ,q);
  %let rfinalpath=&rtemp;
  %AHGrpipe(%str(tailorpages.pl --file &rtemp/&filename.tmp --finalpages &rtemp/&filename) ,q);
  %end;
  
  %if %index(&filename,.rpt)  and %index(&tailor,:)  %then
  %do;

  %AHGrpipe(%str(cp -f &rfinalpath/&filename &rtemp/&filename.tmp) ,q);
  %let rfinalpath=&rtemp;
  %AHGrpipe(%str(tailorpages.pl --removecolumns "&tailor" --file &rtemp/&filename.tmp --finalpages &rtemp/&filename) ,q);
  %end;  
  
  file "&temp";

  %if %lowcase(&type)=dsn or (%scan(&filename,2,.)=sas7bdat and %scan(&filename,3,.) ne diff)  %then
    %do;
	%let isDsn=1;
	%let ext=.sas7bdat;
    %let filename=%scan(&filename,1,.);
    %let locfile=%sysfunc(tranwrd(&filename,:,.));
    %if  %length(&version) %then  %let locfile=ver&version%sysfunc(tranwrd(&filename,:,.));
    %let locfile=%sysfunc(tranwrd(&locfile,.,_));
    put "libname ldsnpath v9 ""&locpath"" ; ";
    put "rsubmit;";
    put "libname rdsnpath ""&rfinalpath"" ; ";

    put "proc download data=rdsnpath.&filename  " ;
	put "            out=ldsnpath.&locfile ; "

   ;
    put "run ; ";
    put "endrsubmit;";
    run;

    %let locfile=&locfile..sas7bdat;
    %end;
  %else
    %do;
    %if %index(&filename,:) %then  %let locfile=%sysfunc(tranwrd(&filename,:,.)).log;
    %else %let locfile=&filename;
    %if  %length(&version) %then  %let locfile=ver&version&locfile;
    put "filename locpath ""&locpath"" lrecl=32767; ";
    put "rsubmit;";
	%if %scan(&filename,2,.)=rpt or  &wash=1 %then 	
	%do;
	%AHGrpipe(%str(test -e &rtemp/&filename..q    %nrstr(&&)  rm -f &rtemp/&filename..q )  ,q )  ;
	%AHGrpipe(%str(removeq  &rtemp/&filename > &rtemp/&filename..q) ,q);
	%AHGrpipe(%str(mv -f &rtemp/&filename..q  &rtemp/&filename) ,q);
	%end;

    put "filename rlib   ""&rfinalpath/&filename"" lrecl=32767; ";

    put "proc download infile=rlib &binary  " ;
    %if not &rename  %then  put "            outfile=locpath(""&locfile"") &binary; ";
    %else put "            outfile=locpath(""&locfile..log"") &binary; ";
    ;
    put "run ; ";
    put "endrsubmit;";
    run;
    %end;


  %if &downfirst=yes %then %include "&temp";;
   %AHGrpipe(%str(test -e &rtemp/&filename&ext,v    %nrstr(&&)  rm -f &rtemp/&filename&ext,v ),q   )  ;
   %AHGrpipe(%str(test -e &rtemp/&filename&ext    %nrstr(&&)  rm -f &rtemp/&filename&ext )  ,q )  ;
   %AHGrpipe(%str(test -e &rtemp/&filename&ext..q    %nrstr(&&)  rm -f &rtemp/&filename&ext..q )  ,q )  ;

  option noxsync noxwait;
  %if &open= 1 %then %AHGopenfile(&locpath\&locfile);
  %if  &rename %then %AHGopenfile(&locpath\&locfile..log);

  %global rdownfiles;
  %let rdownfiles=&rdownfiles + &locpath\&locfile;


  option xsync ;
  %innerExit:;

  %mend;
%local i allfilename;
%let allfilename=&filename;
%do i=1 %to %AHGcount(&allfilename);

    %let filename=%scan(&allfilename,&i,%str( ));
    %if &rlevel=0 or &rlevel=1 or &rlevel=2 or  &rlevel=3 %then
        %do;
        %global allfile;
        %let allfile=;
        %AHGrpipe(%str(allfile=$(ls &rpath/&filename |sed ""s/.*\///""); echo $allfile ),allfile)  ;
        %AHGfuncloop(%nrbquote(    inner(ahuige)     ),
        loopvar=ahuige,loops=&allfile

        );
        %end;

    %if &rlevel=all %then
        %do;
          %AHGrpipe(%str( rpipeout='0';test -f &root0%str(/)&folder/&filename %nrstr(&&) rpipeout=1;echo $rpipeout ),filethere0)  ;
          %if  &filethere0 eq 1 %then %let rlevel=0;
          %AHGrpipe(%str( rpipeout='0';test -f &root1%str(/)&folder/&filename %nrstr(&&) rpipeout=1;echo $rpipeout ),filethere1)  ;
          %if  &filethere1 eq 1 %then %let rlevel=1;
          %AHGrpipe(%str( rpipeout='0';test -f &root2%str(/)&folder/&filename %nrstr(&&) rpipeout=1;echo $rpipeout ),filethere2)  ;
          %if  &filethere2  eq 1 %then %let rlevel=2;
          %AHGrpipe(%str( rpipeout='0';test -f &root3%str(/)&folder/&filename %nrstr(&&) rpipeout=1;echo $rpipeout ),filethere3)  ;
          %if  &filethere3 eq 1 %then %let rlevel=3;
          %let rpath=&&root&rlevel%str(/)&folder ;

          %let allfile=&filename;
        %AHGfuncloop(%nrbquote(    inner(ahuige)     ),
        loopvar=ahuige,loops=&allfile

        );
        %end;
%end;
%mend;
