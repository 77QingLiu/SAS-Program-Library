/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX
  Example Call:          Note: Part of program: pfesacq_map_scrf 
               
                         Called from parent macro pfesacq_map_scrf:
                         %pfesacq_map_scrf_listing;

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley, Nathan Johnson, $LastChangedBy: hartlen $
  Creation Date:         12FEB2015                       $LastChangedDate: 2016-01-28 14:38:18 -0500 (Thu, 28 Jan 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfesacq_map_scrf_listing.sas $
 
  Files Created:         None
 
  Program Purpose:       Create Mapping Info and Exceptions Listing
 
                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Sources:
 
    1) SRCINPUT - SAS library for source CSDW SCRF datasets
    2) TAROUTPUT - SAS library for created SACQ datasets
    3) Work SAS dataset Listing_TAB4 - Created per macro pfesacq_map_scrf_listing
    4) Work SAS dataset Listing_TAB5 - Created per macro pfesacq_map_scrf_listing
    5) Macro variable SEND_TRANSFER - set in parent macro pfesacq_map_scrf to YES 
       or NO depending on input macro variable TESTING
    6) SACQ_MD - SAS library for source SACQ metadata data (created from 
       pfesacq_map_input_checks from parent macro input parameter SACQ_METADATA)
 
  Macro Output:     

    Name:                Pfizer &Pxl_Code %upcase(&Protocol) SACQ Transfer 
                         Information and Exceptions Listing.xls 
      Type:              XML File
      Allowed Values:    N/A
      Default Value:     N/A
      Description:       Saved to same output location as SACQ datasets, 
                         specifies transfer information, issues, differences
                         from last transfer

  Macro Dependencies:    This is a submacro dependant on calling parent macro: 
                         pfesacq_map_scrf.sas

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1760 $

Version: 1.0 Date: 26MAR2015 Author: Nathan Hartley
    1) Update to not save transfer_data file when input parameter ‘TESTING=YES’

Version: 2.0 Date: 19JUN2015 Author: Nathan Johnson
    1) Provide user feedback to UNIX standard output during runtime

Version: 3.0 Date: 29JUN2015 Author: Nathan Johnson
    1) Added raw data information to listing TAB 1.
    
Version: 4.0 Date: 18SEP2015 Author: Nathan Johnson
    1) Modified Tab 3 to only contain domains found in the SCRF data
    2) Create Tab 7 to contain variable name changes to raw data
    
Version: 5.0 Date: 20160104 Author: Nathan Hartley    
    1) Updated Listing_TAB6 to show differences

Version: 6.0 Date: 20160127 Author: Nathan Hartley
    1) Added TAB3 MAPPED, CODELIST_FORMAT, CODELIST_ROOT, and UIMS columns
    2) Changed DEFAULTED_COLUMN_WIDTH to ABSOLUTE_COLUMN_WIDTH
    3) Updated TAB6 variable list

Version: 7.0 Date: 20160128 Author: Nathan Hartley
    1) Changed MAPPED to M_MAPPED for filtering SACQ mapped records

-----------------------------------------------------------------------------*/

%macro pfesacq_map_scrf_listing;
    %put ---------------------------------------------------------------------;
    %put PFESACQ_MAP_SCRF_LISTING: Start of Submacro;
    %put ---------------------------------------------------------------------;

    %* OPTION MPRINT MLOGIC SYMBOLGEN SOURCE NOTES;
        %let prev_tran = ;
        %let tab1_ref = None Found; %* Differences/First Transfer message;
        %let tab1_ref_n = 0; %* Number of differences;

    ***************************************************************************
    * CHECK FOR EXISTENCE OF TAB DATASETS;

      %let listing_TAB4 = 
        issue              length=   8 label="Issue #"
        issue_id           length=$200 label="Issue ID"
        priority           length=$200 label="Issue Priority"
        desc               length=$200 label="Issue Description"
        scrf_dataset       length=$200 label="SCRF Dataset"
        scrf_dataset_label length=$256 label="SCRF Dataset Label"
        scrf_variable      length=$200 label="SCRF Variable"
        scrf_type          length=$200 label="SCRF Type"
        scrf_length        length=   8 label="SCRF Length"
        scrf_format        length=$200 label="SCRF Format"
        scrf_label         length=$256 label="SCRF Label"
        sacq_dataset       length=$200 label="SACQ Dataset"
        sacq_variable      length=$200 label="SACQ Variable"
        sacq_core          length=$200 label="SCRF Core"
        sacq_type          length=$200 label="SCRF Type"
        sacq_length        length=   8 label="SCRF Length"
        sacq_format        length=$200 label="SCRF Format"
        sacq_codelist      length=$200 label="SCRF Codelist"
        sacq_label         length=$256 label="SCRF Label";

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

        
    %macro _dscheck(ds);
      %put *********** Checking for dataset &ds;
      proc sql noprint;
        select count(*) into:dscheck
        from sashelp.vtable where libname = "WORK" and upcase(memname) = upcase("&ds")
        ;
      quit;
      
      data _null_;
        count = &dscheck;
        if count = 0 then exist = 0;
        else exist = 1;
        call symputx('dsexist',exist);
      run;
      
      %if &dsexist = 0 %then %do;
        %put *********** Create dataset &ds;
        data &ds;
          attrib &&&ds;
          delete;
        run;
      %end;
    %mend;
    
    %_dscheck(Listing_TAB4);
    %_dscheck(Listing_TAB5);
    
    ***************************************************************************
    * Derive used information;
    x "echo ------ Derive Listing File Information";
        %let ListingName= Pfizer &Pxl_Code %upcase(&Protocol) SACQ Transfer Information and Exceptions Listing;
        %let ListingTitle= &ListingName;

        * Get path of library SACQ;
        proc sql noprint;
            select left(trim(path)) into: path_scrf
            from (
                select distinct path 
                from sashelp.vlibnam
                where upcase(libname)=upcase("&srcInput"));

            select left(trim(path)) into: path_sacq
            from (
                select distinct path 
                from sashelp.vlibnam
                where upcase(libname)=upcase("&tarOutput"));
                
            select left(trim(path)) into: path_download
            from (
                select distinct path 
                from sashelp.vlibnam
                where upcase(libname)=upcase("&download"));
        quit;
        %let path_scrf=%left(%trim(&path_scrf));
        %let path_sacq=%left(%trim(&path_sacq));
        %let path_download=%left(%trim(&path_download));

        %global sn sw se vn vw ve;
        proc sql noprint;
            select count(*) into: sn
            from Listing_TAB4
            where priority = "NOTE";

            select count(*) into: sw
            from Listing_TAB4
            where priority = "%str(WARN)ING";

            select count(*) into: se
            from Listing_TAB4
            where priority = "%str(ERR)OR";

            select count(*) into: vn
            from Listing_TAB5
            where priority = "NOTE";

            select count(*) into: vw
            from Listing_TAB5
            where priority = "%str(WARN)ING";

            select count(*) into: ve
            from Listing_TAB5
            where priority = "%str(ERR)OR";
        quit;
        %let total_s = %eval(&sn + &sw + &se);
        %let total_v = %eval(&vn + &vw + &ve);
        %let total = %eval(&total_s + &total_v);

        * If any %str(ERR)OR issues found then do not send zip file to CAL for Pfizer transfer!; 
        %if &send_transfer = YES and ( %eval(&se > 0) or %eval(&ve > 0)) %then %do;
            %let send_transfer = NO, Transfer not sent if %str(ERR)OR Issues found;
            %put %str(ERR)OR:[PXL] Issues found, zip file will not be posted to CAL;
        %end;
        %else %do;
            %put send_transfer = &send_transfer ;
        %end;

        %global count_raw_datasets count_Transfer_records sacq_version codelist_version; * used in output to transfer_log;
        proc sql noprint;
            select memlabel into: sacq_version 
            from sashelp.vtable 
            where libname = upcase("SACQ_MD")
                  and memname = upcase("&sacq");

            select memlabel into: codelist_version
            from sashelp.vtable
            where libname = upcase("SACQ_MD")
                  and memname = upcase("codelists");

            select count(*) into: count_Transfer_records
            from _manifest_metadata
            where index(upcase(filename),"_SACQ");
            
            select count(*) into :count_raw_datasets 
            from sashelp.vtable 
            where upcase(libname) = upcase("&download") and nobs > 0;
        quit;



    ***************************************************************************
    * Listing Setup;
    x "echo ------ Lisitng File Setup";

        * Set file name as xls even though tagsets.excelxp creates an XML doc;
        ods listing close;

        ods tagsets.excelxp file= "&path_sacq./&ListingName._&cdatetime..xls";

        * Set titles and footnotes;
        title;
        title1 justify=left "&ListingTitle";
        footnote1 j=l "PAREXEL International Confidential";
        footnote2 j=l "Produced by %upcase(&sysuserid) on &sysdate9";

        data no_obs;
            issue = "Clean Run: No Issues Found.";
        run;

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
                WIDTH_FUDGE = "0.75");

    ***************************************************************************
    * Listing_TAB3;
        data Listing_TAB3a(drop=has_uims_variables);
            length UIMS $3.;
            label
                M_DATASET = "DATASET"
                M_VARIABLE = "VARIABLE"
                M_MAPPED = "MAPPED"

                scrf_dataset = "SCRF Dataset"
                scrf_dataset_label = "SCRF Dataset Label"
                scrf_variable = "SCRF Variable"
                scrf_type = "SCRF Type"
                scrf_length = "SCRF Length"
                scrf_format = "SCRF Format"
                scrf_label = "SCRF Label"

                sacq_dataset = "SACQ Dataset"
                sacq_variable = "SACQ Variable"
                sacq_core = "SACQ Core"
                sacq_type = "SACQ Type"
                sacq_length = "SACQ Length"
                sacq_format = "SACQ Format"
                sacq_codelist_standard = "SACQ Codelist Standard"
                sacq_codelist = "SACQ Codelist"
                sacq_codelist_format = "SACQ Codelist Format"
                sacq_codelist_root = "SACQ Codelist Root"
                sacq_label = "SACQ Label"
                UIMS = "UIMS -999"
            ;
            set _metadata;
            if has_uims_variables = 1 then UIMS = "YES";
        run;

        * limit TAB3 to domains that are part of the SCRF data;
        proc sql;
          create table Listing_TAB3 as
          select * 
          from Listing_TAB3a
          where sacq_dataset in
                          (select distinct sacq_dataset from _metadata
                           where scrf_dataset ne "")
           ;
        quit;

    %***************************************************************************
    * Listing_TAB6
        PURPOSE: Get list of differences between this transfer and previous
        INPUT:
            1) Macro Variables
                1) PROTOCOL - holds study protocol number
                2) VERSION - holds version of SACQ spec used
                3) CDATETIME - holds current datetime of macro run
            2) SAS Libraries
                1) TRANSDAT - transfer log directory that holds each transfer metadata SAS datasets
                   Format of saved dataset name = &PROTOCOL_<datetime>
            3) Work Datasets
                1) Listing_TAB3 - Contains list of metadata of current transfer
        OUTPUT: 
            1) Work Datasets
                1) Listing_TAB6 - Contains list of differences found
            2) Archive current metadata if not TESTING and no ERRORS - TRANSDAT.&PROTOCOL_&CDATETIME 
        ;
        %macro Derive_Listing_TAB6(
            inMV_PROTOCOL=null,
            inMV_VERSION=null,
            inMV_CDT=null,
            inMV_Err=null,
            inLib_Transfers=null,
            inDS_CurrentMetadata=null,
            outDS_Differences=null
            );

            OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR SOURCE NOTES;

            %local inLib_Transfers_Path;
            proc sql noprint;
                select path into: inLib_Transfers_Path
                from sashelp.vlibnam 
                where libname = "%upcase(&inLib_Transfers)";
            quit;

            %put INFO:[PXL]---------------------------------------------------------------------;
            %put INFO:[PXL] PFESACQ_MAP_SCRF_LISTING > DERIVE_LISTING_TAB6: Start of Macro;
            %put INFO:[PXL] ;
            %put INFO:[PXL] PURPOSE: ;
            %put INFO:[PXL]    1) Derive differences from last transfer;
            %put INFO:[PXL]    2) Save current transfer metadata to log archive;
            %put INFO:[PXL] ;
            %put INFO:[PXL] INPUT: ;
            %put INFO:[PXL]    1) inMV_PROTOCOL= &inMV_PROTOCOL;
            %put INFO:[PXL]    2) inMV_VERSION= &inMV_VERSION;
            %put INFO:[PXL]    3) inMV_CDT= &inMV_CDT;
            %put INFO:[PXL]    4) inMV_Err= &inMV_Err;
            %put INFO:[PXL]    5) inLib_Transfers= &inLib_Transfers;
            %put INFO:[PXL]       Full Path= &inLib_Transfers_Path;
            %put INFO:[PXL]    6) inDS_CurrentMetadata= &inDS_CurrentMetadata;
            %put INFO:[PXL]    7) outDS_Differences= &outDS_Differences;
            %put INFO:[PXL] ;
            %put INFO:[PXL] OUTPUT: ;
            %put INFO:[PXL]    1) Work Dataset - &outDS_Differences;
            %put INFO:[PXL]    2) Saved Dataset - &inLib_Transfers..&inDS_CurrentMetadata;
            %put INFO:[PXL]    3) Macro Variable - tab1_ref;
            %put INFO:[PXL]    4) Macro Variable - &tab1_ref_n;
            %put INFO:[PXL]---------------------------------------------------------------------;

            %* Macro Variables;
                %let current_transfer_metadata = %lowcase(&protocol._&cdatetime); %* Name for current transfer metadata to save if not TESTING=Y;
                %let previous_transfer_metadata = None Found/First Transfer; %* Will hold previous transfer SAS dataset name if exists;
                %let tab1_ref = None Found; %* Differences/First Transfer message;
                %let tab1_ref_n = 0; %* Number of differences;                

            %* Set and save current transfer metadata to transfer log location;
                data work.current_transfer_metadata;
                    attrib SACQ_DATASET_LABEL length=$200 label="SACQ Specification Version";
                    set &inDS_CurrentMetadata;
                    if not missing(SACQ_DATASET) then SACQ_DATASET_LABEL = compress(tranwrd(symget("inMV_VERSION"), '_', '.'), 'vV'); 
                    else SACQ_DATASET_LABEL = '';
                run;

            %* Check if previous transfer file exists;
                %local exist_prev;
                proc sql noprint;
                    select count(*) into: exist_prev
                    from (select distinct libname, memname from sashelp.vtable) 
                    where upcase(libname) = "%upcase(&inLib_Transfers)"
                          and substr(upcase(memname), 1, 8) = upcase("&inMV_PROTOCOL");
                quit;
                %put NOTE:[PXL] Number of existing previous transfers: %left(%trim(&exist_prev));

                %if &exist_prev > 0 %then %do;
                    %* Get previous transfer metadata dataset name;
                    proc sql noprint;
                        select max(memname) into: previous_transfer_metadata
                        from (select distinct libname, memname from sashelp.vtable) 
                        where upcase(libname) = "%upcase(&inLib_Transfers)"
                              and substr(upcase(memname), 1, 8) = upcase("&inMV_PROTOCOL")
                        order by 1;
                    quit;
                    %put Previous recorded transfer is &previous_transfer_metadata;

                    %* Filter for only mapped SACQ data where changes matter:
                       1) SACQ_DATASET
                       2) SACQ_VARIABLE
                       3) SACQ_LENGTH
                       4) SACQ_LABEL
                    ;
                    %macro VarExist(ds,var); 
                        %local rc dsid result; 
                        %let dsid=%sysfunc(open(&ds)); 
                        %if %sysfunc(varnum(&dsid,&var)) > 0 %then %do; 
                            %let result=1; 
                        %end; 
                        %else %do; 
                            %let result=0; 
                        %end; 
                        %let rc=%sysfunc(close(&dsid));
                        &result 
                    %mend VarExist; 

                    %* Update to V11 adds MAPPED column to matedata, only want mapped SACQ data;
                    data prev(keep= SACQ_DATASET SACQ_VARIABLE SACQ_LENGTH SACQ_LABEL);
                    set &inLib_Transfers..&previous_transfer_metadata;
                        if (not missing(SCRF_VARIABLE) and not missing(SACQ_VARIABLE))
                        %if %VarExist(&inLib_Transfers..&previous_transfer_metadata,M_MAPPED) %then %do; or M_MAPPED="YES" %end;
                        then output;
                    run;

                    data cur(keep= SACQ_DATASET SACQ_VARIABLE SACQ_LENGTH SACQ_LABEL);
                    set current_transfer_metadata;
                        if (not missing(SCRF_VARIABLE) and not missing(SACQ_VARIABLE))
                        %if %VarExist(current_transfer_metadata,M_MAPPED) %then %do; or M_MAPPED="YES" %end;
                        then output;                  
                    run;

                    %* Get differences;
                    proc sql noprint;
                        %* Previous dataset not in current;
                        create table _D1 as 
                        select "Dataset Dropped" as DIFF, 
                               "PREVIOUS" as SOURCE,
                               a.SACQ_DATASET as SACQ_DATASET
                        from (select distinct SACQ_DATASET from prev) as a 
                             full outer join 
                             (select distinct SACQ_DATASET from cur) as b 
                        on a.SACQ_DATASET = b.SACQ_DATASET
                        where b.SACQ_DATASET is null;

                        %* Current dataset not in previous;
                        create table _D2 as 
                        select "Dataset Added" as DIFF, 
                               "CURRENT" as SOURCE,
                               b.SACQ_DATASET as SACQ_DATASET
                        from (select distinct SACQ_DATASET from prev) as a 
                             full outer join 
                             (select distinct SACQ_DATASET from cur) as b 
                        on a.SACQ_DATASET = b.SACQ_DATASET
                        where a.SACQ_DATASET is null;

                        %* Previous variable not in current;
                        create table _D3 as 
                        select "Variable Dropped" as DIFF,
                               "PREVIOUS" as SOURCE,
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

                        %* Current variable not in previous;
                        create table _D4 as 
                        select "Variable Added" as DIFF,
                               "CURRENT" as SOURCE,
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

                        %* Attrib differences;
                        create table _D5 as 
                        select "Attrib Differences" as DIFF,
                               "PREVIOUS" as SOURCE,
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

                        create table _D6 as 
                        select "Attrib Differences" as DIFF,
                               "CURRENT" as SOURCE,
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

                    data &outDS_Differences;
                        attrib 
                            DIFF length=$200 label="Differences"
                            SOURCE length=$200 label="Source"
                            SACQ_DATASET length=$200 label="Dataset"
                            SACQ_VARIABLE length=$200 label="Variable"
                            SACQ_LENGTH length=8. label="Length"
                            SACQ_LABEL length=$200 label="Label"
                        ;
                        set _D1 _D2 _D3 _D4 _D5 _D6;
                    run;
                    proc sort data = &outDS_Differences; by SACQ_DATASET SACQ_VARIABLE decending SOURCE; run;

                    proc sql noprint;
                        select count(*) into: tab1_ref_n
                        from &outDS_Differences;
                    quit;

                    %let tab1_ref = Differences between %upcase(&current_transfer_metadata) and %upcase(&previous_transfer_metadata) = %left(%trim(&tab1_ref_n));

                    %if &tab1_ref_n = 0 %then %do;
                        data &outDS_Differences;
                            DIFF = "No Differences Found.";
                        run;                        
                    %end;
                %end;
                %else %do;
                    %put NOTE:[PXL] No previous transfer metadata found / first transfer;
                    %let tab1_ref = First Transfer - No Comparison for %upcase(&current_transfer_metadata) Data;
                    %let tab1_ref_n = 0;

                    data &outDS_Differences;
                        attrib DIFF length=$200 label="Differences";
                        DIFF = "No Differences Found.";
                    run;
                %end;

            %* Save current transfer metadata;
                %local archived_metadata;                
                %if "&TESTING" = "YES" %then %do;
                    %put NOTE:[PXL] Input Parameter TESTING=YES - Current Metadata Not saved &inLib_Transfers..&current_transfer_metadata;
                    %let archived_metadata = NO as Input Parameter TESTING=YES;
                %end;
                %else %if %eval(&inMV_Err = 0) %then %do;
                    %put NOTE:[PXL] Input Parameter TESTING=NO - Current Metadata Saved &inLib_Transfers..&current_transfer_metadata;
                    data &inLib_Transfers..&current_transfer_metadata; set work.current_transfer_metadata; run;
                    %let archived_metadata = YES;
                %end;
                %else %do;
                    %put NOTE:[PXL] Input Parameter TESTING=NO but Number of ERRORS = %left(%trim(&inMV_Err)) > 0 - Current Metadata Not saved &inLib_Transfers..&current_transfer_metadata;
                    %let archived_metadata = NO as ERRORS found in transfer;
                %end;

            %put ;
            %put INFO:[PXL] --------------------------------------------------------------------------;
            %put INFO:[PXL] Current Transfer: &current_transfer_metadata;
            %put INFO:[PXL] Previous Transfer: &previous_transfer_metadata;
            %put INFO:[PXL] Differences Found Message: &tab1_ref;
            %put INFO:[PXL] Found SACQ Transfer Attribute Differences =  %left(%trim(&tab1_ref_n));
            %put INFO:[PXL] Archived Current Transfer Metadata = &archived_metadata;
            %put INFO:[PXL] Created Work Output Dataset = &outDS_Differences;
            %put INFO:[PXL] --------------------------------------------------------------------------;
            %put ;   
            %put INFO:[PXL] --------------------------------------------------------------------------;
            %put INFO:[PXL] PFESACQ_MAP_SCRF_LISTING > DERIVE_LISTING_TAB6: End of Macro;
            %put INFO:[PXL] --------------------------------------------------------------------------;
            %put ;

        %mend Derive_Listing_TAB6;

        %let total_err = %eval(&se + &ve); %* Used to determine if to save current metadata or not;

        %Derive_Listing_TAB6(
            inMV_PROTOCOL=&protocol,
            inMV_VERSION=&version,
            inMV_CDT=&cdatetime,
            inLib_Transfers=TRANSDAT,
            inDS_CurrentMetadata=Listing_TAB3,
            inMV_Err=&total_err,
            outDS_Differences=Listing_TAB6
            );

    ***************************************************************************
    * Listing_TAB1;

        data Listing_TAB1;
            attrib
                ti length=$200. label="Transfer Information"
                tiv length=$200. label="Transfer Information Values"
            ;

            ti = "Listing Name:"; tiv = "&ListingName._&cdatetime..xls"; output;
            ti = "Run Date and Time:"; tiv = "&cdatetimen"; output; 
            ti = "Run By: "; tiv = "&sysuserid"; output;  

            ti = ""; tiv = ""; output;
            ti = "Run Macro:"; tiv = "pfesacq_map_scrf"; output;  
            ti = "Run Version:"; tiv = "&version_num"; output;
            ti = "Run Version Date:"; tiv = "&version_date"; output; 
            ti = "Run Macro Location:"; tiv = "&version_path"; output; 

            ti = ""; tiv = ""; output; 
            ti = "Study PXL Code:"; tiv = "&Pxl_Code"; output;   
            ti = "Study PFE Code:"; tiv = "%upcase(&Protocol)"; output; 

            ti = ""; tiv = ""; output;  
            ti = "Input:"; tiv = ""; output; 
            ti = "SCRF Libname Path:"; tiv = "&path_scrf"; output;   
            ti = "Download Libname Path:"; tiv = "&path_download"; output;   
            ti = ""; tiv = ""; output;  
            ti = "SACQ Specification:"; tiv = "&sacq_metadata/&sacq..sas7bdat"; output; 
            ti = "SACQ Specification Version:"; tiv = "&sacq_version"; output; 
            ti = "Codelist Specification:"; tiv = "&sacq_metadata/&codelists..sas7bdat"; output;  
            ti = "Codelist Specification Version:"; tiv = "&codelist_version"; output;  

            ti = ""; tiv = ""; output;
            ti = "Output:"; tiv = ""; output;
            ti = "SACQ Dataset Output Path:"; tiv = "&path_sacq"; output;
            ti = "Number of SACQ Output Datasets:"; tiv = "&count_Transfer_records"; output;
            ti = "Number of Raw Datasets:"; tiv = "&count_raw_datasets"; output;
            ti = "Listing Output Path:"; tiv = "&path_sacq"; output;
            ti = "Zip File Name:"; tiv = "PAREXEL_&protocol._ClinicalStudyGeneral_&cdatetime..zip"; output;


            ti = ""; tiv = ""; output;
            ti = "SACQ Transferred to Pfizer?"; tiv = "&send_transfer"; output;
            ti = "SACQ Structure Differences From Last Transfer:"; tiv = "&tab1_ref"; output;
            ti = "Exception Issues (Structure and Value) Total:"; tiv = "&total"; output;
              

            ti = ""; tiv = ""; output;
            ti = "Structure issues Total:"; tiv = "&total_s"; output;
            ti = "Structure issues NOTES:"; tiv = "&sn"; output;
            ti = "Structure issues WARNINGS:"; tiv = "&sw"; output;
            ti = "Structure Issues ERRORS:"; tiv = "&se"; output;

            ti = ""; tiv = ""; output;
            ti = "Value Issues Total:"; tiv = "&total_v"; output;
            ti = "Value Issues NOTES:"; tiv = "&vn"; output;
            ti = "Value Issues WARNINGS:"; tiv = "&vw"; output;                                    
            ti = "Value Issues ERRORS:"; tiv = "&ve"; output;     
                 
        run;

    ***************************************************************************
    * TAB1 Output;
    x "echo ------ Output TAB1: Transfer Information";
        ods tagsets.excelxp options ( sheet_name = "Transfer Information" ABSOLUTE_COLUMN_WIDTH= "40, 80" );
        proc report data= Listing_TAB1 style(column)={tagattr='Format:Text'};
            column ti tiv;
        run;

    ***************************************************************************
    * TAB2 Output;
    x "echo ------ Output TAB2: Transfer Records";

        data Listing_TAB2(keep=fileName dataStandardVer domainVersion dataCleanliness isDatabaseLock dataSensitivity 
            generationTime srcSystemExtractionTime maxLastChangeTime noColumns noOfRows noSubjects);
            attrib
                fileName label = "Dataset Name"
                dataStandardVer label = "SACQ Version"
                domainVersion label = "CRF Module Version"
                dataCleanliness label = "Data Cleanliness"
                isDatabaseLock label = "Database Locked"
                dataSensitivity label = "Data Sensitivity"
                generationTime label = "SACQ Dataset Created DateTime"
                srcSystemExtractionTime label = "SCRF Dataset Created DateTime"
                maxLastChangeTime label = "Last Change DateTime"
                noColumns label = "Number of Columns"
                noOfRows label = "Number of Rows"
                noSubjects label = "Number of Unique Subjects"
            ;
        set _manifest_metadata;
        run;

        ods tagsets.excelxp options ( sheet_name = "Transfer Records" ABSOLUTE_COLUMN_WIDTH= "15" );
        proc report data= Listing_TAB2 style(column)={tagattr='Format:Text'};
        run;    

    ***************************************************************************
    * TAB3 Output;
    x "echo ------ Output TAB3: Metadata";
        data no_obs;
            issue = "Records Found.";
        run;
        proc sql noprint;
            select count(*) into : nobs
            from Listing_TAB3;
        quit;   
        ods tagsets.excelxp options ( sheet_name = "Metadata" );
        %if &nobs = 0 %then %do;
            ods tagsets.excelxp options ( Default_column_width= "100" );
            proc report data= no_obs style(column)={tagattr='Format:Text'};
                column issue;
            run;
        %end;
        %else %do;
            ods tagsets.excelxp options ( 
                ABSOLUTE_COLUMN_WIDTH= "15,15,15,15,15,15,15,15,15,35,15,15,15,15,15,17,15,16,15,15,35,15"
                frozen_headers = "4" 
                row_repeat = "4");

            proc report data= Listing_TAB3 style(column)={tagattr='Format:Text'};
                column M_DATASET M_VARIABLE M_MAPPED
                ("SCRF Metadata" scrf_dataset scrf_dataset_label scrf_variable scrf_type scrf_length 
                scrf_format scrf_label)
                ("SACQ Metadata" sacq_dataset sacq_variable sacq_core sacq_type sacq_length sacq_format
                sacq_codelist_standard sacq_codelist sacq_codelist_format sacq_codelist_root sacq_label UIMS);
            run;
        %end; 

    ***************************************************************************
    * TAB 4 - Structure Exceptions Output;
    x "echo ------ Output TAB4: Structure Exceptions";

        data no_obs;
            issue = "Clean Run: No Issues Found.";
        run;
        proc sql noprint;
            select count(*) into : nobs
            from Listing_TAB4;
        quit;
        ods tagsets.excelxp options ( frozen_headers = "3" row_repeat = "3" sheet_name = "Structure Exceptions" );
        %if &nobs = 0 %then %do;
            ods tagsets.excelxp options ( Default_column_width= "100" );
            proc report data= no_obs style(column)={tagattr='Format:Text'};
                column issue;
            run;
        %end;
        %else %do;
            ods tagsets.excelxp options ( ABSOLUTE_COLUMN_WIDTH= "8, 8, 8, 25, 10, 8, 10, 8, 8, 10, 20, 10, 10, 10 ,10, 10, 10, 10, 20" );
            proc report data= Listing_TAB4 style(column)={tagattr='Format:Text'};
                column issue issue_id priority desc scrf_dataset scrf_dataset_label 
                    scrf_variable scrf_type scrf_length scrf_format scrf_label 
                    sacq_dataset sacq_variable sacq_core sacq_type sacq_length 
                    sacq_format sacq_codelist sacq_label;
            run;
        %end;

    ***************************************************************************
    * TAB 5 - Value Exceptions Output;
    x "echo ------ Output TAB5: Value Exceptions";

        proc sql noprint;
            select count(*) into : nobs
            from Listing_TAB5;
        quit;
        ods tagsets.excelxp options ( sheet_name = "Value Exceptions" );
        %if &nobs = 0 %then %do;
            ods tagsets.excelxp options ( Default_column_width= "100" );
            proc report data= no_obs style(column)={tagattr='Format:Text'};
                column issue;
            run;
        %end;
        %else %do;
            ods tagsets.excelxp options ( ABSOLUTE_COLUMN_WIDTH= "8, 8, 10, 15, 25, 15, 10, 10, 20, 20" );
            proc report data= Listing_TAB5 style(column)={tagattr='Format:Text'};
                column issue issue_id priority desc desc_info key scrf_dataset scrf_variable
                    scrf_variable_value sacq_variable_value;
            run;
        %end;

    ***************************************************************************
    * TAB 6 - Differences from last transfer Output;
    x "echo ------ Output TAB6: Differences Report";
    
        title2 justify=left "&tab1_ref";

        data no_obs;
            attrib issue length=$200 label="Differences";
            issue = "No Differences Found.";
        run;
        ods tagsets.excelxp options ( sheet_name = "Differences Report" );  
        %let nobs = 0;
        proc sql noprint;
            select count(*) into: nobs 
            from Listing_TAB6;
        quit;
        data null;
            set Listing_TAB6;
            if _n_ =1 and DIFF = "No Differences Found." then 
                call symput("nobs",'0');
        run;
        %if %eval(&nobs = 0) %then %do;
            ods tagsets.excelxp options ( ABSOLUTE_COLUMN_WIDTH= "100" frozen_headers = "4" row_repeat = "4");
            proc report data= no_obs style(column)={tagattr='Format:Text'};
                column issue;
            run;
        %end;
        %else %do;
            ods tagsets.excelxp options ( ABSOLUTE_COLUMN_WIDTH= "15" frozen_headers = "4" row_repeat = "4");
            proc report data= Listing_TAB6 style(column)={tagattr='Format:Text'};
                column DIFF SOURCE SACQ_DATASET SACQ_VARIABLE SACQ_LENGTH SACQ_LABEL;
            run;
        %end; 

        
    ***************************************************************************
    * TAB 7 - Raw Data Variable Changes;
    
    x "echo ------ Output TAB7: Raw Data Variable Report";

        title2 justify=left "Raw Dataset Variables That Were Renamed";


        * CHECK FOR RAW DATASETS;
        %let total_raw_datasets = 0;
        proc sql noprint;
            select count(*) into :total_raw_datasets 
            from sashelp.vtable 
            where upcase(libname) = upcase("&download");
        quit;

        ods tagsets.excelxp options ( sheet_name = "Raw Data Variables" ); 

        %let total_raw_datasets = %trim(%left(&total_raw_datasets));

        %if %eval(&total_raw_datasets = 0) %then %do;
            data no_obs;
                attrib issue length=$200 label="Renames";
                issue = "No Raw datasets found.";
            run;

            ods tagsets.excelxp options ( ABSOLUTE_COLUMN_WIDTH= "100" frozen_headers = "4" row_repeat = "4");

            proc report data= no_obs style(column)={tagattr='Format:Text'};
                column issue;
            run;
        %end;

        %else %do;
            * CHECK FOR VARIABLES WITH NAMES THAT ARE RESTRICTED TERMS;
            %let nobs = 0;

            proc sql noprint;
                create table checkcolumns as
                select memname, name, trim(name) || "_x" as new_name
                from sashelp.vcolumn
                where upcase(libname) = upcase("&download")
                    and upcase(name) in (select upcase(name) from sacq_md.sacq_restricted_terms)
                ;

                select count(*) into:nobs
                from sashelp.vcolumn
                where upcase(libname) = upcase("&download")
                    and upcase(name) in (select upcase(name) from sacq_md.sacq_restricted_terms)
                ;
            quit;
            
            %put ******* Number of variables to be renamed = &nobs;
            
            %if %eval(&nobs = 0) %then %do;
                data no_obs;
                    attrib issue length=$200 label="Renames";
                    issue = "No variables required name changes.";
                run;

                ods tagsets.excelxp options ( ABSOLUTE_COLUMN_WIDTH= "100" frozen_headers = "4" row_repeat = "4");

                proc report data= no_obs style(column)={tagattr='Format:Text'};
                    column issue;
                run;
            %end;
            
            %else %do;
                ods tagsets.excelxp options ( ABSOLUTE_COLUMN_WIDTH= "20" 
                frozen_headers = "4" 
                row_repeat = "4");

                proc report data= checkcolumns;
                    column memname name new_name;
                run;
            %end; 

        %end;
        
    ods tagsets.excelxp close;
    ods listing;

********************************************************************************
* End of Macro;
    %* OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR;
    %put ---------------------------------------------------------------------;
    %put PFESACQ_MAP_SCRF_LISTING: End of Submacro;
    %put ---------------------------------------------------------------------;
  
%mend pfesacq_map_scrf_listing;