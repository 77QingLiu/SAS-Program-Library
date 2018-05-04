/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson  $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2016-04-12 16:51:43 -0400 (Tue, 12 Apr 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_map_scrf.sas $
 
  Files Created:         SACQ Datasets:
                         - if Macro parameter tarOutput is not NULL, then output 
                         to where the SAS library tarOutput specifies
                         <path if different from calling program> <filename>.<ext>
                         - if Macro parameter tarOutput is NULL and global macro
                         DEVEL = 0 then will output to 
                         &path_dm/datasets/sacq/YYYYMMDDD where date is date run
                         - if Macro parameter tarOutput is NULL and global macro 
                         DEVEL > 0 then will output to
                         &path_dm/datasets/sacq/draft

                         Information and Exceptions Listing:
                         Output to same location as SACQ datasets, named as:
                         Pfizer &Pxl_Code %upcase(&Protocol) SACQ Transfer 
                         Information and Exceptions Listing.xls

                         Transfer Log:
                         Will add record of transfer per macro parameters
                         &sacq_metadata/&transfer_log
 
  Program Purpose:       Purpose of this macro is to read in study CSDW SCRF
                         datasets and create SACQ datasets per Pfizer SACQ
                         specifictions and codelist values. 

                         Will list create a listing with the info:
                         - Transfer Information
                         - Transfer Records
                         - Metadata
                         - Structure Exceptions
                         - Value Exceptions
                         - Differences Report

                         Ouput record of transfer to SACQ metadata

                         Read from SACQ metadata central location for 
                         specifications and study data

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:
 
    Name:                sacq_metadata
      Allowed Values:    Valid KENNET directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Specifies the central SACQ metadata location that holds
                         SACQ specifications, codelist values, study data, and 
                         transfer records data
 
    Name:                path_cal
      Allowed Values:    Valid KENNET directory path
      Default Value:     /projects/std_pfizer/sponsor/data/csdw
      Description:       Specifies the KENNET root path that Pfizer CAL picks up
                         zip files for SACQ transfers. 
                         - &path_cal/transfer - CAL pickup location
                         - &path_cal/archive - saved zip file location
 
    Name:                transfer_data
      Allowed Values:    Valid KENNET directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/transfer_data
      Description:       Specifies the KENNET directory to store SAS dataset 
                         of transfer metadata that is used to create difference
                         report of changes between transfers.

    Name:                version
      Allowed Values:    Valid version of SACQ specification as found under 
                         &sacq_metadata 
      Default Value:     v1_4
      Description:       As new SACQ specifications are given by Pfizer, they will
                         be converted to SAS datasets and placed under SACQ 
                         metadata location. SAS dataset names follow 
                         sacq_v1_4.sas7bdat naming convection. Latest specification
                         is listed for VERSION as 'v1_4', etc. 

    Name:                codelists
      Allowed Values:    Name of the codelist SAS dataset under SACQ metadata 
      Default Value:     codelists
      Description:       As new updates to possible codelist values are made,
                         the SAS dataset codelists under SACQ metadata will be 
                         updated. 

    Name:                study_data
      Allowed Values:    Name of the study data SAS dataset under SACQ metadata 
      Default Value:     study_data
      Description:       The study data dataset specifies per study information
                         used in mapping to SACQ such as locked, coding dictionary
                         info, etc.  

    Name:                transfer_log
      Allowed Values:    Name of the transfer log SAS dataset under SACQ metadata 
      Default Value:     transfer_log
      Description:       Each transfer is logged to a SAS dataset that holds 
                         study, date and time, issues, and if posted to CAL

    Name:                srcInput
      Allowed Values:    Valid SAS library that stores the CSDW SCRF datasets
      Default Value:     scrf
      Description:       Source CSDW SCRF SAS datasets that are mapped to SACQ

    Name:                tarOutput
      Allowed Values:    Left as null or valid SAS library to store output SACQ 
                         datasets
      Default Value:     null
      Description:       Will default to creating output SACQ library per will 
                         use a SAS library specified here

    Name:                testing
      Allowed Values:    YES, NO
      Default Value:     NO
      Description:       If No, then outputs ZIP file to CAL for pickup, if YES
                         then will not zopy ZIP file for CAL pickup and will 
                         output messsage to log and listing stating that

    Name:                download
      Allowed Values:    SAS library
      Default Value:     download
      Description:       SAS library of raw SAS datasets used to include into 
                         CSDWManifest and Zip file with -999 standard

    Name:                path_edata
      Allowed Values:    Valid UNIX directory path
      Default Value:     path_edata
      Description:       Path to were external SAS datasets are stored to include
                         with raw data into CSDWManifest and Zip file with
                         -999 standard

    Name:                OverRide999Domains
      Allowed Values:    ALL or @ seperated dataset names
      Default Value:     null
      Description:       Defaults -999 standard in CSDWManifest file for ALL datasets or 
                         each listed in the @ seperated list        

  Macro Dependencies:    pfesacq_map_scrf_input_checks<br />
                         pfesacq_map_scrf_listing<br />
                         pfesacq_map_scrf_manifest<br />
                         pfesacq_map_scrf_process_ds<br />
                         pfesacq_map_scrf_char_dates<br />
                         pfesacq_map_scrf_char_times<br />
                         pfesacq_map_scrf_validate_struct<br />
                         pfesacq_map_scrf_zip

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2153 $
-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
  MODIFICATION VERSIONS: 

  Version: 1.0 Date: 12FEB2015 Author: Nathan Hartley

  Version: 2.0 Date: 18MAR2015 Author: Nathan Hartley
    Updates:
    1) pfesacq_map_scrf_process_ds V2.0
    2) pfesacq_map_scrf_validate_value v2.0

  Version: 2.1 Date: 27MAR2015 Author: Nathan Hartley
    Updates:
    1) pfesacq_map_scrf_listing V2.0
    2) pfesacq_map_scrf_zip V2.0

  Version: 3.0 Date: 17APR2015 Author: Nathan Hartley
    Updates:
    1) pfesacq_map_scrf_manifest V2.0

  Version: 4.0 Date: 19JUN2015 Author: Nathan Johnson
    Updates:
    1) pfesacq_map_scrf_listing V3.0
    2) pfesacq_map_scrf_zip V3.0
    3) pfesacq_map_scrf_manifest V3.0

  Version: 5.0 Date: 14JUL2015 Author: Nathan Johnson
    Updates:
    1) pfesacq_map_scrf_manifest V4.0 
        1) inclusion of raw datasets from download library in manifest
    2) pfesacq_map_scrf_zip V4.0
        1) inclusion of raw datasets from download library in zip file
        2) renaming of raw dataset variables that are Oracle keywords or restricted terms

  Version: 6.0 Date: 22JUL2015 Author: Nathan Hartley
    Updates:
    1) pfesacq_map_scrf_manifest V5.0
    2) modified header info revisions, added options noquotelenmax

  Version: 7.0 Date: 20150909 Author: Nathan Hartley
    Updates:
    1) pfesacq_map_scrf_input_checks V2.0
    2) Added to check 1.14 for encoding=WLATIN1 as required per Pfizer CAL

  Version: 8.0 Date: 20150918 Author: Nathan Johnson
    Updates:
    1) Update pfesacq_map_scrf_listing.sas to remove report tab ‘Metadata’ where 
       domain is not part of transfer
    2) Update pfesacq_map_scrf_zip.sas to use metadata/data/sacq_restricted_terms.sas7bdat 
       for list of restricted terms rather than local dataset.
    3) Update pfesacq_map_scrf_manifest.sas to remove references to sacq library 
       that do not use tarOutput macro variable.
    4) Append SACQ UIMS submitted variables to _metadata dataset, with datastandard
       version set to -999.

  Version: 9.0 Date 20151230 Author: Nathan Hartley
    Updates:
    1) Update cleanup code to separately remove tables and views to avoid log messages
    2) Updated appending of sacq metadata and uims variables to avoid log issues
    3) Updated to map to 3 part codelists
    4) Added input parameter OverRide999Domains to default -999 standards
    5) Submacros Updated  
      1) pfesacq_map_scrf_manifest 7.0 Date: 20151229 Author: Nathan Hartley 
      2) pfesacq_map_scrf_char_dates 2.0 Date: 20151229 Author: Nathan Hartley
      3) pfesacq_map_scrf_char_times 2.0 Date: 20151229 Author: Nathan Hartley
      4) pfesacq_map_scrf_process_ds 4.0 Date: 20151229 Author: Nathan Hartley
  
  Version: 10.0 Date 20160104 Author: Nathan Hartley  
    1) Corrected SACQ Transfer Total WARN and ERROR section
    2) Changed to %bquote in call %pfesacq_map_scrf_zip %bquote(&send_transfer)
       due to comma in data
    3) Submacros Updated
      1) pfesacq_map_scrf_zip v7
      2) pfesacq_map_scrf_listing v5
      3) pfesacq_map_scrf_process_ds v5

  Version: 11.0 Date 20160127 Author: Nathan Hartley
    1) Modifed CLEAN UP ENVIRONMENT section to allow work datasets LISTING_LAB5 
       and LISTING_TAB6 through for testing purposes
    2) Submacros Updated
      1) pfesacq_map_scrf_process_ds v6
      2) pfesacq_map_scrf_listings v6
      3) pfesacq_map_scrf_char_dates v3
      4) pfesacq_map_scrf_manifest v8

  Version: 12.0 Date 20160128 Author: Nathan Hartley
    1) Submacros Updated
      1) pfesacq_map_scrf_listings v7
        1) Changed MAPPED to M_MAPPED for filtering SACQ mapped records      

  Version: 13.0 Date 20160411 Author: Nathan Johnson
    1) Submacros Updated
      1) pfesacq_map_scrf_manifest v9
        1) Streamline echo output by not outputting count of lstchgts columns
      2) pfesacq_map_scrf_process_ds v7
        1) check if the RT site dataset(_rt_site) exists
        2) Added edit checks CK_V14 to CK_V27
        
-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf(
	sacq_metadata=/projects/std_pfizer/sacq/metadata/data,
	path_cal=/projects/std_pfizer/sponsor/data/csdw,
	transfer_data=/projects/std_pfizer/sacq/metadata/transfer_data,
	version=v1_9,
	codelists=codelists,
	study_data=study_data,
	transfer_log=transfer_log,
	srcInput=scrf,
	tarOutput=null,
	testing=NO,
	download=download,
	path_edata=path_edata,
  OverRide999Domains=null);

********************************************************************************
* Program Metadata;

	OPTIONS nofmterr;
  OPTIONS noquotelenmax;

	%let run_macro = PFESACQ_MAP_SCRF;
	%let version_num = 13;
	%let version_date = 20160411;

	%let version_path = opt/pxlcommon/stats/macros/partnership_macros/pfe;
	%*let version_path = opt/pxlcommon/stats/macros/unittesting/test_area/macros/partnership_macros/pfe;

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
            OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR /* NOSOURCE NONOTES */;
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

	* set sacq as name of Pfizer metadata sacq spec SAS dataset with version;
      %let sacq = sacq_&version;
      %let sacq_uims = sacq_uimsvars_&version;

	* Testing prevents Zip files posted to CAL;
    	%let send_transfer =;
    	%if %upcase(&testing)=NO %then %do;
    		%let send_transfer = YES;
    	%end;
    	%else %do;
    		%let send_transfer = NO, Macro Input Parameter TESTING=YES;
    	%end;
	
	* Notes:
		Global macro data taken from below, checked within submacro pfesacq_map_input_checks
		  1) PROTOCOL
		  2) PXL_CODE
		  3) DEVEL (if input parameter tarOutput not set)
		  4) PATH_DM (if input parameter tarOutput not set)
		
		* libname SACQ_MD "&sacq_metadata"; * created per Parameter check C1.2
		;

    %put ;
    %put INFO:[PXL]---------------------------------------------------------------------;
    %put INFO:[PXL] MAP_SCRF_SACQ: Start of Macro ;
    %put INFO:[PXL] File Location: &version_path ;
    %put INFO:[PXL] Version Number: &version_num ;
    %put INFO:[PXL] Version Date: &version_date ;
    %put INFO:[PXL] ;
    %put INFO:[PXL] Purpose: Map Pfizer CSDW SCRF Datasets to SACQ Datasets using ;
    %put INFO:[PXL]          Pfizer SACQ Specifictions ;
    %put INFO:[PXL] Input: 1) Pfizer SACQ Metadata Area: ;
    %put INFO:[PXL]           &sacq_metadata ;
    %put INFO:[PXL]           1) Pfizer Standards SACQ Specifiction: &sacq..sas7bdat;
    %put INFO:[PXL]           2) Pfizer Standards CODELISTS: &codelists..sas7bdat ;
	  %put INFO:[PXL]           3) Study Data Tracker: &study_data..sas7bdat ;
    %put INFO:[PXL]        2) Study Specific SCRF Datasets per SAS library: &srcInput ;
    %put INFO:[PXL] Output: 1) Study Specific SACQ Datasets per SAS library: &tarOutput ;
	  %put INFO:[PXL]         2) Zip transfer file per path: &path_cal;
	  %put INFO:[PXL]         3) Transfer Log: &sacq_metadata/&transfer_log..sas7bdat ;
    %put INFO:[PXL]         4) Send_Transfer = &send_transfer ;
    %put INFO:[PXL] Global Macros: ;
    %put INFO:[PXL]         1) DEBUG=&DEBUG;
	  %put INFO:[PXL]         2) GMPXLERR=&GMPXLERR;
    %put INFO:[PXL]---------------------------------------------------------------------;
    %put ;

	data Listing_TAB4;
	run;

    %let Listing_TAB5 = 
        issue               length=   8 label="Issue #"
        issue_id            length=$200 label="Issue ID"
        priority            length=$200 label="Issue Priority"
        desc                length=$200 label="Issue Description"
        desc_info           length=$200 label="Detailed Info"
        key                 length=$200 label="KEY (SITEID-SUBJID-ACTEVENT-DOCNUM-REPEATSN)"
        scrf_dataset        length=$200 label="SCRF Dataset"
        scrf_variable       length=$200 label="SCRF Variable"
        scrf_variable_value length=$200 label="SCRF Variable Value"
        sacq_variable_value length=$200 label="SACQ Variable Value";

    data Listing_TAB5;
    run;

	* Generate run date time for output listing and transfer_log update;
	%global cdatetime;
	data _null_;
		format _cdatetime E8601DT.;
		_cdatetime = datetime();
		call symput('cdatetime',compress(put(_cdatetime, E8601DT.),'-:'));
		call symput('cdatetimen',put(_cdatetime, E8601DT.));
	run;

********************************************************************************
* Internal Macros;

	* PURPOSE: Output log message for start or stop of code section
	  INPUT: message=text to dispay
	  OUTPUT: Text to log only;
		%macro _Section(message=null);
			%put NOTE:[PXL] ---------------------------------------------------------------------;
			%put NOTE:[PXL] &message;
			%put NOTE:[PXL] ---------------------------------------------------------------------;
		%mend _Section;

********************************************************************************
* Input Checks;
  x "echo --- Run Input Checks";

	%let ErrFlag = 0;
	%pfesacq_map_scrf_input_checks;
	%if &ErrFlag=1 %then %goto macerr;

*************************************************************************
* Read in SCRF Metadata;
  x "echo --- Get SCRF Metadata";

	%_Section(message=S1: Read in SCRF Metdata);

	* SCRF Metadata;
		proc sql noprint;
			create table _SCRF_METADATA as
				select
					upcase(a.memname) as scrf_dataset,
					a.memlabel as scrf_dataset_label,
					upcase(b.name) as scrf_variable,
					b.type as scrf_type,
					b.length as scrf_length,
					b.format as scrf_format,
					b.label as scrf_label
				from
					sashelp.vtable as a 
					inner join
					sashelp.vcolumn as b 
				on 
					a.libname = upcase("&srcInput")
					and b.libname = upcase("&srcInput")
					and a.memname = b.memname;
		quit;

	%_Section(message=S1: Read in SCRF Metdata: Completed);

*************************************************************************
* Append SACQ Standard Metadata;
  x "echo --- Append SACQ Standard Metadata";
	%_Section(message=S2: Append SACQ Standard Metadata);

    data work._sacq_metadata_in;
        attrib
            DATASET length=$200
            VARIABLE length=$200
            RQ  length=$200
            DATA_TYPE length=$200
            DATA_LENGTH length=8.
            DATA_FORMAT length=$200
            DATA_LABEL length=$200
            CODELIST_STANDARD length=$200
            CODELIST length=$200
            CODELIST_FORMAT length=$200
            CODELIST_ROOT length=$200
        ;
        set SACQ_MD.&sacq (in=a);
    run;

    data work._sacq_metadata;
        set _sacq_metadata_in (in=a)
            SACQ_MD.&sacq_uims (in=b)
            ;
        if a then has_uims_variables = 0;
        if b then has_uims_variables = 1;
    run;
    
	proc sql noprint;
		create table _metadata as
			select 
				coalescec(a.scrf_dataset, b.dataset) as M_DATASET,
				coalescec(a.scrf_variable, b.variable) as M_VARIABLE,

				a.scrf_dataset,
				a.scrf_dataset_label,
				a.scrf_variable,
				a.scrf_type,
				a.scrf_length,
				a.scrf_format,
				a.scrf_label,

				b.dataset as sacq_dataset,
				b.variable as sacq_variable,
				b.rq as sacq_core,
				b.data_type as sacq_type,
				b.data_length as sacq_length,
				b.data_format as sacq_format,
				b.codelist_standard as sacq_codelist_standard,
				b.codelist as sacq_codelist,
        b.codelist_format as sacq_codelist_format,
        b.codelist_root as sacq_codelist_root,
				b.data_label as sacq_label,
        b.has_uims_variables as has_uims_variables

			from _SCRF_METADATA as a 
				full outer join
				_sacq_metadata as b
			on catt(upcase(a.scrf_dataset),"_SACQ") = upcase(b.dataset) 
			   and upcase(a.scrf_variable) = upcase(b.variable);
        
        drop table _sacq_metadata, _sacq_metadata_in;
	quit;
    
    /* set data standard version based on whether variables exist in SCRF that
        are currently under UIMS request for addition to spec */
    data _metadata;
        set _metadata;
        length data_standardver $4.;
        if has_uims_variables and scrf_variable ne "" then data_standardver = "-999";
        else data_standardver = "1.0";
    run;
    
    data _null_;
        set _metadata (where=(data_standardver = "-999"));
        if _n_ = 1 then do;
            put "----------------------------------------------------";
            put "VARIABLES IN UIMS REQUEST DATASET AND SCRF DATA";
            put "----------------------------------------------------";
        end;
        put sacq_variable +1 scrf_variable +1 data_standardver;
    run;

    %* OverRide with -999 for input parameter;
        %if &OverRide999Domains = ALL %then %do;
            data _metadata;
                set _metadata;
                DATA_STANDARDVER = "-999";
            run;
        %end;
        %else %do;
            %* Cycle through each record and set to -999 if DATASET listed in OverRide999Domains input parameter;
            data _metadata(DROP=_part _OverRide999Domains count);
                length _part $15 _OverRide999Domains $500;
                set _metadata;

                _OverRide999Domains = symget('OverRide999Domains');

                if not missing(SACQ_DATASET) and not missing(SCRF_DATASET) then do;
                    count=0;
                    do until(_part='');
                        count+1;
                        _part = upcase(scan(_OverRide999Domains,count,'@'));
                        
                        if SACQ_DATASET = _PART or SACQ_DATASET = catx("_",_PART,"SACQ") then do;
                            DATA_STANDARDVER = "-999";
                        end;
                    end;
                end;
            run;
        %end;
        
	%_Section(message=S2: Append SACQ Standard Metadata: Completed);

*************************************************************************
* Validation Checks for Structure CK_S1 - CK_S3 
  Creates work dataset Listing_TAB4;
  x "echo --- Run Validation Checks for Structure";
	%pfesacq_map_scrf_validate_struct;

********************************************************************************
* Cycle through each SCRF-SACQ dataset;
    x "echo --- Processing Conversion of SCRF Datasets";

  	* Get list of datasets that have variable matches between SCRF and SACQ;
  	proc sql noprint;
    		create table _match_datasets as
    		select distinct scrf_dataset
    		from _metadata
    		where scrf_variable = sacq_variable;

    		select count(*) into : Total_SCRF_Datasets
    		from _match_datasets;

    		%if &Total_SCRF_Datasets > 0 %then %do;
      			select 
      				scrf_dataset
      				into :SDS_1-:SDS_%TRIM(%LEFT(&Total_SCRF_Datasets))
      			from _match_datasets; 
    		%end;
  	quit;

  	* Cycle through each dataset to map SCRF to SACQ dataset;
  	%do k=1 %to &Total_SCRF_Datasets;
        x "echo ------ Processing SCRF Dataset %left(%trim(&k)) of %left(%trim(&Total_SCRF_Datasets)): &&SDS_&k";

        %* PURPOSE: Maps SCRF dataset to SACQ dataset and value validation
         * OUTPUT: &inDataDS._SACQ and LISTING_TAB5
         *;
        %pfesacq_map_scrf_process_ds(
            inlibSACQMetadata =SACQ_MD,
            inlibSCRF         =&srcInput,
            outlibSACQ        =&tarOutput,
            inDataSACQSpec    =&sacq,
            inDataUIMSSpec    =&sacq_uims,
            inDataCodelists   =&codelists,
            inDataDS          =&&SDS_&k,
            inVersion         =&version,
            inProtocol        =&Protocol);
  	%end;

********************************************************************************
* Creation of CSDWManifest.xml file;
  x "echo --- Create Manifest File";

  %pfesacq_map_scrf_manifest;

********************************************************************************
* Output Information and Exceptions Listing;
  x "echo --- Create Listing File";
  
	%pfesacq_map_scrf_listing;

********************************************************************************
* Creation of XPT and Zip file for CAL Transfer;
  x "echo --- Create Zip File";
  %put NOTE:[PXL] send_transfer=&send_transfer;
  %pfesacq_map_scrf_zip(
      _tarOutput=&tarOutput,
      _download=&download,
      _path_edata=&path_edata,
      _manifest=CSDWManifest.xml,
      _protocol=&protocol,
      _cdatetime=&cdatetime,
      _send_transfer=%bquote(&send_transfer),
      _path_cal=&path_cal);

********************************************************************************
* Output to Transfer Log;
  x "echo --- Output to Transfer Log";

	%put NOTE:[PXL] ---------------------------------------------------------------------;
	%put NOTE:[PXL] Output to Transfer Log;
	%put NOTE:[PXL] ---------------------------------------------------------------------;

	%let numUniqueSubjectsDEMOG = 0;
	proc sql noprint;
		select noSubjects into: numUniqueSubjectsDEMOG
		from _manifest_metadata
		where upcase(fileName) = upcase("DEMOG_SACQ");
	quit;

	%let total_notes = 0;
	%let total_notes = %eval(&sn + &vn);

	%let total_warn = 0;
	%let total_warn = %eval(&sw + &vw);

	%let total_err = 0;
	%let total_err = %eval(&se + &ve);

  %put INFO:[PXL] ---------------------------------------------------------------------;
  %put INFO:[PXL] SACQ Transfer Total NOTES = %left(%trim(&total_notes));
  %put INFO:[PXL] SACQ Transfer Total WARNINGS = %left(%trim(&total_warn));
  %put INFO:[PXL] SACQ Transfer Total ERRORS = %left(%trim(&total_err));
  %put INFO:[PXL] ---------------------------------------------------------------------;

	%if %eval(&total_err > 0) %then %do;
		%let sentToPfizer = NO, Transfer not sent if %str(ERR)OR Issues found; 
		%put %str(ERR)OR:[PXL] sentToPfizer = &sentToPfizer;
	%end;
	%else %do;
		%let sentToPfizer = &send_transfer;
		%put NOTE:[PXL] send_transfer = &send_transfer;
	%end;
  x "echo ------ Send Transfer: &send_transfer";

	data _transfer_log;
		attrib 
			pxl_code length= 8 
			protocol length= $12 
			genDateTime length= 8 format=E8601DT. 
			sentToPfizer length= $50
			numDatasets length= 8
			numUniqueSubjectsDEMOG length= 8
			numNotes length= 8
			numWarn length= 8
			numErr length= 8
			runMacro length= $25
			runMacroVersion length= $25
			sacqSpecVersion length= $25
			codelistsVersion length= $25
		;
		pxl_code = &Pxl_Code;
		protocol = "&Protocol";
		genDateTime = input("&cdatetimen", E8601DT.);
		sentToPfizer = "&sentToPfizer";
		numDatasets = &count_Transfer_records;
		numUniqueSubjectsDEMOG = &numUniqueSubjectsDEMOG;
		numNotes = &total_notes;
		numWarn = &total_warn;
		numErr = &total_err;
		runMacro = "&run_macro";
		runMacroVersion = "&version_num.|&version_date";
		sacqSpecVersion = "&sacq_version";
		codelistsVersion = "&codelist_version";
	run;

	%if "&testing" ne "YES" %then %do;
		data sacq_md.transfer_log;
			length sentToPfizer $50.;
      set sacq_md.transfer_log _transfer_log;
		run;
	%end;

	%put NOTE:[PXL] ---------------------------------------------------------------------;
	%put NOTE:[PXL] Output to Transfer Log Completed;
	%put NOTE:[PXL] ---------------------------------------------------------------------;

********************************************************************************
* End of Program;

	* Derive macro run duration;
	data _null_;
		format startDT endDT E8601DT.;

		* Created at beginning of macro;
		startDT = input(symget('cdatetimen'), E8601DT.);

		endDT = datetime();
		hours = floor((endDT-startDT)/3600);
		if hours < 0 then hours = 0;
		minutes = floor(((endDT-startDT)-(hours*3600))/60);
		if minutes < 0 then minutes = 0;
		seconds = floor((endDT-startDT)-(hours*3600)-(minutes*60)) + 1;
		if seconds < 0 then seconds = 0;

		put ;
		put "INFO[PXL] Macro MAP_SCRF_SACQ Run Time Duration:";
		put "INFO[PXL] Start DateTime   : " startDT;
		put "INFO[PXL] Complete DateTime: " endDT;
		put "INFO[PXL] Macro MAP_SCRF_SACQ Run Time Duration = " hours " hours, " minutes " minutes, and " seconds " seconds";
		put ;
	run;
  
	%put ;
	%goto macend;
    
	%macerr:;
	%put %str(ERR)OR:[PXL] ---------------------------------------------------------------------;
	%put %str(ERR)OR:[PXL] MAP_SCRF_SACQ: Abnormal end to program. Review Log.;
	%put %str(ERR)OR:[PXL] ---------------------------------------------------------------------;

	%macend:;

    /***************************************************************************
    * CLEAN UP ENVIRONMENT
    ***************************************************************************/
    %let tablelist = ;
    %let viewlist = ;
    proc sql noprint;
        select memname into:tablelist separated by ','
        from sashelp.vtable 
        where libname = "WORK" and memtype = "DATA"
        and memname not in ("_UNITTEST_PRGOPTIONS","_UNITTEST_RAW","Listing_TAB5","Listing_TAB6")
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
    %dellib(libn=transdat);
    
    options fmterr NOMINOPERATOR quotelenmax;

    %symdel CATEGORY
            CDATETIME
            CODELIST_VERSION
            CODELIST_VERSION
            count_raw_datasets
            COUNT_TRANSFER_RECORDS
            DATACLEANLINESS
            DATASENSITIVITY
            debug
            ISDATABASELOCK
            NS1COMMENTS
            PATH_DOWNLOAD
            PATH_SACQ
            SACQ_VERSION
            SACQ_VERSION
            SE SN SW VE VN VW   
            tablelist viewlist
            /nowarn ;
    
    title;
    footnote;
        
	%put ;
	%put INFO:[PXL] ---------------------------------------------------------------------;
	%put INFO:[PXL] MAP_SCRF_SACQ: End of Macro ;
	%put INFO:[PXL] File Location: &version_path ;
	%put INFO:[PXL] Version Number: &version_num ;
	%put INFO:[PXL] Version Date: &version_date ;
	%put INFO:[PXL] Send_Transfer: &send_transfer ;	
	%put INFO:[PXL] ---------------------------------------------------------------------;
	%put ;
    

%mend pfesacq_map_scrf;