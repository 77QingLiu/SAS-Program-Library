/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Called from parent macro pfesacq_map_scrf:
                         %let ErrFlag = 0;
	                     %pfesacq_map_scrf_input_checks;

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2015-09-09 10:27:14 -0400 (Wed, 09 Sep 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_map_scrf_input_checks.sas $
 
  Files Created:         None
 
  Program Purpose:       Verify input source data 

                         Macro will run each input check per 'Input Checks' tab
                         on the macro design plan; 
                         output message to log for start and end and if pass or 
                         fail. If any fail, exists the macro while showing an 
                         error message to the log for that check and setting 
                         ErrFlag=1.  Parent macro then terminates and outputs 
                         error message to log as well. 
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Data Sources:
 
	1) Parent macro input parameter SRCINPUT - 
	   source SAS library for study SCRF datasets
	2) Parent macro input parameter SACQ_METADATA - 
	   path of all sacq metadata information
	3) Parent macro input parameter CODELISTS - 
	   name of the SAS dataset that contains Pifzer codelists standards data
	4) SAS dataset &srcInput.DEMOG - 
	   required CSDW SCRF dataset to be present, checks if it exists
	5) Global macro variable PROTOCOL - 
	   should be set to Pfizer's protrocol name
	6) Global macro variable PXL_CODE - 
	   should be set to PAREXEL's study number
	7) Parent macro input parameter TAROUTPUT - 
	   optional specified target SAS library for SACQ datasets
	8) Global macro variable PATH_DM - 
	   if tarOutput not specified then root path for SACQ output datasets 
	   YYYYMMDD directory
	9) Global macro variable DEVEL - 
	   if tarOutput not specified then reads in DEVEL (if greater than 0 then 
	   run from development, otherwise run form production area)
	10) Parent macro input parameter PATH_CAL - 
	    specified directory path for output CAL system transfer of zip files
	11) Parent macro input parameter TRANSFER_DATA - 
	    specified directory path for SACQ metadata information (SAS files for 
	    specifications, codelist, study_data, and transfer_log data)
	12) Parent macro input parameter STUDY_DATA - 
	    specified SAS dataset that holds study general data 
	    (locked, cleaninless, etc)
	13) Parent macro input parameter TRANSFER_LOG - 
	    specified SAS dataset that holds metadata on each SACQ transfer 
	    (date time, issues, if errors and not trasnfered to CAL, etc)
	14) Parent macro input parameter TESTING - 
	    YES/NO value that specifies if posts to CAL or not
	15) Parent macro input parameter VERSION - 
	    used to check with SACQ_&VERSION specifies valid SAS metadata dataset
 
  Macro Output:   
    
    Name:              ErrFlag
    Type:              Parent created macro variable
    Allowed Values:    1, 0
    Default Value:     0
    Description:       If input checks do not pass, ErrFlag set to 1

    Name:              SACQ_MD
    Type:              SAS library
    Allowed Values:    Valid SAS library
    Default Value:     N/A
    Description:       SAS library for source SACQ metadata data (created from 
                       pfesacq_map_input_checks from parent macro input 
                       parameter SACQ_METADATA)

    Name:              tarOutput
    Type:              Parent created input parameter macro variable
    Allowed Values:    Valid SAS library that will store output SACQ datasets
    Default Value:     null
    Description:       If already a valid SAS library set, verify and pass 
                       through. If null, create per 
                       &devel > 0 then &path_dm/datasets/sacq/draft
                       else then &path_dm/datasets/sacq/YYYYMMDD

  Macro Dependencies:  This is a submacro dependant on calling parent macro: 
                       pfesacq_map_scrf.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1085 $
-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_input_checks;

/*
	MODIFICATION VERSIONS: 

	Version: 1.0 Date: 20150212 Author: Nathan Hartley

	Version: 2.0 Date: 20150909 Author: Nathan Hartley
		Updates:
		1) Added to check 1.14 for encoding=WLATIN1 as required per Pfizer CAL
*/

*******************************************************
* Internal Macros;

	* PURPOSE: Output log message for start of check macro
	  INPUT: checkid=CHECK ID Number
	         check=description of check
	  OUTPUT: Start of check message to log only;
		%macro _StartCheck(checkid=null, check=null);
			%put ---------------------------------------------------------------------;
			%put Check &checkid.: &check;
			%put ---------------------------------------------------------------------;
		%mend _StartCheck;

	* PURPOSE: Output log message for end of check macro
	  INPUT: 1) Macro Parameter CHECK=CHECK ID Number
	         2) Macro Parameter STATUS=PASS or FAIL Message to display
	  OUTPUT: 1) End of check message to log only;
		%macro _EndCheck(check=null, status=null);
			%put ---------------------------------------------------------------------;
			%put Check &check.: Completed: &status;
			%put ---------------------------------------------------------------------;
		%mend _EndCheck;

*******************************************************
* Input Checks Macros;

	%_StartCheck(checkid=1.01-1.13,check=Verify Input Sources);

	%let ErrFlag=0;

	* PURPOSE: CHECK ID 1.01: Verify input parameter srcInput specifies a valid SAS library that exists
	  INPUT: 1) Macro input parameter srcInput
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_1;
			%_StartCheck(checkid=1.01,check=Verify SAS Library SCRF);

			%let FLAG=0;
			proc sql noprint;
				select count(*) into: FLAG
				from sashelp.vslib
				where libname=upcase("&srcInput");
			quit;

			%if &FLAG=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS Library [%upcase("&srcInput")] is not valid.;
			    %let ErrFlag=1;
			    %_EndCheck(check=1.01, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.01, status=PASS);
			%end;
		%mend _C1_1;

	* PURPOSE: CHECK ID 1.02: Verify Macro Variable SACQ_METADATA is a valid directory
	  INPUT: 1) Macro input variable &sacq_metadata - Shows path of all metadata 
	            information
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_2;
			%_StartCheck(checkid=1.02,check=Verify Macro Variable SACQ_METADATA is a valid directory);

			%if %sysfunc(fileexist("&sacq_metadata")) = 0 %then %do;
			    %put %str(ERR)OR:[PXL] Unix file path &sacq_metadata is not valid.;
			    %let ErrFlag=1;
			    %_EndCheck(check=1.02, status=FAIL);
			%end;
			%else %do;
				libname SACQ_MD "&sacq_metadata";
				%_EndCheck(check=1.02, status=PASS);
			%end;
		%mend _C1_2;

	* PURPOSE: CHECK ID 1.03: Verify metadata SAS dataset for Pfizer codelists exists
	  INPUT: 1) Macro variable &codelists - name of the SAS dataset that contains 
	            Pifzer codelists standards data
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_3;
			%_StartCheck(checkid=1.03,check=Verify metadata SAS dataset for Pfizer codelists exists);
			%let FLAG=0;
			proc sql noprint;
				select count(*) into: FLAG
				from (select distinct memname, libname from sashelp.vcolumn) 
				where memname = upcase("&codelists");
			quit;
			%if &FLAG=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS dataset &sacq_metadata/&codelists is not valid.;
			    %let ErrFlag=1;	
			    %_EndCheck(check=1.03, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.03, status=PASS);
			%end;
		%mend _C1_3;

	* PURPOSE: CHECK ID 1.04: Verify metadata SAS dataset for SACQ Standards exist (SACQ_&VERSION)
	  INPUT: 1) Macro variable &sacq - name of the SAS dataset that contains 
	            Pifzer SACQ standards data
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_4;
			%_StartCheck(checkid=1.04,check=Verify metadata SAS dataset for SACQ Standards exist);
			%let FLAG=0;
			proc sql noprint;
				select count(*) into: FLAG
				from (select distinct memname, libname from sashelp.vcolumn) 
				where memname = upcase("&sacq");
			quit;
			%if &FLAG=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS dataset &sacq_metadata/&sacq is not valid.;
			    %let ErrFlag=1;	
			    %_EndCheck(check=1.04, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.04, status=PASS);
			%end;
		%mend _C1_4;

	* PURPOSE: CHECK ID 1.05: Verify SCRF DEMOG dataset exists
	  INPUT: 1) SAS library SCRF
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_5;
			%_StartCheck(checkid=1.05,check=Verify SCRF DEMOG dataset exists);
			%let FLAG=0;
			proc sql noprint;
				create table _c1_5 as
				select distinct libname, memname from sashelp.vtable
				where upcase(libname) = upcase("&srcInput")
				      and upcase(memname) = upcase("DEMOG");

				select count(*) into: FLAG
				from _c1_5;
			quit;
			%if &FLAG=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS dataset DEMOG does not exist.;
			    %let ErrFlag=1;	
			    %_EndCheck(check=1.05, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.05, status=PASS);
			%end;
		%mend _C1_5;

	* PURPOSE: CHECK ID 1.06: Verify global macro variable PROTOCOL exists and has a value
	  INPUT: 1) Macro variable PROTOCOL - Created in study /macro/project_setup.sas, names
	            Pfizer protocol name
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_6;
			%_StartCheck(checkid=1.06,check=Verify global macro variable PROTOCOL exists and has a value);

			* Check if global macro variable &protocol exists;
			%let FLAG1=0;
			proc sql noprint;
				select count(*) into: FLAG1
				from sashelp.vmacro
				where upcase(scope) = "GLOBAL"
				      and upcase(name) = upcase("PROTOCOL")
				      and VALUE is not null;
			quit;

			%if &FLAG1=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS global macro variable PROTOCOL does not exist.;
			    %put %str(ERR)OR:[PXL] Should be set within /projects/pfizrNNNNNN/macros/project_setup.sas;
			    %put %str(ERR)OR:[PXL] Should hold the value for the Pfizer PROTOCOL name;
			    %let ErrFlag=1;	
			    %_EndCheck(check=1.06, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.06, status=PASS);
			%end;
		%mend _C1_6;

	* PURPOSE: CHECK ID 1.07: Verify global macro variable PXL_CODE exists and has a value
	  INPUT: 1) Macro variable PXL_CODE - Created through pfizer standards autoexec.sas call
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_7;
			%_StartCheck(checkid=1.07,check=Verify global macro variable PXL_CODE exists and has a value);

			* Check if global macro variable &pxl_code exists;
			%let FLAG1=0;
			proc sql noprint;
				select count(*) into: FLAG1
				from sashelp.vmacro
				where upcase(scope) = "GLOBAL"
				      and upcase(name) = "PXL_CODE"
				      and VALUE is not null;
			quit;

			%if &FLAG1=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS global macro variable PXL_CODE does not exist.;
			    %put %str(ERR)OR:[PXL] Created through Pfizer standards autoexec.sas call;
			    %put %str(ERR)OR:[PXL] Should hold the value of the PAREXEL study code;
			    %let ErrFlag=1;	
			    %_EndCheck(check=1.07, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.07, status=PASS);
			%end;
		%mend _C1_7;

	* PURPOSE: CHECK ID 1.08: Check and Create output SACQ location
	  INPUT: 1) &path_dm - global macro variable for study specific location on kennet
	         2) &devel - global macro variable for run from development or production
	         3) Input parameter &tarOutput - for testing, should be libname for output
	            to overide output location
	  OUTPUT: 1) &path_dm/datasets/sacq/YYYYMMDD or draft
                 - draft if run from development
                 - YYYYMMDD if run from production for date run
                 or if &output is not null, to this libname location;
		%macro _C1_8;
			%_StartCheck(checkid=1.08,check=Check and Create output SACQ location);

			%if &tarOutput = null %then %do;
				%let tarOutput=sacq;

				* Check if global macro variable path_dm exists;
				%let FLAG1=0;
				proc sql noprint;
					select count(*) into: FLAG1
					from sashelp.vmacro
					where upcase(scope) = "GLOBAL"
					      and upcase(name) = "PATH_DM"
					      and VALUE is not null;
				quit;

				* Check if global macro variable devel exists;
				%let FLAG2=0;
				proc sql noprint;
					select count(*) into: FLAG2
					from sashelp.vmacro
					where upcase(scope) = "GLOBAL"
					      and upcase(name) = "DEVEL"
					      and VALUE is not null;
				quit;

				* Test devel is number;
				proc sql noprint;
					select count(*) into: _testDevel
					from sashelp.vmacro
					where upcase(scope) = "GLOBAL"
					      and upcase(name) = "DEVEL"
					      and value is not null
					      and input(value, 8.) is not null
					      and input(value, 8.) >= 0;
				quit;

				%if &FLAG1=0 %then %do;
				    %put %str(ERR)OR:[PXL] SAS global macro variable path_dm does not exist.;
				    %put %str(ERR)OR:[PXL] Should specify path such as /projects/pfizrNNNNNN/dm/datasets;
				    %let ErrFlag=1;	
				    %_EndCheck(check=1.08, status=FAIL);
				%end;
				%else %if &FLAG2=0 %then %do;
				    %put %str(ERR)OR:[PXL] SAS global macro variable devel does not exist.;
				    %put %str(ERR)OR:[PXL] Value should be 0 for production or >0 for development.;
				    %let ErrFlag=1;	
				    %_EndCheck(check=1.08, status=FAIL);
				%end;
				%else %if %sysfunc(fileexist("&path_dm")) = 0 %then %do; 
				    %put %str(ERR)OR:[PXL] SAS global macro variable path_dm= &path_dm not exist.;
				    %put %str(ERR)OR:[PXL] Should specify path such as /projects/pfizrNNNNNN/dm/datasets;
				    %let ErrFlag=1;	
				    %_EndCheck(check=1.08, status=FAIL);					
				%end;
				%else %if %eval(&_testDevel) = 0 %then %do;
					%put %str(ERR)OR:[PXL] SAS global macro variable devel value is not a number.;
			    	%put %str(ERR)OR:[PXL] Value should be 0 for production or >0 for development.;
			    	%put %str(ERR)OR:[PXL] SAS global macro variable devel = &devel;
			    	%let ErrFlag=1;	
			    	%_EndCheck(check=1.08, status=FAIL);
			    %end;
				%else %do;
					* Create sacq path if not present;
					%if %sysfunc(fileexist("&path_dm/datasets/sacq")) = 0 %then %do;
						%put NOTE:[PXL] Path not found, creating: &path_dm/datasets/sacq;
						data _null_;
							command1 = 'mkdir ' || "&path_dm/datasets/sacq" ;
							command2 = 'chmod 775 ' || "&path_dm/datasets/sacq" ;
							rc1 = system(command1) ;
							rc2 = system(command2) ;
						run ;
					%end;

					* Create sacq/draft path if not present;
					%if %sysfunc(fileexist("&path_dm/datasets/sacq/draft")) = 0 %then %do;
						%put NOTE:[PXL] Path not found, creating: &path_dm/datasets/sacq/draft;
						data _null_;
							command1 = 'mkdir ' || "&path_dm/datasets/sacq/draft" ;
							command2 = 'chmod 775 ' || "&path_dm/datasets/sacq/draft" ;
							rc1 = system(command1) ;
							rc2 = system(command2) ;
						run ;
					%end;

					%if %eval(&devel) = 0 %then %do;
						* Run from production, create dated sacq/YYYYMMDD folder;
						%let _date=%sysfunc(compress(%sysfunc(today(),yymmddd10.),'-'));

						data _null_;
							command1 = 'mkdir ' || "&path_dm/datasets/sacq/&_date" ;
							command2 = 'chmod 775 ' || "&path_dm/datasets/sacq/&_date" ;
							rc1 = system(command1) ;
							rc2 = system(command2) ;
						run ;
						%put NOTE:[PXL] Ran from production, SACQ points to: &path_dm/datasets/sacq/&_date;
						libname &tarOutput "&path_dm/datasets/sacq/&_date";
					%end;
					%else %do;
						* Run from development, point to draft;
						%put NOTE:[PXL] Ran from development, SACQ points to: &path_dm/datasets/sacq/draft;
						libname &tarOutput "&path_dm/datasets/sacq/draft";
					%end;
					%_EndCheck(check=1.08, status=PASS);
				%end;
			%end;
			%else %do;
					* Input parameter &tarOutput is other than null;

					* Check if SAS libname &tarOutput is valid;
					%let FLAG=0;
					proc sql noprint;
						select count(*) into: FLAG
						from sashelp.vslib
						where upcase(libname)=upcase("&tarOutput");
					quit;

					%if &FLAG=0 %then %do;
					    %put %str(ERR)OR:[PXL] SAS global library for input parameter &tarOutput does not exist.;
					    %let ErrFlag=1;	
					    %_EndCheck(check=1.08, status=FAIL);
					%end;
					%else %do;
						%_EndCheck(check=1.08, status=PASS);
					%end;
			%end;
		%mend _C1_8;

	* PURPOSE: CHECK ID 1.09: Verify macro input parameter PATH_CAL is a valid directory
	  INPUT: 1) Macro variable &PATH_CAL - Shows path of all metadata 
	            information
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_9;
			%_StartCheck(checkid=1.09,check=Verify macro input parameter PATH_CAL is a valid directory);

			%if %sysfunc(fileexist("&PATH_CAL")) = 0 %then %do;
			    %put %str(ERR)OR:[PXL] Unix file path &PATH_CAL is not valid.;
			    %let ErrFlag=1;
			    %_EndCheck(check=1.09, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.09, status=PASS);
			%end;
		%mend _C1_9;

	* PURPOSE: CHECK ID 1.10: Verify macro input parameter TRANSFER_DATA is a valid directory
	  INPUT: 1) Macro variable &TRANSFER_DATA - Shows path of all metadata 
	            information
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_10;
			%_StartCheck(checkid=1.10,check=Verify macro input parameter TRANSFER_DATA is a valid directory);

			%if %sysfunc(fileexist("&TRANSFER_DATA")) = 0 %then %do;
			    %put %str(ERR)OR:[PXL] Unix file path &TRANSFER_DATA is not valid.;
			    %let ErrFlag=1;
			    %_EndCheck(check=1.10, status=FAIL);
			%end;
			%else %do;
				libname transdat "&transfer_data";
				%_EndCheck(check=1.10, status=PASS);
			%end;
		%mend _C1_10;

	* PURPOSE: CHECK ID 1.11: Verify macro input parameter STUDY_DATA is a valid SAS dataset under &sacq_metadata/&STUDY_DATA
	  INPUT: 1) SAS &sacq_metadata/&STUDY_DATA
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_11;
			%_StartCheck(checkid=1.11,check=Verify &sacq_metadata/&STUDY_DATA dataset exists);
			%let FLAG=0;
			proc sql noprint;
				create table _c1_11 as
				select distinct libname, memname from sashelp.vtable
				where upcase(libname) = upcase("SACQ_MD")
				      and upcase(memname) = upcase("&STUDY_DATA");

				select count(*) into: FLAG
				from _c1_11;
			quit;
			%if &FLAG=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS dataset &sacq_metadata..&STUDY_DATA does not exist.;
			    %let ErrFlag=1;	
			    %_EndCheck(check=1.11, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.11, status=PASS);
			%end;
		%mend _C1_11;

	* PURPOSE: CHECK ID 1.12: Verify macro input parameter TRANSFER_LOG is a valid SAS dataset under &sacq_metadata/&TRANSFER_LOG
	  INPUT: 1) SAS &sacq_metadata/&TRANSFER_LOG
	  OUTPUT: 1) if found, show PASS note in log,
	             if not found, throw message to log and exist program;
		%macro _C1_12;
			%_StartCheck(checkid=1.12,check=Verify macro input parameter TRANSFER_LOG is a valid SAS dataset under &sacq_metadata/&TRANSFER_LOG);
			%let FLAG=0;
			proc sql noprint;
				create table _c1_12 as
				select distinct libname, memname from sashelp.vtable
				where upcase(libname) = upcase("SACQ_MD")
				      and upcase(memname) = upcase("&TRANSFER_LOG");

				select count(*) into: FLAG
				from _c1_12;
			quit;
			%if &FLAG=0 %then %do;
			    %put %str(ERR)OR:[PXL] SAS dataset &sacq_metadata.&TRANSFER_LOG does not exist.;
			    %let ErrFlag=1;	
			    %_EndCheck(check=1.12, status=FAIL);
			%end;
			%else %do;
				%_EndCheck(check=1.12, status=PASS);
			%end;
		%mend _C1_12;

	* PURPOSE: CHECK ID 1.13: Verify macro input parameter TESTING value is either YES or NO (defaulted to NO)
	  INPUT: 1) input parameter TESTING
	  OUTPUT: 1) if value is YES or NO, show PASS note in log,
	             if not, throw message to log and exist program;
		%macro _C1_13;
			%_StartCheck(checkid=1.13,check=Verify macro input parameter TESTING value is either YES or NO);
			%if %upcase(&TESTING) = YES or %upcase(&TESTING) = NO %then %do;
				%_EndCheck(check=1.13, status=PASS);
			%end;
			%else %do;
				%put %str(ERR)OR:[PXL] Macro input parameter TESTING is not YES or NO: TESTING=&TESTING;
			    %let ErrFlag=1;	
				%_EndCheck(check=1.13, status=FAIL);
			%end;
		%mend _C1_13;

	* PURPOSE: CHECK ID 1.14: Verify run using -encoding wlatin1 as required per Pfizer CAL system
	  INPUT: 1) System encoding 
	  OUTPUT: 1) if encoding=WLAINT1 then show PASS note in log,
	             if not, throw message to log and exist program;
		%macro _C1_14;
			%_StartCheck(checkid=1.14,check=Verify run using -encoding wlatin1 as required per Pfizer CAL system);

			%put NOTE:[PXL] sysencoding=&sysencoding; * Shows system encoding option;
			proc options option=encoding; run; * Shows system encoding option set;

			%if %str("%upcase(&testing)") = %str("YES") %then %do;
				%put NOTE:[PXL] Check 1.14 Does not check encoding when Input Parameter TESTING=YES as data is not transfered to Pfizer CAL;
			%end;
			%else %do;
				%if %str("%upcase(&sysencoding)") = %str("WLATIN1") %then %do;
					%put NOTE:[PXL] Check 1.14 PASS Encoding = WLATIN;
					%_EndCheck(check=1.14, status=PASS);
				%end;
				%else %do;
					%put %str(ERR)OR:[PXL] Macro was not run using -encoding wlatin1 system parameter: Encoding=&sysencoding;
				    %let ErrFlag=1;	
					%_EndCheck(check=1.14, status=FAIL);				
				%end;
			%end;
		%mend _C1_14;

*******************************************************
* Input Check Macro Calls;

	%_C1_1;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_2;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_3;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_4;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_5;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_6;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_7;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_8;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_9;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_10;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_11;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_12;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_13;
	%if &ErrFlag=1 %then %goto macerr;
	%_C1_14;
	%if &ErrFlag=1 %then %goto macerr;	

*******************************************************
* End of Submacro;

	%put ;
	%_EndCheck(check=1.1-1.13, status=PASS);

	%goto macend;
	%macerr:;
	%put %str(ERR)OR:[PXL] ---------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_INPUT_CHECKS: Abnormal end to submacro. Review Log.;
	%put %str(ERR)OR:[PXL] ---------------------------------------------------------------------;
	%_EndCheck(check=1.1-1.13, status=FAIL);

	%macend:;

%mend pfesacq_map_scrf_input_checks;