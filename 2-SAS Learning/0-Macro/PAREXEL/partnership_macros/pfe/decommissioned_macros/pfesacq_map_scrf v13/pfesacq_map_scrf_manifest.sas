/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Called from parent macro pfesacq_map_scrf:
                         %pfesacq_map_scrf_manifest;

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: johnson2 $
  Creation Date:         12FEB2015                       $LastChangedDate: 2016-04-11 17:27:29 -0400 (Mon, 11 Apr 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfesacq_map_scrf_manifest.sas $
 
  Files Created:         None
 
  Program Purpose:       Create CSDWManifest.xml from SACQ datasets, DOWNLOAD 
                         datasets, and EDATA latest datasets that have more than
                         0 records.  
 
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
 
	1) Global macro variable DATASENSITIVITY or takes value from &study_data 
	   (unblinding info present or not)
	2) Global macro variable PROTOCOL
	3) Global macro variable ISDATABASELOCK or takes value from &study_data 
	   (study locked true/false)
	4) Global macro variable DATACLEANLINESS or takes value from &study_data 
	   (cleanliness of the data value)
	5) &study_data -> get gategory (WORKING_DATA, etc)
	6) Global macro variable DATABASE_TYPE (will default to DATALABS if not 
	   present and throw warning message)
	7) Parent macro input parameter VERSION_NUM (version of program number)
	8) Parent macro input parameter VERSION_DATE 
	   (version date of program number)
	9) SAS library TAROUTPUT (will be SACQ datasets location)
 
  Macro Output:   
    
    Name:                CSDWManifest.xml 
      Type:              XML File
      Allowed Values:    N/A
      Default Value:     N/A
      Description:       &TAROUTPUT.CSDWManifest.xml (where TAROUTPUT is 
                         location of SAS library path, same place SACQ 
                         output datasets located)

  Macro Dependencies:  This is a submacro dependant on calling parent macro: 
                       pfesacq_map_scrf.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2142 $

Version: 1.0 Date: 12FEB2015 Author: Nathan Hartley

Version: 2.0 Date: 27MAR2015 Author: Nathan Hartley
	Updates
	1) Updated dataSensitivity check to allow DUMMY/MASKED_DATA

Version: 3.0 Date: 19JUN2015 Author: Nathan Johnson
	Updates
	1) Include Raw Data In Manifest File
  2) Error handling to avoid log errors
 
Version: 4.0 Date: 17JUL2015 Author: Nathan Johnson
  Updates
  1) ensure dataStandardVer and domainVersion are left as -999 for raw data
  2) update program comments
  3) ensure noSubjects is -1 if there is no subject data present
  4) cleanup of libraries and datasets for validation
  
Version: 5.0 Date: 22JUL2015 Author: Nathan Hartley
  Updates
  1) Updated check of dataSensitivity values to work with / in data

Version: 6.0 Date: 18SEP2015 Author: Nathan Johnson
  Updates
  1) Removed references to sacq library not using tarOutput macro variable
  2) Update DataStandardVer and DomainVer based on values from _metadata dataset
  
Version: 7.0 Date: 20151229 Author: Nathan Hartley
  Updates
  1) Updated put statements per updated test validation
  2) Updated clean up section

Version: 8.0 Date: 20160127 Author: Nathan Hartley
  1) maxLastChangeTime - added where lstchgts is not null

Version: 9.0 Date: 20160411 Author: Nathan Johnson
  1) Streamline echo output by not outputting count of lstchgts columns
  
-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_manifest;

  %put ;
	%put INFO:[PXL]---------------------------------------------------------------------;
	%put INFO:[PXL] PFESACQ_MAP_SCRF_MANIFEST: Start of Submacro;
	%put INFO:[PXL] Input:;
	%put INFO:[PXL]   version_num=&version_num;
	%put INFO:[PXL]   version_date=&version_date;
	%put INFO:[PXL]   study_data=&study_data;
	%put INFO:[PXL]   tarOutput=&tarOutput;
	%put INFO:[PXL]   srcInput=&srcInput;
	%put INFO:[PXL]   protocol=&protocol;
	%put INFO:[PXL]   send_transfer=&send_transfer;
	%put INFO:[PXL]---------------------------------------------------------------------;	
  %put ;

  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_setup
  * PURPOSE: Setup input local references and output log macro run message;
  *****************************************************************************/
  %macro _manifest_setup;

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

    * Verify PROTOCOL exists in &STUDY_DATA;
      %let cnt_protocol = 0;
      proc sql noprint;
        select count(*) into: cnt_protocol
        from sacq_md.&study_data
        where upcase(protocol) = upcase("&protocol");
      quit;
      %if &cnt_protocol = 0 %then %do;
          %put ;
          %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: Global Macro PROTOCOL value does not exist in &study_data;
          %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: PROTOCOL = &PROTOCOL;
          %let SEND_TRANSFER = NO, issues found in CSDWManifest.xml, see SAS log;
          %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: SEND_TRANSFER = &send_transfer;
          %put ;
          %let GMPXLERR = 1;
          %goto MacErr;			
      %end;

    * Get path of library SACQ;
      proc sql noprint;
        select left(trim(path)) into: path_sacq
        from (
          select distinct path 
          from sashelp.vlibnam
          where upcase(libname)=upcase("&tarOutput"));
      quit;
      %let path_sacq=%left(%trim(&path_sacq));

    * Get path of library DOWNLOAD;
      proc sql noprint;
        select left(trim(path)) into: path_download
        from (
          select distinct path 
          from sashelp.vlibnam
          where upcase(libname)=upcase("&download"));
      quit;
      %let path_download=%left(%trim(&path_download));				

    %put ;
    %put INFO:[PXL]-------------------------------------------------------------------------------;
    %put INFO:[PXL] Submacro Name: PFESACQ_MAP_SCRF_MANIFEST.sas;
    %put INFO:[PXL] Parent Macro Name: PFESACQ_MAP_SCRF.sas;
    %put ;
    %put INFO:[PXL] PURPOSE: Create CSDWManifest.xml from SACQ, DOWNLOAD, and EDATA SAS datasets, ;
    %put INFO:[PXL] %str(   )as metadata per Pfizer CSDWManifest file specifications. ;
    %put ;
    %put INFO:[PXL] INPUT PARAMETERS: ;
    %put INFO:[PXL] %str(   )1) study_data=sacq_md.&study_data;
    %put INFO:[PXL] %str(   )2) tarOutput=&tarOutput;
    %put INFO:[PXL] %str(   )3) srcInput=&srcInput;
    %put INFO:[PXL] %str(   )4) protocol=&protocol;
    %put INFO:[PXL] %str(   )5) send_transfer=&send_transfer;
    %put ;
    %put INFO:[PXL] OUTPUT: ;
    %put INFO:[PXL] %str(   )1) &TAROUTPUT.CSDWManifest.xml;
    %put INFO:[PXL] %str(   )2) Work SAS dataset _manifest_metadata;
    %put INFO:[PXL]-------------------------------------------------------------------------------;
    %put ;	

    * Read metadata for processing;
    option nonotes; * Suppresses encoding notes in log;
    data work.vtable;
      set sashelp.vtable;
    run;
    data work.vcolumn;
       set sashelp.vcolumn;
    run;
    %if &DEBUG=0 %then %do; option notes; %end;			

    %MacErr:;
  %mend _manifest_setup;

  
  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_getRaw
  * PURPOSE: Get metadata from raw data in DOWNLOAD folder 
  *****************************************************************************/
  %macro _manifest_getRaw;
    %put ;		
    %put NOTE:[PXL] Get DOWNLOAD;
          x "echo ------ Get Raw Data Information for Manifest from &download";

    * Get count of datasets with at least one observation;
    proc sql noprint;
      select count(*) into :total_datasets 
      from vtable 
      where upcase(libname) = upcase("&download") and nobs > 0;
      
      select count(*) into :ignored_datasets 
      from vtable 
      where upcase(libname) = upcase("&download") and nobs = 0;
    quit;
    
    %let total_datasets = %trim(%left(&total_datasets));
    %let ignored_datasets = %trim(%left(&ignored_datasets));

    %if &total_datasets > 0 %then %do;
      %put NOTE:[PXL] Total DOWNLOAD SAS Datasets Found = &total_datasets;
              x "echo -------- Total DOWNLOAD SAS Datasets Found = &total_datasets";
      proc sql noprint;
        select memname, nobs
             into :dataset_1-:dataset_&total_datasets,
                  :nobs_1-:nobs_&total_datasets
        from vtable
        where upcase(libname) = upcase("&download") and nobs > 0;
      quit; 

    %end;			

    %if &ignored_datasets > 0 %then %do;
      %put NOTE:[PXL] Total DOWNLOAD SAS Datasets with 0 Observations (Not included in transfer) = &ignored_datasets;
      x "echo ------ Datasets in DOWNLOAD ignored due to 0 observations = &ignored_datasets";
    %end;

    
    %if &total_datasets > 0 %then %do;
        %put ;		
        %put NOTE:[PXL] Add raw datasets to dataset _manifest_metadata_raw;
                                 
        proc sql noprint;
          create table _manifest_metadata_raw as
          select
            "PAREXEL" as sourceData,
            "Created by SAS program PFESACQ_MAP_SCRF.sas, version &version_num &version_date, Encoding set for WLATIN1" as Comments,
            upcase("&category") as category,
            "&protocol" as studyID,
            upcase("&dataSensitivity") as dataSensitivity length=25,
            "CUMULATIVE" as loadType,
            lowcase("&isDatabaseLock") as isDatabaseLock length=5,
            a.memname as fileName,
            "Raw" as dataConformance,
            "-999" as dataStandardVer,
            "-999" as domainVersion,
            upcase("&dataCleanliness") as dataCleanliness length=25,
            a.crdate as generationTime format=e8601dt19.,
            a.crdate as srcSystemExtractionTime format=e8601dt19.,
            a.crdate as maxLastChangeTime format=e8601dt19.,
            a.nvar as noColumns,
            a.nobs as noOfRows,
            -1 as noSubjects,
            "" as medicalEventDictionary length=200,
            "" as drugDictionary length=200,
            "" as Comments2 length=200
          from (select * from vtable where upcase(libname) = upcase("&download") and nobs > 0) as a
          ;
        quit;	

          *************************************************************
          * Create macro var list of datasets;
            proc sql noprint;
              select fileName
                     into :dataset_1-:dataset_%trim(%left(&total_datasets))
              from _manifest_metadata_raw;
            quit;

          *************************************************************
          * Cycle through each dataset;
            %put NOTE:[PXL] Cycle through each dataset;
            %do i=1 %to &total_datasets;
              %put NOTE:[PXL] ***** Processing raw dataset &i of %trim(%left(&total_datasets)): &&dataset_&i;
              x "echo --------- Processing raw dataset &i of %trim(%left(&total_datasets)): &&dataset_&i";

              * determine if lastupd is available;
              proc sql noprint;
                select count(*) into:column_lastupd
                from vcolumn
                where upcase(libname) = upcase("&download") and upcase(memname) = upcase("&&dataset_&i")
                      and upcase(name) = "LASTUPD"
                ;
                select count(*) into:column_patid
                from vcolumn
                where upcase(libname) = upcase("&download") and upcase(memname) = upcase("&&dataset_&i")
                      and upcase(name) = "PATID"
                ;
              quit;
              
              %if &column_lastupd > 0 %then %do;

                *************************************************************
                * maxLastChangeTime;
                proc sql noprint;
                  update work._manifest_metadata_raw
                  set maxLastChangeTime=(
                    select max(lstchgts_numeric)
                    from (
                      select lastupd as lstchgts_numeric format=e8601dt19.
                      from &download..&&dataset_&i(encoding=WLATIN1)))
                  where fileName = "&&dataset_&i";
                quit;

              %end;
              
              %if &column_patid > 0 %then %do;
              
                *************************************************************
                * noSubjects;
                proc sql noprint;
                  update work._manifest_metadata_raw
                  set noSubjects=(
                    select count(*)
                    from (
                      select distinct patid 
                      from &download..&&dataset_&i(encoding=WLATIN1)))
                  where fileName = "&&dataset_&i";
                quit;
                  
              %end;

            %end; * End Cycle through each dataset;

        %put NOTE:[PXL] SAS work dataset _manifest_metadata_raw created;
            
      %end;
      
      %else %do;
        data _manifest_metadata_raw;
          length 
            sourceData                 $7.                                                              
            Comments                   $91.                                                              
            category                   $12.                                                              
            studyID                    $8.                                                              
            dataSensitivity            $25.                                                              
            loadType                   $10.                                                              
            isDatabaseLock             $5.                                                              
            fileName                   $32.
            dataConformance            $3.                                                              
            dataStandardVer            $4.                                                              
            domainVersion              $4.                                                              
            dataCleanliness            $25.                                                              
            generationTime             8.
            srcSystemExtractionTime    8.
            maxLastChangeTime          8.
            noColumns                  8.
            noOfRows                   8.
            noSubjects                 8.
            medicalEventDictionary     $200.
            drugDictionary             $200.
            Comments2                  $200.
          ;
          delete;
        run;
      %end;
          
  %mend _manifest_getRaw;


  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_dataSensitivity
  * PURPOSE: Get value from global macro dataSensitivity if present, 
  *          otherwise get value from &study_data.dataSensitivity
  *****************************************************************************/
  %macro _manifest_dataSensitivity;
    %put ;		
    %put NOTE:[PXL] Derive dataSensitivity;
    x "echo ------ Derive dataSensitivity";

    * Check if global macro variable dataSensitivity exists;
    %let FLAG1=0;
    proc sql noprint;
      select count(*) into: FLAG1
      from sashelp.vmacro
      where upcase(scope) = "GLOBAL"
            and upcase(name) = "DATASENSITIVITY"
            and VALUE is not null;
    quit;

    %if &FLAG1=0 %then %do;	
      * Since global macro override variable does not exist, get value from metadata;
      proc sql noprint;
        select upcase(dataSensitivity) into: dataSensitivity
        from sacq_md.&study_data;
      quit;
      %put NOTE:[PXL] Global macro override variable DATASENSITIVITY does not exist or is not set,;
      %put NOTE:[PXL] Value of dataSensitivity taken from metadata &study_data;
    %end;
    %else %do;
      %put NOTE:[PXL] Global override variable dataSensitivity exits, value taken from it;
    %end;

    * Value must be valid per CAL Spec V2, check value is in this list;
    options MINOPERATOR;
    %let dataSensitivity_values = SENSITIVE_DATA DUMMY/MASKED_DATA NOT_SENSITIVE_DATA;
    %let dataSensitivity = %left(%trim(&dataSensitivity));
    %if %str("&dataSensitivity") = %str("SENSITIVE_DATA")
        or %str("&dataSensitivity") = %str("DUMMY/MASKED_DATA")
        or %str("&dataSensitivity") = %str("NOT_SENSITIVE_DATA")
        %then %do;
      %put NOTE:[PXL] dataSensitivity = &dataSensitivity;
    %end;
    %else %do;
        %put ;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: dataSensitivity value not valid, check Global macro or &STUDY_DATA value that was used;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: dataSensitivity = &dataSensitivity;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: Valid values are: [SENSITIVE_DATA,DUMMY/MASKED_DATA,NOT_SENSITIVE_DATA];
        %let SEND_TRANSFER = NO, issues found in CSDWManifest.xml, see SAS log;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: SEND_TRANSFER = &SEND_TRANSFER;
        %put ;
        %let GMPXLERR = 1;
        %goto macErr;
    %end;

    %MacErr:;
  %mend _manifest_dataSensitivity;

  
  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_isDatabaseLock
  * PURPOSE: Get value from global macro isDatabaseLock if present, 
	*          otherwise get value from &STUDY_DATA.isDatabaseLock
  *****************************************************************************/
  %macro _manifest_isDatabaseLock;
    %put ;		
    %put NOTE:[PXL] Derive isDatabaseLock;	
    x "echo ------ Derive isDatabaseLock";

    * Check if global macro variable isDatabaseLock exists;
    %let FLAG1=0;
    proc sql noprint;
      select count(*) into: FLAG1
      from sashelp.vmacro
      where upcase(scope) = "GLOBAL"
            and upcase(name) = "ISDATABASELOCK"
            and VALUE is not null;
    quit;

    %if &FLAG1=0 %then %do;	
      * Since global macro override variable does not exist, get value from metadata;
      proc sql noprint;
        select isDatabaseLock into: isDatabaseLock
        from sacq_md.&study_data;
      quit;
      %put NOTE:[PXL] Value of isDatabaseLock taken from metadata &study_data;
    %end;
    %else %do;
      %put NOTE:[PXL] Global override variable isDatabaseLock exits, value taken from it;
    %end;

    * Value must be valid per CAL Spec V2;
    options MINOPERATOR;
    %let isDatabaseLock = %lowcase(&isDatabaseLock); * Force into lower case;
    %let isDatabaseLock_values = true false;
    %if %left(%trim(&isDatabaseLock)) = true
        or %left(%trim(&isDatabaseLock)) = false
        %then %do;
      %put NOTE:[PXL] isDatabaseLock = &isDatabaseLock;
    %end;
    %else %do;
        %put ;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: isDatabaseLock value not valid, check Global macro or &STUDY_DATA value that was used;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: isDatabaseLock = &isDatabaseLock;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: Valid values are: [true,false];
        %let SEND_TRANSFER = NO, issues found in CSDWManifest.xml, see SAS log;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: SEND_TRANSFER = &SEND_TRANSFER;
        %put ;
        %let GMPXLERR = 1;
        %goto macErr;
    %end;

    %MacErr:;
  %mend _manifest_isDatabaseLock;

  
  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_dataCleanliness
  * PURPOSE: dataCleanliness - Get value from global macro isDatabaseLock if present, 
  *          otherwise default to DIRTY
  *****************************************************************************/
  %macro _manifest_dataCleanliness;
    %put ;		
    %put NOTE:[PXL]Derive dataCleanliness;	
    x "echo ------ Derive dataCleanliness";
    
    * Check if global macro variable isDatabaseLock exists;
    %let FLAG1=0;
    proc sql noprint;
      select count(*) into: FLAG1
      from sashelp.vmacro
      where upcase(scope) = "GLOBAL"
            and upcase(name) = "DATACLEANLINESS"
            and VALUE is not null;
    quit;

    %if &FLAG1=0 %then %do;	
      * Since global macro override variable does not exist, default to DIRTY;
      %put NOTE:[PXL] Global macro override variable DATACLEANLINESS does not exist, default dataCleanliness to DIRTY;
      %let dataCleanliness = DIRTY;
    %end;
    %else %do;
      %put NOTE:[PXL] Global override variable dataCleanliness exits, value taken from it;
    %end;

    * Value must be valid per CAL Spec V2;
    options MINOPERATOR;
    %let dataCleanliness_values = CLEAN DIRTY;
    %if %left(%trim(&dataCleanliness)) = CLEAN
        or %left(%trim(&dataCleanliness)) = DIRTY
        %then %do;
      %put NOTE:[PXL] dataCleanliness = &dataCleanliness;
    %end;
    %else %do;
        %put ;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: dataCleanliness value not valid, check Global macro value that was used;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: dataCleanliness = &dataCleanliness;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: Valid values are: [&dataCleanliness_values];
        %let SEND_TRANSFER = NO, issues found in CSDWManifest.xml, see SAS log;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: SEND_TRANSFER = &SEND_TRANSFER;
        %put ;
        %let GMPXLERR = 1;
        %goto macErr;
    %end;

    %MacErr:;
  %mend _manifest_dataCleanliness;	


  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_category
  * PURPOSE: category - Get value from global macro category if present, 
  *          otherwise default to WORKING_DATA
  *****************************************************************************/
  %macro _manifest_category;
    %put ;		
    %put NOTE:[PXL] Derive WORKING_DATA;
    x "echo ------ Derive Working Data";

    * Check if global macro variable category exists;
    %let FLAG1=0;
    proc sql noprint;
      select count(*) into: FLAG1
      from sashelp.vmacro
      where upcase(scope) = "GLOBAL"
            and upcase(name) = "CATEGORY"
            and VALUE is not null;
    quit;

    %if &FLAG1=0 %then %do;	
      * Since global macro override variable does not exist, default to DIRTY;
      %put NOTE:[PXL] Global macro override variable CATEGORY does not exist, default CATEGORY to WORKING_DATA;
      %let category = WORKING_DATA;
    %end;
    %else %do;
      %put NOTE:[PXL] Global override variable category exits, value taken from it;
    %end;

    * Value must be valid per CAL Spec V2;
    options MINOPERATOR;
    %let category_values = WORKING_DATA STUDY_REPORTING_EVENT DRUG_PROGRAM_REPORTING_EVENT;
    %if %left(%trim(&category)) = WORKING_DATA
        or %left(%trim(&category)) = STUDY_REPORTING_EVENT
        or %left(%trim(&category)) = DRUG_PROGRAM_REPORTING_EVENT
        %then %do;
      %put NOTE:[PXL] category = &category;
    %end;
    %else %do;
        %put ;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: category value not valid, check Global macro or &STUDY_DATA value that was used;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: category = &category;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: Valid values are: [&category_values];
        %let SEND_TRANSFER = NO, issues found in CSDWManifest.xml, see SAS log;
        %put %str(ERR)OR:[PXL] PFESACQ_MAP_SCRF_MANIFEST: SEND_TRANSFER = &SEND_TRANSFER;
        %put ;
        %let GMPXLERR = 1;
        %goto macErr;
    %end;

    %MacErr:;
  %mend _manifest_category;	

  
  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_ns1Comments
  * PURPOSE: ns1Comments - Get value from global macro DATABASE_TYPE if present, 
  *          otherwise default to "DataLabs study &protocol"
  *****************************************************************************/
  %macro _manifest_ns1Comments;
    %put ;		
    %put NOTE:[PXL] Derive ns1Comments;		
    x "echo ------ Derive ns1Comments";

    * Check if global macro variable DATABASE_TYPE exists;
    %let FLAG1=0;
    proc sql noprint;
      select count(*) into: FLAG1
      from sashelp.vmacro
      where upcase(scope) = "GLOBAL"
            and upcase(name) = "DATABASE_TYPE"
            and VALUE is not null;
    quit;

    %if &FLAG1=0 %then %do;	
      %put %str(WARN)ING:[PXL] Global Macro DATABASE_TYPE is not present. ;
      %put %str(WARN)ING:[PXL] Value should be set per study under /macros/project_setup.sas as DATALABS or OC.;
      %put %str(WARN)ING:[PXL] Value assumed to be DATALABS;
      %let ns1Comments = DataLabs study &protocol;
    %end;
    %else %do;
      %if %upcase(&DATABASE_TYPE) = DATALABS %then %do;
        %let ns1Comments = DataLabs study &protocol;
      %end;
      %else %do;
        %put %str(WARN)ING:[PXL] Global Macro DATABASE_TYPE value other than DATALABS: &DATABASE_TYPE;
        %put %str(WARN)ING:[PXL] Value should be set per study under /macros/project_setup.sas as DATALABS;
        %put %str(WARN)ING:[PXL] Value assumed to be DATALABS;
        %let ns1Comments = DataLabs study &protocol;
      %end;
    %end;

    %put NOTE:[PXL] Derived ns1Comments as &ns1Comments;	

    %MacErr:;
  %mend _manifest_ns1Comments;									


  /*****************************************************************************
  * DEFINE INTERNAL MACRO _manifest_setDefaults
  * PURPOSE: Create work dataset _manifest_metadata with defaulted information from 
  *          macro variables and sashelp.vtable data
  *****************************************************************************/
  %macro _manifest_setDefaults;
    %put ;		
    %put NOTE:[PXL] Create and set defaults to work dataset _manifest_metadata;
    x "echo ------ Get SACQ Data Information for Manifest from &tarOutput";

    proc sql noprint;
      create table _manifest_metadata as
      select
        "PAREXEL" as sourceData,
        "Created by SAS program PFESACQ_MAP_SCRF.sas, version &version_num &version_date, Encoding set for WLATIN1" as Comments,
        upcase("&category") as category,
        "&protocol" as studyID,
        upcase("&dataSensitivity") as dataSensitivity length=25,
        "CUMULATIVE" as loadType,
        lowcase("&isDatabaseLock") as isDatabaseLock length=5,
        a.memname as fileName,
        "sACQ" as dataConformance,
        /*        
            a.memlabel as dataStandardVer,
            b.memlabel as domainVersion,
        */
        upcase("&dataCleanliness") as dataCleanliness length=25,
        a.crdate as generationTime format=e8601dt19.,
        b.crdate as srcSystemExtractionTime format=e8601dt19.,
        b.crdate as maxLastChangeTime format=e8601dt19.,
        a.nvar as noColumns,
        a.nobs as noOfRows,
        -1 as noSubjects,
        "" as medicalEventDictionary length=200,
        "" as drugDictionary length=200,
        "&ns1Comments" as Comments2 length=200,
        "1.0" as domainVersion length=4,
        "1.0" as dataStandardVer length=4

      from (select * from vtable where upcase(libname) = upcase("&tarOutput")) as a
           inner join
           (select * from vtable where upcase(libname) = upcase("&srcInput")) as b 
      on a.memname = catx("_",b.memname,"SACQ");
    quit;	
    %put NOTE:[PXL] SAS work dataset _manifest_metadata created;

    * Process edata;
    filename dirlist pipe "ls -la &path_edata" ;

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
        select '"' || compress("&path_edata" || datec) || '"' into :_concat separated by ','
        from work._dirlist;
        
        drop table _dirlist;
      quit;

      libname _edata (&_concat);	   		
  %mend _manifest_setDefaults;

	**************************************************************************
    * Macro Process
	**************************************************************************;

		* Local Macros;
    %global path_sacq path_download dataSensitivity isDatabaseLock dataCleanliness category ns1Comments;
    /*
		%let path_sacq= ;
		%let path_download= ;
		%let dataSensitivity= ;
		%let isDatabaseLock= ;
		%let dataCleanliness= ;
		%let category= ;
		%let ns1Comments= ;
    */
    
		* Internal Macro Calls;
		%_manifest_setup;
		%if &GMPXLERR = 1 %then %goto MacErr;

		%_manifest_dataSensitivity;
		%if &GMPXLERR = 1 %then %goto MacErr;

		%_manifest_isDatabaseLock;
		%if &GMPXLERR = 1 %then %goto MacErr;

		%_manifest_dataCleanliness;
		%if &GMPXLERR = 1 %then %goto MacErr;

		%_manifest_category;
		%if &GMPXLERR = 1 %then %goto MacErr;	

		%_manifest_ns1Comments;
		%if &GMPXLERR = 1 %then %goto MacErr;	

		%_manifest_getRaw;
		%if &GMPXLERR = 1 %then %goto MacErr;

		%_manifest_setDefaults;		
		%if &GMPXLERR = 1 %then %goto MacErr;

    
    
    
    
		* Create macro var list of datasets;
		proc sql noprint;
			select count(*) into :total_datasets
			from _manifest_metadata;


			select fileName
			       into :dataset_1-:dataset_%trim(%left(&total_datasets))
			from _manifest_metadata;
		quit;

    

  /*****************************************************************************
  * UPDATE MANIFEST INFORMATION FOR SACQ DATASETS
  *****************************************************************************/
    
		*************************************************************
		* Create macro var list of datasets;
			proc sql noprint;
				select count(*) into :total_datasets
				from _manifest_metadata;

				select fileName
				       into :dataset_1-:dataset_%trim(%left(&total_datasets))
				from _manifest_metadata;
			quit;

		*************************************************************
		* Cycle through each dataset;
		%put NOTE:[PXL] Cycle through each dataset;
		%do i=1 %to &total_datasets;
            %put NOTE:[PXL] ***** Processing SACQ dataset &i of %trim(%left(&total_datasets)): &&dataset_&i;
            x "echo ---------    Processing SACQ dataset &i of %trim(%left(&total_datasets)): &&dataset_&i";

                  * determine if lstchgts is available;
                  proc sql noprint;
                    select count(*) into:column_lstchgts
                    from vcolumn
                    where upcase(libname) = upcase("sacq") and upcase(memname) = upcase("&&dataset_&i")
                          and upcase(name) = "LSTCHGTS"
                    ;
                    select count(*) into:column_pid
                    from vcolumn
                    where upcase(libname) = upcase("sacq") and upcase(memname) = upcase("&&dataset_&i")
                          and upcase(name) = "PID"
                    ;
                  quit;
        
            %if &column_lstchgts > 0 %then %do;
                *************************************************************
                * maxLastChangeTime;
                proc sql noprint;
                    update work._manifest_metadata
                    set maxLastChangeTime=(
                        select max(lstchgts_numeric)
                        from (
                                select input(lstchgts,e8601dt19.) as lstchgts_numeric format=e8601dt19.
                                from &tarOutput..&&dataset_&i(encoding=WLATIN1)
                                where lstchgts is not null)
                        )
                    where fileName = "&&dataset_&i";
                quit;
            %end;
        
            %if &column_pid > 0 %then %do;
              
              *************************************************************
              * noSubjects;
                proc sql noprint;
                  update work._manifest_metadata
                  set noSubjects=(
                    select count(*)
                    from (
                      select distinct PID 
                      from &tarOutput..&&dataset_&i(encoding=WLATIN1)))
                  where fileName = "&&dataset_&i";
                quit;
            %end;
            
            * Update DataStandardVer using _metadata, if any are -999 then sets to -999;
            proc sql noprint;
                update work._manifest_metadata
                set domainVersion=(
                    select min(data_standardver)
                    from _metadata 
                    where sacq_dataset = "&&dataset_&i"
                        )
                where fileName = "&&dataset_&i"
                ;
                
                update work._manifest_metadata
                set dataStandardVer=(
                    select min(data_standardver)
                    from _metadata 
                    where sacq_dataset = "&&dataset_&i"
                        )
                where fileName = "&&dataset_&i"
                ;
                
                select min(data_standardver) into:idataver
                from _metadata
                where sacq_dataset = "&&dataset_&i"
                ;
            quit;
            
            %put NOTE:[PXL] -------------------------------------------------------;
            %put NOTE:[PXL] - For &&dataset_&i - Data Standard Ver set to &idataver;
            %put NOTE:[PXL] -------------------------------------------------------;

        
		%end; * End Cycle through each dataset;

		*************************************************************
		* Set drugDictionary and medicalEventDictionary;
			%put ;
			%put NOTE:[PXL] Set drugDictionary and medicalEventDictionary;
			%put ;

			* medicalEventDictionary - MEDDRA;
			proc sql noprint;
				update work._manifest_metadata
				set medicalEventDictionary=(
                        select event_dict 
                        from sacq_md.study_data
                        where protocol = "&Protocol"
                        )
                where fileName in (
                    select distinct memname 
                    from vcolumn
                    where libname='SACQ' 
                          and name like '%DECD%');
			quit;

			* drugDictionary - WHODRUG;
			proc sql noprint;
				update work._manifest_metadata
				set drugDictionary=(
                        select drug_dict 
                        from sacq_md.study_data
                        where protocol = "&Protocol"
                        )
                where fileName in (
                    select distinct memname 
                    from vcolumn
                    where libname='SACQ' 
                          and name like '%CMCODE%');
			quit;

			proc sql noprint;
				update work._manifest_metadata
				set drugDictionary=catx("_", drugDictionary, compress(left(trim(put(datepart(maxLastChangeTime), yymmdd10.))),'-'))
				where drugDictionary like '%WHO%'
				      and drugDictionary is not null;
			quit;

   
  /*****************************************************************************
  * COMBINE MANIFEST DATA AND OUTPUT XML FILE
  *****************************************************************************/
    %put ;
    %put NOTE:[PXL] Output XML File;
    %put ;
    x "echo ------ Output XML File";

    data _manifest_metadata;
        label
            sourceData              = "sourceData"
            comments                = "Comments"
            category                = "category" 
            studyID                 = "studyID" 
            dataSensitivity         = "dataSensitivity" 
            loadType                = "loadType" 
            isDatabaseLock          = "isDatabaseLock" 
            fileName                = "fileName" 
            dataConformance         = "dataConformance" 
            dataStandardVer         = "dataStandardVer" 
            domainVersion           = "domainVersion" 
            dataCleanliness         = "dataCleanliness" 
            generationTime          = "generationTime" 
            srcSystemExtractionTime = "srcSystemExtractionTime" 
            maxLastChangeTime       = "maxLastChangeTime" 
            noColumns               = "noColumns" 
            noOfRows                = "noOfRows" 
            noSubjects              = "noSubjects" 
            medicalEventDictionary  = "medicalEventDictionary"
            drugDictionary          = "drugDictionary"
            comments2               = "Comments"
        ;

        * STACK SACQ DATASETS AND RAW DATASETS;
        set _manifest_metadata (in=a) 
            _manifest_metadata_raw;
      
        * dataStandardVer Requirement;
        /*
        if a then do;
          %put NOTE:[PXL] domainVersion and dataStandardVer for SACQ datasets set to 1.0 per Pfizer demand;
          domainVersion = '1.0';
          dataStandardVer = '1.0';
        end;
        
        */
        * CAL Spec Requirement;
        fileName = lowcase(fileName);
    run;

    %let ListingName= CSDWManifest;

    * Get path of library SACQ;
    %let path_csdw=;
    proc sql noprint;
        select left(trim(path)) into: path_csdw
        from (
            select distinct path 
             from sashelp.vlibnam
             where upcase(libname)=upcase("&tarOutput"));
    quit;
    %let path_csdw=%left(%trim(&path_csdw));

    %put NOTE:[PXL] ******** Manifest File: "&path_csdw./&ListingName..xml";
    x "echo --------- Manifest File: &path_csdw./&ListingName..xml";

    * OUTPUT MANIFEST FILE;
    data work._null_ ;
        set work._manifest_metadata end=eof ;
        file "&path_csdw./&ListingName..xml" ;
        retain col -1 ;

        if _n_ = 1 then do ; 
        put '<?xml version="1.0" encoding="UTF-8" ?>';
        put ;
        put '<tns:DataManifest';
        put 'sourceData="' sourceData +col'"';
        put 'xmlns:tns="http://www.csdw.cal.cloud.com/CSDWManifest"';
        put 'xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"';
        put 'xsi:schemaLocation="http://www.csdw.cal.cloud.com/CSDWManifest ../../src/com/accenture/lsh/dataload/CSDWManifest.xsd"';
        put 'Comments="' Comments +col'"' ;
        put 'category="' category +col'"' ;
        put 'studyID="' studyID +col'"' ;
        put 'dataSensitivity="' dataSensitivity +col'"' ;
        put 'loadType="CUMULATIVE"' ;
        put 'isDatabaseLock="' isDatabaseLock +col '">' ;
        end ; * End _n_ = 1;

        put / '<tns:DataFile' ;
        put 'fileName="' filename +col '.xpt" ' ; 
        put 'dataConformance="' dataConformance +col '"' ;
        put 'dataStandardVer="' dataStandardVer +col '"' ;
        put 'domainVersion="' domainVersion +col '"' ;
        put 'dataCleanliness="' dataCleanliness +col '"' ;
        put 'generationTime="' generationTime IS8601DT. '"' ;
        put 'srcSystemExtractionTime="' srcSystemExtractionTime IS8601DT. '"' ;
        put 'maxLastChangeTime="' maxLastChangeTime IS8601DT. '"' ;
        put 'noColumns="' noColumns +col '"' ;
        put 'noOfRows="' noOfRows +col '"' ;
        if missing(medicalEventDictionary) and missing(drugDictionary) then 
          put 'noSubjects="' noSubjects +col '">' ;
        else if missing(medicalEventDictionary) and not missing(drugDictionary) then do;
          put 'noSubjects="' noSubjects +col '"' ;
          put 'drugDictionary="' drugDictionary +col '">' ;
        end;
        else if not missing(medicalEventDictionary) and missing(drugDictionary) then do;
          put 'noSubjects="' noSubjects +col '"' ;
          put 'medicalEventDictionary="' medicalEventDictionary +col '">' ;
        end;
        else do;
          put 'noSubjects="' noSubjects +col '"' ;
          put 'medicalEventDictionary="' medicalEventDictionary +col '">' ;
          put 'drugDictionary="' drugDictionary +col '">' ;
        end;
          put '<tns:Comments>' comments2 +col '</tns:Comments>' ;
          put '</tns:DataFile>';
          ;

        if eof then do ;
          put ;
          put '</tns:DataManifest>' ;
        end ;
    run ;

	%goto macend;

    %macerr:;
    %put %str(ERR)OR:[PXL]---------------------------------------------------------------------;
    %put %str(ERR)OR:[PXL] Abnormal end to macro, CSDWManifest not created, ;
    %put %str(ERR)OR:[PXL] Zip file will not be posted for Pfizer CAL;
    %put %str(ERR)OR:[PXL]---------------------------------------------------------------------;	

    %macend:;

    * clean up;
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
      %dellib(libn=_edata);   

      %macro delmac(wds=null);
          %if %sysfunc(exist(&wds)) %then %do; 
              proc datasets lib=work nolist; delete &wds; quit; run; 
          %end; 
      %mend delmac;
      %delmac(wds=vcolumn);
      %delmac(wds=vtable);

    options NOMINOPERATOR nonotes;
 
		%_Section(message=Create CSDWManifest.xml from SACQ datasets Completed);


%mend pfesacq_map_scrf_manifest;


/*
dm"log;clear;"; proc datasets lib=work kill nolist memtype=data; quit;

%let path_root=/projects/std_pfizer/sacq/program/test/;
libname sacq_md '/projects/std_pfizer/sacq/metadata/data';
libname download "&path_root/download";
libname scrf "&path_root/scrf";
libname sacq "&path_root/sacq";
*/
/* %let cdatetime=20150101T010101; */
/*
%let tarOutput=sacq;
%let srcInput=scrf;
%let download=download;
%let path_edata=&path_root/e_data/datasets/;
%let send_transfer=NO, TESTING=YES;
%let study_data=study_data;
%let version_num=2.1;
%let version_date=20150408;

%global;
%let DEBUG=0;
%let GMPXLERR=0;

data download.dm;
	a=1;
run;

data download.ae;
run;



%pfesacq_map_scrf_manifest;
*/
