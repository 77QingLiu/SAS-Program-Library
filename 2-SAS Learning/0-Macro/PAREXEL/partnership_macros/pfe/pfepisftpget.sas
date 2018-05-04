/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20150820       $LastChangedDate: 2015-08-20 11:07:46 -0400 (Thu, 20 Aug 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfepisftpget.sas $
 
  Files Created:         1) Global Macro Variable: pfepisftpget_PassOrFail - PASS or FAIL
                         2) Global Macro Variable: pfepisftpget_FailMsg - If FAIL, then message as to details why failed
                         3) Unzipped ASCII and SAS XPT files saved to input parameter outputDir location
 
  Program Purpose:       Purpose of this macro is to:
                         1) Connect to PI SFTP and download the latest <protocol>_ASCII_LIVE_<isodatetime>.zip and
                            <protocol>_SAS_LIVE_<isodatetime>.zip files and unzip

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has not been validated for use only in PAREXEL's
                         working environment yet.
 
  Macro Parameters:
 
    Name:                _pxl_code
      Allowed Values:    PAREXEL study number of leave blank
      Default Value:     null
      Description:       PAREXEL study number or will try to get the value from global macro PXL_CODE
 
    Name:                _protocol
      Allowed Values:    Pfizer protocol number
      Default Value:     null
      Description:       Pfizer protocol number or will try to get the value from global macro PROTOCOL
 
    Name:                pi_code
      Allowed Values:    PI Study code
      Default Value:     null
      Description:       PI Study code, location for HTTP server connection

    Name:                pisftp_username
      Allowed Values:    Users PI SFTP user name login or leave null
      Default Value:     null
      Description:       User can enter their own PI SFTP login name if they have one or can leave blank 
                         to read from standards config file

    Name:                pisftp_password
      Allowed Values:    Users PI SFTP password or leave null
      Default Value:     null
      Description:       User can enter their own PI SFTP password if they have one or can leave blank 
                         to read from standards config file

    Name:                pfepisftpget_pisftp_metadata
      Allowed Values:    Kennet directory that holds formated config file
      Default Value:     /projects/std_pfizer/sacq/metadata/data/pi_sftp.config
      Description:       Holds a text file in a certain format to read a PI SFTP login and encrypted
                         password to PI SFTP study locations

    Name:                dayspast
      Allowed Values:    Number 1 to 100
      Default Value:     2
      Description:       A number for range search to look for latest zip files

    Name:                outputDir
      Allowed Values:    A valid Kennet UNIX directory
      Default Value:     null
      Description:       Location to save retreived zip files and to unzip too

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 986 $

Version: 1.0 Date: 20150820 Author: Nathan Hartley

-----------------------------------------------------------------------------*/

%macro pfepisftpget(
	_pxl_code=null,
	_protocol=null,
	pi_code=null, 
	pisftp_username=null, 
	pisftp_password=null,
	pfepisftpget_pisftp_metadata = /projects/std_pfizer/sacq/metadata/data/pi_sftp.config,
	dayspast=2,
	outputDir=null);

	%put ***********************************************************************;
	%put Macro Startup;
	%put ***********************************************************************;
		* Macro Variable Declarations;
			%let pfepisftpget_MacroName        = PFEPISFTPGET;
			%let pfepisftpget_MacroVersion     = 1.0;
			%let pfepisftpget_MacroVersionDate = 20150820;
			%let pfepisftpget_MacroPath        = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
			%*let pfepisftpget_MacroPath        = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
			%let pfepisftpget_RunDateTime      = %sysfunc(compress(%sysfunc(left(%sysfunc(datetime(), IS8601DT.))), '-'));

			* Global return macros;
			%global pfepisftpget_PassOrFail pfepisftpget_FailMsg;
			%let pfepisftpget_PassOrFail = FAIL; * PASS or FAIL;
			%let pfepisftpget_FailMsg = null; * If FAIL, message for failure;	

			* Internal use macros;
			%let nbsp=%nrstr(&nbsp);	

			%let ascii_zip_filename = ;
			%let sas_zip_filename = ;	

			%put INFO:[PXL]----------------------------------------------;
			%put INFO:[PXL] &pfepisftpget_MacroName: Macro Started; 
    		%put INFO:[PXL] File Location: &pfepisftpget_MacroPath ;
    		%put INFO:[PXL] Version Number: &pfepisftpget_MacroVersion ;
    		%put INFO:[PXL] Version Date: &pfepisftpget_MacroVersionDate ;
			%put INFO:[PXL] Run DateTime: &pfepisftpget_RunDateTime;    		
    		%put INFO:[PXL] ;
    		%put INFO:[PXL] Purpose: Compare SAS Structure against last approved transfer ;          	
			%put INFO:[PXL] Input Parameters:;
			%put INFO:[PXL]		1) _pxl_code = &_pxl_code;
			%put INFO:[PXL]		2) _protocol = &_protocol;
			%put INFO:[PXL]		3) pi_code = &pi_code;
			%put INFO:[PXL]		4) pisftp_username = &pisftp_username;
			%put INFO:[PXL]		5) pisftp_password = &pisftp_password;
			%put INFO:[PXL]		6) pfepisftpget_pisftp_metadata = &pfepisftpget_pisftp_metadata;
			%put INFO:[PXL]		7) dayspast = &dayspast;
			%put INFO:[PXL]		8) outputDir = &outputDir;
			%put INFO:[PXL]----------------------------------------------;			

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
	        %end;
	        %else %do;
	            %if &DEBUG=0 %then %do;
	                OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN;
	                %* OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOSOURCE NONOTES;
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
	            %put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: Global macro GMPXLERR = 1, macro not executed;
	            %put ;
	            %goto MacErr;
	        %end;

	%put ***********************************************************************;
	%put Verify and Set Parameters;
	%put ***********************************************************************;

		* Macro can only be run in sas92 or sas93;
			%if &SYSVER = 9.1 %then %do;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: Run from SAS91 but can only be run from SAS92 or SAS93;
				%let pfepisftpget_FailMsg = Run from SAS91 but can only be run from SAS92 or SAS93;
	            %goto MacErr;	
			%end;

		* _PXL_CODE;
			%if %str("&_pxl_code") = %str("null") %then %do;
				* If not set, use global macro pxl_code if exists;
				proc sql noprint;
					select count(*) into: cnt
					from sashelp.vmacro
					where scope = "GLOBAL"
					      and name = "PXL_CODE";
				quit;
				%if %eval(&cnt = 0) %then %do;
					* Global macro not found, exit macro;
					%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: Input Parameter _pxl_code is null and global macro pxl_code not found;
					%let pfepisftpget_FailMsg = Input Parameter _pxl_code is null and global macro pxl_code not found;
	            	%goto MacErr;					
				%end;
				%else %do;
					* Global macro found, use it;
					%let _pxl_code = &_pxl_code;
				%end;
			%end;
			%put _PXL_CODE = &_PXL_CODE;

		* _PROTOCOL;
			%if %str("&_protocol") = %str("null") %then %do;
				* If not set, use global macro protocol if exists;
				proc sql noprint;
					select count(*) into: cnt
					from sashelp.vmacro
					where scope = "GLOBAL"
					      and name = "PROTOCOL";
				quit;
				%if %eval(&cnt = 0) %then %do;
					* Global macro not found, exit macro;
					%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: Input Parameter _protocol is null and global macro protocol not found;
					%let pfepisftpget_FailMsg = Input Parameter _protocol is null and global macro protocol not found;
	            	%goto MacErr;					
				%end;
				%else %do;
					* Global macro found, use it;
					%let _protocol = &pxl_code;
				%end;
			%end;

			%if %str("&pi_code") = %str("null") %then %do;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: Input Parameter pi_code is null and is required;
				%let pfepisftpget_FailMsg = Input Parameter pi_code is null and is required;
	            %goto MacErr;
			%end;
			%put _PROTOCOL = &_PROTOCOL;

		* PI SFTP LOGIN;
			* If pi login info not given, get from metadata;
			%if %str("&pisftp_username") = %str("null")
				and %str("&pisftp_password") = %str("null") %then %do;

				* Check if metadata file exists;
				%if not %sysfunc(fileexist(&pfepisftpget_pisftp_metadata)) %then %do;
					%let pfepisftpget_FailMsg = PI SFTP login metadata file not found: &pfepisftpget_pisftp_metadata;
					%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
	            	%goto MacErr;
				%end;

				* Metadata file exists - check if login info exist;
			        data _null_; delete; run;
			        %put pfepisftpget_pisftp_metadata = &pfepisftpget_pisftp_metadata;
			        filename cf "&pfepisftpget_pisftp_metadata";
			        data _null_;
			            infile cf lrecl=200 truncover;
			            input log_message $200.;

			            if index(log_message, "pisftp_username =") > 0 then do;
			                call symput('pisftp_username',scan(log_message, 2, '='));
			            end;
			            if index(log_message, "pisftp_password =") > 0 then do;
			                call symput('pisftp_password',scan(log_message, 2, '='));
			            end;			            
			        run;
					%let pisftp_username = %left(%trim(&pisftp_username));
					%let pisftp_password = %left(%trim(&pisftp_password));
			        %*put pisftp_username = &pisftp_username;
			        %*put pisftp_password = &pisftp_password;

					%if %str("&pisftp_username") = %str("null")
						or %str("&pisftp_password") = %str("null") %then %do;

						%let pfepisftpget_FailMsg = Input Parameter pisftp_username or pisftp_password is null from: &pfepisftpget_pisftp_metadata;
						%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
		            	%goto MacErr;
					%end;
			%end;
			%else %do;
				* Use PI SFTP login info from input parameters if both present;
				%if %str("&pisftp_username") = %str("null")
					or %str("&pisftp_password") = %str("null") %then %do;

					%let pfepisftpget_FailMsg = Input Parameter pisftp_username or pisftp_password is null;
					%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
	            	%goto MacErr;
				%end;
			%end;

		* dayspast;
			* dayspast needs to be a number;
			%let _pass = FAILED;
			data _null_;
				raw = symget('dayspast');

				num = input(raw,?? 8.);
				if not missing(num) then num2 = int(num);

				if not missing(num2) 
				   and num = num2 
				   and num2 >= 1
				   and num2 <= 100
				   then do;
					* input value  is a whole number between 1 and 100;
					call symput('_pass','PASSED');
				end;
				else do;
					call symput('_pass','FAILED');
				end;
			run;

			%if %str("&_pass") = %str("FAILED") %then %do;
				%let pfepisftpget_FailMsg = Input Parameter dayspast is not whole number between 1 and 100: &dayspast;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
	            %goto MacErr;
			%end;

		* outputDir;
			* Check if outputDir exists;
			%if not %sysfunc(fileexist(&outputDir)) %then %do;
				%let pfepisftpget_FailMsg = Input Parameter outputDir does not specify a valid directory: &outputDir;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
	            %goto MacErr;
			%end;		

	%put ***********************************************************************;
	%put Get Zip Files off PI SFTP;
	%put ***********************************************************************;
		%put 1) Get list of files from PI SFTP;
			* Clear temp.html if exists;
			%sysexec %str(rm -rf temp.html);

			* Connect to PI SFTP and save list of files present to temp html file;
			filename tempfile "temp.html";
			proc http 
			   	method='get' 
			   	url="https://parexel-ftp.edc.perceptive.com/%upcase(&pi_code)/Outbound/Exports/AdvancedExports/"
			   	webusername="&pisftp_username" 
			   	webpassword="&pisftp_password"
			   	out=tempfile;
			run;

			* Check if temp.html was created;
			%if not %sysfunc(fileexist(temp.html)) %then %do;
				%let pfepisftpget_FailMsg = %str(ERR)OR in connecting to PI SFTP and getting temp.html list of files. Check login and PI Code.;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
				%goto MacErr;
			%end;

			* Get list of filenames and datetime of files that exist in PI SFTP that have &protocol._LIVE_ in name;
			data sftpFileList(keep=filename datetime);
			   	length filename $50.;
			   	format datetime B8601DT.;
				infile tempfile lrecl=30000;
				input col1 $30000.;

			   	* Cycle through each record and output each file name
			      file names must be in format of ANNNNNNN_LIVE_<ASCII or SAS>_YYYYMMDDTHHMMSS;
			   	do i=1 to length(col1);
			    	if i=1 then inflag=0;

			      	if length(col1) >= (i + 14) then do;
			        	if substr(col1,i,14) = "&_protocol._LIVE_" then do;
			            	inflag=1;
			               	filename="";
			         	end;
			      	end;

				    if inflag = 1 then do;
				        if substr(col1,i,1) = "<" then do;
				            filename = compress(filename,'.zip');
				            if substr(filename,15,3) = "SAS" then do;
				            	datetime = input(substr(filename,19),?? B8601DT.);
				            end;
				            else if substr(filename,15,5) = "ASCII" then do;
				            	datetime = input(substr(filename,21),?? B8601DT.);
				            end;
				            if datetime ne . then output;
				            inflag=0;
				        end;
			         	else do;
			            	filename = catt(filename,substr(col1,i,1));
			        	end;
			    	end;
				end;
			run;

		%put 2) Get latest dated file for ASCII and SAS that is within %left(%trim(&dayspast)) days;

			* Get latest ASCII zip dated file that is within &dayspast days of current date;
			proc sql noprint;
			   select b.filename into: ascii_zip_filename
			   from (select max(datetime) as datetime from sftpFileList where substr(filename,15,5) = "ASCII") as a 
			        inner join
			        (select * from sftpFileList where substr(filename,15,5) = "ASCII") as b 
			   on a.datetime = b.datetime
			   where datepart(today()) - datepart(b.datetime) <= &dayspast;
			quit;
			%put Latest ASCII zip filename found: %left(%trim(&ascii_zip_filename)).zip;

			* If file does not exist, exit;
			%if &ascii_zip_filename = %str() %then %do;
				%let pfepisftpget_FailMsg = No PI SFTP Zip file for <protocol>_LIVE_ASCII_YYYYMMDDTHHMMSS.zip found for a date within &dayspast days;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
				%goto MacErr;
			%end;

			* Get latest SAS zip dated file that is within &dayspast days of current date;
			proc sql noprint;
			   select b.filename into: sas_zip_filename
			   from (select max(datetime) as datetime from sftpFileList where substr(filename,15,3) = "SAS") as a 
			        inner join
			        (select * from sftpFileList where substr(filename,15,3) = "SAS") as b 
			   on a.datetime = b.datetime
			   where datepart(today()) - datepart(b.datetime) <= &dayspast;
			quit;
			%put Latest SAS zip filename found: %left(%trim(&sas_zip_filename)).zip;   

			* If file does not exist, exit;
			%if &sas_zip_filename = %str() %then %do;
				%let pfepisftpget_FailMsg = No PI SFTP Zip file for <protocol>_LIVE_SAS_YYYYMMDDTHHMMSS.zip found for a date within &dayspast days;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
				%goto MacErr;
			%end;

		%put 3) Download the zip files into the kennet location;

			* Download the ascii file;
			%let asciiZip = &outputDir/%left(%trim(&ascii_zip_filename)).zip;
			filename fascii "&asciiZip";
			proc http 
			   method='get' 
			   url="https://parexel-ftp.edc.perceptive.com/%upcase(&pi_code)/Outbound/Exports/AdvancedExports/%left(%trim(&ascii_zip_filename)).zip"
			   webusername="&pisftp_username" 
			   webpassword="&pisftp_password"
			   out=fascii ;
			run;

			* Verify file downloaded;
			%if not %sysfunc(fileexist(&asciiZip)) %then %do;  
				%let pfepisftpget_FailMsg = Unknown %str(ERR)OR in downloading %left(%trim(&ascii_zip_filename)).zip;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
				%goto MacErr;              
			%end;

			* Download the xpt file;
			%let sasZip = &outputDir/%left(%trim(&sas_zip_filename)).zip;
			filename fsas "&sasZip";
			proc http 
			   method='get' 
			   url="https://parexel-ftp.edc.perceptive.com/%upcase(&pi_code)/Outbound/Exports/AdvancedExports/%left(%trim(&sas_zip_filename)).zip"
			   webusername="&pisftp_username" 
			   webpassword="&pisftp_password"
			   out=fsas ;
			run;

			* Verify file downloaded;
			%if  not %sysfunc(fileexist(&&sasZip)) %then %do;  
				%let pfepisftpget_FailMsg = Unknown %str(ERR)OR in downloading %left(%trim(&sas_zip_filename)).zip;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
				%goto MacErr;               
			%end;  

		%put 4) Unzip Downloaded Zip Files;
            %sysexec %str(unzip -o &asciiZip -d &outputDir >/dev/null);
            %sysexec %str(unzip -o &sasZip -d &outputDir >/dev/null);

        %put 5) Verify at least 1 .sas7bdat and 1 .txt file has been created;

            * Get list of files in unzipped directory;
            filename dirlist pipe "ls -la %left(%trim(&outputDir))" ;

            * Get count of txt and xpt files found in directory;
            %let cnt_txt = 1;
            %let cnt_xpt = 1;
            data work._dirlist ;
				length dirline dirline2 $200 ;
				infile dirlist recfm=v lrecl=200 truncover end=eof;
				input dirline $1-200 ;
				dirline2 = substr(dirline,59);
				retain cnt_txt cnt_xpt;
				if _n_ = 1 then do;
					cnt_txt = 1; 
					cnt_xpt = 1;
				end;
				else do;
					if index(dirline2,'.txt') > 0 then cnt_txt = cnt_txt + 1;
					if index(dirline2,'.xpt') > 0 then cnt_xpt = cnt_xpt + 1;
				end;
				if eof then do;
					call symput('cnt_txt',left(trim(put(cnt_txt,8.))));
					call symput('cnt_xpt',left(trim(put(cnt_xpt,8.))));
				end;
            run; 

            * Ensure at least 1 txt and 1 xpt file;
            %if &cnt_txt = 0 %then %do;
				%let pfepisftpget_FailMsg = Unknown %str(ERR)OR in unzipping &path_dir%left(%trim(&ascii_zip_filename)).zip;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
				%goto MacErr;  
            %end;
            %if &cnt_xpt = 0 %then %do;
				%let pfepisftpget_FailMsg = Unknown %str(ERR)OR in unzipping &path_dir%left(%trim(&sas_zip_filename)).zip;
				%put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: &pfepisftpget_FailMsg;
				%goto MacErr;
            %end;

        %let pfepisftpget_PassOrFail = PASS;

	%put ***********************************************************************;
	%put Macro End;
	%put ***********************************************************************;
	    %goto MacEnd;
	    %MacErr:;
	    %put %str(ERR)OR:[PXL] ---------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: Abnormal end to macro;
	    %put %str(ERR)OR:[PXL] &pfepisftpget_MacroName: See log for details;
	    %put %str(ERR)OR:[PXL] ---------------------------------------------------;
	    %let GMPXLERR=1;

		%MacEnd:;

		%macro delmac(wds=null);
            %if %sysfunc(exist(&wds)) %then %do; 
                proc datasets lib=work nolist; delete &wds; quit; run; 
            %end; 
        %mend delmac;
        %delmac(wds=SFTPFILELIST);
        %delmac(wds=_DIRLIST);

		%put ;
		%put INFO:[PXL]----------------------------------------------;
		%put INFO:[PXL] &pfepisftpget_MacroName: Macro Completed; 
		%put INFO:[PXL] Output: ;
		%put INFO:[PXL]   1) pfepisftpget_PassOrFail = &pfepisftpget_PassOrFail;
		%put INFO:[PXL]   2) pfepisftpget_FailMsg = &pfepisftpget_FailMsg;
		%put INFO:[PXL]   3) Output Directory: &outputDir;
		%put INFO:[PXL]      1) ASCII Zip File Unzipped: %left(%trim(&ascii_zip_filename)).zip;
		%put INFO:[PXL]      2) SAS XPT Zip File Unzipped: %left(%trim(&sas_zip_filename)).zip;
		%put INFO:[PXL]----------------------------------------------;
		%put ;

%mend pfepisftpget;