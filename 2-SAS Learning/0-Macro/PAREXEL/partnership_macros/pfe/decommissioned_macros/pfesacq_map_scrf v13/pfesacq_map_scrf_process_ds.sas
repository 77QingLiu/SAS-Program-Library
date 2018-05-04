/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          
-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2016-04-12 14:31:01 -0400 (Tue, 12 Apr 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_map_scrf_process_ds.sas $
 
  Files Created:         1) Mapped SACQ dataset
                         2) SAS work dataset of Value Validation LISTING_TAB5
 
  Program Purpose:       Map CSDW SCRF dataset to SACQ and Value Validation
 						 Note: Part of parent macro 'pfesacq_map_scrf' and not 
 						       validated individually

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters:
 
    Name:                inlibSACQMetadata
      Allowed Values:    SAS library
      Default Value:     null
      Description:       SAS library containing SACQ spec and CODELISTS metadata

    Name:                inlibSCRF
      Allowed Values:    SAS library
      Default Value:     null
      Description:       SAS library containing study CSDW SCRF input dataset

    Name:                outlibSACQ
      Allowed Values:    SAS library
      Default Value:     null
      Description:       SAS library to output mapped SACQ dataset

    Name:                inDataSACQSpec
      Allowed Values:    SAS Dataset Name
      Default Value:     null
      Description:       SAS Dataset for SACQ specification metadata

    Name:                inDataCodelists
      Allowed Values:    SAS Dataset Name
      Default Value:     null
      Description:       SAS Dataset for Pfizer Codelist metadata

    Name:                inDataDS
      Allowed Values:    SAS Dataset Name
      Default Value:     null
      Description:       SAS CSDW SCRF dataset name to map

    Name:                inVersion
      Allowed Values:    SACQ Specification Version
      Default Value:     null
      Description:       SACQ Specification Version, example: 'V1_9', output 
                         set for SACQ dataset label

    Name:                inProtocol
      Allowed Values:    Pfizer Study Protocol
      Default Value:     null
      Description:       Pfizer Protocol, used to check data values in CK_V8

  Macro Dependencies:    This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf.sas

  Called Macros:         %pfesacq_map_scrf_char_dates
                         %pfesacq_map_scrf_char_times

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2152 $
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
Note: Version based on parent macro PFESACQ_MAP_SCRF

Version: 1.0 Date: 12FEB2015 Author: Nathan Hartley

Version: 2.0 Date: 25MAR2015 Author: Nathan Hartley
  1) Updated to not save to output SACQ dataset for no observations
  
Version: 3.0 Date: 20150918 Author: Nathan Johnson
    1) Updated to use dynamic _metadata dataset to get retain SACQ variable list 
       rather than the verison in sacq_md. This allows UIMS variables to be included
       in the final sacq datasets. See updates to pfesacq_map_scrf for details
       on the UIMS variables.

Version: 4.0 Date: 20151229 Author: Nathan Hartley
    1) Re-wrote macro to modular
    2) Included pfesacq_map_scrf_validate_value within this macro
    3) Added CK_V12 - CODELIST values compared to ROOT consistancy
    4) Modified to map per CODELIST_FORMAT
    5) Removed external calls to pfesacq_map_scrf_codelist_char and _num

Version: 5.0 Date: 20160104 Author: Nathan Hartley
    1) Changed left to full outer join for Create SACQ Spec Attributes Macro array

Version: 6.0 Date: 20160127 Author: Nathan Hartley
	1) Updated varKeepOrder to ABC sorted
	2) Added MAPPED column to _metadata
	3) Created ROOT+F or ROOT+N with values from ROOT variables if non-exist
	4) Added value validation check CK_V13

Version: 7.0 Date: 20160330 Author: Berlie Manuel
	1) Added submacro checkRTExists to check if the RT site dataset(_rt_site) exists
	2) Added edit checks CK_V14 to CK_V27	
-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_process_ds(
	inlibSACQMetadata =null,
	inlibSCRF         =null,
	outlibSACQ        =null,
	inDataSACQSpec    =null,
	inDataUIMSSpec    =null,
	inDataCodelists   =null,
	inDataDS          =null,
	inVersion         =null,
	inProtocol        =null);

   %********************************************************************************
    * Start Up
    ********************************************************************************;

	    %* Declare local macros;
	    	%local macroName macroVersion macroDate macroRunDT macroLocation;
		    %let macroName = PFESACQ_MAP_SCRF_PROCESS_DS;
		    %let macroVersion = 6.0;
		    %let macroDate = 20160127;
		    %let macroRunDT = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));
		    %let macroLocation = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
		    %*let macroLocation = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
		    %local i j k;

		%* Output start of macro log note;
		    %put ;
		    %put INFO:[PXL]%sysfunc(repeat(%str(-),79));
		    %put INFO:[PXL] Submacro Name: &macroName;
		    %put INFO:[PXL] Submacro Version Number: &macroVersion;
		    %put INFO:[PXL] Submacro Version Date: &macroDate;
		    %put INFO:[PXL] Submacro Run DateTime: &macroRunDT;
		    %put INFO:[PXL] Submacro Location: &macroLocation;

		    %put INFO:[PXL]%sysfunc(repeat(%str(-),79));
		    %put INFO:[PXL] Input Parameters:;
		    %put INFO:[PXL]   1) inlibSACQMetadata = &inlibSACQMetadata;
			%put INFO:[PXL]   2) inlibSCRF         = &inlibSCRF;
			%put INFO:[PXL]   3) outlibSACQ        = &outlibSACQ;
			%put INFO:[PXL]   4) inDataSACQSpec    = &inDataSACQSpec;
			%put INFO:[PXL]   4) inDataUIMSSpec    = &inDataUIMSSpec;
			%put INFO:[PXL]   5) inDataCodelists   = &inDataCodelists;
			%put INFO:[PXL]   6) inDataDS          = &inDataDS;
		    %put INFO:[PXL]   7) inVersion         = &inVersion;
			%put INFO:[PXL]   8) inProtocol        = &inProtocol;

			%put INFO:[PXL]%sysfunc(repeat(%str(-),79));
			%put INFO:[PXL] Output:;
			%put INFO:[PXL]   1) &outlibSACQ..&indataDS._SACQ;
            %put INFO:[PXL]   2) WORK.LISTING_TAB5;

			%put INFO:[PXL]%sysfunc(repeat(%str(-),79));
		    %put ;

            
            
            
				%global RTSiteDS RT_DS_Exist RT_Dir_Exist;
                
                %let RTSiteDS =_rt_site;				
				%let RT_DS_Exist=;
				%let RT_Dir_Exist=;

				%* check if the study metadata folder exists;
                    %if not ((%sysfunc(libref(meta)))=0) %then %do;	
                        %let RT_Dir_Exist=NO;
                        %put INFO:[PXL] metadata folder does not exist in the study. Right Track dataset cannot be accessed; 	
                    %end;		
                    %* check if Right Track site dataset exists in the folder;
                    %else %if %sysfunc(exist(meta.&RTSiteDS))<=0 %then %do;																	
                        %let RT_DS_Exist=NO;
                        %put INFO:[PXL] Right Track dataset does not exist in the metadata folder; 
                    %end;
				


            
   %********************************************************************************
    * Internal Utility Macros
    ********************************************************************************;
	    %* 
	     * 1) LogMessageOutput
	     *;

		%* MACRO: LogMessageOutput
		 * PURPOSE: Standardize Macro Log Message Output
		 * INPUT: 1) subMacroName - Name of macro and defaulted to macro variable macroName
		 *        2) noteType - i=INFO, n=NOTE, e=ERR OR, w=WARN ING
		 *        3) noteMessage - Message text with @ for line breaks
	     * OUTPUT: 1) Log Message
	     *;
		    %macro LogMessageOutput(noteType, noteMessage, subMacroName=&macroName);
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
		                %put &_type.:[PXL] SUBMACRO &subMacroName: %scan(&noteMessage,&i,"@");
		            %end;
		        %end;
		        %else %do;
		            %put &_type.:[PXL] SUBMACRO &subMacroName: &noteMessage;
		        %end;
		        
		        %if %str("&notetype") ne %str("n") %then %do; 
			        * FOOTER LINE;
			        %put &_type.:[PXL]%sysfunc(repeat(%str(-),79));
			        %put;			        
			    %end;

		    %mend LogMessageOutput;

   %********************************************************************************
    * Setup Mapping Metadata
    ********************************************************************************;
    	%LogMessageOutput(i, Setup Mapping Metadata for &inlibSCRF..%upcase(&inDataDS));
    	%* Creates temporary datasets: 
    	 * 1) _SACQSPEC - SACQ Spec Data for SAS attributes including codelist info
    	 * 2) _SCRFDATA - SCRF dataset &inlibSCRF..&inDataDS SAS attributes
         *;

		%* Create SCRF Attributes Macro array;
			%LogMessageOutput(n, Create SCRF Attributes Macro array);
			proc sql noprint;
				create table _SCRFDATA as
				select *
				from sashelp.vcolumn 
				where libname = "%upcase(&inlibSCRF)"
				      and memname = "%upcase(&inDataDS)";

				select count(*) into: totalSCRFVars
				from _SCRFDATA;

				select NAME, TYPE 
	                   into :var1-:var%trim(%left(&totalSCRFVars)),
	                        :type1-:type%trim(%left(&totalSCRFVars))
	            from _SCRFDATA; 
	        quit;

	        %* If 0 obs then do not map to SACQ;
	        proc sql noprint;
	        	select count(*) into: nobs 
	        	from &inlibSCRF..&inDataDS;
	        quit;
	        %if &nobs = 0 %then %do;
	        	%LogMessageOutput(n, &inlibSCRF..&inDataDS Contains 0 obs and will not be mapped to SACQ Dataset per PDS Business Rules);
				%goto macend;
	        %end;

		%* Create SACQ Spec Attributes Macro array;
			%LogMessageOutput(n, Create SACQ Spec Attributes Macro array from &inlibSACQMetadata..&inDataSACQSpec);
	        proc sql noprint;
	        	%* Get SACQ spec attribtues, over riding with UIMS Submitted metadata;
	        	create table _SACQSPEC as 
	        	select 
	        		coalescec(b.DATASET, a.DATASET) as DATASET,
	        		coalescec(b.VARIABLE, a.VARIABLE) as VARIABLE,
	        		coalescec(b.RQ, a.RQ) as RQ,
	        		coalescec(b.DATA_TYPE, a.DATA_TYPE) as DATA_TYPE,
	        		coalesce(b.DATA_LENGTH, a.DATA_LENGTH) as DATA_LENGTH,
	        		coalescec(b.DATA_FORMAT, a.DATA_FORMAT) as DATA_FORMAT,
	        		coalescec(b.DATA_LABEL, a.DATA_LABEL) as DATA_LABEL,
	        		coalescec(b.CODELIST_STANDARD, a.CODELIST_STANDARD) as CODELIST_STANDARD,
	        		coalescec(b.CODELIST, a.CODELIST) as CODELIST,
	        		coalescec(b.CODELIST_FORMAT, a.CODELIST_FORMAT) as CODELIST_FORMAT,
	        		coalescec(b.CODELIST_ROOT, a.CODELIST_ROOT) as CODELIST_ROOT
	        	from (select * from &inlibSACQMetadata..&inDataSACQSpec where DATASET="%left(%trim(&inDataDS))_SACQ") as a 
	        	     full outer join
	        	     (select * from &inlibSACQMetadata..&inDataUIMSSpec where DATASET="%left(%trim(&inDataDS))_SACQ") as b 
	        	on a.DATASET = b.DATASET and a.VARIABLE = b.VARIABLE
	        	order by a.DATASET, a.VARIABLE;

	            %* Macro array for SACQ Metadata;
	            select count(*) into: totalSACQVars
				from _SACQSPEC;

				select VARIABLE,
				       RQ,
				       DATA_LENGTH,
				       DATA_FORMAT,
				       DATA_LABEL,
				       CODELIST,
				       CODELIST_STANDARD,
				       CODELIST_FORMAT,
				       CODELIST_ROOT,
				       0 as varSACQMatch

	                   into :varSACQ1-:varSACQ%trim(%left(&totalSACQVars)),
	                        :varSACQRQ1-:varSACQRQ%trim(%left(&totalSACQVars)),
	                        :varSACQDataLength1-:varSACQDataLength%trim(%left(&totalSACQVars)),
	                        :varSACQDataFormat1-:varSACQDataFormat%trim(%left(&totalSACQVars)),
	                        :varSACQLabel1-:varSACQLabel%trim(%left(&totalSACQVars)),
	                        :varSACQC1-:varSACQC%trim(%left(&totalSACQVars)),
	                        :varSACQCS1-:varSACQCS%trim(%left(&totalSACQVars)),
	                        :varSACQCF1-:varSACQCF%trim(%left(&totalSACQVars)),
	                        :varSACQCR1-:varSACQCR%trim(%left(&totalSACQVars)),
	                        :varSACQMatch1-:varSACQMatch%trim(%left(&totalSACQVars))
	            from _SACQSPEC;
			quit;

   %********************************************************************************
    * Map Variables
    ********************************************************************************;
    	%LogMessageOutput(i, Map Variables);

		%* Map Values to SACQ format
		 * Process: First builds macro code per mapping possibilty and then maps within 
		 *          a dataset
		 * Creates temporary datasets: 
		 *   1) _&inDataDS - raw dataset with formats removed
		 *   2) _TEMP1 - raw dataset mapped to SACQ format
		 * Mapping Possibilties:
		 *   1) Numeric Codelist Attached
		 *   2) Numeric Date YYYY-MM-DD
		 *   3) Numeric Date YYYYMMDD
		 *   4) Numeric DateTime YYYY-MM-DD hh:mm:ss
		 *   5) Numeric Time HH:MM:SS
		 *   6) Numeric Time HHMMSS
		 *   7) Numeric Number
		 *   8) Character Codelist Attached
		 *   9) Character Date YYYY-MM-DD or YYYYMMDD
		 *  10) Character Time HH:MM:SS or HHMMSS
		 *  11) Character Text
         *;

		data _&inDataDS; set &inlibSCRF..&inDataDS; format _all_; run;

		data _TEMP1;
			attrib
				%do i=1 %to &totalSACQVars;
					&&varSACQ&i length=$&&varSACQDataLength&i label="&&varSACQLabel&i"
				%end;
			;

			set _&inDataDS(rename=( %do i=1 %to &totalSCRFVars; &&var&i=_&&var&i %end; ));
			format _all_;

			%do i=1 %to &totalSACQVars; &&varSACQ&i=''; %end; %* Set Defaults;

			%* Cycle through mapped SCRF to SACQ variables and handle each case;
			%do i=1 %to &totalSCRFVars;
				%let matchFlag = 0;
				%do j=1 %to &totalSACQVars;
					%if %upcase(&&var&i) = %upcase(&&varSACQ&j) %then %do;
						%let varSACQMatch&j = 1;

						%* 1) Numeric Codelist Attached;
	                        %if &&type&i = %str(num) and "&&varSACQC&j" ne "%str()" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 1 Numeric Codelist Attached);
	                         	if missing(_&&var&i) then &&varSACQ&j = ""; else &&varSACQ&j = left(trim(put(_&&var&i, 8.)));
	                        %end;

						%* 2) Numeric Date YYYY-MM-DD;
	                        %else %if &&type&i = %str(num) and "%str(&&varSACQDataFormat&j)" = "%str(YYYY-MM-DD)" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 2 Numeric Date YYYY-MM-DD);
	                         	if missing(_&&var&i) then &&varSACQ&j = ""; else &&varSACQ&j = left(trim(put(_&&var&i, YYMMDD10.)));
	                        %end;

						%* 3) Numeric Date YYYYMMDD;
	                        %else %if &&type&i = %str(num) and "%str(&&varSACQDataFormat&j)" = "%str(YYYYMMDD)" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 3 Numeric Date YYYYMMDD);
	                         	if missing(_&&var&i) then &&varSACQ&j = ""; else &&varSACQ&j = left(trim(compress(put(_&&var&i, YYMMDD10.),'-')));
	                        %end;

						%* 4) Numeric DateTime YYYY-MM-DD hh:mm:ss - Map to YYYY-MM-DD hh:mm:ss;
	                        %else %if &&type&i = %str(num) and "%str(&&varSACQDataFormat&j)" = "%str(YYYY-MM-DD hh:mm:ss)" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 4 Numeric DateTime YYYY-MM-DD hh:mm:ss);
	                         	if missing(_&&var&i) then &&varSACQ&j = ""; else &&varSACQ&j = catx(' ', put(datepart(_&&var&i),yymmdd10.), put(timepart(_&&var&i),tod8.));
	                        %end;

						%* 5) Numeric Time HH:MM:SS;
	                        %else %if &&type&i = %str(num) and "%str(&&varSACQDataFormat&j)" = "%str(HH:MM:SS)" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 5 Numeric Time HH:MM:SS);
	                         	if missing(_&&var&i) then &&varSACQ&j = ""; else &&varSACQ&j = left(trim(put(_&&var&i, TIME8.)));
	                        %end;

						%* 6) Numeric Time HHMMSS;
	                        %else %if &&type&i = %str(num) and "%str(&&varSACQDataFormat&j)" = "%str(HHMMSS)" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 6 Numeric Time HHMMSS);
	                         	if missing(_&&var&i) then &&varSACQ&j = ""; else &&varSACQ&j = left(trim(compress(put(_&&var&i, TIME8.), ':')));
	                        %end;

						%* 7) Numeric Number;
	                        %else %if &&type&i = %str(num) and "&&varSACQC&j" = "%str()" and "%str(&&varSACQDataFormat&j)" = "%str()" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 7 Numeric Number);
	                         	if missing(_&&var&i) then &&varSACQ&j = ""; else &&varSACQ&j = left(trim(put(_&&var&i, BEST.)));
	                        %end;

						%* 8) Character Codelist Attached;
	                        %else %if &&type&i = %str(char) and &&varSACQC&j ne %str() %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 8 Character Codelist Attached);
	                         	&&varSACQ&j = left(trim(compress(_&&var&i,,'WK')));
	                        %end;

						%* 9) Character Date YYYY-MM-DD or YYYYMMDD;
	                        %else %if &&type&i = %str(char) and ("%str(&&varSACQDataFormat&j)" = "%str(YYYY-MM-DD)" or "%str(&&varSACQDataFormat&j)" = "%str(YYYYMMDD)") %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 9 Character Date YYYY-MM-DD or YYYYMMDD);
	                         	%* Broken into parts due to amperstands, percent, and commas being used;
	                         	_&&var&i = left(trim(compress(_&&var&i,,'WK')));
	    						%pfesacq_map_scrf_char_dates(inVar=_&&var&i, outVar=&&varSACQ&j);
	                        %end;

						%* 10) Character Time HH:MM:SS or HHMMSS;
	                        %else %if &&type&i = %str(char) and ("%str(&&varSACQDataFormat&j)" = "%str(HH:MM:SS)" or "%str(&&varSACQDataFormat&j)" = "%str(HHMMSS)") %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 10 Character Time HH:MM:SS or HHMMSS);
	                         	_&&var&i = left(trim(compress(_&&var&i,,'WK')));
	    						%pfesacq_map_scrf_char_times(inVar=_&&var&i, outVar=&&varSACQ&j);
	                        %end;

						%* 11) Character Text;
	                        %else %if &&type&i = %str(char) and "&&varSACQC&j" = "%str()" and "%str(&&varSACQDataFormat&j)" = "%str()" %then %do;
	                         	%LogMessageOutput(n, &&var&i - MAPPED - 11 Character Text);
	                         	&&varSACQ&j = left(trim(compress(_&&var&i,,'WK')));
	                        %end;

	                    %* Capture any issues where a variable should have been mapped;
	                    	%else %do;
	                    		%LogMessageOutput(e, &&var&i - NOT MAPPED);
	                    	%end;                         
					%end;
				%end;
			%end;
		run;

   %********************************************************************************
    * Add non-safety codelist root+F and root+N varaibles if they do not already exist
    ********************************************************************************;
    	%LogMessageOutput(i, Add Efficacy Codelist ROOT+F or ROOT+N if Not Present);

		data _TEMP1;
		set _TEMP1;
	    	%* Cycle through SACQ var list;
	    	%do j=1 %to &totalSACQVars;
	    		%* Find SACQ Variables with match to raw and codelist_format=SHORT;
	    		%if &&varSACQMatch&j = 1 and "%str(&&varSACQCF&j)" = "SHORT" %then %do;
	    			%* Cycle through SACQ var list again;
	    			%do k=1 %to &totalSACQVars;
	    				%* Check if ROOT+N or ROOT+F does not exist;
	    				%if %eval(&&varSACQMatch&k = 0) and ( ("&&varSACQ&j..F" = "&&varSACQ&k") or ("&&varSACQ&j..N" = "&&varSACQ&k") ) %then %do;
	    					%LogMessageOutput(n, Add Efficacy Codelist ROOT+F or ROOT+N Variable: &&varSACQ&k);
	    					%let varSACQMatch&k = 1; %* Add to output;
	    					&&varSACQ&k = &&varSACQ&j; *% Set it to ROOT variable value. Will be mapped to codelist format later;
	    				%end; %* End if looop;
	    			%end; %* End do K loop;
	    		%end; %* End if loop;
	    	%end; %* End do J loop;
	    run;

   %********************************************************************************
    * Map Codelist Values
    ********************************************************************************;
    	%LogMessageOutput(i, Map Codelist Values);

		%* Map Codelist;
		%macro Map_Codelist(datasetName=null, variableName=null, standard=null, codelistName=null, codelistFormat=null);
			%LogMessageOutput(n, Mapping Codelist - datasetName=&datasetName variableName=&variableName standard=&standard codelistName=&codelistName codelistFormat=&codelistFormat );

			%* Append codelist SEQ, SHORT, and LONG values;
			proc sql noprint;
				create table _TEMP2 as
				select a.*, 
				       left(trim(b.SHORT_LABEL)) as &variableName._SHORTLABEL,
				       left(trim(b.LONG_LABEL)) as &variableName._LONGLABEL,
				       left(trim(put(b.SEQ_NUMBER, 8.))) as &variableName._SEQNUMBER
				from _TEMP1 as a 
				     left join
				     &inlibSACQMetadata..&inDataCodelists as b 
				on b.standard = "&standard"
				   and b.codelist_name = "&codelistName"
				   and 
				   (
				   		upcase(left(trim(a.&variableName))) = left(trim(b.SHORT_LABEL))
				   		or
				   		upcase(left(trim(a.&variableName))) = left(trim(b.LONG_LABEL))
		                or
				   		upcase(left(trim(a.&variableName))) = strip(put(b.SEQ_NUMBER,best.))
				   );
			quit;			

			data _TEMP1; 
			set _TEMP2; 
				if not missing(&variableName) and missing(&variableName._LONGLABEL) then do;
					&variableName = ""; * Drop non-codelist conformant values, will be identified in SACQ validation later;
				end;
				else do;
					%if &codelistFormat = SEQ %then %do;
						&variableName = &variableName._SEQNUMBER;
						if &variableName = "." then &variableName = "";
					%end;
					%else %if &codelistFormat = SHORT %then %do;
						&variableName = &variableName._SHORTLABEL;
					%end;
					%else %if &codelistFormat = LONG %then %do;
						&variableName = &variableName._LONGLABEL;
					%end;
				end;
			run;
		%mend Map_Codelist;	

		%* Verify equal records (no duplicated codelist values on seq, short, or long);
		proc sql noprint;
			select count(*) into: totalRecordsBefore
			from _&inDataDS;
		quit;

		%* Cycle through each variable that maps per a codelist;
		%do i=1 %to &totalSACQVars;
			%if &&varSACQMatch&i = 1 and &&varSACQC&i ne %str() %then %do;
				%Map_Codelist(datasetName=&inDataDS, variableName=&&varSACQ&i, standard=&&varSACQCS&i, codelistName=&&varSACQC&i, codelistFormat=&&varSACQCF&i);
			%end;
		%end;

		%* Verify no duplicated records added per duplicated codelist values;
		proc sql noprint;
			select count(*) into: totalRecordsAfter
			from _TEMP1;
		quit;		
		%if %eval(&totalRecordsBefore ne &totalRecordsAfter) %then %do;
			%LogMessageOutput(e, Duplicated CODELIST values have added records to &inDataDS - %left(%trim(&totalRecordsBefore)) to %left(%trim(&totalRecordsAfter)));
		%end;

   %********************************************************************************
    * Update Sort and Output
    ********************************************************************************;
    	%LogMessageOutput(i, Update Sort and Output);
		%* Derive SACQ keep and variable order as ABC order;
	    	%let varKeepOrder = ;

			data varKeepOrder;
			    length VAR1 $200;
			    %do i=1 %to &totalSACQVars;
			        %if &&varSACQMatch&i = 1 %then %do;
			            VAR1 = "&&varSACQ&i"; output;
			        %end;
			    %end;
			run;

			proc sql noprint;
			    select VAR1 into: varKeepOrder separated by  ' '
			    from varKeepOrder
			    order by 1;
			quit;
	    	%LogMessageOutput(n, SACQ Keep and Order Variable List varKeepOrder= &varKeepOrder);

    	%* Derive dataset label;
	    	%let dsLabel = ;
			data _null_;
				length DS_LABEL $200.;
				DS_LABEL = symget('inVersion');
				DS_LABEL = tranwrd(DS_LABEL, '_', '.');
				DS_LABEL = compress(DS_LABEL, 'vV');
				call symput('dsLabel', DS_LABEL);
			run;    	
			%LogMessageOutput(n, SACQ Dataset Label dsLabel= &dsLabel);

		%* Drop 0 Observation datasets per CAL requirement;
			proc sql noprint;
				select count(*) into: nobs
				from _TEMP1;
			quit;	
			%if &nobs = 0 %then %do;
				%LogMessageOutput(n, Raw SCRF Dataset &inlibSCRF..&inDataDS contains 0 obs and will not be mapped to SACQ Dataset);
			%end;

		%* Output;
			%else %do;
				proc sort data=_TEMP1 out=_TEMP2; by PID ACTEVENT REPEATSN; run;

				data &outlibSACQ..&inDataDS._SACQ(keep=&varKeepOrder encoding=wlatin1 label="&dsLabel")
				     work.&inDataDS._SACQ(keep=&varKeepOrder encoding=wlatin1 label="&dsLabel");
				    retain &varKeepOrder;
					set _TEMP2;
				run;
			%end;

   %********************************************************************************
    * Add MAPPED Column for Metadata Tab Listing Output
    ********************************************************************************;
    	%LogMessageOutput(i, Add MAPPED Column for Metadata Tab Listing Output);

    	data _metadata;
    		attrib M_MAPPED length=$3 label="Mapped";
    		set _metadata;

		    %do i=1 %to &totalSACQVars;
		        %if &&varSACQMatch&i = 1 %then %do;
		            if sacq_dataset = "&indataDS._SACQ" and sacq_variable = "&&varSACQ&i" then 
		            	M_MAPPED = "YES";
		        %end;
		    %end;
    	run;

   %********************************************************************************
    * Validation Checks for Value Exceptions
    ********************************************************************************;
		%macro pfesacq_map_scrf_validate_value();
			%LogMessageOutput(i, Start of SubMacro pfesacq_map_scrf_validate_value);

		   %********************************************************************************
		    * CK_V_SETUP
		    ********************************************************************************;
		     	%macro CK_V_SETUP;
				    %let Listing_TAB5 = 
				        ISSUE               length=   8 label="Issue #"
				        ISSUE_ID            length=$200 label="Issue ID"
				        PRIORITY            length=$200 label="Issue Priority"
				        DESC                length=$200 label="Issue Description"
				        DESC_INFO           length=$200 label="Detailed Info"
				        KEY                 length=$200 label="KEY (SITEID-SUBJID-ACTEVENT-REPEATSN)"
				        SCRF_DATASET        length=$200 label="SCRF Dataset"
				        SCRF_VARIABLE       length=$200 label="SCRF Variable"
				        SCRF_VARIABLE_VALUE length=$200 label="SCRF Variable Value"
				        SACQ_VARIABLE_VALUE length=$200 label="SACQ Variable Value";

				    data _Listing_TAB5 
				        %if not %sysfunc(exist(Listing_TAB5)) %then %do; Listing_TAB5 %end; ;

				    	attrib &Listing_TAB5;

				    	ISSUE = .;
				    	ISSUE_ID = '';
				    	PRIORITY = '';
				    	DESC = '';
				    	DESC_INFO = '';
				    	KEY = '';
				    	SCRF_DATASET = '';
				    	SCRF_VARIABLE = '';
				    	SCRF_VARIABLE_VALUE = '';
				    	SACQ_VARIABLE_VALUE = '';
				    	delete; 
				    run;
			    %mend CK_V_SETUP;

		   %********************************************************************************
		    * CK_V1
		    ********************************************************************************;
		    	%macro CK_V1;
			     	%LogMessageOutput(n, CK_V1 - SCRF Variable actual data length is longer than SACQ standard);

			     	data CK_V1(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     		set _Listing_TAB5 _TEMP2;

			     		%do i=1 %to &totalSCRFVars;
			     			%do j=1 %to &totalSACQVars;
			     				%if %upcase(&&var&i) = %upcase(&&varSACQ&j) 
			     				    and "&&type&i" = "char" 
			     				    and "&&varSACQC&j" = "" %then %do;

			     				    if length(_&&var&i) > &&varSACQDataLength&j then do;
					                    issue = .;
					                    issue_id = "CK_V01";
					                    priority = "WARNING";
					                    desc = "SCRF Variable actual data length is longer than SACQ standard";
					                    desc_info = catx(" ",
					                                     "SCRF &inDataDS..&&var&i value as a length of",
					                                     left(trim(put(length(_&&var&i),8.))),
					                                     "but length is",
					                                     %left(%trim(&&varSACQDataLength&j)),
					                                     "for SACQ. Truncation of data occurred.");
					                    key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
					                    scrf_dataset = "&inDataDS";
					                    scrf_variable = "&&var&i";
					                    scrf_variable_value = _&&var&i;
					                    sacq_variable_value = &&var&i;
					                    output CK_V1;      				    	
			     				    end;
			     				%end;
			     			%end;
			     		%end;
			     		delete;
			     	run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V1; run;
		     	%mend CK_V1;

		   %********************************************************************************
		    * CK_V2
		    ********************************************************************************;
		    	%macro CK_V2;
			     	%LogMessageOutput(n, CK_V2 - Value not in Pfizer Codelist);

			     	data CK_V2(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     		set _Listing_TAB5 _TEMP2;

			     		%do i=1 %to &totalSCRFVars;
			     			%do j=1 %to &totalSACQVars;
			     				%if %upcase(&&var&i) = %upcase(&&varSACQ&j) 
			     				    and "&&varSACQC&j" ne "" %then %do;

			     				    if not missing(_&&var&i) and missing(&&var&i.._LONGLABEL) then do;
					                    issue = .;
					                    issue_id = "CK_V02";
					                    priority = "WARNING";
					                    desc = "Value not in Pfizer Codelist";
					                    desc_info = catx(" ", "SCRF &inDataDS..&&var&i value is required to be present within Pfizer"
					                    	                , "&&varSACQCS&j Codelist &&varSACQC&j but was not found. Value dropped.");
					                    key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
					                    scrf_dataset = "&inDataDS";
					                    scrf_variable = "&&var&i";
				                        %if "&&type&i" = "num" %then %do;
				                        	scrf_variable_value = left(trim(put(_&&var&i, best.)));
				                        %end;
				                        %else %do;
				                            scrf_variable_value = _&&var&i;
				                        %end;
					                    sacq_variable_value = &&var&i;
					                    output CK_V2;
			     				    end;
			     				%end;
			     			%end;
			     		%end;
			     		delete;
			     	run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V2; run;
		     	%mend CK_V2;

		   %********************************************************************************
		    * CK_V3
		    ********************************************************************************;
		    	%macro CK_V3;
			     	%LogMessageOutput(n, CK_V3 - SCRF Char date did not map to SACQ Char Date);

			     	data CK_V3(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     		set _Listing_TAB5 _TEMP2;

			     		%do i=1 %to &totalSCRFVars;
			     			%do j=1 %to &totalSACQVars;
			     				%if %upcase(&&var&i) = %upcase(&&varSACQ&j) 
			     				    and "&&type&i" = "char"
			     				    and ( 
			     				   			"&&varSACQDataFormat&j" = "YYYY-MM-DD" 
			     				   			or "&&varSACQDataFormat&j" = "YYYYMMDD"
			     				   		) %then %do;

			     				    if not missing(_&&var&i) and missing(&&var&i) then do;
					                    issue = .;
					                    issue_id = "CK_V03";
					                    priority = "WARNING";
					                    desc = "SCRF Char date did not map to SACQ Char Date";
					                    desc_info = catx(" ", "SCRF &inDataDS..&&var&i value did not map to SCRF date format."
					                    	                , "Value dropped.");
					                    key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
					                    scrf_dataset = "&inDataDS";
					                    scrf_variable = "&&var&i";
				                        %if "&&type&i" = "num" %then %do;
				                        	scrf_variable_value = left(trim(put(_&&var&i, best.)));
				                        %end;
				                        %else %do;
				                            scrf_variable_value = _&&var&i;
				                        %end;
					                    sacq_variable_value = &&var&i;
					                    output CK_V3;      				    	
			     				    end;
			     				%end;
			     			%end;
			     		%end;
			     		delete;
			     	run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V3; run;
		     	%mend CK_V3;

		   %********************************************************************************
		    * CK_V4
		    ********************************************************************************;
		    	%macro CK_V4;
			     	%LogMessageOutput(n, CK_V4 - SCRF Char time did not map to SACQ Char time);

			     	data CK_V4(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     		set _Listing_TAB5 _TEMP2;

			     		%do i=1 %to &totalSCRFVars;
			     			%do j=1 %to &totalSACQVars;
			     				%if %upcase(&&var&i) = %upcase(&&varSACQ&j) 
			     				    and "&&type&i" = "char"
			     				    and ( 
			     				   			"&&varSACQDataFormat&j" = "HH:MM:SS" 
			     				   			or "&&varSACQDataFormat&j" = "HHMMSS"
			     				   		) %then %do;

			     				    if not missing(_&&var&i) and missing(&&var&i) then do;
					                    issue = .;
					                    issue_id = "CK_V04";
					                    priority = "WARNING";
					                    desc = "SCRF Char time did not map to SACQ Char time";
					                    desc_info = catx(" ", "SCRF &inDataDS..&&var&i value did not map to SCRF date format."
					                    	                , "Value dropped.");
					                    key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
					                    scrf_dataset = "&inDataDS";
					                    scrf_variable = "&&var&i";
				                        %if "&&type&i" = "num" %then %do;
				                        	scrf_variable_value = left(trim(put(_&&var&i, best.)));
				                        %end;
				                        %else %do;
				                            scrf_variable_value = _&&var&i;
				                        %end;
					                    sacq_variable_value = &&var&i;
					                    output CK_V4;      				    	
			     				    end;
			     				%end;
			     			%end;
			     		%end;
			     		delete;
			     	run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V4; run;
		     	%mend CK_V4;

		   %********************************************************************************
		    * CK_V5
		    ********************************************************************************;
		    	%macro CK_V5;
			     	%LogMessageOutput(n, CK_V5 - SACQ Header Variable value is NULL);

			     	data CK_V5(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     		set _Listing_TAB5 _TEMP2;

			     		%do i=1 %to &totalSCRFVars;
			     			%do j=1 %to &totalSACQVars;
			     				%if %upcase(&&var&i) = %upcase(&&varSACQ&j) 
			     					and (
			     							"&&var&i" = "ACCESSTS"
						                  	or "&&var&i" = "ACTEVENT"
						                  	or "&&var&i" = "COLLDATE"
							                or "&&var&i" = "CPEVENT"
							                or "&&var&i" = "INV"
							                or "&&var&i" = "LSTCHGTS"
							                or "&&var&i" = "PID"
							                or "&&var&i" = "PROJCODE"
							                or "&&var&i" = "PROTNO"
							                or "&&var&i" = "REPEATSN"
							                or "&&var&i" = "SID"
							                or "&&var&i" = "SITEID"
							                or "&&var&i" = "STUDY"
							                or "&&var&i" = "STUDYID"
							                or "&&var&i" = "SUBEVE"
							                or "&&var&i" = "SUBJID"
							                or "&&var&i" = "TRIALNO"
						                    or "&&var&i" = "VISIT" 
			                  			) %then %do;

			     				    if missing(&&var&i) then do;
					                    issue = .;
					                    issue_id = "CK_V05";
					                    priority = "WARNING";
					                    desc = "SACQ Header Variable value is NULL";
					                    desc_info = catx(" ", "SCRF &inDataDS..&&var&i value is null."
					                    	                , "Pfizer standards requires all header/key variable values to present.");
					                    key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
					                    scrf_dataset = "&inDataDS";
					                    scrf_variable = "&&var&i";
				                        scrf_variable_value = "";
					                    sacq_variable_value = "";
					                    output CK_V5;      				    	
			     				    end;
			     				%end;
			     			%end;
			     		%end;
			     		delete;
			     	run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V5; run;    
		     	%mend CK_V5; 		

		   %********************************************************************************
		    * CK_V6
		    ********************************************************************************;
		    	%macro CK_V6;
			     	%LogMessageOutput(n, CK_V6);

			     	proc sql noprint;
			     		select count(*) into: nobs_scrf
			     		from &inlibSCRF..&inDataDS;

			     		select count(*) into: nobs_sacq
			     		from &outlibSACQ..&inDataDS._SACQ;
			     	quit;

			     	%if %eval(&nobs_scrf ne &nobs_sacq)
			     	    and %eval(&nobs_scrf > 0) %then %do;

			     	    data _dummy; run;

			     	    data CK_V6(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;

							issue = .;
							issue_id = "CK_V06";
							priority = "ERROR";
							desc = "SCRF Dataset to SACQ Dataset Number of Obs Mismatch";
			                desc_info = catx(" ", "SCRF &inDataDS has %left(%trim(&nobs_scrf)) observations but SACQ &inDataDS._SACQ"
			                	                , "has %left(%trim(&nobs_sacq)) observations. These values must match.");				
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "N/A";
							scrf_variable_value = "";
							sacq_variable_value = "";
							output;
			     	    run;
			     	%end;
			     	%else %do;
			     		data CK_V6; delete; run;
			     	%end;

			     	data Listing_TAB5; set Listing_TAB5 CK_V6; run;
		     	%mend CK_V6;

		   %********************************************************************************
		    * CK_V7
		    ********************************************************************************;
		    	%macro CK_V7;
			     	%LogMessageOutput(n, CK_V7 - SCRF Dataset to SACQ Dataset Number of Unique Subjects Mismatch);

			     	proc sql noprint;
			     		select count(*) into: nobs_scrf
			     		from (select distinct PID from &inlibSCRF..&inDataDS);

			     		select count(*) into: nobs_sacq
			     		from (select distinct PID from &outlibSACQ..&inDataDS._SACQ);
			     	quit;

			     	%if %eval(&nobs_scrf ne &nobs_sacq)
			     	    and %eval(&nobs_scrf > 0) %then %do;

			     	    data _dummy; run;

			     	    data CK_V7(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;

							issue = .;
							issue_id = "CK_V07";
							priority = "ERROR";
							desc = "SCRF Dataset to SACQ Dataset Number of Unique Subjects Mismatch";
			                desc_info = catx(" ", "SCRF &inDataDS has %left(%trim(&nobs_scrf)) unique subjects but SACQ &inDataDS._SACQ"
			                	                , "has %left(%trim(&nobs_sacq)) unique subjects. These values must match.");
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "N/A";
							scrf_variable_value = "";
							sacq_variable_value = "";
							output;
			     	    run;
			     	%end;
			     	%else %do;
			     		data CK_V7; delete; run;
			     	%end;

			     	data Listing_TAB5; set Listing_TAB5 CK_V7; run;
		     	%mend CK_V7;

		   %********************************************************************************
		    * CK_V8
		    ********************************************************************************;
		    	%macro CK_V8;
			     	%LogMessageOutput(n, CK_V8 - SACQ header variable PROTNO does not equal global macro variable);

					data CK_V8(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     		set _Listing_TAB5 _TEMP2;		     	    	

						issue = .;
						issue_id = "CK_V08";
						priority = "ERROR";
						desc = "SACQ header variable PROTNO does not equal global macro variable";
		                desc_info = catx(" ", "SCRF &inDataDS header/key variable PROTNO has value not matching project_setup.sas set global"
		                	                , "macro variable PROTOCOL [&inProtocol]. These values must match.");
						key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
						scrf_dataset = "&inDataDS";
						scrf_variable = "PROTNO";
						scrf_variable_value = _PROTNO;
						sacq_variable_value = PROTNO;

						if PROTNO ne "&inProtocol" then do;
							output;
						end;
						else do;
							delete;
						end;
		     	    run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V8; run;
		     	%mend CK_V8;		     			     	

		   %********************************************************************************
		    * CK_V9
		    ********************************************************************************;
		    	%macro CK_V9;
			     	%LogMessageOutput(n, CK_V9 - SACQ Variable is R1 but has missing values);

					data CK_V9(keep=issue--sacq_variable_value);
				        set _LISTING_TAB5 _TEMP2;

				        %do i=1 %to &totalSACQVars;
				        	%if &&varSACQMatch&i = 1 
				        	    and "&&varSACQRQ&i" = "R1" 
				        	    and "&&varSACQ&i" ne "ACCESSTS"
				                and "&&varSACQ&i" ne "ACTEVENT"
				                and "&&varSACQ&i" ne "COLLDATE"
				                and "&&varSACQ&i" ne "COLLDATF"
				                and "&&varSACQ&i" ne "CPEVENT"
				                and "&&varSACQ&i" ne "INV"
				                and "&&varSACQ&i" ne "LSTCHGTS"
				                and "&&varSACQ&i" ne "PID"
				                and "&&varSACQ&i" ne "PROJCODE"
				                and "&&varSACQ&i" ne "PROTNO"
				                and "&&varSACQ&i" ne "REPEATSN"
				                and "&&varSACQ&i" ne "SID"
				                and "&&varSACQ&i" ne "SITEID"
				                and "&&varSACQ&i" ne "STUDY"
		                        and "&&varSACQ&i" ne "STUDYID"
				                and "&&varSACQ&i" ne "SUBEVE"
				                and "&&varSACQ&i" ne "SUBJID"
				                and "&&varSACQ&i" ne "TRIALNO"
				                and "&&varSACQ&i" ne "VISIT" %then %do;

				                if missing(_&&varSACQ&i) then do;
				                    issue = .;
				                    issue_id = "CK_V09";
				                    priority = "WARNING";
				                    desc = "SACQ Variable is R1 but has missing values";
				                    desc_info = "SCRF &inDataDS..&&varSACQ&i is required R1 variable but the value is missing. It is required to always have values.";
				                    key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
				                    scrf_dataset = "&inDataDS";
				                    scrf_variable = "&&varSACQ&i";
				                    scrf_variable_value = "";
				                    sacq_variable_value = &&varSACQ&i;
				                    output;                      
				                end;
				            %end;
				        %end; 
				        delete;
					run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V9; run;
		     	%mend CK_V9;

		   %********************************************************************************
		    * CK_V10
		    ********************************************************************************;
		    	%macro CK_V10;
			     	%LogMessageOutput(n, CK_V10 - SACQ Variable is R2 but no values are populated);

			     	data CK_V10; delete; run;

		     		%do i=1 %to &totalSACQVars;
			        	%if &&varSACQMatch&i = 1 
			        	    and "&&varSACQRQ&i" = "R2" %then %do;

				        	proc sql noprint;
			                    select count(*) into: cnt
			                    from _temp2
			                    where _&&varSACQ&i is not null;
                			quit;

                			%put Checking &&varSACQ&i &CNT;

                			data _dummy; run;

                			%if %eval(&cnt = 0) %then %do;
                				%put Outputing &&varSACQ&i;
                				data _CK_V10(keep=ISSUE--SACQ_VARIABLE_VALUE);
		     						set _Listing_TAB5 _dummy;
		     						issue = .;
			                        issue_id = "CK_V10";
			                        priority = "WARNING";
			                        desc = "SACQ Variable is R2 but no values are populated";
			                        desc_info = "SCRF &inDataDS..&&varSACQ&i is required R2 variable but no values were populated. It is required to have at least one value.";
			                        key = "N/A";
			                        scrf_dataset = "&inDataDS";
			                        scrf_variable = "&&varSACQ&i";
			                        scrf_variable_value = "";
			                        sacq_variable_value = "";
			                        output;
		     					run;

		     					data CK_V10; set CK_V10 _CK_V10; run;
                			%end;
                		%end;
			       	%end;

			     	data Listing_TAB5; set Listing_TAB5 CK_V10; run;
		     	%mend CK_V10;

		   %********************************************************************************
		    * CK_V11
		    ********************************************************************************;
		    	%macro CK_V11;
			     	%LogMessageOutput(n, CK_V11 - SCRF or RAW dataset contains 0 observations);

			     	proc sql noprint;
			     		select count(*) into: nobs_scrf
			     		from (select distinct PID from &inlibSCRF..&inDataDS);

			     		select count(*) into: nobs_sacq
			     		from (select distinct PID from &outlibSACQ..&inDataDS._SACQ);
			     	quit;

			     	%if %eval(&nobs_sacq = 0 ) %then %do;

			     		data _dummy; run;

			     	    data CK_V11(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;

							issue = .;
							issue_id = "CK_V11";
							priority = "ERROR";
							desc = "SCRF or RAW dataset and SACQ dataset contains 0 observations";
			                desc_info = catx(" ", "Any dataset that does not have any observations will not be included in the transfer."
			                	                , "This will cause failure at Pfizer CAL read.");
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "N/A";
							scrf_variable_value = "";
							sacq_variable_value = "";
							output;
			     	    run;
			     	%end;
			     	%else %do;
			     		data CK_V11; delete; run;
			     	%end;

			     	data Listing_TAB5; set Listing_TAB5 CK_V11; run;
		     	%mend CK_V11;

		   %********************************************************************************
		    * CK_V12
		    ********************************************************************************;
		    	%macro CK_V12;
			     	%LogMessageOutput(n, CK_V12 - Codelist Value Compared to Root Not Consistant);

					data CK_V12(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     		set _Listing_TAB5 _TEMP2;

			     		%do i=1 %to &totalSCRFVars;
				     		%do j=1 %to &totalSACQVars;
					        	%if %upcase(&&var&i) = %upcase(&&varSACQ&j)
					        	    and "&&varSACQCR&j" ne ""
					        	    and &&varSACQ&j ne &&varSACQCR&j %then %do;					        	    

						     		* Non-Root Codelist Variables must be consistant with ROOT value;
					     			if &&varSACQ&j ne &&varSACQCR&j.._SHORTLABEL 
					     			   and &&varSACQ&j ne &&varSACQCR&j.._LONGLABEL
					     			   and &&varSACQ&j ne &&varSACQCR&j.._SEQNUMBER then do;

										issue = .;
										issue_id = "CK_V12";
										priority = "WARNING";
										desc = "Codelist Value Compared to Root Not Consistant";
						                desc_info = catx(" ", "Codelist Value Compared to Root Not Consistant per Codelist Standard and SEQ/SHORT/LONG Value."
						                	                , "These values must match.");
										key = catx("-",SITEID,SUBJID,ACTEVENT,REPEATSN);
										scrf_dataset = "&inDataDS";
										scrf_variable = "&&varSACQ&j";
										%if "&&type&i" = "num" %then %do;
											scrf_variable_value = left(trim(put(_&&varSACQ&j, best.)));
										%end;
										%else %do;
											scrf_variable_value = _&&varSACQ&j;
										%end;
										output;
									end;
					     	    %end;
					     	%end;
				     	%end;
				     	delete;
				    run;

			     	data Listing_TAB5; set Listing_TAB5 CK_V12; run;
		     	%mend CK_V12;	

		   %********************************************************************************
		    * CK_V13
		    ********************************************************************************;
		    	%macro CK_V13;
			     	%LogMessageOutput(n, CK_V13 - SACQ Header Variable LSTCHGTS value all NULL);

			     	proc sql noprint;
			     		select count(*) into: nobs_total
			     		from &outlibSACQ..&inDataDS._SACQ;

			     		select count(*) into: nobs_null
			     		from &outlibSACQ..&inDataDS._SACQ
			     		where LSTCHGTS is null;
			     	quit;

			     	%* Check if all records have LSTCHGTS as blank or null;
					%if %eval(&nobs_total = &nobs_null) %then %do;

			     		data _dummy; run;

			     	    data CK_V13(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;

							issue = .;
							issue_id = "CK_V13";
							priority = "ERROR";
							desc = "SACQ Header Variable LSTCHGTS value all NULL";
			                desc_info = catx(" ", "Mapped SACQ Header Variable LSTCHGTS is R1 and is always required"
			                	                , "and will FAIL CAL load if all blank or missing.");
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "LSTCHGTS";
							scrf_variable_value = "";
							sacq_variable_value = "";
							output;
			     	    run;
			     	%end;
			     	%else %do;
			     		data CK_V13; delete; run;
			     	%end;

			     	data Listing_TAB5; set Listing_TAB5 CK_V13; run;
		     	%mend CK_V13;

		   %********************************************************************************
		    * CK_V14
		    ********************************************************************************;
		    	%macro CK_V14;
			     	%LogMessageOutput(n, CK_V14 - INV Value does not match RIGHT TRACK Value per SITEID);
					
				%if not(%str(&RT_DS_Exist)=%str(NO)) and not(%str(&RT_Dir_Exist)=%str(NO)) %then %do;

					proc sql noprint;
							create table invdiff as
							select distinct(a.inv), a.invsite from &inlibSCRF..&inDataDS a, meta.&RTSiteDS r
							where a.invsite = r.center
							and a.inv not in 
							             (
											select distinct (invid) from  meta.&RTSiteDS r
							                where r.center = a.invsite
										 );

						select count(*) into: nobs_invdiff from invdiff;
			     	  quit;

			     	%if %eval(&nobs_invdiff > 0) %then %do;

						data invdiff; set invdiff;	record=_n_;	run;

			     	    data _dummy; run;

						%do i=1 %to &nobs_invdiff;
						data _null_;
							set invdiff(where=(record=&i));
							call symput('inv',inv);
							call symput('invsite',invsite);
						run;
						
							%if &i=1 %then %do;
								data CK_V14; set _Listing_TAB5; run;
							%end;

			     	    data _CK_V14(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;
							
							issue = .;
							issue_id = "CK_V14";
							priority = "WARNING";
							desc = "INV Value does not match RIGHT TRACK Value per SITEID";
			                desc_info = catx(" ", "SCRF &inDataDS INV value is %left(%trim(&inv)) for site %left(%trim(&invsite)). But the SITE %left(%trim(&invsite))"
			                	                , "  has different INV value in Right Track. SCRF INV must match with RIGHT TRACK Value per SITEID.");				
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "INV - INVSITE";
							scrf_variable_value = "&inv. - &invsite.";
							sacq_variable_value = "";
							output;
			     	    run;

						data CK_V14; set CK_V14 _CK_V14; run;
						%end;
			     	%end;
					%else %do;
						data CK_V14; delete; run;
					%end;
					data Listing_TAB5; set Listing_TAB5 CK_V14; run;
				%end;
		     	%mend CK_V14;


		   %********************************************************************************
		    * CK_V15
		    ********************************************************************************;
		    	%macro CK_V15;
			     	%LogMessageOutput(n, CK_V15 - INV value does not exists in Right Track);

				%if not(%str(&RT_DS_Exist)=%str(NO)) and not(%str(&RT_Dir_Exist)=%str(NO)) %then %do;

					proc sql noprint;
							create table noinv as
							select distinct(inv),invsite from &inlibSCRF..&inDataDS
							where inv not in 
							             (
											select distinct(invid) from  &inlibSCRF..&RTSiteDS							                
										 );

						select count(*) into: nobs_noinv from noinv;
			     	  quit;

			     	%if %eval(&nobs_noinv > 0) %then %do;

						data noinv; set noinv;	record=_n_;	run;
			     	    data _dummy; run;

						%do i=1 %to &nobs_noinv;
						data _null_;
							set noinv(where=(record=&i));
							call symput('inv',inv);
							call symput('invsite',invsite);
						run;
						
							%if &i=1 %then %do;
								data CK_V15; set _Listing_TAB5; run;
							%end;

			     	    data _CK_V15(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;
							
							issue = .;
							issue_id = "CK_V15";
							priority = "WARNING";
							desc = "INV value does not exists in Right Track";
			                desc_info = catx(" ", "SCRF &inDataDS INV value is %left(%trim(&inv)) for site %left(%trim(&invsite)). But this INV  value"
			                	                , "  is not available in Right Track. SCRF INV must match with RIGHT TRACK Value per SITEID.");				
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "INV - INVSITE";
							scrf_variable_value = "&inv. - &invsite.";
							sacq_variable_value = "";
							output;
			     	    run;

						data CK_V15; set CK_V15 _CK_V15; run;
						%end;
			     	%end;
					%else %do;
						data CK_V15; delete; run;
					%end;
					data Listing_TAB5; set Listing_TAB5 CK_V15; run;
				%end;
		     	%mend CK_V15;


		   %********************************************************************************
		    * CK_V16
		    ********************************************************************************;
		    	%macro CK_V16;
			     	%LogMessageOutput(n, CK_V16 - SITE value does not exists in Right Track);

				%if not(%str(&RT_DS_Exist)=%str(NO)) and not(%str(&RT_Dir_Exist)=%str(NO)) %then %do;

					proc sql noprint;
							create table nosite as
							select distinct(invsite),inv from &inlibSCRF..&inDataDS
							where invsite not in 
							             (
											select distinct(center) from  &inlibSCRF..&RTSiteDS							                
										 );

					select count(*) into: nobs_nosite from nosite;
			     	quit;
					  
			     	%if %eval(&nobs_nosite > 0) %then %do;

						data nosite; set nosite;	record=_n_;	run;
			     	    data _dummy; run;

						%do i=1 %to &nobs_nosite;
						data _null_;
							set nosite(where=(record=&i));
							call symput('inv',inv);
							call symput('invsite',invsite);
						run;
						
							%if &i=1 %then %do;
								data CK_V16; set _Listing_TAB5; run;
							%end;

			     	    data _CK_V16(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;
							
							issue = .;
							issue_id = "CK_V16";
							priority = "WARNING";
							desc = "SITE value does not exists in Right Track";
			                desc_info = catx(" ", "SCRF &inDataDS SITE value is %left(%trim(&invsite)) for INV %left(%trim(&inv)). But this SITE value"
			                	                , "  is not available in Right Track. SCRF SITE and INV values must match with RIGHT TRACK ");				
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "INV - INVSITE";
							scrf_variable_value = "&inv. - &invsite.";
							sacq_variable_value = "";
							output;
			     	    run;

						data CK_V16; set CK_V16 _CK_V16; run;
						%end;
			     	%end;
					%else %do;
						data CK_V16; delete; run;
					%end;
					data Listing_TAB5; set Listing_TAB5 CK_V16; run;
				%end;
		     	%mend CK_V16;



		   %********************************************************************************
		    * CK_V17
		    ********************************************************************************;
		    	%macro CK_V17;
			     	%LogMessageOutput(n, CK_V17 - INV and SITEID values cannot contain characters);
				
				%if not(%str(&RT_DS_Exist)=%str(NO)) and not(%str(&RT_Dir_Exist)=%str(NO)) %then %do;

					  data InvSiteSpecialChars;
					  	set &inlibSCRF..&inDataDS;
						if notdigit(inv) or  notdigit(invsite) then output;
					  run;

					  proc sql noprint;
					  	select count(*) into: nobs_special from InvSiteSpecialChars;
					  quit;
					  
			     	%if %eval(&nobs_special > 0) %then %do;

						data InvSiteSpecialChars; set InvSiteSpecialChars;	record=_n_;	run;
			     	    data _dummy; run;

						%do i=1 %to &nobs_special;
						data _null_;
							set InvSiteSpecialChars(where=(record=&i));
							call symput('inv',inv);
							call symput('invsite',invsite);
						run;
						
							%if &i=1 %then %do;
								data CK_V17; set _Listing_TAB5; run;
							%end;

			     	    data _CK_V17(keep=ISSUE--SACQ_VARIABLE_VALUE);
			     	    	set _Listing_TAB5 _dummy;
							
							issue = .;
							issue_id = "CK_V17";
							priority = "WARNING";
							desc = "INV and SITEID values cannot contain characters";
			                desc_info = catx(" ", "SCRF &inDataDS has SITE value %left(%trim(&invsite)) and INV value %left(%trim(&inv))."
			                	                , "  INV and SITEID values cannot contain characters ");				
							key = "N/A";
							scrf_dataset = "&inDataDS";
							scrf_variable = "INV - INVSITE";
							scrf_variable_value = "&inv. - &invsite.";
							sacq_variable_value = "";
							output;
			     	    run;

						data CK_V17; set CK_V17 _CK_V17; run;
						%end;
			     	%end;
					%else %do;
						data CK_V17; delete; run;
					%end;
					data Listing_TAB5; set Listing_TAB5 CK_V17; run;
				%end;
		     	%mend CK_V17;


		   %********************************************************************************
		    * CK_V18
		    ********************************************************************************;
		    	%macro CK_V18;
			     	%LogMessageOutput(n, CK_V18 - Time Variables values cannot be greater than 23:59:59 hours);

					%* find the variables with format time8;
					data _DsetDetails;
					 set _scrfdata;
					 where index(lowcase(format),'time8');
					run;

                    proc sql noprint;
                        select count(*) into: nobs_timevars from _DsetDetails;
                    quit;	
                        
                    %if %eval(&nobs_timevars > 0) %then %do;						
                        proc sql noprint;
                            select count(*) into: nobs_timevars from _DsetDetails;
                            select name into :var1-:var%trim(%left(&nobs_timevars)) from _DsetDetails;
                        quit;	
					
                        %do i=1 %to &nobs_timevars;							
                            data CK_V18(keep=ISSUE--SACQ_VARIABLE_VALUE);
                                set _Listing_TAB5 &inlibSCRF..&inDataDS;						
                                    if input(compress(&&var&i,':'),best12.) >= 86400 then do;												
                                        issue = .;
                                        issue_id = "CK_V18";
                                        priority = "WARNING";
                                        desc = "Time Variables values cannot be greater than 23:59:59 hours";
                                        desc_info = catx(" ", "SCRF &inDataDS &&var&i has value that is not valid."
                                                            , "  Time Variables values cannot be greater than 23:59:59 hours");				
                                        key = "N/A";
                                        scrf_dataset = "&inDataDS";
                                        scrf_variable = "&&var&i";
                                        scrf_variable_value = left(trim(&&var&i));
                                        sacq_variable_value = "";
                                        output;						
                                    end;
                            run;

                            data Listing_TAB5; set Listing_TAB5 CK_V18; run;							
                        %end;
					%end;
					%else %do;
						data CK_V18; delete; run;
					%end;
		     	%mend CK_V18;


			%********************************************************************************
		    * CK_V19
		    ********************************************************************************;
		    	%macro CK_V19;
			     	%LogMessageOutput(n, CK_V19 - LAB_SAFE.LABUNITR cannot be a number);

				%if %eval(%lowcase(&inDataDS) = lab_safe) %then %do;	

							proc sql noprint;
								select count(*) into :tot_recs from _scrfdata where upcase(name)='LABUNITR';
							quit;	

							%if %eval(&tot_recs > 0) %then %do;												
								data CK_V19(keep=ISSUE--SACQ_VARIABLE_VALUE);
									set _Listing_TAB5 &inlibSCRF..&inDataDS;						
										if labunitr ne '' and notdigit(strip(labunitr)) = 0 then do;												
											issue = .;
											issue_id = "CK_V19";
											priority = "WARNING";
											desc = "LAB_SAFE.LABUNITR cannot be a number";
							                desc_info = catx(" ", "SCRF &inDataDS LABUNITR has value that is not valid. "
																 , "LABUNITR can be a character or alphanumeric, but not a number");				
											key = "N/A";
											scrf_dataset = "&inDataDS";
											scrf_variable = "LABUNITR";
											scrf_variable_value = LABUNITR;
											sacq_variable_value = "";
											output;						
										end;
								run;

							data Listing_TAB5; set Listing_TAB5 CK_V19; run;						
							%end;
					%end;
					%else %do;
						data CK_V19; delete; run;
					%end;
		     	%mend CK_V19;


			%********************************************************************************
		    * CK_V20
		    ********************************************************************************;
		    	%macro CK_V20;
			     	%LogMessageOutput(n, CK_V20 - LAB_SAFE.COLLDATE not equal to LBDT);
					
					%if %eval(%lowcase(&inDataDS) = lab_safe) %then %do;	

							proc sql noprint;
								select count(*) into :tot_recs from _scrfdata where upcase(name)='LBDT';
							quit;	

							%if %eval(&tot_recs > 0) %then %do;												
								data CK_V20(keep=ISSUE--SACQ_VARIABLE_VALUE);
									set _Listing_TAB5 &inlibSCRF..&inDataDS;						
										if not missing(LBDT) and LBDT NE COLLDATE then do;												
											issue = .;
											issue_id = "CK_V20";
											priority = "WARNING";
											desc = "LAB_SAFE.COLLDATE not equal to LBDT";
							                desc_info = catx(" ", "SCRF &inDataDS COLLDATE and LBDT value do not match. "
																 , "COLLDATE and LBDT values should match if LBDT exists");				
											key = "N/A";
											scrf_dataset = "&inDataDS";
											scrf_variable = "COLLDATE - LBDT";
											scrf_variable_value = strip(put(COLLDATE,date9.)) ||' - '|| strip(put(LBDT,date9.));
											sacq_variable_value = "";
											output;						
										end;
								run;

							data Listing_TAB5; set Listing_TAB5 CK_V20; run;						
							%end;
					%end;
					%else %do;
						data CK_V20; delete; run;
					%end;
		     	%mend CK_V20;


			%********************************************************************************
		    * CK_V21
		    ********************************************************************************;
		    	%macro CK_V21;
			     	%LogMessageOutput(n, CK_V21 - SID is Not in correct format);
																					
					data CK_V21(keep=ISSUE--SACQ_VARIABLE_VALUE);
						set _Listing_TAB5 &inlibSCRF..&inDataDS;						
							if scan(strip(sid),1,'') ne strip(siteid) or  scan(strip(sid),2,'') ne strip(subjid) then do;												
								issue = .;
								issue_id = "CK_V21";
								priority = "WARNING";
								desc = "SID is Not in correct format";
				                desc_info = catx(" ", "SCRF &inDataDS SID is not following <SITEID><space><SUBJID> format. "
													 , "SID should be a combination of SITEID and SUBJID seperated by space");				
								key = "N/A";
								scrf_dataset = "&inDataDS";
								scrf_variable = "SID - SITEID - SUBJID";
								scrf_variable_value = strip(SID) ||' - '|| strip(SITEID) ||' - '|| strip(SUBJID);
								sacq_variable_value = "";
								output;						
							end;
					run;

							data Listing_TAB5; set Listing_TAB5 CK_V21; run;								

		     	%mend CK_V21;



			%********************************************************************************
		    * CK_V22
		    ********************************************************************************;
		    	%macro CK_V22;
			     	%LogMessageOutput(n, CK_V22 - PID is Not in correct format);

																					
					data CK_V22(keep=ISSUE--SACQ_VARIABLE_VALUE);
						set _Listing_TAB5 &inlibSCRF..&inDataDS;							
							if scan(strip(pid),1,'') ne strip(protno) or  scan(strip(pid),2,'') ne strip(siteid) or  scan(strip(pid),3,'') ne strip(subjid) then do;												
								issue = .;
								issue_id = "CK_V22";
								priority = "WARNING";
								desc = "PID is Not in correct format";
				                desc_info = catx(" ", "SCRF &inDataDS PID is not following <PROTNO><space><SITEID><space><SUBJID> format. "
													 , "PID should be a combination of PROTNO, SITEID and SUBJID seperated by space");				
								key = "N/A";
								scrf_dataset = "&inDataDS";
								scrf_variable = "PID - PROTNO - SITEID - SUBJID";
								scrf_variable_value = strip(PID) ||' - '||strip(PROTNO) ||' - '|| strip(SITEID) ||' - '|| strip(SUBJID);
								sacq_variable_value = "";
								output;						
							end;							
					run;

							data Listing_TAB5; set Listing_TAB5 CK_V22; run;								
		     	%mend CK_V22;


			%********************************************************************************
		    * CK_V23
		    ********************************************************************************;
		    	%macro CK_V23;
			     	%LogMessageOutput(n, CK_V23 - CHILD dataset can not have both CHILDPOT and CHLDBIO Variables);

					proc sql noprint;
						select count(*) into :tot_recs from _scrfdata where upcase(name) in ('CHILDPOT' , 'CHLDBIO');
					quit;						

					%if &tot_recs>=2 %then %do;
					
						data _dummy; run;
																						
						data CK_V23(keep=ISSUE--SACQ_VARIABLE_VALUE);
							set _Listing_TAB5 _dummy;														
									issue = .;
									issue_id = "CK_V23";
									priority = "ERROR";
									desc = "CHILD dataset can not have both CHILDPOT and CHLDBIO Variables";
					                desc_info = catx(" ", "SCRF &inDataDS has CHILDPOT and CHLDBIO Variables. "
														 , "CHILD dataset can not have both CHILDPOT and CHLDBIO Variables");				
									key = "N/A";
									scrf_dataset = "&inDataDS";
									scrf_variable = "";
									scrf_variable_value = "";
									sacq_variable_value = "";
									output;																	
						run;

						data Listing_TAB5; set Listing_TAB5 CK_V23; run;								
					%end;
		     	%mend CK_V23;


			%********************************************************************************
		    * CK_V24
		    ********************************************************************************;
		    	%macro CK_V24;
			     	%LogMessageOutput(n, CK_V24 - If EFDTF then EFDT must exist and vice versa);

   					%if %upcase(&inDataDS)=ADVERSE or %upcase(&inDataDS)=ALLERGY
                    or %upcase(&inDataDS)=CD_B_P or %upcase(&inDataDS)=CHILD
                    or %upcase(&inDataDS)=CN_6_P or %upcase(&inDataDS)=CN_7_P
                    or %upcase(&inDataDS)=CN_8_P or %upcase(&inDataDS)=CN_9_P
                    or %upcase(&inDataDS)=CN_A_P or %upcase(&inDataDS)=CONDRUG
                    or %upcase(&inDataDS)=CONTRT or %upcase(&inDataDS)=DEMOG
                    or %upcase(&inDataDS)=DEV_P or %upcase(&inDataDS)=ECG
                    or %upcase(&inDataDS)=FINAL or %upcase(&inDataDS)=HE
                    or %upcase(&inDataDS)=IC_P or %upcase(&inDataDS)=LAB_SAFE
                    or %upcase(&inDataDS)=ME or %upcase(&inDataDS)=OMIC_P
                    or %upcase(&inDataDS)=PHYEXAM or %upcase(&inDataDS)=PREVDIS
                    or %upcase(&inDataDS)=PRIMDIAG or %upcase(&inDataDS)=RANDOM
                    or %upcase(&inDataDS)=RDOSE or %upcase(&inDataDS)=SCDG
                    or %upcase(&inDataDS)=TESTDRUG or %upcase(&inDataDS)=VITALS
                    or %upcase(&inDataDS)=PK_P %then %do;						
					
						data _efdtf _efdt;
							set _scrfdata;
								if strip(upcase(name)) = 'EFDTF' then output _efdtf;
								if strip(upcase(name)) = 'EFDT' then output _efdt;
						run;

						proc sql noprint;
							select count(*) into :tot_efdtf from _efdtf; 
							select count(*) into :tot_efdt from _efdt; 
						quit;

							%if (&tot_efdtf >= 1 and &tot_efdt=0) or (&tot_efdt >= 1 and &tot_efdtf=0) %then %do;
								data _dummy; run;
																								
								data CK_V24(keep=ISSUE--SACQ_VARIABLE_VALUE);
									set _Listing_TAB5 _dummy;														
											issue = .;
											issue_id = "CK_V24";
											priority = "ERROR";
											desc = "If EFDTF present then EFDT must exist and vice-versa";
											if &&tot_efdtf >= 1 then do;
							                desc_info = catx(" ", "SCRF &inDataDS has variable EFDTF but missing EFDT variable. "
																 , "If variable EFDTF is present then EFDT must exist for Efficacy Domains");
											end;	
											if &&tot_efdt >= 1 then do;
							                desc_info = catx(" ", "SCRF &inDataDS has variable EFDT but missing EFDTF variable. "
																 , "If variable EFDT is present then EFDTF must exist for Efficacy Domains");
											end;
											key = "N/A";
											scrf_dataset = "&inDataDS";
											scrf_variable = "";
											scrf_variable_value = "";
											sacq_variable_value = "";
											output;																	
								run;

										data Listing_TAB5; set Listing_TAB5 CK_V24; run;								

							%end;
					%end;
		     	%mend CK_V24;


			%********************************************************************************
		    * CK_V25
		    ********************************************************************************;
		    	%macro CK_V25;
			     	%LogMessageOutput(n, CK_V25 - If EFTMF present then EFTM must exist and Vice Versa);

   					%if %upcase(&inDataDS)=ADVERSE or %upcase(&inDataDS)=ALLERGY
                    or %upcase(&inDataDS)=CD_B_P or %upcase(&inDataDS)=CHILD
                    or %upcase(&inDataDS)=CN_6_P or %upcase(&inDataDS)=CN_7_P
                    or %upcase(&inDataDS)=CN_8_P or %upcase(&inDataDS)=CN_9_P
                    or %upcase(&inDataDS)=CN_A_P or %upcase(&inDataDS)=CONDRUG
                    or %upcase(&inDataDS)=CONTRT or %upcase(&inDataDS)=DEMOG
                    or %upcase(&inDataDS)=DEV_P or %upcase(&inDataDS)=ECG
                    or %upcase(&inDataDS)=FINAL or %upcase(&inDataDS)=HE
                    or %upcase(&inDataDS)=IC_P or %upcase(&inDataDS)=LAB_SAFE
                    or %upcase(&inDataDS)=ME or %upcase(&inDataDS)=OMIC_P
                    or %upcase(&inDataDS)=PHYEXAM or %upcase(&inDataDS)=PREVDIS
                    or %upcase(&inDataDS)=PRIMDIAG or %upcase(&inDataDS)=RANDOM
                    or %upcase(&inDataDS)=RDOSE or %upcase(&inDataDS)=SCDG
                    or %upcase(&inDataDS)=TESTDRUG or %upcase(&inDataDS)=VITALS
                    or %upcase(&inDataDS)=PK_P %then %do;						
					
						data _eftmf _eftm;
							set _scrfdata;
								if strip(upcase(name)) = 'EFTMF' then output _eftmf;
								if strip(upcase(name)) = 'EFTM' then output _eftm;
						run;

						proc sql noprint;
							select count(*) into :tot_eftmf from _eftmf; 
							select count(*) into :tot_eftm from _eftm; 
						quit;

							%if (&tot_eftmf >= 1 and &tot_eftm=0) or (&tot_eftm >= 1 and &tot_eftmf=0) %then %do;
								data _dummy; run;
																								
								data CK_V25(keep=ISSUE--SACQ_VARIABLE_VALUE);
									set _Listing_TAB5 _dummy;														
											issue = .;
											issue_id = "CK_V25";
											priority = "ERROR";
											desc = "If EFTMF present then EFTM must exist and Vice Versa";
											if &tot_eftmf >= 1 then do;
							                desc_info = catx(" ", "SCRF &inDataDS has variable EFTMF but missing EFTM variable. "
																 , "If variable EFTMF is present then EFTM must exist for Efficacy Domains");
											end;
											if &tot_eftm >= 1 then do;
							                desc_info = catx(" ", "SCRF &inDataDS has variable EFTM but missing EFTMF variable. "
																 , "If variable EFTM is present then EFTMF must exist for Efficacy Domains");
											end;		
											key = "N/A";
											scrf_dataset = "&inDataDS";
											scrf_variable = "";
											scrf_variable_value = "";
											sacq_variable_value = "";
											output;																	
								run;

										data Listing_TAB5; set Listing_TAB5 CK_V25; run;								
							%end;
					%end;
		     	%mend CK_V25;

			%**********************************************************************************************
		    * CK_V26
			* run this check only if symbolic links are used and the mapping type is CSDW SCRF to SACQ. 
			* No need to run for user added input params
		    ***********************************************************************************************;			
			%macro CK_V26;
			%if /*%upcase(&mapType)=CSDWSCRFTOSACQ and*/ %upcase(&srcInput)=SCRF and %upcase(&download)=DOWNLOAD %then %do;		    	
			     	%LogMessageOutput(n, CK_V26 - directory name or symbolic link current pointer for /download and /scrf  do not match );

                    /*
					%let inlibSCRF=out;
					%let inDataDS=cd_b_p;
   					*/	
					%let scrfLoc=%sysfunc(pathname(scrf));
					%let downloadLoc=%sysfunc(pathname(download));
						x cd &scrfLoc;
						filename scrf_lst pipe "ls -la current";

						data _null_;
						format file_date yymmddn8.;
							infile scrf_lst dsd;		
							length file_status $ 200;
							input file_status  $ @;	 	
							if not notdigit(substr(compress(file_status),length(compress(file_status))-7)) then
							file_date=substr(compress(file_status),length(compress(file_status))-7);
							
							call symput('scrf_file_date', strip(file_date));	
						RUN;	

						
						x cd &downloadLoc; 	
						filename raw_lst pipe "ls -la current";		

						data _null_;
						format file_date yymmddn8.;
							infile raw_lst dsd;		
							length file_status $ 200;
							input file_status  $ @;	 	
							if not notdigit(substr(compress(file_status),length(compress(file_status))-7)) then 
							file_date=substr(compress(file_status),length(compress(file_status))-7);
							
							call symput('raw_file_date', strip(file_date));		
						RUN;											
						
				    	%if &scrf_file_date ne  &raw_file_date %then %do;
								data _dummy; run;
																								
								data CK_V26(keep=ISSUE--SACQ_VARIABLE_VALUE);
									set _Listing_TAB5 _dummy;														
											issue = .;
											issue_id = "CK_V26";
											priority = "ERROR";
											desc = "Directory name or symbolic link current pointer for /download and /scrf  do not match";
							                desc_info = catx(" ", "SCRF symbolic link current pointer points to &scrf_file_date. and DOWNLOAD symbolic link current pointer "
																 , "points to &raw_file_date.. Symbolic link current pointers must match");				
											key = "N/A";
											scrf_dataset = "&inDataDS";
											scrf_variable = "";
											scrf_variable_value = "";
											sacq_variable_value = "";
											output;																	
								run;

										data Listing_TAB5; set Listing_TAB5 CK_V26; run;								
						%end;
				%end;
		     	%mend CK_V26;

			%********************************************************************************
		    * CK_V27
		    ********************************************************************************;
		    	%macro CK_V27;
			     	%LogMessageOutput(n, CK_V27 - TRIAL_ID is Not in correct format);					
																					
					data CK_V27(keep=ISSUE--SACQ_VARIABLE_VALUE);
						set _Listing_TAB5 &inlibSCRF..&inDataDS;							
							if 	index(trial_id,'-') = 0 or 
								index(trial_id,'-') > 0 and 
								(scan(strip(trial_id),1,'-') ne strip(protno) or  scan(strip(trial_id),2,'-') ne strip(siteid)) then do;												
								issue = .;
								issue_id = "CK_V27";
								priority = "WARNING";
								desc = "TRIAL_ID is Not in correct format";
				                desc_info = catx(" ", "SCRF &inDataDS TRIAL_ID is not following <PROTNO>-<SITEID> format. "
													 , "TRIAL_ID should be a combination of PROTOCOL and SITEID seperated by hyphen (-)");				
								key = "N/A";
								scrf_dataset = "&inDataDS";
								scrf_variable = "TRIAL_ID - PROTNO - SITEID";
								scrf_variable_value = strip(TRIAL_ID) ||' - '||strip(PROTNO) ||' - '|| strip(SITEID);
								sacq_variable_value = "";
								output;						
							end;							
					run;

							data Listing_TAB5; set Listing_TAB5 CK_V27; run;		

		     	%mend CK_V27;


		   %********************************************************************************
		    * Value Validation Run Process
		    ********************************************************************************;
		 	 
				%* PURPOSE: Creates SAS dataset Listing_TAB5 listings any Value Data Issues
				 * CK_V_SETUP - Setup temporary SAS dataset schell _Listing_TAB5 and create attrib LISTING_TAB5 macro variable
				 * CK_V1 - SCRF Variable actual data length is longer than SACQ standard
				 * CK_V2 - Value not in Pfizer Codelist
				 * CK_V3 - SCRF Char date did not map to SACQ Char Date
				 * CK_V4 - SCRF Char time did not map to SACQ Char time
				 * CK_V5 - SACQ Header Variable value is NULL
				 * CK_V6 - SCRF Dataset to SACQ Dataset Number of Obs Mismatch
				 * CK_V7 - SCRF Dataset to SACQ Dataset Number of Unique Subjects Mismatch
				 * CK_V8 - SACQ header variable PROTNO does not equal global macro variable
				 * CK_V9 - SACQ Variable is R1 but has missing values
				 * CK_V10 - SACQ Variable is R2 but no values are populated
				 * CK_V11 - SCRF or RAW dataset contains 0 observations
				 * CK_V12 - Codelist Value Compared to Root Not Consistant
				 * CK_V13 - SACQ Header Variable LSTCHGTS value all NULL
				 *;

				%let Listing_TAB5 = ;

				%CK_V_SETUP;	

			    %CK_V1;
			    %CK_V2;
			    %CK_V3;
			    %CK_V4;
			    %CK_V5;
			    %CK_V6;
			    %CK_V7;
			    %CK_V8;
			    %CK_V9;
			    %CK_V10;
			    %CK_V11;
			    %CK_V12;
			    %CK_V13;
				%CK_V14;
				%CK_V15;
				%CK_V16;
				%CK_V17;
				%*CK_V18;
				%CK_V19;
				%CK_V20;
				%CK_V21;
				%CK_V22;
				%CK_V23;
				%CK_V24;
				%CK_V25;
				%*CK_V26;
				%*CK_V27;

			    * Derive Issue #;
			    proc sort data=Listing_TAB5(where=(not missing(issue_ID))) out=Listing_TAB5; by issue_id scrf_dataset scrf_variable key; run;
			    data Listing_TAB5;
			    	set Listing_TAB5;
			    	ISSUE = _n_;
			    run;

			%LogMessageOutput(i, End of SubMacro pfesacq_map_scrf_validate_value);
		%mend pfesacq_map_scrf_validate_value;    
		%pfesacq_map_scrf_validate_value;

   %********************************************************************************
    * End Macro
    ********************************************************************************;

	    %* Remove Work Datasets;
	    	%macend:;
	        %macro delmac(wds=null);
	            %if %sysfunc(exist(&wds)) %then %do; 
	                proc datasets lib=work nolist; delete &wds; quit; run; 
	            %end; 
	        %mend delmac;
	        %delmac(wds=_temp1);
	        %delmac(wds=_temp2);
	        %delmac(wds=_SACQSPEC);
	        %delmac(wds=_SCRFDATA);
	        %delmac(wds=&inDataDS._SACQ);
	        %delmac(wds=_&inDataDS);
	        %delmac(wds=CK_V1);
	        %delmac(wds=CK_V2);
	        %delmac(wds=CK_V3);
	        %delmac(wds=CK_V4);
	        %delmac(wds=CK_V5);
	        %delmac(wds=CK_V6);
	        %delmac(wds=CK_V7);
	        %delmac(wds=CK_V8);
	        %delmac(wds=CK_V9);
	        %delmac(wds=CK_V10);
	        %delmac(wds=CK_V11);
	        %delmac(wds=CK_V12);
			%delmac(wds=CK_V13);
			%delmac(wds=CK_V14);
			%delmac(wds=CK_V15);
			%delmac(wds=CK_V16);
			%delmac(wds=CK_V17);
			%delmac(wds=CK_V18);
			%delmac(wds=CK_V19);
			%delmac(wds=CK_V20);
			%delmac(wds=CK_V21);
			%delmac(wds=CK_V22);
			%delmac(wds=CK_V23);
			%delmac(wds=CK_V24);
			%delmac(wds=CK_V25);
			%delmac(wds=CK_V26);
			%delmac(wds=CK_V27);
			%delmac(wds=InvSiteSpecialChars);
			%delmac(wds=_DsetDetails);
	        %delmac(wds=_listing_tab5);
			%delmac(wds=varKeepOrder);

		%LogMessageOutput(i, End OF MACRO);

%mend pfesacq_map_scrf_process_ds;