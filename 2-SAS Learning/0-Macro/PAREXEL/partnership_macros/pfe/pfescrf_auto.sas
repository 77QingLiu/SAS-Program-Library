/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: johnson2 $
  Creation Date:         20151020       $LastChangedDate: 2016-10-06 13:06:28 -0400 (Thu, 06 Oct 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfescrf_auto.sas $
 
  Files Created:         1) Zip files
                         2) Download files
                         3) CSDW SCRF files
                         4) Listings per process
                         5) Email notifications
 
  Program Purpose:       Purpose of this macro is to: <br />
                         1) Get latest DL raw data zip files <br />
                         2) Run study SAS program extract.sas and check log <br />
                         3) Run study SAS program export.sas and check log <br />
                         4) Run proc compare if double programmed <br />
                         5) Validate CSDW SCRF <br />
                         6) Run structure compare against last approved transfer <br />

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has not been validated for use only in PAREXEL's
                         working environment yet.
 
  Macro Parameters:
 
    Name:                pfescrf_auto_pxl_code
      Allowed Values:    Valid Study PAREXEL code
      Default Value:     null
      Description:       Valid Study PAREXEL code, if null will attempt to get from global macro pxl_code
 
    Name:                pfescrf_auto_protocol
      Allowed Values:    Valid Study Pfizer protocol code
      Default Value:     null
      Description:       Valid Study Pfizer protocol code, if null will attempt to get from global macro protocol
 
    Name:                pfescrf_auto_pi_code
      Allowed Values:    Valid PI Study Code
      Default Value:     null
      Description:       Specifies the study code PI uses for their SFTP server. Must be entered.

    Name:                pfescrf_auto_sftpdayspast
      Allowed Values:    Valid number 1-100
      Default Value:     2
      Description:       Specifies the number of days past current date to look for latest ZIP files

    Name:                pfescrf_auto_double
      Allowed Values:    Y or N
      Default Value:     N
      Description:       Y = run proccompare scrf/current to scrf/current/qc
                         N = do not run proccompare

    Name:                pfescrf_auto_path_zip
      Allowed Values:    Valid directory path
      Default Value:     null
      Description:       Directory path to save PI SFTP zip files created, if null ill use 
                         /projects/pfizrNNNNNN/dm/datasets/zip/prod/YYYYMMDD

    Name:                pfescrf_auto_path_code
      Allowed Values:    Valid directory path
      Default Value:     null
      Description:       Directory path to find extract.sas, export.sas, etc.  If null then will use
                         /projects/pfizrNNNNNN/dm/sasprogs/production

    Name:                pfescrf_auto_lib_download
      Allowed Values:    Valid SAS library
      Default Value:     download
      Description:       Valid SAS library that holds raw download data location 
                         Normall points to /projects/pfizrNNNNNN/dm/datasets/download/current

    Name:                pfescrf_auto_lib_scrf
      Allowed Values:    Valid SAS library
      Default Value:     scrf
      Description:       Valid SAS library that holds mapped csdw scrf data location 
                         Normall points to /projects/pfizrNNNNNN/dm/datasets/scrf/current

    Name:                pfescrf_auto_path_listings_out
      Allowed Values:    Valid directory path
      Default Value:     null
      Description:       Directory path to save listing files created, will use /projects/pfizrNNNNNN/dm/listings/YYYYMMDD 
                         if null

    Name:                pfescrf_auto_path_scrf_metadata
      Allowed Values:    Valid directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Used for testing, path to csdw spec and codelists to check scrf data

    Name:                pfescrf_auto_path_struct_metadat
      Allowed Values:    Valid directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/scrf_csdw
      Description:       Used for testing, path to save transfer SAS structure to check each transfer against,
                         Updated when pfescrf_auto_confirmedchange=Y

    Name:                pfescrf_auto_confirmedchange
      Allowed Values:    Y or N
      Default Value:     N
      Description:       When pfescrf_auto_confirmedchange=Y then pfescrf_auto_path_struct_metadat structure file 
                         is updated, used to check structure against per transfer for changes

    Name:                pfescrf_auto_file_emails_study 
      Allowed Values:    Valid directory path and csv file from certain format
      Default Value:     null
      Description:       Each study has /macros/study_contacts.csv that olds emails to notify CDBP Programmers

    Name:                pfescrf_auto_file_emails_dex
      Allowed Values:    Valid directory path and csv file from certain format
      Default Value:     null
      Description:       Holds standards area DEX team eamil addresses

    Name:                pfescrf_auto_path_transfers
      Allowed Values:    Valid directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Holds the dataset that saves each transer information

    Name:                pfescrf_auto_testing
      Allowed Values:    Y or N
      Default Value:     N
      Description:       Used for testing, will bypass PISFTPGET macro

    Name:                pfescrf_auto_sendemail
      Allowed Values:    Y or N
      Default Value:     Y
      Description:       Used for testing, will turn sending email notifications on or off

  Global Macrovariables:
 
    Name:                pfescrf_auto_PassOrFail
      Usage:             Creates
      Description:       Sets to PASS or FAIL depnding on macro outcome

    Name:                pfescrf_auto_FailMsg
      Usage:             Creates
      Description:       Sets to message for any abnormal termination

  Metadata Keys:

    Name:                Reference Specification Data
      Description:       PAREXEL Modified Pfizer Data Standards CSDW SCRF Specification
                         Defaulted locoation per input parameter &pfescrf_auto_path_scrf_metadata
      Dataset:           scrf_csdw_pxl
 
    Name:                Reference Codelist Data
      Description:       Holds all possible Pfizer codelist values
                         Defaulted locoation per input parameter &pfescrf_auto_path_scrf_metadata
      Dataset:           codelists      

    Name:                Reference Data Transfer Structure Data
      Description:       Located per input parameter &pfescrf_auto_path_struct_metadat but default is 
                         /projects/std_pfizer/sacq/metadata/data/scrf_csdw/SCRF_CSDW_&pfescrf_auto_pxl_code. 
                         where input parameter pfescrf_auto_pxl_code is PXL study Code ID. 
                         This holds the last approved study transfer structure metadata to compare against/create/update.
      Dataset:           scrf_csdw_<6 digit PXL Study Code>

    Name:                Reference Specification Data
      Description:       Located per input parameter &pfescrf_auto_path_transfers but default is 
                         /projects/std_pfizer/sacq/metadata/data/. 
                         Adds a record per transfer with transfer details.
      Dataset:           scrf_transfer_archive

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2708 $

-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
  MODIFICATION VERSIONS:  

  Ver  | Date     | Author | Revisions
  -----------------------------------------------------------------------------
  V1.0 | 20151020 | Nathan Hartley | Initial Version
  V2.0 | 20150826 | Nathan Hartley | 
    1) Updated Interna Macro SEND_EMAIL - Modified PMED link for more info so email is sent
  V3.0 | 20151023 | Nathan Hartley | 
    1) In Section 2.4, Added -rp option to cp command to retain file datetimes and copy /qc folder
    2) Added Section 4.3 Run PFESCRF_AUTO_TRIGGER when sysparm is AUTO
  V4.0 | 20151027 | Nathan Hartley |
    1) Modifed Section 4.3 When PFESCRF_AUTO_TRIGGER returns NO to %goto NoRun
  V5.0 | 20160301 | Nathan Hartley |
    1) Added %update_path_for_issue(pathroot=&pfescrf_auto_path_download after scrf failures too
       this forces raw download data to match scrf data for sacq transfer process
  V6.0 | 20160824 | Nathan Hartley |       
    1) Added submacro email_pcda_coding as seperate email on special coding listings to be sent to PCDA
  V7.0 | 20161006 | Nathan Johnson |       
    1) Added noterminal option to x commands calling extract.sas and export.sas

-----------------------------------------------------------------------------*/

%macro pfescrf_auto(
    pfescrf_auto_pxl_code=null,
    pfescrf_auto_protocol=null,
    pfescrf_auto_pi_code=null,
    pfescrf_auto_sftpdayspast=2,
    pfescrf_auto_double=N,
    pfescrf_auto_path_zip=null,
    pfescrf_auto_path_code=null,
    pfescrf_auto_lib_download=download,
    pfescrf_auto_lib_scrf=scrf,
    pfescrf_auto_path_listings_out=null,
    pfescrf_auto_path_scrf_metadata=/projects/std_pfizer/sacq/metadata/data,
    pfescrf_auto_path_struct_metadat=/projects/std_pfizer/sacq/metadata/scrf_csdw,
    pfescrf_auto_confirmedchange=N,
    pfescrf_auto_file_emails_study=null,
    pfescrf_auto_file_emails_dex=null,
    pfescrf_auto_path_transfers=/projects/std_pfizer/sacq/metadata/data,
    pfescrf_auto_testing=N,
    pfescrf_auto_sendemail=Y);

    %* Macro Process
     * 1) Setup
     * 2) Setup Internal Macros
     * 3) Setup Process Macros
     * 4) Run Process
     * 5) Macro End and Cleanup
     *;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 1) Setup ;
    %put NOTE:[PXL] ***********************************************************************************;

        ods listing close;
        options nofmterr noquotelenmax; * Ignore macro variables longer than 256 char;        
        title;
        footnote;

        * Macro Variable Declarations;
        %let pfescrf_auto_MacroName        = PFESCRF_AUTO;
        %let pfescrf_auto_MacroVersion     = 7.0;
        %let pfescrf_auto_MacroVersionDate = 20161006;

        %local
          SMARTSVN_Version
          MacroLocation
          MacroLastChangeDateTime
        ;

        %let SMARTSVN_Version = ;
        data _null_;
            %* Derive from SMARTSVN updated string as revision number;
            VALUE = "$Rev: 2708 $";
            VALUE = compress(VALUE,'$Rev: ');
            call symput('SMARTSVN_Version', VALUE);
        run;
        %let MacroLocation = ; %* Derive from SMARTSVN updated string below;
        data _null_;
          VALUE = "$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/unittesting/testing_area/macros/partnership_macros/pfe/pfescrf_auto.sas $";
              %* Replace Smart SVN Repository name with actual UNIX path used;
              VALUE = tranwrd(VALUE,'HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/', '/opt/pxlcommon/stats/');
              VALUE = compress(VALUE,'$');
              call symput('MacroLocation', VALUE);
        run;
        %let MacroLastChangeDateTime = %substr("$LastChangedDate: 2016-10-06 13:06:28 -0400 (Thu, 06 Oct 2016) $", 20, 26); %* Derived from SMARTSVN string;

        %let pfescrf_auto_MacroPath        = &MacroLocation;
        %let pfescrf_auto_RunDateTime      = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));  
        %let pfescrf_auto_RunDate          = %sysfunc(left(%sysfunc(date(), yymmddn8.)));

        * Global return macros;
        %global pfescrf_auto_PassOrFail pfescrf_auto_FailMsg;
        %let pfescrf_auto_PassOrFail = FAIL;
        %let pfescrf_auto_FailMsg = null;

        * Declare local macro variables;
        %let pfescrf_auto_path_zip_full = ; * Will add current date YYYYMMDD to &pfescrf_auto_path_zip to use to save and extract zip files;
        %let pfescrf_auto_path_download = null; * Used for root unix path of lib pfescrf_auto_lib_download without the /current;
        %let PFESCRF_AUTO_PATH_DOWNLOAD_CURDT = null; * library download path with current date YYYYMMDD instead of /current;
        %let pfescrf_auto_path_scrf = null; * library scrf path without the /current;
        %let pfescrf_auto_path_scrf_curdate = null; * library scrf path with current date YYYYMMDD instead of /current;
        %let emails_dex = ; * email address list for DEX team;
        %let emails_study = ; %* email address list for CDBPSAS per study_contacts;        
        %let emails_stat = ; %* email address list for STATPRG per study_contacts;
        %let emails_pcda = ; %* email address list for PCDA per study_contacts;
        %let macro_path_total = 0; * Used for _macstart and _macend for macro breadcrumbs;
        %let extract_sc_exist = N; * Used for extract warnings found in log for coded data;

        * Dclare local macro variables for send_email;
        %let nbsp=%nrstr(&nbsp); * Used to insert HTML spaces;      

        * Send Email macro variabels. Set during each process. Email sent as end of macro.;
        %let send_email_sftp_zip_passOrFail = Not Completed;
        %let send_email_sftp_zip_failMsg = null;
        %let send_email_extract_passOrFail = Not Completed;
        %let send_email_extract_failMsg = null;
        %let send_email_export_passOrFail = Not Completed;
        %let send_email_export_failMsg = null;
        %let send_email_csdw_passOrFail = Not Completed;
        %let send_email_csdw_failMsg = null;
        %let send_email_struct_passOrFail = Not Completed;
        %let send_email_struct_failMsg = null;

        %put INFO:[PXL]----------------------------------------------;
        %put INFO:[PXL] &pfescrf_auto_MacroName: Macro Started; 
        %put INFO:[PXL] File Location: &pfescrf_auto_MacroPath ;
        %put INFO:[PXL] Version Number: &pfescrf_auto_MacroVersion ;
        %put INFO:[PXL] Version Date: &pfescrf_auto_MacroVersionDate ;
        %put INFO:[PXL] Run DateTime: &pfescrf_auto_RunDateTime;
        %put INFO:[PXL] SMARTSVN Revision: &SMARTSVN_Version;
        %put INFO:[PXL] SMARTSVN LastUpdate: &MacroLastChangeDateTime;                
        %put INFO:[PXL] ;
        %put INFO:[PXL] Purpose: Automatic SCRF Transfers ; 
        %put INFO:[PXL] Input Parameters:;
        %put INFO:[PXL]   1) pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;
        %put INFO:[PXL]   2) pfescrf_auto_protocol = &pfescrf_auto_protocol;
        %put INFO:[PXL]   3) pfescrf_auto_pi_code = &pfescrf_auto_pi_code;
        %put INFO:[PXL]   4) pfescrf_auto_double = &pfescrf_auto_double;
        %put INFO:[PXL]   5) pfescrf_auto_path_zip = &pfescrf_auto_path_zip;
        %put INFO:[PXL]   6) pfescrf_auto_lib_download = &pfescrf_auto_lib_download;
        %put INFO:[PXL]   7) pfescrf_auto_lib_scrf = &pfescrf_auto_lib_scrf;
        %put INFO:[PXL]   8) pfescrf_auto_path_listings_out=&pfescrf_auto_path_listings_out;
        %put INFO:[PXL]   9) pfescrf_auto_path_scrf_metadata=&pfescrf_auto_path_scrf_metadata;
        %put INFO:[PXL]  10) pfescrf_auto_path_struct_metadat=&pfescrf_auto_path_struct_metadat;
        %put INFO:[PXL]  11) pfescrf_auto_confirmedchange=&pfescrf_auto_confirmedchange;
        %put INFO:[PXL]  12) pfescrf_auto_file_emails_study=&pfescrf_auto_file_emails_study;
        %put INFO:[PXL]  13) pfescrf_auto_file_emails_dex=&pfescrf_auto_file_emails_dex;
        %put INFO:[PXL]  14) pfescrf_auto_path_transfers=&pfescrf_auto_path_transfers;
        %put INFO:[PXL]  15) pfescrf_auto_testing=&pfescrf_auto_testing;
        %put INFO:[PXL]  16) pfescrf_auto_sendemail=&pfescrf_auto_sendemail;
        %put INFO:[PXL]----------------------------------------------;            

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 2) Setup Internal Macros ;
    %put NOTE:[PXL] ***********************************************************************************;
        %*
         * 2.1 _MacStart
         * 2.2 _MacEnd
         * 2.3 SEND_EMAIL
         * 2.4 UPDATE_PATH_FOR_ISSUE
         * 2.5 ARCHIVE_TRANSFER
         *;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.1) Setup Internal Macro _MacStart;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: _MacStart
            PURPOSE: Output log message for start of macro
            INPUT: 
                1) MacroName - name of macro starting
                2) macro_path_total - macro for number of total nested macros
                3) macro_path_<number> - macro array of nested macros
            OUTPUT: 
                1) log message
                2) macro_path_total - adds 1
                3) macro_path_<number> - adds macro to nested list array
            ;
            %macro _MacStart(MacroName=null);
                * Derive macro path;
                %let macro_path_total = %eval(&macro_path_total + 1);
                %let macro_path_total = %left(%trim(&macro_path_total));
                
                %symdel macro_path_&macro_path_total /NOWARN;
                %global macro_path_&macro_path_total;
                %let macro_path_&macro_path_total = &MacroName;
                
                %let _path = >> &macro_path_1;
                %do i=2 %to &macro_path_total;
                    %let _path = &_path > &&macro_path_&i;
                %end;

                * Log message;
                %put INFO[PXL]: ------------------------------------------------------;
                %put INFO[PXL]: &MacroName.: Macro Started;
                %put INFO[PXL]: Macro Path: &_path;
                %put INFO[PXL]: ------------------------------------------------------;
            %mend _MacStart;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.2) Setup Internal Macro _MacEnd;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: _MacEnd
            PURPOSE: Output log message for End of macro
            INPUT: 
                1) MacroName - name of macro starting
                2) macro_path_total - macro for number of total nested macros
                3) macro_path_<number> - macro array of nested macros
            OUTPUT: 
                1) log message
                2) macro_path_total - subtracts 1
                3) macro_path_<number> - removes macro to nested list array
            ;
            %macro _MacEnd(MacroName=null);
                * Derive macro path;
                %let _path = >> &macro_path_1;
                %do i=2 %to &macro_path_total;
                    %let _path = &_path > &&macro_path_&i;
                %end;

                * Log message;
                %put INFO[PXL]: ------------------------------------------------------;
                %put INFO[PXL]: Macro Path: &_path;
                %put INFO[PXL]: &MacroName.: Macro Completed;
                %put INFO[PXL]: ------------------------------------------------------;

                %symdel macro_path_&macro_path_total /NOWARN;
                %let macro_path_total = %eval(&macro_path_total - 1);          
            %mend _MacEnd; 

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.3) Setup Internal Macro SEND_EMAIL;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: send_email
            PURPOSE: Output fail message and email details
            INPUT: 
                1) msg=fail message text
            OUTPUT: 
                1) log message
                2) email of issue details
            ;
            %macro send_email;
                %_MacStart(MacroName=SEND_EMAIL);

                %put NOTE:[PXL] -------------------------------------------------------------------;
                %put NOTE:[PXL] Macro Variable Input Parameters:;
                %put NOTE:[PXL] pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;
                %put NOTE:[PXL] pfescrf_auto_protocol = &pfescrf_auto_protocol;
                %put NOTE:[PXL] pfescrf_auto_PassOrFail = &pfescrf_auto_PassOrFail;
                %put NOTE:[PXL] pfescrf_auto_FailMsg = &pfescrf_auto_FailMsg;
                %put NOTE:[PXL] send_email_sftp_zip_passOrFail = &send_email_sftp_zip_passOrFail;
                %put NOTE:[PXL] send_email_sftp_zip_failMsg = &send_email_sftp_zip_failMsg;
                %put NOTE:[PXL] send_email_extract_passOrFail = &send_email_extract_passOrFail;
                %put NOTE:[PXL] send_email_extract_failMsg = &send_email_extract_failMsg;
                %put NOTE:[PXL] send_email_export_passOrFail = &send_email_export_passOrFail;
                %put NOTE:[PXL] send_email_export_failMsg = &send_email_export_failMsg;
                %put NOTE:[PXL] send_email_csdw_passOrFail = &send_email_csdw_passOrFail;
                %put NOTE:[PXL] send_email_csdw_failMsg = &send_email_csdw_failMsg;
                %put NOTE:[PXL] send_email_struct_passOrFail = &send_email_struct_passOrFail;
                %put NOTE:[PXL] send_email_struct_failMsg = &send_email_struct_failMsg;
                %put NOTE:[PXL] ;
                %put NOTE:[PXL] emails_study = &emails_study;
                %put NOTE:[PXL] emails_dex = &emails_dex;
                %put NOTE:[PXL] -------------------------------------------------------------------;

                * Create work dataset, used for validation testing;
                data send_email;
                    send_email_sftp_zip_passOrFail = symget('send_email_sftp_zip_passOrFail');
                    send_email_sftp_zip_failMsg = symget('send_email_sftp_zip_failMsg');
                    send_email_extract_passOrFail = symget('send_email_extract_passOrFail');
                    send_email_extract_failMsg = symget('send_email_extract_failMsg');
                    send_email_export_passOrFail = symget('send_email_export_passOrFail');
                    send_email_export_failMsg = symget('send_email_export_failMsg');
                    send_email_csdw_passOrFail = symget('send_email_csdw_passOrFail');
                    send_email_csdw_failMsg = symget('send_email_csdw_failMsg');
                    send_email_struct_passOrFail = symget('send_email_struct_passOrFail');
                    send_email_struct_failMsg = symget('send_email_struct_failMsg');
                    emails_study = symget('emails_study');
                    emails_dex = symget('emails_dex');
                run;

                * Get list of emails to send too;
                %let Send_to_Emails = &emails_study &emails_dex;
                %*let Send_to_Emails = 'nathan.hartley@parexel.com';

                * Send email;
                %if %str("&pfescrf_auto_sendemail") = %str("Y") %then %do;
                    filename Mailbox EMAIL 'Nathan.Hartley@parexel.com'
                        type = "TEXT/HTML"
                        to = (&Send_to_Emails)
                        subject="%left(%trim(&pfescrf_auto_pxl_code)) %left(%trim(&pfescrf_auto_protocol)) Automatic SCRF Creation - %left(%trim(&pfescrf_auto_PassOrFail))";
                        * attach=("") - add this to attach something;

                        data _null_;
                            file Mailbox;
                            put "Hello,<br />";
                            put "<br />";
                            put "This is an automatic generated message by PFZCRON. Review any issue if present, ";
                            put "make updates as needed and run manually by running: '../dm/sasprogs/production/sas93 run_pfescrf_auto.sas'. ";
                            put "Please note that this must be run in SAS92 or SAS93. <br />";
                            put "<br />";
                            put "----------------------------------------------------------------------------------------------------------------<br />";
                            put "&nbsp. <br />";
                            put "Overall Process: &pfescrf_auto_PassOrFail <br />";
                            put "&nbsp. <br />";
                            put "Process Details: <br />";
                            put "<table border='1' style='border: 1px solid black; border-collapse: collapse; padding: 8px;'>";
                            put "   <tr><td>1. PI SFTP Zip Files Download:</td><td>&send_email_sftp_zip_passOrFail.</td></tr>";
                            put "   <tr><td>2. Extract Download:          </td><td>&send_email_extract_passOrFail. </td></tr>";
                            put "   <tr><td>3. Export SCRF:               </td><td>&send_email_export_passOrFail.  </td></tr>";
                            put "   <tr><td>4. CSDW SCRF Validator:       </td><td>&send_email_csdw_passOrFail.    </td></tr>";
                            put "   <tr><td>5. Structure Validator:       </td><td>&send_email_struct_passOrFail.  </td></tr>";
                            put " </table>&nbsp. <br />";

                            %if %str("&pfescrf_auto_FailMsg") ne %str("null") %then %do;
                                put "&pfescrf_auto_FailMsg <br /> &nbsp. <br />";
                            %end;

                            %if %str("&send_email_sftp_zip_failMsg") ne %str("null") %then %do;
                                put "&send_email_sftp_zip_failMsg <br />&nbsp. <br />";
                            %end;

                            %if %str("&send_email_extract_failMsg") ne %str("null") %then %do;
                                put "&send_email_extract_failMsg <br />&nbsp. <br />";
                            %end;

                            %if %str("&send_email_export_failMsg") ne %str("null") %then %do;
                                put "&send_email_export_failMsg <br />&nbsp. <br />";
                            %end;

                            %if %str("&send_email_csdw_failMsg") ne %str("null") %then %do;
                                put "&send_email_csdw_failMsg <br />&nbsp. <br />";
                            %end;                      

                            %if %str("&send_email_struct_failMsg") ne %str("null") %then %do;
                                put "&send_email_struct_failMsg <br />&nbsp. <br />";
                            %end;

                            put "----------------------------------------------------------------------------------------------------------------<br />";
                            put "PMED Link for More Information: <a href=""http://p-med.pxl.int/p-med/livelink.exe/properties/246492060"">Things to know - Auto SCRF.docx</a><br />";
                            put "End of automatic generated email";
                        run;
                    quit;
                %end;

                %_MacEnd(MacroName=SEND_EMAIL);
            %mend send_email;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.4) Setup Internal Macro UPDATE_PATH_FOR_ISSUE;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: update_path_for_issue
            PURPOSE: Reset folder when issues occur
            INPUT: 
                1) pathroot = unix path current resides in 
                2) curdate =  current date in YYYYMMDD
            OUTPUT: 
                1) Move YYYYMMDD folder to error_YYYYMMDD
                2) Update unix symbolic link current to point to previous YYYYMMDD folder
            ;        
            %macro update_path_for_issue(pathroot=null, curdate=null);
                %_MacStart(MacroName=UPDATE_PATH_FOR_ISSUE);

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] pathroot = &pathroot;
                %put NOTE:[PXL] curdate = &curdate;
                %put NOTE:[PXL] ;

                * Path for dated and new err directory;
                %let pathroot_dated = &pathroot/%left(%trim(&curdate))/;
                %let pathroot_err = &pathroot/error_%left(%trim(&curdate));

                %put NOTE:[PXL] Create new directory: &pathroot_err;
                %sysexec %str(rm -rf &pathroot_err 2> /dev/null);
                %sysexec %str(mkdir -p &pathroot_err);

                %put NOTE:[PXL] Moving data from &pathroot_dated to &pathroot_err;
                %sysexec %str(cp -rp &pathroot_dated &pathroot_err 2> /dev/null);
                %sysexec %str(rm -rf &pathroot_dated 2> /dev/null);
                %sysexec %str(rmdir &pathroot_dated 2> /dev/null);

                * Get list of YYYYMMDD folders;
                filename dirlist pipe "ls -la %left(%trim(&pathroot))" ;
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

                * Get max date;
                proc sql noprint;
                    select max(input(dirline2, 8.)) as TargetDate into: TargetDate
                    from _dirlist;
                quit;
                %put NOTE:[PXL] Target Date = &TargetDate;

                * Delete symbolic link current if exists;
                %put NOTE:[PXL] Running: rm &pathroot/current;
                %sysexec %str(rm -f &pathroot/current);

                * Create new symbolic link current;
                %if %eval(&cnt = 0) %then %do;
                    %put NOTE:[PXL] No previous dated folder found, symbolic link current not created.;
                %end;
                %else %if %sysfunc(fileexist(&pathroot/%left(%trim(&TargetDate)))) %then %do;

                    %put NOTE:[PXL] Running: cd &pathroot;
                    %sysexec %str(cd &pathroot);

                    %put NOTE:[PXL] Running: ln -s &pathroot/%left(%trim(&TargetDate)) current;
                    %sysexec %str(ln -s &pathroot/%left(%trim(&TargetDate)) current);
                %end;
                %else %do;
                    %put NOTE:[PXL] No previous dated folder found, symbolic link current not created.;
                %end;                

                %_MacEnd(MacroName=UPDATE_PATH_FOR_ISSUE);
            %mend;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.5) Setup Internal Macro ARCHIVE_TRANSFER;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro archive_transfer;
                %_MacStart(MacroName=ARCHIVE_TRANSFER);

                options nofmterr noquotelenmax;

                data _temp;
                    attrib 
                        pfescrf_auto_pxl_code            length=$10.
                        pfescrf_auto_protocol            length=$10.
                        pfescrf_auto_pi_code             length=$10.
                        pfescrf_auto_RunDateTime         format=IS8601DT.
                        run_by                           length=$10.
                        pfescrf_auto_PassOrFail          length=$10.
                        pfescrf_auto_FailMsg             length=$500.
                        send_email_sftp_zip_passOrFail   length=$10.
                        send_email_sftp_zip_failMsg      length=$500.
                        send_email_extract_passOrFail    length=$10.
                        send_email_extract_failMsg       length=$500.
                        send_email_export_passOrFail     length=$10.
                        send_email_export_failMsg        length=$500.
                        send_email_csdw_passOrFail       length=$10.
                        send_email_csdw_failMsg          length=$500.
                        send_email_struct_passOrFail     length=$200.
                        send_email_struct_failMsg        length=$500.
                        emails_study                     length=$200.
                        emails_dex                       length=$200.
                        pfescrf_auto_confirmedchange     length=$1.
                    ;

                        pfescrf_auto_pxl_code            = "&pfescrf_auto_pxl_code";
                        pfescrf_auto_protocol            = "&pfescrf_auto_protocol";
                        pfescrf_auto_pi_code             = "&pfescrf_auto_pi_code";
                        pfescrf_auto_RunDateTime         = input(symget('pfescrf_auto_RunDateTime'), IS8601DT.);
                        run_by                           = upcase("&sysuserid");
                        pfescrf_auto_PassOrFail          = "&pfescrf_auto_PassOrFail";
                        pfescrf_auto_FailMsg             = "&pfescrf_auto_FailMsg";
                        send_email_sftp_zip_passOrFail   = "&send_email_sftp_zip_passOrFail";
                        send_email_sftp_zip_failMsg      = "&send_email_sftp_zip_failMsg";
                        send_email_extract_passOrFail    = "&send_email_extract_passOrFail";
                        send_email_extract_failMsg       = "&send_email_extract_failMsg";
                        send_email_export_passOrFail     = "&send_email_export_passOrFail";
                        send_email_export_failMsg        = "&send_email_export_failMsg";
                        send_email_csdw_passOrFail       = "&&send_email_csdw_passOrFail";
                        send_email_csdw_failMsg          = "&send_email_csdw_failMsg";
                        send_email_struct_passOrFail     = "&send_email_struct_passOrFail";
                        send_email_struct_failMsg        = "&send_email_struct_failMsg";
                        emails_study                     = "&emails_study";
                        emails_dex                       = "&emails_dex";
                        pfescrf_auto_confirmedchange     = "&pfescrf_auto_confirmedchange";
                run;

                proc sql noprint;
                    select count(*) into: exists_lib_at
                    from sashelp.vtable 
                    where libname = "LIB_AT";
                quit;

                %if %str("&pfescrf_auto_protocol") = %str("DUMMYTEST") %then %do;
                    %put NOTE:[PXL] Transfer Information Record Not Saved: pfescrf_auto_protocol = DUMMYTEST;
                %end;
                %else %do;
                    %if %eval(&exists_lib_at > 0) %then %do;
                        proc sql noprint;
                            select count(*) into: exists
                            from sashelp.vtable 
                            where libname = "LIB_AT"
                                  and memname = "SCRF_TRANSFER_ARCHIVE";
                        quit;
                        %if %eval(&exists = 0) %then %do;
                            data lib_at.scrf_transfer_archive; set _temp; run;
                        %end;
                        %else %do;
                            data lib_at.scrf_transfer_archive; set lib_at.scrf_transfer_archive _temp; run;
                        %end;
                    %end;
                %end;

                %_MacEnd(MacroName=ARCHIVE_TRANSFER);
            %mend archive_transfer;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 3) Setup Process Macros ;
    %put NOTE:[PXL] ***********************************************************************************; 
        %*
         * 3.1) Setup Macro VERIFY_SOURCE_DATA
         * 3.2) Setup Macro SFTP_ZIP
         * 3.3) Setup Macro EXTRACT_DOWNLOAD
         * 3.4) Setup Macro EXPORT_SCRF
         * 3.5) Setup Macro SCRF_CSDW_VALIDATION 
         * 3.6) Setup Macro STRUCTURE_CHANGE
         * 3.7) Setup Macro EMAIL_PCDA_CODING
         *;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.1) Setup Macro VERIFY_SOURCE_DATA ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro verify_source_data;
                %_MacStart(MacroName=VERIFY_SOURCE_DATA);

                %put NOTE:[PXL] 1) Process Global MAD macro DEBUG (option statement);
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

                %put NOTE:[PXL] 2) Verify Global MAD macro GMPXLERR (unsucessiful execution flag);
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
                        %let pfescrf_auto_FailMsg = Global macro GMPXLERR = 1, macro not executed;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                        %goto MacErr;                        
                    %end;

                %put NOTE:[PXL] 3) Verify Input Parameter pfescrf_auto_pxl_code;
                    %if %str("&pfescrf_auto_pxl_code")=%str("null") %then %do;
                        * Default, check if can get from global macro PXL_CODE;

                        * First check if macro PXL_CODE exists;
                        proc sql noprint;
                            select count(*) into :exists
                            from sashelp.vmacro 
                            where name="PXL_CODE";
                        quit;
                        %if %eval(&exists=0) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_pxl_code is null and global macro PXL_CODE does not exist;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                            %goto MacErr;
                        %end;
                        %else %do;
                            %put NOTE:[PXL] Value taken from global macro PXL_CODE=&PXL_CODE;
                            %let pfescrf_auto_pxl_code = &pxl_code;
                        %end;
                    %end;
                    %let pfescrf_auto_pxl_code = %left(%trim(&pfescrf_auto_pxl_code));
                    %put NOTE:[PXL] pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;

                %put NOTE:[PXL] 4) Verify Input Parameter pfescrf_auto_protocol;
                    %if %str("&pfescrf_auto_protocol")=%str("null") %then %do;
                        * Default, check if can get from global macro PXL_CODE;

                        * First check if macro PXL_CODE exists;
                        proc sql noprint;
                            select count(*) into :exists
                            from sashelp.vmacro 
                            where name="PROTOCOL";
                        quit;
                        %if %eval(&exists=0) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_protocol is null and global macro PROTOCOL does not exist;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                            %goto MacErr;
                        %end;
                        %else %do;
                            %put NOTE:[PXL] Value taken from global macro PROTOCOL=&PROTOCOL;
                            %let pfescrf_auto_protocol = &protocol;
                        %end;
                    %end;
                    %let pfescrf_auto_protocol = %left(%trim(&pfescrf_auto_protocol));
                    %put NOTE:[PXL] pfescrf_auto_protocol = &pfescrf_auto_protocol;

                %put NOTE:[PXL] 5) Verify Input Parameter pfescrf_auto_pi_code;
                    %if %str("&pfescrf_auto_pi_code") = %str("null") %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_pi_code is null and must be set;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                        %goto MacErr;
                    %end;
                    %put NOTE:[PXL] pfescrf_auto_pi_code = &pfescrf_auto_pi_code;

                %put NOTE:[PXL] 6) Verify Input Parameter pfescrf_auto_sftpdayspast;
                    %put NOTE:[PXL] pfescrf_auto_sftpdayspast = &pfescrf_auto_sftpdayspast;

                    %let _pass = FAILED;
                    data _null_;
                        raw = symget('pfescrf_auto_sftpdayspast');

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
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_sftpdayspast is not whole number between 1 and 100: &pfescrf_auto_sftpdayspast;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;                    

                %put NOTE:[PXL] 7) Verify Input Parameter pfescrf_auto_double;
                    %if %str("&pfescrf_auto_double") ne %str("Y") 
                        and %str("&pfescrf_auto_double") ne %str("N") %then %do;

                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_double is not Y or N;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 8) Verify Input Parameter pfescrf_auto_path_zip;
                    %if %str("&pfescrf_auto_path_zip") = %str("null") %then %do;
                        * User did not enter a path for zip, use expected standard parth adding current dated folder;
                        %put NOTE:[PXL] Create directory per below if it does not exist, if exists then delete everything in it:;
                        %put NOTE:[PXL] kennet: /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/datasets/download/zip/prod/YYYYMMDD;

                        %let pfescrf_auto_path_zip = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/datasets/download/zip/prod;

                        * Verify expected root directory location exists;
                        %if not %sysfunc(fileexist(&pfescrf_auto_path_zip)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_zip=null but expected directory does not exist: &pfescrf_auto_path_zip;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                        %let pfescrf_auto_path_zip = &pfescrf_auto_path_zip/%left(%trim(&pfescrf_auto_RunDate));

                        * Create directory if does not exist;
                        %sysexec %str(mkdir -p &pfescrf_auto_path_zip);

                        %put NOTE:[PXL] Path to upload and extract zip files: &pfescrf_auto_path_zip;
                    %end;
                    %else %do;
                        * User entered a path for zip;
                        %if not %sysfunc(fileexist(&pfescrf_auto_path_zip)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_zip does not specify a valid directory: &pfescrf_auto_path_zip;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;
                    %end;

                %put NOTE:[PXL] 9) Verify Input Parameter pfescrf_auto_path_code;
                    %if %str("&pfescrf_auto_path_code") = %str("null") %then %do;
                        %put NOTE:[PXL] Input Parameter pfescrf_auto_path_code = null, assume standard location;
                        %let pfescrf_auto_path_code = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/sasprogs/production;
                        
                    %end;

                    %let pfescrf_auto_path_code = &pfescrf_auto_path_code/;
                    %put NOTE:[PXL] pfescrf_auto_path_code set to &pfescrf_auto_path_code;

                    %if not %sysfunc(fileexist(&pfescrf_auto_path_code)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_code does not specify a valid directory: &pfescrf_auto_path_code;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 10) Verify Input Parameter pfescrf_auto_lib_download;
                    proc sql noprint;
                        select path into: pfescrf_auto_path_download 
                        from sashelp.vlibnam 
                        where libname="%upcase(&pfescrf_auto_lib_download)";
                    quit;
                    %put NOTE:[PXL] pfescrf_auto_path_download = &pfescrf_auto_path_download;

                    * Strip /current off if exists;
                    data _null_;
                        pathc = symget('pfescrf_auto_path_download');
                        pathc = tranwrd(pathc, '/current', '');
                        call symput('pfescrf_auto_path_download',pathc);
                    run;

                    %if not %sysfunc(fileexist(&pfescrf_auto_path_download)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_lib_download does not specify a valid libname;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                    %let pfescrf_auto_path_download = %left(%trim(&pfescrf_auto_path_download));
                    %put NOTE:[PXL] pfescrf_auto_path_download = &pfescrf_auto_path_download;
                    %let PFESCRF_AUTO_PATH_DOWNLOAD_CURDT = &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate)); * current dated folder - will be created in extract_download macro;
                    %put NOTE:[PXL] PFESCRF_AUTO_PATH_DOWNLOAD_CURDT = &PFESCRF_AUTO_PATH_DOWNLOAD_CURDT;

                %put NOTE:[PXL] 11) Verify Input Parameter pfescrf_auto_lib_scrf;
                    proc sql noprint;
                        select path into: pfescrf_auto_path_scrf 
                        from sashelp.vlibnam 
                        where libname="%upcase(&pfescrf_auto_lib_scrf)";
                    quit;
                    %put NOTE:[PXL] pfescrf_auto_path_scrf = &pfescrf_auto_path_scrf;

                    %put NOTE:[PXL] Strip /current off if exists;
                    data _null_;
                        pathc = symget('pfescrf_auto_path_scrf');
                        pathc = tranwrd(pathc, '/current', '');
                        call symput('pfescrf_auto_path_scrf',pathc);
                    run;

                    %if not %sysfunc(fileexist(&pfescrf_auto_path_scrf)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_lib_scrf does not specify a valid libname;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                    %let pfescrf_auto_path_scrf = %left(%trim(&pfescrf_auto_path_scrf));
                    %put NOTE:[PXL] pfescrf_auto_path_scrf = &pfescrf_auto_path_scrf;
                    %let pfescrf_auto_path_scrf_curdate = &pfescrf_auto_path_scrf/%left(%trim(&pfescrf_auto_RunDate)); * current dated folder - will be created in extract_download macro;
                    %put NOTE:[PXL] pfescrf_auto_path_scrf_curdate = &pfescrf_auto_path_scrf_curdate;

                %put NOTE:[PXL] 12) Verify Input Parameter pfescrf_auto_path_listings_out;
                    %if %str("&pfescrf_auto_path_listings_out") = %str("null") %then %do;
                        %put NOTE:[PXL] Input Parameter pfescrf_auto_path_listings_out = null, assume standard location;
                        %let pfescrf_auto_path_listings_out = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/listings/%left(%trim(&pfescrf_auto_RunDate));
                    
                        %let pfescrf_auto_path_listings_out = &pfescrf_auto_path_listings_out/;
                        %put NOTE:[PXL] pfescrf_auto_path_listings_out set to &pfescrf_auto_path_listings_out;

                        %sysexec %str(mkdir -p &pfescrf_auto_path_listings_out 2> /dev/null);
                    %end;
                    %else %do;
                        * User entered a value, do not use standard pfizer listings location;
                        %if not %sysfunc(fileexist(&pfescrf_auto_path_listings_out)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_listings_out does not specify a valid directory: &pfescrf_auto_path_listings_out;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;
                    %end;
                    
                %put NOTE:[PXL] 13) Verify Input Parameter pfescrf_auto_path_scrf_metadata;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_scrf_metadata)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_scrf_metadata does not specify a valid directory: &pfescrf_auto_path_scrf_metadata;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 14) Verify Input Parameter pfescrf_auto_path_struct_metadat;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_struct_metadat)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_struct_metadat does not specify a valid directory: &pfescrf_auto_path_struct_metadat;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end; 

                %put NOTE:[PXL] 15) Verify Input Parameter pfescrf_auto_confirmedchange;
                    %if %str("&pfescrf_auto_confirmedchange") ne %str("Y") 
                        and %str("&pfescrf_auto_confirmedchange") ne %str("N") %then %do;

                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_confirmedchange is not Y or N;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 16) Verify Input Parameter pfescrf_auto_file_emails_study exists;
                    %put NOTE:[PXL] 16.1) If pfescrf_auto_file_emails_study=null then set to default standard location;
                        %if %str("&pfescrf_auto_file_emails_study") = %str("null") %then %do;
                            %put NOTE:[PXL] Input parameter pfescrf_auto_file_emails_study is null, set to default expected csv file;
                            %let pfescrf_auto_file_emails_study = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/macros/study_contacts.csv;
                        %end;

                    %put NOTE:[PXL] 16.2) Verify pfescrf_auto_file_emails_study exists;
                        %if not %sysfunc(fileexist(&pfescrf_auto_file_emails_study)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_file_emails_study does not specify a valid file: &pfescrf_auto_file_emails_study;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                    %put NOTE:[PXL] 16.3) Read CSV and check emails exists;

                        %let emails_study = ;
                        %let emails_stat = ;
                        %let emails_pcda = ;

                        %* Macro Variable pfescrf_auto_file_emails_study includes /study_contacts.csv but %pfestudy_contacts only includes path;
                        %local path_study_contacts;
                        %let path_study_contacts = ;
                        data _null_;
                            pathv = symget('pfescrf_auto_file_emails_study');
                            pathv = tranwrd(pathv, '/study_contacts.csv', '');
                            call symput('path_study_contacts', pathv);
                        run;

                        %* Populates from study_contacts.csv per study;
                        %pfestudy_contacts(
                            In_Path_Study_Contacts = &path_study_contacts,
                            Out_MV_Emails_CDBP     = emails_study,
                            Out_MV_Emails_Stat     = emails_stat,
                            Out_MV_Emails_PCDA     = emails_pcda);
                        options nofmterr noquotelenmax;

                        %let nbsp=%nrstr(&nbsp); * Used to insert HTML spaces; 
                        %if %str("&emails_study") = %str("null") or %str("&emails_study") = %str("")%then %do;
                            %let pfescrf_auto_FailMsg=Input Parameter pfescrf_auto_file_emails_study file contains no email addresses for CDBPSAS: <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg &pfescrf_auto_file_emails_study <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg &nbsp <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg Input CSV file should have emails entered as CDBPSAS: <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg na@parexel.com - n/a no email address <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg tbd@parexel.com - to be determined <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg firstname.lastname@parexel.com - one email <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg or use a semi colon to seperate for more 2+ emails;

                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %let emails_study = ; * Cleared for email output;

                            %goto MacErr;
                        %end;

                        %put NOTE:[PXL] emails_study = &emails_study;
                        %put NOTE:[PXL] emails_pcda = &emails_pcda;

                %put NOTE:[PXL] 17) Verify Input Parameter pfescrf_auto_file_emails_dex exists;
                    %put NOTE:[PXL] 17.1) If pfescrf_auto_file_emails_dex=null then set to default standard location;
                        %if %str("&pfescrf_auto_file_emails_dex") = %str("null") %then %do;
                            %put NOTE:[PXL] Input parameter pfescrf_auto_file_emails_dex is null, set to default expected csv file;
                            %let pfescrf_auto_file_emails_dex = /projects/std_pfizer/sacq/metadata/data/dex_emails.csv;
                        %end;

                    %put NOTE:[PXL] 17.2) Verify pfescrf_auto_file_emails_dex exists;
                        %if not %sysfunc(fileexist(&pfescrf_auto_file_emails_dex)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_file_emails_dex does not specify a valid file: &pfescrf_auto_file_emails_dex;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                    %put NOTE:[PXL] 17.3) Read CSV and check emails exists;
                        proc import datafile="&pfescrf_auto_file_emails_dex"
                             out=study_emails
                             dbms=csv
                             replace;
                             getnames=no;
                        run;

                        * study_contacts should have emails entered as:
                          na@parexel.com - n/a so do not use
                          tbd@parexel.com - to be determined so do not use
                          me@parexel.com - one email
                          or use a semi colon to seperate for more 2+ emails;
                        %let emails_dex = null;
                        data _null_;
                            length emails var1 $1500.;
                            retain emails;
                            set study_emails end=eof;

                            if _n_=1 then eamils = '';

                            put var1;

                            if not missing(VAR1)  and VAR1 ne 'na@parexel.com' then do;
                                VAR1 = tranwrd(VAR1, ';', "' '"); * Handle muiltiple email addresse;
                                VAR1 = compress(VAR1,' ');
                                emails = catx(" ", emails, "'", VAR1, "'");
                            end;

                            put "modified: " var1;

                            if eof then do;
                                if not missing(emails) then do;
                                    emails = compress(emails);
                                    emails = tranwrd(emails, "''", "' '");
                                    call symput('emails_dex', emails);
                                end;
                            end;
                        run;

                        %if %str("&emails_dex") = %str("null") or %str("&emails_dex") = %str("") %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_file_emails_study file contains no email addresses: &pfescrf_auto_file_emails_dex;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                        %put NOTE:[PXL] emails_dex = &emails_dex;

                %put NOTE:[PXL] 18) Verify Input Parameter pfescrf_auto_path_transfers;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_transfers)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_transfers does not specify a valid directory: &pfescrf_auto_path_transfers;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;
                    libname lib_at "&pfescrf_auto_path_transfers";

                %goto MacEnd;

                %MacErr:;
                %let GMPXLERR=1;

                %MacEnd:; 
                %put INFO:[PXL] ------------------------------------------------------;
                %put INFO:[PXL] &pfescrf_auto_MacroName: Macro Started; 
                %put INFO:[PXL] File Location: &pfescrf_auto_MacroPath ;
                %put INFO:[PXL] Version Number: &pfescrf_auto_MacroVersion ;
                %put INFO:[PXL] Version Date: &pfescrf_auto_MacroVersionDate ;
                %put INFO:[PXL] Run DateTime: &pfescrf_auto_RunDateTime;       
                %put INFO:[PXL] Run By: %upcase(&sysuserid); 
                %put INFO:[PXL] ;
                %put INFO:[PXL] Purpose: Automatic SCRF Transfers ; 
                %put INFO:[PXL] Input Parameters:;
                %put INFO:[PXL]   1) pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;
                %put INFO:[PXL]   2) pfescrf_auto_protocol = &pfescrf_auto_protocol;
                %put INFO:[PXL]   3) pfescrf_auto_pi_code = &pfescrf_auto_pi_code;
                %put INFO:[PXL]   4) pfescrf_auto_double = &pfescrf_auto_double;
                %put INFO:[PXL]   5) pfescrf_auto_path_zip = &pfescrf_auto_path_zip;
                %put INFO:[PXL]   6) pfescrf_auto_lib_download = &pfescrf_auto_lib_download;
                %put INFO:[PXL]   7) pfescrf_auto_lib_scrf = &pfescrf_auto_lib_scrf;
                %put INFO:[PXL]   8) pfescrf_auto_path_listings_out=&pfescrf_auto_path_listings_out;
                %put INFO:[PXL]   9) pfescrf_auto_path_scrf_metadata=&pfescrf_auto_path_scrf_metadata;
                %put INFO:[PXL]  10) pfescrf_auto_path_struct_metadat=&pfescrf_auto_path_struct_metadat;
                %put INFO:[PXL]  11) pfescrf_auto_confirmedchange=&pfescrf_auto_confirmedchange;
                %put INFO:[PXL]  12) pfescrf_auto_file_emails_study=&pfescrf_auto_file_emails_study;
                %put INFO:[PXL]  13) pfescrf_auto_file_emails_dex=&pfescrf_auto_file_emails_dex;
                %put INFO:[PXL]  14) pfescrf_auto_path_transfers=&pfescrf_auto_path_transfers;
                %put INFO:[PXL]  15) pfescrf_auto_testing=&pfescrf_auto_testing;
                %put INFO:[PXL]  16) pfescrf_auto_sendemail=&pfescrf_auto_sendemail;                
                %put INFO:[PXL] ------------------------------------------------------;

                %_MacEnd(MacroName=VERIFY_SOURCE_DATA);
            %mend verify_source_data;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.2) Setup Macro SFTP_ZIP ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro sftp_zip;
                %_MacStart(MacroName=SFTP_ZIP);

                * Pfizer Global Macro - Gets zip files using generic login and unzips to kennet location;
                %if %str("&pfescrf_auto_testing") = %str("Y") %then %do;
                    %put NOTE:[PXL] pfescrf_auto_testing is Y, testing will simulate macro pfepisftpget PASS run;
                    %global pfepisftpget_PassOrFail pfepisftpget_FailMsg;
                    %let pfepisftpget_PassOrFail = PASS;
                    %let pfepisftpget_FailMsg = null;
                %end;
                %else %do;
                    * Delete contains if present;
                    %sysexec %str(rm -f &pfescrf_auto_path_zip.*.*);

                    %pfepisftpget(
                        _pxl_code=&pfescrf_auto_pxl_code,
                        _protocol=&pfescrf_auto_protocol,
                        pi_code=&pfescrf_auto_pi_code, 
                        dayspast=&pfescrf_auto_sftpdayspast,
                        outputDir=&pfescrf_auto_path_zip);
                %end;

                * Set Eamil macro variables from macro pfepisftpget return global macros;
                %let send_email_sftp_zip_passOrFail = &pfepisftpget_PassOrFail;
                %let send_email_sftp_zip_failMsg = &pfepisftpget_FailMsg;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] send_email_sftp_zip_passOrFail = &send_email_sftp_zip_passOrFail; * Returned global macro with PASS or FAIL;
                %put NOTE:[PXL] send_email_sftp_zip_failMsg = &send_email_sftp_zip_failMsg; * Returned global macro for message if FAILED;
                %put NOTE:[PXL] ;

                %if %str("&pfepisftpget_PassOrFail") ne %str("PASS") %then %do;
                    %let pfescrf_auto_PassOrFail = FAIL;
                    %let GMPXLERR=1;
                %end;

                %goto MacEnd;
            
                %MacErr:;
                %let GMPXLERR=1;

                %MacEnd:; 
                %_MacEnd(MacroName=SFTP_ZIP);
            %mend sftp_zip;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.3) Setup Macro EXTRACT_DOWNLOAD ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro extract_download;
                %_MacStart(MacroName=EXTRACT_DOWNLOAD);
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] MACRO NAME: EXTRACT_DOWNLOAD;
                %put NOTE:[PXL] PURPOSE: Create SAS datasets containing coded data;         
                %put NOTE:[PXL] INPUT PARAMATERS:;
                %put NOTE:[PXL]    1) pfescrf_auto_pxl_code= &pfescrf_auto_pxl_code;
                %put NOTE:[PXL]    2) pfescrf_auto_protocol= &pfescrf_auto_protocol;
                %put NOTE:[PXL]    3) pfescrf_auto_path_code= &pfescrf_auto_path_code;
                %put NOTE:[PXL]    4) pfescrf_auto_lib_download= &pfescrf_auto_lib_download;
                %put NOTE:[PXL]    5) pfescrf_auto_RunDate= &pfescrf_auto_RunDate;
                %put NOTE:[PXL] INPUT: ;
                %put NOTE:[PXL]    1) Raw unzipped txt and xpt files at this location:;
                %put NOTE:[PXL]       &pfescrf_auto_path_code;
                %put NOTE:[PXL] OUTPUT: ;
                %put NOTE:[PXL]    1) SAS datasets to this location:;
                %put NOTE:[PXL]       &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate));
                %put NOTE:[PXL]    2) Symbolic link ../download/current points to %left(%trim(&pfescrf_auto_RunDate));
                %put NOTE:[PXL] ------------------------------------------------------;

                %let send_email_extract_passOrFail = FAIL;
                %let send_email_extract_failMsg = null;

                * 1) Unix command Mkdir –p /projects/<pfizrNNNNNN>/dm/sasprogs/production/logs;
                    %put NOTE:[PXL] Project code path = &pfescrf_auto_path_code;
                    %sysexec %str(mkdir -p &pfescrf_auto_path_code.logs 2> /dev/null);

                * 2) Unix command mv *.log and *.lst files to /logs;
                    %sysexec %str(mv &pfescrf_auto_path_code.*.log &pfescrf_auto_path_code.logs 2> /dev/null);
                    %sysexec %str(mv &pfescrf_auto_path_code.*.lst &pfescrf_auto_path_code.logs 2> /dev/null);
                    %sysexec %str(mv &pfescrf_auto_path_code.*.pdf &pfescrf_auto_path_code.logs 2> /dev/null);

                * 3) Verify extract.sas exists;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_code/extract.sas)) %then %do;
                        %let send_email_extract_failMsg = Extract.sas program does not exist: &pfescrf_auto_path_code/extract.sas;
                        %put %str(ERR)OR: &pfescrf_auto_MacroName: File not found: &pfescrf_auto_path_code/extract.sas;
                        %goto MacErr;               
                    %end;

                * 4) Run via SAS92 extract.sas;
                    %sysexec %str(cd &pfescrf_auto_path_code);
                    x "sas92 extract.sas -noterminal";

                * 5) Check extract.log for any issues;
                    * Get name of log file;
                    filename dirlist pipe "ls -la %left(%trim(&pfescrf_auto_path_code))";
                    data work._dirlist ;
                       length dirline dirline2 $200 ;
                       infile dirlist recfm=v lrecl=200 truncover end=eof;
                       input dirline $1-200 ;
                       dirline2 = substr(dirline,59);
                       if index(dirline2,'extract') > 0 
                          and index(dirline2,'.log') > 0 then do;
                          call symput('extract_log_filname',left(trim(dirline2)));
                       end;
                    run;   
                    %put NOTE:[PXL] extract_log_filname = &extract_log_filname;

                    * Run logcheck on log file;
                        %_MacStart(MacroName=PFELOGCHECK);
                        %pfelogcheck(
                            FileName=&extract_log_filname,
                            _pxl_code=&pfescrf_auto_pxl_code,
                            _protocol=pfescrf_auto_protocol,
                            AddDateTime=N,
                            IgnoreList=null,
                            ShowInUnix=N,
                            CreatePDF=Y);
                        %_MacEnd(MacroName=PFELOGCHECK);
                        options nofmterr noquotelenmax;

                        %put NOTE:[PXL] pfelogcheck_TotalLogIssues = &pfelogcheck_TotalLogIssues; * Total log issues found;
                        %put NOTE:[PXL] pfelogcheck_pdflistingname = &pfelogcheck_pdflistingname; * PDF Listing output file name;

                    * Check if logcheck found issues;
                    %if %eval(&pfelogcheck_TotalLogIssues > 0) %then %do;
                        %put %str(ERR)OR:[PXL] %left(%trim(&pfelogcheck_TotalLogIssues)) SAS log issues found in &pfescrf_auto_path_code.&extract_log_filname;

                        * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate);                     

                        %let send_email_extract_failMsg = FAILED Issues per below: <br />
                            (%left(%trim(&pfelogcheck_TotalLogIssues))) SAS log issues found in &pfescrf_auto_path_code.&extract_log_filname <br />
                            See LOGCHECK generated file: &pfescrf_auto_path_code.<br />&pfelogcheck_pdflistingname.<br />
                            &nbsp <br />
                            Renamed &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate))<br /> 
                            to error_%left(%trim(&pfescrf_auto_RunDate))<br />;
                        %put %str(ERR)OR: &pfescrf_auto_MacroName: extract log found issues;
                        %goto MacErr;
                    %end;
                    %else %do;
                        %put NOTE:[PXL] No issues found in extract log, checking for special characters;
                        * No Issues found in the log;
                        * Check if speical characters note found in log;
                            * Read and review log for <NOTE:[PXL] PFESCRF_AUTO:>;

                            * Read extract log and look for special char found in coding records
                              and save to macro var;
                            %let extract_sc_exist=N;
                            filename inlog "&pfescrf_auto_path_code.&extract_log_filname";
                            data _null_;
                                length msg_raw $256 msg $1500;
                                retain msg;
                                infile inlog;
                                input;
                                msg_raw = _infile_;
                                if index(msg_raw,"NOTE:[PXL] PFESCRF_AUTO:") > 0 then do;
                                    put "NOTE:[PXL]: Found Special Characters in MEDDRA/WHODRUG Coding Records: " msg_raw;
                                    msg_raw = tranwrd(msg_raw, "NOTE:[PXL] PFESCRF_AUTO:", "");
                                    msg = catx("<br />", msg, catx(" ", "Total Issues Found =", scan(msg_raw, 1, ' '), "in", scan(msg_raw, 2, ' ')));
                                    call symput("extract_sc_exist", msg);
                                end;
                                delete;
                            run;
                            %put NOTE:[PXL] extract_sc_exist: &extract_sc_exist;

                            * Set email output message for coding special characters if found;
                            %if %str("&extract_sc_exist") ne %str("N") %then %do;
                                %let send_email_extract_failMsg = Extract: <b>%left(%trim(%str(WARN)))ING!!!</b> Special Characters found in MEDDRA/WHODRUG coded data in raw ASCII files. <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg This will cause data to not include coding levels of data. Please review and submit to PCDA to query. <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg See extract.sas created listings found under: <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg &pfescrf_auto_path_listings_out <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg &nbsp <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg %left(%trim(&extract_sc_exist));
                            %end;
                    %end;

                * 8) Verify number of SAS datasets in download/current match .xpt files from raw;
                    %put NOTE:[PXL] ;
                    %put NOTE:[PXL] Verify number of SAS datasets in download/current match .xpt files from raw; 

                    * Get number of xpt files;
                    filename dirlist pipe "ls -la &pfescrf_auto_path_zip" ;

                    data work._dirlist ;
                        length dirline $200 ;
                        infile dirlist recfm=v lrecl=200 truncover end=eof;
                        input dirline $1-200 ;
                        if index(upcase(dirline),'.XPT') then output;
                    run;                  

                    proc sql noprint;
                        select count(*) into: count_xpt
                        from _dirlist;

                        select count(*) into: count_sas
                        from sashelp.vtable
                        where libname="DOWNLOAD";
                    quit;

                    %if %eval(&count_xpt ne &count_sas) %then %do;
                        %put %str(ERR)OR:[PXL]: The number of XPT files %left(%trim(&count_xpt)) is different from the created SAS datasets %left(%trim(&count_sas));  

                        data _null_;
                            length msg $2500;
                            msg = catx("<br />",
                                "FAILED Issues per below:",
                                "The number of XPT files is different from the created SAS datasets",
                                "Number of XPT Files: %left(%trim(&count_xpt))",
                                "XPT File Location: &pfescrf_auto_path_zip",
                                "Number of SAS Datasets: %left(%trim(&count_sas))",
                                "SAS Datasets : &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate))",
                                "&nbsp ",
                                "Renamed &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate))",
                                "to error_%left(%trim(&pfescrf_auto_RunDate))");
                            call symput('msg_failedissues', msg);
                        run;
                        %let send_email_extract_failMsg = &msg_failedissues;

                        * Update symbolic link current to point to previous dated folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate);
                        %goto MacErr;                       
                    %end;

                    %if %str("&extract_sc_exist") ne %str("N") %then %do;
                        %let send_email_extract_passOrFail = PASS *** WITH %str(WARN)ING ***;
                    %end;
                    %else %do;
                        %let send_email_extract_passOrFail = PASS;
                    %end;

                %goto MacEnd;
              
                %MacErr:;
                %let GMPXLERR=1;

                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro EXTRACT_DOWNLOAD Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_extract_passOrFail = &send_email_extract_passOrFail;
                %put NOTE:[PXL]    send_email_extract_failMsg = &send_email_extract_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;

                %_MacEnd(MacroName=EXTRACT_DOWNLOAD);
            %mend extract_download;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.4) Setup Macro EXPORT_SCRF ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro export_scrf;
                %_MacStart(MacroName=EXPORT_SCRF);
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] MACRO NAME: EXPORT_SCRF;
                %put NOTE:[PXL] PURPOSE: Create CSDW SCRF datasets by running export.sas;
                %put NOTE:[PXL] INPUT PARAMATERS:;
                %put NOTE:[PXL]    1) pfescrf_auto_pxl_code= &pfescrf_auto_pxl_code;
                %put NOTE:[PXL]    2) pfescrf_auto_protocol= &pfescrf_auto_protocol;
                %put NOTE:[PXL]    3) pfescrf_auto_path_code= &pfescrf_auto_path_code;
                %put NOTE:[PXL]    4) pfescrf_auto_lib_scrf= &pfescrf_auto_lib_download;
                %put NOTE:[PXL]    5) pfescrf_auto_path_listings_out= &pfescrf_auto_path_listings_out;
                %put NOTE:[PXL]    6) pfescrf_auto_double= &pfescrf_auto_double;
                %put NOTE:[PXL]    7) pfescrf_auto_double= &pfescrf_auto_double;
                %put NOTE:[PXL]    8) pfescrf_auto_RunDate= &pfescrf_auto_RunDate;
                %put NOTE:[PXL] INPUT: ;
                %put NOTE:[PXL]    1) Raw unzipped txt and xpt files at this location:;
                %put NOTE:[PXL]       &pfescrf_auto_path_code;
                %put NOTE:[PXL] OUTPUT: ;
                %put NOTE:[PXL]    1) CSDW SCRF SAS datasets to this location:;
                %put NOTE:[PXL]       /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/datasets/scrf/%left(%trim(&pfescrf_auto_RunDate))/;
                %put NOTE:[PXL]    2) Symbolic link ../scrf/current points to %left(%trim(&pfescrf_auto_RunDate));
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] ;

                %let send_email_export_passOrFail = FAIL;
                %let send_email_export_failMsg = null;

                %put NOTE:[PXL] 1) Verify export.sas exists;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_code.export.sas)) %then %do;
                        %put %str(ERR)OR:[PXL] File not found: &pfescrf_auto_path_code.export.sas;

                        %let send_email_export_failMsg = FAILED Issues per below: <br />
                            File not found: &pfescrf_auto_path_code.export.sas <br />;            
                                            
                        %let GMPXLERR = 1;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 2) Run via SAS92 export.sas;
                    %sysexec %str(cd &pfescrf_auto_path_code);
                    x "sas92 export.sas -noterminal";

                %put NOTE:[PXL] 3) Check export.log for any issues;
                    * Get name of log file;
                    %let export_log_filname = null;
                    filename dirlist pipe "ls -la &pfescrf_auto_path_code";
                    data work._dirlist ;
                       length dirline dirline2 $200 ;
                       infile dirlist recfm=v lrecl=200 truncover end=eof;
                       input dirline $1-200 ;
                       dirline2 = substr(dirline,59);
                       if index(dirline2,'export') > 0 
                          and index(dirline2,'.log') > 0 then do;
                          call symput('export_log_filname',left(trim(dirline2)));
                       end;
                    run;   
                    %put NOTE:[PXL] export_log_filname = &export_log_filname;

                %put NOTE:[PXL] 4) Run pfelogcheck macro on export log;
                    * Run logcheck on log file;
                        %_MacStart(MacroName=PFELOGCHECK);
                        %pfelogcheck(
                            FileName=&export_log_filname,
                            _pxl_code=&pfescrf_auto_pxl_code,
                            _protocol=pfescrf_auto_protocol,
                            AddDateTime=N,
                            IgnoreList=null,
                            ShowInUnix=N,
                            CreatePDF=Y);
                        %_MacEnd(MacroName=PFELOGCHECK); 
                        options nofmterr noquotelenmax;          

                %put NOTE:[PXL] 5) Check if logcheck found issues;
                    %if %eval(&pfelogcheck_TotalLogIssues > 0) %then %do;
                        %put %str(ERR)OR:[PXL] %left(%trim(&pfelogcheck_TotalLogIssues)) SAS log issues found in &pfescrf_auto_path_code.&export_log_filname;

                        %let send_email_export_failMsg =
                            FAILED Issues per below: <br />
                            (%left(%trim(&pfelogcheck_TotalLogIssues))) SAS log issues found in &pfescrf_auto_path_code.&export_log_filname <br />
                            See LOGCHECK generated file: &pfescrf_auto_path_code <br />
                            &pfelogcheck_pdflistingname <br />
                            &nbsp <br />
                            Renamed &pfescrf_auto_path_scrf_curdate <br />
                            to error_%left(%trim(&pfescrf_auto_RunDate)) <br />;

                        %put %str(ERR)OR: &pfescrf_auto_MacroName: export log found issues;

                        * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                        %goto MacErr;               
                    %end;                

                %put NOTE:[PXL] 6) Verify at least DEMOG SCRF dataset created;
                    proc sql noprint;
                        select count(*) into: cnt
                        from sashelp.vtable
                        where libname="%upcase(&pfescrf_auto_lib_scrf)"
                              and memname="DEMOG";
                    quit;

                    %if %eval(&cnt = 0) %then %do;
                        data _null_;
                            length msg $2500;
                            msg = catx("<br />",
                                "FAILED Issues per below:",
                                "SCRF dataset demog.sas7bdat not found",
                                "SAS Datasets: &pfescrf_auto_path_scrf_curdate",
                                "&nbsp ",
                                "Renamed &pfescrf_auto_path_scrf_curdate",
                                "to error_%left(%trim(&pfescrf_auto_RunDate))");
                            call symput('send_email_export_failMsg', msg);
                        run;

                        %put %str(ERR)OR:[PXL]: SCRF dataset demog.sas7bdat not found;

                        * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                        %goto MacErr;                       
                    %end;
    
                %put NOTE:[PXL] 7) If pfescrf_auto_double=Y, then compare primary to qc SCRF datasets;
                    %if %str("&pfescrf_auto_double") = %str("N") %then %do;
                        %put NOTE:[PXL] pfescrf_auto_double=N, compare primary to qc SCRF datasets not done;
                    %end;
                    %else %do;
                        %put NOTE:[PXL] pfescrf_auto_double=Y, compare primary to qc SCRF datasets;

                        %put NOTE:[PXL] 1) Verify &pfescrf_auto_path_scrf_curdate/qc directory exists;

                        %if not %sysfunc(fileexist(&pfescrf_auto_path_scrf_curdate/qc)) %then %do;
                            %put %str(ERR)OR:[PXL] SCRF Datasets QC Directory not found: &pfescrf_auto_path_scrf_curdate/qc;

                            %let send_email_export_failMsg =
                                FAILED Issues per below: <br />
                                Macro Input Parameter pfescrf_auto_double = Y but SCRF QC directory does not exist: <br />
                                &pfescrf_auto_path_scrf_curdate/qc <br />; 

                            * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                            %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                            %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                           %goto MacErr;               
                        %end;

                        %put NOTE:[PXL] 2) Compare datasets with /qc datasets for exact 1 to 1 match by name and attributes;
                            libname scrfqc "&pfescrf_auto_path_scrf_curdate/qc";

                            %_MacStart(MacroName=PFEPROCCOMPARE);
                            %pfeproccompare(
                                pfeproccompare_pxl_code=&pfescrf_auto_pxl_code,
                                pfeproccompare_protocol=&pfescrf_auto_protocol,
                                pfeproccompare_lib_pri=&pfescrf_auto_lib_scrf,
                                pfeproccompare_lib_qc=scrfqc,
                                pfeproccompare_path_listings=&pfescrf_auto_path_listings_out,
                                pfeproccompare_addDateTime=Y);
                            %_MacEnd(MacroName=PFEPROCCOMPARE);
                            options nofmterr noquotelenmax;

                            libname scrfqc clear;

                            %if %str("&pfeproccompare_PassOrFail") = %str("FAIL") %then %do;
                                data _null_;
                                    length msg $2500;
                                    msg = catx("<br />",
                                        "FAILED Issues per below:",
                                        "Proc Compare Primary against QC SCRF datasets failed",
                                        "Primary: &pfescrf_auto_path_scrf_curdate",
                                        "QC: &pfescrf_auto_path_scrf_curdate/qc",
                                        "&nbsp",
                                        "Total Attrib Issues: %left(%trim(&pfeproccompare_NumIssuesAttrib))",
                                        "Total Value Issues: %left(%trim(&pfeproccompare_NumIssuesValues))",
                                        "&nbsp",
                                        "Output Listings PDF and XLS to Review:",
                                        "&pfeproccompare_ListingName");
                                    call symput('send_email_export_failMsg', msg);
                                run;                                    

                                %put %str(ERR)OR: &pfescrf_auto_MacroName: Proc Compare Primary against QC SCRF datasets failed;

                                * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                                %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                                %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                                %goto MacErr;
                            %end;
                    %end;

                %let send_email_export_passOrFail = PASS;

                %goto MacEnd;
              
                %MacErr:;
                
                %let GMPXLERR=1;

                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro EXPORT_SCRF Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_export_passOrFail = &send_email_extract_passOrFail;
                %put NOTE:[PXL]    send_email_export_failMsg = &send_email_extract_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;

                %_MacEnd(MacroName=EXPORT_SCRF);
            %mend export_scrf;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.5) Setup Macro SCRF_CSDW_VALIDATION ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro scrf_csdw_validation;
                %_MacStart(MacroName=SCRF_CSDW_VALIDATION);

                %let send_email_csdw_passOrFail = FAIL;
                %let send_email_csdw_failMsg = null;

                %_MacStart(MacroName=PFESCRF_CSDW_VALIDATOR);
                %pfescrf_csdw_validator(
                    pfescrf_csdw_validator_metadata=&pfescrf_auto_path_scrf_metadata,
                    pfescrf_csdw_validator_spec=scrf_csdw_pxl,
                    pfescrf_csdw_validator_codelists=codelists,
                    pfescrf_csdw_validator_download=download,
                    pfescrf_csdw_validator_scrf=scrf,
                    pfescrf_csdw_validator_pathlist=&pfescrf_auto_path_listings_out,
                    pfescrf_csdw_validator_protocol=&pfescrf_auto_protocol,
                    pfescrf_csdw_validator_pxl_code=&pfescrf_auto_pxl_code,
                    pfescrf_csdw_validator_AddDT=Y,
                    pfescrf_csdw_validator_test=N);
                %_MacEnd(MacroName=PFESCRF_CSDW_VALIDATOR);
                OPTIONS noquotelenmax;

                %if %str("&pfescrf_csdw_validator_PassFail") = %str("FAIL") %then %do;

                    data _null_;
                        length msg $2500;
                        msg = catx(" <br /> ",
                            "<b>FAIL Issues per below: </b>",
                            "PFESCRF_CSDW_VALIDATOR Found issues comparing data against PDS ",
                            "CSDW SCRF Datasets: &pfescrf_auto_path_scrf_curdate ",
                            "&nbsp ",
                            "Total %str(ERR)ORS Found: %left(%trim(&pfescrf_csdw_validator_NumErr)) ",
                            "Total %str(WARN)INGS Found: %left(%trim(&pfescrf_csdw_validator_NumWarn)) ",
                            "&nbsp ",
                            "Output Listing XLS to Review: ",
                            "&pfescrf_auto_path_listings_out",
                            "&pfescrf_csdw_validator_ListName ",
                            "&nbsp ",
                            "Datasets Renamed &pfescrf_auto_path_scrf_curdate ",
                            "to %str(err)or_%left(%trim(&pfescrf_auto_RunDate)) ");
                        call symput('send_email_csdw_failMsg', msg);
                    run;

                    %if %str("&pfescrf_csdw_validator_ErrMsg") ne %str("null") %then %do;
                        %let send_email_csdw_failMsg = &pfescrf_csdw_validator_ErrMsg &nbsp <br /> &pfescrf_csdw_validator_ErrMsg;
                    %end;

                    %put %str(ERR)OR: &pfescrf_auto_MacroName: PFESCRF_CSDW_VALIDATOR Found issues comparing data against PDS;

                    * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                    %goto MacErr;
                %end;

                %let send_email_csdw_passOrFail = PASS;

                %goto MacEnd;
                %MacErr:;
                %let GMPXLERR=1;
                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro SCRF_CSDW_VALIDATION Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_csdw_passOrFail = &send_email_csdw_passOrFail;
                %put NOTE:[PXL]    send_email_csdw_failMsg = &send_email_csdw_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] ;                    
                %_MacEnd(MacroName=SCRF_CSDW_VALIDATION);
            %mend scrf_csdw_validation;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.6) Setup Macro STRUCTURE_CHANGE ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro structure_change(pxl_code=null);
                %_MacStart(MacroName=STRUCTURE_CHANGE);

                %let send_email_struct_passOrFail = FAIL;
                %let send_email_struct_failMsg = null;                
                
                %_MacStart(MacroName=PFESTRUCTCOMPARE);
                %pfestructcompare(
                    pfestructcompare_metadata=&pfescrf_auto_path_struct_metadat,
                    pfestructcompare_confirmedchange=&pfescrf_auto_confirmedchange,
                    pfestructcompare_protocol=&pfescrf_auto_protocol,
                    pfestructcompare_pxl_code=&pfescrf_auto_pxl_code,
                    pfestructcompare_pathlist=&pfescrf_auto_path_listings_out,
                    pfestructcompare_scrf=&pfescrf_auto_lib_scrf);
                %_MacEnd(MacroName=PFESTRUCTCOMPARE);
                options nofmterr noquotelenmax;

                %let send_email_struct_passOrFail = &pfestructcompare_PassFail;
                %let send_email_struct_failMsg = &pfestructcompare_ErrMsg;

                %put NOTE:[PXL] send_email_struct_passOrFail = &send_email_struct_passOrFail;
                %put NOTE:[PXL] send_email_struct_failMsg = &send_email_struct_failMsg;

                %if %str("&pfestructcompare_PassFail") = %str("FAIL") %then %do;
                    %let send_email_struct_failMsg = &send_email_struct_failMsg <br /> &nbsp <br />;
                    %let send_email_struct_failMsg = &send_email_struct_failMsg Number of Issues Found: %left(%trim(&pfestructcompare_NumDiff)) <br />;
                    %let send_email_struct_failMsg = &send_email_struct_failMsg Listing Created: &pfestructcompare_ListName;

                    %put %str(ERR)OR: &pfescrf_auto_MacroName: PFESTRUCTCOMPARE Found issues comparing data against previous transfer;

                    * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                    %goto MacErr;
                %end;

                %if %str("&pfestructcompare_PassFail") = %str("PASS - CONFIRMED STRUCTURE CHANGE") %then %do;
                    %put NOTE:[PXL] PASS - CONFIRMED STRUCTURE CHANGE, Notify DEX team;

                    %if %str("&pfescrf_auto_sendemail") = %str("Y") %then %do;
                        filename Mailbox EMAIL 'Nathan.Hartley@parexel.com'
                            type = "TEXT/HTML"
                            to = (&emails_dex)
                            subject="%left(%trim(&pfescrf_auto_pxl_code)) %left(%trim(&pfescrf_auto_protocol)) Automatic SCRF Creation - CONFIRMED STRUCTURE CHANGE"
                            attach=("&pfestructcompare_ListName");

                            data _null_;
                                file Mailbox;
                                put "Hello,<br />";
                                put "<br />";
                                put "%left(%trim(&pfescrf_auto_pxl_code)) %left(%trim(&pfescrf_auto_protocol)) <br />";
                                put "User Confirmed Structure Change, see updates: <br />";
                                put "&pfestructcompare_ListName <br />";
                                put "<br />";
                                put "----------------------------------------------------------------------------------------------------------------<br />";
                                put "End of automatic generated email";
                            run;
                        quit;
                    %end;
                %end;

                * Update for consistancy;
                %if %str("&send_email_struct_passOrFail") = %str("PASS - NO DIFFERENCES") %then %do;
                    %let send_email_struct_passOrFail = PASS;
                %end;

                %goto MacEnd;
                %MacErr:;
                %let GMPXLERR=1;
                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro STRUCTURE_CHANGE Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_struct_passOrFail = &send_email_struct_passOrFail;
                %put NOTE:[PXL]    send_email_struct_failMsg = &send_email_struct_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] ; 

                %_MacEnd(MacroName=STRUCTURE_CHANGE);
            %mend structure_change;  

        %* Purpose: Email PCDA if special coding listings exist
         * Input: 
                1) email_pcda_coding_pxl_code = &pfescrf_auto_pxl_code -> PXL Study Code, used for email subject
                2) email_pcda_coding_protocol = &pfescrf_auto_protocol -> PFE Study Code, used for email subject
                3) email_pcda_coding_sendemail = &pfescrf_auto_sendemail -> Y or N, testing=N to not send emails
                4) email_pcda_coding_run = &extract_sc_exist -> N or transfer email text information, used to know if 
                   special characters exist 
                5) email_pcda_coding_path_log = &pfescrf_auto_path_code -> kennet path for extract log
                6) email_pcda_coding_file_log = &extract_log_filname -> extract file log name to look through to get 
                   information about special coding listings created
                7) email_pcda_coding_path_list = &pfescrf_auto_path_listings_out -> kennet path listings are located
                8) email_pcda_coding_emails_pcda = &emails_pcda -> macro variable containing PCDA email addresses
         * Output:
         *   1) Email sent to PCDA and copy PFZCRON with attached special characters in coding listings attached
         *   2) Create work dataset email_pcda_coding used in testing validation only
         *;
            %macro email_pcda_coding(
                email_pcda_coding_pxl_code = &pfescrf_auto_pxl_code,
                email_pcda_coding_protocol = &pfescrf_auto_protocol,
                email_pcda_coding_sendemail = &pfescrf_auto_sendemail,
                email_pcda_coding_run = &extract_sc_exist,
                email_pcda_coding_path_log = &pfescrf_auto_path_code,
                email_pcda_coding_file_log = &extract_log_filname,
                email_pcda_coding_path_list = &pfescrf_auto_path_listings_out,
                email_pcda_coding_emails_pcda = &emails_pcda
                );
                %_MacStart(MacroName=EMAIL_PCDA_CODING);

                %if "&email_pcda_coding_run" ne "N" %then %do;
                    %put NOTE:[PXL] email_pcda_coding_run is not N -> Send PCDA Email of listings;

                    %* Output Input Parameters Used;
                        %put NOTE:[PXL] --------------------------------------------------;
                        %put NOTE:[PXL] Given Input Parameters:;
                        %put NOTE:[PXL] email_pcda_coding_pxl_code = &email_pcda_coding_pxl_code;
                        %put NOTE:[PXL] email_pcda_coding_protocol = &email_pcda_coding_protocol;
                        %put NOTE:[PXL] email_pcda_coding_sendemail = &email_pcda_coding_sendemail;
                        %put NOTE:[PXL] email_pcda_coding_path_log = &email_pcda_coding_path_log;
                        %put NOTE:[PXL] email_pcda_coding_file_log = &email_pcda_coding_file_log;
                        %put NOTE:[PXL] email_pcda_coding_path_list = &email_pcda_coding_path_list;
                        %put NOTE:[PXL] email_pcda_coding_emails_pcda = &email_pcda_coding_emails_pcda;
                        %put NOTE:[PXL] --------------------------------------------------;

                    %* Initialize Variables;
                        options nofmterr noquotelenmax;

                        %local total i subject;
                        %let total = 0; %* Used as total listings created;
                        %let i = 0; %* Used as incremental counter;
                        %let nbsp = %nrstr(&nbsp;);

                        %* Email subject line;
                        %let subject = %left(%trim(&email_pcda_coding_pxl_code));
                        %let subject = &subject %left(%trim(&email_pcda_coding_protocol));
                        %let subject = &subject Special Character Coding Listings *** WARNING ***;

                    %* Read extract log to get listings information;
                        filename inlog "&email_pcda_coding_path_log/&email_pcda_coding_file_log";
                        data _null_;
                            length msg_raw $256;
                            retain cnt 0;
                            infile inlog;
                            input;
                            msg_raw = _infile_;
                            if _n_ = 1 then cnt = 0;
                            if index(msg_raw,"NOTE:[PXL] PFESCRF_AUTO:") > 0 then do;                          
                                put "NOTE:[PXL]: Found Special Characters in MEDDRA/WHODRUG Coding Records: " msg_raw;
                                msg_raw = tranwrd(msg_raw, "NOTE:[PXL] PFESCRF_AUTO:", "");
                                cnt = cnt + 1;
                                call symput(catx("_","listni",strip(put(cnt,8.))), scan(msg_raw, 1, ' ')); %* Issues Found;
                                call symput(catx("_","listname",strip(put(cnt,8.))), scan(msg_raw, 2, ' ')); %* Listing name;
                                call symput("total", strip(put(cnt,8.)));
                            end;
                        run;

                    %* Send email;
                        %* email attachment - list of special coding listings;
                        %let attachments = ;
                        %do i=1 %to &total;
                            %let attachments = &attachments "&email_pcda_coding_path_list/&&listname_&i" name="&&listname_&i" ext="PDF" ;
                        %end;

                        %if %str("&email_pcda_coding_sendemail") = %str("Y") %then %do;
                            filename Mailbox EMAIL 'Nathan.Hartley@parexel.com'
                                type = "TEXT/HTML"
                                to = (&email_pcda_coding_emails_pcda)
                                cc = ('pfzcron@parexel.com')
                                subject="&subject"
                                attach=(&attachments);

                                data _null_;
                                    file Mailbox;
                                    put "Hello,<br />";
                                    put "<br />";
                                    put "This is an automatic generated message by PFZCRON. Special characters were found <br />"; 
                                    put "in raw datasets containing coded data. This will prevent coded data from being mapped. <br />"; 
                                    put "See listings attached for details. These must be corrrected within DataLabs. <br />";
                                    put "<br />";
                                    put "----------------------------------------------------------------------------------------------------------------<br />";
                                    put "&nbsp. <br />";
                                    put "Total Listing(s): %left(%trim(&total)) <br />";
                                    put "&nbsp. <br />";
                                    put "Listing Details: <br />";
                                    put "<table border='1' style='border: 1px solid black; border-collapse: collapse; padding: 8px;'>";
                                    put "   <tr><td>#</td><td>Issues Found</td><td>Listing Name</td></tr>";
                                    %do i=1 %to &total;
                                        put "   <tr><td>&i..</td><td>&&listni_&i</td><td>&&listname_&i</td></tr>";
                                    %end;
                                    put " </table>&nbsp. <br />";
                                    put "----------------------------------------------------------------------------------------------------------------<br />";
                                    put "End of automatic generated email";
                                run;
                            quit;
                        %end; %* End if;

                    %* Create work email used for testcases;
                        data email_pcda_coding;
                            length subject email_pcda_coding_emails_pcda $500 attachments $5000 total_listings $8;

                            subject = symget('subject');
                            %do i=1 %to &total;
                                attachments = catx(",", attachments, "&i &&listni_&i &&listname_&i");
                            %end;                            
                            
                            email_pcda_coding_emails_pcda = "&email_pcda_coding_emails_pcda";
                            total_listings = symget('total');
                        run;                                                
                %end; %* End if;
                %else %do;
                    %put NOTE:[PXL] email_pcda_coding_run = N -> Do Not Send PCDA Email of listings;
                %end;

                %_MacEnd(MacroName=EMAIL_PCDA_CODING);
            %mend email_pcda_coding;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 4) Run Process ;
    %put NOTE:[PXL] ***********************************************************************************;
        %*
         * 1) Macro Start Log Message
         * 2) Verify source data and output run info to log
         * 3) If Auto Run, Verify Run Needed
         * 4) Get latest raw zip files and unzip to kennet
         * 5) Create SAS datasets with coded data from raw data
         * 6) Create SCRF datasets
         * 7) Verify SCRF datasets match CSDW SCRF Specification
         * 8) Verify No/Confirmed Structure Change
         * 9) Set Coding Special Character Warn Flag
         *;

        * 1) Macro Start Log Message;
            %_MacStart(MacroName=&pfescrf_auto_MacroName);

        * 2) Verify source data and output run info to log;
            %verify_source_data;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 3) If Auto Run, Verify Run Needed;
            %put NOTE:[PXL] sysparm = &sysparm;
            %if %str("&sysparm") = %str("AUTO") %then %do;
                %put NOTE:[PXL] SYSPARM = AUTO - Running PFESCRF_AUTO_TRIGGER;

                %* Independant Macro PFESCRF_AUTO_TRIGGER
                 * Purpose: Return to run or not run rest of PFESCRF_AUTO
                 * Input: 1) pxl_code_in - pxl_code
                 *        2) path_metadata_in - directory of metadata
                 *        3) data_transfer_log_in - name of SAS dataset holding past transfer data
                 *        4) file_config_in - name of config csv file
                 * Output: 1) Global macro pfescrf_auto_trigger_run
                 *            YES - Continue run of PFESCRF_AUTO
                 *            NO - Do not run (PASS run within 4 days or PASS today if scheduled run day)
                 *            FAIL - Issue found
                 *;
                %pfescrf_auto_trigger(
                    pxl_code_in=&pfescrf_auto_pxl_code,
                    path_metadata_in=&pfescrf_auto_path_scrf_metadata,
                    data_transfer_log_in=scrf_transfer_archive,
                    file_config_in=pfescrf_auto_trigger.csv);

                %if %str("&pfescrf_auto_trigger_run") = %str("FAIL") %then %do;
                    %put NOTE:[PXL] Macro PFESCRF_AUTO_TRIGGER returned FAIL, terminating macro PFESCRF_AUTO;
                %end;
                %else %if %str("&pfescrf_auto_trigger_run") = %str("NO") %then %do;
                    %put NOTE:[PXL] Macro PFESCRF_AUTO_TRIGGER returned NO and PFESCRF_AUTO does not need run;
                    %let pfescrf_auto_PassOrFail = N/A;
                    %goto NoRun;
                %end;
                %else %do;
                    %put NOTE:[PXL] Macro PFESCRF_AUTO_TRIGGER returned YES and PFESCRF_AUTO does will be run;
                %end;                

                %if &GMPXLERR = 1 %then %do;
                    %goto MacErr;
                %end;
            %end;
            %else %do;
                %put NOTE:[PXL] SYSPARM NOT AUTO - Not Running PFESCRF_AUTO_TRIGGER, Manual Always Run PFESCRF_AUTO;
            %end;

        * 4) Get latest raw zip files and unzip to kennet;
            %sftp_zip;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 5) Create SAS datasets with coded data from raw data;
            %extract_download;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 6) Create SCRF datasets;
            %export_scrf;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 7) Verify SCRF datasets match CSDW SCRF Specification;
            %scrf_csdw_validation;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 8) Verify No/Confirmed Structure Change;
             %structure_change;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;
        
        * 9) Set Coding Special Character Warn Flag;
            %if %str("&extract_sc_exist") ne %str("N") %then %do;
                %let pfescrf_auto_PassOrFail = PASS *** WITH %str(WARN)ING ***;
            %end;
            %else %do;
                %let pfescrf_auto_PassOrFail = PASS;
            %end;

    %put NOTE:[PXL] ******************************************************************************* ;
    %put NOTE:[PXL] 5) Macro End and Cleanup;
    %put NOTE:[PXL] *******************************************************************************;
        %* 
         * 1) Abnormal Macro End 
         * 2) Send Final Email
         * 3) Archive Transfer
         * 4) Derive Run Duration
         * 5) Macro End Setup Reset
         * 6) Macro End Remove Work Datasets
         * 7) Macro End Remove Libnames Created
         * 8) Macro End Remove Catalogs Created
         * 9) Remove Global Macos Used
         * 10) Macro End Final Log Message
         *;

        %goto MacEnd;

        %MacErr:;
        * 1) Abnormal Macro End ;
            %put %str(ERR)OR:[PXL] ------------------------------------------------------;        
            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: Abnormal end to macro;
            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: See log for details;
            %put %str(ERR)OR:[PXL] Global macro GMPXLERR set to 1, macro terminated early;
            %put %str(ERR)OR:[PXL] ------------------------------------------------------;
            %let GMPXLERR=1;

        %MacEnd:;

        * 2) Send Final Transfer Overview Email to Study team and DEX;
            %send_email;    

        %* 2.2) Send Email to PCDA if Special Coding Listings Created;
            %email_pcda_coding;

        * 3) Archive Transfer;
            %archive_transfer; 

        %NoRun:;

        * 4) Derive Run Duration;
            %let end_datetime = ;
            data _null_;
               format startdtm enddtm IS8601DT.;
               startdtm = input(symget('pfescrf_auto_RunDateTime'), IS8601DT.);
               put "Macro Start Date and Time = " startdtm;
               enddtm=datetime();
               put "Macro End Date and Time = " enddtm;
               duration = enddtm - startdtm;
               call symput('end_datetime',"Macro &pfescrf_auto_MacroName Run Time as Hours:Minutes:Seconds: " || left(trim(put(duration, time9.))));   
            run;
            %put ;
            %put NOTE:[PXL] Total Duration = &end_datetime;
            %put ;

        * 5) Macro End Setup Reset;
            title;
            footnote;
            OPTIONS fmterr quotelenmax;; * Reset Ignore format notes in log;
            OPTIONS missing='.';
            options printerpath='';

        * 6) Macro End Remove Work Datasets;
            %macro delmac(wds=null);
                %if %sysfunc(exist(&wds)) %then %do; 
                    proc datasets lib=work nolist; delete &wds; quit; run; 
                %end; 
            %mend delmac;
            %delmac(wds=_temp);
            %delmac(wds=study_emails);
            %delmac(wds=dataset_info_final);
            %delmac(wds=elisting_tab1);
            %delmac(wds=elisting_tab2);
            %delmac(wds=elisting_tab3);
            %delmac(wds=elisting_tab4);
            %delmac(wds=issuesattrib);
            %delmac(wds=logissues);
            %delmac(wds=result_demog);
            %delmac(wds=_spec);
            %delmac(wds=_tab3);
            %delmac(wds=_dirlist);

        * 7) Macro End Remove Libnames Created;
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
            %dellib(libn=LIB_AT);
            %dellib(libn=SCRFQC);

        * 8) Macro End Remove Catalogs Created;
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

        * 9) Remove Global Macos Used;
            %symdel 
                PFEPISFTPGET_FAILMSG PFEPISFTPGET_PASSORFAIL 
                PFELOGCHECK_PDFLISTINGNAME PFELOGCHECK_TOTALLOGISSUES 
                PFEPROCCOMPARE_LISTINGNAME PFEPROCCOMPARE_NUMISSUESATTRIB PFEPROCCOMPARE_NUMISSUESVALUES PFEPROCCOMPARE_PASSORFAIL 
                PFESCRF_CSDW_VALIDATOR_ERRMSG PFESCRF_CSDW_VALIDATOR_LISTNAME PFESCRF_CSDW_VALIDATOR_NUMERR PFESCRF_CSDW_VALIDATOR_NUMWARN 
                PFESCRF_CSDW_VALIDATOR_PASSFAIL PFESTRUCTCOMPARE_ERRMSG PFESTRUCTCOMPARE_LISTNAME PFESTRUCTCOMPARE_NUMDIFF 
                PFESTRUCTCOMPARE_PASSFAIL PFESCRF_AUTO_TRIGGER_RUN PFESCRF_AUTO_TRIGGER_ERRMSG /nowarn;

        * 10) Macro End Final Log Message;
            %_MacEnd(MacroName=&pfescrf_auto_MacroName);

%mend pfescrf_auto;/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20151020       $LastChangedDate: 2016-08-29 11:46:55 -0400 (Mon, 29 Aug 2016) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfescrf_auto.sas $
 
  Files Created:         1) Zip files
                         2) Download files
                         3) CSDW SCRF files
                         4) Listings per process
                         5) Email notifications
 
  Program Purpose:       Purpose of this macro is to: <br />
                         1) Get latest DL raw data zip files <br />
                         2) Run study SAS program extract.sas and check log <br />
                         3) Run study SAS program export.sas and check log <br />
                         4) Run proc compare if double programmed <br />
                         5) Validate CSDW SCRF <br />
                         6) Run structure compare against last approved transfer <br />

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has not been validated for use only in PAREXEL's
                         working environment yet.
 
  Macro Parameters:
 
    Name:                pfescrf_auto_pxl_code
      Allowed Values:    Valid Study PAREXEL code
      Default Value:     null
      Description:       Valid Study PAREXEL code, if null will attempt to get from global macro pxl_code
 
    Name:                pfescrf_auto_protocol
      Allowed Values:    Valid Study Pfizer protocol code
      Default Value:     null
      Description:       Valid Study Pfizer protocol code, if null will attempt to get from global macro protocol
 
    Name:                pfescrf_auto_pi_code
      Allowed Values:    Valid PI Study Code
      Default Value:     null
      Description:       Specifies the study code PI uses for their SFTP server. Must be entered.

    Name:                pfescrf_auto_sftpdayspast
      Allowed Values:    Valid number 1-100
      Default Value:     2
      Description:       Specifies the number of days past current date to look for latest ZIP files

    Name:                pfescrf_auto_double
      Allowed Values:    Y or N
      Default Value:     N
      Description:       Y = run proccompare scrf/current to scrf/current/qc
                         N = do not run proccompare

    Name:                pfescrf_auto_path_zip
      Allowed Values:    Valid directory path
      Default Value:     null
      Description:       Directory path to save PI SFTP zip files created, if null ill use 
                         /projects/pfizrNNNNNN/dm/datasets/zip/prod/YYYYMMDD

    Name:                pfescrf_auto_path_code
      Allowed Values:    Valid directory path
      Default Value:     null
      Description:       Directory path to find extract.sas, export.sas, etc.  If null then will use
                         /projects/pfizrNNNNNN/dm/sasprogs/production

    Name:                pfescrf_auto_lib_download
      Allowed Values:    Valid SAS library
      Default Value:     download
      Description:       Valid SAS library that holds raw download data location 
                         Normall points to /projects/pfizrNNNNNN/dm/datasets/download/current

    Name:                pfescrf_auto_lib_scrf
      Allowed Values:    Valid SAS library
      Default Value:     scrf
      Description:       Valid SAS library that holds mapped csdw scrf data location 
                         Normall points to /projects/pfizrNNNNNN/dm/datasets/scrf/current

    Name:                pfescrf_auto_path_listings_out
      Allowed Values:    Valid directory path
      Default Value:     null
      Description:       Directory path to save listing files created, will use /projects/pfizrNNNNNN/dm/listings/YYYYMMDD 
                         if null

    Name:                pfescrf_auto_path_scrf_metadata
      Allowed Values:    Valid directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Used for testing, path to csdw spec and codelists to check scrf data

    Name:                pfescrf_auto_path_struct_metadat
      Allowed Values:    Valid directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/scrf_csdw
      Description:       Used for testing, path to save transfer SAS structure to check each transfer against,
                         Updated when pfescrf_auto_confirmedchange=Y

    Name:                pfescrf_auto_confirmedchange
      Allowed Values:    Y or N
      Default Value:     N
      Description:       When pfescrf_auto_confirmedchange=Y then pfescrf_auto_path_struct_metadat structure file 
                         is updated, used to check structure against per transfer for changes

    Name:                pfescrf_auto_file_emails_study 
      Allowed Values:    Valid directory path and csv file from certain format
      Default Value:     null
      Description:       Each study has /macros/study_contacts.csv that olds emails to notify CDBP Programmers

    Name:                pfescrf_auto_file_emails_dex
      Allowed Values:    Valid directory path and csv file from certain format
      Default Value:     null
      Description:       Holds standards area DEX team eamil addresses

    Name:                pfescrf_auto_path_transfers
      Allowed Values:    Valid directory path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Holds the dataset that saves each transer information

    Name:                pfescrf_auto_testing
      Allowed Values:    Y or N
      Default Value:     N
      Description:       Used for testing, will bypass PISFTPGET macro

    Name:                pfescrf_auto_sendemail
      Allowed Values:    Y or N
      Default Value:     Y
      Description:       Used for testing, will turn sending email notifications on or off

  Global Macrovariables:
 
    Name:                pfescrf_auto_PassOrFail
      Usage:             Creates
      Description:       Sets to PASS or FAIL depnding on macro outcome

    Name:                pfescrf_auto_FailMsg
      Usage:             Creates
      Description:       Sets to message for any abnormal termination

  Metadata Keys:

    Name:                Reference Specification Data
      Description:       PAREXEL Modified Pfizer Data Standards CSDW SCRF Specification
                         Defaulted locoation per input parameter &pfescrf_auto_path_scrf_metadata
      Dataset:           scrf_csdw_pxl
 
    Name:                Reference Codelist Data
      Description:       Holds all possible Pfizer codelist values
                         Defaulted locoation per input parameter &pfescrf_auto_path_scrf_metadata
      Dataset:           codelists      

    Name:                Reference Data Transfer Structure Data
      Description:       Located per input parameter &pfescrf_auto_path_struct_metadat but default is 
                         /projects/std_pfizer/sacq/metadata/data/scrf_csdw/SCRF_CSDW_&pfescrf_auto_pxl_code. 
                         where input parameter pfescrf_auto_pxl_code is PXL study Code ID. 
                         This holds the last approved study transfer structure metadata to compare against/create/update.
      Dataset:           scrf_csdw_<6 digit PXL Study Code>

    Name:                Reference Specification Data
      Description:       Located per input parameter &pfescrf_auto_path_transfers but default is 
                         /projects/std_pfizer/sacq/metadata/data/. 
                         Adds a record per transfer with transfer details.
      Dataset:           scrf_transfer_archive

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2561 $

-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------
  MODIFICATION VERSIONS:  

  Ver  | Date     | Author | Revisions
  -----------------------------------------------------------------------------
  V1.0 | 20151020 | Nathan Hartley | Initial Version
  V2.0 | 20150826 | Nathan Hartley | 
    1) Updated Interna Macro SEND_EMAIL - Modified PMED link for more info so email is sent
  V3.0 | 20151023 | Nathan Hartley | 
    1) In Section 2.4, Added -rp option to cp command to retain file datetimes and copy /qc folder
    2) Added Section 4.3 Run PFESCRF_AUTO_TRIGGER when sysparm is AUTO
  V4.0 | 20151027 | Nathan Hartley |
    1) Modifed Section 4.3 When PFESCRF_AUTO_TRIGGER returns NO to %goto NoRun
  V5.0 | 20160301 | Nathan Hartley |
    1) Added %update_path_for_issue(pathroot=&pfescrf_auto_path_download after scrf failures too
       this forces raw download data to match scrf data for sacq transfer process
  V6.0 | 20160829 | Nathan Hartley |       
    1) Added submacro email_pcda_coding as seperate email on special coding listings to be sent to PCDA

-----------------------------------------------------------------------------*/

%macro pfescrf_auto(
    pfescrf_auto_pxl_code=null,
    pfescrf_auto_protocol=null,
    pfescrf_auto_pi_code=null,
    pfescrf_auto_sftpdayspast=2,
    pfescrf_auto_double=N,
    pfescrf_auto_path_zip=null,
    pfescrf_auto_path_code=null,
    pfescrf_auto_lib_download=download,
    pfescrf_auto_lib_scrf=scrf,
    pfescrf_auto_path_listings_out=null,
    pfescrf_auto_path_scrf_metadata=/projects/std_pfizer/sacq/metadata/data,
    pfescrf_auto_path_struct_metadat=/projects/std_pfizer/sacq/metadata/scrf_csdw,
    pfescrf_auto_confirmedchange=N,
    pfescrf_auto_file_emails_study=null,
    pfescrf_auto_file_emails_dex=null,
    pfescrf_auto_path_transfers=/projects/std_pfizer/sacq/metadata/data,
    pfescrf_auto_testing=N,
    pfescrf_auto_sendemail=Y);

    %* Macro Process
     * 1) Setup
     * 2) Setup Internal Macros
     * 3) Setup Process Macros
     * 4) Run Process
     * 5) Macro End and Cleanup
     *;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 1) Setup ;
    %put NOTE:[PXL] ***********************************************************************************;

        ods listing close;
        options nofmterr noquotelenmax; * Ignore macro variables longer than 256 char;        
        title;
        footnote;

        * Macro Variable Declarations;
        %let pfescrf_auto_MacroName        = PFESCRF_AUTO;
        %let pfescrf_auto_MacroVersion     = 6.0;
        %let pfescrf_auto_MacroVersionDate = 20160829;

        %local
          SMARTSVN_Version
          MacroLocation
          MacroLastChangeDateTime
        ;

        %let SMARTSVN_Version = ;
        data _null_;
            %* Derive from SMARTSVN updated string as revision number;
            VALUE = "$Rev: 2561 $";
            VALUE = compress(VALUE,'$Rev: ');
            call symput('SMARTSVN_Version', VALUE);
        run;
        %let MacroLocation = ; %* Derive from SMARTSVN updated string below;
        data _null_;
          VALUE = "$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfescrf_auto.sas $";
              %* Replace Smart SVN Repository name with actual UNIX path used;
              VALUE = tranwrd(VALUE,'HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/', '/opt/pxlcommon/stats/');
              VALUE = compress(VALUE,'$');
              call symput('MacroLocation', VALUE);
        run;
        %let MacroLastChangeDateTime = %substr("$LastChangedDate: 2016-08-29 11:46:55 -0400 (Mon, 29 Aug 2016) $", 20, 26); %* Derived from SMARTSVN string;

        %let pfescrf_auto_MacroPath        = &MacroLocation;
        %let pfescrf_auto_RunDateTime      = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));  
        %let pfescrf_auto_RunDate          = %sysfunc(left(%sysfunc(date(), yymmddn8.)));

        * Global return macros;
        %global pfescrf_auto_PassOrFail pfescrf_auto_FailMsg;
        %let pfescrf_auto_PassOrFail = FAIL;
        %let pfescrf_auto_FailMsg = null;

        * Declare local macro variables;
        %let pfescrf_auto_path_zip_full = ; * Will add current date YYYYMMDD to &pfescrf_auto_path_zip to use to save and extract zip files;
        %let pfescrf_auto_path_download = null; * Used for root unix path of lib pfescrf_auto_lib_download without the /current;
        %let PFESCRF_AUTO_PATH_DOWNLOAD_CURDT = null; * library download path with current date YYYYMMDD instead of /current;
        %let pfescrf_auto_path_scrf = null; * library scrf path without the /current;
        %let pfescrf_auto_path_scrf_curdate = null; * library scrf path with current date YYYYMMDD instead of /current;
        %let emails_dex = ; * email address list for DEX team;
        %let emails_study = ; %* email address list for CDBPSAS per study_contacts;        
        %let emails_stat = ; %* email address list for STATPRG per study_contacts;
        %let emails_pcda = ; %* email address list for PCDA per study_contacts;
        %let macro_path_total = 0; * Used for _macstart and _macend for macro breadcrumbs;
        %let extract_sc_exist = N; * Used for extract warnings found in log for coded data;

        * Dclare local macro variables for send_email;
        %let nbsp=%nrstr(&nbsp); * Used to insert HTML spaces;      

        * Send Email macro variabels. Set during each process. Email sent as end of macro.;
        %let send_email_sftp_zip_passOrFail = Not Completed;
        %let send_email_sftp_zip_failMsg = null;
        %let send_email_extract_passOrFail = Not Completed;
        %let send_email_extract_failMsg = null;
        %let send_email_export_passOrFail = Not Completed;
        %let send_email_export_failMsg = null;
        %let send_email_csdw_passOrFail = Not Completed;
        %let send_email_csdw_failMsg = null;
        %let send_email_struct_passOrFail = Not Completed;
        %let send_email_struct_failMsg = null;

        %put INFO:[PXL]----------------------------------------------;
        %put INFO:[PXL] &pfescrf_auto_MacroName: Macro Started; 
        %put INFO:[PXL] File Location: &pfescrf_auto_MacroPath ;
        %put INFO:[PXL] Version Number: &pfescrf_auto_MacroVersion ;
        %put INFO:[PXL] Version Date: &pfescrf_auto_MacroVersionDate ;
        %put INFO:[PXL] Run DateTime: &pfescrf_auto_RunDateTime;
        %put INFO:[PXL] SMARTSVN Revision: &SMARTSVN_Version;
        %put INFO:[PXL] SMARTSVN LastUpdate: &MacroLastChangeDateTime;                
        %put INFO:[PXL] ;
        %put INFO:[PXL] Purpose: Automatic SCRF Transfers ; 
        %put INFO:[PXL] Input Parameters:;
        %put INFO:[PXL]   1) pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;
        %put INFO:[PXL]   2) pfescrf_auto_protocol = &pfescrf_auto_protocol;
        %put INFO:[PXL]   3) pfescrf_auto_pi_code = &pfescrf_auto_pi_code;
        %put INFO:[PXL]   4) pfescrf_auto_double = &pfescrf_auto_double;
        %put INFO:[PXL]   5) pfescrf_auto_path_zip = &pfescrf_auto_path_zip;
        %put INFO:[PXL]   6) pfescrf_auto_lib_download = &pfescrf_auto_lib_download;
        %put INFO:[PXL]   7) pfescrf_auto_lib_scrf = &pfescrf_auto_lib_scrf;
        %put INFO:[PXL]   8) pfescrf_auto_path_listings_out=&pfescrf_auto_path_listings_out;
        %put INFO:[PXL]   9) pfescrf_auto_path_scrf_metadata=&pfescrf_auto_path_scrf_metadata;
        %put INFO:[PXL]  10) pfescrf_auto_path_struct_metadat=&pfescrf_auto_path_struct_metadat;
        %put INFO:[PXL]  11) pfescrf_auto_confirmedchange=&pfescrf_auto_confirmedchange;
        %put INFO:[PXL]  12) pfescrf_auto_file_emails_study=&pfescrf_auto_file_emails_study;
        %put INFO:[PXL]  13) pfescrf_auto_file_emails_dex=&pfescrf_auto_file_emails_dex;
        %put INFO:[PXL]  14) pfescrf_auto_path_transfers=&pfescrf_auto_path_transfers;
        %put INFO:[PXL]  15) pfescrf_auto_testing=&pfescrf_auto_testing;
        %put INFO:[PXL]  16) pfescrf_auto_sendemail=&pfescrf_auto_sendemail;
        %put INFO:[PXL]----------------------------------------------;            

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 2) Setup Internal Macros ;
    %put NOTE:[PXL] ***********************************************************************************;
        %*
         * 2.1 _MacStart
         * 2.2 _MacEnd
         * 2.3 SEND_EMAIL
         * 2.4 UPDATE_PATH_FOR_ISSUE
         * 2.5 ARCHIVE_TRANSFER
         *;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.1) Setup Internal Macro _MacStart;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: _MacStart
            PURPOSE: Output log message for start of macro
            INPUT: 
                1) MacroName - name of macro starting
                2) macro_path_total - macro for number of total nested macros
                3) macro_path_<number> - macro array of nested macros
            OUTPUT: 
                1) log message
                2) macro_path_total - adds 1
                3) macro_path_<number> - adds macro to nested list array
            ;
            %macro _MacStart(MacroName=null);
                * Derive macro path;
                %let macro_path_total = %eval(&macro_path_total + 1);
                %let macro_path_total = %left(%trim(&macro_path_total));
                
                %symdel macro_path_&macro_path_total /NOWARN;
                %global macro_path_&macro_path_total;
                %let macro_path_&macro_path_total = &MacroName;
                
                %let _path = >> &macro_path_1;
                %do i=2 %to &macro_path_total;
                    %let _path = &_path > &&macro_path_&i;
                %end;

                * Log message;
                %put INFO[PXL]: ------------------------------------------------------;
                %put INFO[PXL]: &MacroName.: Macro Started;
                %put INFO[PXL]: Macro Path: &_path;
                %put INFO[PXL]: ------------------------------------------------------;
            %mend _MacStart;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.2) Setup Internal Macro _MacEnd;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: _MacEnd
            PURPOSE: Output log message for End of macro
            INPUT: 
                1) MacroName - name of macro starting
                2) macro_path_total - macro for number of total nested macros
                3) macro_path_<number> - macro array of nested macros
            OUTPUT: 
                1) log message
                2) macro_path_total - subtracts 1
                3) macro_path_<number> - removes macro to nested list array
            ;
            %macro _MacEnd(MacroName=null);
                * Derive macro path;
                %let _path = >> &macro_path_1;
                %do i=2 %to &macro_path_total;
                    %let _path = &_path > &&macro_path_&i;
                %end;

                * Log message;
                %put INFO[PXL]: ------------------------------------------------------;
                %put INFO[PXL]: Macro Path: &_path;
                %put INFO[PXL]: &MacroName.: Macro Completed;
                %put INFO[PXL]: ------------------------------------------------------;

                %symdel macro_path_&macro_path_total /NOWARN;
                %let macro_path_total = %eval(&macro_path_total - 1);          
            %mend _MacEnd; 

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.3) Setup Internal Macro SEND_EMAIL;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: send_email
            PURPOSE: Output fail message and email details
            INPUT: 
                1) msg=fail message text
            OUTPUT: 
                1) log message
                2) email of issue details
            ;
            %macro send_email;
                %_MacStart(MacroName=SEND_EMAIL);

                %put NOTE:[PXL] -------------------------------------------------------------------;
                %put NOTE:[PXL] Macro Variable Input Parameters:;
                %put NOTE:[PXL] pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;
                %put NOTE:[PXL] pfescrf_auto_protocol = &pfescrf_auto_protocol;
                %put NOTE:[PXL] pfescrf_auto_PassOrFail = &pfescrf_auto_PassOrFail;
                %put NOTE:[PXL] pfescrf_auto_FailMsg = &pfescrf_auto_FailMsg;
                %put NOTE:[PXL] send_email_sftp_zip_passOrFail = &send_email_sftp_zip_passOrFail;
                %put NOTE:[PXL] send_email_sftp_zip_failMsg = &send_email_sftp_zip_failMsg;
                %put NOTE:[PXL] send_email_extract_passOrFail = &send_email_extract_passOrFail;
                %put NOTE:[PXL] send_email_extract_failMsg = &send_email_extract_failMsg;
                %put NOTE:[PXL] send_email_export_passOrFail = &send_email_export_passOrFail;
                %put NOTE:[PXL] send_email_export_failMsg = &send_email_export_failMsg;
                %put NOTE:[PXL] send_email_csdw_passOrFail = &send_email_csdw_passOrFail;
                %put NOTE:[PXL] send_email_csdw_failMsg = &send_email_csdw_failMsg;
                %put NOTE:[PXL] send_email_struct_passOrFail = &send_email_struct_passOrFail;
                %put NOTE:[PXL] send_email_struct_failMsg = &send_email_struct_failMsg;
                %put NOTE:[PXL] ;
                %put NOTE:[PXL] emails_study = &emails_study;
                %put NOTE:[PXL] emails_dex = &emails_dex;
                %put NOTE:[PXL] -------------------------------------------------------------------;

                * Create work dataset, used for validation testing;
                data send_email;
                    send_email_sftp_zip_passOrFail = symget('send_email_sftp_zip_passOrFail');
                    send_email_sftp_zip_failMsg = symget('send_email_sftp_zip_failMsg');
                    send_email_extract_passOrFail = symget('send_email_extract_passOrFail');
                    send_email_extract_failMsg = symget('send_email_extract_failMsg');
                    send_email_export_passOrFail = symget('send_email_export_passOrFail');
                    send_email_export_failMsg = symget('send_email_export_failMsg');
                    send_email_csdw_passOrFail = symget('send_email_csdw_passOrFail');
                    send_email_csdw_failMsg = symget('send_email_csdw_failMsg');
                    send_email_struct_passOrFail = symget('send_email_struct_passOrFail');
                    send_email_struct_failMsg = symget('send_email_struct_failMsg');
                    emails_study = symget('emails_study');
                    emails_dex = symget('emails_dex');
                run;

                * Get list of emails to send too;
                %let Send_to_Emails = &emails_study &emails_dex;
                %*let Send_to_Emails = 'nathan.hartley@parexel.com';

                * Send email;
                %if %str("&pfescrf_auto_sendemail") = %str("Y") %then %do;
                    filename Mailbox EMAIL 'Nathan.Hartley@parexel.com'
                        type = "TEXT/HTML"
                        to = (&Send_to_Emails)
                        subject="%left(%trim(&pfescrf_auto_pxl_code)) %left(%trim(&pfescrf_auto_protocol)) Automatic SCRF Creation - %left(%trim(&pfescrf_auto_PassOrFail))";
                        * attach=("") - add this to attach something;

                        data _null_;
                            file Mailbox;
                            put "Hello,<br />";
                            put "<br />";
                            put "This is an automatic generated message by PFZCRON. Review any issue if present, ";
                            put "make updates as needed and run manually by running: '../dm/sasprogs/production/sas93 run_pfescrf_auto.sas'. ";
                            put "Please note that this must be run in SAS92 or SAS93. <br />";
                            put "<br />";
                            put "----------------------------------------------------------------------------------------------------------------<br />";
                            put "&nbsp. <br />";
                            put "Overall Process: &pfescrf_auto_PassOrFail <br />";
                            put "&nbsp. <br />";
                            put "Process Details: <br />";
                            put "<table border='1' style='border: 1px solid black; border-collapse: collapse; padding: 8px;'>";
                            put "   <tr><td>1. PI SFTP Zip Files Download:</td><td>&send_email_sftp_zip_passOrFail.</td></tr>";
                            put "   <tr><td>2. Extract Download:          </td><td>&send_email_extract_passOrFail. </td></tr>";
                            put "   <tr><td>3. Export SCRF:               </td><td>&send_email_export_passOrFail.  </td></tr>";
                            put "   <tr><td>4. CSDW SCRF Validator:       </td><td>&send_email_csdw_passOrFail.    </td></tr>";
                            put "   <tr><td>5. Structure Validator:       </td><td>&send_email_struct_passOrFail.  </td></tr>";
                            put " </table>&nbsp. <br />";

                            %if %str("&pfescrf_auto_FailMsg") ne %str("null") %then %do;
                                put "&pfescrf_auto_FailMsg <br /> &nbsp. <br />";
                            %end;

                            %if %str("&send_email_sftp_zip_failMsg") ne %str("null") %then %do;
                                put "&send_email_sftp_zip_failMsg <br />&nbsp. <br />";
                            %end;

                            %if %str("&send_email_extract_failMsg") ne %str("null") %then %do;
                                put "&send_email_extract_failMsg <br />&nbsp. <br />";
                            %end;

                            %if %str("&send_email_export_failMsg") ne %str("null") %then %do;
                                put "&send_email_export_failMsg <br />&nbsp. <br />";
                            %end;

                            %if %str("&send_email_csdw_failMsg") ne %str("null") %then %do;
                                put "&send_email_csdw_failMsg <br />&nbsp. <br />";
                            %end;                      

                            %if %str("&send_email_struct_failMsg") ne %str("null") %then %do;
                                put "&send_email_struct_failMsg <br />&nbsp. <br />";
                            %end;

                            put "----------------------------------------------------------------------------------------------------------------<br />";
                            put "PMED Link for More Information: <a href=""http://p-med.pxl.int/p-med/livelink.exe/properties/246492060"">Things to know - Auto SCRF.docx</a><br />";
                            put "End of automatic generated email";
                        run;
                    quit;
                %end;

                %_MacEnd(MacroName=SEND_EMAIL);
            %mend send_email;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.4) Setup Internal Macro UPDATE_PATH_FOR_ISSUE;
        %put NOTE:[PXL] ***********************************************************************************;
            * MACRO NAME: update_path_for_issue
            PURPOSE: Reset folder when issues occur
            INPUT: 
                1) pathroot = unix path current resides in 
                2) curdate =  current date in YYYYMMDD
            OUTPUT: 
                1) Move YYYYMMDD folder to error_YYYYMMDD
                2) Update unix symbolic link current to point to previous YYYYMMDD folder
            ;        
            %macro update_path_for_issue(pathroot=null, curdate=null);
                %_MacStart(MacroName=UPDATE_PATH_FOR_ISSUE);

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] pathroot = &pathroot;
                %put NOTE:[PXL] curdate = &curdate;
                %put NOTE:[PXL] ;

                * Path for dated and new err directory;
                %let pathroot_dated = &pathroot/%left(%trim(&curdate))/;
                %let pathroot_err = &pathroot/error_%left(%trim(&curdate));

                %put NOTE:[PXL] Create new directory: &pathroot_err;
                %sysexec %str(rm -rf &pathroot_err 2> /dev/null);
                %sysexec %str(mkdir -p &pathroot_err);

                %put NOTE:[PXL] Moving data from &pathroot_dated to &pathroot_err;
                %sysexec %str(cp -rp &pathroot_dated &pathroot_err 2> /dev/null);
                %sysexec %str(rm -rf &pathroot_dated 2> /dev/null);
                %sysexec %str(rmdir &pathroot_dated 2> /dev/null);

                * Get list of YYYYMMDD folders;
                filename dirlist pipe "ls -la %left(%trim(&pathroot))" ;
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

                * Get max date;
                proc sql noprint;
                    select max(input(dirline2, 8.)) as TargetDate into: TargetDate
                    from _dirlist;
                quit;
                %put NOTE:[PXL] Target Date = &TargetDate;

                * Delete symbolic link current if exists;
                %put NOTE:[PXL] Running: rm &pathroot/current;
                %sysexec %str(rm -f &pathroot/current);

                * Create new symbolic link current;
                %if %eval(&cnt = 0) %then %do;
                    %put NOTE:[PXL] No previous dated folder found, symbolic link current not created.;
                %end;
                %else %if %sysfunc(fileexist(&pathroot/%left(%trim(&TargetDate)))) %then %do;

                    %put NOTE:[PXL] Running: cd &pathroot;
                    %sysexec %str(cd &pathroot);

                    %put NOTE:[PXL] Running: ln -s &pathroot/%left(%trim(&TargetDate)) current;
                    %sysexec %str(ln -s &pathroot/%left(%trim(&TargetDate)) current);
                %end;
                %else %do;
                    %put NOTE:[PXL] No previous dated folder found, symbolic link current not created.;
                %end;                

                %_MacEnd(MacroName=UPDATE_PATH_FOR_ISSUE);
            %mend;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 2.5) Setup Internal Macro ARCHIVE_TRANSFER;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro archive_transfer;
                %_MacStart(MacroName=ARCHIVE_TRANSFER);

                options nofmterr noquotelenmax;

                data _temp;
                    attrib 
                        pfescrf_auto_pxl_code            length=$10.
                        pfescrf_auto_protocol            length=$10.
                        pfescrf_auto_pi_code             length=$10.
                        pfescrf_auto_RunDateTime         format=IS8601DT.
                        run_by                           length=$10.
                        pfescrf_auto_PassOrFail          length=$10.
                        pfescrf_auto_FailMsg             length=$500.
                        send_email_sftp_zip_passOrFail   length=$10.
                        send_email_sftp_zip_failMsg      length=$500.
                        send_email_extract_passOrFail    length=$10.
                        send_email_extract_failMsg       length=$500.
                        send_email_export_passOrFail     length=$10.
                        send_email_export_failMsg        length=$500.
                        send_email_csdw_passOrFail       length=$10.
                        send_email_csdw_failMsg          length=$500.
                        send_email_struct_passOrFail     length=$200.
                        send_email_struct_failMsg        length=$500.
                        emails_study                     length=$200.
                        emails_dex                       length=$200.
                        pfescrf_auto_confirmedchange     length=$1.
                    ;

                        pfescrf_auto_pxl_code            = "&pfescrf_auto_pxl_code";
                        pfescrf_auto_protocol            = "&pfescrf_auto_protocol";
                        pfescrf_auto_pi_code             = "&pfescrf_auto_pi_code";
                        pfescrf_auto_RunDateTime         = input(symget('pfescrf_auto_RunDateTime'), IS8601DT.);
                        run_by                           = upcase("&sysuserid");
                        pfescrf_auto_PassOrFail          = "&pfescrf_auto_PassOrFail";
                        pfescrf_auto_FailMsg             = "&pfescrf_auto_FailMsg";
                        send_email_sftp_zip_passOrFail   = "&send_email_sftp_zip_passOrFail";
                        send_email_sftp_zip_failMsg      = "&send_email_sftp_zip_failMsg";
                        send_email_extract_passOrFail    = "&send_email_extract_passOrFail";
                        send_email_extract_failMsg       = "&send_email_extract_failMsg";
                        send_email_export_passOrFail     = "&send_email_export_passOrFail";
                        send_email_export_failMsg        = "&send_email_export_failMsg";
                        send_email_csdw_passOrFail       = "&&send_email_csdw_passOrFail";
                        send_email_csdw_failMsg          = "&send_email_csdw_failMsg";
                        send_email_struct_passOrFail     = "&send_email_struct_passOrFail";
                        send_email_struct_failMsg        = "&send_email_struct_failMsg";
                        emails_study                     = "&emails_study";
                        emails_dex                       = "&emails_dex";
                        pfescrf_auto_confirmedchange     = "&pfescrf_auto_confirmedchange";
                run;

                proc sql noprint;
                    select count(*) into: exists_lib_at
                    from sashelp.vtable 
                    where libname = "LIB_AT";
                quit;

                %if %str("&pfescrf_auto_protocol") = %str("DUMMYTEST") %then %do;
                    %put NOTE:[PXL] Transfer Information Record Not Saved: pfescrf_auto_protocol = DUMMYTEST;
                %end;
                %else %do;
                    %if %eval(&exists_lib_at > 0) %then %do;
                        proc sql noprint;
                            select count(*) into: exists
                            from sashelp.vtable 
                            where libname = "LIB_AT"
                                  and memname = "SCRF_TRANSFER_ARCHIVE";
                        quit;
                        %if %eval(&exists = 0) %then %do;
                            data lib_at.scrf_transfer_archive; set _temp; run;
                        %end;
                        %else %do;
                            data lib_at.scrf_transfer_archive; set lib_at.scrf_transfer_archive _temp; run;
                        %end;
                    %end;
                %end;

                %_MacEnd(MacroName=ARCHIVE_TRANSFER);
            %mend archive_transfer;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 3) Setup Process Macros ;
    %put NOTE:[PXL] ***********************************************************************************; 
        %*
         * 3.1) Setup Macro VERIFY_SOURCE_DATA
         * 3.2) Setup Macro SFTP_ZIP
         * 3.3) Setup Macro EXTRACT_DOWNLOAD
         * 3.4) Setup Macro EXPORT_SCRF
         * 3.5) Setup Macro SCRF_CSDW_VALIDATION 
         * 3.6) Setup Macro STRUCTURE_CHANGE
         * 3.7) Setup Macro EMAIL_PCDA_CODING
         *;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.1) Setup Macro VERIFY_SOURCE_DATA ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro verify_source_data;
                %_MacStart(MacroName=VERIFY_SOURCE_DATA);

                %put NOTE:[PXL] 1) Process Global MAD macro DEBUG (option statement);
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

                %put NOTE:[PXL] 2) Verify Global MAD macro GMPXLERR (unsucessiful execution flag);
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
                        %let pfescrf_auto_FailMsg = Global macro GMPXLERR = 1, macro not executed;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                        %goto MacErr;                        
                    %end;

                %put NOTE:[PXL] 3) Verify Input Parameter pfescrf_auto_pxl_code;
                    %if %str("&pfescrf_auto_pxl_code")=%str("null") %then %do;
                        * Default, check if can get from global macro PXL_CODE;

                        * First check if macro PXL_CODE exists;
                        proc sql noprint;
                            select count(*) into :exists
                            from sashelp.vmacro 
                            where name="PXL_CODE";
                        quit;
                        %if %eval(&exists=0) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_pxl_code is null and global macro PXL_CODE does not exist;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                            %goto MacErr;
                        %end;
                        %else %do;
                            %put NOTE:[PXL] Value taken from global macro PXL_CODE=&PXL_CODE;
                            %let pfescrf_auto_pxl_code = &pxl_code;
                        %end;
                    %end;
                    %let pfescrf_auto_pxl_code = %left(%trim(&pfescrf_auto_pxl_code));
                    %put NOTE:[PXL] pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;

                %put NOTE:[PXL] 4) Verify Input Parameter pfescrf_auto_protocol;
                    %if %str("&pfescrf_auto_protocol")=%str("null") %then %do;
                        * Default, check if can get from global macro PXL_CODE;

                        * First check if macro PXL_CODE exists;
                        proc sql noprint;
                            select count(*) into :exists
                            from sashelp.vmacro 
                            where name="PROTOCOL";
                        quit;
                        %if %eval(&exists=0) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_protocol is null and global macro PROTOCOL does not exist;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                            %goto MacErr;
                        %end;
                        %else %do;
                            %put NOTE:[PXL] Value taken from global macro PROTOCOL=&PROTOCOL;
                            %let pfescrf_auto_protocol = &protocol;
                        %end;
                    %end;
                    %let pfescrf_auto_protocol = %left(%trim(&pfescrf_auto_protocol));
                    %put NOTE:[PXL] pfescrf_auto_protocol = &pfescrf_auto_protocol;

                %put NOTE:[PXL] 5) Verify Input Parameter pfescrf_auto_pi_code;
                    %if %str("&pfescrf_auto_pi_code") = %str("null") %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_pi_code is null and must be set;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                        %goto MacErr;
                    %end;
                    %put NOTE:[PXL] pfescrf_auto_pi_code = &pfescrf_auto_pi_code;

                %put NOTE:[PXL] 6) Verify Input Parameter pfescrf_auto_sftpdayspast;
                    %put NOTE:[PXL] pfescrf_auto_sftpdayspast = &pfescrf_auto_sftpdayspast;

                    %let _pass = FAILED;
                    data _null_;
                        raw = symget('pfescrf_auto_sftpdayspast');

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
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_sftpdayspast is not whole number between 1 and 100: &pfescrf_auto_sftpdayspast;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;                    

                %put NOTE:[PXL] 7) Verify Input Parameter pfescrf_auto_double;
                    %if %str("&pfescrf_auto_double") ne %str("Y") 
                        and %str("&pfescrf_auto_double") ne %str("N") %then %do;

                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_double is not Y or N;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg; 
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 8) Verify Input Parameter pfescrf_auto_path_zip;
                    %if %str("&pfescrf_auto_path_zip") = %str("null") %then %do;
                        * User did not enter a path for zip, use expected standard parth adding current dated folder;
                        %put NOTE:[PXL] Create directory per below if it does not exist, if exists then delete everything in it:;
                        %put NOTE:[PXL] kennet: /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/datasets/download/zip/prod/YYYYMMDD;

                        %let pfescrf_auto_path_zip = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/datasets/download/zip/prod;

                        * Verify expected root directory location exists;
                        %if not %sysfunc(fileexist(&pfescrf_auto_path_zip)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_zip=null but expected directory does not exist: &pfescrf_auto_path_zip;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                        %let pfescrf_auto_path_zip = &pfescrf_auto_path_zip/%left(%trim(&pfescrf_auto_RunDate));

                        * Create directory if does not exist;
                        %sysexec %str(mkdir -p &pfescrf_auto_path_zip);

                        %put NOTE:[PXL] Path to upload and extract zip files: &pfescrf_auto_path_zip;
                    %end;
                    %else %do;
                        * User entered a path for zip;
                        %if not %sysfunc(fileexist(&pfescrf_auto_path_zip)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_zip does not specify a valid directory: &pfescrf_auto_path_zip;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;
                    %end;

                %put NOTE:[PXL] 9) Verify Input Parameter pfescrf_auto_path_code;
                    %if %str("&pfescrf_auto_path_code") = %str("null") %then %do;
                        %put NOTE:[PXL] Input Parameter pfescrf_auto_path_code = null, assume standard location;
                        %let pfescrf_auto_path_code = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/sasprogs/production;
                        
                    %end;

                    %let pfescrf_auto_path_code = &pfescrf_auto_path_code/;
                    %put NOTE:[PXL] pfescrf_auto_path_code set to &pfescrf_auto_path_code;

                    %if not %sysfunc(fileexist(&pfescrf_auto_path_code)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_code does not specify a valid directory: &pfescrf_auto_path_code;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 10) Verify Input Parameter pfescrf_auto_lib_download;
                    proc sql noprint;
                        select path into: pfescrf_auto_path_download 
                        from sashelp.vlibnam 
                        where libname="%upcase(&pfescrf_auto_lib_download)";
                    quit;
                    %put NOTE:[PXL] pfescrf_auto_path_download = &pfescrf_auto_path_download;

                    * Strip /current off if exists;
                    data _null_;
                        pathc = symget('pfescrf_auto_path_download');
                        pathc = tranwrd(pathc, '/current', '');
                        call symput('pfescrf_auto_path_download',pathc);
                    run;

                    %if not %sysfunc(fileexist(&pfescrf_auto_path_download)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_lib_download does not specify a valid libname;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                    %let pfescrf_auto_path_download = %left(%trim(&pfescrf_auto_path_download));
                    %put NOTE:[PXL] pfescrf_auto_path_download = &pfescrf_auto_path_download;
                    %let PFESCRF_AUTO_PATH_DOWNLOAD_CURDT = &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate)); * current dated folder - will be created in extract_download macro;
                    %put NOTE:[PXL] PFESCRF_AUTO_PATH_DOWNLOAD_CURDT = &PFESCRF_AUTO_PATH_DOWNLOAD_CURDT;

                %put NOTE:[PXL] 11) Verify Input Parameter pfescrf_auto_lib_scrf;
                    proc sql noprint;
                        select path into: pfescrf_auto_path_scrf 
                        from sashelp.vlibnam 
                        where libname="%upcase(&pfescrf_auto_lib_scrf)";
                    quit;
                    %put NOTE:[PXL] pfescrf_auto_path_scrf = &pfescrf_auto_path_scrf;

                    %put NOTE:[PXL] Strip /current off if exists;
                    data _null_;
                        pathc = symget('pfescrf_auto_path_scrf');
                        pathc = tranwrd(pathc, '/current', '');
                        call symput('pfescrf_auto_path_scrf',pathc);
                    run;

                    %if not %sysfunc(fileexist(&pfescrf_auto_path_scrf)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_lib_scrf does not specify a valid libname;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                    %let pfescrf_auto_path_scrf = %left(%trim(&pfescrf_auto_path_scrf));
                    %put NOTE:[PXL] pfescrf_auto_path_scrf = &pfescrf_auto_path_scrf;
                    %let pfescrf_auto_path_scrf_curdate = &pfescrf_auto_path_scrf/%left(%trim(&pfescrf_auto_RunDate)); * current dated folder - will be created in extract_download macro;
                    %put NOTE:[PXL] pfescrf_auto_path_scrf_curdate = &pfescrf_auto_path_scrf_curdate;

                %put NOTE:[PXL] 12) Verify Input Parameter pfescrf_auto_path_listings_out;
                    %if %str("&pfescrf_auto_path_listings_out") = %str("null") %then %do;
                        %put NOTE:[PXL] Input Parameter pfescrf_auto_path_listings_out = null, assume standard location;
                        %let pfescrf_auto_path_listings_out = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/listings/%left(%trim(&pfescrf_auto_RunDate));
                    
                        %let pfescrf_auto_path_listings_out = &pfescrf_auto_path_listings_out/;
                        %put NOTE:[PXL] pfescrf_auto_path_listings_out set to &pfescrf_auto_path_listings_out;

                        %sysexec %str(mkdir -p &pfescrf_auto_path_listings_out 2> /dev/null);
                    %end;
                    %else %do;
                        * User entered a value, do not use standard pfizer listings location;
                        %if not %sysfunc(fileexist(&pfescrf_auto_path_listings_out)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_listings_out does not specify a valid directory: &pfescrf_auto_path_listings_out;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;
                    %end;
                    
                %put NOTE:[PXL] 13) Verify Input Parameter pfescrf_auto_path_scrf_metadata;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_scrf_metadata)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_scrf_metadata does not specify a valid directory: &pfescrf_auto_path_scrf_metadata;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 14) Verify Input Parameter pfescrf_auto_path_struct_metadat;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_struct_metadat)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_struct_metadat does not specify a valid directory: &pfescrf_auto_path_struct_metadat;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end; 

                %put NOTE:[PXL] 15) Verify Input Parameter pfescrf_auto_confirmedchange;
                    %if %str("&pfescrf_auto_confirmedchange") ne %str("Y") 
                        and %str("&pfescrf_auto_confirmedchange") ne %str("N") %then %do;

                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_confirmedchange is not Y or N;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 16) Verify Input Parameter pfescrf_auto_file_emails_study exists;
                    %put NOTE:[PXL] 16.1) If pfescrf_auto_file_emails_study=null then set to default standard location;
                        %if %str("&pfescrf_auto_file_emails_study") = %str("null") %then %do;
                            %put NOTE:[PXL] Input parameter pfescrf_auto_file_emails_study is null, set to default expected csv file;
                            %let pfescrf_auto_file_emails_study = /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/macros/study_contacts.csv;
                        %end;

                    %put NOTE:[PXL] 16.2) Verify pfescrf_auto_file_emails_study exists;
                        %if not %sysfunc(fileexist(&pfescrf_auto_file_emails_study)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_file_emails_study does not specify a valid file: &pfescrf_auto_file_emails_study;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                    %put NOTE:[PXL] 16.3) Read CSV and check emails exists;

                        %let emails_study = ;
                        %let emails_stat = ;
                        %let emails_pcda = ;

                        %* Macro Variable pfescrf_auto_file_emails_study includes /study_contacts.csv but %pfestudy_contacts only includes path;
                        %local path_study_contacts;
                        %let path_study_contacts = ;
                        data _null_;
                            pathv = symget('pfescrf_auto_file_emails_study');
                            pathv = tranwrd(pathv, '/study_contacts.csv', '');
                            call symput('path_study_contacts', pathv);
                        run;

                        %* Populates from study_contacts.csv per study;
                        %pfestudy_contacts(
                            In_Path_Study_Contacts = &path_study_contacts,
                            Out_MV_Emails_CDBP     = emails_study,
                            Out_MV_Emails_Stat     = emails_stat,
                            Out_MV_Emails_PCDA     = emails_pcda);
                        options nofmterr noquotelenmax;

                        %let nbsp=%nrstr(&nbsp); * Used to insert HTML spaces; 
                        %if %str("&emails_study") = %str("null") or %str("&emails_study") = %str("")%then %do;
                            %let pfescrf_auto_FailMsg=Input Parameter pfescrf_auto_file_emails_study file contains no email addresses for CDBPSAS: <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg &pfescrf_auto_file_emails_study <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg &nbsp <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg Input CSV file should have emails entered as CDBPSAS: <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg na@parexel.com - n/a no email address <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg tbd@parexel.com - to be determined <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg firstname.lastname@parexel.com - one email <br />;
                            %let pfescrf_auto_FailMsg=&pfescrf_auto_FailMsg or use a semi colon to seperate for more 2+ emails;

                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %let emails_study = ; * Cleared for email output;

                            %goto MacErr;
                        %end;

                        %put NOTE:[PXL] emails_study = &emails_study;
                        %put NOTE:[PXL] emails_pcda = &emails_pcda;

                %put NOTE:[PXL] 17) Verify Input Parameter pfescrf_auto_file_emails_dex exists;
                    %put NOTE:[PXL] 17.1) If pfescrf_auto_file_emails_dex=null then set to default standard location;
                        %if %str("&pfescrf_auto_file_emails_dex") = %str("null") %then %do;
                            %put NOTE:[PXL] Input parameter pfescrf_auto_file_emails_dex is null, set to default expected csv file;
                            %let pfescrf_auto_file_emails_dex = /projects/std_pfizer/sacq/metadata/data/dex_emails.csv;
                        %end;

                    %put NOTE:[PXL] 17.2) Verify pfescrf_auto_file_emails_dex exists;
                        %if not %sysfunc(fileexist(&pfescrf_auto_file_emails_dex)) %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_file_emails_dex does not specify a valid file: &pfescrf_auto_file_emails_dex;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                    %put NOTE:[PXL] 17.3) Read CSV and check emails exists;
                        proc import datafile="&pfescrf_auto_file_emails_dex"
                             out=study_emails
                             dbms=csv
                             replace;
                             getnames=no;
                        run;

                        * study_contacts should have emails entered as:
                          na@parexel.com - n/a so do not use
                          tbd@parexel.com - to be determined so do not use
                          me@parexel.com - one email
                          or use a semi colon to seperate for more 2+ emails;
                        %let emails_dex = null;
                        data _null_;
                            length emails var1 $1500.;
                            retain emails;
                            set study_emails end=eof;

                            if _n_=1 then eamils = '';

                            put var1;

                            if not missing(VAR1)  and VAR1 ne 'na@parexel.com' then do;
                                VAR1 = tranwrd(VAR1, ';', "' '"); * Handle muiltiple email addresse;
                                VAR1 = compress(VAR1,' ');
                                emails = catx(" ", emails, "'", VAR1, "'");
                            end;

                            put "modified: " var1;

                            if eof then do;
                                if not missing(emails) then do;
                                    emails = compress(emails);
                                    emails = tranwrd(emails, "''", "' '");
                                    call symput('emails_dex', emails);
                                end;
                            end;
                        run;

                        %if %str("&emails_dex") = %str("null") or %str("&emails_dex") = %str("") %then %do;
                            %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_file_emails_study file contains no email addresses: &pfescrf_auto_file_emails_dex;
                            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                            %goto MacErr;
                        %end;

                        %put NOTE:[PXL] emails_dex = &emails_dex;

                %put NOTE:[PXL] 18) Verify Input Parameter pfescrf_auto_path_transfers;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_transfers)) %then %do;
                        %let pfescrf_auto_FailMsg = Input Parameter pfescrf_auto_path_transfers does not specify a valid directory: &pfescrf_auto_path_transfers;
                        %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: &pfescrf_auto_FailMsg;
                        %goto MacErr;
                    %end;
                    libname lib_at "&pfescrf_auto_path_transfers";

                %goto MacEnd;

                %MacErr:;
                %let GMPXLERR=1;

                %MacEnd:; 
                %put INFO:[PXL] ------------------------------------------------------;
                %put INFO:[PXL] &pfescrf_auto_MacroName: Macro Started; 
                %put INFO:[PXL] File Location: &pfescrf_auto_MacroPath ;
                %put INFO:[PXL] Version Number: &pfescrf_auto_MacroVersion ;
                %put INFO:[PXL] Version Date: &pfescrf_auto_MacroVersionDate ;
                %put INFO:[PXL] Run DateTime: &pfescrf_auto_RunDateTime;       
                %put INFO:[PXL] Run By: %upcase(&sysuserid); 
                %put INFO:[PXL] ;
                %put INFO:[PXL] Purpose: Automatic SCRF Transfers ; 
                %put INFO:[PXL] Input Parameters:;
                %put INFO:[PXL]   1) pfescrf_auto_pxl_code = &pfescrf_auto_pxl_code;
                %put INFO:[PXL]   2) pfescrf_auto_protocol = &pfescrf_auto_protocol;
                %put INFO:[PXL]   3) pfescrf_auto_pi_code = &pfescrf_auto_pi_code;
                %put INFO:[PXL]   4) pfescrf_auto_double = &pfescrf_auto_double;
                %put INFO:[PXL]   5) pfescrf_auto_path_zip = &pfescrf_auto_path_zip;
                %put INFO:[PXL]   6) pfescrf_auto_lib_download = &pfescrf_auto_lib_download;
                %put INFO:[PXL]   7) pfescrf_auto_lib_scrf = &pfescrf_auto_lib_scrf;
                %put INFO:[PXL]   8) pfescrf_auto_path_listings_out=&pfescrf_auto_path_listings_out;
                %put INFO:[PXL]   9) pfescrf_auto_path_scrf_metadata=&pfescrf_auto_path_scrf_metadata;
                %put INFO:[PXL]  10) pfescrf_auto_path_struct_metadat=&pfescrf_auto_path_struct_metadat;
                %put INFO:[PXL]  11) pfescrf_auto_confirmedchange=&pfescrf_auto_confirmedchange;
                %put INFO:[PXL]  12) pfescrf_auto_file_emails_study=&pfescrf_auto_file_emails_study;
                %put INFO:[PXL]  13) pfescrf_auto_file_emails_dex=&pfescrf_auto_file_emails_dex;
                %put INFO:[PXL]  14) pfescrf_auto_path_transfers=&pfescrf_auto_path_transfers;
                %put INFO:[PXL]  15) pfescrf_auto_testing=&pfescrf_auto_testing;
                %put INFO:[PXL]  16) pfescrf_auto_sendemail=&pfescrf_auto_sendemail;                
                %put INFO:[PXL] ------------------------------------------------------;

                %_MacEnd(MacroName=VERIFY_SOURCE_DATA);
            %mend verify_source_data;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.2) Setup Macro SFTP_ZIP ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro sftp_zip;
                %_MacStart(MacroName=SFTP_ZIP);

                * Pfizer Global Macro - Gets zip files using generic login and unzips to kennet location;
                %if %str("&pfescrf_auto_testing") = %str("Y") %then %do;
                    %put NOTE:[PXL] pfescrf_auto_testing is Y, testing will simulate macro pfepisftpget PASS run;
                    %global pfepisftpget_PassOrFail pfepisftpget_FailMsg;
                    %let pfepisftpget_PassOrFail = PASS;
                    %let pfepisftpget_FailMsg = null;
                %end;
                %else %do;
                    * Delete contains if present;
                    %sysexec %str(rm -f &pfescrf_auto_path_zip.*.*);

                    %pfepisftpget(
                        _pxl_code=&pfescrf_auto_pxl_code,
                        _protocol=&pfescrf_auto_protocol,
                        pi_code=&pfescrf_auto_pi_code, 
                        dayspast=&pfescrf_auto_sftpdayspast,
                        outputDir=&pfescrf_auto_path_zip);
                %end;

                * Set Eamil macro variables from macro pfepisftpget return global macros;
                %let send_email_sftp_zip_passOrFail = &pfepisftpget_PassOrFail;
                %let send_email_sftp_zip_failMsg = &pfepisftpget_FailMsg;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] send_email_sftp_zip_passOrFail = &send_email_sftp_zip_passOrFail; * Returned global macro with PASS or FAIL;
                %put NOTE:[PXL] send_email_sftp_zip_failMsg = &send_email_sftp_zip_failMsg; * Returned global macro for message if FAILED;
                %put NOTE:[PXL] ;

                %if %str("&pfepisftpget_PassOrFail") ne %str("PASS") %then %do;
                    %let pfescrf_auto_PassOrFail = FAIL;
                    %let GMPXLERR=1;
                %end;

                %goto MacEnd;
            
                %MacErr:;
                %let GMPXLERR=1;

                %MacEnd:; 
                %_MacEnd(MacroName=SFTP_ZIP);
            %mend sftp_zip;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.3) Setup Macro EXTRACT_DOWNLOAD ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro extract_download;
                %_MacStart(MacroName=EXTRACT_DOWNLOAD);
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] MACRO NAME: EXTRACT_DOWNLOAD;
                %put NOTE:[PXL] PURPOSE: Create SAS datasets containing coded data;         
                %put NOTE:[PXL] INPUT PARAMATERS:;
                %put NOTE:[PXL]    1) pfescrf_auto_pxl_code= &pfescrf_auto_pxl_code;
                %put NOTE:[PXL]    2) pfescrf_auto_protocol= &pfescrf_auto_protocol;
                %put NOTE:[PXL]    3) pfescrf_auto_path_code= &pfescrf_auto_path_code;
                %put NOTE:[PXL]    4) pfescrf_auto_lib_download= &pfescrf_auto_lib_download;
                %put NOTE:[PXL]    5) pfescrf_auto_RunDate= &pfescrf_auto_RunDate;
                %put NOTE:[PXL] INPUT: ;
                %put NOTE:[PXL]    1) Raw unzipped txt and xpt files at this location:;
                %put NOTE:[PXL]       &pfescrf_auto_path_code;
                %put NOTE:[PXL] OUTPUT: ;
                %put NOTE:[PXL]    1) SAS datasets to this location:;
                %put NOTE:[PXL]       &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate));
                %put NOTE:[PXL]    2) Symbolic link ../download/current points to %left(%trim(&pfescrf_auto_RunDate));
                %put NOTE:[PXL] ------------------------------------------------------;

                %let send_email_extract_passOrFail = FAIL;
                %let send_email_extract_failMsg = null;

                * 1) Unix command Mkdir –p /projects/<pfizrNNNNNN>/dm/sasprogs/production/logs;
                    %put NOTE:[PXL] Project code path = &pfescrf_auto_path_code;
                    %sysexec %str(mkdir -p &pfescrf_auto_path_code.logs 2> /dev/null);

                * 2) Unix command mv *.log and *.lst files to /logs;
                    %sysexec %str(mv &pfescrf_auto_path_code.*.log &pfescrf_auto_path_code.logs 2> /dev/null);
                    %sysexec %str(mv &pfescrf_auto_path_code.*.lst &pfescrf_auto_path_code.logs 2> /dev/null);
                    %sysexec %str(mv &pfescrf_auto_path_code.*.pdf &pfescrf_auto_path_code.logs 2> /dev/null);

                * 3) Verify extract.sas exists;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_code/extract.sas)) %then %do;
                        %let send_email_extract_failMsg = Extract.sas program does not exist: &pfescrf_auto_path_code/extract.sas;
                        %put %str(ERR)OR: &pfescrf_auto_MacroName: File not found: &pfescrf_auto_path_code/extract.sas;
                        %goto MacErr;               
                    %end;

                * 4) Run via SAS92 extract.sas;
                    %sysexec %str(cd &pfescrf_auto_path_code);
                    x "sas92 extract.sas";

                * 5) Check extract.log for any issues;
                    * Get name of log file;
                    filename dirlist pipe "ls -la %left(%trim(&pfescrf_auto_path_code))";
                    data work._dirlist ;
                       length dirline dirline2 $200 ;
                       infile dirlist recfm=v lrecl=200 truncover end=eof;
                       input dirline $1-200 ;
                       dirline2 = substr(dirline,59);
                       if index(dirline2,'extract') > 0 
                          and index(dirline2,'.log') > 0 then do;
                          call symput('extract_log_filname',left(trim(dirline2)));
                       end;
                    run;   
                    %put NOTE:[PXL] extract_log_filname = &extract_log_filname;

                    * Run logcheck on log file;
                        %_MacStart(MacroName=PFELOGCHECK);
                        %pfelogcheck(
                            FileName=&extract_log_filname,
                            _pxl_code=&pfescrf_auto_pxl_code,
                            _protocol=pfescrf_auto_protocol,
                            AddDateTime=N,
                            IgnoreList=null,
                            ShowInUnix=N,
                            CreatePDF=Y);
                        %_MacEnd(MacroName=PFELOGCHECK);
                        options nofmterr noquotelenmax;

                        %put NOTE:[PXL] pfelogcheck_TotalLogIssues = &pfelogcheck_TotalLogIssues; * Total log issues found;
                        %put NOTE:[PXL] pfelogcheck_pdflistingname = &pfelogcheck_pdflistingname; * PDF Listing output file name;

                    * Check if logcheck found issues;
                    %if %eval(&pfelogcheck_TotalLogIssues > 0) %then %do;
                        %put %str(ERR)OR:[PXL] %left(%trim(&pfelogcheck_TotalLogIssues)) SAS log issues found in &pfescrf_auto_path_code.&extract_log_filname;

                        * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate);                     

                        %let send_email_extract_failMsg = FAILED Issues per below: <br />
                            (%left(%trim(&pfelogcheck_TotalLogIssues))) SAS log issues found in &pfescrf_auto_path_code.&extract_log_filname <br />
                            See LOGCHECK generated file: &pfescrf_auto_path_code.<br />&pfelogcheck_pdflistingname.<br />
                            &nbsp <br />
                            Renamed &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate))<br /> 
                            to error_%left(%trim(&pfescrf_auto_RunDate))<br />;
                        %put %str(ERR)OR: &pfescrf_auto_MacroName: extract log found issues;
                        %goto MacErr;
                    %end;
                    %else %do;
                        %put NOTE:[PXL] No issues found in extract log, checking for special characters;
                        * No Issues found in the log;
                        * Check if speical characters note found in log;
                            * Read and review log for <NOTE:[PXL] PFESCRF_AUTO:>;

                            * Read extract log and look for special char found in coding records
                              and save to macro var;
                            %let extract_sc_exist=N;
                            filename inlog "&pfescrf_auto_path_code.&extract_log_filname";
                            data _null_;
                                length msg_raw $256 msg $1500;
                                retain msg;
                                infile inlog;
                                input;
                                msg_raw = _infile_;
                                if index(msg_raw,"NOTE:[PXL] PFESCRF_AUTO:") > 0 then do;
                                    put "NOTE:[PXL]: Found Special Characters in MEDDRA/WHODRUG Coding Records: " msg_raw;
                                    msg_raw = tranwrd(msg_raw, "NOTE:[PXL] PFESCRF_AUTO:", "");
                                    msg = catx("<br />", msg, catx(" ", "Total Issues Found =", scan(msg_raw, 1, ' '), "in", scan(msg_raw, 2, ' ')));
                                    call symput("extract_sc_exist", msg);
                                end;
                                delete;
                            run;
                            %put NOTE:[PXL] extract_sc_exist: &extract_sc_exist;

                            * Set email output message for coding special characters if found;
                            %if %str("&extract_sc_exist") ne %str("N") %then %do;
                                %let send_email_extract_failMsg = Extract: <b>%left(%trim(%str(WARN)))ING!!!</b> Special Characters found in MEDDRA/WHODRUG coded data in raw ASCII files. <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg This will cause data to not include coding levels of data. Please review and submit to PCDA to query. <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg See extract.sas created listings found under: <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg &pfescrf_auto_path_listings_out <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg &nbsp <br />;
                                %let send_email_extract_failMsg = &send_email_extract_failMsg %left(%trim(&extract_sc_exist));
                            %end;
                    %end;

                * 8) Verify number of SAS datasets in download/current match .xpt files from raw;
                    %put NOTE:[PXL] ;
                    %put NOTE:[PXL] Verify number of SAS datasets in download/current match .xpt files from raw; 

                    * Get number of xpt files;
                    filename dirlist pipe "ls -la &pfescrf_auto_path_zip" ;

                    data work._dirlist ;
                        length dirline $200 ;
                        infile dirlist recfm=v lrecl=200 truncover end=eof;
                        input dirline $1-200 ;
                        if index(upcase(dirline),'.XPT') then output;
                    run;                  

                    proc sql noprint;
                        select count(*) into: count_xpt
                        from _dirlist;

                        select count(*) into: count_sas
                        from sashelp.vtable
                        where libname="DOWNLOAD";
                    quit;

                    %if %eval(&count_xpt ne &count_sas) %then %do;
                        %put %str(ERR)OR:[PXL]: The number of XPT files %left(%trim(&count_xpt)) is different from the created SAS datasets %left(%trim(&count_sas));  

                        data _null_;
                            length msg $2500;
                            msg = catx("<br />",
                                "FAILED Issues per below:",
                                "The number of XPT files is different from the created SAS datasets",
                                "Number of XPT Files: %left(%trim(&count_xpt))",
                                "XPT File Location: &pfescrf_auto_path_zip",
                                "Number of SAS Datasets: %left(%trim(&count_sas))",
                                "SAS Datasets : &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate))",
                                "&nbsp ",
                                "Renamed &pfescrf_auto_path_download/%left(%trim(&pfescrf_auto_RunDate))",
                                "to error_%left(%trim(&pfescrf_auto_RunDate))");
                            call symput('msg_failedissues', msg);
                        run;
                        %let send_email_extract_failMsg = &msg_failedissues;

                        * Update symbolic link current to point to previous dated folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate);
                        %goto MacErr;                       
                    %end;

                    %if %str("&extract_sc_exist") ne %str("N") %then %do;
                        %let send_email_extract_passOrFail = PASS *** WITH %str(WARN)ING ***;
                    %end;
                    %else %do;
                        %let send_email_extract_passOrFail = PASS;
                    %end;

                %goto MacEnd;
              
                %MacErr:;
                %let GMPXLERR=1;

                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro EXTRACT_DOWNLOAD Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_extract_passOrFail = &send_email_extract_passOrFail;
                %put NOTE:[PXL]    send_email_extract_failMsg = &send_email_extract_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;

                %_MacEnd(MacroName=EXTRACT_DOWNLOAD);
            %mend extract_download;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.4) Setup Macro EXPORT_SCRF ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro export_scrf;
                %_MacStart(MacroName=EXPORT_SCRF);
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] MACRO NAME: EXPORT_SCRF;
                %put NOTE:[PXL] PURPOSE: Create CSDW SCRF datasets by running export.sas;
                %put NOTE:[PXL] INPUT PARAMATERS:;
                %put NOTE:[PXL]    1) pfescrf_auto_pxl_code= &pfescrf_auto_pxl_code;
                %put NOTE:[PXL]    2) pfescrf_auto_protocol= &pfescrf_auto_protocol;
                %put NOTE:[PXL]    3) pfescrf_auto_path_code= &pfescrf_auto_path_code;
                %put NOTE:[PXL]    4) pfescrf_auto_lib_scrf= &pfescrf_auto_lib_download;
                %put NOTE:[PXL]    5) pfescrf_auto_path_listings_out= &pfescrf_auto_path_listings_out;
                %put NOTE:[PXL]    6) pfescrf_auto_double= &pfescrf_auto_double;
                %put NOTE:[PXL]    7) pfescrf_auto_double= &pfescrf_auto_double;
                %put NOTE:[PXL]    8) pfescrf_auto_RunDate= &pfescrf_auto_RunDate;
                %put NOTE:[PXL] INPUT: ;
                %put NOTE:[PXL]    1) Raw unzipped txt and xpt files at this location:;
                %put NOTE:[PXL]       &pfescrf_auto_path_code;
                %put NOTE:[PXL] OUTPUT: ;
                %put NOTE:[PXL]    1) CSDW SCRF SAS datasets to this location:;
                %put NOTE:[PXL]       /projects/pfizr%left(%trim(&pfescrf_auto_pxl_code))/dm/datasets/scrf/%left(%trim(&pfescrf_auto_RunDate))/;
                %put NOTE:[PXL]    2) Symbolic link ../scrf/current points to %left(%trim(&pfescrf_auto_RunDate));
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] ;

                %let send_email_export_passOrFail = FAIL;
                %let send_email_export_failMsg = null;

                %put NOTE:[PXL] 1) Verify export.sas exists;
                    %if not %sysfunc(fileexist(&pfescrf_auto_path_code.export.sas)) %then %do;
                        %put %str(ERR)OR:[PXL] File not found: &pfescrf_auto_path_code.export.sas;

                        %let send_email_export_failMsg = FAILED Issues per below: <br />
                            File not found: &pfescrf_auto_path_code.export.sas <br />;            
                                            
                        %let GMPXLERR = 1;
                        %goto MacErr;
                    %end;

                %put NOTE:[PXL] 2) Run via SAS92 export.sas;
                    %sysexec %str(cd &pfescrf_auto_path_code);
                    x "sas92 export.sas";

                %put NOTE:[PXL] 3) Check export.log for any issues;
                    * Get name of log file;
                    %let export_log_filname = null;
                    filename dirlist pipe "ls -la &pfescrf_auto_path_code";
                    data work._dirlist ;
                       length dirline dirline2 $200 ;
                       infile dirlist recfm=v lrecl=200 truncover end=eof;
                       input dirline $1-200 ;
                       dirline2 = substr(dirline,59);
                       if index(dirline2,'export') > 0 
                          and index(dirline2,'.log') > 0 then do;
                          call symput('export_log_filname',left(trim(dirline2)));
                       end;
                    run;   
                    %put NOTE:[PXL] export_log_filname = &export_log_filname;

                %put NOTE:[PXL] 4) Run pfelogcheck macro on export log;
                    * Run logcheck on log file;
                        %_MacStart(MacroName=PFELOGCHECK);
                        %pfelogcheck(
                            FileName=&export_log_filname,
                            _pxl_code=&pfescrf_auto_pxl_code,
                            _protocol=pfescrf_auto_protocol,
                            AddDateTime=N,
                            IgnoreList=null,
                            ShowInUnix=N,
                            CreatePDF=Y);
                        %_MacEnd(MacroName=PFELOGCHECK); 
                        options nofmterr noquotelenmax;          

                %put NOTE:[PXL] 5) Check if logcheck found issues;
                    %if %eval(&pfelogcheck_TotalLogIssues > 0) %then %do;
                        %put %str(ERR)OR:[PXL] %left(%trim(&pfelogcheck_TotalLogIssues)) SAS log issues found in &pfescrf_auto_path_code.&export_log_filname;

                        %let send_email_export_failMsg =
                            FAILED Issues per below: <br />
                            (%left(%trim(&pfelogcheck_TotalLogIssues))) SAS log issues found in &pfescrf_auto_path_code.&export_log_filname <br />
                            See LOGCHECK generated file: &pfescrf_auto_path_code <br />
                            &pfelogcheck_pdflistingname <br />
                            &nbsp <br />
                            Renamed &pfescrf_auto_path_scrf_curdate <br />
                            to error_%left(%trim(&pfescrf_auto_RunDate)) <br />;

                        %put %str(ERR)OR: &pfescrf_auto_MacroName: export log found issues;

                        * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                        %goto MacErr;               
                    %end;                

                %put NOTE:[PXL] 6) Verify at least DEMOG SCRF dataset created;
                    proc sql noprint;
                        select count(*) into: cnt
                        from sashelp.vtable
                        where libname="%upcase(&pfescrf_auto_lib_scrf)"
                              and memname="DEMOG";
                    quit;

                    %if %eval(&cnt = 0) %then %do;
                        data _null_;
                            length msg $2500;
                            msg = catx("<br />",
                                "FAILED Issues per below:",
                                "SCRF dataset demog.sas7bdat not found",
                                "SAS Datasets: &pfescrf_auto_path_scrf_curdate",
                                "&nbsp ",
                                "Renamed &pfescrf_auto_path_scrf_curdate",
                                "to error_%left(%trim(&pfescrf_auto_RunDate))");
                            call symput('send_email_export_failMsg', msg);
                        run;

                        %put %str(ERR)OR:[PXL]: SCRF dataset demog.sas7bdat not found;

                        * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                        %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                        %goto MacErr;                       
                    %end;
    
                %put NOTE:[PXL] 7) If pfescrf_auto_double=Y, then compare primary to qc SCRF datasets;
                    %if %str("&pfescrf_auto_double") = %str("N") %then %do;
                        %put NOTE:[PXL] pfescrf_auto_double=N, compare primary to qc SCRF datasets not done;
                    %end;
                    %else %do;
                        %put NOTE:[PXL] pfescrf_auto_double=Y, compare primary to qc SCRF datasets;

                        %put NOTE:[PXL] 1) Verify &pfescrf_auto_path_scrf_curdate/qc directory exists;

                        %if not %sysfunc(fileexist(&pfescrf_auto_path_scrf_curdate/qc)) %then %do;
                            %put %str(ERR)OR:[PXL] SCRF Datasets QC Directory not found: &pfescrf_auto_path_scrf_curdate/qc;

                            %let send_email_export_failMsg =
                                FAILED Issues per below: <br />
                                Macro Input Parameter pfescrf_auto_double = Y but SCRF QC directory does not exist: <br />
                                &pfescrf_auto_path_scrf_curdate/qc <br />; 

                            * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                            %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                            %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                           %goto MacErr;               
                        %end;

                        %put NOTE:[PXL] 2) Compare datasets with /qc datasets for exact 1 to 1 match by name and attributes;
                            libname scrfqc "&pfescrf_auto_path_scrf_curdate/qc";

                            %_MacStart(MacroName=PFEPROCCOMPARE);
                            %pfeproccompare(
                                pfeproccompare_pxl_code=&pfescrf_auto_pxl_code,
                                pfeproccompare_protocol=&pfescrf_auto_protocol,
                                pfeproccompare_lib_pri=&pfescrf_auto_lib_scrf,
                                pfeproccompare_lib_qc=scrfqc,
                                pfeproccompare_path_listings=&pfescrf_auto_path_listings_out,
                                pfeproccompare_addDateTime=Y);
                            %_MacEnd(MacroName=PFEPROCCOMPARE);
                            options nofmterr noquotelenmax;

                            libname scrfqc clear;

                            %if %str("&pfeproccompare_PassOrFail") = %str("FAIL") %then %do;
                                data _null_;
                                    length msg $2500;
                                    msg = catx("<br />",
                                        "FAILED Issues per below:",
                                        "Proc Compare Primary against QC SCRF datasets failed",
                                        "Primary: &pfescrf_auto_path_scrf_curdate",
                                        "QC: &pfescrf_auto_path_scrf_curdate/qc",
                                        "&nbsp",
                                        "Total Attrib Issues: %left(%trim(&pfeproccompare_NumIssuesAttrib))",
                                        "Total Value Issues: %left(%trim(&pfeproccompare_NumIssuesValues))",
                                        "&nbsp",
                                        "Output Listings PDF and XLS to Review:",
                                        "&pfeproccompare_ListingName");
                                    call symput('send_email_export_failMsg', msg);
                                run;                                    

                                %put %str(ERR)OR: &pfescrf_auto_MacroName: Proc Compare Primary against QC SCRF datasets failed;

                                * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                                %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                                %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                                %goto MacErr;
                            %end;
                    %end;

                %let send_email_export_passOrFail = PASS;

                %goto MacEnd;
              
                %MacErr:;
                
                %let GMPXLERR=1;

                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro EXPORT_SCRF Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_export_passOrFail = &send_email_extract_passOrFail;
                %put NOTE:[PXL]    send_email_export_failMsg = &send_email_extract_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;

                %_MacEnd(MacroName=EXPORT_SCRF);
            %mend export_scrf;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.5) Setup Macro SCRF_CSDW_VALIDATION ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro scrf_csdw_validation;
                %_MacStart(MacroName=SCRF_CSDW_VALIDATION);

                %let send_email_csdw_passOrFail = FAIL;
                %let send_email_csdw_failMsg = null;

                %_MacStart(MacroName=PFESCRF_CSDW_VALIDATOR);
                %pfescrf_csdw_validator(
                    pfescrf_csdw_validator_metadata=&pfescrf_auto_path_scrf_metadata,
                    pfescrf_csdw_validator_spec=scrf_csdw_pxl,
                    pfescrf_csdw_validator_codelists=codelists,
                    pfescrf_csdw_validator_download=download,
                    pfescrf_csdw_validator_scrf=scrf,
                    pfescrf_csdw_validator_pathlist=&pfescrf_auto_path_listings_out,
                    pfescrf_csdw_validator_protocol=&pfescrf_auto_protocol,
                    pfescrf_csdw_validator_pxl_code=&pfescrf_auto_pxl_code,
                    pfescrf_csdw_validator_AddDT=Y,
                    pfescrf_csdw_validator_test=N);
                %_MacEnd(MacroName=PFESCRF_CSDW_VALIDATOR);
                OPTIONS noquotelenmax;

                %if %str("&pfescrf_csdw_validator_PassFail") = %str("FAIL") %then %do;

                    data _null_;
                        length msg $2500;
                        msg = catx(" <br /> ",
                            "<b>FAIL Issues per below: </b>",
                            "PFESCRF_CSDW_VALIDATOR Found issues comparing data against PDS ",
                            "CSDW SCRF Datasets: &pfescrf_auto_path_scrf_curdate ",
                            "&nbsp ",
                            "Total %str(ERR)ORS Found: %left(%trim(&pfescrf_csdw_validator_NumErr)) ",
                            "Total %str(WARN)INGS Found: %left(%trim(&pfescrf_csdw_validator_NumWarn)) ",
                            "&nbsp ",
                            "Output Listing XLS to Review: ",
                            "&pfescrf_auto_path_listings_out",
                            "&pfescrf_csdw_validator_ListName ",
                            "&nbsp ",
                            "Datasets Renamed &pfescrf_auto_path_scrf_curdate ",
                            "to %str(err)or_%left(%trim(&pfescrf_auto_RunDate)) ");
                        call symput('send_email_csdw_failMsg', msg);
                    run;

                    %if %str("&pfescrf_csdw_validator_ErrMsg") ne %str("null") %then %do;
                        %let send_email_csdw_failMsg = &pfescrf_csdw_validator_ErrMsg &nbsp <br /> &pfescrf_csdw_validator_ErrMsg;
                    %end;

                    %put %str(ERR)OR: &pfescrf_auto_MacroName: PFESCRF_CSDW_VALIDATOR Found issues comparing data against PDS;

                    * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                    %goto MacErr;
                %end;

                %let send_email_csdw_passOrFail = PASS;

                %goto MacEnd;
                %MacErr:;
                %let GMPXLERR=1;
                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro SCRF_CSDW_VALIDATION Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_csdw_passOrFail = &send_email_csdw_passOrFail;
                %put NOTE:[PXL]    send_email_csdw_failMsg = &send_email_csdw_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] ;                    
                %_MacEnd(MacroName=SCRF_CSDW_VALIDATION);
            %mend scrf_csdw_validation;

        %put NOTE:[PXL] ***********************************************************************************;
        %put NOTE:[PXL] 3.6) Setup Macro STRUCTURE_CHANGE ;
        %put NOTE:[PXL] ***********************************************************************************;
            %macro structure_change(pxl_code=null);
                %_MacStart(MacroName=STRUCTURE_CHANGE);

                %let send_email_struct_passOrFail = FAIL;
                %let send_email_struct_failMsg = null;                
                
                %_MacStart(MacroName=PFESTRUCTCOMPARE);
                %pfestructcompare(
                    pfestructcompare_metadata=&pfescrf_auto_path_struct_metadat,
                    pfestructcompare_confirmedchange=&pfescrf_auto_confirmedchange,
                    pfestructcompare_protocol=&pfescrf_auto_protocol,
                    pfestructcompare_pxl_code=&pfescrf_auto_pxl_code,
                    pfestructcompare_pathlist=&pfescrf_auto_path_listings_out,
                    pfestructcompare_scrf=&pfescrf_auto_lib_scrf);
                %_MacEnd(MacroName=PFESTRUCTCOMPARE);
                options nofmterr noquotelenmax;

                %let send_email_struct_passOrFail = &pfestructcompare_PassFail;
                %let send_email_struct_failMsg = &pfestructcompare_ErrMsg;

                %put NOTE:[PXL] send_email_struct_passOrFail = &send_email_struct_passOrFail;
                %put NOTE:[PXL] send_email_struct_failMsg = &send_email_struct_failMsg;

                %if %str("&pfestructcompare_PassFail") = %str("FAIL") %then %do;
                    %let send_email_struct_failMsg = &send_email_struct_failMsg <br /> &nbsp <br />;
                    %let send_email_struct_failMsg = &send_email_struct_failMsg Number of Issues Found: %left(%trim(&pfestructcompare_NumDiff)) <br />;
                    %let send_email_struct_failMsg = &send_email_struct_failMsg Listing Created: &pfestructcompare_ListName;

                    %put %str(ERR)OR: &pfescrf_auto_MacroName: PFESTRUCTCOMPARE Found issues comparing data against previous transfer;

                    * Issue found, move data to error_YYYYMMDD and updated symbolic link current to point to previous YYYYMMDD folder;
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_scrf, curdate=&pfescrf_auto_RunDate);
                    %update_path_for_issue(pathroot=&pfescrf_auto_path_download, curdate=&pfescrf_auto_RunDate); 

                    %goto MacErr;
                %end;

                %if %str("&pfestructcompare_PassFail") = %str("PASS - CONFIRMED STRUCTURE CHANGE") %then %do;
                    %put NOTE:[PXL] PASS - CONFIRMED STRUCTURE CHANGE, Notify DEX team;

                    %if %str("&pfescrf_auto_sendemail") = %str("Y") %then %do;
                        filename Mailbox EMAIL 'Nathan.Hartley@parexel.com'
                            type = "TEXT/HTML"
                            to = (&emails_dex)
                            subject="%left(%trim(&pfescrf_auto_pxl_code)) %left(%trim(&pfescrf_auto_protocol)) Automatic SCRF Creation - CONFIRMED STRUCTURE CHANGE"
                            attach=("&pfestructcompare_ListName");

                            data _null_;
                                file Mailbox;
                                put "Hello,<br />";
                                put "<br />";
                                put "%left(%trim(&pfescrf_auto_pxl_code)) %left(%trim(&pfescrf_auto_protocol)) <br />";
                                put "User Confirmed Structure Change, see updates: <br />";
                                put "&pfestructcompare_ListName <br />";
                                put "<br />";
                                put "----------------------------------------------------------------------------------------------------------------<br />";
                                put "End of automatic generated email";
                            run;
                        quit;
                    %end;
                %end;

                * Update for consistancy;
                %if %str("&send_email_struct_passOrFail") = %str("PASS - NO DIFFERENCES") %then %do;
                    %let send_email_struct_passOrFail = PASS;
                %end;

                %goto MacEnd;
                %MacErr:;
                %let GMPXLERR=1;
                %MacEnd:;

                %put NOTE:[PXL] ;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] Macro STRUCTURE_CHANGE Completed;
                %put NOTE:[PXL] OUTPUT:;
                %put NOTE:[PXL]    send_email_struct_passOrFail = &send_email_struct_passOrFail;
                %put NOTE:[PXL]    send_email_struct_failMsg = &send_email_struct_failMsg;
                %put NOTE:[PXL] ------------------------------------------------------;
                %put NOTE:[PXL] ; 

                %_MacEnd(MacroName=STRUCTURE_CHANGE);
            %mend structure_change;  

        %* Purpose: Email PCDA if special coding listings exist
         * Input: 
                1) email_pcda_coding_pxl_code = &pfescrf_auto_pxl_code -> PXL Study Code, used for email subject
                2) email_pcda_coding_protocol = &pfescrf_auto_protocol -> PFE Study Code, used for email subject
                3) email_pcda_coding_sendemail = &pfescrf_auto_sendemail -> Y or N, testing=N to not send emails
                4) email_pcda_coding_run = &extract_sc_exist -> N or transfer email text information, used to know if 
                   special characters exist 
                5) email_pcda_coding_path_log = &pfescrf_auto_path_code -> kennet path for extract log
                6) email_pcda_coding_file_log = &extract_log_filname -> extract file log name to look through to get 
                   information about special coding listings created
                7) email_pcda_coding_path_list = &pfescrf_auto_path_listings_out -> kennet path listings are located
                8) email_pcda_coding_emails_pcda = &emails_pcda -> macro variable containing PCDA email addresses
         * Output:
         *   1) Email sent to PCDA and copy PFZCRON with attached special characters in coding listings attached
         *   2) Create work dataset email_pcda_coding used in testing validation only
         *;
            %macro email_pcda_coding(
                email_pcda_coding_pxl_code = &pfescrf_auto_pxl_code,
                email_pcda_coding_protocol = &pfescrf_auto_protocol,
                email_pcda_coding_sendemail = &pfescrf_auto_sendemail,
                email_pcda_coding_run = &extract_sc_exist,
                email_pcda_coding_path_log = &pfescrf_auto_path_code,
                email_pcda_coding_file_log = &extract_log_filname,
                email_pcda_coding_path_list = &pfescrf_auto_path_listings_out,
                email_pcda_coding_emails_pcda = &emails_pcda
                );
                %_MacStart(MacroName=EMAIL_PCDA_CODING);

                %if "&email_pcda_coding_run" ne "N" %then %do;
                    %put NOTE:[PXL] email_pcda_coding_run is not N -> Send PCDA Email of listings;

                    %* Output Input Parameters Used;
                        %put NOTE:[PXL] --------------------------------------------------;
                        %put NOTE:[PXL] Given Input Parameters:;
                        %put NOTE:[PXL] email_pcda_coding_pxl_code = &email_pcda_coding_pxl_code;
                        %put NOTE:[PXL] email_pcda_coding_protocol = &email_pcda_coding_protocol;
                        %put NOTE:[PXL] email_pcda_coding_sendemail = &email_pcda_coding_sendemail;
                        %put NOTE:[PXL] email_pcda_coding_path_log = &email_pcda_coding_path_log;
                        %put NOTE:[PXL] email_pcda_coding_file_log = &email_pcda_coding_file_log;
                        %put NOTE:[PXL] email_pcda_coding_path_list = &email_pcda_coding_path_list;
                        %put NOTE:[PXL] email_pcda_coding_emails_pcda = &email_pcda_coding_emails_pcda;
                        %put NOTE:[PXL] --------------------------------------------------;

                    %* Initialize Variables;
                        options nofmterr noquotelenmax;

                        %local total i subject;
                        %let total = 0; %* Used as total listings created;
                        %let i = 0; %* Used as incremental counter;
                        %let nbsp = %nrstr(&nbsp;);

                        %* Email subject line;
                        %let subject = %left(%trim(&email_pcda_coding_pxl_code));
                        %let subject = &subject %left(%trim(&email_pcda_coding_protocol));
                        %let subject = &subject Special Character Coding Listings *** WARNING ***;

                    %* Read extract log to get listings information;
                        filename inlog "&email_pcda_coding_path_log/&email_pcda_coding_file_log";
                        data _null_;
                            length msg_raw $256;
                            retain cnt 0;
                            infile inlog;
                            input;
                            msg_raw = _infile_;
                            if _n_ = 1 then cnt = 0;
                            if index(msg_raw,"NOTE:[PXL] PFESCRF_AUTO:") > 0 then do;                          
                                put "NOTE:[PXL]: Found Special Characters in MEDDRA/WHODRUG Coding Records: " msg_raw;
                                msg_raw = tranwrd(msg_raw, "NOTE:[PXL] PFESCRF_AUTO:", "");
                                cnt = cnt + 1;
                                call symput(catx("_","listni",strip(put(cnt,8.))), scan(msg_raw, 1, ' ')); %* Issues Found;
                                call symput(catx("_","listname",strip(put(cnt,8.))), scan(msg_raw, 2, ' ')); %* Listing name;
                                call symput("total", strip(put(cnt,8.)));
                            end;
                        run;

                    %* Send email;
                        %* email attachment - list of special coding listings;
                        %let attachments = ;
                        %do i=1 %to &total;
                            %let attachments = &attachments "&email_pcda_coding_path_list/&&listname_&i" name="&&listname_&i" ext="PDF" ;
                        %end;

                        %if %str("&email_pcda_coding_sendemail") = %str("Y") %then %do;
                            filename Mailbox EMAIL 'Nathan.Hartley@parexel.com'
                                type = "TEXT/HTML"
                                to = (&email_pcda_coding_emails_pcda)
                                cc = ('pfzcron@parexel.com')
                                subject="&subject"
                                attach=(&attachments);

                                data _null_;
                                    file Mailbox;
                                    put "Hello,<br />";
                                    put "<br />";
                                    put "This is an automatic generated message by PFZCRON. Special characters were found <br />"; 
                                    put "in raw datasets containing coded data. This will prevent coded data from being mapped. <br />"; 
                                    put "See listings attached for details. These must be corrrected within DataLabs. <br />";
                                    put "<br />";
                                    put "----------------------------------------------------------------------------------------------------------------<br />";
                                    put "&nbsp. <br />";
                                    put "Total Listing(s): %left(%trim(&total)) <br />";
                                    put "&nbsp. <br />";
                                    put "Listing Details: <br />";
                                    put "<table border='1' style='border: 1px solid black; border-collapse: collapse; padding: 8px;'>";
                                    put "   <tr><td>#</td><td>Issues Found</td><td>Listing Name</td></tr>";
                                    %do i=1 %to &total;
                                        put "   <tr><td>&i..</td><td>&&listni_&i</td><td>&&listname_&i</td></tr>";
                                    %end;
                                    put " </table>&nbsp. <br />";
                                    put "----------------------------------------------------------------------------------------------------------------<br />";
                                    put "End of automatic generated email";
                                run;
                            quit;
                        %end; %* End if;

                    %* Create work email used for testcases;
                        data email_pcda_coding;
                            length subject email_pcda_coding_emails_pcda $500 attachments $5000 total_listings $8;

                            subject = symget('subject');
                            %do i=1 %to &total;
                                attachments = catx(",", attachments, "&i &&listni_&i &&listname_&i");
                            %end;                            
                            
                            email_pcda_coding_emails_pcda = "&email_pcda_coding_emails_pcda";
                            total_listings = symget('total');
                        run;                                                
                %end; %* End if;
                %else %do;
                    %put NOTE:[PXL] email_pcda_coding_run = N -> Do Not Send PCDA Email of listings;
                %end;

                %_MacEnd(MacroName=EMAIL_PCDA_CODING);
            %mend email_pcda_coding;

    %put NOTE:[PXL] ***********************************************************************************;
    %put NOTE:[PXL] 4) Run Process ;
    %put NOTE:[PXL] ***********************************************************************************;
        %*
         * 1) Macro Start Log Message
         * 2) Verify source data and output run info to log
         * 3) If Auto Run, Verify Run Needed
         * 4) Get latest raw zip files and unzip to kennet
         * 5) Create SAS datasets with coded data from raw data
         * 6) Create SCRF datasets
         * 7) Verify SCRF datasets match CSDW SCRF Specification
         * 8) Verify No/Confirmed Structure Change
         * 9) Set Coding Special Character Warn Flag
         *;

        * 1) Macro Start Log Message;
            %_MacStart(MacroName=&pfescrf_auto_MacroName);

        * 2) Verify source data and output run info to log;
            %verify_source_data;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 3) If Auto Run, Verify Run Needed;
            %put NOTE:[PXL] sysparm = &sysparm;
            %if %str("&sysparm") = %str("AUTO") %then %do;
                %put NOTE:[PXL] SYSPARM = AUTO - Running PFESCRF_AUTO_TRIGGER;

                %* Independant Macro PFESCRF_AUTO_TRIGGER
                 * Purpose: Return to run or not run rest of PFESCRF_AUTO
                 * Input: 1) pxl_code_in - pxl_code
                 *        2) path_metadata_in - directory of metadata
                 *        3) data_transfer_log_in - name of SAS dataset holding past transfer data
                 *        4) file_config_in - name of config csv file
                 * Output: 1) Global macro pfescrf_auto_trigger_run
                 *            YES - Continue run of PFESCRF_AUTO
                 *            NO - Do not run (PASS run within 4 days or PASS today if scheduled run day)
                 *            FAIL - Issue found
                 *;
                %pfescrf_auto_trigger(
                    pxl_code_in=&pfescrf_auto_pxl_code,
                    path_metadata_in=&pfescrf_auto_path_scrf_metadata,
                    data_transfer_log_in=scrf_transfer_archive,
                    file_config_in=pfescrf_auto_trigger.csv);

                %if %str("&pfescrf_auto_trigger_run") = %str("FAIL") %then %do;
                    %put NOTE:[PXL] Macro PFESCRF_AUTO_TRIGGER returned FAIL, terminating macro PFESCRF_AUTO;
                %end;
                %else %if %str("&pfescrf_auto_trigger_run") = %str("NO") %then %do;
                    %put NOTE:[PXL] Macro PFESCRF_AUTO_TRIGGER returned NO and PFESCRF_AUTO does not need run;
                    %let pfescrf_auto_PassOrFail = N/A;
                    %goto NoRun;
                %end;
                %else %do;
                    %put NOTE:[PXL] Macro PFESCRF_AUTO_TRIGGER returned YES and PFESCRF_AUTO does will be run;
                %end;                

                %if &GMPXLERR = 1 %then %do;
                    %goto MacErr;
                %end;
            %end;
            %else %do;
                %put NOTE:[PXL] SYSPARM NOT AUTO - Not Running PFESCRF_AUTO_TRIGGER, Manual Always Run PFESCRF_AUTO;
            %end;

        * 4) Get latest raw zip files and unzip to kennet;
            %sftp_zip;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 5) Create SAS datasets with coded data from raw data;
            %extract_download;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 6) Create SCRF datasets;
            %export_scrf;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 7) Verify SCRF datasets match CSDW SCRF Specification;
            %scrf_csdw_validation;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;

        * 8) Verify No/Confirmed Structure Change;
             %structure_change;
            %if &GMPXLERR = 1 %then %do;
               %goto MacErr;
            %end;
        
        * 9) Set Coding Special Character Warn Flag;
            %if %str("&extract_sc_exist") ne %str("N") %then %do;
                %let pfescrf_auto_PassOrFail = PASS *** WITH %str(WARN)ING ***;
            %end;
            %else %do;
                %let pfescrf_auto_PassOrFail = PASS;
            %end;

    %put NOTE:[PXL] ******************************************************************************* ;
    %put NOTE:[PXL] 5) Macro End and Cleanup;
    %put NOTE:[PXL] *******************************************************************************;
        %* 
         * 1) Abnormal Macro End 
         * 2) Send Final Email
         * 3) Archive Transfer
         * 4) Derive Run Duration
         * 5) Macro End Setup Reset
         * 6) Macro End Remove Work Datasets
         * 7) Macro End Remove Libnames Created
         * 8) Macro End Remove Catalogs Created
         * 9) Remove Global Macos Used
         * 10) Macro End Final Log Message
         *;

        %goto MacEnd;

        %MacErr:;
        * 1) Abnormal Macro End ;
            %put %str(ERR)OR:[PXL] ------------------------------------------------------;        
            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: Abnormal end to macro;
            %put %str(ERR)OR:[PXL] &pfescrf_auto_MacroName: See log for details;
            %put %str(ERR)OR:[PXL] Global macro GMPXLERR set to 1, macro terminated early;
            %put %str(ERR)OR:[PXL] ------------------------------------------------------;
            %let GMPXLERR=1;

        %MacEnd:;

        * 2) Send Final Transfer Overview Email to Study team and DEX;
            %send_email;    

        %* 2.2) Send Email to PCDA if Special Coding Listings Created;
            %email_pcda_coding;

        * 3) Archive Transfer;
            %archive_transfer; 

        %NoRun:;

        * 4) Derive Run Duration;
            %let end_datetime = ;
            data _null_;
               format startdtm enddtm IS8601DT.;
               startdtm = input(symget('pfescrf_auto_RunDateTime'), IS8601DT.);
               put "Macro Start Date and Time = " startdtm;
               enddtm=datetime();
               put "Macro End Date and Time = " enddtm;
               duration = enddtm - startdtm;
               call symput('end_datetime',"Macro &pfescrf_auto_MacroName Run Time as Hours:Minutes:Seconds: " || left(trim(put(duration, time9.))));   
            run;
            %put ;
            %put NOTE:[PXL] Total Duration = &end_datetime;
            %put ;

        * 5) Macro End Setup Reset;
            title;
            footnote;
            OPTIONS fmterr quotelenmax;; * Reset Ignore format notes in log;
            OPTIONS missing='.';
            options printerpath='';

        * 6) Macro End Remove Work Datasets;
            %macro delmac(wds=null);
                %if %sysfunc(exist(&wds)) %then %do; 
                    proc datasets lib=work nolist; delete &wds; quit; run; 
                %end; 
            %mend delmac;
            %delmac(wds=_temp);
            %delmac(wds=study_emails);
            %delmac(wds=dataset_info_final);
            %delmac(wds=elisting_tab1);
            %delmac(wds=elisting_tab2);
            %delmac(wds=elisting_tab3);
            %delmac(wds=elisting_tab4);
            %delmac(wds=issuesattrib);
            %delmac(wds=logissues);
            %delmac(wds=result_demog);
            %delmac(wds=_spec);
            %delmac(wds=_tab3);
            %delmac(wds=_dirlist);

        * 7) Macro End Remove Libnames Created;
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
            %dellib(libn=LIB_AT);
            %dellib(libn=SCRFQC);

        * 8) Macro End Remove Catalogs Created;
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

        * 9) Remove Global Macos Used;
            %symdel 
                PFEPISFTPGET_FAILMSG PFEPISFTPGET_PASSORFAIL 
                PFELOGCHECK_PDFLISTINGNAME PFELOGCHECK_TOTALLOGISSUES 
                PFEPROCCOMPARE_LISTINGNAME PFEPROCCOMPARE_NUMISSUESATTRIB PFEPROCCOMPARE_NUMISSUESVALUES PFEPROCCOMPARE_PASSORFAIL 
                PFESCRF_CSDW_VALIDATOR_ERRMSG PFESCRF_CSDW_VALIDATOR_LISTNAME PFESCRF_CSDW_VALIDATOR_NUMERR PFESCRF_CSDW_VALIDATOR_NUMWARN 
                PFESCRF_CSDW_VALIDATOR_PASSFAIL PFESTRUCTCOMPARE_ERRMSG PFESTRUCTCOMPARE_LISTNAME PFESTRUCTCOMPARE_NUMDIFF 
                PFESTRUCTCOMPARE_PASSFAIL PFESCRF_AUTO_TRIGGER_RUN PFESCRF_AUTO_TRIGGER_ERRMSG /nowarn;

        * 10) Macro End Final Log Message;
            %_MacEnd(MacroName=&pfescrf_auto_MacroName);

%mend pfescrf_auto;