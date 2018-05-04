/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20150824       $LastChangedDate: 2015-08-24 18:20:25 -0400 (Mon, 24 Aug 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfe_auto.sas $
 
  Files Created:         None
 
  Program Purpose:       Run study macro call run_pfescrf_auto from Cron job call <br />
                         1) Expected day is current day <br />
                         2) No previous PASS run exists <br />
                         3) Days since last PASS run is 7 or more days

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:

    Name:                pfe_auto_pxl_code
      Allowed Values:    PAREXEL study number
      Default Value:     null
      Description:       PAREXEL study number that runs pfescrf_auto macro (needs setup at study level)

    Name:                pfe_auto_expected_runday
      Allowed Values:    Number 2-6
      Default Value:     null
      Description:       Day of week expected to always run pfescrf_auto for the study
                         2=MONDAY
                         3=TUESDAY
                         4=WEDNESDAY
                         5=THURSDAY
                         6=FRIDAY

    Name:                pfe_auto_path_code
      Allowed Values:    Kennet path for run_pfescrf_auto.sas
      Default Value:     null
      Description:       If null, then will use /projects/pfizr&pfe_auto_pxl_code/dm/sasprogs/production
                         This input parameter only used for testing

    Name:                pfe_auto_path_transfers
      Allowed Values:    Kennet path to metadata data location
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Path to metadata data location

    Name:                pfe_auto_file_transfers
      Allowed Values:    SAS dataset
      Default Value:     SCRF_TRANSFER_ARCHIVE
      Description:       Metadata SAS dataset that saves run information

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1025 $

-----------------------------------------------------------------------------*/

%macro pfe_auto(
    pfe_auto_pxl_code=null,
    pfe_auto_expected_runday=null,
    pfe_auto_path_code=null,
    pfe_auto_path_transfers=/projects/std_pfizer/sacq/metadata/data,
    pfe_auto_file_transfers=SCRF_TRANSFER_ARCHIVE);

    /*
      Version History:
        Version: V1.0 Date: 20150824 Author: Nathan Hartley
          1) Initial Version  
    */

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Macro Startup;
    %put NOTE:[PXL] ***********************************************************************;
        OPTIONS nofmterr; * Ignore format notes in log;
        OPTIONS noquotelenmax; * Ignore longer macro variable strings;
        title;
        footnote;

        * Macro Variable Declarations;
          %let pfe_auto_MacName  = PFE_AUTO;
          %let pfe_auto_MacVer   = 1.0;
          %let pfe_auto_MacVerDT = 20150824;
          %let pfe_auto_MacPath  = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
          %*let pfe_auto_MacPath  = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
          %let pfe_auto_RunDTE   = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));
          %*let pfe_auto__RunDateTime      = %sysfunc(compress(%sysfunc(left(%sysfunc(datetime(), IS8601DT.))), '-:'));

        * Log output input parameters;
          %put INFO:[PXL]----------------------------------------------;
          %put INFO:[PXL] &pfe_auto_MacName: Macro Started; 
          %put INFO:[PXL] File Location: &pfe_auto_MacPath ;
          %put INFO:[PXL] Version Number: &pfe_auto_MacVer ;
          %put INFO:[PXL] Version Date: &pfe_auto_MacVerDT ;
          %put INFO:[PXL] Run DateTime: &pfe_auto_RunDTE;        
          %put INFO:[PXL] ;
          %put INFO:[PXL] Purpose: Run study macro call run_pfescrf_auto from Cron job call ; 
          %put INFO:[PXL] Input Parameters:;
          %put INFO:[PXL]   1) pfe_auto_pxl_code = &pfe_auto_pxl_code;
          %put INFO:[PXL]   2) pfe_auto_expected_runday = &pfe_auto_expected_runday;
          %put INFO:[PXL]   3) pfe_auto_path_code = &pfe_auto_path_code;
          %put INFO:[PXL]   4) pfe_auto_path_transfers = &pfe_auto_path_transfers;
          %put INFO:[PXL]   5) pfe_auto_file_transfers = &pfe_auto_file_transfers;
          %put INFO:[PXL]----------------------------------------------;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Process Parameters;
    %put NOTE:[PXL] ***********************************************************************;

        %if %str("&pfe_auto_path_code") = %str("null") %then %do;
            %let pfe_auto_path_code = /projects/pfizr%left(%trim(&pfe_auto_pxl_code))/dm/sasprogs/production/;
        %end;
        %put NOTE:[PXL] pfe_auto_path_code = &pfe_auto_path_code;

        libname lib_at "&pfe_auto_path_transfers";

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Process;
    %put NOTE:[PXL] ***********************************************************************;

        * Get current day of the week 1=Sunday, 2=Monday, ..., 7=Saturday;
        %let current_day = %sysfunc(weekday(%sysfunc(date())));
        
        %put NOTE:[PXL] ;
        %put NOTE:[PXL] 1) Check if current day of week is study scheduled day to run;
            %put NOTE:[PXL] Current Day = %left(%trim(&current_day));
            %put NOTE:[PXL] Scheduled Day pfe_auto_expected_runday = &pfe_auto_expected_runday;
            %if %eval(&pfe_auto_expected_runday = &current_day) %then %do;
                %put NOTE:[PXL] Scheduled day is current day of week (&current_day), Run macro;
                %goto RunMacro;
            %end;

        %put NOTE:[PXL] ;
        %put NOTE:[PXL] 2) Check if No previous PASS run exists;
            proc sql noprint;
                select count(*) into: exists
                from LIB_AT.SCRF_TRANSFER_ARCHIVE
                where pfescrf_auto_pxl_code = "%left(%trim(&pfe_auto_pxl_code))"
                      and pfescrf_auto_PassOrFail ne "FAIL";
            quit;
            %if %eval(&exists = 0) %then %do;
                %put NOTE:[PXL] No previous PASS run found, run macro;
                %goto RunMacro;
            %end;
            %else %do;
                %put NOTE:[PXL] Previous PASS found: %left(%trim(&exists));
            %end;

        %put NOTE:[PXL] ;            
        %put NOTE:[PXL] 3) Check if Day since last PASS run is 7 or more days;
            %let RunMacro = Y;
            data _null_;
                retain RunMacro 0;
                set LIB_AT.SCRF_TRANSFER_ARCHIVE end=eof;
                format curdate lastdate date11.;

                if _n_ = 1 then RunMacro = 1;

                if pfescrf_auto_pxl_code = "%left(%trim(&pfe_auto_pxl_code))"
                   and pfescrf_auto_PassOrFail ne "FAIL" then do;

                    curdate = date();
                    lastdate = datepart(pfescrf_auto_RunDateTime);
                    dayssince = curdate - lastdate;
                    put "Days between current date and PASS Date: " curdate lastdate dayssince;

                    if dayssince < 7 then do;
                        put "Days 6 or less, macro will not be run";
                        RunMacro = 0;
                    end;
                end;

                if eof then do;
                    put "Final RunMacro = " RunMacro;
                    if RunMacro = 0 then do;
                        call symput('RunMacro','N');
                    end;
                end;
            run;

            %put NOTE:[PXL] Macro Variable RunMacro = &RunMacro;
            %if %str("&RunMacro") = %str("Y") %then %do;
                %goto RunMacro;
            %end;

        %goto DoNotRunMacro;

        %RunMacro:;
            %put NOTE:[PXL] ;
            %put NOTE:[PXL] Running macro call run_pfescrf_auto();
            %put NOTE:[PXL] ;
            x "cd &pfe_auto_path_code";
            x "sas92 run_pfescrf_auto.sas";
            %goto MacEnd;

        %DoNotRunMacro:;
            %put NOTE:[PXL] ;
            %put NOTE:[PXL] Macro call run_pfescrf_auto() not run;
            %put NOTE:[PXL] ;
            %goto MacEnd;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Macro End and Cleanup;
    %put NOTE:[PXL] ***********************************************************************;

        %goto MacEnd;
        %MacErr:;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %put %str(ERR)OR:[PXL] &pfe_auto_MacName: Abnormal end to macro;
        %put %str(ERR)OR:[PXL] &pfe_auto_MacName: See log for details;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %let GMPXLERR=1;

        %MacEnd:;

        OPTIONS fmterr;
        OPTIONS quotelenmax;

        proc sql noprint;
            select count(*) into: exists
            from sashelp.vlibnam
            where libname = "LIB_AT";
        quit;
        %if %eval(&exists > 0) %then %do;
            libname LIB_AT clear;
        %end;

        %symdel CURRENT_DAY /nowarn;

        %put INFO:[PXL]----------------------------------------------;
        %put INFO:[PXL] &pfe_auto_MacName: Macro Completed; 
        %put INFO:[PXL] Output: ;     
        %put INFO:[PXL]----------------------------------------------;

%mend pfe_auto;
