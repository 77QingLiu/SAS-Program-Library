/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20150318       $LastChangedDate: 2015-09-22 14:32:59 -0400 (Tue, 22 Sep 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfescrf_csdw_validator.sas $
 
  Files Created:         Exception Listing Report in XML (Saved as XLS)
 
  Program Purpose:       Read CSDW SCRF SAS datasets and validate per below to create exception based output listing<br />
                            1) Compares against latest Pfizer Data Standards Catalog PDS CSDW Transfer Specifications - SCRF V4.0 (Modified for PAREXEL and Pfizer business rules)<br />
                            2) Compares against special Pfizer business rules

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:

    Name:                pfescrf_csdw_validator_metadata
      Allowed Values:    Valid KENNET path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Specifies the central metadata location that holds
                         specifications saved as SAS datasets
 
    Name:                pfescrf_csdw_validator_spec
      Allowed Values:    Valid SAS dataset 
      Default Value:     scrf_csdw_pxl
      Description:       SAS dataset name of PAREXEL 
                         modified CSDW SCRF Specification 
 
    Name:                pfescrf_csdw_validator_codelists
      Allowed Values:    Valid SAS dataset
      Default Value:     codelists
      Description:       SAS dataset of Pfizer codelist standard values

    Name:                pfescrf_csdw_validator_download
      Allowed Values:    SAS library 
      Default Value:     download
      Description:       SAS library that holds raw SAS datasets (Uncompressed SAS
                         datasets from SFTP raw XPT files with coded data merged in
                         from raw ASCII text files recieved from PI SFTP out of 
                         DataLabs)

    Name:                pfescrf_csdw_validator_scrf
      Allowed Values:    SAS library 
      Default Value:     scrf
      Description:       SAS library that holds the CSDW SCRF creates SAS 
                         datasets to check against 

    Name:                pfescrf_csdw_validator_pathlist
      Allowed Values:    Valid KENNET directory path
      Default Value:     path_listings
      Description:       Unix path to save the output listing. Defaults to use 
                         macro variable path_listings location. 

    Name:                pfescrf_csdw_validator_protocol
      Allowed Values:    Value of the protocol
      Default Value:     protocol
      Description:       Will use as name of protocol to check against, or use macro
                         variable PROTOCOL value.

    Name:                pfescrf_csdw_validator_pxl_code
      Allowed Values:    Value of the pxl code for study
      Default Value:     pxl_code
      Description:       Will use as name of pxl code for study to check against, 
                         or use macro variable pxl_code value.

    Name:                pfescrf_csdw_validator_AddDT
      Allowed Values:    Y or N
      Default Value:     N
      Description:       If Y, will add date and time to output listing name

    Name:                pfescrf_csdw_validator_test
      Allowed Values:    Y or N
      Default Value:     N
      Description:       If N, will not save the date and time to the file name.

  Global Macrovariables:
 
    Name:                pfescrf_csdw_validator_PassFail
      Usage:             Creates
      Description:       Sets to PASS or FAIL depnding on macro outcome
 
    Name:                pfescrf_csdw_validator_NumErr
      Usage:             Creates
      Description:       Sets to number of ERR OR issues found
 
    Name:                pfescrf_csdw_validator_NumWarn
      Usage:             Creates
      Description:       Sets to number of WARN ING issues found

    Name:                pfescrf_csdw_validator_ListName
      Usage:             Creates
      Description:       Sets to name of output listing created

    Name:                pfescrf_csdw_validator_ErrMsg
      Usage:             Creates
      Description:       Sets to message for any abnormal termination

  Metadata Keys:
 
    Name:                Reference Specification Data
      Description:       PAREXEL Modified Pfizer Data Standards CSDW SCRF Specification
                         Defaulted locoation per input parameter &pfescrf_csdw_validator_metadata
                         Defaulted dataset name per input parameter &pfescrf_csdw_validator_spec
      Dataset:           scrf_csdw_pxl
 
    Name:                Reference Codelist Data
      Description:       Holds all possible Pfizer codelist values
                         Defaulted locoation per input parameter &pfescrf_csdw_validator_metadata
                         Defaulted dataset name per input parameter &pfescrf_csdw_validator_spec
      Dataset:           codelists

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1105 $

-----------------------------------------------------------------------------*/

%macro pfescrf_csdw_validator(
    pfescrf_csdw_validator_metadata=/projects/std_pfizer/sacq/metadata/data,
    pfescrf_csdw_validator_spec=scrf_csdw_pxl,
    pfescrf_csdw_validator_codelists=codelists,
    pfescrf_csdw_validator_download=download,
    pfescrf_csdw_validator_scrf=scrf,
    pfescrf_csdw_validator_pathlist=null,
    pfescrf_csdw_validator_protocol=null,
    pfescrf_csdw_validator_pxl_code=null,
    pfescrf_csdw_validator_AddDT=N,
    pfescrf_csdw_validator_test=N);

    /*
      Version History:
        Version: V1.0 Date: 20150821 Author: Nathan Hartley
          1) Initial Version  
        Version: V2.0 Date: 20150922 Author: Nathan Hartley
          1) Removed check 4.05
    */

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Macro Startup;
    %put NOTE:[PXL] ***********************************************************************;
        OPTIONS nofmterr; * Ignore format notes in log;
        OPTIONS noquotelenmax; * Ignore longer macro variable strings;
        title;
        footnote;

        * Macro Variable Declarations;
          %let pfescrf_csdw_validator_MacName  = PFESCRF_CSDW_VALIDATOR;
          %let pfescrf_csdw_validator_MacVer   = 2.0;
          %let pfescrf_csdw_validator_MacVerDT = 20150922;
          %*let pfescrf_csdw_validator_MacPath  = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
          %let pfescrf_csdw_validator_MacPath  = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
          %let pfescrf_csdw_validator_RunDTE   = %sysfunc(left(%sysfunc(datetime(), IS8601DT.)));
          %*let pfescrf_csdw_validator_RunDateTime      = %sysfunc(compress(%sysfunc(left(%sysfunc(datetime(), IS8601DT.))), '-:'));

        * Global return macros - used with submacro call from a parent;
          %global 
              pfescrf_csdw_validator_PassFail 
              pfescrf_csdw_validator_NumErr 
              pfescrf_csdw_validator_NumWarn 
              pfescrf_csdw_validator_ListName
              pfescrf_csdw_validator_ErrMsg;

          %let pfescrf_csdw_validator_PassFail = FAIL; * PASS or FAIL final outcome, Any Err ors then FAIL;
          %let pfescrf_csdw_validator_NumErr   = null; * Number of err or issues;
          %let pfescrf_csdw_validator_NumWarn  = null; * Number of warn ing issues;
          %let pfescrf_csdw_validator_ListName = null; * Path and name of output listing created;
          %let pfescrf_csdw_validator_ErrMsg   = null; * If program run has issues, lists what the issue was;

        * Log output input parameters;
          %put INFO:[PXL]----------------------------------------------;
          %put INFO:[PXL] &pfescrf_csdw_validator_MacName: Macro Started; 
          %put INFO:[PXL] File Location: &pfescrf_csdw_validator_MacPath ;
          %put INFO:[PXL] Version Number: &pfescrf_csdw_validator_MacVer ;
          %put INFO:[PXL] Version Date: &pfescrf_csdw_validator_MacVerDT ;
          %put INFO:[PXL] Run DateTime: &pfescrf_csdw_validator_RunDTE;        
          %put INFO:[PXL] ;
          %put INFO:[PXL] Purpose: Verify CSDW SCRF Datasets Confirm to Standards ; 
          %put INFO:[PXL] Input Parameters:;
          %put INFO:[PXL]   1) pfescrf_csdw_validator_metadata = &pfescrf_csdw_validator_metadata;
          %put INFO:[PXL]   2) pfescrf_csdw_validator_spec = &pfescrf_csdw_validator_spec;
          %put INFO:[PXL]   3) pfescrf_csdw_validator_codelists = &pfescrf_csdw_validator_codelists;
          %put INFO:[PXL]   4) pfescrf_csdw_validator_download = &pfescrf_csdw_validator_download;
          %put INFO:[PXL]   6) pfescrf_csdw_validator_scrf = &pfescrf_csdw_validator_scrf;
          %put INFO:[PXL]   7) pfescrf_csdw_validator_pathlist = &pfescrf_csdw_validator_pathlist;
          %put INFO:[PXL]   8) pfescrf_csdw_validator_protocol = &pfescrf_csdw_validator_protocol;
          %put INFO:[PXL]   9) pfescrf_csdw_validator_pxl_code = &pfescrf_csdw_validator_pxl_code;
          %put INFO:[PXL]  10) pfescrf_csdw_validator_AddDT = &pfescrf_csdw_validator_AddDT;
          %put INFO:[PXL]----------------------------------------------;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Setup of Internal Macros;
    %put NOTE:[PXL] ***********************************************************************;

        * PURPOSE: Verify if file directory exists
          INPUT:  1) pathdir = directory path text
          OUTPUT: 1) returns: 1 if dir exists
                              0 if dir does not exist
                             -1 if abnormal macro end;
            %put NOTE:[PXL] Creating mu_direxist;
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

        * PURPOSE: Verify if variable exists in a SAS dataset
          INPUT:  1) dsname = name of the SAS dataset
                  2) varname = name of SAS variable to verify existance
          OUTPUT: 1) returns: 1 if variable exists
                              0 if variable does not exist
                             -1 if dataset does not exist or abnormal macro end;
            %put NOTE:[PXL] Creating mu_varexist;
            %macro mu_varexist(dsname=_last_, varname=null);
                %local _rc;
                %let _rc = -1;

                %if %sysfunc(exist(&dsname)) %then %do;
                    %local _dsid;
                    %let _dsid = %sysfunc(open(&dsname));
                    %if &_dsid >= 1 %then %do;
                        %if %sysfunc(varnum(&_dsid, &varname)) %then %do;
                            %let _rc = 1;
                        %end;
                        %else %do;
                            %let _rc = 0;
                        %end;
                    %end;
                    %let _dsid = %sysfunc(close(&_dsid));
                %end;
                %else %do;
                    %*put %str(WARN)ING:[PXL] MU_VAREXIST: Dataset DSNAME=&DSNAME does not exist.;
                %end;

                %if %eval(&_rc) >= 1 %then %do ;
                    1
                %end ;
                %else %if %eval(&_rc) = 0 %then %do ;
                    0
                %end ;
                %else %do ;
                    -1
                %end ;
            %mend mu_varexist;

        * PURPOSE: Return variable type
          INPUT:  1) dsname = Name of dataset containing the variable
                  2) varname = Name of the variable
          OUTPUT: 1) Return values:
                     C = Variable is of type CHARACTER
                     N = Variable is of type NUMERIC (includes DATES)
                     X = The variable type could not be determined, which also includes that the variable 
                         does not exist in the dataset;
            %put NOTE:[PXL] Creating mu_vartype;
            %macro mu_vartype(dsname=_last_, varname=null);
                %let _rc = X ;

                %if %sysfunc(exist(&dsname)) %then %do;
                    %local _dsid ;
                    %let _dsid = %sysfunc(open(&dsname));
                    %if &_dsid >= 1 %then %do ;
                        %if %mu_varexist(dsname=&dsname,varname=&varname) %then %do;
                            %let _rc = %sysfunc(vartype(&_dsid,(%sysfunc(varnum(&_dsid, &varname )))));
                        %end;
                        %else %do;
                            %put %str(WARN)ING:[PXL] MU_VARTYPE: Dataset DSNAME=&DSNAME exists but VARNAME=&VARNAME does not exist.;
                        %end;
                    %end;
                    %let _dsid = %sysfunc(close(&_dsid));
                %end;
                %else %do;
                    %put %str(WARN)ING:[PXL] MU_VARTYPE: Dataset DSNAME=&DSNAME does not exist.;
                %end;

                %if %upcase(&_rc) = %str(C) %then %do;
                  C
                %end;
                %else %if %upcase(&_rc) = %str(N) %then %do;
                  N
                %end;
                %else %do;
                  X
                %end;                
            %mend mu_vartype;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Verify Source Data;
    %put NOTE:[PXL] ***********************************************************************;

        %put NOTE:[PXL] 1) Verify Global MAD macro DEBUG (option statement);
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
                    OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOFMTERR /* NOSOURCE NONOTES */;
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
                %let pfescrf_csdw_validator_ErrMsg = Global macro GMPXLERR = 1, macro not executed;
                %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg;
                %goto MacErr;
            %end;          

        %put NOTE:[PXL] 3) Verify Reference Metadata Exists;
            %put NOTE:[PXL] 3.1) Check if pfescrf_csdw_validator_metadata is a valid directory;
                %if %mu_direxist(pathdir=&pfescrf_csdw_validator_metadata) = 0 %then %do;
                    %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_metadata does not exist: &pfescrf_csdw_validator_metadata;
                    %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg;
                    %goto MacErr;
                %end;

                libname lib_md "&pfescrf_csdw_validator_metadata";

            
            %put NOTE:[PXL] 3.2) Verify metadata specification exists;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vtable 
                    where libname="LIB_MD"
                          and memname=%upcase("&pfescrf_csdw_validator_spec");
                quit;
                %if &exists=0 %then %do;
                    %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_spec does not exist: &pfescrf_csdw_validator_metadata/&pfescrf_csdw_validator_spec;
                    %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg;
                    %goto MacErr;                
                %end;
                %put NOTE:[PXL] pfescrf_csdw_validator_spec = &pfescrf_csdw_validator_spec;

                data spec_data;
                set LIB_MD.&pfescrf_csdw_validator_spec;
                run;

                proc sql noprint;
                    select memlabel into: spec_label
                    from sashelp.vtable 
                    where libname = "LIB_MD"
                          and memname = "%upcase(&pfescrf_csdw_validator_spec)";
                quit;            

            %put NOTE:[PXL] 3.3) Verify metadata codelist info exists;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vtable 
                    where libname="LIB_MD"
                          and memname="%upcase(&pfescrf_csdw_validator_codelists)";
                quit;
                %if &exists=0 %then %do;
                    %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_codelists does not exist: &pfescrf_csdw_validator_metadata/&pfescrf_csdw_validator_codelists;
                    %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg;
                    %goto MacErr;                
                %end;
                %put NOTE:[PXL] pfescrf_csdw_validator_codelists = &pfescrf_csdw_validator_codelists;

                data codelists;
                set LIB_MD.&pfescrf_csdw_validator_codelists;
                run;

                proc sql noprint; 
                    select memlabel into: codelists_label
                    from sashelp.vtable 
                    where libname = "LIB_MD"
                          and memname = "%upcase(&pfescrf_csdw_validator_codelists)";
                quit;            

        %put NOTE:[PXL] 4) Verify libname pfescrf_csdw_validator_download and derive path_download;
            * Check if input parameter libname &pfescrf_csdw_validator_download exists;
            proc sql noprint;
                select count(*) into: cnt
                from sashelp.vslib
                where libname = "%upcase(&pfescrf_csdw_validator_download)";
            quit;            
            %if %eval(&cnt = 0) %then %do;
                %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_download is not a valid SAS library: &pfescrf_csdw_validator_download;
                %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg;
                %goto MacErr;
            %end;

            proc sql noprint;
                select distinct
                    path into :path_download
                from sashelp.vlibnam 
                where libname="%upcase(&pfescrf_csdw_validator_download)";
            quit;    
            %let path_download = %left(%trim(&path_download));
            %put NOTE:[PXL] path_download = &path_download;

            * Remove /current if found to get current symbolic path;
            data _null_;
                length _path $200.;
                _path=left(trim(symget('path_download')));
                _path = tranwrd(_path, '/current', '');
                call symput('path_download_updated',_path);
            run;
            %put NOTE:[PXL] path_download_updated = &path_download_updated;

            * Get the symbolic link path for download current;
            filename dirlist pipe "ls -la %left(%trim(&path_download_updated))" ;

            * Set path_download_sl with folder the symbolic link current points too if it exists;
            %let path_download_sl=No Symbolic Link Found;
            data work._dirlist ;
                length dirline dirline2 $200 ;
                infile dirlist recfm=v lrecl=200 truncover ;
                input dirline $1-200 ;
                dirline2 = substr(dirline,59);
                if substr(dirline2,1,7) = 'current' then call symput('path_download_sl',dirline2);
            run;    
            %put NOTE:[PXL] path_download_sl = &path_download_sl;

        %put NOTE:[PXL] 5) Verify libname pfescrf_csdw_validator_scrf and derive path_scrf;
            * Check if libname &pfescrf_csdw_validator_scrf exists;
            proc sql noprint;
                select count(*) into: cnt
                from sashelp.vslib
                where libname = "%upcase(&pfescrf_csdw_validator_scrf)";
            quit;            
            %if %eval(&cnt = 0) %then %do;
                %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_scrf is not a valid SAS library: &pfescrf_csdw_validator_scrf;
                %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg;                      
                %goto MacErr;                
            %end; 

            * Get actual path of SAS library;
            proc sql noprint;
                select distinct
                    path into :path_scrf
                from sashelp.vlibnam 
                where libname="%upcase(&pfescrf_csdw_validator_scrf)";
            quit;    
            %let path_scrf = %left(%trim(&path_scrf));
            %put NOTE:[PXL] path_scrf = &path_scrf;

            * Remove /current if found to get current symbolic path;
            data _null_;
                length _path $200.;
                _path=left(trim(symget('path_scrf')));
                _path = tranwrd(_path, '/current', '');
                call symput('path_scrf_updated',_path);
            run;
            %put NOTE:[PXL] path_scrf_updated = &path_scrf_updated;

            * Get the symbolic link path for download current;
            filename dirlist pipe "ls -la %left(%trim(&path_scrf_updated))" ;

            * Set path_download_sl with folder the symbolic link current points too if it exists;
            %let path_scrf_sl=No Symbolic Link Found;
            data work._dirlist ;
                length dirline dirline2 $200 ;
                infile dirlist recfm=v lrecl=200 truncover ;
                input dirline $1-200 ;
                dirline2 = substr(dirline,59);
                if substr(dirline2,1,7) = 'current' then call symput('path_scrf_sl',dirline2);
            run;
            %put NOTE:[PXL] path_scrf_sl = &path_scrf_sl;

        %put NOTE:[PXL] 6) Verify pfescrf_csdw_validator_pathlist is valid directory for listing output;
            %if %str("&pfescrf_csdw_validator_pathlist")=%str("null") %then %do;
                * Get listing path from global macro path_listings if exists
                  this is global macro created by pfizer standard setup, should poing to /projects/pfizrNNNNNN/dm/listings;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vmacro 
                    where name="PATH_LISTINGS";
                quit;
                %if &exists=0 %then %do;
                    %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_pathlist is null and global macro PATH_LISTINGS does not exist;
                    %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg; 
                    %goto MacErr;
                %end;
                %else %do;
                    %put NOTE:[PXL] Global macro path_listings exists, creating symbolic link current to today dated folder;
                    %sysexec %str(mkdir -p  &PATH_LISTINGS/%sysfunc(today(),yymmddn8.)); * Create new dated folder;
                    %sysexec %str(rm -rf &PATH_LISTINGS/current 2> /dev/null); * Delete current symbolic link;
                    %sysexec %str(ln -s &PATH_LISTINGS/%sysfunc(today(),yymmddn8.) &PATH_LISTINGS/current 2> /dev/null); * Create new symbolic link;

                    %let pfescrf_csdw_validator_pathlist = &PATH_LISTINGS/current;
                %end;                
            %end;
            %else %do;
                * Check if given path is valid directory;
                %if %mu_direxist(pathdir=&pfescrf_csdw_validator_pathlist) = 0 %then %do;
                    %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_pathlist is not a valid directory: &pfescrf_csdw_validator_pathlist;
                    %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg; 
                    %goto MacErr;
                %end;               
            %end;
            %let pfescrf_csdw_validator_pathlist = %left(%trim(&pfescrf_csdw_validator_pathlist));

        %put NOTE:[PXL] 7) Verify pfescrf_csdw_validator_protocol;
            %if %str("&pfescrf_csdw_validator_protocol")=%str("null") %then %do;
                * Default, check if can get from global macro protocol;

                * First check if macro protocol exists;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vmacro 
                    where name="PROTOCOL";
                quit;
                %if &exists=0 %then %do;
                    %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_protocol is null and global macro protocol does not exist;
                    %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg; 
                    %goto MacErr;
                %end;
                %else %do;
                    %let pfescrf_csdw_validator_protocol = &protocol;
                %end;
                %let pfescrf_csdw_validator_protocol = %left(%trim(&pfescrf_csdw_validator_protocol));
            %end;

        %put NOTE:[PXL] 8) Verify pfescrf_csdw_validator_pxl_code;
            %if %str("&pfescrf_csdw_validator_pxl_code")=%str("null") %then %do;
                * Default, check if can get from global macro PXL_CODE;

                * First check if macro PXL_CODE exists;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vmacro 
                    where name="PXL_CODE";
                quit;
                %if &exists=0 %then %do;
                    %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_pxl_code is null and global macro PXL_CODE does not exist;
                    %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg; 
                    %goto MacErr;
                %end;
                %else %do;
                    %let pfescrf_csdw_validator_pxl_code = &pxl_code;
                %end;
                %let pfescrf_csdw_validator_pxl_code = %left(%trim(&pfescrf_csdw_validator_pxl_code));
            %end;

        %put NOTE:[PXL] 9) Verify pfescrf_csdw_validator_AddDT;
            * Check if exists and value must be N or Y;
            %let pfescrf_csdw_validator_AddDT=%left(%trim(%upcase(&pfescrf_csdw_validator_AddDT)));
            %if %str("&pfescrf_csdw_validator_AddDT") ne "N" and %str("&pfescrf_csdw_validator_AddDT") ne "Y" %then %do;
                %let pfescrf_csdw_validator_ErrMsg = Input Parameter pfescrf_csdw_validator_AddDT is not N or Y: &pfescrf_csdw_validator_AddDT;
                %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: &pfescrf_csdw_validator_ErrMsg; 
                %goto MacErr;               
            %end;

        %put NOTE:[PXL] 10) Derive base for ouput listing file name;
            %if %str("&pfescrf_csdw_validator_AddDT") = "N"  %then %do;
                %let pfescrf_csdw_validator_ListName = &pfescrf_csdw_validator_pxl_code &pfescrf_csdw_validator_protocol PFESCRF CSDW Validator Listing;
            %end;
            %else %if "&pfescrf_csdw_validator_AddDT" = "Y" %then %do;
                %let pfescrf_csdw_validator_ListName = &pfescrf_csdw_validator_pxl_code &pfescrf_csdw_validator_protocol PFESCRF CSDW Validator Listing %sysfunc(compress(&pfescrf_csdw_validator_RunDTE, '-:'));
            %end;

        %put INFO:[PXL]------------------------------------------------------;
        %put INFO:[PXL] Verified/Updated Input Parameters:;
        %put INFO:[PXL]    1) pfescrf_csdw_validator_metadata=&pfescrf_csdw_validator_metadata;
        %put INFO:[PXL]    2) pfescrf_csdw_validator_spec=&pfescrf_csdw_validator_spec..sas7bat &spec_label;
        %put INFO:[PXL]    3) pfescrf_csdw_validator_codelists=&pfescrf_csdw_validator_codelists..sas7bdat &codelists_label;
        %put INFO:[PXL]    4) pfescrf_csdw_validator_download=&pfescrf_csdw_validator_download;
        %put INFO:[PXL]       Library DOWNLOAD directory path: &path_download;
        %put INFO:[PXL]       Symbolic link current path (is used):&path_download_sl;
        %put INFO:[PXL]    5) pfescrf_csdw_validator_scrf=&pfescrf_csdw_validator_scrf;
        %put INFO:[PXL]       Library SCRF directory path: &path_scrf;
        %put INFO:[PXL]       Symbolic link current path (is used):&path_scrf_sl;
        %put INFO:[PXL]    6) pfescrf_csdw_validator_pathlist=&pfescrf_csdw_validator_pathlist;
        %put INFO:[PXL]    7) pfescrf_csdw_validator_protocol=&pfescrf_csdw_validator_protocol;
        %put INFO:[PXL]    8) pfescrf_csdw_validator_pxl_code=&pfescrf_csdw_validator_pxl_code;
        %put INFO:[PXL]    9) pfescrf_csdw_validator_AddDT=&pfescrf_csdw_validator_AddDT;       
        %put INFO:[PXL] ;
        %put INFO:[PXL] Base for Output Listing File Name:;
        %put INFO:[PXL]    1) File Output Name=&pfescrf_csdw_validator_ListName;
        %put INFO:[PXL]------------------------------------------------------;         

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Create work dataset _data_spec_attrib;
    %put NOTE:[PXL] ***********************************************************************;
        * Create workdataset _data_spec_attrib: 
          Merge SCRF data attributes to CSDW SCRF spec info by 
          dataset, dataset domain version, and variable. This is
          used in several checks. ;    

        * Get data list of csdw scrf datasets;
        proc sql noprint;
            create table _data as
            select memname as dataset length=32, 
                   memlabel
            from sashelp.vtable
            where libname = "%upcase(&pfescrf_csdw_validator_scrf)"
            order by 1;
        quit;

        * Get spec datasets and domains versions;
        proc sql noprint;
            create table _spec as
            select distinct 
                dataset length=32, 
                domain_version
            from spec_data
            order by 1, 2;
        quit;

        * Get match between data and spec by dataset and domain version;
        data _data_spec_datasets;
        merge _data(in=a) _spec(in=b);
        by dataset;
            if a and b;
            if not missing(memlabel) and not missing(domain_version);
            if not missing(input(memlabel,?? best.));

            if input(memlabel, best.) <= domain_version then 
                output;
            else if last.dataset then
                output;
        run;

        * Append all data attributes;
        proc sql noprint;
            create table _data_spec_var1 as
            select 
                a.dataset as data_dataset,
                a.memlabel as data_dataset_label length=200,
                b.name as data_variable,
                b.type as data_type,
                b.length as data_length,
                b.format as data_format,
                b.label as data_label
            from _data_spec_datasets as a
                 inner join 
                 (select * from sashelp.vcolumn where libname="%upcase(&pfescrf_csdw_validator_scrf)") as b
            on a.dataset = b.memname
            order by 1, 2;
        quit;

        * Get list of csdw scrf spec records for only datasets that match to data;
        proc sql noprint;
            create table _data_spec_var2 as
            select a.*
            from 
                spec_data as a
                inner join
                _data_spec_datasets as b
            on a.dataset = b.dataset
               and a.domain_version = b.domain_version
            order by 1, 2;
        quit;

        * Append csdw scrf spec attributes;
        proc sql noprint;
            create table _data_spec_attrib as 
            select 
                coalescec(a.data_dataset, b.dataset) as dataset,
                coalescec(a.data_variable, b.var_name) as variable,

                a.*,

                b.dataset as spec_dataset,
                b.domain_version as spec_domain_version,
                b.var_name as spec_variable,
                b.core as spec_core,
                b.sas_data_type as spec_type,
                b.sas_length as spec_length,
                b.var_label as spec_label,
                b.sas_format as spec_format,
                b.comments as spec_comments,
                b.pxl_notes as spec_PXL_Notes
            from 
                _data_spec_var1 as a
                full outer join
                _data_spec_var2 as b 
            on 
                a.data_dataset = b.dataset 
                and a.data_variable = b.var_name
            order by 1, 2;
        quit;

        %put NOTE:[PXL] -----------------------------------------------;
        %put NOTE:[PXL] End of Create workdataset _data_spec_attrib;
        %put NOTE:[PXL] -----------------------------------------------;  

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Validation Checks;
    %put NOTE:[PXL] ***********************************************************************;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Validation Setup;
        %put NOTE:[PXL] ***********************************************************************;
            * Empty output Shell;
            data elisting_tab3;
                length checkid type pxl_Notes dataset variable data_value data_key $200.;
                checkid = '';
                type = '';
                pxl_Notes = '';     
                dataset = '';
                variable = '';
                data_value = '';
                data_key = ''; 
                delete;
            run;      

            data elisting_tab4;
                length checkid dataset variable $200.;
                checkid = '';
                dataset = '';
                variable = '';
                cnt_mis = 0;
                cnt_pre = 0;
                cnt_exp = 0;
                cnt_tot = 0;
                delete; 
            run; 

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Validation Checks 1.01-1.08;
        %put NOTE:[PXL] ***********************************************************************;

            * Check 1.01 Dataset exists that is not in spec - Remove LAB_SAFE1; 
                %put NOTE:[PXL] Start Check 1.01;
                proc sql noprint;
                    create table _1_01 as
                    select 
                        'CK 1.01' as checkid length=200,
                        "%str(WARN)ING" as type length=200,
                        b.memname as dataset length=200,
                        'N/A' as variable length=200,
                        memname as data_dataset length=200,
                        memlabel as data_dataset_label length=200                        
                    from
                        (   
                            select distinct dataset 
                            from spec_data
                        ) as a 
                        right outer join
                        (
                            select distinct memname, memlabel 
                            from sashelp.vtable
                            where libname = "%upcase(&pfescrf_csdw_validator_scrf)"
                        ) as b 
                    on a.dataset = b.memname
                    where a.dataset is null
                          and b.memname not in ('LAB_SAFE1')
                    order by b.memname;
                quit;

                data elisting_tab3;
                set elisting_tab3 _1_01;
                run; 

            * Check 1.02 Dataset label does not have a valid domain version specified;
                %put NOTE:[PXL] Start Check 1.02;
                proc sql noprint;
                    create table _elisting as
                    select 
                        'CK 1.02' as checkid length=200,
                        "%str(ERR)OR" as type length=200,
                        memname as dataset length=200,
                        'N/A' as variable length=200,
                        memname as data_dataset length=200,
                        memlabel as data_dataset_label length=200
                    from sashelp.vtable
                    where 
                        libname = "%upcase(&pfescrf_csdw_validator_scrf)"
                        and memname not in ('LAB_SAFE1')
                        and memname not in (select dataset from _1_01)
                    order by 1, 2;
                quit;

                data _elisting;
                set _elisting;
                    if missing(input(data_dataset_label,?? best.)) then 
                        output;
                    else do;
                        if input(data_dataset_label, best.) <= 0
                           or input(data_dataset_label, best.) > 100 then 
                           output;
                    end;
                run;

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;    

            * Check 1.03 Dataset label greater than spec domain version;
                %put NOTE:[PXL] Start Check 1.03;
                proc sql noprint;
                    create table _elisting as
                    select 
                        'CK 1.03' as checkid length=200,
                        "%str(WARN)ING" as type length=200,
                        a.memname as dataset length=200,
                        'N/A' as variable length=200,
                        a.memname as data_dataset length=200,
                        a.memlabel as data_dataset_label length=200,                  
                        b.dataset as spec_dataset length=200,
                        b.domain_version as spec_domain_version
                    from 
                        (   
                            select memname, memlabel
                            from sashelp.vtable
                            where libname = "%upcase(&pfescrf_csdw_validator_scrf)"
                                  and memname not in ('LAB_SAFE1')) as a
                        inner join
                        (
                            select distinct 
                                dataset, 
                                max(domain_version) as domain_version
                            from spec_data
                            group by dataset) as b
                    on a.memname = b.dataset
                    order by 1, 2, 3, 4;
                quit;

                data _elisting;
                set _elisting;
                    if missing(input(data_dataset_label,?? best.)) then 
                        delete;
                    else do;
                        if input(data_dataset_label, best.) > spec_domain_version 
                           and input(data_dataset_label, best.) <= 100 then 
                           output;
                    end;
                run;

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;    

            * Check 1.04 Check if earliest download date is greater than latest scrf date; 
                %put NOTE:[PXL] Start Check 1.04;
                proc sql noprint;
                    create table _elisting as
                    select 
                        'CK 1.04' as checkid length=200,
                        "%str(ERR)OR" as type length=200,
                        "ALL [&pfescrf_csdw_validator_download]" as dataset length=200,
                        "N/A"  as variable length=200,
                        catx(" ","Earlist &pfescrf_csdw_validator_download file date ",
                            put(a.download_max_date, E8601DT.),
                            " is after the latest &pfescrf_csdw_validator_scrf date",
                            put(b.scrf_min_date, E8601DT.)) as pxl_notes length=200
                    from (  select 1 as ord, max(crdate) as download_max_date format=datetime20.
                            from sashelp.vtable
                            where libname = "%upcase(&pfescrf_csdw_validator_download)") as a
                        inner join
                        (   select 1 as ord, min(crdate) as scrf_min_date format=datetime20.
                            from sashelp.vtable
                            where libname = "%upcase(&pfescrf_csdw_validator_scrf)") as b
                    on a.ord=b.ord
                    where not missing(a.download_max_date) 
                          and not missing(b.scrf_min_date)
                          and a.download_max_date > b.scrf_min_date;                          
                quit;

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;  

            * Check 1.05 Global macro variable "dataSensitivity" does not exist or is valid.; 
                * Check if global macro variable "dataSensitivity" exists;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vmacro 
                    where name="DATASENSITIVITY";
                quit;
                %if %eval(&exists = 0) %then %do;
                    data _listing;
                        length checkid type dataset variable PXL_Notes $200.;
                        checkid = 'CK 1.05';
                        type = "%str(ERR)OR";
                        dataset = 'N/A';
                        variable = 'N/A';
                        PXL_Notes = 'Global macro variable dataSensitivity does not exist';
                    run;
                    %let dataSensitivity = ;

                    data elisting_tab3;
                    set elisting_tab3 _listing;
                    run;
                %end;
                %else %do;
                    %let DATASENSITIVITY = %left(%trim(&DATASENSITIVITY));
                    %if %str("&DATASENSITIVITY") ne %str("NOT_SENSITIVE_DATA")
                        and %str("&DATASENSITIVITY") ne %str("DUMMY/MASKED_DATA")
                        and %str("&DATASENSITIVITY") ne %str("SENSITIVE_DATA") %then %do;

                        data _listing;
                            length checkid type dataset variable PXL_Notes $200.;
                            checkid = 'CK 1.05';
                            type = "%str(ERR)OR";                            
                            dataset = 'N/A';
                            variable = 'N/A';
                            PXL_Notes = "Global macro variable value is not valid dataSensitivity=&dataSensitivity";
                        run;

                        data elisting_tab3;
                        set elisting_tab3 _listing;
                        run;
                    %end;
                    %else %do;
                        %put NOTE:[PXL] Global macro variable dataSensitivity = &dataSensitivity;
                    %end;
                %end;     

            * Check 1.06 Symbolic Link current within libname DOWNLOAD points to DRAFT;
                %if %index(&path_download_sl,draf) > 0 %then %do;
                    data _elisting;
                        length checkid type dataset variable PXL_Notes $200.;
                        checkid = 'CK 1.06';
                        type = "%str(ERR)OR";                        
                        dataset = 'N/A';
                        variable = 'N/A';
                        PXL_Notes = "Symbolic Link current within libname DOWNLOAD points to DRAFT";
                    run;

                   data elisting_tab3;
                        set elisting_tab3 _elisting;
                    run;
                %end;

            * Check 1.07 Symbolic Link current within libname SCRF points to DRAFT;
                %if %index(&path_scrf_sl,draft) > 0 %then %do;
                    data _elisting;
                        length checkid type dataset variable PXL_Notes $200.;
                        checkid = 'CK 1.07';
                        type = "%str(ERR)OR";                        
                        dataset = 'N/A';
                        variable = 'N/A';
                        PXL_Notes = "Symbolic Link current within libname SCRF points to DRAFT";
                    run;

                   data elisting_tab3;
                        set elisting_tab3 _elisting;
                    run;
                %end;   

            * Check 1.08 SCRF Dataset DEMOG must exist;
                %put NOTE:[PXL] Start Check 1.08;

                proc sql noprint;
                    select count(*) into: exists
                    from sashelp.vtable
                    where 
                        libname = "%upcase(&pfescrf_csdw_validator_scrf)"
                        and memname in ('DEMOG');
                quit;
                %if %eval(&exists = 0) %then %do;
                    data _elisting;
                        length checkid type dataset variable PXL_Notes $200.;
                        checkid = 'CK 1.08';
                        type = "%str(ERR)OR";                        
                        dataset = 'DEMOG';
                        variable = 'N/A';
                        PXL_Notes = "";
                    run;

                    data elisting_tab3;
                        set elisting_tab3 _elisting;
                    run;
                %end;

            * Check 1.09 Check 1.09 Libname %upcase(&pfescrf_csdw_validator_download) contains no datasets;
                %put NOTE:[PXL] Start Check 1.09;

                proc sql noprint;
                    select count(*) into: exists
                    from sashelp.vtable
                    where libname = "%upcase(&pfescrf_csdw_validator_download)";
                quit;

                %if %eval(&exists = 0) %then %do;
                    data _elisting;
                        length checkid type dataset variable PXL_Notes $200.;
                        checkid = 'CK 1.09';
                        type = "%str(ERR)OR";                        
                        dataset = 'N/A';
                        variable = 'N/A';
                        PXL_Notes = "";
                    run;

                    data elisting_tab3;
                        set elisting_tab3 _elisting;
                    run;
                %end;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Validation Checks 2.01-2.06;
        %put NOTE:[PXL] ***********************************************************************;

            * Checks 2.01-2.05;
                data _elisting;
                    length checkid type data_dataset_label $200;
                set _data_spec_attrib;
                    if not missing(data_variable) and missing(spec_variable) then do;
                        checkid = "CK 2.01";
                        type = "%str(WARN)ING";
                        output;
                    end;

                    if spec_core = 'REQUIRED'
                        and missing(data_variable) then do;
                        checkid = "CK 2.05";
                        type = "%str(ERR)OR";
                        output;
                    end;

                    if not missing(data_variable)
                       and not missing(spec_variable) then do;

                        if upcase(data_type) ne upcase(spec_type) then do;
                            checkid = "CK 2.02";
                            type = "%str(ERR)OR";
                            output;
                        end;

                        if data_length ne spec_length then do;
                            checkid = "CK 2.03";
                            type = "%str(ERR)OR";
                            output;
                        end;

                        if data_label ne spec_label then do;
                            checkid = "CK 2.04";
                            type = "%str(ERR)OR";
                            output;
                        end;                                      
                    end;

                    delete;
                run;
                  
                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;

            * Check 2.06 - format does not match spec format expected codelist name;
                data _elisting(drop=_format);
                    length _format $200.;
                set _data_spec_attrib;
                    checkid = "CK 2.06";
                    type = "%str(ERR)OR";

                    if not missing(data_variable)
                       and not missing(spec_variable);

                    if data_format ne spec_format;

                    if index(spec_comments, 'DATA STANDARDS CODELISTS /') > 0 then do;
                        if spec_type = 'NUM' then 
                            _format = cats(tranwrd(spec_comments,'DATA STANDARDS CODELISTS /',''), '.');
                        if spec_type = 'CHAR' then
                            _format = cats('$', tranwrd(spec_comments,'DATA STANDARDS CODELISTS /',''), '.');
                    end;
                    else if index(spec_comments, 'GRADES CODELISTS /') > 0 then do;
                        if spec_type = 'NUM' then 
                            _format = cats(tranwrd(spec_comments,'GRADES CODELISTS /',''), '.');
                        if spec_type = 'CHAR' then
                            _format = cats('$', tranwrd(spec_comments,'GRADES CODELISTS /',''), '.');
                    end;
                    else if spec_type = 'NUM' and not missing(spec_format) then do;
                        if index(spec_format,'.') = 0 then _format = cats(spec_format,'.');
                    end; 

                    if data_format = _format then delete;

                    * Special add 'G' to end for GRADES codelists with same name;
                    if index(spec_comments, 'GRADES CODELISTS /') > 0 then do;
                      _format = catt(compress(_format,'.'),'G.');
                        if data_format = _format then delete;
                    end; 

                run;   

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;                    

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Validation Checks 3.01-3.11;
        %put NOTE:[PXL] ***********************************************************************;
            * Check 3.01 Value not found in codelist
              Will identify codelist values in data and check to see if that value 
              exists in the metadata codelists spec;
                %put NOTE:[PXL] Start Check 3.01 Value present found in codelist;

                * Get codelist info and matches of variables that have a codelist;
                data _temp;
                    length spec_codelist_standard spec_codelist $200.;
                set _data_spec_attrib;
                    if index(spec_comments,'DATA STANDARDS CODELISTS /') then do;
                        spec_codelist_standard = 'DATA STANDARDS';
                        spec_codelist = strip(tranwrd(spec_comments,'DATA STANDARDS CODELISTS /',''));
                    end;
                    else if index(spec_comments,'GRADES CODELISTS /') then do;
                        spec_codelist_standard = 'GRADES';
                        spec_codelist = strip(tranwrd(spec_comments,'GRADES CODELISTS /',''));
                    end;
                    else if dataset = 'LAB_SAFE' and variable = 'PXCODE' then do;
                        spec_codelist_standard = 'OTHER';
                        spec_codelist = 'PXCODE';
                    end;

                    if not missing(data_variable) and not missing(spec_codelist);
                run;

                * Get macro var list;
                proc sql noprint;
                    select count(*) into :v_total
                    from _temp;
                quit;

                data _elisting;
                    delete;
                run;        

                %put NOTE:[PXL] Checking %left(%trim(&v_total)) Variables with codelists;        

                %if %eval(&v_total > 0) %then %do;
                    proc sql noprint;
                        select 
                            dataset,
                            variable,
                            data_type,
                            spec_codelist_standard,
                            spec_codelist
                            into :v_ds_1-:v_ds_%trim(%left(&v_total)),
                                 :v_vr_1-:v_vr_%trim(%left(&v_total)),
                                 :v_dt_1-:v_dt_%trim(%left(&v_total)),
                                 :v_scs_1-:v_scs_%trim(%left(&v_total)),
                                 :v_sc_1-:v_sc_%trim(%left(&v_total))
                        from _temp;
                    quit;               

                    %do i=1 %to &v_total;
                        %put NOTE:[PXL] #&i Checking &&v_ds_&i &&v_vr_&i &&v_dt_&i codelist &&v_scs_&i &&v_sc_&i values exist in codelist;

                        data _temp(keep=&&v_vr_&i);                
                        set &pfescrf_csdw_validator_scrf..&&v_ds_&i;
                            format _all_;
                            if not missing(&&v_vr_&i);
                        run;

                        * Only checks each unique variable value once;
                        proc sort data = _temp nodupkey; by &&v_vr_&i; run;

                        %if &&v_dt_&i = num %then %do;
                            proc sql noprint;
                                create table _3_01_c as
                                select distinct
                                    "&&v_ds_&i" as dataset length=200, 
                                    "&&v_vr_&i" as variable length=200, 
                                    left(trim(put(a.&&v_vr_&i, best.))) as data_value length=200,
                                    left(trim(put(b.seq_number, best.))) as codelist_value length=200
                                from 
                                    _temp as a 
                                    left join
                                    codelists as b 
                                on "&&v_scs_&i" = b.standard 
                                   and "&&v_sc_&i" = b.codelist_name 
                                   and a.&&v_vr_&i = b.seq_number;
                            quit;              
                        %end;
                        %else %do;
                            proc sql noprint;
                                create table _3_01_c as
                                select distinct
                                    "&&v_ds_&i" as dataset length=200, 
                                    "&&v_vr_&i" as variable length=200, 
                                    a.&&v_vr_&i as data_value length=200,
                                    b.long_label as codelist_value length=200
                                from 
                                    _temp as a 
                                    left join
                                    codelists as b 
                                on "&&v_scs_&i" = b.standard 
                                   and "&&v_sc_&i" = b.codelist_name 
                                   and (a.&&v_vr_&i = b.short_label or a.&&v_vr_&i = b.long_label);
                            quit;   
                        %end;

                        data _elisting;
                            length checkid type data_key $200;
                        set _elisting _3_01_c;
                            checkid = 'CK 3.01';
                            type = "%str(ERR)OR";
                            data_key = 'N/A';
                            if not missing(dataset)
                               and (missing(codelist_value) or codelist_value = ".") then 
                               output;
                        run;
                    %end; * End DO loop;                 
                %end; * End If statement;

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run; 

            * Check 3.02 Value non-conformant per date format DDMMMYYYY;
                %put NOTE:[PXL] Start Check 3.02 Value non-conformant per date format DDMMMYYYY;

                * Get codelist info and matches of variables that have a codelist;
                data _temp;
                set _data_spec_attrib;
                    if not missing(data_variable) 
                       and data_type = "char"
                       and spec_comments = "DDMMMYYYY";
                run;        

                * Get macro var list;
                proc sql noprint;
                    select count(*) into :v_total
                    from _temp;
                quit; 

                %if &v_total > 0 %then %do;
                    proc sql noprint;
                        select 
                            dataset,
                            variable
                            into :v_ds_1-:v_ds_%trim(%left(&v_total)),
                                 :v_vr_1-:v_vr_%trim(%left(&v_total))
                        from _temp;
                    quit;       
                %end;               

                %*put Checking %left(%trim(&v_total)) Variables with char values expected in DDMMMYYYY format;

                %do i=1 %to &v_total;
                    %*put #&i Checking &&v_ds_&i &&v_vr_&i char values are in DDMMMYYYY format;

                    data _elisting(keep=checkid type dataset variable data_value data_key);                
                        length checkid type dataset variable data_value data_key $200.;
                    set &pfescrf_csdw_validator_scrf..&&v_ds_&i;
                        format _all_;

                        checkid = "CK 3.02";
                        type = "%str(WARN)ING";
                        dataset = "&&v_ds_&i";
                        variable = "&&v_vr_&i";
                        data_value = &&v_vr_&i;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=PID) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=ACTEVENT) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=REPEATSN) %then %do;
                            data_key = catx("-",PID,ACTEVENT,REPEATSN);
                        %end;
                        %else %do;
                            data_key = '';
                        %end;      

                        * put "Checking value: " &&v_vr_&i;

                        * Allowable values: NULL, DDMMMYYY, UNMMMYYYY, DDUNKYYYY, UNUNKYYYY;
                        if missing(&&v_vr_&i) then delete;
                        else if length(&&v_vr_&i) = 9 then do; 
                            if not missing(input(&&v_vr_&i,?? DATE9.)) then delete;
                            else if substr(&&v_vr_&i,1,2) = "UN" 
                                and not missing(input("01"||substr(&&v_vr_&i,3,7),?? DATE9.)) then delete;
                            else if substr(&&v_vr_&i,3,3) = "UNK" 
                                and not missing(input(substr(&&v_vr_&i,1,2)||"JAN"||substr(&&v_vr_&i,6,4),?? DATE9.)) then delete;
                            else if substr(&&v_vr_&i,1,2) = "UN" 
                                and substr(&&v_vr_&i,3,3) = "UNK" 
                                and not missing(input("01JAN"||substr(&&v_vr_&i,6,4),?? DATE9.)) then delete;
                            else 
                                output;
                        end;
                        else
                            output;
                    run;     

                    data elisting_tab3;
                    set elisting_tab3 _elisting;
                    run; 
                %end;  

            * Check 3.03 Value non-conformant per date format DD-MMM-YYYY;
                %put NOTE:[PXL] Start Check 3.03 Value non-conformant per date format DD-MMM-YYYY;

                * Get codelist info and matches of variables that have a codelist;
                data _temp;
                set _data_spec_attrib;
                    if not missing(data_variable) 
                       and data_type = "char"
                       and spec_comments = "DD-MMM-YYYY";
                run;        

                * Get macro var list;
                proc sql noprint;
                    select count(*) into :v_total
                    from _temp;
                quit;

                %if &v_total > 0 %then %do;
                    proc sql noprint;
                        select 
                            dataset,
                            variable
                            into :v_ds_1-:v_ds_%trim(%left(&v_total)),
                                 :v_vr_1-:v_vr_%trim(%left(&v_total))
                        from _temp;
                    quit;       
                %end;

                %*put Checking %left(%trim(&v_total)) Variables with char values expected in DD-MMM-YYYY format;

                %do i=1 %to &v_total;
                    %put NOTE:[PXL] #&i Checking &&v_ds_&i &&v_vr_&i char values are in DD-MMM-YYYY format;

                    data _elisting(keep=checkid type dataset variable data_value data_key);                
                        length checkid type dataset variable data_value data_key $200.;
                    set &pfescrf_csdw_validator_scrf..&&v_ds_&i;
                        format _all_;

                        checkid = "CK 3.03";
                        type = "%str(WARN)ING";
                        dataset = "&&v_ds_&i";
                        variable = "&&v_vr_&i";
                        data_value = &&v_vr_&i;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=PID) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=ACTEVENT) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=REPEATSN) %then %do;
                            data_key = catx("-",PID,ACTEVENT,REPEATSN);
                        %end;
                        %else %do;
                            data_key = '';
                        %end;                

                        * Allowable values: NULL, DD-MMM-YYYY, UN-MMM-YYYY, DD-UNK-YYYY, UN-UNK-YYYY;
                        if missing(&&v_vr_&i) then delete;
                        else if length(&&v_vr_&i) = 11 then do;
                            if not missing(input(&&v_vr_&i,?? DATE11.)) then delete;
                            else if substr(&&v_vr_&i,1,2) = "UN" 
                                and not missing(input("01"||substr(&&v_vr_&i,3,9),?? DATE11.)) then delete;
                            else if length(&&v_vr_&i) = 11 and substr(&&v_vr_&i,4,3) = "UNK" 
                                and not missing(input(substr(&&v_vr_&i,1,2)||"-JAN-"||substr(&&v_vr_&i,8,4),?? DATE11.)) then delete;
                            else if length(&&v_vr_&i) = 11 and substr(&&v_vr_&i,1,2) = "UN" 
                                and substr(&&v_vr_&i,4,3) = "UNK" 
                                and not missing(input("01-JAN-"||substr(&&v_vr_&i,8,4),?? DATE11.)) then delete;
                            else 
                                output;
                        end;
                        else output;
                    run;     

                    data elisting_tab3;
                    set elisting_tab3 _elisting;
                    run;
                %end;   

            * Check 3.04 Value non-conformant per date format YYYY-MM-DD;
                %put NOTE:[PXL] Start Check 3.04 Value non-conformant per date format YYYY-MM-DD;

                * Get codelist info and matches of variables that have a codelist;
                data _temp;
                set _data_spec_attrib;
                    if not missing(data_variable) 
                       and data_type = "char"
                       and spec_comments = "YYYY-MM-DD";
                run;        

                * Get macro var list;
                proc sql noprint;
                    select count(*) into :v_total
                    from _temp;
                quit;

                %if &v_total > 0 %then %do;
                    proc sql noprint;
                        select 
                            dataset,
                            variable
                            into :v_ds_1-:v_ds_%trim(%left(&v_total)),
                                 :v_vr_1-:v_vr_%trim(%left(&v_total))
                        from _temp;
                    quit;       
                %end;

                %*put Checking %left(%trim(&v_total)) Variables with char values expected in YYYY-MM-DD format;

                %do i=1 %to &v_total;
                    %put NOTE:[PXL] #&i Checking &&v_ds_&i &&v_vr_&i char values are in YYYY-MM-DD format;

                    data _elisting(keep=checkid type dataset variable data_value data_key);                
                        length checkid type dataset variable data_value data_key $200.;
                    set &pfescrf_csdw_validator_scrf..&&v_ds_&i;
                        format _all_;

                        checkid = "CK 3.04";
                        type = "%str(WARN)ING";
                        dataset = "&&v_ds_&i";
                        variable = "&&v_vr_&i";
                        data_value = &&v_vr_&i;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=PID) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=ACTEVENT) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=REPEATSN) %then %do;
                            data_key = catx("-",PID,ACTEVENT,REPEATSN);
                        %end;
                        %else %do;
                            data_key = '';
                        %end;                

                        * Allowable values: NULL, YYYY-MM-DD, YYYY-MM-UN, YYYY-UN-UN, YYYY-UN-DD, 
                          YYYY-XX-XX, YYYY-XX-DD, YYYY-MM-XX;
                        if missing(&&v_vr_&i) then delete;
                        else if length(&&v_vr_&i) = 10 then do;
                            if not missing(input(&&v_vr_&i,?? yymmdd10.)) then delete;
                            else if substr(&&v_vr_&i,9,2) = "UN" 
                                and not missing(input(substr(&&v_vr_&i,1,8)||"01",?? yymmdd10.)) then delete;
                            else if substr(&&v_vr_&i,6,2) = "UN" 
                                and not missing(input(substr(&&v_vr_&i,1,5)||"01"||substr(&&v_vr_&i,8,3),?? yymmdd10.)) then delete;
                            else if substr(&&v_vr_&i,6,2) = "UN" 
                                and substr(&&v_vr_&i,9,3) = "UN" 
                                and not missing(input(substr(&&v_vr_&i,1,5)||"01-01",?? yymmdd10.)) then delete;
                            else if substr(&&v_vr_&i,9,2) = "XX" 
                                and not missing(input(substr(&&v_vr_&i,1,8)||"01",?? yymmdd10.)) then delete;
                            else if substr(&&v_vr_&i,6,2) = "XX" 
                                and not missing(input(substr(&&v_vr_&i,1,5)||"01"||substr(&&v_vr_&i,8,3),?? yymmdd10.)) then delete;
                            else if substr(&&v_vr_&i,6,2) = "XX" 
                                and substr(&&v_vr_&i,9,3) = "XX" 
                                and not missing(input(substr(&&v_vr_&i,1,5)||"01-01",?? yymmdd10.)) then delete;
                            else
                                output;
                        end;
                        else output;
                    run;     

                    data elisting_tab3;
                    set elisting_tab3 _elisting;
                    run;
                %end;   

            * Check 3.05 Value non-conformant per time format HH:MM;
                %put NOTE:[PXL] Start Check 3.05 Value non-conformant per time format HH:MM;

                * Get codelist info and matches of variables that have a codelist;
                data _temp;
                set _data_spec_attrib;
                    if not missing(data_variable) 
                       and data_type = "char"
                       and spec_comments = "HH:MM";
                run;        

                * Get macro var list;
                proc sql noprint;
                    select count(*) into :v_total
                    from _temp;
                quit;

                %if &v_total > 0 %then %do;
                    proc sql noprint;
                        select 
                            dataset,
                            variable
                            into :v_ds_1-:v_ds_%trim(%left(&v_total)),
                                 :v_vr_1-:v_vr_%trim(%left(&v_total))
                        from _temp;
                    quit;       
                %end;

                %*put Checking %left(%trim(&v_total)) Variables with char values expected in HH:MM format;

                %do i=1 %to &v_total;
                    %*put #&i Checking &&v_ds_&i &&v_vr_&i char values are in HH:MM format;

                    data _elisting(keep=checkid type dataset variable data_value data_key);                
                        length checkid type dataset variable data_value data_key $200.;
                    set &pfescrf_csdw_validator_scrf..&&v_ds_&i;
                        format _all_;

                        checkid = "CK 3.05";
                        type = "%str(WARN)ING";
                        dataset = "&&v_ds_&i";
                        variable = "&&v_vr_&i";
                        data_value = &&v_vr_&i;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=PID) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=ACTEVENT) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=REPEATSN) %then %do;
                            data_key = catx("-",PID,ACTEVENT,REPEATSN);
                        %end;
                        %else %do;
                            data_key = '';
                        %end;                

                        * Allowable values: NULL, HH:MM;
                        if missing(&&v_vr_&i) then delete;
                        else if length(&&v_vr_&i) = 5 then do;
                            if input(substr(&&v_vr_&i,1,2),?? 8.) > 24 then output;
                            else if input(substr(&&v_vr_&i,4,2),?? 8.) >= 60 then output;
                            else if input(substr(&&v_vr_&i,1,2),?? 8.) = 24 
                                 and input(substr(&&v_vr_&i,4,2),?? 8.) >= 1 then output;
                            else if not missing(input(&&v_vr_&i,?? time5.)) then delete;
                            else output;
                        end;
                        else output;
                    run;     

                    data elisting_tab3;
                    set elisting_tab3 _elisting;
                    run;
                %end; 

            * Check 3.06 Value non-conformant per time format HH:MM:SS;
                %put NOTE:[PXL] Start Check 3.06 Value non-conformant per time format HH:MM:SS;

                * Get codelist info and matches of variables that have a codelist;
                data _temp;
                set _data_spec_attrib;
                    if not missing(data_variable) 
                       and data_type = "char"
                       and spec_comments = "HH:MM:SS";
                run;        

                * Get macro var list;
                proc sql noprint;
                    select count(*) into :v_total
                    from _temp;
                quit;

                %if &v_total > 0 %then %do;
                    proc sql noprint;
                        select 
                            dataset,
                            variable
                            into :v_ds_1-:v_ds_%trim(%left(&v_total)),
                                 :v_vr_1-:v_vr_%trim(%left(&v_total))
                        from _temp;
                    quit;       
                %end;

                %*put Checking %left(%trim(&v_total)) Variables with char values expected in HH:MM:SS format;  

                %do i=1 %to &v_total;
                    %*put #&i Checking &&v_ds_&i &&v_vr_&i char values are in HH:MM:SS format;

                    data _elisting(keep=checkid type dataset variable data_value data_key);                
                        length checkid type dataset variable data_value data_key $200.;
                    set &pfescrf_csdw_validator_scrf..&&v_ds_&i;
                        format _all_;

                        checkid = "CK 3.06";
                        type = "%str(WARN)ING";
                        dataset = "&&v_ds_&i";
                        variable = "&&v_vr_&i";
                        data_value = &&v_vr_&i;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=PID) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=ACTEVENT) 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&v_ds_&i, varname=REPEATSN) %then %do;
                            data_key = catx("-",PID,ACTEVENT,REPEATSN);
                        %end;
                        %else %do;
                            data_key = '';
                        %end;                

                        * Allowable values: NULL, HH:MM:SS;
                        if missing(&&v_vr_&i) then delete;
                        else if length(&&v_vr_&i) = 8 then do;
                            if input(substr(&&v_vr_&i,1,2),?? 8.) > 24 then output;
                            else if input(substr(&&v_vr_&i,4,2),?? 8.) >= 60 then output;
                            else if input(substr(&&v_vr_&i,1,2),?? 8.) = 24 
                                 and (input(substr(&&v_vr_&i,4,2),?? 8.) >= 1
                                    or input(substr(&&v_vr_&i,7,2),?? 8.) >= 1) then output;
                            else if not missing(input(&&v_vr_&i,?? time8.)) then delete;
                            else output;
                        end;
                        else output;                        
                    run;     

                    data elisting_tab3;
                    set elisting_tab3 _elisting;
                    run;

                %end;         

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Validation Checks 4.01-4.04;
        %put NOTE:[PXL] ***********************************************************************;

            * Get macro var of all SCRF datasets;
            proc sql noprint;
                select count(*) into :ds_total
                from (
                    select distinct data_dataset 
                    from _data_spec_attrib
                    where data_dataset is not null);
            quit;

            %if %eval(&ds_total > 0) %then %do;
                proc sql noprint;
                    select 
                        data_dataset
                        into :ds_1-:ds_%trim(%left(&ds_total))
                    from (
                        select distinct data_dataset 
                        from _data_spec_attrib
                        where data_dataset is not null);
                quit;
            %end;

            * Cycle through each SCRF dataset and run checks;
            %do i=1 %to &ds_total;
                %put NOTE:[PXL] Checking &&ds_&i;

                * Get variable list;
                proc sql noprint;
                    select count(*) into: varn_total
                    from _data_spec_attrib
                    where data_dataset = "&&ds_&i"
                          and data_variable is not null;

                    select 
                        data_variable
                        into :varn_1-:varn_%trim(%left(&varn_total))
                    from _data_spec_attrib
                    where data_dataset = "&&ds_&i"
                          and data_variable is not null;              
                quit;

                data _elisting(keep=checkid type dataset variable data_value data_key);
                    length checkid type dataset variable data_value data_key $200.;
                    format _all_;
                set &pfescrf_csdw_validator_scrf..&&ds_&i;

                    checkid = '';
                    type = '';
                    dataset = "&&ds_&i";
                    variable = '';
                    data_value = '';
                    data_key = '';  

                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&ds_&i, varname=PID) 
                        and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&ds_&i, varname=ACTEVENT) 
                        and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&ds_&i, varname=REPEATSN) %then %do;
                        if not missing(PID) and not missing(ACTEVENT) and not missing(REPEATSN) then
                            data_key = catx("-",PID,ACTEVENT,REPEATSN);
                    %end;

                    * Cycle through each variable name;
                        %if %eval(&varn_total > 0) %then %do;
                            %do j=1 %to &varn_total;
                                %*put Checking &&ds_&i &&varn_&j;

                                * Check 4.01 Non-printable ASCII characters found;
                                %if %mu_vartype(dsname=&pfescrf_csdw_validator_scrf..&&ds_&i, varname=&&varn_&j) = C %then %do;
                                    %*put Checking &&ds_&i &&varn_&j for special ascii charcaters;
                                    if &&varn_&j ne compress(&&varn_&j,,'wk') then do;
                                        checkid = 'CK 4.01';
                                        type = "%str(ERR)OR";
                                        variable = "&&varn_&j";
                                        data_value = &&varn_&j;
                                        output;
                                    end;                        
                                %end;
                            %end; * End cycle through each variable;
                        %end;

                    * Check 4.02 Part 1 - UAT data found (site or subject value contains UAT);
                        %macro _4_02(_4_02_varn=null);                    
                            %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&ds_&i, varname=&_4_02_varn) > 0 %then %do;
                                if index(&_4_02_varn,'TEST') > 0 
                                   or index(&_4_02_varn,'UAT') > 0 then do;
                                    checkid = 'CK 4.02';
                                    type = "%str(ERR)OR";
                                    variable = "&_4_02_varn";
                                    data_value = &_4_02_varn;
                                    output;                                
                                end;                    
                            %end;
                        %mend _4_02;
                        %_4_02(_4_02_varn=SITEID);    
                        %_4_02(_4_02_varn=SID);
                        %_4_02(_4_02_varn=PID);
                        %_4_02(_4_02_varn=SUBJID);
                        %_4_02(_4_02_varn=TRIALNO); 

                    * Check 4.03 PID value format is incorrect (Combined PROTNO, TRIALNO, and SUBJID with spaces in between);
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&ds_&i, varname=PID) > 0 %then %do;
                            if not missing(PID) then do;
                                if length(PID) ne 22 
                                    or substr(PID,1,8) ne PROTNO
                                    or substr(PID,10,4) ne SITEID
                                    or substr(PID,15,8) ne SUBJID
                                    or substr(PID,9,1) ne ' '
                                    or substr(PID,14,1) ne ' ' then do;

                                    checkid = 'CK 4.03';
                                    type = "%str(ERR)OR";
                                    variable = "PID";
                                    data_value = PID;
                                    output;
                                end;
                            end;
                        %end;       

                    * Check 4.04 CPEVENT length of data is longer than 20;                   
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&&ds_&i, varname=CPEVENT) > 0 %then %do;
                            if length(CPEVENT) > 20 then do;
                                checkid = 'CK 4.04';
                                type = "%str(ERR)OR";
                                variable = "CPEVENT";
                                data_value = CPEVENT;
                                output;
                            end;                    
                        %end;                  

                    delete;
                run;

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;
            %end;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Missing Required Value Report 5.001-5.018;
        %put NOTE:[PXL] ***********************************************************************;
            * Check 5.001-5.018 Required header/key variables;
                %put NOTE:[PXL] Starting 5.001-5.018 Required header/key variables;

                * Get macro var of all &pfescrf_csdw_validator_scrf datasets;
                proc sql noprint;
                    select count(*) into :ds_total
                    from (
                        select distinct data_dataset 
                        from _data_spec_attrib
                        where data_dataset is not null);
                quit;

                %if %eval(&ds_total > 0) %then %do;
                    proc sql noprint;
                        select 
                            data_dataset
                            into :ds_1-:ds_%trim(%left(&ds_total))
                        from (
                            select distinct data_dataset 
                            from _data_spec_attrib
                            where data_dataset is not null);
                    quit;
                %end;

                * Cycle through each &pfescrf_csdw_validator_scrf dataset and run checks;
                %do i=1 %to &ds_total;
                    data _elisting(keep= checkid dataset variable cnt_mis cnt_pre cnt_exp cnt_tot);
                        length dataset variable $200.;
                        retain m1-m18 cnt_tot 0;
                    set &pfescrf_csdw_validator_scrf..&&ds_&i end=eof;
                        cnt_tot = cnt_tot + 1;
                        cnt_exp = cnt_tot;

                        if missing(ACTEVENT) then m1 = m1 + 1;
                        if missing(CPEVENT)  then m2 = m2 + 2;
                        if missing(INV)      then m3 = m3 + 3;
                        if missing(LSTCHGTS) then m4 = m4 + 4;
                        if missing(PID)      then m5 = m5 + 5;
                        if missing(PROJCODE) then m6 = m6 + 6;
                        if missing(PROTNO)   then m7 = m7 + 7;
                        if missing(REPEATSN) then m8 = m8 + 8;
                        if missing(SID)      then m9 = m9 + 9;
                        if missing(SITEID)   then m10 = m10 + 10;
                        if missing(STUDY)    then m11 = m11 + 11;
                        if missing(STUDYID)  then m12 = m12 + 12;
                        if missing(SUBEVE)   then m13 = m13 + 13;
                        if missing(SUBJID)   then m14 = m14 + 14;
                        if missing(TRIALNO)  then m15 = m15 + 15;
                        if missing(VISIT)    then m16 = m16 + 16;
                        if missing(ACCESSTS) then m17 = m17 + 17;
                        if missing(COLLDATE) then m18 = m18 + 18;

                        if eof then do;
                            dataset = "&&ds_&i";

                            checkid='5.001'; variable = "ACTEVENT"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.002'; variable = "CPEVENT"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.003'; variable = "INV"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.004'; variable = "LSTCHGTS"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.005'; variable = "PID"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.006'; variable = "PROJCODE"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.007'; variable = "PROTNO"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.008'; variable = "REPEATSN"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.009'; variable = "SID"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.010'; variable = "SITEID"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.011'; variable = "STUDY"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.012'; variable = "STUDYID"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.013'; variable = "SUBEVE"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.014'; variable = "SUBJID"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.015'; variable = "TRIALNO"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.016'; variable = "VISIT"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.017'; variable = "ACCESSTS"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;
                            checkid='5.018'; variable = "COLLDATE"; cnt_mis = m1; cnt_pre = cnt_exp-cnt_mis; output;                                                    
                        end;
                    run;

                    data _elisting;
                    set _elisting;
                        if cnt_mis ne 0;
                    run;

                    data elisting_tab4;
                    set elisting_tab4 _elisting;
                    run;
                %end;   

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Missing Required Value Report 5.019-5.096;
        %put NOTE:[PXL] ***********************************************************************;

            * Internal use macro;
            %macro _ck_none(_dsn=null, _vrn=null, _novrn1=null, _novrn1_value=null, _novrn2=null, _novrn2_value=null);
                %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_vrn) > 0 %then %do;
                    %put NOTE:[PXL] Checking &_dsn..&_vrn;

                    data _elisting(keep=dataset variable cnt_mis cnt_pre cnt_exp cnt_tot);
                        length dataset variable $200.;
                        retain cnt_mis cnt_exp cnt_tot 0;
                    set SCRF.&_dsn end=eof;
                        format _all_;
                        dataset = "&_dsn";
                        variable = "&_vrn";
                        cnt_tot = cnt_tot + 1;

                        * Exception var 1 only exists;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn1) > 0 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn2) = 0 %then %do;
                            if &_novrn1 ne &_novrn1_value then do;
                                if missing(&_vrn) then do;
                                    cnt_mis = cnt_mis + 1;
                                    cnt_exp = cnt_exp + 1;
                                end;
                                else do;
                                    cnt_exp = cnt_exp + 1;
                                end;
                            end;
                        %end;

                        * Exception var 2 only exists;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn1) = 0 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn2) > 0 %then %do;
                            if &_novrn2 ne &_novrn2_value then do;
                                if missing(&_vrn) then do;
                                    cnt_mis = cnt_mis + 1;
                                    cnt_exp = cnt_exp + 1;
                                end;
                                else do;
                                    cnt_exp = cnt_exp + 1;
                                end;
                            end;
                        %end;

                        * Exception var 1 and 2 exist;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn1) > 0 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn2) > 0 %then %do;
                            if &_novrn1 ne &_novrn1_value 
                               and &_novrn2 ne &_novrn2_value then do;
                                if missing(&_vrn) then do;
                                    cnt_mis = cnt_mis + 1;
                                    cnt_exp = cnt_exp + 1;
                                end;
                                else do;
                                    cnt_exp = cnt_exp + 1;
                                end;
                            end;
                        %end;

                        * Neither exception var exists;
                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn1) = 0 
                            and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..&_dsn, varname=&_novrn2) = 0 %then %do; 
                            if missing(&_vrn) then do;
                                cnt_mis = cnt_mis + 1;
                                cnt_exp = cnt_exp + 1;
                            end;
                            else do;
                                cnt_exp = cnt_exp + 1;
                            end;                   
                        %end;
                        
                        if eof then do;
                            cnt_pre = cnt_exp - cnt_mis;
                            output;
                        end;
                        delete;
                    run; 

                    data elisting_tab4;
                    set elisting_tab4 _elisting;
                    run;
                %end;  
                %else %do; 
                    %put NOTE:[PXL] &pfescrf_csdw_validator_scrf..&_dsn..&_vrn does not exist, not checked;
                %end;      
            %mend _ck_none;

            * Special checks;
                * ADVERSE AESEV or AEGRAE required;
                %macro _ck_adverse_aesev_or_aegrade;
                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..ADVERSE, varname=AESEV) > 0 
                        and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..ADVERSE, varname=AEGRADE) = 0 %then %do;
                        %_ck_none(_dsn=ADVERSE, _vrn=AESEV, _novrn1=AENONE, _novrn1_value=1);
                    %end;
                
                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..ADVERSE, varname=AESEV) = 0 
                        and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..ADVERSE, varname=AEGRADE) > 0 %then %do;
                        %_ck_none(_dsn=ADVERSE, _vrn=AEGRADE, _novrn1=AENONE, _novrn1_value=1);
                    %end;

                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..ADVERSE, varname=AESEV) > 0 
                        and %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..ADVERSE, varname=AEGRADE) > 0 %then %do;

                        %put NOTE:[PXL] Checking ADVERSE AESEV and AEGRADE;

                        data _elisting(keep=dataset variable cnt_mis cnt_pre cnt_exp cnt_tot);
                            length dataset variable $200.;
                            retain cnt_mis cnt_exp cnt_tot 0;
                        set &pfescrf_csdw_validator_scrf..adverse end=eof;
                            format _all_;
                            dataset = "ADVERSE";
                            variable = "AESEV";
                            cnt_tot = cnt_tot + 1;

                            %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AENONE) > 0 %then %do;
                                if AENONE ne 1 then do;
                                    if missing(AESEV) and missing(AEGRADE) then do;
                                        cnt_mis = cnt_mis + 1;
                                        cnt_exp = cnt_exp + 1;
                                    end;
                                    else do;
                                        cnt_exp = cnt_exp + 1;
                                    end;
                                end;
                            %end;
                            %else %do;
                                if missing(AESEV) and missing(AEGRADE) then do;
                                    cnt_mis = cnt_mis + 1;
                                    cnt_exp = cnt_exp + 1;
                                end;
                                else do;
                                    cnt_exp = cnt_exp + 1;
                                end;              
                            %end;
                            
                            if eof then do;
                                cnt_pre = cnt_exp - cnt_mis;
                                output;
                            end;
                            delete;
                        run; 

                        data elisting_tab4;
                        set elisting_tab4 _elisting;
                        run;
                    %end;
                %mend _ck_adverse_aesev_or_aegrade;

                * ADVERSE required values unless AENONE=1 'NONE': AESTDRG, AEST1NM, AEST1TR, 
                  AEST2NM, AEST2TR, AEST3NM or AEST3TR has to have a value;
                %macro _ck_adverse_aestdrg;
                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..ADVERSE, varname=AESTDRG) > 0 %then %do;

                        %put NOTE:[PXL] Checking ADVERSE AESTDRG;

                        data _elisting(keep=dataset variable cnt_mis cnt_pre cnt_exp cnt_tot);
                            length dataset variable $200.;
                            retain cnt_mis cnt_exp cnt_tot 0;
                        set &pfescrf_csdw_validator_scrf..adverse end=eof;
                            format _all_;
                            dataset = "ADVERSE";
                            variable = "AESTDRG";
                            cnt_tot = cnt_tot + 1;

                            %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AENONE) > 0 %then %do;
                                if AENONE ne 1 then do;
                                    if missing(AESTDRG) 
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST1NM) > 0 %then %do; and missing(AEST1NM) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST1TR) > 0 %then %do; and missing(AEST1TR) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST2NM) > 0 %then %do; and missing(AEST2NM) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST2TR) > 0 %then %do; and missing(AEST2TR) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST3NM) > 0 %then %do; and missing(AEST3NM) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST3TR) > 0 %then %do; and missing(AEST3TR) %end;
                                        then do;
                                        cnt_mis = cnt_mis + 1;
                                        cnt_exp = cnt_exp + 1;
                                    end;
                                    else do;
                                        cnt_exp = cnt_exp + 1;
                                    end;
                                end;
                            %end;
                            %else %do;
                                if missing(AESTDRG) 
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST1NM) > 0 %then %do; and missing(AEST1NM) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST1TR) > 0 %then %do; and missing(AEST1TR) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST2NM) > 0 %then %do; and missing(AEST2NM) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST2TR) > 0 %then %do; and missing(AEST2TR) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST3NM) > 0 %then %do; and missing(AEST3NM) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..adverse, varname=AEST3TR) > 0 %then %do; and missing(AEST3TR) %end;
                                    then do;
                                    cnt_mis = cnt_mis + 1;
                                    cnt_exp = cnt_exp + 1;
                                end;
                                else do;
                                    cnt_exp = cnt_exp + 1;
                                end;              
                            %end;
                            
                            if eof then do;
                                cnt_pre = cnt_exp - cnt_mis;
                                output;
                            end;
                            delete;
                        run; 

                        data elisting_tab4;
                        set elisting_tab4 _elisting;
                        run;    
                    %end;
                %mend _ck_adverse_aestdrg;

                * DEMOG domain version > 2 requires ETHNIC have values;
                %macro _ck_demog_ethnic;
                    %let demog_ds_label =;
                    proc sql noprint;
                        select memlabel into: demog_ds_label
                        from sashelp.vtable
                        where libname = "%upcase(&pfescrf_csdw_validator_scrf)"
                              and memname = "DEMOG";
                    quit;
                    %if %eval(&demog_ds_label > 2) %then %do;
                        %_ck_none(_dsn=DEMOG, _vrn=ETHNIC);
                        %_ck_none(_dsn=DEMOG, _vrn=ETHNICC);
                    %end;
                %mend _ck_demog_ethnic;

                * PRIMDIAG - One Diagnosis Date is required value unless PRMNONE=1 'NONE': 
                  (PRIMDATE, PRIMDATF, DIAGDT PRIMHDT PRMEPDT ONCCUDT ONCLODT ONCMEDT ONCREDT PRIMPDT);
                %macro _ck_primdiag_primdate;
                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRIMDATE) > 0 %then %do;

                        %put NOTE:[PXL] Checking PRIMDIAG PRIMDATE;

                        data _elisting(keep=dataset variable cnt_mis cnt_pre cnt_exp cnt_tot);
                            length dataset variable $200.;
                            retain cnt_mis cnt_exp cnt_tot 0;
                        set &pfescrf_csdw_validator_scrf..PRIMDIAG end=eof;
                            format _all_;
                            dataset = "PRIMDIAG";
                            variable = "PRIMDATE";
                            cnt_tot = cnt_tot + 1;

                            %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRMNONE) > 0 %then %do;
                                if PRMNONE ne 1 then do;
                                    if missing(PRIMDATE) 
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRIMDATF) > 0 %then %do; and missing(PRIMDATF) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=DIAGDT) > 0 %then %do; and missing(DIAGDT) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRIMHDT) > 0 %then %do; and missing(PRIMHDT) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRMEPDT) > 0 %then %do; and missing(PRMEPDT) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCCUDT) > 0 %then %do; and missing(ONCCUDT) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCLODT) > 0 %then %do; and missing(ONCLODT) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCMEDT) > 0 %then %do; and missing(ONCMEDT) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCREDT) > 0 %then %do; and missing(ONCREDT) %end;
                                        %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRIMPDT) > 0 %then %do; and missing(PRIMPDT) %end;
                                        then do;
                                        cnt_mis = cnt_mis + 1;
                                        cnt_exp = cnt_exp + 1;
                                    end;
                                    else do;
                                        cnt_exp = cnt_exp + 1;
                                    end;
                                end;
                            %end;
                            %else %do;
                                if missing(PRIMDATE) 
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRIMDATF) > 0 %then %do; and missing(PRIMDATF) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=DIAGDT) > 0 %then %do; and missing(DIAGDT) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRIMHDT) > 0 %then %do; and missing(PRIMHDT) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRMEPDT) > 0 %then %do; and missing(PRMEPDT) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCCUDT) > 0 %then %do; and missing(ONCCUDT) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCLODT) > 0 %then %do; and missing(ONCLODT) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCMEDT) > 0 %then %do; and missing(ONCMEDT) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=ONCREDT) > 0 %then %do; and missing(ONCREDT) %end;
                                    %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..PRIMDIAG, varname=PRIMPDT) > 0 %then %do; and missing(PRIMPDT) %end;
                                    then do;
                                    cnt_mis = cnt_mis + 1;
                                    cnt_exp = cnt_exp + 1;
                                end;
                                else do;
                                    cnt_exp = cnt_exp + 1;
                                end;              
                            %end;
                            
                            if eof then do;
                                cnt_pre = cnt_exp - cnt_mis;
                                output;
                            end;
                            delete;
                        run; 

                        data elisting_tab4;
                        set elisting_tab4 _elisting;
                        run;    
                    %end;
                %mend _ck_primdiag_primdate;

            * ADVERSE Checks;
                %_ck_none(_dsn=ADVERSE, _vrn=FROMDATE, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=TODATE, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=AEDECD1, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=AEDECD2, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=AEDECD3, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=AEDECD4, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=AEBDSYS, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=AESER, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ADVERSE, _vrn=AETERM, _novrn1=AENONE, _novrn1_value=1);
                %_ck_adverse_aesev_or_aegrade;
                %_ck_adverse_aestdrg;

            * CONDRUG Checks;
                %_ck_none(_dsn=CONDRUG, _vrn=CMCODE, _novrn1=NONE, _novrn1_value=1, _novrn2=NOTDONE, _novrn2_value="NOT DONE");
                %_ck_none(_dsn=CONDRUG, _vrn=CMTERM, _novrn1=NONE, _novrn1_value=1, _novrn2=NOTDONE, _novrn2_value="NOT DONE");
                %if %mu_varexist(dsname=&pfescrf_csdw_validator_scrf..CONDRUG, varname=CDRGPRIM) > 0 %then %do;
                    %_ck_none(_dsn=CONDRUG, _vrn=CDRGPRIM, _novrn1=NONE, _novrn1_value=1, _novrn2=NOTDONE, _novrn2_value="NOT DONE");
                %end;

            * CONTRT Checks;
                %_ck_none(_dsn=CONTRT, _vrn=CTDECD1, _novrn1=NONE, _novrn1_value=1);
                %_ck_none(_dsn=CONTRT, _vrn=CTDECD2, _novrn1=NONE, _novrn1_value=1);
                %_ck_none(_dsn=CONTRT, _vrn=CTDECD3, _novrn1=NONE, _novrn1_value=1);
                %_ck_none(_dsn=CONTRT, _vrn=CTDECD4, _novrn1=NONE, _novrn1_value=1);
                %_ck_none(_dsn=CONTRT, _vrn=CTBDSYS, _novrn1=NONE, _novrn1_value=1);
                %_ck_none(_dsn=CONTRT, _vrn=CTTERM, _novrn1=NONE, _novrn1_value=1);

            * DEMOG Checks;
                %_ck_none(_dsn=DEMOG, _vrn=DOB);
                %_ck_none(_dsn=DEMOG, _vrn=SEX);
                %_ck_demog_ethnic;

            * ECG Checks;
                %_ck_none(_dsn=ECG, _vrn=EGND);
                %_ck_none(_dsn=ECG, _vrn=EGTEST);

            * PRIMDIAG Checks;
                %_ck_none(_dsn=PRIMDIAG, _vrn=PSDECD1, _novrn1=PRMNONE, _novrn1_value=1);
                %_ck_none(_dsn=PRIMDIAG, _vrn=PSDECD2, _novrn1=PRMNONE, _novrn1_value=1);
                %_ck_none(_dsn=PRIMDIAG, _vrn=PSDECD3, _novrn1=PRMNONE, _novrn1_value=1);
                %_ck_none(_dsn=PRIMDIAG, _vrn=PSDECD4, _novrn1=PRMNONE, _novrn1_value=1);
                %_ck_none(_dsn=PRIMDIAG, _vrn=PSBDSYS, _novrn1=PRMNONE, _novrn1_value=1);
                %_ck_none(_dsn=PRIMDIAG, _vrn=PSTERM, _novrn1=PRMNONE, _novrn1_value=1);
                %_ck_primdiag_primdate;

            * PREVDIS Checks;
                %_ck_none(_dsn=PREVDIS, _vrn=MNOTDONE);
                %_ck_none(_dsn=PREVDIS, _vrn=DISSTAT1, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=NSHIST, _novrn2_value=1);
                %_ck_none(_dsn=PREVDIS, _vrn=MHDECD1, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=DISSTAT1, _novrn2_value=7);
                %_ck_none(_dsn=PREVDIS, _vrn=MHDECD2, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=DISSTAT1, _novrn2_value=7);
                %_ck_none(_dsn=PREVDIS, _vrn=MHDECD3, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=DISSTAT1, _novrn2_value=7);
                %_ck_none(_dsn=PREVDIS, _vrn=MHDECD4, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=DISSTAT1, _novrn2_value=7);
                %_ck_none(_dsn=PREVDIS, _vrn=MHBDSYS, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=DISSTAT1, _novrn2_value=7);
                %_ck_none(_dsn=PREVDIS, _vrn=MHTERM, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=DISSTAT1, _novrn2_value=7);
                %_ck_none(_dsn=PREVDIS, _vrn=NSHIST, _novrn1=MNOTDONE, _novrn1_value=1, _novrn2=DISSTAT1, _novrn2_value=7); 

            * FINAL Checks;
                %_ck_none(_dsn=FINAL, _vrn=FINSTAT);
                %_ck_none(_dsn=FINAL, _vrn=COLLDATF);

            * HE Checks ;
                %_ck_none(_dsn=HE, _vrn=AEDECD1, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=HE, _vrn=AEDECD2, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=HE, _vrn=AEDECD3, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=HE, _vrn=AEDECD4, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=HE, _vrn=AEBDSYS, _novrn1=AENONE, _novrn1_value=1);

            * LAB_SAFE Checks;
                %_ck_none(_dsn=LAB_SAFE, _vrn=LABCODE);
                %_ck_none(_dsn=LAB_SAFE, _vrn=TRIAL_ID);

            * ME Checks;
                %_ck_none(_dsn=ME, _vrn=AEDECD1, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ME, _vrn=AEDECD2, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ME, _vrn=AEDECD3, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ME, _vrn=AEDECD4, _novrn1=AENONE, _novrn1_value=1);
                %_ck_none(_dsn=ME, _vrn=AEBDSYS, _novrn1=AENONE, _novrn1_value=1);

            * PHYEXAM Checks;
                %_ck_none(_dsn=PHYEXAM, _vrn=RSLTCODE, _novrn1=NOTDONE, _novrn1_value=1);

            * RANDOM Checks;
                %_ck_none(_dsn=RANDOM, _vrn=COUNTRY);
                %_ck_none(_dsn=RANDOM, _vrn=PTRAND);
                %_ck_none(_dsn=RANDOM, _vrn=RANDNAME);
                %_ck_none(_dsn=RANDOM, _vrn=RANDPAT);

            * SCDG Checks;
                %_ck_none(_dsn=SCDG, _vrn=PSDECD1, _novrn1=SCDNONE, _novrn1_value=1);      
                %_ck_none(_dsn=SCDG, _vrn=PSDECD2, _novrn1=SCDNONE, _novrn1_value=1);
                %_ck_none(_dsn=SCDG, _vrn=PSDECD3, _novrn1=SCDNONE, _novrn1_value=1);
                %_ck_none(_dsn=SCDG, _vrn=PSDECD4, _novrn1=SCDNONE, _novrn1_value=1);
                %_ck_none(_dsn=SCDG, _vrn=PSBDSYS, _novrn1=SCDNONE, _novrn1_value=1);
                %_ck_none(_dsn=SCDG, _vrn=PSTERM, _novrn1=SCDNONE, _novrn1_value=1);

            * TESTDRUG Checks;
                %_ck_none(_dsn=TESTDRUG, _vrn=DRGCODE, _novrn1=NOTDONE, _novrn1_value=1);
                %_ck_none(_dsn=TESTDRUG, _vrn=DRGGROUP, _novrn1=NOTDONE, _novrn1_value=1);
                %_ck_none(_dsn=TESTDRUG, _vrn=DRGNAME, _novrn1=NOTDONE, _novrn1_value=1);
                %_ck_none(_dsn=TESTDRUG, _vrn=DOSE, _novrn1=NOTDONE, _novrn1_value=1);
                %_ck_none(_dsn=TESTDRUG, _vrn=DOSEUNI, _novrn1=NOTDONE, _novrn1_value=1);
                %_ck_none(_dsn=TESTDRUG, _vrn=DOSTOT, _novrn1=NOTDONE, _novrn1_value=1);
                %_ck_none(_dsn=TESTDRUG, _vrn=FROMDATE, _novrn1=NOTDONE, _novrn1_value=1);
                %_ck_none(_dsn=TESTDRUG, _vrn=TODATE, _novrn1=NOTDONE, _novrn1_value=1);
                
            * VITALS Checks;
                %_ck_none(_dsn=VITALS, _vrn=VSDTF, _novrn1=VSND, _novrn1_value="NOT DONE"); 
                %_ck_none(_dsn=VITALS, _vrn=VSPOS, _novrn1=VSND, _novrn1_value="NOT DONE");
                %_ck_none(_dsn=VITALS, _vrn=VSND);                               

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Validation Checks 4.06-4.07;
        %put NOTE:[PXL] ***********************************************************************;        
            * Check 4.06 - Missing Required Value Report shows more than 25% of values 
              missing where expected;
                %put NOTE:[PXL] Checking 4.06;
                data _elisting(keep=checkid type dataset variable pxl_notes data_value data_key);
                set elisting_tab4;
                    length pxl_Notes $200.;
                    checkid = 'CK 4.06';
                    type = "%str(WARN)ING";
                    pfail = 0;
                    if cnt_mis > 0 and cnt_exp > 0 then do;
                        pfail = round(cnt_mis / cnt_exp * 100, 0.01);
                    end;
                    data_value = 'N/A';
                    data_key = 'N/A';

                    if pfail > 25 then do;
                        pxl_Notes = "Missing per Expected at " || left(trim(put(pfail, 8.2))) || "%";
                        output;
                    end;
                    else do;
                        delete;
                    end;
                run;

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;

            * Check 4.07 - DOWNLOAD Dataset contains numeric variable with a format or 
              informat greater than SAS max length of 32;
                * Get macro var of all DOWNLOAD datasets;
                %put NOTE:[PXL] Checking 4.07;
                proc sql noprint;
                    create table _temp as 
                    select *
                    from sashelp.vcolumn 
                    where libname="%upcase(&pfescrf_csdw_validator_download)"
                          and type="num";
                quit;

                data _elisting(keep=checkid type dataset variable PXL_Notes);
                    length checkid type dataset variable PXL_Notes $200.;
                set _temp;
                    checkid = "CK 4.07";
                    type = "%str(ERR)OR";
                    dataset = memname;
                    variable = name;
                    PXL_Notes = catx(" ","%upcase(&pfescrf_csdw_validator_download) Dataset has format=",format," or informat=",informat,"greater than 32");

                    if  (not missing(input(format,??  best.)) and input(format,??  best.) > 32)
                        or 
                        (not missing(input(format,??  best.)) and input(format,??  best.) > 32) then do;

                        output;
                    end;
                run;

                data elisting_tab3;
                set elisting_tab3 _elisting;
                run;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Validation Review;
    %put NOTE:[PXL] ***********************************************************************;

        %put NOTE:[PXL] Merge metadata on to output;
        data _elisting_tab3; set elisting_tab3; run;
        proc sql noprint;
            create table elisting_tab3 as
            select a.checkid,
                   a.type,
                   a.dataset,
                   a.variable,
                   a.PXL_Notes,
                   coalescec(a.data_dataset, b.data_dataset) as data_dataset length=200,
                   coalescec(a.data_dataset_label, b.data_dataset_label) as data_dataset_label length=200,
                   a.data_key,
                   a.data_value,
                   b.data_variable,
                   b.data_type,
                   b.data_length,
                   b.data_format,
                   b.data_label length=200,
                   coalescec(a.spec_dataset,b.spec_dataset) as spec_dataset length=200,
                   b.spec_variable,
                   b.spec_core,
                   b.spec_type,
                   b.spec_length,
                   b.spec_label,
                   b.spec_format,
                   coalesce(a.spec_domain_version,b.spec_domain_version) as spec_domain_version length=200,
                   b.spec_comments,
                   b.spec_PXL_Notes
            from _elisting_tab3 as a
                 left join
                 _data_spec_attrib as b 
            on a.dataset = b.dataset 
               and a.variable = b.variable
            order by checkid, dataset, variable;                  
        quit;
        proc datasets lib=work nolist; delete _elisting_tab3; quit; run;

        data elisting_tab4;
            length type $200.;
        set elisting_tab4;
            if checkid in ("5.001","5.002","5.003","5.004","5.005","5.006","5.007","5.008","5.009","5.010","5.011","5.012","5.013","5.014","5.015","5.016","5.017","5.018") then 
                type = "%str(ERR)OR";
            else 
                type = "%str(WARN)ING";

            if cnt_mis = 0 or cnt_exp = 0 then delete; * Only want where values not present when expected;
        run;

        proc sql noprint;
            select count(*) into: _total_err1
            from elisting_tab3
            where type = "%str(ERR)OR";

            select count(*) into: _total_err2
            from elisting_tab4
            where type = "%str(ERR)OR";            

            select count(*) into: _total_warn1
            from elisting_tab3
            where type = "%str(WARN)ING";

            select count(*) into: _total_warn2
            from elisting_tab4
            where type = "%str(WARN)ING";
        quit;

        %let pfescrf_csdw_validator_NumErr = %left(%trim(%eval(&_total_err1 + &_total_err2)));
        %let pfescrf_csdw_validator_NumWarn = %left(%trim(%eval(&_total_warn1 + &_total_warn2)));

        %if %eval(&pfescrf_csdw_validator_NumErr = 0) %then %do;
            %let pfescrf_csdw_validator_PassFail = PASS;
        %end;

        * Warnings then Dirty Data;
        %if %eval(&pfescrf_csdw_validator_NumWarn = 0) %then %do;
            %let _cleandirty = CLEAN;
        %end;
        %else %do;
            %let _cleandirty = DIRTY;
        %end; 

        * Set listing name with pass/fail and clean/dirty data. Add path before macro completely for use in parent calling macros;
        %let pfescrf_csdw_validator_ListName = &pfescrf_csdw_validator_ListName OVERALL=&pfescrf_csdw_validator_PassFail with &_cleandirty Data.xls;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Listing Creation;
    %put NOTE:[PXL] ***********************************************************************;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Listing Creation - TAB1 Overview;
        %put NOTE:[PXL] ***********************************************************************;

            data _tab1;
                attrib
                    metadata length=$200 label="Metadata"
                    values   length=$200 label="Values"
                ;

                metadata = "Macro Info"; Values = ""; output;
                metadata = "Name:"; Values = "&pfescrf_csdw_validator_MacName"; output;
                metadata = "Version Number:"; Values = "&pfescrf_csdw_validator_MacVer"; output;
                metadata = "Version Date:"; Values = "&pfescrf_csdw_validator_MacVerDT"; output;
                metadata = "Macro Location:"; Values = "&pfescrf_csdw_validator_MacPath"; output;
                metadata = "Run By:"; Values = "%upcase(&sysuserid)"; output;
                metadata = "Date & Time Run:"; Values = "&pfescrf_csdw_validator_RunDTE"; output;
                
                metadata = ""; Values = ""; output;
                metadata = "Global Macro Variables"; Values = ""; output;
                metadata = "DEBUG:"; Values = "&DEBUG"; output;
                metadata = "GMPXLERR:"; Values = "&GMPXLERR"; output;

                metadata = ""; Values = ""; output;
                metadata = "Input Parameters"; Values = ""; output;
                metadata = "pfescrf_csdw_validator_metadata:"; Values = "&pfescrf_csdw_validator_metadata"; output;
                metadata = "pfescrf_csdw_validator_spec:"; Values = "%left(%trim(&pfescrf_csdw_validator_spec..sas7bat &spec_label))"; output;
                metadata = "pfescrf_csdw_validator_codelists:"; Values = "%left(%trim(&pfescrf_csdw_validator_codelists..sas7bdat &codelists_label))"; output;
                metadata = "pfescrf_csdw_validator_download:"; Values = "&pfescrf_csdw_validator_download"; output; 
                metadata = "pfescrf_csdw_validator_download PATH:"; Values = %str("&path_download"); output;
                metadata = "pfescrf_csdw_validator_download Symbolic Link current PATH (if used):"; Values = "&path_download_sl"; output;
                metadata = "pfescrf_csdw_validator_scrf:"; Values = "&pfescrf_csdw_validator_scrf"; output;
                metadata = "pfescrf_csdw_validator_scrf PATH:"; Values = "&path_scrf"; output;
                metadata = "pfescrf_csdw_validator_scrf Symbolic Link current PATH (if used):"; Values = "&path_scrf_sl"; output;
                metadata = "pfescrf_csdw_validator_protocol:"; Values = "&pfescrf_csdw_validator_protocol"; output;
                metadata = "pfescrf_csdw_validator_pxl_code:"; Values = "&pfescrf_csdw_validator_pxl_code"; output;
                metadata = "pfescrf_csdw_validator_AddDT:"; Values = "&pfescrf_csdw_validator_AddDT"; output;

                metadata = ""; Values = ""; output;
                metadata = "Output Listing"; Values = ""; output;
                metadata = "Output Path:"; Values = "&pfescrf_csdw_validator_pathlist"; output;
                metadata = "Output File Name:"; Values = "&pfescrf_csdw_validator_ListName"; output;

                metadata = ""; Values = ""; output;
                metadata = "Overall"; Values = ""; output;
                metadata = "Validation Checks %str(ERR)ORS: (PASS/FAIL)"; Values = "&pfescrf_csdw_validator_PassFail"; output;
                metadata = "Validation Checks %str(WARN)INGS: (ClEAN/DIRTY)"; Values = "&_cleandirty"; output;
                metadata = "Total Number of %str(ERR)ORS:"; Values = "%left(%trim(&pfescrf_csdw_validator_NumErr))"; output;
                metadata = "Total Number of %str(WARN)INGS:"; Values = "%left(%trim(&pfescrf_csdw_validator_NumWarn))"; output;
            run;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Listing Creation - TAB2 List of Checks Completed;
        %put NOTE:[PXL] ***********************************************************************;
            data _tab2;
                attrib
                    checkid         length=$200  label="Check ID"
                    type            length=$20   label="Severity"
                    check_desc      length=$1500 label="Check Description"
                    user_fix_action length=$1500 label="User Fix Action"
                ;

                checkid="Validation Checks";
                type="";
                check_desc="";
                user_fix_action="";
                output;                

                * 1 checks;
                    checkid="1.01";
                    type="%str(WARN)ING";
                    check_desc="Dataset exists that is not in spec";
                    user_fix_action="Contact Data Exchange Group to Submit UIMS or to remove dataset";
                    output;
                    checkid="";
                    type="";
                    check_desc="- Remove LAB_SAFE1";
                    user_fix_action="";
                    output;    

                    checkid="1.02";
                    type="%str(ERR)OR";
                    check_desc="Dataset label does not have a valid domain version specified";
                    user_fix_action="Update Dataset Domain to valid label per CSDW SCRF Spec";
                    output;
                    checkid="";
                    type="";
                    check_desc="- Remove LAB_SAFE1";
                    user_fix_action="";
                    output;                            
                    checkid="";
                    type="";
                    check_desc="- Dataset label must be number greater than 0 and less than 100";
                    user_fix_action="";
                    output; 

                    checkid="1.03";
                    type="%str(WARN)ING";
                    check_desc="Dataset label greater than spec domain version";
                    user_fix_action="Update Dataset Domain to valid label per CSDW SCRF Spec or submit UIMS if new CRF module version and variables do not exist in CSDW SCRF spec";
                    output;
                    checkid="";
                    type="";
                    check_desc="- Dataset label greater than max domain version found";
                    user_fix_action="";
                    output;  

                    checkid="1.04";
                    type="%str(ERR)OR";
                    check_desc="Libname &pfescrf_csdw_validator_download latest date of a file is after earliest libname &pfescrf_csdw_validator_scrf file date";
                    user_fix_action="SCRF created datasets must be created after raw datasets, re-create SCRF from raw data.";
                    output;  

                    checkid="1.05";
                    type="%str(ERR)OR";
                    check_desc="Global macro variable 'dataSensitivity' does not exist or is valid.";
                    user_fix_action=catx(" ",
                        "Macro variable 'dataSensitivity' should be created and set to global in the",
                        "/projects/pfizrNNNNNN/macros/project_setup.sas file.  The value will be:");
                    output;
                    checkid="";
                    type="";
                    check_desc="1) NOT_SENSTIVE_DATA - if the study is open label and to be treated as open label";
                    user_fix_action="";
                    output;             
                    checkid="";
                    type="";
                    check_desc="2) DUMMY/MASKED_DATA - if the study is blinded or open label and to be treated as blinded";
                    user_fix_action="";
                    output;  
                    checkid="";
                    type="";
                    check_desc="3) SENSITIVE_DATA - if the study is unblinded or unblinded data is present";
                    user_fix_action="";
                    output;

                    checkid="1.06";
                    type="%str(ERR)OR";
                    check_desc="Symbolic Link current within libname &pfescrf_csdw_validator_download points to DRAFT";
                    user_fix_action="The symbolic link current should point the latest dated folder and not test data within draft.";
                    output; 

                    checkid="1.07";
                    type="%str(ERR)OR";
                    check_desc="Symbolic Link current within libname &pfescrf_csdw_validator_scrf points to DRAFT";
                    user_fix_action="The symbolic link current should point the latest dated folder and not test data within draft.";
                    output;  

                    checkid="1.08";
                    type="%str(ERR)OR";
                    check_desc="SCRF Dataset DEMOG must exist";
                    user_fix_action="Check mapping and ensure DEMOG is present";
                    output;                                                                                                

                    checkid="1.09";
                    type="%str(ERR)OR";
                    check_desc="Libname %upcase(&pfescrf_csdw_validator_download) contains no datasets";
                    user_fix_action="Check mapping and ensure raw datasets are present";
                    output; 

                * 2 checks;
                    checkid="2.01";
                    type="%str(WARN)ING";
                    check_desc="Variable exists that is not in spec";
                    user_fix_action="If required, submit UIMS.";
                    output;
                    checkid="";
                    type="";
                    check_desc="- Remove datasets not in spec";
                    user_fix_action="";
                    output; 
                    checkid="";
                    type="";
                    check_desc="- Remove special header/key added variables";
                    user_fix_action="";
                    output;
                    checkid="";
                    type="";
                    check_desc="- Remove special variables added as needed for SACQ";
                    user_fix_action="";
                    output;

                    checkid="2.02";
                    type="%str(ERR)OR";
                    check_desc="Variable type does not match spec";
                    user_fix_action="Update variable type to match spec";
                    output;

                    checkid="2.03";
                    type="%str(ERR)OR";
                    check_desc="Variable length does not match spec";
                    user_fix_action="Update variable length to match spec or submit UIMS and get approval before modifying length from spec length";
                    output;

                    checkid="2.04";
                    type="%str(ERR)OR";
                    check_desc="Variable label does not match spec";
                    user_fix_action="Update variable label to match spec";
                    output;

                    checkid="2.05";
                    type="%str(ERR)OR";
                    check_desc="Variable is required but not found";
                    user_fix_action="Add veriable and derive value if possible, otherwise leave as NULL";
                    output;

                    checkid="2.06";
                    type="%str(ERR)OR";
                    check_desc="Variable format does not match spec";
                    user_fix_action=catx(" ","Update variable format to match spec. Note that format names as",
                        "codelists are acceptable to use (as most studies use them even though they do not",
                        "exist in the spec under format column).  Example is char format of $YESNO. or GRADES",
                        "standards codelist char format of $YESNOG. (when codelist same name exists for both",
                        "DATA STANDARDS and GRADES)or number format YESNO., etc but it must",
                        "match Pfizer expected codelist type and name");
                    output;
                    checkid="";
                    type="";
                    check_desc="- Remove where data format = codelist name";
                    user_fix_action="";
                    output;
                    checkid="";
                    type="";
                    check_desc="- Remove where data format = codelist name + G for GRADES CODELIST";
                    user_fix_action="";
                    output;                                

                * 3 checks;
                    checkid="3.01";
                    type="%str(ERR)OR";
                    check_desc="Value not present in codelist";
                    user_fix_action=catx(" ","Correct mapping to match Pfizer codelist. Pay special attention",
                        "to codelist standard (DATA STANDARD or GRADES or special if for PXCODE).  Values",
                        "must be in this codelist or submit and get approval of UIMS before mapping.");
                    output;

                    checkid="3.02";
                    type="%str(WARN)ING";
                    check_desc="Value non-conformant per date format DDMMMYYYY";
                    user_fix_action=catx(" ","Update char date value to match expected format. Unknowns as",
                        "UNUNKYYYY, year always required or leave blank.");
                    output;

                    checkid="3.03";
                    type="%str(WARN)ING";
                    check_desc="Value non-conformant per date format DD-MMM-YYYY";
                    user_fix_action=catx(" ","Update char date value to match expected format. Unknowns as",
                        "UN-UNK-YYYY, year always required or leave blank.");
                    output;

                    checkid="3.04";
                    type="%str(WARN)ING";
                    check_desc="Value non-conformant per date format YYYY-MM-DD";
                    user_fix_action=catx(" ","Update char date value to match expected format. Unknowns as",
                        "YYYY-UN-UN or YYYY-XX-XX, year always required or leave blank.");
                    output;

                    checkid="3.05";
                    type="%str(WARN)ING";
                    check_desc="Value non-conformant per time format HH:MM";
                    user_fix_action="Update char time value to match expected format";
                    output;

                    checkid="3.06";
                    type="%str(WARN)ING";
                    check_desc="Value non-conformant per time format HH:MM:SS";
                    user_fix_action="Update char time value to match expected format";
                    output;

                * 4 checks;
                    checkid="4.01";
                    type="%str(ERR)OR";
                    check_desc="Non-printable ASCII characters found";
                    user_fix_action=catx(" ","Pfizer uses encoding of WLATIN1 so no unprintable ASCII",
                        "characters are allowed. Use 'compress(<variable name>,,'wk') to remove",
                        "unprintable ASCII charcters. These will show up in the listing as only spaces.");
                    output;

                    checkid="4.02";
                    type="%str(ERR)OR";
                    check_desc="UAT data found (site or subject value contains UAT)";
                    user_fix_action=catx(" ","Ensure only production data exists for SCRF transfers unless",
                        "testing.  Delete and re-create UNIX symbolic links if you if required.");
                    output;

                    checkid="4.03";
                    type="%str(ERR)OR";
                    check_desc="PID value format is incorrect (Combined PROTNO, TRIALNO, and SUBJID with spaces in between)";
                    user_fix_action="Update PID derivation to match Pfizer requirement.";
                    output;
                    checkid="";
                    type="";
                    check_desc="- Example: PROTNO = 'A4061068', TRIALNO (or SITEID) = '1001',  SUBJID = '10011001' then PID = 'A4061068 1001 10011001'";
                    user_fix_action="";
                    output;

                    checkid="4.04";
                    type="%str(ERR)OR";
                    check_desc=catx(" ","CPEVENT length of data is longer than 20");
                    user_fix_action=catx(" ","Even though CSDW SCRF spec has length of 40, CDARS and SACQ only allow a max length of 20.",
                        "Update CPEVENT so that the length is 20 or less. ");
                    output; 

                    * check 4.05 removed in version 2;

                    checkid="4.06";
                    type="%str(WARN)ING";
                    check_desc=catx(" ","Missing Required Value Report shows more than 25% of values missing where expected");
                    user_fix_action=catx(" ","Ensure mapping is correct, otherwise notify PCDA to submit queries for",
                        "dirty data. Values are required were expected.");
                    output;

                    checkid="4.07";
                    type="%str(ERR)OR";
                    check_desc=catx(" ","DOWNLOAD Dataset contains numeric variable with a format or informat greater than SAS max length of 32");
                    user_fix_action=catx(" ","Proc SQL can create numeric variables with a format or informat greater than 32 but this will cause",
                        "failure issues during XPT compression and data step processes later. EDC Builder must correct in DataLabs build");
                    output;

                checkid="";
                type="";
                check_desc="";
                user_fix_action="";
                output;

                checkid="Missing Required Value Report Checks";
                type="";
                check_desc="";
                user_fix_action="";
                output;

                type="%str(ERR)OR";
                checkid="5.001"; check_desc="[ALL] required values: ACTEVENT"; user_fix_action="Required to always have a value."; output;
                checkid="5.002"; check_desc="[ALL] required values: CPEVENT"; user_fix_action="Required to always have a value. "; output;
                checkid="5.003"; check_desc="[ALL] required values: INV"; user_fix_action="Required to always have a value. "; output;
                checkid="5.004"; check_desc="[ALL] required values: LSTCHGTS"; user_fix_action="Required to always have a value. "; output;
                checkid="5.005"; check_desc="[ALL] required values: PID"; user_fix_action="Required to always have a value. "; output;
                checkid="5.006"; check_desc="[ALL] required values: PROJCODE"; user_fix_action="Required to always have a value. "; output;
                checkid="5.007"; check_desc="[ALL] required values: PROTNO"; user_fix_action="Required to always have a value. "; output;
                checkid="5.008"; check_desc="[ALL] required values: REPEATSN"; user_fix_action="Required to always have a value. "; output;
                checkid="5.009"; check_desc="[ALL] required values: SID"; user_fix_action="Required to always have a value. "; output;
                checkid="5.010"; check_desc="[ALL] required values: SITEID"; user_fix_action="Required to always have a value. "; output;
                checkid="5.011"; check_desc="[ALL] required values: STUDY"; user_fix_action="Required to always have a value. "; output;
                checkid="5.012"; check_desc="[ALL] required values: STUDYID"; user_fix_action="Required to always have a value. "; output;
                checkid="5.013"; check_desc="[ALL] required values: SUBEVE"; user_fix_action="Required to always have a value. "; output;
                checkid="5.014"; check_desc="[ALL] required values: SUBJID"; user_fix_action="Required to always have a value. "; output;
                checkid="5.015"; check_desc="[ALL] required values: TRIALNO"; user_fix_action="Required to always have a value. "; output;
                checkid="5.016"; check_desc="[ALL] required values: VISIT"; user_fix_action="Required to always have a value. "; output;
                checkid="5.017"; check_desc="[ALL] required values: ACCESSTS"; user_fix_action="Taken from raw FORM.rcvddt and merged in by SiteID, SCRNID, EvtFrmKy, and PatEvtKy."; output;
                checkid="5.018"; check_desc="[ALL] required values: COLLDATE"; user_fix_action="Get the value from a user entered field (such as ADVERSE.FROMDATE, etc) or get from ACCESSTS. "; output;

                type="%str(WARN)ING";
                checkid="5.019"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DRGCODE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.020"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DRGGROUP"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.021"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DRGNAME"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.022"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DOSE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.023"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DOSEUNI"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.024"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DOSTOT"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.025"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': FROMDATE"; 
                    user_fix_action=catx(" ","Ensure mapping is correct, otherwise notify PCDA to submit queries.",
                    "If TODATE does not exist, verify it can be set to FROMDATE (if on same day). It is required to have values."); output;
                checkid="5.026"; check_desc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': TODATE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.027"; check_desc="ADVERSE required values unless AENONE=1 'NONE': FROMDATE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.028"; check_desc="ADVERSE required values unless AENONE=1 'NONE': TODATE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.029"; check_desc="ADVERSE required values unless AENONE=1 'NONE': AEDECD1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.030"; check_desc="ADVERSE required values unless AENONE=1 'NONE': AEDECD2"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.031"; check_desc="ADVERSE required values unless AENONE=1 'NONE': AEDECD3"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.032"; check_desc="ADVERSE required values unless AENONE=1 'NONE': AEDECD4"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.033"; check_desc="ADVERSE required values unless AENONE=1 'NONE': AEBDSYS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.034"; check_desc="ADVERSE required values unless AENONE=1 'NONE': AESER"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.035"; check_desc="ADVERSE required values unless AENONE=1 'NONE': AETERM"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.036"; check_desc="ADVERSE required values unless AENONE=1 'NONE': either AESEV or AEGRADE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.037"; check_desc="ADVERSE required values unless AENONE=1 'NONE': one of: AESTDRG, AEST1NM, AEST1TR, AEST2NM, AEST2TR, AEST3NM or AEST3TR"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.038"; check_desc="DEMOG required values: DOB"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.039"; check_desc="DEMOG required values: SEX"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.040"; check_desc="DEMOG required values if domain version greater than 2: ETHNIC"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.041"; check_desc="DEMOG required values if domain version greater than 2: ETHNICC"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.042"; check_desc="ECG required values always: EGND"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.043"; check_desc="ECG required values always: EGTEST"; 
                    user_fix_action=catx(" ","Ensure mapping is correct, otherwise notify the PCDA to submit queries to users.",
                    "If study is collecting 'overall interpretation' only, then default EGTEST to 'OVERALL ASSESSMENT'"); output;
                checkid="5.044"; check_desc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.045"; check_desc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD2"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.046"; check_desc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD3"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.047"; check_desc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD4"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.048"; check_desc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSBDSYS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.049"; check_desc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSTERM"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.050"; check_desc=catx(" ","PRIMDIAG - One Diagnosis Date is required value unless PRMNONE=1 'NONE':",
                    "PRIMDATE, PRIMDATF, DIAGDT, PRIMHDT, PRMEPDT, ONCCUDT, ONCLODT, ONCMEDT, ONCREDT, or PRIMPDT"); 
                    user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries."; output;
                checkid="5.051"; check_desc="PREVDIS required values: MNOTDONE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.052"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOT DONE' or NSHIST= 1 'NONE': DISSTAT1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.053"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.054"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD2"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.055"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD3"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.056"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD4"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.057"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHBDSYS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.058"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHTERM"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.059"; check_desc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': NSHIST"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.060"; check_desc="CONDRUG required values unless NONE = 1 'NONE' or NOTDONE = 1 'NOT DONE': CMCODE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.061"; check_desc="CONDRUG required values unless NONE = 1 'NONE' or NOTDONE = 1 'NOT DONE': CMTERM"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.062"; check_desc="CONDRUG required values if present unless  NONE = 1 'NONE' or NOTDONE = 1 'NOT DONE': CDRGPRIM"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.063"; check_desc="CONTRT required values unless NONE = 1 'NONE': CTDECD1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.064"; check_desc="CONTRT required values unless NONE = 1 'NONE': CTDECD2"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.065"; check_desc="CONTRT required values unless NONE = 1 'NONE': CTDECD3"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.066"; check_desc="CONTRT required values unless NONE = 1 'NONE': CTDECD4"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.067"; check_desc="CONTRT required values unless NONE = 1 'NONE': CTBDSYS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.068"; check_desc="CONTRT required values unless NONE = 1 'NONE': CTTERM"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.069"; check_desc="FINAL required values: COLLDATF"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.070"; check_desc="FINAL required values: FINSTAT"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.071"; check_desc="HE required values unless AENONE= 1 'NONE': AEDECD1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.072"; check_desc="HE required values unless AENONE= 1 'NONE': AEDECD2"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.073"; check_desc="HE required values unless AENONE= 1 'NONE': AEDECD3"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.074"; check_desc="HE required values unless AENONE= 1 'NONE': AEDECD4"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.075"; check_desc="HE required values unless AENONE= 1 'NONE': AEBDSYS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.076"; check_desc="LAB_SAFE values required: LABCODE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.077"; check_desc="LAB_SAFE values required: TRIAL_ID"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.078"; check_desc="ME required values unless AENONE= 1 'NONE': AEDECD1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.079"; check_desc="ME required values unless AENONE= 1 'NONE': AEDECD2"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.080"; check_desc="ME required values unless AENONE= 1 'NONE': AEDECD3"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.081"; check_desc="ME required values unless AENONE= 1 'NONE': AEDECD4"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.082"; check_desc="ME required values unless AENONE= 1 'NONE': AEBDSYS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.083"; check_desc="PHYEXAM required values unless NOTDONE = 1 'NOT DONE': RSLTCODE"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.084"; check_desc="RANDOM required values: COUNTRY"; 
                    user_fix_action=catx(" ","Ensure mapping is correct, otherwise notify PCDA to submit queries.",
                    "RANDOM dataset should only be created if used for dummy randomization/","actual treatment information as needed per study requirements.","If needed, all required fields need data values always."); output;
                checkid="5.085"; check_desc="RANDOM required values: PTRAND"; 
                    user_fix_action=catx(" ","Ensure mapping is correct, otherwise notify PCDA to submit queries.",
                    "RANDOM dataset should only be created if used for dummy randomization/","actual treatment information as needed per study requirements.","If needed, all required fields need data values always."); output;
                checkid="5.086"; check_desc="RANDOM required values: RANDNAME"; 
                    user_fix_action=catx(" ","Ensure mapping is correct, otherwise notify PCDA to submit queries.",
                    "RANDOM dataset should only be created if used for dummy randomization/","actual treatment information as needed per study requirements.","If needed, all required fields need data values always."); output;
                checkid="5.087"; check_desc="RANDOM required values: RANDPAT"; 
                    user_fix_action=catx(" ","Ensure mapping is correct, otherwise notify PCDA to submit queries.",
                    "RANDOM dataset should only be created if used for dummy randomization/","actual treatment information as needed per study requirements.","If needed, all required fields need data values always."); output;
                checkid="5.088"; check_desc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD1"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.089"; check_desc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD2"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.090"; check_desc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD3"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.091"; check_desc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD4"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.092"; check_desc="SCDG required values unless SCDNONE = 1 'NONE': PSBDSYS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.093"; check_desc="SCDG required values unless SCDNONE = 1 'NONE': PSTERM"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.094"; check_desc="VITALS required values unless VSND=1 'NOT DONE': VSDTF"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.095"; check_desc="VITALS required values unless VSND=1 'NOT DONE': VSPOS"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
                checkid="5.096"; check_desc="VITALS required values: VSND"; user_fix_action="Ensure mapping is correct, otherwise notify PCDA to submit queries.  "; output;
            run;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Listing Creation - TAB3 Validation Check Issues;
        %put NOTE:[PXL] ***********************************************************************;
            * Limit output to 50 per checkid, dataset, and variable;
            proc sort data = elisting_tab3; by checkid dataset variable; run;
            data elisting_tab3(drop=cnt);
                retain cnt;
            set elisting_tab3;
            by checkid dataset variable;
                if first.variable then cnt = 0;
                cnt = cnt + 1;
                if cnt = 50 then do;
                    spec_PXL_Notes = catx("; ",spec_PXL_Notes,"Output per check, dataset, and variable limited to this 50th obs for display");
                end;
                if cnt > 50 then delete;
            run;

            * Set labels and check_desc;
            data _tab3(keep=checkid type check_desc dataset variable pxl_notes data_dataset 
                data_dataset_label data_variable data_type data_length data_format 
                data_label data_key data_value spec_dataset spec_domain_version 
                spec_variable spec_core spec_type spec_length spec_format 
                spec_label spec_comments spec_PXL_Notes);
                attrib
                    checkid length=$200 label="Check ID"
                    type length=$200 label="Severity"
                    check_desc length=$200 label="Check Brief Description"
                    dataset length=$200 label="Dataset"
                    variable length=$200 label="Variable"
                    pxl_notes length=$200 label="Notes"

                    data_dataset length=$200 label="Dataset"
                    data_dataset_label length=$200 label="Dataset Label"
                    data_variable length=$200 label="Variable"
                    data_type length=$200 label="Type"
                    data_length label="Length"
                    data_format length=$200 label="Format"
                    data_label length=$200 label="Label"
                    data_key length=$200 label="Value Key"
                    data_value length=$200 label="Value"

                    spec_dataset label="Dataset"
                    spec_domain_version label="Domain Version"
                    spec_variable label="Variable"
                    spec_core label="Core"
                    spec_type label="Type"
                    spec_length label="Length"
                    spec_format label="Format"
                    spec_label label="Label"
                    spec_comments label="Comments"
                    spec_PXL_Notes label="PXL Notes"
                ;
            set elisting_tab3;                

                if checkid="CK 1.01" then check_desc="Dataset exists that is not in spec";
                if checkid="CK 1.02" then check_desc="Dataset label is not valid";
                if checkid="CK 1.03" then check_desc="Dataset label greater than spec";
                if checkid="CK 1.04" then check_desc="Libname %upcase(&pfescrf_csdw_validator_download) latest date is after earliest libname %upcase(&pfescrf_csdw_validator_scrf)";
                if checkid="CK 1.05" then check_desc="Global macro variable 'dataSensitivity' does not exist or is valid";
                if checkid="CK 1.06" then check_desc="Symbolic Link current within libname %upcase(&pfescrf_csdw_validator_download) points to DRAFT";
                if checkid="CK 1.07" then check_desc="Symbolic Link current within libname %upcase(&pfescrf_csdw_validator_scrf) points to DRAFT";
                if checkid="CK 1.08" then check_desc="SCRF Dataset DEMOG must exist";
                if checkid="CK 1.09" then check_desc="Libname %upcase(&pfescrf_csdw_validator_download) contains no datasets";

                if checkid="CK 2.01" then check_desc="Variable exists that is not in spec";
                if checkid="CK 2.02" then check_desc="Variable type does not match spec";
                if checkid="CK 2.03" then check_desc="Variable length does not match spec";
                if checkid="CK 2.04" then check_desc="Variable label does not match spec";
                if checkid="CK 2.05" then check_desc="Variable is required but not found";
                if checkid="CK 2.06" then check_desc="Variable format does not match spec";

                if checkid="CK 3.01" then check_desc="Value not found in codelist";
                if checkid="CK 3.02" then check_desc="Value non-conformant per date format DDMMMYYYY";
                if checkid="CK 3.03" then check_desc="Value non-conformant per date format DD-MMM-YYYY";
                if checkid="CK 3.04" then check_desc="Value non-conformant per date format YYYY-MM-DD";
                if checkid="CK 3.05" then check_desc="Value non-conformant per time format HH:MM";
                if checkid="CK 3.06" then check_desc="Value non-conformant per time format HH:MM:SS";

                if checkid="CK 4.01" then check_desc="Non-printable ASCII characters found";
                if checkid="CK 4.02" then check_desc="UAT data found";
                if checkid="CK 4.03" then check_desc="PID value format is incorrect";
                if checkid="CK 4.04" then check_desc="CPEVENT length of data is longer than 20";
                if checkid="CK 4.06" then check_desc="Missing Required Value Report missing rate above 25%";
                if checkid="CK 4.07" then check_desc="Libname %upcase(&pfescrf_csdw_validator_download) numeric variable with a format/informat length > 32";
            run;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Listing Creation - TAB4 Missing Required Value Report;
        %put NOTE:[PXL] ***********************************************************************;
            * Set checkid and checdesc;
            data elisting_tab4;
                attrib 
                    checkid   length=$200 label="Check ID"
                    type      length=$200 label="Severity"
                    checkdesc length=$200 label="Check Description"
                    dataset   length=$200 label="Dataset"
                    variable  length=$200 label="Variable"
                    pmis      length=$200 label="Missing per Expected Percent"
                    cnt_mis   length=8 label="Missing"
                    cnt_pre   length=8 label="Present"
                    cnt_exp   length=8 label="Expected"
                    cnt_tot   length=8 label="Total Records"
                ;                    
            set elisting_tab4;                
                cnt_pre = cnt_exp - cnt_mis;
                pmis = catx(" ",put(round(cnt_mis / cnt_exp * 100, 0.01), 8.2),"%");

                if variable = 'ACTEVENT' then do; checkid='5.001'; checkdesc="[ALL] required values: ACTEVENT"; end;
                if variable = 'CPEVENT' then do; checkid='5.002'; checkdesc="[ALL] required values: CPEVENT"; end;
                if variable = 'INV' then do; checkid='5.003'; checkdesc="[ALL] required values: INV"; end;
                if variable = 'LSTCHGTS' then do; checkid='5.004'; checkdesc="[ALL] required values: LSTCHGTS"; end;
                if variable = 'PID' then do; checkid='5.005'; checkdesc="[ALL] required values: PID"; end;
                if variable = 'PROJCODE' then do; checkid='5.006'; checkdesc="[ALL] required values: PROJCODE"; end;
                if variable = 'PROTNO' then do; checkid='5.007'; checkdesc="[ALL] required values: PROTNO"; end;
                if variable = 'REPEATSN' then do; checkid='5.008'; checkdesc="[ALL] required values: REPEATSN"; end;
                if variable = 'SID' then do; checkid='5.009'; checkdesc="[ALL] required values: SID"; end;
                if variable = 'SITEID' then do; checkid='5.010'; checkdesc="[ALL] required values: SITEID"; end;
                if variable = 'STUDY' then do; checkid='5.011'; checkdesc="[ALL] required values: STUDY"; end;
                if variable = 'STUDYID' then do; checkid='5.012'; checkdesc="[ALL] required values: STUDYID"; end;
                if variable = 'SUBEVE' then do; checkid='5.013'; checkdesc="[ALL] required values: SUBEVE"; end;
                if variable = 'SUBJID' then do; checkid='5.014'; checkdesc="[ALL] required values: SUBJID"; end;
                if variable = 'TRIALNO' then do; checkid='5.015'; checkdesc="[ALL] required values: TRIALNO"; end;
                if variable = 'VISIT' then do; checkid='5.016'; checkdesc="[ALL] required values: VISIT"; end;
                if variable = 'ACCESSTS' then do; checkid='5.017'; checkdesc="[ALL] required values: ACCESSTS"; end;
                if variable = 'COLLDATE' then do; checkid='5.018'; checkdesc="[ALL] required values: COLLDATE"; end;

                if dataset = 'TESTDRUG' then do;
                    if variable = 'DRGCODE' then do; checkid='5.019'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DRGCODE"; end;
                    if variable = 'DRGGROUP' then do; checkid='5.020'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DRGGROUP"; end;
                    if variable = 'DRGNAME' then do; checkid='5.021'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DRGNAME"; end;
                    if variable = 'DOSE' then do; checkid='5.022'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DOSE"; end;
                    if variable = 'DOSEUNI' then do; checkid='5.023'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DOSEUNI"; end;
                    if variable = 'DOSTOT' then do; checkid='5.024'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': DOSTOT"; end;
                    if variable = 'FROMDATE' then do; checkid='5.025'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': FROMDATE"; end;
                    if variable = 'TODATE' then do; checkid='5.026'; checkdesc="TESTDRUG required values unless NOTDONE=1 'NOT DONE': TODATE"; end;
                end;

                if dataset = 'ADVERSE' then do;
                    if variable = 'FROMDATE' then do; checkid='5.027'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': FROMDATE"; end;
                    if variable = 'TODATE' then do; checkid='5.028'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': TODATE"; end;
                    if variable = 'AEDECD1' then do; checkid='5.029'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': AEDECD1"; end;
                    if variable = 'AEDECD2' then do; checkid='5.030'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': AEDECD2"; end;
                    if variable = 'AEDECD3' then do; checkid='5.031'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': AEDECD3"; end;
                    if variable = 'AEDECD4' then do; checkid='5.032'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': AEDECD4"; end;
                    if variable = 'AEBDSYS' then do; checkid='5.033'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': AEBDSYS"; end;
                    if variable = 'AESER' then do; checkid='5.034'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': AESER"; end;
                    if variable = 'AETERM' then do; checkid='5.035'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': AETERM"; end;
                    if variable = 'AESEV' then do; checkid='5.036'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': either AESEV or AEGRADE"; end;
                    if variable = 'AESTDRG' then do; checkid='5.037'; checkdesc="ADVERSE required values unless AENONE=1 'NONE': one of: AESTDRG, AEST1NM, AEST1TR, AEST2NM, AEST2TR, AEST3NM or AEST3TR"; end;
                end;

                if dataset = 'DEMOG' then do;
                    if variable = 'DOB' then do; checkid='5.038'; checkdesc="DEMOG required values: DOB"; end;
                    if variable = 'SEX' then do; checkid='5.039'; checkdesc="DEMOG required values: SEX"; end;
                    if variable = 'ETHNIC' then do; checkid='5.040'; checkdesc="DEMOG required values if domain version greater than 2: ETHNIC"; end;
                    if variable = 'ETHNICC' then do; checkid='5.041'; checkdesc="DEMOG required values if domain version greater than 2: ETHNICC"; end;
                end;

                if dataset = 'ECG' then do;
                    if variable = 'EGND' then do; checkid='5.042'; checkdesc="ECG required values always: EGND"; end;
                    if variable = 'EGTEST' then do; checkid='5.043'; checkdesc="ECG required values always: EGTEST"; end;
                end;

                if dataset = 'PRIMDIAG' then do;
                    if variable = 'PSDECD1' then do; checkid='5.044'; checkdesc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD1"; end;
                    if variable = 'PSDECD2' then do; checkid='5.045'; checkdesc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD2"; end;
                    if variable = 'PSDECD3' then do; checkid='5.046'; checkdesc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD3"; end;
                    if variable = 'PSDECD4' then do; checkid='5.047'; checkdesc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSDECD4"; end;
                    if variable = 'PSBDSYS' then do; checkid='5.048'; checkdesc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSBDSYS"; end;
                    if variable = 'PSTERM' then do; checkid='5.049'; checkdesc="PRIMDIAG required values unless PRMNONE=1 'NONE': PSTERM"; end;
                    if variable = 'PRIMDATE' then do; checkid='5.050'; checkdesc=catx(" ","PRIMDIAG - One Diagnosis Date is required value unless PRMNONE=1 'NONE':",
                          "PRIMDATE, PRIMDATF, DIAGDT, PRIMHDT, PRMEPDT, ONCCUDT, ONCLODT, ONCMEDT, ONCREDT, or PRIMPDT"); end;
                end;

                if dataset = 'PREVDIS' then do;
                    if variable = 'MNOTDONE' then do; checkid='5.051'; checkdesc="PREVDIS required values: MNOTDONE"; end;
                    if variable = 'DISSTAT1' then do; checkid='5.052'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOT DONE' or NSHIST= 1 'NONE': DISSTAT1"; end;
                    if variable = 'MHDECD1' then do; checkid='5.053'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD1"; end;
                    if variable = 'MHDECD2' then do; checkid='5.054'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD2"; end;
                    if variable = 'MHDECD3' then do; checkid='5.055'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD3"; end;
                    if variable = 'MHDECD4' then do; checkid='5.056'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHDECD4"; end;
                    if variable = 'MHBDSYS' then do; checkid='5.057'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHBDSYS"; end;
                    if variable = 'MHTERM' then do; checkid='5.058'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': MHTERM"; end;
                    if variable = 'NSHIST' then do; checkid='5.059'; checkdesc="PREVDIS required values unless MNOTDONE = 1 'NOTDONE' or DISSTAT1 = 7 'NOT APPLICABLE': NSHIST"; end;             
                end;

                if dataset = 'CONDRUG' then do;
                    if variable = 'CMCODE' then do; checkid='5.060'; checkdesc="CONDRUG required values unless NONE = 1 'NONE' or NOTDONE = 1 'NOT DONE': CMCODE"; end;
                    if variable = 'CMTERM' then do; checkid='5.061'; checkdesc="CONDRUG required values unless NONE = 1 'NONE' or NOTDONE = 1 'NOT DONE': CMTERM"; end;
                    if variable = 'CDRGPRIM' then do; checkid='5.062'; checkdesc="CONDRUG required values if present unless  NONE = 1 'NONE' or NOTDONE = 1 'NOT DONE': CDRGPRIM"; end;
                end;

                if dataset = 'CONTRT' then do;                
                    if variable = 'CTDECD1' then do; checkid='5.063'; checkdesc="CONTRT required values unless NONE = 1 'NONE': CTDECD1"; end;
                    if variable = 'CTDECD2' then do; checkid='5.064'; checkdesc="CONTRT required values unless NONE = 1 'NONE': CTDECD2"; end;
                    if variable = 'CTDECD3' then do; checkid='5.065'; checkdesc="CONTRT required values unless NONE = 1 'NONE': CTDECD3"; end;
                    if variable = 'CTDECD4' then do; checkid='5.066'; checkdesc="CONTRT required values unless NONE = 1 'NONE': CTDECD4"; end;
                    if variable = 'CTBDSYS' then do; checkid='5.067'; checkdesc="CONTRT required values unless NONE = 1 'NONE': CTBDSYS"; end;
                    if variable = 'CTTERM' then do; checkid='5.068'; checkdesc="CONTRT required values unless NONE = 1 'NONE': CTTERM"; end;
                end;

                if dataset = 'FINAL' then do;  
                    if variable = 'COLLDATF' then do; checkid='5.069'; checkdesc="FINAL required values: COLLDATF"; end;
                    if variable = 'FINSTAT' then do; checkid='5.070'; checkdesc="FINAL required values: FINSTAT"; end;
                end;

                if dataset = 'HE' then do; 
                    if variable = 'AEDECD1' then do; checkid='5.071'; checkdesc="HE required values unless AENONE= 1 'NONE': AEDECD1"; end;
                    if variable = 'AEDECD2' then do; checkid='5.072'; checkdesc="HE required values unless AENONE= 1 'NONE': AEDECD2"; end;
                    if variable = 'AEDECD3' then do; checkid='5.073'; checkdesc="HE required values unless AENONE= 1 'NONE': AEDECD3"; end;
                    if variable = 'AEDECD4' then do; checkid='5.074'; checkdesc="HE required values unless AENONE= 1 'NONE': AEDECD4"; end;
                    if variable = 'AEBDSYS' then do; checkid='5.075'; checkdesc="HE required values unless AENONE= 1 'NONE': AEBDSYS"; end;
                end;

                if dataset = 'LAB_SAFE' then do;    
                    if variable = 'LABCODE' then do; checkid='5.076'; checkdesc="LAB_SAFE values required: LABCODE"; end;
                    if variable = 'TRIAL_ID' then do; checkid='5.077'; checkdesc="LAB_SAFE values required: TRIAL_ID"; end;
                end;

                if dataset = 'ME' then do; 
                    if variable = 'AEDECD1' then do; checkid='5.078'; checkdesc="ME required values unless AENONE= 1 'NONE': AEDECD1"; end;
                    if variable = 'AEDECD2' then do; checkid='5.079'; checkdesc="ME required values unless AENONE= 1 'NONE': AEDECD2"; end;
                    if variable = 'AEDECD3' then do; checkid='5.080'; checkdesc="ME required values unless AENONE= 1 'NONE': AEDECD3"; end;
                    if variable = 'AEDECD4' then do; checkid='5.081'; checkdesc="ME required values unless AENONE= 1 'NONE': AEDECD4"; end;
                    if variable = 'AEBDSYS' then do; checkid='5.082'; checkdesc="ME required values unless AENONE= 1 'NONE': AEBDSYS"; end;
                end;

                if dataset = 'PHYEXAM' then do;
                    if variable = 'RSLTCODE' then do; checkid='5.083'; checkdesc="PHYEXAM required values unless NOTDONE = 1 'NOT DONE': RSLTCODE"; end;
                end;

                if dataset = 'RANDOM' then do;                    
                    if variable = 'COUNTRY' then do; checkid='5.084'; checkdesc="RANDOM required values: COUNTRY"; end;
                    if variable = 'PTRAND' then do; checkid='5.085'; checkdesc="RANDOM required values: PTRAND"; end;
                    if variable = 'RANDNAME' then do; checkid='5.086'; checkdesc="RANDOM required values: RANDNAME"; end;
                    if variable = 'RANDPAT' then do; checkid='5.087'; checkdesc="RANDOM required values: RANDPAT"; end;
                end;

                if dataset = 'SCDG' then do;                                    
                    if variable = 'PSDECD1' then do; checkid='5.088'; checkdesc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD1"; end;
                    if variable = 'PSDECD2' then do; checkid='5.089'; checkdesc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD2"; end;
                    if variable = 'PSDECD3' then do; checkid='5.090'; checkdesc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD3"; end;
                    if variable = 'PSDECD4' then do; checkid='5.091'; checkdesc="SCDG required values unless SCDNONE = 1 'NONE': PSDECD4"; end;
                    if variable = 'PSBDSYS' then do; checkid='5.092'; checkdesc="SCDG required values unless SCDNONE = 1 'NONE': PSBDSYS"; end;
                    if variable = 'PSTERM' then do; checkid='5.093'; checkdesc="SCDG required values unless SCDNONE = 1 'NONE': PSTERM"; end;
                end;

                if dataset = 'VITALS' then do;
                    if variable = 'VSDTF' then do; checkid='5.094'; checkdesc="VITALS required values unless VSND=1 'NOT DONE': VSDTF"; end;
                    if variable = 'VSPOS' then do; checkid='5.095'; checkdesc="VITALS required values unless VSND=1 'NOT DONE': VSPOS"; end;
                    if variable = 'VSND' then do; checkid='5.096'; checkdesc="VITALS required values: VSND"; end;
                end;
            run;  
            proc sort data = elisting_tab4; by checkid; run;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Listing Output;
        %put NOTE:[PXL] ***********************************************************************;

            %if %str("&pfescrf_csdw_validator_test") = %str("N") %then %do;

                options missing='';

                ods listing close; 
                ods tagsets.excelxp file= "&pfescrf_csdw_validator_pathlist/&pfescrf_csdw_validator_ListName";

                * Set titles and footnotes;
                title;
                title1 justify=left "&pfescrf_csdw_validator_ListName";
                footnote1 j=l "PAREXEL International Confidential";
                footnote2 j=l "Produced by %upcase(&sysuserid) on &sysdate9";

                    * Tab 1;
                        ods tagsets.excelxp options (
                            Orientation = "landscape"
                            sheet_name = "Issues"
                            Embedded_Titles = "Yes"
                            Row_Repeat = "Header"
                            Autofit_Height = "Yes"
                            Autofilter = "All"
                            Frozen_Headers = "Yes"
                            Gridlines = "Yes"
                            default_column_width= "40, 80"
                            sheet_name = "Overview"
                            zoom = "80"
                            frozen_headers = "3"
                            row_repeat = "3");

                            proc report data= _tab1 style(column)={tagattr='Format:Text'};
                                compute values; 
                                    if values = "FAIL" or values = "DIRTY" then
                                        call define(_row_,"style","style={background=verylightred}");
                                    if values = "PASS" or values = "CLEAN" then
                                        call define(_row_,"style","style={background=verylightblue}");
                                endcomp;                
                            run; quit;

                    * Tab 2;
                        ods tagsets.excelxp options (
                            default_column_width= "10,8,50,50,15"
                            sheet_name = "List of Checks Completed"
                            frozen_headers = "3"
                            row_repeat = "3");            
                                
                            proc report data= _tab2 style(column)={tagattr='Format:Text'};
                            run; quit;

                    * Tab 3;
                        ods tagsets.excelxp options (
                            default_column_width= "8,10,25,10,10,25,10,10,10,8,8,10,20,20,20,10,10,10,10,8,8,20,20,20"
                            sheet_name = "Validation Check Issues"
                            frozen_headers = "4"
                            zoom = "60"
                            row_repeat = "4");            
                                
                            proc report data= _tab3 style(column)={tagattr='Format:Text'};
                                columns ("Overview" checkid type check_desc dataset variable pxl_notes)
                                        ("Study SCRF Data" data_dataset data_dataset_label data_variable 
                                            data_type data_length data_format data_label data_key 
                                            data_value)
                                        ("CSDW SCRF Specification" spec_dataset spec_domain_version 
                                            spec_variable spec_core spec_type spec_length spec_format 
                                            spec_label spec_comments spec_PXL_Notes);

                                define checkid / display;
                                define type / display;
                                define check_desc / display;
                                define dataset / display;
                                define variable / display;
                                define pxl_notes / display;

                                define data_dataset / display;
                                define data_dataset_label / display;
                                define data_variable / display;
                                define data_type / display;
                                define data_length / display;
                                define data_format / display;
                                define data_label / display;
                                define data_key / display;
                                define data_value / display;

                                define spec_dataset / display;
                                define spec_domain_version / display;
                                define spec_variable / display;
                                define spec_core / display;
                                define spec_type / display;
                                define spec_length / display;
                                define spec_format / display;
                                define spec_label / display;
                                define spec_comments / display;
                                define spec_PXL_Notes / display;       

                                compute checkid; call define(_col_,"style","style={background=verylightgreen}"); endcomp;
                                compute type; call define(_col_,"style","style={background=verylightgreen}"); endcomp;
                                compute check_desc; call define(_col_,"style","style={background=verylightgreen}"); endcomp;
                                compute dataset; call define(_col_,"style","style={background=verylightgreen}"); endcomp;
                                compute variable; call define(_col_,"style","style={background=verylightgreen}"); endcomp;
                                compute pxl_notes; call define(_col_,"style","style={background=verylightgreen}"); endcomp;

                                compute spec_PXL_Notes;
                                    if checkid = "CK 1.01" then do;
                                        call define("data_dataset","style","style={background=verylightred}");
                                        call define("data_dataset_label","style","style={background=verylightred}");
                                    end;
                                    if checkid = "CK 1.02" then do;
                                        call define("data_dataset","style","style={background=verylightred}");
                                        call define("data_dataset_label","style","style={background=verylightred}");
                                    end;
                                    if checkid = "CK 1.03" then do;
                                        call define("data_dataset_label","style","style={background=verylightred}");
                                        call define("spec_domain_version","style","style={background=verylightred}");
                                    end;                            
                                    if checkid in ("CK 1.04") then do;
                                        call define("data_dataset","style","style={background=verylightred}");
                                        call define("pxl_notes","style","style={background=verylightred}");
                                    end;

                                    if checkid = "CK 2.01" then do;
                                        call define("data_dataset","style","style={background=verylightred}");
                                        call define("data_dataset_label","style","style={background=verylightred}");
                                        call define("data_variable","style","style={background=verylightred}");
                                        call define("data_type","style","style={background=verylightred}");
                                        call define("data_length","style","style={background=verylightred}");
                                        call define("data_format","style","style={background=verylightred}");
                                        call define("data_label","style","style={background=verylightred}");
                                    end; 
                                    if checkid = "CK 2.02" then do;
                                        call define("data_type","style","style={background=verylightred}");
                                        call define("spec_type","style","style={background=verylightred}");
                                    end;
                                    if checkid = "CK 2.03" then do;
                                        call define("data_length","style","style={background=verylightred}");
                                        call define("spec_length","style","style={background=verylightred}");
                                    end;
                                    if checkid = "CK 2.04" then do;
                                        call define("data_label","style","style={background=verylightred}");
                                        call define("spec_label","style","style={background=verylightred}");
                                    end;
                                    if checkid = "CK 2.05" then do;
                                        call define("data_dataset","style","style={background=verylightred}");
                                        call define("data_dataset_label","style","style={background=verylightred}");
                                        call define("data_variable","style","style={background=verylightred}");
                                        call define("data_type","style","style={background=verylightred}");
                                        call define("data_length","style","style={background=verylightred}");
                                        call define("data_format","style","style={background=verylightred}");
                                        call define("data_label","style","style={background=verylightred}");
                                    end;
                                    if checkid = "CK 2.06" then do;
                                        call define("data_format","style","style={background=verylightred}");
                                        call define("spec_format","style","style={background=verylightred}");
                                        call define("spec_comments","style","style={background=verylightred}");
                                    end;
                                    if checkid in ("CK 3.01") then do;
                                        call define("data_value","style","style={background=verylightred}");
                                        call define("spec_comments","style","style={background=verylightred}");
                                    end;
                                    if checkid in ("CK 3.02","CK 3.03","CK 3.04","CK 3.05","CK 3.06") then do;
                                        call define("data_key","style","style={background=verylightred}");
                                        call define("data_value","style","style={background=verylightred}");
                                        call define("spec_comments","style","style={background=verylightred}");
                                    end;  
                                    if checkid in ("CK 4.01","CK 4.02","CK 4.03","CK 4.04") then do;
                                        call define("data_key","style","style={background=verylightred}");
                                        call define("data_value","style","style={background=verylightred}");
                                    end; 
                                    if checkid in ("CK 1.05","CK 1.06","CK 1.07","CK 4.06") then do;
                                        call define("pxl_notes","style","style={background=verylightred}");
                                    end;                                                                     
                                endcomp;

                            run; quit;                         

                    * Tab 4;
                        ods tagsets.excelxp options (
                        default_column_width= "8, 10, 50, 10, 10, 8, 8, 8, 8, 8"
                        sheet_name = "Missing Required Value Report"
                        frozen_headers = "4"
                        zoom = "60"
                        row_repeat = "4");            
                            
                        proc report data= elisting_tab4 style(column)={tagattr='Format:Text'};
                            columns ("Overview" checkid type checkdesc dataset variable)
                                    ("Statistics" pmis cnt_mis cnt_pre cnt_exp cnt_tot);
                        run;

                ods tagsets.excelxp close;
                ods listing;

            %end;
            %else %do;
                %put %str(WARN)ING:[PXL] &pfescrf_csdw_validator_MacName: Input Parameter pfescrf_csdw_validator_test is not 'N', XLS Listing not created;
            %end;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Macro End and Cleanup;
    %put NOTE:[PXL] ***********************************************************************;
        %goto MacEnd;
        %MacErr:;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: Abnormal end to macro;
        %put %str(ERR)OR:[PXL] &pfescrf_csdw_validator_MacName: See log for details;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %let GMPXLERR=1;

        %MacEnd:;
        title;
        footnote;
        OPTIONS fmterr quotelenmax;; * Reset Ignore format notes in log;
        OPTIONS missing=.;

        %macro delmac(wds=null);
            %if %sysfunc(exist(&wds)) %then %do; 
                proc datasets lib=work nolist; delete &wds; quit; run; 
            %end; 
        %mend delmac;
        %delmac(wds=_tab1);
        %delmac(wds=_tab2);
        %delmac(wds=elisting_tab3);
        %delmac(wds=_data);
        %delmac(wds=_data_spec_attrib);
        %delmac(wds=_data_spec_datasets);
        %delmac(wds=_data_spec_var1);
        %delmac(wds=_data_spec_var2);
        %delmac(wds=_elisting);
        %delmac(wds=codelists);
        %delmac(wds=spec_data);
        %delmac(wds=_dirlist);
        %delmac(wds=_1_01);
        %delmac(wds=_temp);
        %delmac(wds=_listing);
        %delmac(wds=_3_01_C);         
        %delmac(wds=_spec);

        proc sql noprint;
            select count(*) into: exists
            from sashelp.vlibnam
            where libname = "LIB_MD";
        quit;
        %if %eval(&exists > 0) %then %do;
            libname LIB_MD clear;
        %end;

        %put INFO:[PXL]----------------------------------------------;
        %put INFO:[PXL] &pfescrf_csdw_validator_MacName: Macro Completed; 
        %put INFO:[PXL] Output: ;
        %put INFO:[PXL]    pfescrf_csdw_validator_PassFail = &pfescrf_csdw_validator_PassFail;
        %put INFO:[PXL]    pfescrf_csdw_validator_NumErr = &pfescrf_csdw_validator_NumErr; 
        %put INFO:[PXL]    pfescrf_csdw_validator_NumWarn = &pfescrf_csdw_validator_NumWarn; 
        %put INFO:[PXL]    pfescrf_csdw_validator_ListName = &pfescrf_csdw_validator_ListName;
        %put INFO:[PXL]    pfescrf_csdw_validator_ErrMsg = &pfescrf_csdw_validator_ErrMsg;        
        %put INFO:[PXL]----------------------------------------------;

%mend pfescrf_csdw_validator;
