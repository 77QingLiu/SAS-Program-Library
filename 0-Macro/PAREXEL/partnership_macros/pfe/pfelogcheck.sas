/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20150821       $LastChangedDate: 2015-08-21 16:00:11 -0400 (Fri, 21 Aug 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfelogcheck.sas $
 
  Files Created:         1) Global Macro Variable: pfelogcheck_TotalLogIssues
                         2) Global Macro Variable: pfelogcheck_pdflistingname
                         3) Work SAS Dataset: LogIssues
                         4) PDF Listing pfelogcheck_pdflistingname
                         5) UNIX prompt messages
 
  Program Purpose:       Check a SAS log for potential issues

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has not been validated for use only in PAREXEL's
                         working environment yet.
 
  Macro Parameters:
 
    Name:                FileName
      Allowed Values:    Valid SAS log path and file name
      Default Value:     null
      Description:       Source SAS log path and file name to review for potential issues
 
    Name:                _pxl_code
      Allowed Values:    PAREXEL study code
      Default Value:     null
      Description:       PAREXEL study code passed as input parameter or if null then will try to get 
                         the value from a global macro PXL_CODE
 
    Name:                _protocol
      Allowed Values:    Pfizer study protocol code
      Default Value:     null
      Description:       Pfizer study protocol as input parameter or if null then will try to get 
                         the value from a global macro PROTOCOL

    Name:                AddDateTime
      Allowed Values:    Y|N
      Default Value:     N
      Description:       If Y then will add date time as b8601dt to output PDF listing name

    Name:                IgnoreList
      Allowed Values:    String text without commas that uses the seperater: @
      Default Value:     null
      Description:       Uses index function to check if string in found log lines for potential 
                         issues and then removes it if found from being counted

    Name:                ShowInUnix
      Allowed Values:    Y|N
      Default Value:     N
      Description:       Will show issues found in UNIX prompt if Y

    Name:                CreatePDF
      Allowed Values:    Y|N
      Default Value:     Y
      Description:       Will output PDF listing of issues or clean if Y

  Global Macrovariables:
 
    Name:                pfelogcheck_TotalLogIssues
      Usage:             Creates
      Description:       Sets to number of potential issues found in log

    Name:                pfelogcheck_pdflistingname
      Usage:             Creates
      Description:       Sets to name of output listing pdf created

  Version History:
	Version: 1.0 Date: 20150821 Author: Nathan Hartley

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1001 $

-----------------------------------------------------------------------------*/

%macro pfelogcheck(
	FileName=null,
	_pxl_code=null,
	_protocol=null,
	AddDateTime=N,
	IgnoreList=null,
	ShowInUnix=N,
	CreatePDF=Y);

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Macro Startup;
	%put NOTE:[PXL] ***********************************************************************;
		* Macro Variable Declarations;
			%let pfelogcheck_MacroName        = PFELOGCHECK;
			%let pfelogcheck_MacroVersion     = 1.0;
			%let pfelogcheck_MacroVersionDate = 20150821;
			%let pfelogcheck_MacroPath        = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
			%*let pfelogcheck_MacroPath        = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
			%let pfelogcheck_RunDateTime      = %sysfunc(left(%sysfunc(datetime(), b8601dt.)));

			%global pfelogcheck_TotalLogIssues pfelogcheck_pdflistingname;
			%let pfelogcheck_TotalLogIssues = null; * Total log issues found;
			%let pfelogcheck_pdflistingname = null; * PDF Listing output file name;

			%put INFO:[PXL]----------------------------------------------;
			%put INFO:[PXL] &pfelogcheck_MacroName: Macro Started; 
    		%put INFO:[PXL] File Location: &pfelogcheck_MacroPath ;
    		%put INFO:[PXL] Version Number: &pfelogcheck_MacroVersion ;
    		%put INFO:[PXL] Version Date: &pfelogcheck_MacroVersionDate ;
			%put INFO:[PXL] Run DateTime: &pfelogcheck_RunDateTime;    		
    		%put INFO:[PXL] ;
    		%put INFO:[PXL] Purpose: Check SAS log for potential issues ; 
			%put INFO:[PXL] Input Paramters:;
			%put INFO:[PXL]		1) FileName = &FileName;
			%put INFO:[PXL]		2) _pxl_code = &_pxl_code;
			%put INFO:[PXL]		3) _protocol = &_protocol;
			%put INFO:[PXL]		4) AddDateTime = &AddDateTime;
			%put INFO:[PXL]		5) IgnoreList = &IgnoreList;
			%put INFO:[PXL]		6) ShowInUnix = &ShowInUnix;
			%put INFO:[PXL]		7) CreatePDF = &CreatePDF;															
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
	            %put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Global macro GMPXLERR = 1, macro not executed;
	            %goto MacErr;
	        %end;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Verify and Set Parameters;
	%put NOTE:[PXL] ***********************************************************************;
			%if %str("&FileName") = %str("null") %then %do;
				%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input Parameter FileName must contain a valid path and log file to check: &FileName;
	            %goto MacErr;
			%end;
			%if not %sysfunc(fileexist(&FileName)) %then %do;
				%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input Parameter FileName must contain a valid path and log file to check: &FileName;
	            %goto MacErr;
			%end;
			%if not %index(&FileName, .log) %then %do;
				%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input Parameter FileName must contain a valid path and log file to check: &FileName;
	            %goto MacErr;
			%end;

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
					%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input Parameter _pxl_code is null and global macro pxl_code not found;
	            	%goto MacErr;					
				%end;
				%else %do;
					* Global macro found, use it;
					%let _pxl_code = &pxl_code;
				%end;
			%end;

			%if %str("&_protocol") = %str("null") %then %do;
				* If not set, use global macro pxl_code if exists;
				proc sql noprint;
					select count(*) into: cnt
					from sashelp.vmacro
					where scope = "GLOBAL"
					      and name = "PROTOCOL";
				quit;
				%if %eval(&cnt = 0) %then %do;
					* Global macro not found, exit macro;
					%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input Parameter _protocol is null and global macro protocol not found;
	            	%goto MacErr;					
				%end;
				%else %do;
					* Global macro found, use it;
					%let _protocol = &pxl_code;
				%end;
			%end;

			%if %str("&AddDateTime") ne %str("Y") and %str("&AddDateTime") ne %str("N") %then %do;
				%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input parameter AddDateTime must have a value of Y or N only: &AddDateTime;
	            %goto MacErr;
			%end;

			%if %str("&ShowInUnix") ne %str("Y") and %str("&ShowInUnix") ne %str("N") %then %do;
				%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input parameter ShowInUnix must have a value of Y or N only: &ShowInUnix;
	            %goto MacErr;
			%end;

			%if %str("&CreatePDF") ne %str("Y") and %str("&CreatePDF") ne %str("N") %then %do;
				%put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Input parameter CreatePDF must have a value of Y or N only: &CreatePDF;
	            %goto MacErr;
			%end;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Read and Verify Log;
	%put NOTE:[PXL] ***********************************************************************;
		filename inlog "&FileName";

		* Read log file and filter for potential issues;
		data logissues(keep=line_no type msg);
			label
				line_no = "Log Line #"
				type = "Issue Type"
				msg = "Log Line"
			;			
			length line_no 8. type $10. msg $256.;
			retain line_no 0;
			infile inlog;
			input;
			line_no = line_no + 1;
			msg = _infile_;

			* Remove IgnoreList values if stated;
			%if %str("&IgnoreList") ne %str("null") %then %do;
				%put NOTE:[PXL] Filter for IgnoreList = &IgnoreList;

				* Parse IgnoreList into macro array;
				%let i=1;
				%let s&i = %scan(&IgnoreList, &i, '@');
				%do %while(&&s&i ne );
					%let i=%eval(&i + 1);
					%let s&i = %scan(&IgnoreList, &i, '@');
				%end;
				%let i=%eval(&i - 1);

				* Delete records that have ignore list present;
				%do j=1 %to &i;
					if index(msg, "&&&s&j") > 0 then delete;
				%end;
			%end;

			* Checks;
			if substr(msg,1,6) = "ERROR:" then do;
				type="ERROR";
				output;
			end;
			else if substr(msg,1,8) = "WARNING:" then do;
				if index(msg,"WARNING: DMS bold font metrics fail to match DMS font.") > 0 then do;
					* Ignore this;
				end;
				else if index(msg,"WARNING: Unable to copy SASUSER registry to WORK registry.") > 0 then do;
					* Ignore this;
				end;
				else if index(msg,"WARNING: No matching observations were found.") > 0 then do;
					* Ignore this;
				end;
				else do;
					type="WARNING";
					output;
				end;
			end;
			else if substr(msg,1,5) = "NOTE:" then do;
				if index(msg,"stopped") > 0 
			       or index(msg,"converted") > 0 
			       or index(msg,"uninitialized") > 0 
			       or index(msg,"Division") > 0 
			       or index(msg,"Invalid") > 0  
			       or index(msg,"Missing") > 0 then do;
					type="NOTE";
					output;
				end; 
			end;
			else if index(msg,"Invalid argument to function") > 0
			        or index(msg,"not found") > 0
			        or index(msg,"multiple lengths") > 0
			        or index(msg,"has more than one data set with") > 0
			        or index(msg,"overwrit") > 0
			        or index(msg,"Missing values were generated") > 0 then do;
						type="OTHER";
						output;                
			end;
		run;

		* Get global macro with total issues;
		proc sql noprint;
			select count(*) into: pfelogcheck_TotalLogIssues
			from logissues;
		quit;

        %let pfelogcheck_TotalLogIssues = %left(%trim(&pfelogcheck_TotalLogIssues));
        %put NOTE:[PXL] pfelogcheck_TotalLogIssues = &pfelogcheck_TotalLogIssues;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Output to UNIX;
	%put NOTE:[PXL] ***********************************************************************;
		%if %str("&ShowInUnix") = %str("Y") %then %do;
			%put Input Parameter ShowInUnix = Y, output message to UNIX prompt;

			%if %eval(&pfelogcheck_TotalLogIssues = 0) %then %do;
				%put NOTE:[PXL] Output to UNIX no issues found;
				x "echo ";
				x "echo pfelogcheck: &FileName";
				x "echo Log is Clean";
				x "echo Total Potential Issues Found: 0";
				x "echo ;"
			%end;
			%else %do;
				%put NOTE:[PXL] Output to UNIX list of issues;
				x "echo ";
				x "echo pfelogcheck: &FileName";
				x "echo Total Potential Issues Found: %left(%trim(&pfelogcheck_TotalLogIssues))";
				x "echo ";
				x " echo Line No - Type - Message";

				proc sql noprint;
		            select catx(" - ", line_no, type, msg) as message into :msg_1-:msg_%left(%trim(&pfelogcheck_TotalLogIssues))
		            from logissues;
				quit;

				%do i=1 %to &pfelogcheck_TotalLogIssues;
					x "echo &&msg_&i";
				%end;	

				x "echo ";
			%end;
		%end;
		%else %do;
			%put NOTE:[PXL] Input parameter ShowInUnix = N, not run;
		%end;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Output PDF Listing;
	%put NOTE:[PXL] ***********************************************************************;

		%if %str("&CreatePDF") = %str("Y") %then %do;
			%put NOTE:[PXL] Input parameter CreatePDF = Y, PDF output listing will be created;

			* Derive PASSorFAIL and logIssues if no issues;
			%if %eval(&pfelogcheck_TotalLogIssues = 0) %then %do;
				%put NOTE:[PXL] No issues found, output clean log to PDF listing;

				%let PASSorFAIL=PASSED;
                data logissues;
                    line_no = 0;
                    type = "N/A";
                    msg = "***No Issues Found/Log is Clean***";
                run;
			%end;
			%else %do;
				%put NOTE:[PXL] Issues found, list in PDF listing;

				%let PASSorFAIL=FAILED;
			%end;
			%put NOTE:[PXL] Logcheck Review PASSorFAIL: &PASSorFAIL;

			* Create output listing name;
	        data _null_;
	              _file = symget('FileName');
	              %if %str("&AddDateTime") = %str("Y") %then %do;
	              		* Add date and time run to listing name
	              		  macro var RunDateTime defined under Macro Startup;
	              		_file = tranwrd(_file,".log","_logcheck_&PASSorFAIL._&pfelogcheck_RunDateTime..pdf");
	              %end;
	              %else %do;
	              		_file = tranwrd(_file,".log","_logcheck_&PASSorFAIL..pdf");
	              %end;
	              call symput("pfelogcheck_pdflistingname", _file);
	        run;
	        %put NOTE:[PXL] Global macro pfelogcheck_pdflistingname = &pfelogcheck_pdflistingname;

			* Create PDF logcheck results file;
			ods listing close;
			ods pdf file="&pfelogcheck_pdflistingname";
				title1 j=l "Logcheck Review";

				title2 j=l "Overview";
				data _null_;
					file print ps=49 ls=196 notitles;
					put "Purpose:";
					put "Review SAS log and identify any possible code run issues.";
					put ;
					put "Remediation:";
					put "The SAS log is required to be clean of any potential problems. Correct in SAS code or source data.";
					put ;
					put "---------------------------------------------------------------------------------------";
					put "Run By: %upcase(&sysuserid)";
					put "Run On: &pfelogcheck_RunDateTime";
					put ;
					put "PAREXEL Study Code: &_pxl_code";
					put "Protocol: &_protocol";
					put ;
					put "Run Macro Name: &pfelogcheck_MacroName";
					put "Run Macro Version: &pfelogcheck_MacroVersion";
					put "Run Macro Version Date: &pfelogcheck_MacroVersionDate";
					put "Run Macro Location: &pfelogcheck_MacroPath";
					put ;
					put "---------------------------------------------------------------------------------------";
					put "File Checked: &FileName";
					put ;
					put "Overall PASS or FAIL: &PASSorFAIL";
					put "Total Issues Found: &pfelogcheck_TotalLogIssues";
					put ;
					put "---------------------------------------------------------------------------------------";
					put "Details of Issues listed below";
					put ;
				run;

				title2 j=l "Details";
                proc report data = LogIssues nowd; 
                    column OBS LINE_NO TYPE MSG; 
                    define OBS / computed;
                    compute OBS;
                        DSOBS + 1;
                        OBS = DSOBS;
                    endcompute;
                run;

			ods pdf close;
			ods listing;

		%end;
		%else %do;
			%put NOTE:[PXL] Input parameter CreatePDF = N, PDF output listing will not be created;
		%end;

	%put NOTE:[PXL] ***********************************************************************;
	%put NOTE:[PXL] Macro End;
	%put NOTE:[PXL] ***********************************************************************;
	    %goto MacEnd;
	    %MacErr:;
	    %put %str(ERR)OR:[PXL] ---------------------------------------------------;
	    %put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: Abnormal end to macro;
	    %put %str(ERR)OR:[PXL] &pfelogcheck_MacroName: See log for details;
	    %put %str(ERR)OR:[PXL] ---------------------------------------------------;
	    %let GMPXLERR=1;

		%MacEnd:;
		%put INFO:[PXL]----------------------------------------------;
		%put INFO:[PXL] &pfelogcheck_MacroName: Macro Completed; 
		%put INFO:[PXL] Output: ;
		%put INFO:[PXL] 	1) Global Macro pfelogcheck_TotalLogIssues = &pfelogcheck_TotalLogIssues;
		%put INFO:[PXL]     2) Global Macro pfelogcheck_pdflistingname = &pfelogcheck_pdflistingname;
		%put INFO:[PXL]		3) Work Dataset LogIssues;
		%if %str("&CreatePDF") = %str("Y") %then %do;
			%put INFO:[PXL]		4) PDF Listing: &pfelogcheck_pdflistingname; 
		%end;
		%put INFO:[PXL]----------------------------------------------;

		title;
		footnote; 

%mend pfelogcheck;