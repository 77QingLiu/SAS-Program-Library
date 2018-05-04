/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: johnson2 $
  Creation Date:         20160818       $LastChangedDate: 2016-10-04 17:31:06 -0400 (Tue, 04 Oct 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_csdw_auto.sas $
 
  Files Created:         1) SACQ Datasets
                         2) Log Check Listings
                         3) Structure Differences Listing
                         4) Zip files of older SACQ directories
                         5) Ongoing Log Check Listings
                         6) SACQ Transfer Report
                         7) Metadata Update for Transfer
                         8) Email of Transfer Status
 
  Program Purpose:       Purpose of this macro is to: <br />
                         1) Run CSDW to SACQ Transfers

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has not been validated for use only in PAREXEL's
                         working environment yet.
 
  Macro Parameters:
 
    Name:                In_PXL_Code
      Allowed Values:    Valid Study PAREXEL code
      Default Value:     null
      Description:       Valid Study PAREXEL code, if null will attempt to get from global macro PXL_CODE

    Name:                In_Protocol
      Allowed Values:    Valid Study PFIZER protocol
      Default Value:     null
      Description:       Valid Study PFIZER protocol, if null will attempt to get from global macro PROTOCOL

    Name:                In_ForceRun
      Allowed Values:    YES|NO
      Default Value:     NO
      Description:       Force run, otherwise will run SACQ transfer only if source data later than 
                         last SACQ data

    Name:                Path_SACQRoot
      Allowed Values:    Valid KENNT directory
      Default Value:     null
      Description:       Root SACQ kennet directory to store mapped SACQ dated YYYYMMDD 
                         directories per transfer

    Name:                Path_SCRFRoot
      Allowed Values:    Valid KENNT directory
      Default Value:     null
      Description:       Root kennet directory to get latest standarized formated source data, 
                         directories should be dated as YYYYMMDD

    Name:                Path_DownloadRoot
      Allowed Values:    Valid KENNT directory
      Default Value:     null
      Description:       Root kennet directory to get latest raw datasets, 
                         directories should be dated as YYYYMMDD                         

    Name:                Path_Progs
      Allowed Values:    Valid KENNT directory
      Default Value:     null
      Description:       Kennet directory that holds study driver run_pfesacq_map_scrf.sas,
                         if null then will use /projects/pfizrNNNNNN/dm/sasprogs/production

    Name:                Path_Metadata
      Allowed Values:    Valid KENNT directory
      Default Value:     null
      Description:       Kennet directory that holds SACQ per transfer structureal metadata,
                         if null then will use /projects/std_pfizer/sacq/metadata

    Name:                Path_CAL
      Allowed Values:    Valid KENNT directory
      Default Value:     null
      Description:       Kennet directory to place SACQ transfer zip files for Pfizer CAL pickup,
                         if null then will use &path_sacqroot./archive

    Name:                Path_StudyContacts
      Allowed Values:    Valid KENNT directory
      Default Value:     null
      Description:       Kennet directory that holds study_contacts.csv to get study emails from, 
                         if null then will use /projects/pfizrNNNNNN/macros        

    Name:                TESTING
      Allowed Values:    YES|NO
      Default Value:     NO
      Description:       if YES then will not post zip file to transfer or send emails          

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2700 $

-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
  MODIFICATION VERSIONS: 

  Version: 1.0 Date: 20160818 Author: Nathan Hartley
  
  Version: 2.0 Date: 20161004 Author: Nathan Johnson
    Updates:  1) Change default location of CAL Path to sacq/archive
              2) Adjust wording of feedback email and include CAL path in email

-----------------------------------------------------------------------------*/

%macro pfesacq_csdw_auto(
    In_PXL_Code        = null, 
    In_Protocol        = null,
    In_ForceRun        = NO,
    Path_SACQRoot      = null,
    Path_SCRFRoot      = null,
    Path_DownloadRoot  = null,
    Path_Progs         = null,
    Path_Metadata      = null,
    Path_CAL           = null,
    Path_StudyContacts = null,
    TESTING            = NO
    );

    %* Initialize Macro Variables;
      	%let MacroVersion = 2.0;
      	%let MacroVersionDate = 20161004;
        data _null_;
            %* Derive from SMARTSVN updated string as revision number;
            VALUE = "$Rev: 2700 $";
            VALUE = compress(VALUE,'$Rev: ');
            call symput('SMARTSVN_Version', VALUE);
        run;
      	%let MacroLocation = ; %* Derive from SMARTSVN updated string below;
      	data _null_;
  		    VALUE = "$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_csdw_auto.sas $";
              %* Replace Smart SVN Repository name with actual UNIX path used;
              VALUE = tranwrd(VALUE,'HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/', '/opt/pxlcommon/stats/');
              VALUE = compress(VALUE,'$');
              call symput('MacroLocation', VALUE);
  	    run;
      	%let MacroLastChangeDateTime = %substr("$LastChangedDate: 2016-10-04 17:31:06 -0400 (Tue, 04 Oct 2016) $", 18, 26); %* Derived from SMARTSVN string;
      	%let MacroRunDate = %sysfunc(left(%sysfunc(date(), yymmddn8.)));
      	%let MacroRUnDateTime = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));

      	%let RC = 0; %* Return code used in sub macros;
        %let study_emails = ; %* Study team email contacts loaded from study_contacts.csv at study level;
        %let stat_emails = ; %* Study team Stat primary/backup emails from study_contacts.csv for structure change email;
        %let dex_emails = ; %* DEX team email contacts from loaded metadata;
        %let pfe_emails = ; %* Pfizer email contacts from loaded metadata;
        %let total_notes = ; %* Total returned NOTES from pfesacq_map_scrf macro;
        %let total_warnings = ; %* Total returned WARNINGS from pfesacq_map_scrf macro;
        %let total_errors = ; %* Total returned ERRORS from pfesacq_map_scrf macro;
        %let total_differences = ; %* Total number of structureal differences between current and last SACQ transfer metadata;
        %let current_transfer_metadata = ; %* ;
        %let previous_transfer_metadata = ; %* ;
        %let pfesacq_map_scrf_logname = ;
        %let pfesacq_map_scrf_listingname = ; %* Listing file created by SACQ mapping driver;
        %let PostToCal_FileName = ; %* Zip file to post to CAL on succesiful SACQ transfer;

    %* Macro Utilities

        %* MACRO: LogMessageOutput
         * PURPOSE: Standardize Macro Log Message Output
         * INPUT: 
         *   1) noteType - i=INFO, n=NOTE, e=ERR OR, w=WARN ING
         *   2) noteMessage - Message text with @ for line breaks\
         *   3) macroName - Macro breadcrumbs
         * OUTPUT: 
         *   1) Log Message
         *;
	        %macro LogMessageOutput(noteType, noteMessage, macroName);
	            %local _type i countwords;

	            %if %str("&notetype") = %str("i") %then %do;
	                %put ;
	                %let _type = INFO;
	            %end;
	            %else %if %str("&notetype") = %str("n") %then %do;
	                %let _type = %str(NOTE);
	            %end;
	            %else %if %str("&notetype") = %str("e") %then %do;
	                %put ;
	                %let _type = %str(ERR)OR;
	                %let GMPXLERR = 1;
	            %end;
	            %else %if %str("&notetype") = %str("w") %then %do;
	                %put ;
	                %let _type = %str(WAR)NING;
	            %end;

	            %if %str("&notetype") ne %str("n") %then %do; 
	                %* HEADER LINE;
	                %put &_type.:[PXL]%sysfunc(repeat(%str(-),79));
	            %end;
	            
	            %* BODY;
	            %let countwords = %eval(%sysfunc(countc(%str(&noteMessage),%str(@)))+1);
	            
	            %if %eval(&countwords>0) %then %do;
	                %do i=1 %to &countwords;
	                    %put &_type.:[PXL] &macroName: %scan(&noteMessage,&i,"@");
	                %end;
	            %end;
	            %else %do;
	                %put &_type.:[PXL] &macroName: &noteMessage;
	            %end;
	            
	            %if %str("&notetype") ne %str("n") %then %do; 
	                * FOOTER LINE;
	                %put &_type.:[PXL]%sysfunc(repeat(%str(-),79));
	                %put;                   
	            %end;
	        %mend LogMessageOutput;    

        %* MACRO: GetLatestDatedFolder
         * PURPOSE: Get Latest Dated Folder in given Path
         * INPUT: 
         *    1) Path - Unix directory path
         * OUTPUT: 
         *    1) LatestDatedFolder - Set macro variable to latest dated folder as YYYYMMDD or 
                 null if no dated folder found
         *;
            %macro GetLatestDatedFolder(Path=null, MacroPath=null);
            	%LogMessageOutput(i, Start of Macro, &MacroPath);

                * Get list of YYYYMMDD folders;
                filename dirlist pipe "ls -la %left(%trim(&Path))" ;
                %let cnt = 0;
                data work._dirlist ;
                    length dirline dirline2 $200 ;
                    infile dirlist recfm=v lrecl=200 truncover end=eof;
                    input dirline $1-200 ;
                    dirline2 = substr(dirline,59);
                    if length(dirline2) = 8;
                    if not missing(input(dirline2,?? 8.));
                    if input(dirline2,?? 8.) > 19600000 and input(dirline2,?? 8.) < 20990000;
                    call symput('cnt','1');
                run;    

                %if %eval(&cnt = 1) %then %do;
                    * Get max date;
                    proc sql noprint;
                        select max(input(dirline2, 8.)) as LatestDatedFolder into: LatestDatedFolder
                        from _dirlist;
                    quit;
                    %LogMessageOutput(n, %str(Lastest Dated Folder Found = &LatestDatedFolder), &MacroPath);
                %end;
                %else %do;
                    %LogMessageOutput(n, %str(No dated folders found, LatestDatedFolder = null), &MacroPath);
                    %let LatestDatedFolder = null;
                %end;

				        %put ;	                
                %LogMessageOutput(n, %str(Path = &Path), &MacroPath);
                %LogMessageOutput(n, %str(LatestDatedFolder = &LatestDatedFolder), &MacroPath);
                %put ;	                

                %LogMessageOutput(i, End of Macro, &MacroPath); 
            %mend GetLatestDatedFolder;

		    %* MACRO: UpdatePathForIssue
         * PURPOSE: Get Latest Dated Folder in given Path
         * INPUT: 
         *    1) PathRoot - Unix directory path
         *    2) MacroPath - Macro breadcrumb
         * OUTPUT: 
         *    1) Renames today YYYYMMDD folder from PathRoot to error_YYYYMMDD
         *;
            %macro UpdatePathForIssue(PathRoot=null, MacroPath=null);
              	%LogMessageOutput(i, Start of Macro, &MacroPath);

              	%local pathroot_dated pathroot_err;
              	%let PathRootDated = &pathroot/%sysfunc(left(%sysfunc(date(), yymmddn8.)))/;
              	%let PathRootErr = &pathroot/error_%sysfunc(left(%sysfunc(date(), yymmddn8.)));

              	%LogMessageOutput(n, Dated Folder To Rename = &PathRootDated, &MacroPath);
              	%LogMessageOutput(n, Renamed Folder = &PathRootErr, &MacroPath);

                %sysexec %str(rm -rf &PathRootErr 2> /dev/null);
                %sysexec %str(mkdir -p &PathRootErr);

                %sysexec %str(cp -rp &PathRootDated &PathRootErr 2> /dev/null);
                %sysexec %str(rm -rf &PathRootDated 2> /dev/null);
                %sysexec %str(rmdir &PathRootDated 2> /dev/null);	                

                %LogMessageOutput(i, End of Macro, &MacroPath); 
            %mend UpdatePathForIssue;

        %* MACRO: RenameToError
         * PURPOSE: Get Latest Dated Folder in given Path
         * INPUT: 
         *    1) PathRoot - Unix directory path
         *    2) CurDate - Current date directory to look for
         *    2) MacroPath - Macro breadcrumb
         * OUTPUT: 
         *    1) Renames today YYYYMMDD folder from PathRoot to error_YYYYMMDD
         *;
            %macro RenameToError(PathRoot=null, CurDate=null, MacroPath=null);
                %LogMessageOutput(i, Start of Macro, &MacroPath -> RenameToError);

                %if %sysfunc(fileexist(&PathRoot/%left(%trim(&CurDate)))) %then %do;
                    %sysexec %str(mv &PathRoot/%left(%trim(&CurDate)) &PathRoot/error_%left(%trim(&CurDate)));
                    %LogMessageOutput(n, Directory renamed to &PathRoot/error_%left(%trim(&CurDate)), &MacroPath);
                %end;
                %else %do;
                    %LogMessageOutput(i, Directory not found &PathRoot/%left(%trim(&CurDate)), &MacroPath);
                %end;

                %LogMessageOutput(i, End of Macro, &MacroPath &MacroPath -> RenameToError); 
            %mend RenameToError;            
  
    %* Macro Processes
     * 1) PreProcessing - Initialize work informational datasets and output to log input parameters
     * 2) CheckInput - Verify and derive input parameters
     * 3) CheckRunNeed - Verify if SACQ transfer is needed
     * 4) RUN_PFESACQ_MAP_SCRF - Run study driver run_pfesacq_map_scrf.sas file
     * 5) RunLogcheck - Check run_pfesacq_map_scrf log for issues and run for errors
     * 6) CheckDifferences - Check for structure differences against last transfer
     * 7) RunZip - Zip older SACQ transfer directories
     * 8) Ongoing_Logcheck - Check run_pfesacq_csdw_auto ongoing logcheck for issues
     * 8) LogTransfer - Log Transfer to metadata
     * 9) PostToCal - Copy transfer zip file to CAL pickup location
     * 10) GetWarnings - Get number of SACQ transfer warnings and name of created listing if present
     * 11) SendEmail - Email study team and DEX run status of transfer
     * 12) CleanUp - Remove run data, macros, etc
     *;

        %* MACRO: PreProcessing
         * PURPOSE: Initialize work informational datasets and output to log input parameters
         * INPUT: 
         * OUTPUT: 
         *;
	        %macro PreProcessing;	            
	            %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> PreProcessing);

	            %* Derive CONFIG informational object;	            
	            data CONFIG;
  	            	length DESC VALUE $500.;

  	            	DESC="Global Pfizer Macro"; VALUE="PFESACQ_CSDW_AUTO"; output;
  	            	DESC="Macro Version"; VALUE="&MacroVersion"; output;
  	            	DESC="Macro Version Date"; VALUE="&MacroVersionDate"; output;

  	            	DESC="Macro SMARTSVN Revision"; VALUE=compress("$Rev: 2700 $", '$Rev: '); output;
  	             
  				        DESC="Macro Location";
	                %* Smart SVN will replace what is between the $HeadURL $ with the repository name and macro path;
	                VALUE = "$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_csdw_auto.sas $";
	                %* Replace Smart SVN Repository name with actual UNIX path used;
	                VALUE = tranwrd(VALUE,'HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/', '/opt/pxlcommon/stats/');
	                VALUE = compress(VALUE,'$');
	                output;

	                DESC="Macro Last Change DateTime"; VALUE=substr("$LastChangedDate: 2016-10-04 17:31:06 -0400 (Tue, 04 Oct 2016) $", 18, 26); output;
	                DESC="Macro Run Date"; VALUE=strip(put(date(), yymmddn8.)); * YYYYMMDD Date; output;
	                DESC="Macro Run DateTime"; VALUE=strip(put(datetime(), IS8601DT.));  * ISO8601 DATETIME; output;
	                DESC="Run By"; VALUE=upcase("&sysuserid"); output;

	                DESC="In_PXL_Code"; VALUE="&In_PXL_Code"; output;
	                DESC="In_Protocol"; VALUE="&In_Protocol"; output;
	                DESC="In_ForceRun"; VALUE="&In_ForceRun"; output;
	                DESC="Path_SACQRoot"; VALUE="&PATH_SACQRoot"; output;
	                DESC="Path_SCRFRoot"; VALUE="&PATH_SCRFRoot"; output;
	                DESC="Path_Progs"; VALUE="&PATH_Progs"; output;
	                DESC="Path_Metadata"; VALUE="&PATH_Metadata"; output;
	            run;

	            %* Output to log Start of Macro info;
	            data _null_;
	            	set CONFIG;

	                if DESC="Global Pfizer Macro" then do;
  						        put ;
  	                	put "INFO:[PXL]----------------------------------------------";
  	                	put "INFO:[PXL] MACRO INFO: ";	                	                	
  	                	put "INFO:[PXL]   Run of Global Pfizer Macro: " VALUE;
	                end;
	                if DESC="Macro Version" then put "INFO:[PXL]   Macro Version: " VALUE;
	                if DESC="Macro Version Date" then put "INFO:[PXL]   Macro Version Date: " VALUE;
	                if DESC="Macro SMARTSVN Revision" then put "INFO:[PXL]   Macro SMARTSVN Revision: " VALUE;
	                if DESC="Macro Location" then put "INFO:[PXL]   Macro Location: " VALUE;
	                if DESC="Macro Last Change DateTime" then put "INFO:[PXL]   Macro Last Change DateTime: " VALUE;
	                if DESC="Macro Run Date" then put "INFO:[PXL]   Macro Run Date: " VALUE;
	                if DESC="Macro Run DateTime" then put "INFO:[PXL]   Macro Run DateTime: " VALUE;
	                if DESC="Run By" then do;
  	                	put "INFO:[PXL]   Run By: " VALUE;
  		                put "INFO:[PXL]----------------------------------------------";
  		                put "INFO:[PXL] PURPOSE: ";
  		                put "INFO:[PXL]   1) Run study driver run_pfesacq_map_scrf";
  		                put "INFO:[PXL]      if SCRF data newer than SACQ data";
  		                put "INFO:[PXL]   2) Check log and review for issues and email";
  		                put "INFO:[PXL]      status of transfer";
  		                put "INFO:[PXL]   3) Check for differences from last transfer";
  		                put "INFO:[PXL]      and email PXL and PFE any differences";
  		                put "INFO:[PXL]----------------------------------------------";
  		                put "INFO:[PXL] INPUT: ";
		              end;
	                if DESC="In_PXL_Code"   then put "INFO:[PXL]   1) In_PXLCode = " VALUE;
	                if DESC="In_Protocol"   then put "INFO:[PXL]   2) In_Protocol = " VALUE;
	                if DESC="In_ForceRun"   then put "INFO:[PXL]   3) In_ForceRun = " VALUE;
	                if DESC="Path_SACQRoot" then put "INFO:[PXL]   4) Path_SACQRoot = " VALUE;
	                if DESC="Path_SCRFRoot" then put "INFO:[PXL]   5) Path_SCRFRoot = " VALUE;
	                if DESC="Path_Progs"    then put "INFO:[PXL]   6) Path_Progs = " VALUE;
	                if DESC="Path_Metadata" then do; 
	                	  put "INFO:[PXL]   7) Path_Metadata = " VALUE;
						          put "INFO:[PXL]----------------------------------------------";
	                	  put ;
	                end;
	            run;

	            %* Derive EMAIL_PXL informational object;
	            data EMAIL_PXL;
                  length DESC VALUE $500.;

                  DESC="Overall Status"; VALUE="FAILED"; output;
                  DESC="Fail Reason"; VALUE=""; output;

                  DESC="Source Data Checks Status"; VALUE="Not Completed"; output;
                  DESC="Source Data Checks Msg"; VALUE=""; output;

                  DESC="SACQ Transfer Need Status"; VALUE="Not Completed"; output;
                  DESC="SACQ Transfer Need Msg"; VALUE=""; output;

                  DESC="RUN_PFESACQ_MAP_SCRF LogCheck Status"; VALUE="Not Completed"; output;
                  DESC="RUN_PFESACQ_MAP_SCRF LogCheck Msg"; VALUE=""; output;	

                  DESC="Check Differences Status"; VALUE="Not Completed"; output;
                  DESC="Check Differences Msg"; VALUE=""; output;

                  DESC="Zip Older SACQ Directories Status"; VALUE="Not Completed"; output;
                  DESC="Zip Older SACQ Directories Msg"; VALUE=""; output;

                  DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Status"; VALUE="Not Completed"; output;
                  DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Msg"; VALUE=""; output;

                  DESC="Transfer Posted To CAL Status"; VALUE="Not Completed"; output;
                  DESC="Transfer Posted To CAL Msg"; VALUE=""; output;

                  DESC="Transfer Warnings Status"; VALUE="Not Completed"; output;
                  DESC="Transfer Warnings Msg"; VALUE=""; output;                  
	            run;

	            %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> PreProcessing);
	        %mend PreProcessing;

        %* MACRO: CheckInput
         * PURPOSE: Verify and derive input parameters
         * INPUT:
         *   1) Global Macros 
         *     1) DEBUG - If exists, MAD standard sas options identifier
         *     2) GMPXLERR - If exists, MAD standard return code
         *   2) Input Parameters
         *     1) Work Dataset CONFIG
         *     2) Work Dataset EMAIL_PXL
         * OUTPUT: 
         *   1) Populates macro variable dex_emails
         *   2) Populates macro variable pfe_emails
         *;
	        %macro CheckInput;
	            %LogMessageOutput(i, Start of SubMacro, PFESACQ_CSDW_AUTO -> CheckInput);

	            %* MACRO: CK1 
	             * PURPOSE: Global Macro GMPXLERR is valid
	             * INPUT: 
	             *   1) Macro Variable GMPXLERR - Name of global macro variable error indicatior
	             *   2) Work SAS dataset EMAIL_PXL             
	             * OUTPUT:
	             *   1) Macro Variable RC - Set to 1 if issues found or 0 if no issues
	             *   2) Work SAS dataset EMAIL_PXL updated if issues           
	             *;
		            %macro CK1;
		                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK1);

		                %local EXISTS _GMPXLERR;
		                proc sql noprint;
		                    select count(*) into: EXISTS
		                    from sashelp.vmacro
		                    where upcase(scope) = "GLOBAL"
		                          and upcase(name) = "GMPXLERR";
		                quit;

		                %if &EXISTS = 1 %then %do;
  		                	%if %eval(&GMPXLERR ne 0) %then %do;
    		                		%if %eval(&GMPXLERR = 1) %then %do;
                                %* GMPXLERR=1 FAIL case;
                                %LogMessageOutput(e, Global Macro Variable GMPXLERR = 1, pfesacq_csdw_auto -> CheckInput -> CK1);
                                data EMAIL_PXL;
                                    set EMAIL_PXL;
                                    if DESC="Source Data Checks Status" then VALUE="FAILED";
                                    if DESC="Source Data Checks Msg" then VALUE="Global Macro Variable GMPXLERR = 1";
  		                        	run;
  		                        	%goto macerr;
    		                		%end;
    		                		%else %do;
                                %* GMPXLERR not 0 or 1 FAIL case;
                                %let _GMPXLERR = &GMPXLERR;
                                %LogMessageOutput(e, Global Macro Variable GMPXLERR = &_GMPXLERR, pfesacq_csdw_auto -> CheckInput -> CK1);
                                data EMAIL_PXL;
                                    set EMAIL_PXL;
                                    if DESC="Source Data Checks Status" then VALUE="FAILED";
                                    if DESC="Source Data Checks Msg" then VALUE="Global Macro Variable GMPXLERR = &_GMPXLERR";
    	                        	run;
    	                        	%goto macerr;									

    		                		%end;
  		                	%end;
		                %end;
		                %else %do;
                        %global GMPXLERR;
                        %let GMPXLERR = 0;
		                %end;

		                %LogMessageOutput(n, Check 1 - Global Macro GMPXLERR - PASS, pfesacq_csdw_auto -> CheckInput -> CK1);
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:;
		                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK1);               
		            %mend CK1;

	            %* MACRO: CK2 
	             * PURPOSE: Global Macro DEBUG is valid
	             * INPUT: 
	             *   1) Macro Variable DEBUG - Name of global macro variable DEBUG to set SAS options
	             *   2) Work SAS dataset EMAIL_PXL - Name of work dataset holding email_pxl output info
	             *      Attribs: OVERALL_STATUS STEP1_INPUT_CHECKS STEP1_INPUT_CHECKS_MSG $200.             
	             * OUTPUT:
	             *   1) Macro Variable DEBUG - Created and set to 0 if does not exist and sets SAS options
	             *   2) Work SAS dataset EMAIL_PXL - 
	             *      STEP1_INPUT_CHECKS = PASS or FAILED and STEP1_INPUT_CHECKS_MSG with fail 
	             *      message             
	             *;            
		            %macro CK2;
		                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK2);

		                %local EXISTS _DEBUG;
		                proc sql noprint;
		                    select count(*) into: EXISTS
		                    from sashelp.vmacro
		                    where upcase(scope) = "GLOBAL"
		                          and upcase(name) = "DEBUG";
		                quit;

		                %if &EXISTS = 1 %then %do;
		                    %if %eval(&DEBUG = 0) %then %do;
		                        OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR SOURCE NOTES;
		                    %end;
		                    %else %if %eval(&DEBUG = 1) %then %do;
		                        OPTION MPRINT MLOGIC SYMBOLGEN SOURCE NOTES;
		                    %end;
		                    %else %do;
                            %let _DEBUG = &DEBUG;
                            %LogMessageOutput(e, 
		                            Global Macro DEBUG - FAIL - DEBUG is not 0 or 1
		                            @DEBUG = &_DEBUG, 
		                            pfesacq_csdw_auto -> CheckInput -> CK2);

		                        data EMAIL_PXL;
		                            set EMAIL_PXL;
	                            	if DESC="Source Data Checks Status" then VALUE="FAILED";
	                            	if DESC="Source Data Checks Msg" then VALUE=catx(" ","Global Macro Variable DEBUG is not 0 or 1. DEBUG =", &_DEBUG);
		                        run;
		                        %goto macerr;
		                    %end;	                
		                %end;
		                %else %do;
	                        %global DEBUG;
	                        %let DEBUG = 0;
		                %end;

		                %LogMessageOutput(n, Check 2 - Global Macro DEBUG - PASS, pfesacq_csdw_auto -> CheckInput -> CK2);
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:;                
		                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK2); 
		            %mend CK2;

	            %* MACRO: CK3 
	             * PURPOSE: Input Parameter In_PXL_Code
	             * INPUT: 
	             *   1) Macro Variable In_PXL_Code
	             *   2) Macro Variable EMAIL_PXL            
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
	             *; 
		            %macro CK3;
		            	%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK3);

		            	%local EXISTS;
		                proc sql noprint;
		                    select count(*) into: EXISTS
		                    from sashelp.vmacro
		                    where upcase(scope) = "GLOBAL"
		                          and upcase(name) = "PXL_CODE";
		                quit;

						        %* Input parameter In_PXL_Code not given and global macro PXL_CODE does not exist;
		                %if %str("&In_PXL_Code") = "null" and &EXISTS = 0 %then %do;		                	
	                        %LogMessageOutput(e, 
	                            Input Parameter In_PXL_Code = null and Global Macro PXL_CODE does not exist, 
	                            pfesacq_csdw_auto -> CheckInput -> CK3);

	                        data EMAIL_PXL;
	                            set EMAIL_PXL;
                            	if DESC="Source Data Checks Status" then VALUE="FAILED";
                            	if DESC="Source Data Checks Msg" then VALUE="Input Parameter In_PXL_Code = null and Global Macro PXL_CODE does not exist";	                            
	                        run;
	                        %goto macerr; 
		                %end;

		                %* Input parameter In_PXL_Code is null and global macro PXL_CODE is null;
		                %if %str("&In_PXL_Code") = "null" and &EXISTS = 1 %then %do;
		                	%if %str("&PXL_CODE") = "null" or %str("&PXL_CODE") = "" %then %do;
		                        %LogMessageOutput(e, 
		                            Input Parameter In_PXL_Code = null and Global Macro PXL_CODE is null, 
		                            pfesacq_csdw_auto -> CheckInput -> CK3);

		                        data EMAIL_PXL;
		                            set EMAIL_PXL;
	                            	if DESC="Source Data Checks Status" then VALUE="FAILED";
	                            	if DESC="Source Data Checks Msg" then VALUE="Input Parameter In_PXL_Code = null and Global Macro PXL_CODE is null";	                            
		                        run;
		                        %goto macerr;		                	
		                	%end;
		                	%else %do;
		                		%let In_PXL_Code = &PXL_CODE;
		                		%LogMessageOutput(n, Input Parameter In_PXL_Code=null so get value from global macro PXL_CODE=&PXL_CODE, pfesacq_csdw_auto -> CheckInput -> CK3);
		                	%end;
		                %end;

		                %LogMessageOutput(n, Input Parameter In_PXL_Code = &In_PXL_Code, pfesacq_csdw_auto -> CheckInput -> CK3);
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:;                
		                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK3);              
		            %mend CK3;

	            %* MACRO: CK4 
	             * PURPOSE: Check Input Parameter In_Protocol
	             * INPUT: 
	             *   1) Macro Variable In_Protocol
	             *   2) Global Macro PROTOCOL
	             *   3) Macro Variable EMAIL_PXL            
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
	             *; 
		            %macro CK4;
		            	%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK4);

		            	%local EXISTS;
		                proc sql noprint;
		                    select count(*) into: EXISTS
		                    from sashelp.vmacro
		                    where upcase(scope) = "GLOBAL"
		                          and upcase(name) = "PROTOCOL";
		                quit;

						        %* Input parameter In_Protocol not given and global macro PROTOCOL does not exist;
		                %if %str("&In_Protocol") = "null" and &EXISTS = 0 %then %do;		                	
	                        %LogMessageOutput(e, 
	                            Input Parameter In_Protocol = null and Global Macro PROTOCOL does not exist, 
	                            pfesacq_csdw_auto -> CheckInput -> CK4);

	                        data EMAIL_PXL;
	                            set EMAIL_PXL;
	                        	if DESC="Source Data Checks Status" then VALUE="FAILED";
	                        	if DESC="Source Data Checks Msg" then VALUE="Input Parameter In_Protocol = null and Global Macro PROTOCOL does not exist";	                            
	                        run;
	                        %goto macerr; 
		                %end;

		                %* Input parameter In_Protocol is null and global macro PROTOCOL is null;
		                %if %str("&In_Protocol") = "null" and &EXISTS = 1 %then %do;
		                	%if %str("&PROTOCOL") = "null" or %str("&PROTOCOL") = "" %then %do;
		                        %LogMessageOutput(e, 
		                            Input Parameter In_Protocol = null and Global Macro PROTOCOL is null, 
		                            pfesacq_csdw_auto -> CheckInput -> CK4);

		                        data EMAIL_PXL;
		                            set EMAIL_PXL;
	                            	if DESC="Source Data Checks Status" then VALUE="FAILED";
	                            	if DESC="Source Data Checks Msg" then VALUE="Input Parameter In_Protocol = null and Global Macro PROTOCOL is null";	                            
		                        run;
		                        %goto macerr;		                	
		                	%end;
		                	%else %do;
		                		%let In_Protocol = &PROTOCOL;
		                		%LogMessageOutput(n, Input Parameter In_Protocol=null so get value from global macro PROTOCOL=&PROTOCOL, pfesacq_csdw_auto -> CheckInput -> CK4);
		                	%end;
		                %end;

		                %LogMessageOutput(n, Input Parameter In_Protocol = &In_Protocol, pfesacq_csdw_auto -> CheckInput -> CK4);
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:; 

		            	%LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK4);                   
		            %mend CK4;

	            %* MACRO: CK5 
	             * PURPOSE: Check Input Parameter In_ForceRun
	             * INPUT: 
	             *   1) Macro Variable In_ForceRun
	             *   2) Macro Variable EMAIL_PXL
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
	             *; 
		            %macro CK5;
                  %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK5);

		            	%if %str("&In_ForceRun") ne "YES" and %str("&In_ForceRun") ne "NO" %then %do;
                      %LogMessageOutput(e, 
                          %str(Input Parameter In_ForceRun is not YES or NO, In_ForceRun = &In_ForceRun), 
                          pfesacq_csdw_auto -> CheckInput -> CK5);

                      data EMAIL_PXL;
                          set EMAIL_PXL;
                      	if DESC="Source Data Checks Status" then VALUE="FAILED";
                      	if DESC="Source Data Checks Msg" then VALUE="Input Parameter In_ForceRun is not YES or NO, In_ForceRun = &In_ForceRun";	                            
                      run;
                      %goto macerr; 		            		
		            	%end;

  		                %LogMessageOutput(n, Input Parameter In_ForceRun = &In_ForceRun, pfesacq_csdw_auto -> CheckInput -> CK5);
  		                %goto macend;

  		                %macerr:;
  		                %let RC = 1;

  		                %macend:; 

		            	%LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK5);                   
		            %mend CK5;

	            %* MACRO: CK6 
	             * PURPOSE: Check Input Parameter Path_SACQRoot
	             * INPUT: 
	             *   1) Macro Variable Path_SACQRoot
	             *   2) Macro Variable EMAIL_PXL
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
	             *; 
		            %macro CK6;
  		            	%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK6);
  		            	
  		            	%if %str("&Path_SACQRoot") = "null" %then %do;		            		
    		            		%if %sysfunc(fileexist(/projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/sacq)) %then %do;
    								        %* If null then use expected standard Pfizer study setup;
                            %let Path_SACQRoot = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/sacq;
    		            		%end;
    		            		%else %do;
    	            			    %* If null then use expected standard Pfizer study setup but it does not exist issue;
                            %LogMessageOutput(e, 
                                %str(Input Parameter Path_SACQRoot is null
                                	,@but standard study Pfizer setup location does not exist
                                	,@Expected Directory = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/sacq),
                                pfesacq_csdw_auto -> CheckInput -> CK6);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                            	if DESC="Source Data Checks Status" then VALUE="FAILED";
                            	if DESC="Source Data Checks Msg" then VALUE="Input Parameter Path_SACQRoot is null but standard study Pfizer setup location does not exist";	                            
                            run;
                            %goto macerr; 
    		            		%end;
  		            	%end;
  		            	%else %do;
    		            		%if %sysfunc(fileexist(&Path_SACQRoot)) %then %do;
                			      %* File exists and no issues;
    		            		%end;
    		            		%else %do;
                            %LogMessageOutput(e, 
                                %str(Input parameter Path_SACQRoot is not a valid directory, @Path_SACQRoot=&Path_SACQRoot),
                                pfesacq_csdw_auto -> CheckInput -> CK6);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                            	if DESC="Source Data Checks Status" then VALUE="FAILED";
                            	if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_SACQRoot is not a valid directory, Path_SACQRoot=&Path_SACQRoot";	                            
                            run;
                            %goto macerr; 
    		            		%end;		            		
  		            	%end;

  	                %LogMessageOutput(n, Input Parameter Path_SACQRoot = &Path_SACQRoot, pfesacq_csdw_auto -> CheckInput -> CK6);
  	                %goto macend;

  	                %macerr:;
  	                %let RC = 1;

  	                %macend:; 

  		            	%LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK6);                   
		            %mend CK6;

	            %* MACRO: CK7 
	             * PURPOSE: Check Input Parameter Path_SCRFRoot
	             * INPUT: 
	             *   1) Macro Variable Path_SCRFRoot
	             *   2) Macro Variable EMAIL_PXL
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL   
	             *; 
		            %macro CK7;
  		            	%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK7);
  		            	
  		            	%if %str("&Path_SCRFRoot") = "null" %then %do;		            		
    		            		%if %sysfunc(fileexist(/projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/scrf)) %then %do;
    								        %* If null then use expected standard Pfizer study setup;
    		            			  %let Path_SCRFRoot = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/scrf;
    		            		%end;
    		            		%else %do;
    		            			  %* If null then use expected standard Pfizer study setup but it does not exist issue;
  	                        %LogMessageOutput(e, 
  	                            %str(Input Parameter Path_SCRFRoot is null
  	                            	,@but standard study Pfizer setup location does not exist
  	                            	,@Expected Directory = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/scrf),
  	                            pfesacq_csdw_auto -> CheckInput -> CK7);

  	                        data EMAIL_PXL;
  	                            set EMAIL_PXL;
    	                        	if DESC="Source Data Checks Status" then VALUE="FAILED";
    	                        	if DESC="Source Data Checks Msg" then VALUE="Input Parameter Path_SCRFRoot is null but standard study Pfizer setup location does not exist";	                            
  	                        run;
  	                        %goto macerr; 
    		            		%end;
  		            	%end;
  		            	%else %do;
    		            		%if %sysfunc(fileexist(&Path_SCRFRoot)) %then %do;
    		            			  %* File exists and no issues;
    		            		%end;
    		            		%else %do;
  	                        %LogMessageOutput(e, 
  	                            %str(Input parameter Path_SCRFRoot is not a valid directory, @Path_SCRFRoot=&Path_SCRFRoot),
  	                            pfesacq_csdw_auto -> CheckInput -> CK7);

  	                        data EMAIL_PXL;
  	                            set EMAIL_PXL;
  	                        	if DESC="Source Data Checks Status" then VALUE="FAILED";
  	                        	if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_SCRFRoot is not a valid directory, Path_SCRFRoot=&Path_SCRFRoot";	                            
  	                        run;
  	                        %goto macerr; 
    		            		%end;		            		
  		            	%end;

  		            	%* Verify at least one dated YYYYMMDD folder exists;
  		            	%local LatestDatedFolder;
  		            	%let LatestDatedFolder = ;
  						      %GetLatestDatedFolder(Path=%str(&Path_SCRFRoot), MacroPath=pfesacq_csdw_auto -> CheckInput -> CK7 -> GetLatestDatedFolder);
  						      %if %str("&LatestDatedFolder") = "null" %then %do;
                        %LogMessageOutput(e, 
                            %str(Input parameter Path_SCRFRoot contains no YYYYMMDD folders, @Path_SCRFRoot=&Path_SCRFRoot),
                            pfesacq_csdw_auto -> CheckInput -> CK7);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                        	  if DESC="Source Data Checks Status" then VALUE="FAILED";
                        	  if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_SCRFRoot contains no YYYYMMDD folders, Path_SCRFRoot=&Path_SCRFRoot";	                            
                        run;
                        %goto macerr; 							
  						      %end;

  		            	%* Verify at least demog.sas7bdat file exists;
  		            	libname LIB_SCRF "&Path_SCRFRoot/&LatestDatedFolder";
  		            	%local EXISTS;
                    proc sql noprint;
                        select count(*) into: EXISTS
                        from sashelp.vstable
                        where libname = 'LIB_SCRF'
                              and memname = 'DEMOG';
                    quit;
                    %if &EXISTS = 0 %then %do;
                        %LogMessageOutput(e, 
                            %str(Input parameter Path_SCRFRoot folder %left(%trim(&LatestDatedFolder)) requires DEMOG @Path_SCRFRoot=&Path_SCRFRoot),
                            pfesacq_csdw_auto -> CheckInput -> CK7);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                        	  if DESC="Source Data Checks Status" then VALUE="FAILED";
                        	  if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_SCRFRoot folder %left(%trim(&LatestDatedFolder)) requires DEMOG, Path_SCRFRoot=&Path_SCRFRoot";	                            
                        run;
                        %goto macerr; 
                    %end;

  		            	%* Verify at least demog.sas7bdat file exists with > 0 obs;
  		            	%local NOBS;
                    proc sql noprint;
                        select NOBS into: NOBS
                        from sashelp.vtable
                        where libname = 'LIB_SCRF'
                              and memname = 'DEMOG';
                    quit;
                    %if &NOBS = 0 %then %do;
                        %LogMessageOutput(e, 
                            %str(Input parameter Path_SCRFRoot folder %left(%trim(&LatestDatedFolder)) requires DEMOG with at least one record@Path_SCRFRoot=&Path_SCRFRoot),
                            pfesacq_csdw_auto -> CheckInput -> CK7);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                        	  if DESC="Source Data Checks Status" then VALUE="FAILED";
                        	  if DESC="Source Data Checks Msg" then 
                        		VALUE=catx(" ","Input parameter Path_SCRFRoot folder %left(%trim(&LatestDatedFolder)) requires", 
                        		    "DEMOG with at least one record, Path_SCRFRoot=&Path_SCRFRoot");
                        run;
                        %goto macerr;
                    %end;

		                %LogMessageOutput(n, Input Parameter Path_SCRFRoot = &Path_SCRFRoot, pfesacq_csdw_auto -> CheckInput -> CK7);
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:; 

		            	  %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK7);                   
		            %mend CK7;		            
	                
	            %* MACRO: CK8 
	             * PURPOSE: Check Input Parameter Path_Progs
	             * INPUT: 
	             *   1) Macro Variable Path_Progs
	             *   2) Macro Variable EMAIL_PXL
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
	             *; 
		            %macro CK8;
  		            	%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK8);

  		            	%if %str("&Path_Progs") = "null" %then %do;		            		
  		            		  %if %sysfunc(fileexist(/projects/pfizr%left(%trim(&In_PXL_Code))/dm/sasprogs/production)) %then %do;
                            %* If null then use expected standard Pfizer study setup;
  		            			    %let Path_Progs = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/sasprogs/production;
		            		    %end;
  		            		  %else %do;
  		            			    %* If null then use expected standard Pfizer study setup but it does not exist issue;
		                        %LogMessageOutput(e, 
		                            %str(Input Parameter Path_Progs is null
		                            	@but standard study Pfizer setup location does not exist
		                            	@Expected Directory = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/sasprogs/production),
		                            pfesacq_csdw_auto -> CheckInput -> CK8);

		                        data EMAIL_PXL;
		                            set EMAIL_PXL;
		                        	  if DESC="Source Data Checks Status" then VALUE="FAILED";
		                        	  if DESC="Source Data Checks Msg" then VALUE="Input Parameter Path_Progs is null but standard study Pfizer setup location does not exist";	                            
		                        run;
		                        %goto macerr; 
  		            		  %end;
  		            	%end;
  		            	%else %do;
    		            		%if %sysfunc(fileexist(&Path_Progs)) %then %do;
                            %* File directory exists;
    		            		%end;
    		            		%else %do;
		                        %LogMessageOutput(e, 
		                            %str(Input parameter Path_Progs is not a valid directory @Path_Progs=&Path_Progs),
		                            pfesacq_csdw_auto -> CheckInput -> CK8);

		                        data EMAIL_PXL;
		                            set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_Progs is not a valid directory, Path_Progs=&Path_Progs";	                            
		                        run;
		                        %goto macerr; 
    		            		%end;		            		
  		            	%end;

  		            	%* Verify expected sacq mapping driver exists;
  		            	%if NOT %sysfunc(fileexist(&Path_Progs/run_pfesacq_map_scrf.sas)) %then %do;
                        %LogMessageOutput(e, 
                            %str(File run_pfesacq_map_scrf.sas does not exist in Input Parameter Path_Progs 
                            	@File = &Path_Progs/run_pfesacq_map_scrf.sas),
                            pfesacq_csdw_auto -> CheckInput -> CK8);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                            if DESC="Source Data Checks Status" then VALUE="FAILED";
                            if DESC="Source Data Checks Msg" then VALUE="File run_pfesacq_map_scrf.sas does not exist in Input Parameter Path_Progs, File = &&Path_Progs/run_pfesacq_map_scrf.sas";	                            
                        run;
                        %goto macerr; 		            		
  		            	%end;

		                %LogMessageOutput(n, Input Parameter Path_Progs = &Path_Progs, pfesacq_csdw_auto -> CheckInput -> CK8);
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:; 

  		            	%LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK8);                   
		            %mend CK8;

				      %* MACRO: CK9 
	             * PURPOSE: Check Input Parameter Path_Metadata
	             * INPUT: 
	             *   1) Macro Variable Path_Metadata
	             *   2) Macro Variable EMAIL_PXL
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
	             *; 
		            %macro CK9;
  		            	%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK9);

  		            	%local path_sacq_metadata;
  		            	%let path_sacq_metadata = /projects/std_pfizer/sacq/metadata;

  		            	%if %str("&Path_Metadata") = "null" %then %do;
  		            		  %if %sysfunc(fileexist(&path_sacq_metadata)) %then %do;
                            %* If null then use expected standard Pfizer study setup;
                            %let Path_Metadata = &path_sacq_metadata;
                            %LogMessageOutput(n,Path_Metadata taken from standard Pfizer setup location,pfesacq_csdw_auto -> CheckInput -> CK9);
                        %end;
                        %else %do;
                            %* If null then use expected standard Pfizer study setup but it does not exist issue;
                            %LogMessageOutput(e, 
                                %str(Input Parameter Path_Metadata is null
                                @but standard study Pfizer setup location does not exist
                                @Expected Directory = &path_sacq_metadata),
                                pfesacq_csdw_auto -> CheckInput -> CK9);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Input Parameter Path_Metadata is null but standard study Pfizer setup location does not exist";	                            
                            run;
                            %goto macerr; 
                        %end;
                    %end;
                    %else %do;
                        %if %sysfunc(fileexist(&Path_Metadata)) %then %do;
                            %* File directory exists;
                        %end;
                        %else %do;
                            %LogMessageOutput(e, 
                                %str(Input parameter Path_Metadata is not a valid directory @Path_Metadata=&Path_Metadata),
                                pfesacq_csdw_auto -> CheckInput -> CK9);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_Metadata is not a valid directory, Path_Metadata=&Path_Metadata";	                            
                            run;
                            %goto macerr; 
                        %end;		            		
                    %end;

  	                %LogMessageOutput(n, %str(Input Parameter Path_Metadata = &Path_Metadata), pfesacq_csdw_auto -> CheckInput -> CK9);
  	                %goto macend;

  	                %macerr:;
  	                %let RC = 1;

  	                %macend:; 

  		            	%LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK9);                   
		            %mend CK9;

				      %* MACRO: CK10 
	             * PURPOSE: Check metadata expected data exists
	             * INPUT: 
	             *   1) Macro Variable Path_Metadata
	             *   2) Macro Variable EMAIL_PXL
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
	             *; 
		            %macro CK10;
  		            	%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK10);

  		            	%* /data folder required;
  		            	%if NOT %sysfunc(fileexist(&Path_Metadata/data)) %then %do;
                        %LogMessageOutput(e, 
                            %str(Expected metadata directory /data not found
                            	@Path_Metadata = &Path_Metadata),
                            pfesacq_csdw_auto -> CheckInput -> CK10);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                        	  if DESC="Source Data Checks Status" then VALUE="FAILED";
                        	  if DESC="Source Data Checks Msg" then VALUE="Expected metadata directory /data not found";	                            
                        run;
                        %goto macerr;
  		            	%end;

  		            	%* /data/dex_emails.csv required - get DEX team emails;
  						      %if NOT %sysfunc(fileexist(&Path_Metadata/data/dex_emails.csv)) %then %do;
                        %LogMessageOutput(e, 
                            %str(Expected metadata file /data/dex_emails.csv not found
                            	@Path_Metadata = &Path_Metadata),
                            pfesacq_csdw_auto -> CheckInput -> CK10);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                            if DESC="Source Data Checks Status" then VALUE="FAILED";
                            if DESC="Source Data Checks Msg" then VALUE="Expected metadata file /data/dex_emails.csv not found";	                            
                        run;
                        %goto macerr;
  		            	%end;

  		            	%* /data/pfe_emails.csv required - get pfizer emails;
  						      %if NOT %sysfunc(fileexist(&Path_Metadata/data/pfe_emails.csv)) %then %do;
                        %LogMessageOutput(e, 
                            %str(Expected metadata file /data/pfe_emails.csv not found
                            	@Path_Metadata = &Path_Metadata),
                            pfesacq_csdw_auto -> CheckInput -> CK10);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                            if DESC="Source Data Checks Status" then VALUE="FAILED";
                            if DESC="Source Data Checks Msg" then VALUE="Expected metadata file /data/pfe_emails.csv not found";
                        run;
                        %goto macerr;
  		            	%end;

  		            	%* /transfer_data folder required;
  		            	%if NOT %sysfunc(fileexist(&Path_Metadata/transfer_data)) %then %do;
                        %LogMessageOutput(e, 
                            %str(Expected metadata directory /transfer_data not found
                            	@Path_Metadata = &Path_Metadata),
                            pfesacq_csdw_auto -> CheckInput -> CK10);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                            if DESC="Source Data Checks Status" then VALUE="FAILED";
                            if DESC="Source Data Checks Msg" then VALUE="Expected metadata directory /transfer_data not found";	                            
                        run;
                        %goto macerr;
  		            	%end;

		                %LogMessageOutput(n, %str(Verified metadata expected data exists), pfesacq_csdw_auto -> CheckInput -> CK10);
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:; 

                    %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK10);                   
		            %mend CK10;

				      %* MACRO: CK11 
               * PURPOSE: Check metadata dex_emails.csv load is successiful
               * INPUT: 
               *   1) Macro Variable Path_Metadata
               *   2) File %Path_Metadata/data/dex_emails.csv
               *   3) Macro variable dex_emails
               * OUTPUT:
               *   1)  Macro Variable RC - 1 if fail or 0 if pass
               *   2)  Macro Variable EMAIL_PXL     
               *   3) Macro variable dex_emails
               *   4) Macro variable pfe_emails
               *; 
		            %macro CK11;
		                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK11);

				            %let dex_emails = ; %* DEX Team Email Contacts from loaded metadata;            	

		         		    %* Get DEX Email contacts from metadata pfe_emails.csv file;
	         		      proc import datafile="&Path_Metadata/data/dex_emails.csv"
                        out=dex_emails
                        dbms=csv
                        replace;
                        getnames=no;
                    run;

                    %* Check for successiful load of emails;
                    %if NOT %sysfunc(exist(dex_emails)) %then %do;
                        %LogMessageOutput(e, 
                            %str(Error reading dex_emails.csv from 
                            	@&Path_Metadata/data/),
                            pfesacq_csdw_auto -> CheckInput -> CK11);

                        data EMAIL_PXL;
                            set EMAIL_PXL;
                            if DESC="Source Data Checks Status" then VALUE="FAILED";
                            if DESC="Source Data Checks Msg" then VALUE="Error reading dex_emails.csv from &Path_Metadata/data/";
                        run;
                        %goto macerr;		                    	
                    %end;

		                %* study_contacts should have emails entered as:
		                 * na@parexel.com - n/a so do not use
		                 * tbd@parexel.com - to be determined so do not use
		                 * me@parexel.com - one email
		                 * or use a semi colon to seperate for more 2+ emails;
		                data _null_;
		                    length emails var1 $1500.;
		                    retain emails;
		                    set dex_emails end=eof;

		                    if _n_ = 1 then emails = '';

		                    if not missing(VAR1) and VAR1 ne 'na@parexel.com' then do;
		                        VAR1 = tranwrd(VAR1, ';', "' '"); * Handle multiple email addresse;
		                        VAR1 = compress(VAR1,' ');
		                        emails = catx("", emails, "'", VAR1, "'");
		                    end;

		                    if eof then do;
		                        if not missing(emails) then do;
		                            emails = compress(emails);
		                            emails = strip(tranwrd(emails, "''", "' '"));
		                            call symput('dex_emails', emails);
		                        end;
		                    end;
		                run;

  			            %put NOTE:[PXL] pfesacq_csdw_auto -> CheckInput -> CK11: DEX Email Contacts=%left(%trim(&dex_emails));
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:; 

  		            	%LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK11);                   
		            %mend CK11;

				      %* MACRO: CK12 
	             * PURPOSE: Check metadata pfe_emails.csv load is successiful
	             * INPUT: 
	             *   1) Macro Variable Path_Metadata
	             *   2) File %Path_Metadata/data/dex_emails.csv
               *   3) Macro variable pfe_emails
	             * OUTPUT:
	             *   1)  Macro Variable RC - 1 if fail or 0 if pass
	             *   2)  Macro Variable EMAIL_PXL     
               *   3) Macro variable pfe_emails
	             *; 
                    %macro CK12;
                        %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK12);

                        %let pfe_emails = ; %* Ffizer Email Contacts from loaded metadata;		            	

    	         		      %* Get DEX Email contacts from metadata pfe_emails.csv file;
    	         		      proc import datafile="&Path_Metadata/data/pfe_emails.csv"
                            out=pfe_emails
                            dbms=csv
                            replace;
                            getnames=no;
    	                  run;

                        %* Check for successiful load of emails;
                        %if NOT %sysfunc(exist(pfe_emails)) %then %do;
                            %LogMessageOutput(e, 
                                %str(Error reading pfe_emails.csv from 
                                	@&Path_Metadata/data/),
                                pfesacq_csdw_auto -> CheckInput -> CK12);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Error reading pfe_emails.csv from &Path_Metadata/data/";
                            run;
                            %goto macerr;		                    	
                        %end;

		                %* study_contacts should have emails entered as:
		                 * na@parexel.com - n/a so do not use
		                 * tbd@parexel.com - to be determined so do not use
		                 * me@parexel.com - one email
		                 * or use a semi colon to seperate for more 2+ emails;
		                data _null_;
		                    length emails var1 $1500.;
		                    retain emails;
		                    set pfe_emails end=eof;

		                    if _n_ = 1 then emails = '';

		                    if not missing(VAR1) and VAR1 ne 'na@parexel.com' then do;
		                        VAR1 = tranwrd(VAR1, ';', "' '"); * Handle multiple email addresse;
		                        VAR1 = compress(VAR1,' ');
		                        emails = catx("", emails, "'", VAR1, "'");
		                    end;

		                    if eof then do;
		                        if not missing(emails) then do;
		                            emails = compress(emails);
		                            emails = strip(tranwrd(emails, "''", "' '"));
		                            call symput('pfe_emails', emails);
		                        end;
		                    end;
		                run;

                    %put NOTE:[PXL] pfesacq_csdw_auto -> CheckInput -> CK12: Pfizer Email Contacts=%left(%trim(&pfe_emails));;
		                %goto macend;

		                %macerr:;
		                %let RC = 1;

		                %macend:; 

                    %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK12);                   
		            %mend CK12;

              %* MACRO: CK13 
               * PURPOSE: Check Input parameter Path_CAL a valid directory
               * INPUT: 
               *   1) Input parameter Path_CAL
               *   2) Macro Variable EMAIL_PXL 
               * OUTPUT:
               *   1) Macro Variable RC - 1 if fail or 0 if pass
               *   2) Macro Variable EMAIL_PXL     
               *   3) Input parameter Path_CAL
               *; 
                %macro CK13;
                    %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK13);

                    %local path_cal_default;
                    %*let path_cal_default = /projects/std_pfizer/sponsor/data/csdw;
                    %let path_cal_default = &Path_SACQRoot./archive;

                    %if %str("&Path_CAL") = "null" %then %do;
                        %if %sysfunc(fileexist(&path_cal_default)) %then %do;
                            %* If null then use expected standard Pfizer CAL load location;
                            %let Path_CAL = &path_cal_default;
                            %LogMessageOutput(n,Path_CAL taken from standard Pfizer setup location,pfesacq_csdw_auto -> CheckInput -> CK13);
                        %end;
                        %else %do;
                            %* If null then use expected standard Pfizer study setup but it does not exist issue;
                            %LogMessageOutput(e, 
                                %str(Input Parameter Path_CAL is null
                                @but standard study Pfizer setup location does not exist
                                @Expected Directory = &path_cal_default),
                                pfesacq_csdw_auto -> CheckInput -> CK13);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Input Parameter Path_CAL is null but standard study Pfizer setup location does not exist";                                
                            run;
                            %goto macerr;
                        %end;
                    %end;
                    %else %do;
                        %if %sysfunc(fileexist(&Path_CAL)) %then %do;
                            %* File directory exists;
                            %* If /transfer or /archive do not exist then create;
                            %if NOT %sysfunc(fileexist(&Path_CAL/archive)) %then %do;
                                %sysexec %str(mkdir -p &Path_CAL/archive);
                            %end;
                            %if NOT %sysfunc(fileexist(&Path_CAL/transfer)) %then %do;
                                %sysexec %str(mkdir -p &Path_CAL/transfer);
                            %end;
                        %end;
                        %else %do;
                            %LogMessageOutput(e, 
                                %str(Input parameter Path_CAL is not a valid directory @Path_CAL=&Path_CAL),
                                pfesacq_csdw_auto -> CheckInput -> CK13);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_CAL is not a valid directory, Path_CAL=&Path_CAL";                             
                            run;
                            %goto macerr; 
                        %end;                           
                    %end;

                    %LogMessageOutput(n, %str(Path_CAL = &Path_CAL), pfesacq_csdw_auto -> CheckInput -> CK13);
                    %goto macend;

                    %macerr:;
                    %let RC = 1;

                    %macend:; 

                    %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK13);
                %mend CK13;                    		            

              %* MACRO: CK14 
               * PURPOSE: Check metadata Path_StudyContacts/study_contacts.csv load is successiful
               * INPUT: 
               *   1) Macro Variable Path_StudyContacts
               *   2) File %Path_Metadata/data/dex_emails.csv
               *   3) Macro variable pfe_emails
               * OUTPUT:
               *   1) Macro Variable RC - 1 if fail or 0 if pass
               *   2) Macro Variable EMAIL_PXL     
               *   3) Macro variable pfe_emails
               *; 
                    %macro CK14;
                        %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK14);

                        %let study_emails = ; %* Study CDBPSAS Email Contacts Primary and Backup from loaded metadata;
                        %let stat_emails = ; %* Study Stat Email Contacts Primary and Backup from loaded metadata;
                        %let pcda_emails = ; %* Study PCDA Email Contacts;

                        %local path_Path_StudyContacts_default;
                        %let path_Path_StudyContacts_default = /projects/pfizr%left(%trim(&In_PXL_Code))/macros;

                        %* Verify exists;
                            %if %str("&Path_StudyContacts") = "null" %then %do;
                                %if %sysfunc(fileexist(&path_Path_StudyContacts_default/study_contacts.csv)) %then %do;
                                    %* If null then use expected standard Pfizer CAL load location;
                                    %let Path_StudyContacts = &path_Path_StudyContacts_default;
                                    %LogMessageOutput(n,Path_StudyContacts taken from standard Pfizer setup location,pfesacq_csdw_auto -> CheckInput -> CK14);
                                %end;
                                %else %do;
                                    %* If null then use expected standard Pfizer study setup but it does not exist issue;
                                    %LogMessageOutput(e, 
                                        %str(Input Parameter Path_StudyContacts is null
                                        @but standard study Pfizer setup location does not exist
                                        @Expected = &path_Path_StudyContacts_default/study_contacts.csv),
                                        pfesacq_csdw_auto -> CheckInput -> CK14);

                                    data EMAIL_PXL;
                                        set EMAIL_PXL;
                                        if DESC="Source Data Checks Status" then VALUE="FAILED";
                                        if DESC="Source Data Checks Msg" then 
                                            VALUE=catx(" ","Input Parameter Path_StudyContacts is null but standard study Pfizer setup",
                                                "location does not exist, Path=&path_Path_StudyContacts_default/study_contacts.csv");
                                    run;
                                    %goto macerr;
                                %end;
                            %end;
                            %else %do;
                                %if %sysfunc(fileexist(&Path_StudyContacts/study_contacts.csv)) %then %do;
                                    %* File exists;
                                %end;
                                %else %do;
                                    %LogMessageOutput(e, 
                                        %str(File Path_StudyContacts/study_contacts.csv does not exist @File = &Path_StudyContacts/study_contacts.csv),
                                        pfesacq_csdw_auto -> CheckInput -> CK14);

                                    data EMAIL_PXL;
                                        set EMAIL_PXL;
                                        if DESC="Source Data Checks Status" then VALUE="FAILED";
                                        if DESC="Source Data Checks Msg" then VALUE="File Path_StudyContacts/study_contacts.csv does not exist, File = &Path_StudyContacts/study_contacts.csv";                             
                                    run;
                                    %goto macerr; 
                                %end;                           
                            %end;                        

                        %* Load and verify load;
                            %pfestudy_contacts(
                                In_Path_Study_Contacts = &Path_StudyContacts,
                                Out_MV_Emails_CDBP     = study_emails,
                                Out_MV_Emails_Stat     = stat_emails,
                                Out_MV_Emails_PCDA     = pcda_emails);

                        %goto macend;

                        %macerr:;
                        %let RC = 1;

                        %macend:; 

                        %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK14);                   
                    %mend CK14;                    

              %* MACRO: CK15 
               * PURPOSE: Check Input Parameter Path_DownloadRoot
               * INPUT: 
               *   1) Macro Variable Path_DownloadRoot
               *   2) Macro Variable EMAIL_PXL
               * OUTPUT:
               *   1)  Macro Variable RC - 1 if fail or 0 if pass
               *   2)  Macro Variable EMAIL_PXL   
               *; 
                %macro CK15;
                    %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK15);

                    %* 
                     * 1) Path_DownloadRoot = null and standard location does not exist
                     * 2) Path_DownloadRoot <> null and input parameter given does not exist
                     * 3) Path_DownloadRoot does not contain a dated folder
                     *;
                    
                    %if %str("&Path_DownloadRoot") = "null" %then %do;                    
                        %if %sysfunc(fileexist(/projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/download)) %then %do;
                            %* If null then use expected standard Pfizer study setup;
                            %let Path_DownloadRoot = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/download;
                        %end;
                        %else %do;
                            %* If null then use expected standard Pfizer study setup but it does not exist issue;
                            %LogMessageOutput(e, 
                                %str(Input Parameter Path_DownloadRoot is null
                                  ,@but standard study Pfizer setup location does not exist
                                  ,@Expected Directory = /projects/pfizr%left(%trim(&In_PXL_Code))/dm/datasets/download),
                                pfesacq_csdw_auto -> CheckInput -> CK15);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Input Parameter Path_DownloadRoot is null but standard study Pfizer setup location does not exist";                              
                            run;
                            %goto macerr; 
                        %end;
                    %end;
                    %else %do;
                        %if %sysfunc(fileexist(&Path_DownloadRoot)) %then %do;
                            %* File exists and no issues;
                        %end;
                        %else %do;
                            %LogMessageOutput(e, 
                                %str(Input parameter Path_DownloadRoot is not a valid directory, @Path_DownloadRoot=&Path_DownloadRoot),
                                pfesacq_csdw_auto -> CheckInput -> CK15);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                              if DESC="Source Data Checks Status" then VALUE="FAILED";
                              if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_DownloadRoot is not a valid directory, Path_DownloadRoot=&Path_DownloadRoot";                             
                            run;
                            %goto macerr; 
                        %end;                   
                    %end;

                    %LogMessageOutput(n, Input Parameter Path_DownloadRoot = &Path_DownloadRoot, pfesacq_csdw_auto -> CheckInput -> CK15);
                    %goto macend;

                    %macerr:;
                    %let RC = 1;

                    %macend:; 

                    %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK15);                   
                %mend CK15;                      

              %* MACRO: CK16 
               * PURPOSE: Check Input Parameter Path_DownloadRoot and Path_SCRFRoot Match
               * INPUT: 
               *   1) Macro Variable Path_DownloadRoot
               *   2) Macro Variable Path_SCRFRoot
               *   3) Macro Variable EMAIL_PXL
               * OUTPUT:
               *   1)  Macro Variable RC - 1 if fail or 0 if pass
               *   2)  Macro Variable EMAIL_PXL   
               *; 
                %macro CK16;
                    %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckInput -> CK16);
                                    
                    %* Purpose: Raw data download dated folder must match source SCRF data dated folder to ensure matching data sent;
                    %local flag LatestDatedFolder LatestDatedFolder_Download LatestDatedFolder_SCRF;

                    %Step1:;

                    %let flag = ; %* Used as temporary flag;
                    %let LatestDatedFolder = ; %* Used as temporary return submacro value;
                    %let LatestDatedFolder_Download = ;
                    %let LatestDatedFolder_SCRF = ;

                    %* Step 1: Get latest dated Download folder;
                        %LogMessageOutput(n, Input Parameter Path_DownloadRoot = &Path_DownloadRoot, pfesacq_csdw_auto -> CheckInput -> CK16);
                        %local LatestDatedFolder;
                        %GetLatestDatedFolder(Path=&Path_DownloadRoot, MacroPath=pfesacq_csdw_auto -> CheckInput -> CK16 -> GetLatestDatedFolder);
                        %let LatestDatedFolder_Download = &LatestDatedFolder;

                        %if "&LatestDatedFolder_Download" = "null" %then %do;
                            %LogMessageOutput(e, Download dated folder not matched to SCRF which is not possible., pfesacq_csdw_auto -> CheckInput -> CK16);
                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then 
                                    VALUE=catx(" ","Download dated folder not matched to SCRF which is not possible");
                            run;
                            %goto MacErr;
                        %end;

                    %* Step 2: Get latest dated SCRF folder;
                        %LogMessageOutput(n, Input Parameter Path_SCRFRoot = &Path_SCRFRoot, pfesacq_csdw_auto -> CheckInput -> CK16);
                        %local LatestDatedFolder;
                        %GetLatestDatedFolder(Path=&Path_SCRFRoot, MacroPath=pfesacq_csdw_auto -> CheckInput -> CK16 -> GetLatestDatedFolder);
                        %let LatestDatedFolder_SCRF = &LatestDatedFolder;                   

                        %put ;
                        %LogMessageOutput(n, Lastest Download dated folder=&LatestDatedFolder_Download, pfesacq_csdw_auto -> CheckInput -> CK16);
                        %LogMessageOutput(n, Lastest Download dated folder=&LatestDatedFolder_SCRF, pfesacq_csdw_auto -> CheckInput -> CK16);
                        %put ;

                    %* Step 3: latest dated Download folder = latest dated SCRF folder? Then goto step 6;
                        %if %eval(&LatestDatedFolder_Download = &LatestDatedFolder_SCRF) %then %do;
                            %LogMessageOutput(n, 
                                Lastest Download dated folder (%left(%trim(&LatestDatedFolder_Download))) = Lastest SCRF dated folder (%left(%trim(&LatestDatedFolder_SCRF))), 
                                pfesacq_csdw_auto -> CheckInput -> CK16);
                            %goto Step6; %* Set symbolic links current;
                        %end;

                    %* Step 4: latest dated Download folder < latest dated SCRF folder? Then FAIL CK16 check, raw data can not possible 
                               be before scrf dated folder and goto MACERR;
                        %if %eval(&LatestDatedFolder_Download < &LatestDatedFolder_SCRF) %then %do;
                            %LogMessageOutput(e, 
                                Lastest Download dated folder (%left(%trim(&LatestDatedFolder_Download))) < Lastest SCRF dated folder (%left(%trim(&LatestDatedFolder_SCRF))), 
                                pfesacq_csdw_auto -> CheckInput -> CK16);
                            %LogMessageOutput(e, Download dated folder earlier than SCRF which is not possible., pfesacq_csdw_auto -> CheckInput -> CK16);
                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then 
                                    VALUE=catx(" ","Input Parameter Path_DownloadRoot latest date (%left(%trim(&LatestDatedFolder_Download))) folder less than",
                                      "Path_SCRFRoot latest date folder (%left(%trim(&LatestDatedFolder_SCRF)))");
                            run;
                            %goto MacErr;
                        %end;

                    %* Step 5: latest dated Download folder > latest dated SCRF folder? Then rename latest dated Download fodler to 
                               error_YYYYMMDD and goto to step 1;
                        %if %eval(&LatestDatedFolder_Download > &LatestDatedFolder_SCRF) %then %do;
                            %LogMessageOutput(n, 
                                Lastest Download dated folder (%left(%trim(&LatestDatedFolder_Download))) > Lastest SCRF dated folder (%left(%trim(&LatestDatedFolder_SCRF))), 
                                pfesacq_csdw_auto -> CheckInput -> CK16);    

                            %* Rename to error_YYYYMMDD;
                            %sysexec %str(rm -rf &Path_DownloadRoot/error_%left(%trim(&LatestDatedFolder_Download)) 2> /dev/null);
                            %sysexec %str(mv &Path_DownloadRoot/%left(%trim(&LatestDatedFolder_Download)) &Path_DownloadRoot/error_%left(%trim(&LatestDatedFolder_Download))  2> /dev/null);   

                            %if %sysfunc(fileexist(&Path_DownloadRoot/%left(%trim(&LatestDatedFolder_Download)))) %then %do;
                                %LogMessageOutput(e, 
                                    Rename Download to error_ failed for &Path_DownloadRoot/%left(%trim(&LatestDatedFolder_Download)), 
                                    pfesacq_csdw_auto -> CheckInput -> CK16);
                                data EMAIL_PXL;
                                    set EMAIL_PXL;
                                    if DESC="Source Data Checks Status" then VALUE="FAILED";
                                    if DESC="Source Data Checks Msg" then 
                                        VALUE=catx(" ","Rename Download to error_ failed for &Path_DownloadRoot/%left(%trim(&LatestDatedFolder_Download))");
                                run;
                                %goto MacErr;
                            %end; 
                            
                            %goto Step1; %* Continue until get match on download and SACQ;
                        %end;

                    %* Step 6: Create symbolic link current and point to latest dated folder;
                        %Step6:;
                        data _null_;
                            command1 = 'cd ' || "&Path_DownloadRoot" ;
                            command2 = 'rm ' || "current" ;                            
                            command3 = 'umask 0003' ;
                            command4 = 'ln -s ' || "%left(%trim(&LatestDatedFolder_Download)) current" ;
                            rc1 = system(command1) ;
                            rc2 = system(command2) ;
                            rc3 = system(command3) ;
                            rc4 = system(command4) ;
                        run ;

                    %* Step 7: If SCRF symbolic link current exists, create and point to latest dated folder;
                        data _null_;
                            command1 = 'cd ' || "&Path_SCRFRoot" ;
                            command2 = 'rm ' || "current" ;                            
                            command3 = 'umask 0003' ;
                            command4 = 'ln -s ' || "%left(%trim(&LatestDatedFolder_SCRF)) current" ;
                            rc1 = system(command1) ;
                            rc2 = system(command2) ;
                            rc3 = system(command3) ;
                            rc4 = system(command4) ;
                        run ;

                    %* Step 8: At least one raw dataset exists? If yes, then go to MACEND else go to MACERR;
                        libname LIB_DOWN "&Path_DownloadRoot/%left(%trim(&LatestDatedFolder_Download))";
                        %local EXISTS;
                        proc sql noprint;
                            select count(*) into: EXISTS
                            from sashelp.vstable
                            where libname = 'LIB_DOWN';
                        quit;
                        %if &EXISTS = 0 %then %do;
                            %LogMessageOutput(e, 
                                %str(Input parameter Path_DownloadRoot folder %left(%trim(&LatestDatedFolder_Download)) requires at least one raw dataset @Path_DownloadRoot=&Path_DownloadRoot),
                                pfesacq_csdw_auto -> CheckInput -> CK16);

                            data EMAIL_PXL;
                                set EMAIL_PXL;
                                if DESC="Source Data Checks Status" then VALUE="FAILED";
                                if DESC="Source Data Checks Msg" then VALUE="Input parameter Path_DownloadRoot folder %left(%trim(&LatestDatedFolder_Download)) requires at least one raw dataset Path_DownloadRoot=&Path_DownloadRoot";                             
                            run;
                            %goto macerr; 
                        %end;                        

                    %* End of submacro;
                        %goto macend;

                        %macerr:;
                        %let RC = 1;

                        %macend:; 

                    %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckInput -> CK16);                   
                %mend CK16;                      

	            %CK1; %if &RC = 1 %then %goto macerr; %* Global Macro GMPXLERR is valid;
	            %CK2; %if &RC = 1 %then %goto macerr; %* Global Macro DEBUG is valid;
	            %CK3; %if &RC = 1 %then %goto macerr; %* Input Parameter In_PXL_Code;
	            %CK4; %if &RC = 1 %then %goto macerr; %* Check Input Parameter In_Protocol;
	            %CK5; %if &RC = 1 %then %goto macerr; %* Check Input Parameter In_ForceRun;
	            %CK6; %if &RC = 1 %then %goto macerr; %* Check Input Parameter Path_SACQRoot;
	            %CK7; %if &RC = 1 %then %goto macerr; %* Check Input Parameter Path_SCRFRoot;
	            %CK8; %if &RC = 1 %then %goto macerr; %* Check Input Parameter Path_Progs;
	            %CK9; %if &RC = 1 %then %goto macerr; %* Check Input Parameter Path_Metadata;
	            %CK10; %if &RC = 1 %then %goto macerr; %* Check metadata expected data exists;
	            %CK11; %if &RC = 1 %then %goto macerr; %* Check metadata dex_emails.csv load is successiful;
	            %CK12; %if &RC = 1 %then %goto macerr; %* Check metadata pfe_emails.csv load is successiful;
              %CK13; %if &RC = 1 %then %goto macerr; %* Check Input parameter Path_CAL a valid directory;
              %CK14; %if &RC = 1 %then %goto macerr; %* Check metadata Path_StudyContacts/study_contacts.csv load is successiful;
              %CK15; %if &RC = 1 %then %goto macerr; %* Check Input Parameter Path_DownloadRoot;
              %CK16; %if &RC = 1 %then %goto macerr; %* Check Input Parameter Path_DownloadRoot and Path_SCRFRoot Match;

	            %* INPUT_CHECKS - PASS;
	            	  %LogMessageOutput(n, CheckInput All Checks PASSED, pfesacq_csdw_auto -> CheckInput);
	                data EMAIL_PXL;
	                    set EMAIL_PXL;
                    	if DESC="Source Data Checks Status" then VALUE="PASSED";
                    	if DESC="Source Data Checks Msg" then VALUE="";
	                run;
	                %goto macend;

	            %* INPUT_CHECKS - FAIL;
	                %macerr:;
	                %let GMPXLERR = 1;
	    			      %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto -> CheckInput);

	            %* End of Submacro;
	                %macend:;              
	                %LogMessageOutput(i, End of SubMacro, pfesacq_csdw_auto -> CheckInput);
	        %mend CheckInput;

        %* MACRO: CheckRunNeed
         * PURPOSE: Verify if SACQ transfer is needed
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable In_ForceRun
         *   4) Macro variable Path_SACQRoot
         *   5) Macro variable Path_SCRFRoot
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *      3) RC = 2 if no error and no need to run
         *   2) Work Dataset EMAIL_PXL
         *;
         	%macro CheckRunNeed;
              %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckRunNeed);

              %* Derive latest dated folder and libraries;
         			%let RC = 0;
            	%local LatestDatedFolder LatestDatedFolder_SACQ LatestDatedFolder_SCRF LatestDateTime_SACQ LatestDateTime_SCRF;
            	%let LatestDatedFolder = ;
            	%let LatestDatedFolder_SACQ = ;
            	%let LatestDatedFolder_SCRF = ;
            	%let LatestDateTime_SACQ = ;
            	%let LatestDateTime_SCRF = ;

              %GetLatestDatedFolder(Path=%str(&Path_SACQRoot), MacroPath=pfesacq_csdw_auto -> CheckRunNeed -> GetLatestDatedFolder);
              %let LatestDatedFolder_SACQ = &LatestDatedFolder;
              %if %str("&LatestDatedFolder_SACQ") ne "null" %then %do;
						      libname LIB_SACQ "&Path_SACQRoot/&LatestDatedFolder_SACQ";

  	         			proc sql noprint;
    	         				select max(crdate) as crdate format = datetime20. into: LatestDateTime_SACQ
    	         				from sashelp.Vtable 
    	         				where libname = "LIB_SACQ";
  	         			quit;
         			    %if &LatestDateTime_SACQ < 0 %then %let LatestDateTime_SACQ = null;
              %end;

    					%GetLatestDatedFolder(Path=%str(&Path_SCRFRoot), MacroPath=pfesacq_csdw_auto -> CheckRunNeed -> GetLatestDatedFolder);
    					%let LatestDatedFolder_SCRF = &LatestDatedFolder;
    					libname LIB_SCRF "&Path_SCRFRoot/&LatestDatedFolder_SCRF"; *% Always exists as checked previously;
    					%put ;

         			proc sql noprint;
           				select max(crdate) as crdate format = datetime20. into: LatestDateTime_SCRF
           				from sashelp.Vtable 
           				where libname = "LIB_SCRF";
         			quit;

              %* In_ForceRun = YES then run required;
	         		%if %str("&In_ForceRun") = "YES" %then %do;
                  %LogMessageOutput(n, %str(Input Parameter In_ForceRun = YES), pfesacq_csdw_auto -> CheckRunNeed);
                  %goto macRun;	         			
	         		%end;

              %* SACQ dated folder is null then run required;
              %* Verify at least one dated YYYYMMDD folder exists;
              %if %str("&LatestDatedFolder_SACQ") = "null" %then %do;
                  %LogMessageOutput(n, %str(No SACQ Dated Folder Found), pfesacq_csdw_auto -> CheckRunNeed);
                  %goto macRun;
              %end;

              %* SCRF dated folder later than SACQ dated folder then run required;
              %if %eval(&LatestDatedFolder_SCRF > &LatestDatedFolder_SACQ) %then %do;
                  %LogMessageOutput(n, %str(Latest SCRF Folder [%left(%trim(&LatestDatedFolder_SCRF))] > Latest SACQ Folder [%left(%trim(&LatestDatedFolder_SACQ))]), pfesacq_csdw_auto -> CheckRunNeed);
                  %goto macRun;
              %end;

              %* SCRF dated folder = SACQ dated folder and no SACQ files exist then run required;
              %if %eval(&LatestDatedFolder_SCRF = &LatestDatedFolder_SACQ) %then %do;
                  %if %str("&LatestDateTime_SACQ") = "null" %then %do;
                      %LogMessageOutput(n, %str(SCRF and SACQ latest dated folders same %left(%trim(&LatestDatedFolder_SCRF)) and no SACQ files found), 
                      pfesacq_csdw_auto -> CheckRunNeed);
                      %goto macRun;         					
                  %end;
              %end;

              %* SCRF dated folder = SACQ dated folder and SCRF latest datetime file > SACQ latest then run required;
              %if %eval(&LatestDatedFolder_SCRF = &LatestDatedFolder_SACQ) %then %do;
                  %if %eval(&LatestDateTime_SCRF > &LatestDateTime_SACQ) %then %do;
                      %LogMessageOutput(n, %str(SCRF and SACQ folders same and SCRF DateTime greater than SACQ), 
                      pfesacq_csdw_auto -> CheckRunNeed);
                      %goto macRun;         					
                  %end;
              %end;

              %macNoRun:;
              %* SACQ Transfer is NOT needed;
              %LogMessageOutput(n, %str(SACQ Transfer NOT Required), pfesacq_csdw_auto -> CheckRunNeed);
              %let RC =2;
              data EMAIL_PXL;
                  set EMAIL_PXL;
                  if DESC="Overall Status" then VALUE="N/A";
                  if DESC="SACQ Transfer Need Status" then VALUE="NO";
              run;		            
              %goto macend; 

	            %macRun:;
            	%* SACQ Transfer is needed;
         			%LogMessageOutput(n, %str(SACQ Transfer Required), pfesacq_csdw_auto -> CheckRunNeed);
         			%let RC = 0;
        			data EMAIL_PXL;
                	set EMAIL_PXL;
                	
                  %if %str("&In_ForceRun") = "YES" %then %do;
                      if DESC="SACQ Transfer Need Status" then VALUE="YES";
                      if DESC="SACQ Transfer Need Msg" then 
                          VALUE=catx(" ","Parameter In_ForceRun = YES: SCRF Source Folder=",
                            "%left(%trim(&LatestDatedFolder_SCRF))",
                            "Latest File DateTime=",
                            "%left(%trim(&LatestDateTime_SCRF))");
                  %end;
                  %else %do;
                      if DESC="SACQ Transfer Need Status" then VALUE="YES";
                      if DESC="SACQ Transfer Need Msg" then 
                        VALUE=catx(" ","SCRF Source Folder=",
                          "%left(%trim(&LatestDatedFolder_SCRF))",
                          "Latest File DateTime=",
                          "%left(%trim(&LatestDateTime_SCRF))");
                  %end;
            	run;

              %macend:;
	                %put ;
	                %put NOTE:[PXL] -----------------------------------------------------------------;
	                %if &RC = 0 %then %do; %put NOTE:[PXL] SACQ Transfer Need Status = YES; %end;
	                %if &RC = 2 %then %do; %put NOTE:[PXL] SACQ Transfer Need Status = NO; %end;
	                %put NOTE:[PXL] Latest Dated Folder SACQ = &LatestDatedFolder_SACQ;
	                %put NOTE:[PXL] Latest Dated Folder SCRF = &LatestDatedFolder_SCRF;
	                %put NOTE:[PXL] Latest DateTime SACQ = &LatestDateTime_SACQ;
	                %put NOTE:[PXL] Latest DateTime SCRF = &LatestDateTime_SCRF;
	                %put NOTE:[PXL] -----------------------------------------------------------------;
	                %put ;
              %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckRunNeed);
         	%mend CheckRunNeed;

        %* MACRO: RUN_PFESACQ_MAP_SCRF
         * PURPOSE: Run study driver run_pfesacq_map_scrf.sas file
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable Path_Progs
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *;
         	%macro run_pfesacq_map_scrf;
              %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> run_pfesacq_map_scrf);

              %let RC = 0;

              %* If previous SACQ transfer exists for today then copy .zip and .xls to archive and delete files;
              %local cur_date path_sacq_archive path_sacq_curdate;
              %let cur_date = %sysfunc(left(%sysfunc(date(), yymmddn8.))); * YYYYMMDD Date;
              %let path_sacq_archive = &Path_SACQRoot/archive/;
              %let path_sacq_curdate = &Path_SACQRoot/&cur_date/;

              %if %sysfunc(fileexist(&path_sacq_curdate)) %then %do;
                  %* Directory exists;
                  %sysexec %str(mkdir &Path_SACQRoot/archive 2> /dev/null); %* Create archive directory if it does not already exist;
                  %sysexec %str(cp -p &path_sacq_curdate*.xls &path_sacq_archive 2> /dev/null); %* Copy transfer listing xls file to archive;        			
                  %sysexec %str(cp -p &path_sacq_curdate*.zip &path_sacq_archive 2> /dev/null); %* Copy transfer zip file to archive;
                  %sysexec %str(rm -rf &path_sacq_curdate*.* 2> /dev/null); %* Remove files from current directory;
              %end;

              %* Copy previous run_pfesacq_map_scrf logs and pdf to /logs if exists;
              %sysexec %str(mkdir &Path_Progs/logs 2> /dev/null); %* Create logs directory if it does not already exist;
              %sysexec %str(mv -f &Path_Progs/run_pfesacq_map_scrf*.pdf &Path_Progs/logs 2> /dev/null);
              %sysexec %str(mv -f &Path_Progs/run_pfesacq_map_scrf*.log &Path_Progs/logs 2> /dev/null);
              %sysexec %str(mv -f &Path_Progs/run_pfesacq_map_scrf*.lst &Path_Progs/logs 2> /dev/null);

              %* Run SACQ mapping driver;
              %LogMessageOutput(n, Running &Path_Progs/run_pfesacq_map_scrf.sas, pfesacq_csdw_auto -> run_pfesacq_map_scrf);
              %sysexec %str(cd &Path_Progs);
              x "sas92 run_pfesacq_map_scrf.sas -encoding wlatin1";

              %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> run_pfesacq_map_scrf);
         	%mend run_pfesacq_map_scrf;

        %* MACRO: RunLogcheck
         * PURPOSE: Check run_pfesacq_map_scrf log for issues and run for errors
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable Path_Progs - path for pfesacq_map_scrf.sas run file
         *   4) Macro variable Path_SACQRoot - root path for SACQ output
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *;
         	%macro RunLogcheck;
              %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> RunLogcheck);

              options nofmterr noquotelenmax; %* Reset back from standard;

              %let RC = 0; %* Macro return code, 0=PASS 1=FAIL;
              %let pfesacq_map_scrf_logname = ; %* Parent macro variable - Get run_pfesacq_map_scrf log name;
              %let total_errors = 0;

              %* Get name of run_pfesacq_map_scrf log file;
                  filename dirlist pipe "ls -la %left(%trim(&Path_Progs))";
                  data work._dirlist ;
                      length dirline dirline2 $200 ;
                      infile dirlist recfm=v lrecl=200 truncover end=eof;
                      input dirline $1-200 ;
                      dirline2 = substr(dirline,59);
                      if index(dirline2,'run_pfesacq_map_scrf') > 0 and index(dirline2,'.log') > 0 then do;
                      call symput('pfesacq_map_scrf_logname',left(trim(dirline2)));
                      end;
                  run;
                  %LogMessageOutput(n, %str(Name of run_pfesacq_map_scrf log name = &pfesacq_map_scrf_logname), pfesacq_csdw_auto -> RunLogcheck);

              %* Check log for any ERROR Issues;
                  filename mylog "&Path_Progs/&pfesacq_map_scrf_logname";
                  data _null_;
                      infile mylog lrecl=500 truncover;
                      input log_message $500.;

                      if index(log_message, "INFO:[PXL] SACQ Transfer Total ERR ORS =") > 0 then do;
                          call symput('total_errors', scan(log_message,2, '='));
                      end;                    
                  run;

              %* Get name of the listing created;
                  filename dirlist pipe "ls -la %left(%trim(&Path_SACQRoot/&MacroRunDate))";
                  data work._dirlist ;
                      length dirline dirline2 $200 ;
                      infile dirlist recfm=v lrecl=200 truncover end=eof;
                      input dirline $1-200 ;
                      dirline2 = substr(dirline,59);
                      if index(dirline2,'SACQ Transfer Information and Exceptions Listing') > 0 and index(dirline2,'.xls') > 0 then do;
                          call symput('pfesacq_map_scrf_listingname',left(trim(dirline2)));
                      end;
                  run;

              %* Throw error if listing not found;
                  %if "%left(%trim(&pfesacq_map_scrf_listingname))" = %str("") %then %do;
                      %LogMessageOutput(e, SACQ Transfer Listing file not found, pfesacq_csdw_auto -> RunLogcheck);
                      data EMAIL_PXL;
                          set EMAIL_PXL;
                          if DESC="Transfer Warnings Status" then VALUE="FAILED";
                          if DESC="Transfer Warnings Msg" then VALUE="SACQ Transfer Listing Not Found";
                      run;
                      %goto macerr;  
                  %end; 

              %* Throw error if ERROR issue found;
                  %if %eval(&total_errors) > 0 %then %do;
                      %LogMessageOutput(e, %str(%left(%trim(&total_errors)) ERROR Issues Found in RUN_PFESACQ_MAP_SCRF), pfesacq_csdw_auto -> RunLogcheck);
                      data EMAIL_PXL;
                          set EMAIL_PXL;
                          if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Status" then VALUE="FAILED";
                          if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Msg" then do;
                              VALUE=catx(" ","%left(%trim(&total_errors)) ERROR Issues Found in RUN_PFESACQ_MAP_SCRF<br />",
                                "SACQ Transfer Listing: %left(%trim(&Path_SACQRoot))/error_%left(%trim(&MacroRunDate))/<br />%left(%trim(&pfesacq_map_scrf_listingname))");
                          end;
                      run;

                      %goto macerr;                     
                  %end;

              %* Run logcheck on log file;
                  %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> RunLogcheck -> pfelogcheck);
                  %pfelogcheck(
                      FileName=&Path_Progs/&pfesacq_map_scrf_logname,
                      _pxl_code=&In_PXL_Code,
                      _protocol=&In_Protocol,
                      AddDateTime=N,
                      IgnoreList=null,
                      ShowInUnix=N,
                      CreatePDF=Y);
                  %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> RunLogcheck -> pfelogcheck);
                  options nofmterr noquotelenmax; %* Reset back from standard;

              %* Macro creates global macro variables 
              pfelogcheck_TotalLogIssues - Total logcheck issues found, any issue found then fail transfer
              pfelogcheck_pdflistingname - Created PDF listing of logcheck
              ;
              %LogMessageOutput(n, %str(pfelogcheck_TotalLogIssues = &pfelogcheck_TotalLogIssues), pfesacq_csdw_auto -> RunLogcheck); %* Total log issues found;
              %LogMessageOutput(n, %str(pfelogcheck_pdflistingname = &pfelogcheck_pdflistingname), pfesacq_csdw_auto -> RunLogcheck); %* PDF Listing output file name;

              %* Check if logcheck found issues;
              %if %eval(&pfelogcheck_TotalLogIssues > 0) %then %do;
                  %LogMessageOutput(e, 
                  %str(%left(%trim(&pfelogcheck_TotalLogIssues)) SAS log issues found in &Path_Progs/&pfesacq_map_scrf_logname), 
                  pfesacq_csdw_auto -> RunLogcheck);
                  %let RC = 1;
                  data EMAIL_PXL;
                      set EMAIL_PXL;
                      if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Status" then VALUE="FAILED";
                      if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Msg" then VALUE="%left(%trim(&pfelogcheck_TotalLogIssues)) SAS log issues found in &Path_Progs/&pfesacq_map_scrf_logname";
                  run;

                  * Issue found, move sacq transfer data to error_YYYYMMDD;
                  %UpdatePathForIssue(PathRoot=&Path_SACQRoot, MacroPath=pfesacq_csdw_auto -> RunLogcheck -> UpdatePathForIssue);

                  %goto macerr;
              %end;

              data EMAIL_PXL;
                  set EMAIL_PXL;
                  if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Status" then VALUE="PASSED";
                  if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Msg" then VALUE="";
              run;
              %goto macend;                      

              %* FAIL;
              %macerr:;
              %let RC = 1;
              %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto -> RunLogcheck);

              %* End of Submacro;
              %macend:; 

              %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> RunLogcheck);
         	%mend RunLogcheck;         	

		    %* MACRO: CheckDifferences
         * PURPOSE: Check for structure differences from previous SACQ transfer
         *   and email PFE and PXL teams list of differences if they exist
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable Path_Progs - path for pfesacq_map_scrf.sas run file
         *   4) Macro variable Path_SACQRoot - root path for SACQ output
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *;
         	%macro CheckDifferences;
              %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CheckDifferences);

              %let RC = 0; %* Macro return code, 0=PASS 1=FAIL;
              %let total_differences = 0;

              %* Macro Variables;
              %local diff_listing_name;
              %let current_transfer_metadata = null; %* Name for current transfer metadata;
              %let previous_transfer_metadata = null; %* Name for previous transfer SAS dataset name if exists;
              %let diff_listing_name = null; %* Name of xls listing of diffeences between transfer metadata;

              %* Set library for SACQ saved per transfer structure metadata to compare;
              libname LIB_TRAN "&Path_Metadata/transfer_data";

              %* Load metadata;
                  proc sql noprint;
                      create table _tables as 
                      select memname
                      from sashelp.Vtable 
                      where libname = "LIB_TRAN" and substr(memname,1,8) = "&In_Protocol"
                      order by memname desc;
                  quit;

                  data _null_;
                      set _tables;
                      if _n_ = 1 then call symput('current_transfer_metadata', memname);
                      if _n_ = 2 then call symput('previous_transfer_metadata', memname);
                  run;

              %* No current transfer metadata then issue;
                  %if "&current_transfer_metadata" = "null" %then %do;
                      %LogMessageOutput(e, No current SACQ transfer metadata found@Path=&Path_Metadata/transfer_data, pfesacq_csdw_auto -> CheckDifferences);
                      %let RC = 1;
                      data EMAIL_PXL;
                          set EMAIL_PXL;
                          if DESC="Check Differences Status" then VALUE="FAILED";
                          if DESC="Check Differences Msg" then VALUE="No current SACQ transfer metadata found in &Path_Metadata/transfer_data";
                      run;

                      * Issue found, move sacq transfer data to error_YYYYMMDD;
                      %UpdatePathForIssue(PathRoot=&Path_SACQRoot, MacroPath=pfesacq_csdw_auto -> CheckDifferences -> UpdatePathForIssue);

                      %goto macerr;                	
                  %end;

              %* No previous transfer metadata then no differences as it is first transfer;
                  %if "&previous_transfer_metadata" = "null" %then %do;
                      %LogMessageOutput(n, %str(No previous transfer metadata found, first transfer), pfesacq_csdw_auto -> CheckDifferences);
                      data EMAIL_PXL;
                          set EMAIL_PXL;
                          if DESC="Check Differences Status" then VALUE="NO DIFFERENCES FOUND";
                          if DESC="Check Differences Msg" then VALUE="No previous transfer metadata found: first transfer";
                      run;
                      %goto macend;                	
                  %end;

              %* Check current against previous for differences;
                  data work.cur;
                      set LIB_TRAN.&current_transfer_metadata;
                      if M_MAPPED = "YES"; %* Holds raw data as well and we only want mapped SACQ data;
                  run;

                  data work.prev;
                      set LIB_TRAN.&previous_transfer_metadata;
                      if M_MAPPED = "YES"; %* Holds raw data as well and we only want mapped SACQ data;
                  run;

              %* Get differences;
                  proc sql noprint;
                      %* Previous dataset not in current;
                      create table _D1 as 
                      select "Dataset Dropped" as DIFF, 
                             "PREVIOUS" as SOURCE,
                             a.SACQ_DATASET_LABEL as SACQ_VERSION,
                             a.DATA_STANDARDVER,
                             a.SACQ_DATASET
                      from (select distinct DATA_STANDARDVER, SACQ_DATASET_LABEL, SACQ_DATASET from prev) as a 
                           full outer join 
                           (select distinct DATA_STANDARDVER, SACQ_DATASET_LABEL, SACQ_DATASET from cur) as b 
                      on a.SACQ_DATASET = b.SACQ_DATASET
                      where b.SACQ_DATASET is null;
                  quit;

                  proc sql noprint;
                      %* Current dataset not in previous;
                      create table _D2 as 
                      select "Dataset Added" as DIFF, 
                             "CURRENT" as SOURCE,
                             b.SACQ_DATASET_LABEL as SACQ_VERSION,
                             b.DATA_STANDARDVER,
                             b.SACQ_DATASET
                      from (select distinct DATA_STANDARDVER, SACQ_DATASET_LABEL, SACQ_DATASET from prev) as a 
                           full outer join 
                           (select distinct DATA_STANDARDVER, SACQ_DATASET_LABEL, SACQ_DATASET from cur) as b 
                      on a.SACQ_DATASET = b.SACQ_DATASET
                      where a.SACQ_DATASET is null;
                  quit;

                  proc sql noprint;
                      %* Previous variable not in current;
                      create table _D3 as 
                      select "Variable Dropped" as DIFF,
                             "PREVIOUS" as SOURCE,
                             a.SACQ_DATASET_LABEL as SACQ_VERSION,
                             a.DATA_STANDARDVER,
                             a.UIMS,
                             a.SACQ_DATASET,
                             a.SACQ_VARIABLE,
                             a.SACQ_LENGTH,
                             a.SACQ_LABEL
                      from prev as a 
                           full outer join 
                           cur as b 
                      on a.SACQ_DATASET = b.SACQ_DATASET
                         and a.SACQ_VARIABLE = b.SACQ_VARIABLE
                      where a.SACQ_DATASET is not null
                            and b.SACQ_VARIABLE is null
                            and a.SACQ_DATASET not in (select SACQ_DATASET from _D1);
                  quit;

                  proc sql noprint;
                      %* Current variable not in previous;
                      create table _D4 as 
                      select "Variable Added" as DIFF,
                             "CURRENT" as SOURCE,
                             a.SACQ_DATASET_LABEL as SACQ_VERSION,
                             a.DATA_STANDARDVER,
                             a.UIMS,
                             a.SACQ_DATASET,
                             a.SACQ_VARIABLE,
                             a.SACQ_LENGTH,
                             a.SACQ_LABEL
                      from cur as a 
                           full outer join 
                           prev as b 
                      on a.SACQ_DATASET = b.SACQ_DATASET
                         and a.SACQ_VARIABLE = b.SACQ_VARIABLE
                      where a.SACQ_DATASET is not null
                            and b.SACQ_VARIABLE is null
                            and a.SACQ_DATASET not in (select SACQ_DATASET from _D2);   
                  quit;

                  proc sql noprint;
                      %* Attrib differences;
                      create table _D5 as 
                      select "Attrib Differences" as DIFF,
                             "PREVIOUS" as SOURCE,
                             a.SACQ_DATASET_LABEL as SACQ_VERSION,
                             a.DATA_STANDARDVER,
                             a.UIMS,
                             a.SACQ_DATASET,
                             a.SACQ_VARIABLE,
                             a.SACQ_LENGTH,
                             a.SACQ_LABEL
                      from prev as a 
                           inner join 
                           cur as b 
                      on a.SACQ_DATASET = b.SACQ_DATASET
                         and a.SACQ_VARIABLE = b.SACQ_VARIABLE
                      where a.SACQ_LENGTH ne b.SACQ_LENGTH 
                            or a.SACQ_LABEL ne b.SACQ_LABEL;
                  quit;

                  proc sql noprint;
                      create table _D6 as 
                      select "Attrib Differences" as DIFF,
                             "CURRENT" as SOURCE,
                             b.SACQ_DATASET_LABEL as SACQ_VERSION,
                             b.DATA_STANDARDVER,
                             b.UIMS,
                             b.SACQ_DATASET,
                             b.SACQ_VARIABLE,
                             b.SACQ_LENGTH,
                             b.SACQ_LABEL
                      from prev as a 
                           inner join 
                           cur as b 
                      on a.SACQ_DATASET = b.SACQ_DATASET
                         and a.SACQ_VARIABLE = b.SACQ_VARIABLE
                      where a.SACQ_LENGTH ne b.SACQ_LENGTH 
                            or a.SACQ_LABEL ne b.SACQ_LABEL;
                  quit;

                  data Differences;
                      attrib 
                          DIFF length=$200 label="Differences"
                          SOURCE length=$200 label="Source"
                          SACQ_VERSION length=$200 label="SACQ Version"
                          DATA_STANDARDVER length=$200 label="-999 Manifest Sent Domain Standard Version?"                            
                          SACQ_DATASET length=$200 label="Dataset"
                          UIMS length=$200 label="UIMS Updated Variable?"
                          SACQ_VARIABLE length=$200 label="Variable"
                          SACQ_LENGTH length=8. label="Length"
                          SACQ_LABEL length=$200 label="Label"
                      ;
                      set _D1 _D2 _D3 _D4 _D5 _D6;
                  run;
                  proc sort data = Differences; by SACQ_DATASET SACQ_VARIABLE decending SOURCE; run;

              %* Check if differences;
                    proc sql noprint;
                        select count(*) into: total_differences
                        from Differences;
                    quit;

                    %if %eval(&total_differences = 0) %then %do;
    	                	%LogMessageOutput(n, %str(Current Metadata: &current_transfer_metadata), pfesacq_csdw_auto -> CheckDifferences);
                        %LogMessageOutput(n, %str(Previous Metadata: &previous_transfer_metadata), pfesacq_csdw_auto -> CheckDifferences);
                        %LogMessageOutput(n, %str(No differences between current and previous transfer), pfesacq_csdw_auto -> CheckDifferences);
    	        			    data EMAIL_PXL;
    	                    	set EMAIL_PXL;
        		            		if DESC="Check Differences Status" then VALUE="NO DIFFERENCES FOUND";
        		            		if DESC="Check Differences Msg" then VALUE="No differences between current (%left(%trim(&current_transfer_metadata))) and previous transfer (%left(%trim(&previous_transfer_metadata)))";
    	                	run;
    		                %goto macend;
                    %end;

              %* Output listing to xls;
                  %let diff_listing_name = Structure_Differences_%left(%trim(&previous_transfer_metadata))_to_%left(%trim(&current_transfer_metadata)).xls;
                  ods listing close;
                  ods tagsets.excelxp file= "&Path_Metadata/transfer_data/&diff_listing_name";

                      * Set titles and footnotes;
                      title;
                      title1 justify=left "&diff_listing_name";
                      footnote1 j=l "PAREXEL International Confidential";
                      footnote2 j=l "Produced by %upcase(&sysuserid) on &sysdate9";

                      ods tagsets.excelxp options (
                          Orientation = "landscape"
                          Embedded_Titles = "Yes"
                          Row_Repeat = "Header"
                          Autofit_Height = "Yes"
                          Autofilter = "All"
                          Frozen_Headers = "Yes"
                          Gridlines = "Yes"
                          Zoom = "80"
                          frozen_headers = "3"
                          row_repeat = "3"
                          WIDTH_FUDGE = "0.75"
                          sheet_name = "Transfer Information" 
                          ABSOLUTE_COLUMN_WIDTH= "15, 10, 10, 10, 15, 10, 10, 8, 25");

        			        proc report data= differences style(column)={tagattr='Format:Text'};
        			            column DIFF SOURCE SACQ_VERSION DATA_STANDARDVER SACQ_DATASET UIMS SACQ_VARIABLE SACQ_LENGTH SACQ_LABEL;
        			        run;                        

      			    	ods tagsets.excelxp close;
      			    	ods listing;

              %* Send email of differences;
                	%if %str("&TESTING") = %str("NO") %then %do;
	                    filename Mailbox EMAIL 'Nathan.Hartley@parexel.com'
	                        type = "TEXT/HTML"
	                        to = (&pfe_emails &stat_emails)
	                        cc = (&study_emails &dex_emails) 

	                        subject="%left(%trim(&In_Protocol)) %left(%trim(&In_PXL_Code)) SACQ Transfer Structure Differences Identified"
	                        attach=("&Path_Metadata/transfer_data/&diff_listing_name");

	                        data _null_;
	                            file Mailbox;
	                            put "Hello,<br />";
	                            put "<br />";
	                            put "SACQ Transfer Structure Differences Identified<br /><br />";
	                            put "<table border='1' style='border: 1px solid black; border-collapse: collapse; padding: 8px;'>";
	                            put "  <tr>";
	                            put "    <td><b>Number of Differences Found:</b></td>";
	                            put "    <td>%left(%trim(&total_differences))</td>";
	                            put "  </tr>";
	                            put "  <tr>";
	                            put "    <td><b>Current SACQ Transfer:</b></td>";
	                            put "    <td>%left(%trim(&current_transfer_metadata))</td>";
	                            put "  </tr>";	
	                            put "  <tr>";
	                            put "    <td><b>Previous SACQ Transfer:</b></td>";
	                            put "    <td>%left(%trim(&previous_transfer_metadata))</td>";
	                            put "  </tr>";
	                            put "</table>";
	                            put "See attached listing for details.<br />";
	                            put "<br />";
	                            put "---------------------------------------------------------------------<br />";
	                            put "End of automatic generated email";
	                        run;
	                    quit;
                  %end;	

                  %LogMessageOutput(n, %str(Found %left(%trim(&total_differences)) differences), pfesacq_csdw_auto -> CheckDifferences);
                  data EMAIL_PXL;
                      set EMAIL_PXL;
                      if DESC="Check Differences Status" then VALUE="DIFFERENCES FOUND";
                      if DESC="Check Differences Msg" then VALUE="Found %left(%trim(&total_differences)) differences";
                  run;                   	         						

	            %goto macend;                      

              %* FAIL;
                  %macerr:;
                  %let GMPXLERR = 1;
                  %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto -> CheckDifferences);

              %* End of Submacro;
                  %macend:; 
                  %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CheckDifferences);
         	%mend CheckDifferences; 

		    %* MACRO: RunZip
         * PURPOSE: Zips SACQ transfer dated folders older than 30 days unless 
         *  most recent and any error_ folders older than 30 days. Creates zip 
         *  file of all files under the directory of same name as directory.
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable Path_SACQRoot - root path for SACQ output
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *;
         	%macro RunZip;
              %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> RunZip);

              %let RC = 0; %* Macro return code, 0=PASS 1=FAIL;
              %local total_zipped_directories;
              %let total_zipped_directories = 0;

              %* Zip dated folders older than 30 days exept most recent;
              %* Get list of dated folders in Path_SACQRoot;
              data _null_ ;
                  call system("cd &Path_SACQRoot");
                  call system("pwd ; du -sk ; df -k .");
              run;

              filename dirlist pipe 'ls -la' ;

              data work._dirlist ;
                  length dirline datec $200 ;
                  infile dirlist recfm=v lrecl=200 truncover ;

                  input dirline $1-200 ;
                  if substr(dirline,1,1) = 'd' ;
                  datec = scan(substr(dirline,59,14),1,' ') ;
                  if index(datec,'.') or datec = ' ' then delete ;
                  date = input(datec,?? yymmdd10.) ;
                  if date = . then delete ;
                  format date date9. ;
              run;

              proc sort data = work._dirlist;
                  by date;
              run;

              %* Do not zip most recent folder;
              data work._dirlist ;
                  set work._dirlist end = eof;
                  if eof then do;
                      delete;
                  end;
              run;

              %* Create macro array of dated folders greater than 30 days;
              %let dircnt = 0 ;

              data _null_ ;
                  set work._dirlist end = eof ;
                  where date < today() - 30 ;

                  call symput('dir' || left(put(_n_,best.)),compress(datec,' ')) ;

                  if eof then do ;
                      call symput('dircnt' ,left(put(_n_,best.))) ;
                  end ;
              run ;

              %* Zip dated folders;
              %if %eval(&dircnt) >= 1 %then %do;
                  %let total_zipped_directories = %eval(&total_zipped_directories + &dircnt);
                  %LogMessageOutput(n, Zipping Directories within &Path_SACQRoot, pfesacq_csdw_auto -> RunZip);
                  %do _i = 1 %to &dircnt;
                      %LogMessageOutput(n, Zipping Directory &&dir&_i, pfesacq_csdw_auto -> RunZip);

                      data _null_ ;
                          call system("cd &Path_SACQRoot/&&dir&_i");
                          call system("pwd");
                      run;

                      filename filelist pipe 'ls -la' ;

                      data work._filelist ;
                          length dirline filename $200 ;
                          infile filelist recfm=v lrecl=200 truncover ;

                          input dirline $1-200 ;
                          if substr(dirline,1,1) = 'd' then delete ;
                          else if substr(dirline,1,6) = 'total' then delete ;

                          filename = reverse(scan(left(reverse(dirline)),1,' ')) ;
                          if filename = ' ' then delete ;
                          else if index(filename,'.zip') then delete ;

                          call system("/usr/local/bin/zip -j -m -T &Path_SACQRoot/&&dir&_i/&&dir&_i " || filename) ;

                          %*zip = "/usr/local/bin/zip -j -m -T &&dir&_i " || filename ;
                          %*put "ALERT_U: " zip= ;
                      run ;    						
                  %end;
              %end;

              %* Zip all error_ folders;
              %* Get list of error_ folders;
              data _null_ ;
                  call system("cd &Path_SACQRoot");
                  call system("pwd ; du -sk ; df -k .");
              run;

              filename dirlist pipe 'ls -la' ;

              data work._dirlist ;
                  length dirline datec $200 ;
                  infile dirlist recfm=v lrecl=200 truncover ;

                  input dirline $1-200 ;
                  if substr(dirline,1,1) = 'd' ;
                  datec = scan(substr(dirline,59,14),1,' ') ;
                  if substr(datec,1,6) = 'error_';
                  if index(datec,'.') or datec = ' ' then delete ;
              run;

              proc sort data = work._dirlist;
                  by datec;
              run;

              %* Do not zip most recent folder if within 30 days;
              data work._dirlist ;
                  set work._dirlist end = eof;
                  if eof then do;
                      format date date9. ;
                      date = input(substr(datec, 7),?? yymmdd10.);
                      if date = . then delete;
                      if not (date < today() - 30) then delete;
                  end;							
              run;    

              %* Create macro array of dated folders greater than 30 days;
              %let dircnt = 0 ;

              data _null_ ;
                  set work._dirlist end = eof ;

                  call symput('dir2' || left(put(_n_,best.)),compress(datec,' ')) ;

                  if eof then do ;
                      call symput('dircnt' ,left(put(_n_,best.))) ;
                  end ;
              run ;

              %* Zip dated folders;
              %if %eval(&dircnt) >= 1 %then %do;
                  %let total_zipped_directories = %eval(&total_zipped_directories + &dircnt);
                  %LogMessageOutput(n, Zipping error_ Directories within &Path_SACQRoot, pfesacq_csdw_auto -> RunZip);
                  %do _i = 1 %to &dircnt;
                      %LogMessageOutput(n, Zipping Directory &&dir2&_i, pfesacq_csdw_auto -> RunZip);

                      data _null_ ;
                          call system("cd &Path_SACQRoot/&&dir2&_i");
                          call system("pwd");
                      run;

                      filename filelist pipe 'ls -la' ;

                      data work._filelist ;
                          length dirline filename $200 ;
                          infile filelist recfm=v lrecl=200 truncover ;

                          input dirline $1-200 ;
                          if substr(dirline,1,1) = 'd' then delete ;
                          else if substr(dirline,1,6) = 'total' then delete ;

                          filename = reverse(scan(left(reverse(dirline)),1,' ')) ;
                          if filename = ' ' then delete ;
                          else if index(filename,'.zip') then delete ;

                          call system("/usr/local/bin/zip -j -m -T &Path_SACQRoot/&&dir2&_i/&&dir2&_i " || filename) ;

                          %* zip = "/usr/local/bin/zip -j -m -T &&dir2&_i " || filename ;
                          %* put "ALERT_U: " zip= ;
                          run ;    						
                  %end;
              %end;										

            	%LogMessageOutput(n, %str(Run zip completed, Zipped %left(%trim(&&total_zipped_directories)) older SACQ directories), pfesacq_csdw_auto -> RunZip);
              data EMAIL_PXL;
                  set EMAIL_PXL;
                  if DESC="Zip Older SACQ Directories Status" then VALUE="COMPLETED";
                  if DESC="Zip Older SACQ Directories Msg" then VALUE="Zipped %left(%trim(&&total_zipped_directories)) older SACQ directories";
              run; 
              %goto macend;

	            %* FAIL;
	                %macerr:;
	                %let GMPXLERR = 1;
	    			      %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto -> RunZip);

	            %* End of Submacro;
	                %macend:; 

              %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> RunZip);
         	%mend RunZip;					        		

        %* MACRO: GetWarnings
         * PURPOSE: Get number of SACQ transfer warnings and name of created listing if present
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable pfesacq_map_scrf_logname
         *   4) Macro input parameter Path_Progs
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *   2) Macro variable - pfesacq_map_scrf_listingname with SACQ driver created listing name
         *;
            %macro GetWarnings;
                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> GetWarnings);

                %let RC = 0;
                %let total_notes = 0;
                %let total_warnings = 0;

                %local NumberNotes NumberWarnings;
                %let NumberNotes = 0;
                %let NumberWarnings = 0;

                %* Get from run_pfesacq_map_scrf log;
                filename mylog "&Path_Progs/&pfesacq_map_scrf_logname";
                data _null_;
                    infile mylog lrecl=200 truncover;
                    input log_message $200.;

                    if index(log_message, "INFO:[PXL] SACQ Transfer Total NOTES =") > 0 then do;
                        call symput('total_notes', scan(log_message,2, '='));
                    end;

                    if index(log_message, "INFO:[PXL] SACQ Transfer Total WARN INGS =") > 0 then do;
                        call symput('total_warnings', scan(log_message,2, '='));
                    end;

                    if index(log_message, "INFO:[PXL] SACQ Transfer Total ERR ORS =") > 0 then do;
                        call symput('total_errors', scan(log_message,2, '='));
                    end;                    
                run;

                %if %eval(&total_notes) > 0 or %eval(&total_warnings) > 0 %then %do;
                    data EMAIL_PXL;
                        set EMAIL_PXL;
                        if DESC="Transfer Warnings Status" then VALUE="POSSIBLE ISSUES FOUND";
                        if DESC="Transfer Warnings Msg" then VALUE="Found %left(%trim(&total_notes)) NOTES and %left(%trim(&total_warnings)) WARNINGS*";
                    run;                
                %end;
                %else %do;
                    data EMAIL_PXL;
                        set EMAIL_PXL;
                        if DESC="Transfer Warnings Status" then VALUE="PASSED";
                        if DESC="Transfer Warnings Msg" then VALUE="No NOTES or WARNINGS Found";
                    run;
                %end;

                %goto macend;

                %* FAIL;
                %macerr:;
                %let GMPXLERR = 1;
                %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto -> GetWarnings);

                %* End of Submacro;
                %macend:; 

                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> GetWarnings);
            %mend GetWarnings;

        %* MACRO: Ongoing_Logcheck
         * PURPOSE: Check run_pfesacq_csdw_auto ongoing logcheck for issues
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable Path_Progs
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *;
            %macro Ongoing_Logcheck;
                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> Ongoing_Logcheck);

                %let RC = 0;

                %local current_logname;
                %let current_logname = ;

                %* Get name of the zip file created;
                filename dirlist pipe "ls -la %left(%trim(&Path_Progs))";
                data work._dirlist ;
                    length dirline dirline2 $200 ;
                    infile dirlist recfm=v lrecl=200 truncover end=eof;
                    input dirline $1-200 ;
                    dirline2 = substr(dirline,59);
                    if index(dirline2,'run_pfesacq_csdw_auto') > 0 and index(dirline2,'.log') > 0 then do;
                        call symput('current_logname',left(trim(dirline2)));
                    end;
                run;
                %LogMessageOutput(n, RUN_PFESACQ_CSDW_AUTO SAS log = %left(%trim(&current_logname)), pfesacq_csdw_auto -> Ongoing_Logcheck);

                %* Check if file exists;
                %if "%left(%trim(&current_logname))" = %str("") %then %do;
                    %LogMessageOutput(e, RUN_PFESACQ_CSDW_AUTO SAS log file not found, pfesacq_csdw_auto -> Ongoing_Logcheck);
                    data EMAIL_PXL;
                        set EMAIL_PXL;
                        if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Status" then VALUE="FAILED";
                        if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Msg" then VALUE="RUN_PFESACQ_CSDW_AUTO Ongoing Log File Not Found";
                    run;
                    %goto macerr;  
                %end;

                %* Check log;
                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> Ongoing_Logcheck -> pfelogcheck);
                %pfelogcheck(
                    FileName=&Path_Progs/%left(%trim(&current_logname)),
                    _pxl_code=&In_PXL_Code,
                    _protocol=&In_Protocol,
                    AddDateTime=N,
                    IgnoreList=null,
                    ShowInUnix=N,
                    CreatePDF=Y);
                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> Ongoing_Logcheck -> pfelogcheck);
                options nofmterr noquotelenmax; %* Reset back from standard;

                %if %eval(&pfelogcheck_TotalLogIssues > 0) %then %do;
                    %LogMessageOutput(e, RUN_PFESACQ_CSDW_AUTO SAS log file found %left(%trim(&pfelogcheck_TotalLogIssues)) Issues, pfesacq_csdw_auto -> Ongoing_Logcheck);
                    data EMAIL_PXL;
                        set EMAIL_PXL;
                        if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Status" then VALUE="FAILED";
                        if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Msg" then VALUE="%left(%trim(&pfelogcheck_TotalLogIssues)) SAS log issues found in &Path_Progs/%left(%trim(&current_logname))";
                    run;
                    %goto macerr;                    
                %end;

                %put Not Completed yet;

                data EMAIL_PXL;
                    set EMAIL_PXL;
                    if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Status" then VALUE="PASSED";
                    if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Msg" then VALUE="";
                run;
                %goto macend;                      

                %* FAIL;
                %macerr:;
                %let RC = 1;
                %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto -> RunLogcheck);

                %* End of Submacro;
                %macend:;              

                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> Ongoing_Logcheck);
            %mend Ongoing_Logcheck;            

        %* MACRO: PostToCal
         * PURPOSE: Copy transfer zip file to CAL pickup location
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable Path_SACQRoot
         *   4) Macro variable MacroRunDate
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *   2) Work Dataset EMAIL_PXL
         *   3) Macro variable PostToCal_FileName - Post to CAL zip file
         *;
            %macro PostToCal;
                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> PostToCal);

                %let RC = 0;
                %let PostToCal_FileName = ; %* Zip file to post to CAL on succesiful SACQ transfer;

                %* Get name of the zip file created;
                filename dirlist pipe "ls -la %left(%trim(&Path_SACQRoot/&MacroRunDate))";
                data work._dirlist ;
                    length dirline dirline2 $200 ;
                    infile dirlist recfm=v lrecl=200 truncover end=eof;
                    input dirline $1-200 ;
                    dirline2 = substr(dirline,59);
                    if index(dirline2,'ClinicalStudyGeneral') > 0 and index(dirline2,'.zip') > 0 then do;
                        call symput('PostToCal_FileName',left(trim(dirline2)));
                    end;
                run;
                %LogMessageOutput(n, Post to CAL Zip File = %left(%trim(&PostToCal_FileName)), pfesacq_csdw_auto -> PostToCal);

                %* Check if file exists;
                %if "%left(%trim(&PostToCal_FileName))" = %str("") %then %do;
                    %LogMessageOutput(e, Post to CAL Zip file not found, pfesacq_csdw_auto -> PostToCal);
                    data EMAIL_PXL;
                        set EMAIL_PXL;
                        if DESC="Transfer Posted To CAL Status" then VALUE="FAILED";
                        if DESC="Transfer Posted To CAL Msg" then VALUE="SACQ Transfer Zip File Not Found";
                    run;
                    %goto macerr;  
                %end;

                %* Copy to CAL location if overall pass;
                    x "cp -p &Path_SACQRoot/&MacroRunDate/%left(%trim(&PostToCal_FileName)) &Path_CAL/transfer/";
                    x "cp -p &Path_SACQRoot/&MacroRunDate/%left(%trim(&PostToCal_FileName)) &Path_CAL/archive/";

                %* Verify file exists in CAL;
                %if NOT %sysfunc(fileexist(&Path_SACQRoot/&MacroRunDate/%left(%trim(&PostToCal_FileName)))) %then %do;
                    %LogMessageOutput(e, Posted to CAL Zip file not found, pfesacq_csdw_auto -> PostToCal);
                    data EMAIL_PXL;
                        set EMAIL_PXL;
                        if DESC="Transfer Posted To CAL Status" then VALUE="FAILED";
                        if DESC="Transfer Posted To CAL Msg" then VALUE="SACQ Transfer Zip File Copy to CAL Failed";
                    run;
                    %goto macerr;
                %end;

                data EMAIL_PXL;
                    set EMAIL_PXL;
                    if DESC="Transfer Posted To CAL Status" then VALUE="COMPLETED";
                    if DESC="Transfer Posted To CAL Msg" then VALUE="Zip File=%left(%trim(&PostToCal_FileName))";
                run;
                %goto macend;                      

                %* FAIL;
                %macerr:;
                %let GMPXLERR = 1;
                %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto -> PostToCal);

                %* End of Submacro;
                %macend:; 

                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> PostToCal);
            %mend PostToCal;            

        %* MACRO: LogTransfer
         * PURPOSE: Log Transfer to metadata
         * INPUT:  
         *   1) Macro Variable RC - Used for return code
         *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   3) Macro variable Path_Progs
         * OUTPUT: 
         *   1) Macro Variable RC
         *      1) RC = 0 if no error and needs to run SACQ transfer
         *      2) RC = 1 if error found
         *;
            %macro LogTransfer;
                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> LogTransfer);

                %let RC = 0;
                %local
                    OVERALL_STATUS
                    CheckInput_status 
                    CheckInput_msg
                    TransferNeed_status
                    TransferNeed_msg
                    MappingLogCheck_status
                    MappingLogCheck_msg
                    Differences_status
                    Differences_msg
                    Zip_status
                    Zip_msg
                    OngoingLogcheck
                    OngoingLogcheck_msg
                    PostedToCAL
                    PostedToCAL_msg
                    TransferWarnings
                    TransferWarnings_msg
                    FAIL_REASON
                    FAIL_DETAILS
                ;

                data _null_;
                    set EMAIL_PXL;

                    if DESC="Overall Status" then do; call symput('OVERALL_STATUS', left(trim(VALUE))); end;

                    if DESC="Source Data Checks Status" then do; call symput('CheckInput_status', VALUE); end;
                    if DESC="Source Data Checks Msg" then do; call symput('CheckInput_msg', VALUE); end;

                    if DESC="SACQ Transfer Need Status" then do; call symput('TransferNeed_status', VALUE); end;
                    if DESC="SACQ Transfer Need Msg" then do; call symput('TransferNeed_msg', VALUE); end;

                    if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Status" then do; call symput('MappingLogCheck_status', VALUE); end;
                    if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Msg" then do; call symput('MappingLogCheck_msg', VALUE); end;

                    if DESC="Check Differences Status" then do; call symput('Differences_status', VALUE); end;
                    if DESC="Check Differences Msg" then do; call symput('Differences_msg', VALUE); end;

                    if DESC="Zip Older SACQ Directories Status" then do; call symput('Zip_status', VALUE); end;
                    if DESC="Zip Older SACQ Directories Msg" then do; call symput('Zip_msg', VALUE); end;

                    if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Status" then do; call symput('OngoingLogcheck', VALUE); end;
                    if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Msg" then do; call symput('OngoingLogcheck_msg', VALUE); end;

                    if DESC="Transfer Posted To CAL Status" then do; call symput('PostedToCAL', VALUE); end;
                    if DESC="Transfer Posted To CAL Msg" then do; call symput('PostedToCAL_msg', VALUE); end;

                    if DESC="Transfer Warnings Status" then do; call symput('TransferWarnings', VALUE); end;
                    if DESC="Transfer Warnings Msg" then do; call symput('TransferWarnings_msg', VALUE); end;                    
                run;

                %let FAIL_REASON = ;
                %let FAIL_DETAILS = ;

                %if "%left(%trim(&CheckInput_status))" = "FAILED" %then %do;
                    %let FAIL_REASON = Source Data Checks;
                    %let FAIL_DETAILS = &CheckInput_msg;
                %end;
                %else %if "%left(%trim(&TransferNeed_status))" = "FAILED" %then %do;
                    %let FAIL_REASON = SACQ Transfer Need;
                    %let FAIL_DETAILS = &TransferNeed_msg;
                %end;
                %else %if "%left(%trim(&MappingLogCheck_status))" = "FAILED" %then %do;
                    %let FAIL_REASON = RUN_PFESACQ_MAP_SCRF LogCheck;
                    %let FAIL_DETAILS = &MappingLogCheck_msg;
                %end;
                %else %if "%left(%trim(&Differences_status))" = "FAILED" %then %do;
                    %let FAIL_REASON = Check Differences;
                    %let FAIL_DETAILS = &Differences_msg;
                %end; 
                %else %if "%left(%trim(&Zip_status))" = "FAILED" %then %do;
                    %let FAIL_REASON = Zip Older SACQ Directories;
                    %let FAIL_DETAILS = &Zip_msg;
                %end;
                %else %if "%left(%trim(&TransferWarnings))" = "FAILED" %then %do;
                    %let FAIL_REASON = Transfer Notes/Warnings;
                    %let FAIL_DETAILS = &TransferWarnings_msg;
                %end;
                %else %if "%left(%trim(&OngoingLogcheck))" = "FAILED" %then %do;
                    %let FAIL_REASON = RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck;
                    %let FAIL_DETAILS = &OngoingLogcheck_msg;
                %end; 
                %else %if "%left(%trim(&PostedToCAL))" = "FAILED" %then %do;
                    %let FAIL_REASON = Transfer Posted To CAL;
                    %let FAIL_DETAILS = &PostedToCAL_msg;
                %end;

                data _transfer_log_sacq_auto;
                    attrib
                        PXL_CODE length=8.
                        PROTOCOL length=$8.
                        OVERALL_PASSFAIL length=$6.
                        RUN_DATETIME length=8. format=E8601DT19.
                        FAIL_REASON length=$50.
                        FAIL_DETAILS length=$500.
                        NAME_CAL_ZIPFILE length=$200.
                        NUMBER_STRUCTURE_DIFFERENCES length=8.
                        NUMBER_NOTES length=8.
                        NUMBER_WARNINGS length=8.
                        NUMBER_ERRORS length=8.
                        MACRO_RUN_VERSION length=$100.
                        RUN_BY length=$25.
                    ;
                    PXL_CODE = input(symget('In_PXL_Code'),?? 8.);
                    PROTOCOL = "&In_Protocol";
                    OVERALL_PASSFAIL = "%left(%trim(&OVERALL_STATUS))";
                    RUN_DATETIME = input(symget('MacroRUnDateTime'), E8601DT19.);
                    FAIL_REASON = left(trim("&FAIL_REASON"));
                    FAIL_DETAILS = left(trim("&FAIL_DETAILS"));
                    NAME_CAL_ZIPFILE = "&PostToCal_FileName";
                    NUMBER_STRUCTURE_DIFFERENCES = input(symget('total_differences'), 8.);
                    NUMBER_NOTES = input(symget('total_notes'), 8.);
                    NUMBER_WARNINGS = input(symget('total_warnings'), 8.);
                    NUMBER_ERRORS = input(symget('total_errors'), 8.);
                    MACRO_RUN_VERSION = catx(" ", 
                        "PFESACQ_CSDW_AUTO",
                        "v&MacroVersion",
                        "|",
                        "&MacroVersionDate",
                        "|",
                        "&SMARTSVN_Version");
                    RUN_BY = upcase("&sysuserid");
                run;

                %if "&Path_Metadata" ne "null" 
                    and %sysfunc(fileexist(&Path_Metadata/data)) %then %do;
                    libname tlog "&Path_Metadata/data";

                    proc sql noprint;
                        select count(*) into: _exists
                        from sashelp.vtable 
                        where libname="TLOG" and memname="TRANSFER_LOG_SACQ_AUTO";
                    quit;

                    %if %eval(&_exists = 0) %then %do;
                        %LogMessageOutput(n, Record added to new transfer log: &Path_Metadata/data/transfer_log_sacq_auto, pfesacq_csdw_auto -> LogTransfer);
                        data tlog.transfer_log_sacq_auto;
                            set _transfer_log_sacq_auto;
                        run;                    
                    %end;
                    %else %do;
                        %LogMessageOutput(n, Record added to transfer log: &Path_Metadata/data/transfer_log_sacq_auto, pfesacq_csdw_auto -> LogTransfer);
                        data tlog.transfer_log_sacq_auto;
                            set tlog.transfer_log_sacq_auto _transfer_log_sacq_auto;
                        run;
                    %end;
                %end;
                %else %do;
                    %LogMessageOutput(e, Input Parameter Path_Metadata not defined and no transfer attempt logged, pfesacq_csdw_auto -> LogTransfer);
                %end;

                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> LogTransfer);
            %mend LogTransfer;

        %* MACRO: SendEmail
         * PURPOSE: Email study team and DEX run status of transfer
         * INPUT:  
         *   1) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
         *   2) Macro variable Path_Progs
         * OUTPUT: 
         *   1) 
         *;
            %macro SendEmail;
                %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> SendEmail);

                %let RC = 0;
                %local
                    OVERALL_STATUS
                    CheckInput_status 
                    CheckInput_msg
                    TransferNeed_status
                    TransferNeed_msg
                    MappingLogCheck_status
                    MappingLogCheck_msg
                    Differences_status
                    Differences_msg
                    Zip_status
                    Zip_msg
                    OngoingLogcheck
                    OngoingLogcheck_msg
                    PostedToCAL
                    PostedToCAL_msg
                    TransferWarnings
                    TransferWarnings_msg
                ;

                data _null_;
                    set EMAIL_PXL;

                    if DESC="Overall Status" then do; call symput('OVERALL_STATUS', VALUE); end;

                    if DESC="Source Data Checks Status" then do; call symput('CheckInput_status', VALUE); end;
                    if DESC="Source Data Checks Msg" then do; call symput('CheckInput_msg', VALUE); end;

                    if DESC="SACQ Transfer Need Status" then do; call symput('TransferNeed_status', VALUE); end;
                    if DESC="SACQ Transfer Need Msg" then do; call symput('TransferNeed_msg', VALUE); end;

                    if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Status" then do; call symput('MappingLogCheck_status', VALUE); end;
                    if DESC="RUN_PFESACQ_MAP_SCRF LogCheck Msg" then do; call symput('MappingLogCheck_msg', VALUE); end;

                    if DESC="Check Differences Status" then do; call symput('Differences_status', VALUE); end;
                    if DESC="Check Differences Msg" then do; call symput('Differences_msg', VALUE); end;

                    if DESC="Zip Older SACQ Directories Status" then do; call symput('Zip_status', VALUE); end;
                    if DESC="Zip Older SACQ Directories Msg" then do; call symput('Zip_msg', VALUE); end;

                    if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Status" then do; call symput('OngoingLogcheck', VALUE); end;
                    if DESC="RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Msg" then do; call symput('OngoingLogcheck_msg', VALUE); end;

                    if DESC="Transfer Posted To CAL Status" then do; call symput('PostedToCAL', VALUE); end;
                    if DESC="Transfer Posted To CAL Msg" then do; call symput('PostedToCAL_msg', VALUE); end;

                    if DESC="Transfer Warnings Status" then do; call symput('TransferWarnings', VALUE); end;
                    if DESC="Transfer Warnings Msg" then do; call symput('TransferWarnings_msg', VALUE); end;                    
                run;

                %put NOTE:[PXL] pfesacq_csdw_auto -> SendEmail: Study Email Contacts=%left(%trim(&study_emails));;
                %put NOTE:[PXL] pfesacq_csdw_auto -> SendEmail: DEX Email Contacts=%left(%trim(&dex_emails));;

                %* Compute time to run;
                    data _null_;
                        format start_time_n end_time_n IS8601DT.;
                        start_time_n = input(symget('MacroRUnDateTime'), IS8601DT.);
                        x = sleep(2000);
                        end_time_n = datetime();

                        duration = strip(put(end_time_n - start_time_n, time8.));
                        call symput('duration', duration);
                    run;

                %if %str("&TESTING") = %str("NO") 
                    and %str("%left(%trim(&dex_emails))") ne %str("") %then %do;
                    filename Mailbox EMAIL
                        type = "TEXT/HTML"
                        to = (%left(%trim(&study_emails)))
                        cc = (%left(%trim(&dex_emails)))
                        subject = "%left(%trim(&In_PXL_Code)) %left(%trim(&In_Protocol)) Automatic CSDW SCRF to SACQ Creation = %left(%trim(&OVERALL_STATUS))";

                        data _null_;
                            file Mailbox;
                            put "Hello,<br />";
                            put "<br />";
                            put "This is an automatic generated message by PFZCRON.<br />";
                            put "----------------------------------------------------------------------------------------------------------------<br />";

                            %if "%left(%trim(&OVERALL_STATUS))" = "FAILED" %then %do;
                                put "<font color='red'><b>*** Overall Process:</b> %left(%trim(&OVERALL_STATUS)) ***</font><br />";
                            %end;                            
                            %else %do;
                                put "<b>Overall Process:</b> %left(%trim(&OVERALL_STATUS))<br />";
                            %end;
                            
                            put "<br />";
                            put "Process Details<br />";
                            put "<table border='1' style='border: 1px solid black; border-collapse: collapse; padding: 8px;'>";
                            put "  <tr>";
                            put "    <td><b>Source Data Checks Status:</b></td>";
                            put "    <td>%left(%trim(&CheckInput_status))</td>";
                            put "    <td>%left(%trim(&CheckInput_msg))</td>";
                            put "  </tr>";
                            put "  <tr>";
                            put "    <td><b>SACQ Transfer Need Status:</b></td>";
                            put "    <td>%left(%trim(&TransferNeed_status))</td>";
                            put "    <td>%left(%trim(&TransferNeed_msg))</td>";
                            put "  </tr>";  
                            put "  <tr>";
                            put "    <td><b>RUN_PFESACQ_MAP_SCRF LogCheck Status:</b></td>";
                            put "    <td>%left(%trim(&MappingLogCheck_status))</td>";
                            put "    <td>%left(%trim(&MappingLogCheck_msg))</td>";
                            put "  </tr>";
                            put "  <tr>";
                            put "    <td><b>Check Structure Differences Status:</b></td>";
                            put "    <td>%left(%trim(&Differences_status))</td>";
                            put "    <td>%left(%trim(&Differences_msg))</td>";
                            put "  </tr>";
                            put "  <tr>";
                            put "    <td><b>Zip Older SACQ Directories Status:</b></td>";
                            put "    <td>%left(%trim(&Zip_status))</td>";
                            put "    <td>%left(%trim(&Zip_msg))</td>";
                            put "  </tr>"; 
                            put "  <tr>";
                            put "    <td><b>Transfer Listing Warnings Present that Require Review:</b></td>";
                            put "    <td>%left(%trim(&TransferWarnings))</td>";
                            put "    <td>%left(%trim(&TransferWarnings_msg))</td>";
                            put "  </tr>"; 
                            put "  <tr>";
                            put "    <td><b>RUN_PFESACQ_CSDW_AUTO Ongoing LogCheck Status:</b></td>";
                            put "    <td>%left(%trim(&OngoingLogcheck))</td>";
                            put "    <td>%left(%trim(&OngoingLogcheck_msg))</td>";
                            put "  </tr>";                            
                            put "  <tr>";
                            put "    <td><b>Zip File Status:</b></td>";
                            put "    <td>%left(%trim(&PostedToCAL))</td>";
                            put "    <td>Output Path: &Path_CAL<br />%left(%trim(&PostedToCAL_msg))</td>";
                            put "  </tr>";
                            put "</table>";
                            put "<br />";

                            %if "%left(%trim(&OVERALL_STATUS))" = "FAILED" %then %do;
                                put "<font color='red'>*** Overall Process has FAILED. SACQ transfer was not posted to CAL. Process must be corrected and transfer re-run. ***</font><br />";
                                put "<br />";
                            %end;

                            %if "%left(%trim(&TransferWarnings))" ne "PASSED" 
                                and "%left(%trim(&TransferWarnings))" ne "Not Completed" 
                                and "%left(%trim(&TransferWarnings))" ne "FAILED" %then %do;

                                %* NOTES or WARNINGS present, post message for user;
                                put "*NOTES and/or WARNINGS are present<br />";
                                put "Primary mapping programmer is required too:<br />";
                                put "  1) Confirm for NOTES that all source data is mapped correctly with no loss of data<br />";
                                put "  2) Confirm for WARNINGS that data issues are passed to PCDA and confirm no mapping issues/loss of data<br />";
                                put "SACQ Transfer Listing: &Path_SACQRoot/&MacroRunDate/&pfesacq_map_scrf_listingname<br />";
                                put "<br />";
                            %end;

                            put "----------------------------------------------------------------------------------------------------------------<br />";
                            put "Run Duration: &duration <br />";
                            put "End of automatic generated email";
                        run;
                    quit;
                %end;  
                %else %do;
                    %LogMessageOutput(n, Email Notification not sent due to input parameter TESTING=&TESTING or no email addresses specified, pfesacq_csdw_auto -> SendEmail);
                %end;                        

                %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> SendEmail);
            %mend SendEmail;

    		%* MACRO: CleanUp
             * PURPOSE: Check for structure differences from previous SACQ transfer
             *   and email PFE and PXL teams list of differences if they exist
             * INPUT:  
             *   1) Macro Variable RC - Used for return code
             *   2) Work Dataset EMAIL_PXL  - See macro Initialize for attributes
             *   3) Macro variable Path_Progs - path for pfesacq_map_scrf.sas run file
             *   4) Macro variable Path_SACQRoot - root path for SACQ output
             * OUTPUT: 
             *   1) Macro Variable RC
             *      1) RC = 0 if no error and needs to run SACQ transfer
             *      2) RC = 1 if error found
             *;
             	%macro CleanUp;
               		%LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto -> CleanUp);

                  %* Macro End Setup Reset;
                      title;
                      footnote;
                      OPTIONS fmterr NOMINOPERATOR quotelenmax; * Reset Ignore format notes in log;
                      OPTIONS missing='.';
                      options printerpath='';

               		%* Remove work datasets and views;
          				    %let tablelist = ;
          				    %let viewlist = ;
          				    proc sql noprint;
          				        select memname into:tablelist separated by ','
          				        from sashelp.vtable 
          				        where libname = "WORK" and memtype = "DATA"
          				        and memname not in ("_UNITTEST_PRGOPTIONS","_UNITTEST_RAW","CONFIG","EMAIL_PXL","DIFFERENCES")
          				        ;

          				        select memname into:viewlist separated by ','
          				        from sashelp.vtable 
          				        where libname = "WORK" and memtype = "VIEW"
          				        and memname not in ("_UNITTEST_PRGOPTIONS","_UNITTEST_RAW")
          				        ;

          				        %if &tablelist ne %then %do;
          				          drop table &tablelist;
          				        %end;
          				        
          				        %if &viewlist ne %then %do;
          				          drop view &viewlist;
          				        %end;
          				    quit;

               		%* Remove libraries if exist;
          				    %macro dellib(libn=null);
          				        proc sql noprint;
          				            select count(*) into: exists
          				            from sashelp.vlibnam
          				            where libname = "%upcase(&libn)";
          				        quit;
          				        %if %eval(&exists > 0) %then %do;
          				            libname &libn clear;
          				            %put NOTE:[PXL] Deallocated library &libn;
          				        %end;            
          				    %mend dellib;
          				    %dellib(libn=LIB_SCRF);
          				    %dellib(libn=LIB_SACQ);
          				    %dellib(libn=LIB_TRAN);
                      %dellib(libn=TLOG);
                      %dellib(libn=LIB_DOWN);

          				%* Remove GLOBAL macro variables;
          				    %symdel pfelogcheck_pdflistingname 
          				            pfelogcheck_TotalLogIssues
          			            	/nowarn ;
                  %* Macro End Remove Catalogs Created;
                      %macro delcat(catn=null);
                          proc sql noprint;
                              select count(*) into: exists
                              from sashelp.vcatalg
                              where libname = "WORK"
                                    and memname = "%upcase(&catn)";
                          quit;
                          %if %eval(&exists > 0) %then %do;
                              proc catalog catalog=&catn kill; run; quit;
                              %put NOTE:[PXL] Deallocated category &catn;
                          %end;            
                      %mend delcat;
                      %delcat(catn=PARMS);                               

               		%LogMessageOutput(i, End of Macro, pfesacq_csdw_auto -> CleanUp);
              %mend CleanUp; 

    %* Run Process;
        %LogMessageOutput(i, Start of Macro, pfesacq_csdw_auto);
        %PreProcessing; %if &RC = 1 %then %goto macerr;
        %CheckInput; %if &RC = 1 %then %goto macerr;
        %CheckRunNeed; 
            %if &RC = 1 %then %goto macerr;
            %if &RC = 2 %then %goto macend; %* Run not needed;
        %run_pfesacq_map_scrf; %if &RC = 1 %then %goto macerr;
        %RunLogcheck; %if &RC = 1 %then %goto macerr;
        %CheckDifferences; %if &RC = 1 %then %goto macerr;
        %RunZip; %if &RC = 1 %then %goto macerr;
        %GetWarnings; %if &RC = 1 %then %goto macerr;
        %Ongoing_Logcheck; %if &RC = 1 %then %goto macerr;
        %PostToCal; %if &RC = 1 %then %goto macerr;

        %* Temporary force run of SACQ validator;
            %if "&TESTING" ne "Y" and "&TESTING" ne "YES" %then %do;
                libname LIB_SACQ "&Path_SACQRoot/%left(%trim(&MacroRunDate))";
                libname SACQ_MD "/projects/std_pfizer/sacq/metadata/data";
                %pfesacq_validator(
                                    pfesacq_validator_inlib = LIB_SACQ,
                                    pfesacq_validator_outpath = LIB_SACQ
                                  );
            %end;

        %* Made it this far then OVERALL STATUS is PASSED;
        data EMAIL_PXL;
            set EMAIL_PXL;
            if DESC="Overall Status" then VALUE="PASSED";
        run;

        %LogTransfer;
        %SendEmail;
	    
    %* End of Macro;
        %goto macend;

        %macerr:;

            %* Rename SACQ to error_;
            %RenameToError(PathRoot=&Path_SACQRoot, CurDate=&MacroRunDate, MacroPath=pfesacq_csdw_auto);

            %* Delete any transfer metadata so will get correct difference report on next pass;
            libname LIB_TRAN "&Path_Metadata/transfer_data";
            %if %sysfunc(fileexist(&Path_Metadata/transfer_data/&current_transfer_metadata)) > 0 
                and "&current_transfer_metadata" ne "null" 
                and "&current_transfer_metadata" ne "" %then %do;
                proc datasets library=LIB_TRAN nolist; delete LIB_TRAN.&current_transfer_metadata; run;
            %end;            

            %let GMPXLERR = 1;
            %LogMessageOutput(e, Abnormal end to program. Review Log., pfesacq_csdw_auto);
            %LogTransfer;
            %SendEmail;

        %macend:;
            %CleanUp;
            %LogMessageOutput(i, End of Macro, pfesacq_csdw_auto);
%mend pfesacq_csdw_auto;