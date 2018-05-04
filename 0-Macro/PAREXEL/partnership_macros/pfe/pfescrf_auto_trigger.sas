/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20151023       $LastChangedDate: 2015-10-23 14:01:09 -0400 (Fri, 23 Oct 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfescrf_auto_trigger.sas $
 
  Files Created:         None

  Program Purpose:       1) Return YES or NO to run macro pfescrf_auto <br>
                         1.1) Current day is on scheduled run day and no PASS today already<br>
                         1.2) No previous PASS run found <br>
                         1.3) Last PASS run >= allowed days

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:

    Name:                pxl_code_in
      Allowed Values:    Value of the PXL Study code or <null>
      Default Value:     <null>
      Description:       Will use as name of protocol as given or global macro
                         variable PXL_CODE value.

    Name:                path_metadata_in
      Allowed Values:    Valid UNIX directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       UNIX directory containing metadata

    Name:                data_transfer_log_in
      Allowed Values:    SAS dataset
      Default Value:     scrf_transfer_archive
      Description:       SAS dataset name containing pfescrf_auto transfer stats

    Name:                file_config_in
      Allowed Values:    CSV File
      Default Value:     pfescrf_auto_trigger.csv
      Description:       CSV File per expected format that contains study, allowed days, and 
                         scheduled day to run

  Global Macrovariables:
 
    Name:                pfescrf_auto_trigger_run
      Usage:             Creates
      Description:       Sets to YES to run pfescrf_auto (if last PASS >= allowed dasy or on 
                         scheduled day), NO, or FAIL (If issue found)
 
    Name:                pfescrf_auto_trigger_ErrMsg
      Usage:             Creates
      Description:       Contains any issue messages when pfescrf_auto_trigger_run = FAIL

  Metadata Keys:
 
    Name:                PFESCRF_AUTO Transfer Log
      Description:       Located per input parameter path_metadata_in but default is 
                         '/projects/std_pfizer/sacq/metadata/data/scrf_transfer_archive.sas7bdat'.
                         Holds PASS or FAIL and details for each auto scrf transfer.
      Dataset:           scrf_transfer_archive     

    Name:                file_config_in
      Description:       Located per input parameter path_metadata_in but default is 
                         '/projects/std_pfizer/sacq/metadata/data/file_config_in.csv'.
                         Holds configuration information for this macro: pxl_code, 
                         allowed_days, and scheduled day to run.
      Dataset:           N/A                        

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1266 $

-----------------------------------------------------------------------------*/

%macro pfescrf_auto_trigger(
    pxl_code_in=null,
    path_metadata_in=/projects/std_pfizer/sacq/metadata/data,
    data_transfer_log_in=scrf_transfer_archive,
    file_config_in=pfescrf_auto_trigger.csv);

    %* Modification Details
     * Version 1.0 20151022 Nathan Hartley
     *    1) Initial Version
     *;
     
    %* Macro Process
     * 1) Setup
     * 2) Setup of Internal Macros
     * 3) Check Input Sources
     * 4) Run Process
     * 5) Macro End and Cleanup
     *;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] Setup ;
    %put NOTE:[PXL] ***********************************************************************************;
        %* 
         * Setup
         * 1) Set SAS options
         * 2) Macro Variable Declarations
         * 3) Global Macro Variable Declarations
         * 4) Start of Macro Information Output To Log
         *;

        * 1) Set SAS options;
            OPTIONS nofmterr; * Ignore format notes in log;
            OPTIONS noquotelenmax; * Ignore longer macro variable strings;
            title;
            footnote;

        * 2) Macro Variable Declarations;
            %let MacroName        = PFESCRF_AUTO_TRIGGER;
            %let MacroVersion     = 1.0;
            %let MacroVersionDate = 20151023;
            %let MacroPath        = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
            %*let MacroPath        = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
            %let RunDateTime      = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));  * ISO8601 DATETIME;
            %let RunDate          = %sysfunc(left(%sysfunc(date(), yymmddn8.))); * YYYYMMDD Date;

        * 3) Global Macro Variable Declarations;
            * Output global macro (YES|NO|FAIL)
              YES - trigger run of pfescrf_auto due today being study scheduled day or over days since last PASS
              NO - trigger to not run pfescrf_auto
              FAIL - Issue in macro run;
            %global pfescrf_auto_trigger_run pfescrf_auto_trigger_ErrMsg;
            %let pfescrf_auto_trigger_run = FAIL;
            %let pfescrf_auto_trigger_ErrMsg = null;

        * 4) Start of Macro Information Output To Log;
            %put INFO:[PXL]----------------------------------------------;
            %put INFO:[PXL] &MacroName: Macro Started; 
            %put INFO:[PXL] File Location: &MacroPath ;
            %put INFO:[PXL] Version Number: &MacroVersion ;
            %put INFO:[PXL] Version Date: &MacroVersionDate ;
            %put INFO:[PXL] Run DateTime: &RunDateTime;        
            %put INFO:[PXL] ;
            %put INFO:[PXL] Purpose: Return YES or NO for macro pfescrf_auto run is needed ; 
            %put INFO:[PXL] Given Input Parameters:;
            %put INFO:[PXL]   1) pxl_code_in = &pxl_code_in;
            %put INFO:[PXL]   2) path_metadata_in = &path_metadata_in;
            %put INFO:[PXL]   3) data_transfer_log_in = &data_transfer_log_in;
            %put INFO:[PXL]   4) file_config_in = &file_config_in;
            %put INFO:[PXL]----------------------------------------------;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Setup of Internal Macros;
    %put NOTE:[PXL] ***********************************************************************;
        %* 
         * Setup of Internal Macros
         * 1) Creating mu_direxist;
         *;

        %put NOTE:[PXL] 1) Creating mu_direxist;
           %* mu_direxist
            * PURPOSE: Verify if file directory exists
            * INPUT:  1) pathdir = directory path text
            * OUTPUT: 1) returns: 1 if dir exists
            *                     0 if dir does not exist
            *                    -1 if abnormal macro end
            *;
            %macro mu_direxist(pathdir=null);
                %local _rc;
                %let _rc = -1;

                %let _rc = %sysfunc(filename(fileref,&pathdir));
                %if %sysfunc(fexist(&fileref)) %then 
                    %let _rc = 1;
                %else
                    %let _rc = 0;

                %if %eval(&_rc) >= 1 %then %do ;
                    1
                %end ;
                %else %if %eval(&_rc) = 0 %then %do ;
                    0
                %end ;
                %else %do ;
                    -1
                %end ;
            %mend mu_direxist;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] Check Input Sources ;
    %put NOTE:[PXL] ***********************************************************************************;
        %*
         * Check Input Sources
         * 1) Check global MAD macro GMPXLERR =1;
         * 2) Check global MAD macro DEBUG;
         * 3) Check pxl_code_in is not null or global macro pxl_code is present
         * 4) Check path_metadata_in is a valid directory
         * 5) Check data_transfer_log_in is a valid SAS dataset
         * 6) Check file_config_in is a valid file
         * 7) Check that record exists for pxl_code_in in file_config_in csv file that is ACTIVE
         * 8) Check that file_config_in contains a RUN_DAY number between 2 and 6
         * 9) Check that file_config_in contains a ALLOWED_DAYS number between 0 and 100
         *;

        %put NOTE:[PXL] 1) Check global MAD macro GMPXLERR = 1;
            proc sql noprint;
                select count(*) into: exists
                from sashelp.vmacro
                where scope='GLOBAL'
                      and name='GMPXLERR';
            quit;
            %if %eval(&exists = 0) %then %do;
                * MAD macro GMPXLERR does not exist, create and set to 0;
                %global GMPXLERR;
                %let GMPXLERR=0;
            %end;
            %else %if &GMPXLERR = 1 %then %do;
                * Parent macro execution unsuccessful, goto end;
                %let pfescrf_auto_trigger_ErrMsg = Global macro GMPXLERR = 1, macro not executed;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr;
            %end; 
            %put NOTE:[PXL] GMPXLERR = &GMPXLERR;
            %put ;

        %put NOTE:[PXL] 2) Check global MAD macro DEBUG;
            proc sql noprint;
                select count(*) into: exists
                from sashelp.vmacro
                where scope='GLOBAL'
                      and name='DEBUG';
            quit;
            %if %eval(&exists = 0) %then %do;
                * MAD macro DEBUG does not exist, create and set to 0;
                %global DEBUG;
                %let DEBUG=0;
            %end;
            %else %if %eval(&DEBUG = 0) %then %do;
                OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR /* NOSOURCE NONOTES */;
            %end;
            %else %if %eval(&DEBUG = 1) %then %do;
                OPTION MPRINT MLOGIC SYMBOLGEN SOURCE NOTES;
            %end;
            %else %do;
                %let pfescrf_auto_trigger_ErrMsg = Global macro DEBUG is not 1 or 0 and macro not executed: DEBUG=&DEBUG;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr;                
            %end;
            %put NOTE:[PXL] DEBUG = &DEBUG;
            %put ;

        %put NOTE:[PXL] 3) Check pxl_code_in is not null or global macro pxl_code is present;
            %if %str("&pxl_code_in") = %str("null") %then %do;
                proc sql noprint;
                    select count(*) into: exists
                    from sashelp.vmacro
                    where scope='GLOBAL'
                          and name='PXL_CODE';
                quit;
                %if %eval(&exists = 0) %then %do;
                    %let pfescrf_auto_trigger_ErrMsg = Input Parameter PXL_CODE_IN is null and global macro PXL_CODE is not present;
                    %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                    %goto MacErr; 
                %end;
                %else %do;
                    %let pxl_code_in = &PXL_CODE;
                %end;
            %end;
            %put NOTE:[PXL]: PXL_CODE_IN = &pxl_code_in;
            %put ;

        %put NOTE:[PXL] 4) Check path_metadata_in is a valid directory;
            %if %mu_direxist(pathdir=&path_metadata_in) = 0 %then %do;
                %put NOTE:[PXL]: PATH_METADATA_IN = &path_metadata_in;
                %let pfescrf_auto_trigger_ErrMsg = Input Parameter PATH_METADATA_IN is not a valid directory path;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr; 
            %end;
            libname LIB_MD "&path_metadata_in";
            %put NOTE:[PXL]: PATH_METADATA_IN = &path_metadata_in;
            %put ;

        %put NOTE:[PXL] 5) Check data_transfer_log_in is a valid SAS dataset;
            proc sql noprint;
                select count(*) into :exists
                from sashelp.vtable 
                where libname="LIB_MD"
                      and memname=%upcase("&data_transfer_log_in");
            quit;
            %if %eval(&exists=0) %then %do;
                %put NOTE:[PXL] data_transfer_log_in = &data_transfer_log_in;
                %let pfescrf_auto_trigger_ErrMsg = Input Parameter data_transfer_log_in is not a valid SAS dataset;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr;                
            %end;
            %put NOTE:[PXL] data_transfer_log_in = &data_transfer_log_in;
            %put ;

            data data_transfer_log_in;
            set LIB_MD.&data_transfer_log_in;
            run;

        %put NOTE:[PXL] 6) Check file_config_in is a valid file;
            %if not %sysfunc(fileexist(&path_metadata_in/&file_config_in)) %then %do;
                %put NOTE:[PXL]: FILE_CONFIG_IN = &file_config_in;
                %let pfescrf_auto_trigger_ErrMsg = Input Parameter file_config_in is not a valid file;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr; 
            %end;

        %put NOTE:[PXL] 7) Check that record exists for pxl_code_in in file_config_in csv file that is ACTIVE;
            %* Read in csv file
             * Expected structure:
             * VAR1 = ACTIVE (YES or NO)
             * VAR2 = PXL_CODE
             * VAR3 = PROTOCOL (PFE Study ID)
             * VAR4 = RUN_DAY (Scheduled run day number between 2=Monday to 6=Friday)
             * VAR5 = ALLOWED_DAYS (whole number, force run if last PASS this number or more)
             * VAR6 = NOTES (just user info text)
             *;

            proc import 
                datafile="&path_metadata_in/&file_config_in" 
                out=file_config_in
                dbms=csv replace;
                getnames=no;
            run;

            * Check if contains ACTIVE record for given pxl_code;
            proc sql noprint;
                select count(*) into: exists
                from file_config_in
                where VAR1="YES"
                      and VAR2="&pxl_code_in";
            quit;
            %if %eval(&exists = 0) %then %do;
                %put NOTE:[PXL]: PXL_CODE_IN = &pxl_code_in;
                %let pfescrf_auto_trigger_ErrMsg = No Record exists for pxl_code_in in file_config_in csv file that is ACTIVE;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr;                 
            %end;

        %put NOTE:[PXL] 8) Check that file_config_in contains a RUN_DAY number between 2 and 6;
            proc sql noprint;
                select count(*) into: exists
                from file_config_in
                where VAR1="YES"
                      and VAR2="&pxl_code_in"
                      and (not missing(VAR4) and input(VAR4, 8.) between 2 and 6);
            quit;
            %if %eval(&exists = 0) %then %do;
                %put NOTE:[PXL]: PXL_CODE_IN = &pxl_code_in;
                %let pfescrf_auto_trigger_ErrMsg = Record in file_config_in csv has invalid run_day;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr;                 
            %end;

        %put NOTE:[PXL] 9) Check that file_config_in contains a ALLOWED_DAYS number between 0 and 100;
            proc sql noprint;
                select count(*) into: exists
                from file_config_in
                where VAR1="YES"
                      and VAR2="&pxl_code_in"
                      and (not missing(VAR5) and input(VAR5, 8.) between 0 and 100);
            quit;
            %if %eval(&exists = 0) %then %do;
                %put NOTE:[PXL]: PXL_CODE_IN = &pxl_code_in;
                %let pfescrf_auto_trigger_ErrMsg = Record in file_config_in csv has invalid allowed_days;
                %put %str(ERR)OR:[PXL] &MacroName: &pfescrf_auto_trigger_ErrMsg;
                %goto MacErr;                 
            %end;            
            
    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Run Process;
    %put NOTE:[PXL] ***********************************************************************;
        %*
         * Run Process
         * 1) Check if current day of week is study scheduled run_day and no PASS that day
         * 2) Check if No previous PASS run exists
         * 3) Check if Day since last PASS run is allowed_days or more days
         *;

         %put ; %put NOTE:[PXL] 1) Check if current day of week is study scheduled run_day and no PASS that day; %put ; 
            * Get current day of the week 1=Sunday, 2=Monday, ..., 7=Saturday;
            %let current_day = %sysfunc(weekday(%sysfunc(date())));

            proc sql noprint;
                select VAR4 into: run_day
                from file_config_in
                where VAR1="YES"
                      and VAR2="&pxl_code_in"
                      and (not missing(VAR4) and input(VAR4, 8.) between 2 and 6);
            quit;

            %put NOTE:[PXL] Current Day = %left(%trim(&current_day));
            %put NOTE:[PXL] Scheduled Day = &run_day;


            %if %eval(&run_day = &current_day) %then %do;
                %put NOTE:[PXL] Scheduled run day is current day of week (&current_day);

                * Check if PASS already exists for that day;
                proc sql noprint;
                    select datepart(max(PFESCRF_AUTO_RUNDATETIME)) format=yymmdd10. into: max_pass_dt
                    from lib_md.&data_transfer_log_in 
                    where pfescrf_auto_pxl_code = "%left(%trim(&pxl_code_in))"
                          and pfescrf_auto_PassOrFail ne "FAIL"
                          and not missing(PFESCRF_AUTO_RUNDATETIME);
                quit;
                data _null_;
                    format  current_dt max_pass_dt yymmdd10.;

                    current_dt = date();
                    max_pass_dt = input("&max_pass_dt", yymmdd10.);

                    if missing(current_dt) or missing(max_pass_dt) then do;
                        days_past = 9999;
                    end;
                    else do; 
                        days_past = current_dt - max_pass_dt;
                    end;
                    
                    put "NOTE:[PXL] Current Date = " current_dt;
                    put "NOTE:[PXL] Last PASS Date = " max_pass_dt;
                    put "NOTE:[PXL] Calculated Days Since Last Pass = " days_past;

                    if (days_past ne 0) then do;
                        %* On scheduled run day and no previous PASS run that day;
                        call symput('pfescrf_auto_trigger_run', 'YES'); 
                    end;
                    else do;
                        %* On scheduled day and previous PASS run found for that day;
                        call symput('pfescrf_auto_trigger_run', 'NO');
                    end;
                run;

                %if &pfescrf_auto_trigger_run = %str(YES) %then %do;
                    %put NOTE:[PXL] Schedued run day and no previous PASS today, pfescrf_auto_trigger_run (days_past ne 0) = YES;
                    %goto MacEnd;  
                %end;
                %else %if &pfescrf_auto_trigger_run = %str(NO) %then %do;
                    %put NOTE:[PXL] Schedued run day and previous PASS today, pfescrf_auto_trigger_run (days_past = 0) = NO;
                    %goto MacEnd;  
                %end;
            %end;

        %put ; %put NOTE:[PXL] 2) Check if No previous PASS run exists; %put ; 
            proc sql noprint;
                select count(*) into: exists
                from lib_md.&data_transfer_log_in
                where pfescrf_auto_pxl_code = "%left(%trim(&pxl_code_in))"
                      and pfescrf_auto_PassOrFail ne "FAIL";
            quit;
            %if %eval(&exists = 0) %then %do;
                %put NOTE:[PXL] Not scheduled day and no previous PASS transfer found, run macro;
                %let pfescrf_auto_trigger_run = YES;
                %goto MacEnd;
            %end;
            %else %do;
                %put NOTE:[PXL] Previous PASS transfers found: %left(%trim(&exists));
                %put ;
            %end;

        %put ; %put NOTE:[PXL] 3) Check if Day since last PASS run is allowed_days or more days; %put ; 

            * Check if PASS already exists for that day;
            proc sql noprint;
                select datepart(max(PFESCRF_AUTO_RUNDATETIME)) format=yymmdd10. into: max_pass_dt
                from lib_md.&data_transfer_log_in 
                where pfescrf_auto_pxl_code = "%left(%trim(&pxl_code_in))"
                      and pfescrf_auto_PassOrFail ne "FAIL"
                      and not missing(PFESCRF_AUTO_RUNDATETIME);
            quit;

            * Get allowed days number;
            proc sql noprint;
                select VAR5 into: allowed_days
                from file_config_in
                where VAR1="YES"
                      and VAR2="&pxl_code_in";
            quit;

            * Derive pfescrf_auto_trigger_run as days_past > allowed_days = YES or days_past < allowed_days = NO;
            data _null_;
                format  current_dt max_pass_dt yymmdd10.;

                current_dt = date();
                max_pass_dt = input("&max_pass_dt", yymmdd10.);
                allowed_days = input("&allowed_days", 8.);
                if missing(current_dt) or missing(max_pass_dt) then 
                    days_past = 9999;
                else 
                    days_past = current_dt - max_pass_dt;
                
                put "NOTE:[PXL] Current Date = " current_dt;
                put "NOTE:[PXL] Last PASS Date = " max_pass_dt;
                put "NOTE:[PXL] Allowed Days = " allowed_days;
                put "NOTE:[PXL] Calculated Days Since Last Pass = " days_past;

                if days_past >= allowed_days then do;
                    call symput('pfescrf_auto_trigger_run', 'YES'); 
                    put "NOTE:[PXL] pfescrf_auto_trigger_run (days_past >= allowed_days) = YES";
                end;
                else do;
                    call symput('pfescrf_auto_trigger_run', 'NO');
                    put "NOTE:[PXL] pfescrf_auto_trigger_run (days_past < allowed_days) = NO";
                end;                
            run;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Macro End and Cleanup;
    %put NOTE:[PXL] ***********************************************************************;
        %* 
         * 1) Abnormal Macro End 
         * 2) Macro End Setup Reset
         * 3) Macro End Remove Work Datasets
         * 4) Macro End Remove Libnames Created
         * 5) Macro End Remove catalogs Created
         * 6) Macro End Final Log Message
         *;

        %goto MacEnd;

        %MacErr:;
        * 1) Abnormal Macro End ;
            %put %str(ERR)OR:[PXL] ---------------------------------------------------;
            %put %str(ERR)OR:[PXL] &MacroName: Abnormal end to macro;
            %put %str(ERR)OR:[PXL] &MacroName: See log for details;
            %put %str(ERR)OR:[PXL] ---------------------------------------------------;
            %global GMPXLERR;
            %let GMPXLERR=1;

        %MacEnd:;
        * 2) Macro End Setup Reset;
            title;
            footnote;
            OPTIONS fmterr quotelenmax;; * Reset Ignore format notes in log;
            OPTIONS missing=.;
            options printerpath='';

        * 3) Macro End Remove Work Datasets;
            %macro delmac(wds=null);
                %if %sysfunc(exist(&wds)) %then %do; 
                    proc datasets lib=work nolist; delete &wds; quit; run; 
                %end; 
            %mend delmac;
            %delmac(wds=data_transfer_log_in);
            %delmac(wds=file_config_in);

        * 4) Macro End Remove Libnames Created;   
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
            %dellib(libn=LIB_MD);            

        * 5) Macro End Remove catalogs Created;
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

        * 6) Macro End Final Log Message;
            %put INFO:[PXL]----------------------------------------------;
            %put INFO:[PXL] &MacroName: Macro Completed; 
            %put INFO:[PXL] Output: ;
            %put INFO:[PXL]    pfescrf_auto_trigger_run = &pfescrf_auto_trigger_run;
            %put INFO:[PXL]    pfescrf_auto_trigger_ErrMsg = &pfescrf_auto_trigger_ErrMsg;
            %put INFO:[PXL]----------------------------------------------;

%mend pfescrf_auto_trigger;