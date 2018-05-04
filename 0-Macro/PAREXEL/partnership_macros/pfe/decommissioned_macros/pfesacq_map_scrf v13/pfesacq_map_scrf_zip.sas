/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Called from parent macro pfesacq_map_scrf:
                         %pfesacq_map_scrf_zip;

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: johnson2 $
  Creation Date:         12FEB2015                       $LastChangedDate: 2016-04-11 17:27:29 -0400 (Mon, 11 Apr 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_map_scrf_zip.sas $
 
  Files Created:         None
 
  Program Purpose:       Create zip file per CAL specifications of compressed 
                         XPT SCRF datasets and CSDWManifiest.xml
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Sources:
 
	1) SACQ SAS datasets located at SAS library TAROUTPUT
	2) CSDWManifest.xml located at file directory referenced by TAROUTPUT
	3) Global macro variable PROTOCOL
	4) Macro variable SEND_TRANSFER - set in parent macro and 
	   %pfesacq_map_scrf_listing macro; specifies to post to CAL or not
	5) Parent macro input parameter PATH_CAL - Specifies root for CAL zip file 
	   placement for transfer and archive
 
  Macro Output:     

    Name:                PAREXEL_&protocol._ClinicalStudyGeneral_&cdatetime..zip
      Type:              zip file
      Allowed Values:    N/A
      Default Value:     N/A
      Description:       Saved to TAROUTPUT location where cdatetime is 
                         YYYYMMDDTHHMNSS if macro variable SEND_TRANSFER = YES 
                         then also copied to &PATH_CAL/transfer/ and 
                         &PATH_CAL/archieve

  Macro Dependencies:    This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2142 $

Version: 1.0 Date: 12FEB2015 Author: Nathan Hartley

Version: 2.0 Date: 27MAR2015 Author: Nathan Hartley
	1) Revised into internal macros call, added download and edata to xpt
	   and zip files

Version: 3.0 Date: 19JUN2015 Author: Nathan Johnson
	1) Cleanup of processing of raw (download) data

Version: 4.0 Date: 29JUN2015 Author: Nathan Johnson
	1) Modify processing of raw data to ensure that no variable names are Oracle
     restricted terms, per Pfizer request. Any variables that have restricted
     names are to be suffixed with "_x"
  2) update program comments

Version: 5.0 Date: 17JUL2015 Author: Nathan Johnson
	1) clean up libraries for validation

Version: 6.0 Date: 18SEP2015 Author: Nathan Johnson
	1) use metadata list of restricted raw data terms using metadata/data/sacq_restricted_terms.sas7bdat
    2) update references to &download to &_download for internal consistency
    3) add code to clean up work directory of temporary datasets
    4) add additional check of parameters

Version: 7.0 Date: 20150114 Author: Nathan Hartley
  1) Changed to use bquote for: %bquote("&_send_transfer") = %bquote("YES")

-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_zip(
	_tarOutput=null,
	_download=null,
	_path_edata=null,
	_manifest=null,
	_protocol=null,
	_cdatetime=null,
	_send_transfer=null,
	_path_cal=null);
	
	%put ---------------------------------------------------------------------;
	%put PFESACQ_MAP_SCRF_ZIP: Start of Submacro;
	%put ---------------------------------------------------------------------;

    options noquotelenmax;
  /*****************************************************************************
  * DEFINE INTERNAL MACRO _zip_setup
  * PURPOSE: Setup input local references and output log macro run message
  *****************************************************************************/
	%macro _zip_setup;

	    * Global MAD macro DEBUG (option statement);
	        proc sql noprint;
	            select count(*) into: _DEBUG_Exist
	            from sashelp.vmacro
	            where scope='GLOBAL'
	                  and name='DEBUG';
	        quit;
	        %if &_DEBUG_Exist = 0 %then %do;
	            * MAD macro DEBUG does not exist, create and set to 0;
	            %global DEBUG;
	            %let DEBUG=0;
	            OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR NOSOURCE NONOTES;
	        %end;
	        %else %do;
	            %if &DEBUG=0 %then %do;
	                OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR NOSOURCE NONOTES;
	            %end;
	            %else %do;
	                OPTION MPRINT MLOGIC SYMBOLGEN SOURCE NOTES;
	            %end;
	        %end;		

	    * Global MAD macro GMPXLERR (unsucessiful execution flag);
	        proc sql noprint;
	            select count(*) into: _GMPXLERR_Exist
	            from sashelp.vmacro
	            where scope='GLOBAL'
	                  and name='GMPXLERR';
	        quit;
	        %if &_GMPXLERR_Exist = 0 %then %do;
	            * MAD macro GMPXLERR does not exist, create and set to 0;
	            %global GMPXLERR;
	            %let GMPXLERR=0;
	        %end;
	        %else %if &GMPXLERR = 1 %then %do;
	            * Parent macro execution unsuccessful, goto end;
	            %put %str(ERR)OR:[PXL] Global macro GMPXLERR = 1, macro not executed;
	            %put ;
	            %goto MacErr;
	        %end;

		%put ;		
        
        * CHECK PARAMETER: PROTOCOL;
        %if %str("&_protocol") = %str("null") %then %do;
            %put %str(ERR)OR:[PXL] Study Protocol parameter not set.;
            %put ;
            %goto MacErr;
        %end;
        
        * CHECK PARAMETER: CDATETIME;
        %if %str("&_cdatetime") = %str("null") %then %do;
            %put %str(ERR)OR:[PXL] Cdatetime parameter not set.;
            %put ;
            %goto MacErr;
        %end;
        
        * CHECK PARAMETER: SEND_TRANSFER;
        %if %bquote("&_send_transfer") = %bquote("null") %then %do;
            %put %str(ERR)OR:[PXL] SEND_TRANSFER parameter not set.;
            %put ;
            %goto MacErr;
        %end;

        * CHECK PARAMETER: PATH_CAL;
        %if %str("&_path_cal") = %str("null") %then %do;
            %put %str(ERR)OR:[PXL] PATH_CAL parameter not set.;
            %put ;
            %goto MacErr;
        %end;
        
    * Get path of library SACQ;
    %let path_sacq=;
    proc sql noprint;
      select left(trim(path)) into: path_sacq
      from (
        select distinct path 
        from sashelp.vlibnam
        where upcase(libname)=upcase("&_tarOutput"));
    quit;
    %let path_sacq=%left(%trim(&path_sacq));

		%let path_download=;
		proc sql noprint;
			select left(trim(path)) into: path_download
			from (
				select distinct path 
				from sashelp.vlibnam
				where upcase(libname)=upcase("&_download"));
		quit;
		%let path_download=%left(%trim(&path_download));		

		%let zipFileName = PAREXEL_&_protocol._ClinicalStudyGeneral_&_cdatetime..zip;	

		%put ;
		%put -------------------------------------------------------------------------------;
		%put Submacro Name: PFESACQ_MAP_SCRF_ZIP.sas;
		%put Parent Macro Name: PFESACQ_MAP_SCRF.sas;
		%put ;
		%put PURPOSE: Compress SACQ, Raw, and Vendor Raw SAS Datasets to XPT files ;
		%put %str(   )for datasets with 1 or more observations ;
		%put %str(   )and zip along with manifest xml file per Pfizer standards ;
		%put %str(   )and copy zip to CAL transfer location ;
		%put %str(   )if the approved conditions are met;
		%put ;
		%put INPUT PARAMETERS: ;
		%put %str(   )1) _tarOutput=&_tarOutput;
		%put %str(   )2) _download=&_download;
		%put %str(   )3) _path_edata=&_path_edata;
		%put %str(   )4) _manifest=&_manifest;
		%put %str(   )5) _protocol=&_protocol;
		%put %str(   )6) _cdatetime=&_cdatetime;
		%put %str(   )7) _send_transfer=&_send_transfer;
		%put %str(   )8) _path_cal=&_path_cal;
		%put ;
		%put OUTPUT: ;
		%put %str(   )1) SAS SACQ XPT Files= &path_sacq/;
		%put %str(   )2) SAS Raw & Vendor Raw XPT Files= &path_sacq/raw;
		%put %str(   )3) Zip File= &path_sacq/;
		%put %str(               ) &zipFileName;
		%put %str(   )4) Zip File copied to CAL? &_send_transfer;
		%put -------------------------------------------------------------------------------;
		%put ;			

		* Read metadata for processing;
		option nonotes; * Suppresses encoding notes in log;
        proc datasets library=sashelp nolist;
            copy out=work;
                select vtable vcolumn vlibnam;
            run;
        quit;
		%if &DEBUG=0 %then %do; option notes; %end;

        %goto MacEnd;
        
		%MacErr:;
            %let GMPXLERR = 1;
        
        %MacEnd:;
        
	%mend _zip_setup;

  
  /*****************************************************************************
  * DEFINE INTERNAL MACRO _zip_sacq
  * PURPOSE: For SACQ datasets, compress to XPT and add to Zip file
  *****************************************************************************/
	%macro _zip_sacq;
		%put ;		
		%put *********************************;
		%put Start of SACQ Datasets Processing;
		%put *********************************;

		proc sql noprint;
            select count(*) into :check_lib
            from work.vlibnam
			where upcase(libname) = upcase("&_tarOutput");
            
			select count(*) into :total_datasets 
			from work.vtable 
			where upcase(libname) = upcase("&_tarOutput");
		quit;
        
        %if %eval(&check_lib = 0) %then %do;
			%put %str(ERR)OR:[PXL] SACQ library "&_tarOutput" does not exist;
            %goto MacErr;
        %end;
        

		%if %eval(&total_datasets > 0) %then %do;
			%put Total SACQ SAS Datasets Found = %left(%trim(&total_datasets));
			proc sql noprint;
				select memname, nobs
					   into :dataset_1-:dataset_%trim(%left(&total_datasets)),
					        :nobs_1-:nobs_%trim(%left(&total_datasets))
				from work.vtable
				where upcase(libname) = upcase("&_tarOutput");
			quit; 

			%do i=1 %to &total_datasets;
				%put Processing SACQ &&dataset_&i with &&nobs_&i obs;
                x "echo ------ Processing SACQ dataset &i of &total_datasets: &&dataset_&i";

				%if %left(%trim(&&nobs_&i)) > 0 %then %do;
					* Compress to XPT;
                    x "echo --------- Compress and add to zip file";
					proc cport data = &_tarOutput..&&dataset_&i
	      				file = "&path_sacq/%lowcase(&&dataset_&i).xpt" ;
	    			run ;

	    			* Add xpt file to zip file;
	    			x "/usr/local/bin/zip -j &path_sacq./&zipFileName &path_sacq/%lowcase(&&dataset_&i).xpt" ; 				
    			%end; 
    			%else %do;
    				%put SACQ &&dataset_&i with 0 obs not sent to Pfizer;
    				%put ;
                    x "echo --------- Ignore: 0 observations";
    			%end;
			%end;		
		%end;
		%else %do;
			%put %str(ERR)OR:[PXL] No SACQ Datasets found under library &_tarOutput;
            %goto MacErr;
		%end;
        
        %goto MacEnd;
        
        %MacErr:;
            %let GMPXLERR = 1;

        %MacEnd:;
	%mend _zip_sacq;


  /*****************************************************************************
  * DEFINE INTERNAL MACRO _zip_download
  * PURPOSE: For DOWNLOAD datasets, compress to XPT and add to Zip file
  *****************************************************************************/
	%macro _zip_download;
		%put ;		
		%put *************************************;
		%put Start of DOWNLOAD Datasets Processing;
		%put *************************************;

		proc sql noprint;
            select count(*) into :check_lib
            from work.vlibnam
			where upcase(libname) = upcase("&_download");
            
			select count(*) into :total_datasets 
			from work.vtable 
			where upcase(libname) = upcase("&_download");
		quit;
        
        %if &check_lib = 0 %then %do;
			%put %str(ERR)OR:[PXL] DOWNLOAD library "&_download" does not exist;
            %goto MacErr;
        %end;
        
        %let total_datasets = %trim(%left(&total_datasets));

        %if %eval(&total_datasets > 0) %then %do;
            * CHECK FOR VARIABLES WITH NAMES THAT ARE RESTRICTED TERMS;
            %put Total DOWNLOAD SAS Datasets Found = &total_datasets;
            
            data checkcolumns;
                length memname name new_name $24.;
                memname = "";
                name = "";
                new_name = "";
                delete;
            run;
                
            proc sql noprint;
                select memname, nobs
                    into :dataset_1-:dataset_&total_datasets,
                    :nobs_1-:nobs_&total_datasets
                from work.vtable
                where upcase(libname) = upcase("&_download");

                create table checkcolumns as
                select memname, name, trim(name) || "_x" as new_name
                from work.vcolumn
                where upcase(libname) = upcase("&_download")
                    and upcase(name) in (select upcase(name) from sacq_md.sacq_restricted_terms)
                ;
            quit;

            %put NOTE:[PXL] The following variables need to be renamed for successful transfer:;
            data _null_;
                set checkcolumns;
                length lineout $500.;
                lineout = strip(memname) || ":  " || strip(name) || " --> " || strip(new_name);
                put lineout;
            run;


            * CYCLE THROUGH RAW DATASETS;
            %do i=1 %to &total_datasets;
                %put Processing DOWNLOAD &&dataset_&i with &&nobs_&i obs;
                x "echo ------ Processing Raw dataset &i of &total_datasets: &&dataset_&i";

                %if %left(%trim(&&nobs_&i)) > 0 %then %do;
                    * check for restricted words;
                    %let countrestricted = 0;
                    proc sql noprint;
                        select count(*) into: countrestricted
                        from checkcolumns
                        where upcase(memname) = "&&dataset_&i"
                        ;
                    quit;

                    x "echo -------- Columns with restricted variable names = &countrestricted";
                    %let rename_restricted = ;
                    %if &countrestricted > 0 %then %do;
                        /* IF THERE ARE RESTRICTVE VARIABLES, GENERATE RENAME SYNTAX
                        AND MAKE A COPY OF THE DATASET, PERFORM RENAMING, AND ZIP */
                        data _null_;
                            set checkcolumns (where=(upcase(memname)=upcase("&&dataset_&i")));
                            length rn $2000.;
                            retain rn;
                            if _n_ = 1 then rn = "(rename=(";
                            rn = strip(rn) || " " || strip(name) || " = " || strip(name) || "_x";

                            call symput('rename_restricted',strip(rn) || "))");
                        run;

                        * rename variables with restricted terms as variable names;
                        data sacq.&&dataset_&i;
                            set &_download..&&dataset_&i &rename_restricted;
                        run;

                        x "echo --------- Compress dataset with renamed variables to xpt";
                        * Compress to XPT;
                        proc cport data = sacq.&&dataset_&i
                            file = "&path_sacq/%lowcase(&&dataset_&i).xpt" ;
                        run ;

                        proc sql noprint;
                            drop table sacq.&&dataset_&i;
                        quit;
                    %end;
                    %else %do;
                        /* OTHERWISE JUST COMPRESS AND ZIP */
                        x "echo --------- Compress dataset to xpt";
                        * Compress to XPT;
                        proc cport data = &_download..&&dataset_&i
                        file = "&path_sacq/%lowcase(&&dataset_&i).xpt" ;
                        run ;
                    %end;


                    * check XPT file against original;/**/
                    filename xptfile "&path_sacq/%lowcase(&&dataset_&i).xpt";

                    x "mkdir &path_sacq/check";
                    libname check "&path_sacq/check";
                    proc cimport infile=xptfile library=check memtype=data;
                    run;                      

                    proc compare noprint base=download.&&dataset_&i compare=check.&&dataset_&i 
                                outdif outnoequal out=check.compare&i;
                    run;

                    %let n_rawdsdiff=99;
                    proc sql noprint;
                        select count(*) into:n_rawdsdiff
                        from sashelp.vtable
                        where libname="CHECK" and index(upcase(memname),"COMPARE") and nobs > 0
                        ;
                    quit;

                    %if &n_rawdsdiff > 0 %then %do;
                        x "echo --------- ISSUE FOUND IN COMPARING RAW DATASET &&dataset_&i TO XPT FILES";
                        %put %str(ERR)OR:[PXL] Raw dataset &&dataset_&i does not match XPT file;
                        %put ;
                        %goto MacErr;
                    %end;
                    %else %do;
                        x "echo --------- Check Successful: Raw Dataset &&dataset_&i matches XPT file";
                        %put Raw dataset &&dataset_&i Matches XPT file;
                    %end;

                    x "rm -r &path_sacq/check";

                    x "echo --------- Add dataset to zip file";
                    * Add xpt file to zip file;
                    x "/usr/local/bin/zip -j &path_sacq./&zipFileName &path_sacq/%lowcase(&&dataset_&i).xpt" ; 				
                    libname check clear;

                %end; 
                %else %do;
                    %put DOWNLOAD &&dataset_&i with &&nobs_&i obs are not sent to Pfizer;
                    x "echo --------- Ignore: 0 observations";
                %end;
            %end;		
        %end;

        %else %do;
            %put %str(ERR)OR:[PXL] No DOWNLOAD Datasets found under library &_download;
            %goto MacErr;
        %end;

        %goto MacEnd;
        
        %MacErr:;
            %let GMPXLERR = 1;

        %MacEnd:;
    
	%mend _zip_download;	


  /*****************************************************************************
  * DEFINE INTERNAL MACRO _zip_edata
  * PURPOSE: For edata (vendor) datasets, get latest files and copy to 
  *          &path_scaq/raw and compress to XPT and add to Zip file;
  *****************************************************************************/
	%macro _zip_edata;
		%put ;		
		%put *************************************;
		%put Start of EDATA Datasets Processing;
		%put *************************************;
    x "echo ------ Processing EDATA datasets in &_path_edata";

		filename dirlist pipe "ls -la &_path_edata" ;

	    data work._dirlist ;
	      length dirline $200 ;
	      infile dirlist recfm=v lrecl=200 truncover ;

	      input dirline $1-200 ;
	      if substr(dirline,1,1) = 'd' ;
	      datec = scan(substr(dirline,59,12),1,' ') ;
	      if index(datec,'.') or datec = ' ' then delete ;
	      date = input(datec,?? yymmdd10.) ;
	      if date = . then do ;
	        ** Some projects use the folder date of Xddmonyyyy, check for these ** ;
	        if length(trim(left(datec))) = 10 then
	          date = input(substr(datec,2),?? date9.) ;
	      end ;
	      if date = . then delete ;
	      format date date9. ;
	    run ;

	    %let _concat = "." ;

	    proc sql noprint ;
	    	select '"' || compress("&_path_edata" || datec) || '"' into :_concat separated by ','
	    	from work._dirlist;
	    quit;

	    libname _edata (&_concat);
	    *libname _raw "&path_sacq/raw";

		proc sql noprint;
			select count(*) into :total_datasets 
			from work.vtable 
			where upcase(libname) = upcase("_edata");
		quit;
		%put Total EDATA SAS Datasets Found = %left(%trim(&total_datasets));

		%if &total_datasets > 0 %then %do;
			proc sql noprint;
				select memname, nobs
					   into :dataset_1-:dataset_%trim(%left(&total_datasets)),
					        :nobs_1-:nobs_%trim(%left(&total_datasets))
				from work.vtable
				where upcase(libname) = upcase("_edata");
			quit; 

			%do i=1 %to &total_datasets;
				%put Processing EDATA &&dataset_&i with &&nobs_&i obs;
        x "echo ------ Processing EDATA dataset &i of &total_datasets: &&dataset_&i";

				%if %left(%trim(&&nobs_&i)) > 0 %then %do;
          /***
					data _raw.&&dataset_&i;
					set _edata.&&dataset_&i;
					run;
          ***/
          
					* Compress to XPT;
          x "echo --------- Compress and add to zip file";
					proc cport data = /***_raw ***/ _edata.&&dataset_&i
	      				file = "&path_sacq/%lowcase(&&dataset_&i).xpt" ;
	    			run ;

	    			* Add xpt file to zip file;
	    			/*** x "/usr/local/bin/zip -j &path_sacq./&zipFileName &path_sacq/raw/%lowcase(&&dataset_&i).xpt" ; 	 ***/
	    			x "/usr/local/bin/zip -j &path_sacq./&zipFileName &path_sacq/%lowcase(&&dataset_&i).xpt" ; 	
        %end;			
        %else %do;
          %put EDATA &&dataset_&i with &&nobs_&i obs are not sent to Pfizer;
          %put ;
          x "echo --------- Ignore: 0 observations";
        %end;
			%end;		
		%end;
		%else %do;
			%put NOTE:[PXL] No EDATA Datasets found under library &_concat;
		%end;	    
	%mend _zip_edata;

  
  /*****************************************************************************
  * DEFINE INTERNAL MACRO _zip_complete
  * PURPOSE: Add CSDWManifest.xml to zip and copy to CAL if _send_transfer=YES
  *****************************************************************************/
	%macro _zip_complete;
		%put ;
		%put *****************************************************************;
		%put Add CSDWManifest.xml to zip and copy to CAL if Send_Transfer=YES;
		%put *****************************************************************;

		* Add SACQManifest.xml to zip file;
        x "echo ------ Add SACQManifest.xml to zip file";
		x "/usr/local/bin/zip -j &path_sacq./&zipFileName &path_sacq./*.xml" ; 

		%put Send_Transfer = &_send_transfer;
		x echo "--- Send_Transfer : %str(&_send_transfer)";
		%put ;
		%if %bquote("&_send_transfer") = %bquote("YES") %then %do;
            x echo "--- Copy Transfer files to &_path_cal";
			x "cp -p &path_sacq./&zipFileName &_path_cal/transfer/";
			x "cp -p &path_sacq./&zipFileName &_path_cal/archive/";
			%put NOTE:[PXL] SACQ Zip file posted to CAL: &path_sacq./&zipFileName;
		%end;
		%else %do;
			%put %str(WARN)ING:[PXL] SACQ Transferred to Pfizer? &send_transfer., transfer zip file not posted to CAL;
		%end;		
	%mend _zip_complete;


	**************************************************************************
    * Macro Process
	**************************************************************************;

	* Local Macros;
	%let path_sacq = ;
	%let path_download = ;
	%let zipFileName = ;

	* Internal Macro Calls;
	%_zip_setup;
	%if &GMPXLERR = 1 %then %goto MacErr;

	%_zip_sacq;
	%if &GMPXLERR = 1 %then %goto MacErr;

	%_zip_download;
	%if &GMPXLERR = 1 %then %goto MacErr;	
  
  /*
  %_zip_edata;
	%if &GMPXLERR = 1 %then %goto MacErr;	
  */
  
	%_zip_complete;

	**************************************************************************
    * End of Macro
	**************************************************************************;

	%put ;
	%goto MacEnd;

	%MacErr:;
	%put %str(ERR)OR:[PXL] ---------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_ZIP: Abnormal end to program. Review Log.;
	%put %str(ERR)OR:[PXL] ---------------------------------------------------------------------;
    x "echo --- Abnormal end to program.";

	%MacEnd:;	
    /* CLEAN UP */
    /*
    %macro delds(wds=null,type=DATA);
        %put ---- CLEAN UP: check if talbe WORK.&wds exists;
        %if %sysfunc(exist(&wds, "&type")) %then %do; 
            proc datasets lib=work nolist; 
                delete &wds / memtype=&type; 
                run;
            quit;
            %put ---- CLEAN UP: remove table WORK.&wds;            
        %end; 
    %mend delds;
    
    %delds(wds=CHECKCOLUMNS);
    %delds(wds=VCOLUMN,type=VIEW);
    %delds(wds=VTABLE,type=VIEW);              
    %delds(wds=VLIBNAM,type=VIEW);              
    */
    options quotelenmax;
    
	%put ---------------------------------------------------------------------;
	%put PFESACQ_MAP_SCRF_ZIP: End of Submacro;
	%put ---------------------------------------------------------------------;
    
    
%mend pfesacq_map_scrf_zip;