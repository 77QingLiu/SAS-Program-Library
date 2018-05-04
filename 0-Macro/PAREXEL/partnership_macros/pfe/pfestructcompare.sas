/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
 
  SAS Version:           9.2 and above
  Operating System:      UNIX

-------------------------------------------------------------------------------
 
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20150824       $LastChangedDate: 2015-08-24 15:32:43 -0400 (Mon, 24 Aug 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/pfestructcompare.sas $
 
  Files Created:         SAS Dataset Transfer metadata and verification against it listing report

  Program Purpose:       1) Create approved transfer SAS dataset metadata <br />
                         2) Modify approved transfer SAS dataset metadata <br />
                         3) Verify a transfer matches approved transfer SAS dataset metadata

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
 
  Macro Parameters:

    Name:                pfestructcompare_metadata
      Allowed Values:    Valid KENNET path
      Default Value:     /projects/std_pfizer/sacq/metadata/data
      Description:       Specifies the central metadata location that holds
                         specifications saved as SAS datasets
 
    Name:                pfestructcompare_confirmedchange
      Allowed Values:    Y or N
      Default Value:     N
      Description:       1) Set to Y if confirming there will be changes to SAS structure and to 
                         replace the study approved transfer metadata structure standard or if 
                         first transfer and to set the standard
                         2) Set to N if transfer expected to match the set standard
 
    Name:                pfestructcompare_protocol
      Allowed Values:    Value of the protocol
      Default Value:     protocol
      Description:       Will use as name of protocol to check against, or use macro
                         variable PROTOCOL value.

    Name:                pfestructcompare_pxl_code
      Allowed Values:    Value of the pxl code for study
      Default Value:     pxl_code
      Description:       Will use as name of pxl code for study to check against, 
                         or use macro variable pxl_code value.

    Name:                pfestructcompare_pathlist
      Allowed Values:    Valid KENNET directory path
      Default Value:     path_listings
      Description:       Unix path to save the output listing. Defaults to use 
                         macro variable path_listings location.

    Name:                pfestructcompare_scrf
      Allowed Values:    SAS library name
      Default Value:     scrf
      Description:       SAS library that holds the CSDW SCRF created SAS 
                         datasets to check against 

  Global Macrovariables:
 
    Name:                pfestructcompare_PassFail
      Usage:             Creates
      Description:       Sets to PASS or FAIL depnding on macro outcome
 
    Name:                pfestructcompare_NumDiff
      Usage:             Creates
      Description:       Sets to number of differences found

    Name:                pfestructcompare_ListName
      Usage:             Creates
      Description:       Sets to name of output listing created

    Name:                pfestructcompare_ErrMsg
      Usage:             Creates
      Description:       Sets to message for any abnormal termination

  Metadata Keys:
 
    Name:                Reference Specification Data
      Description:       Located per input parameter &pfestructcompare_metadata but default is 
                         /projects/std_pfizer/sacq/metadata/data/SCRF_CSDW_&pfestructcompare_pxl_code. 
                         where input parameter pfestructcompare_pxl_code is PXL study Code ID. 
                         This holds the last approved study transfer structure metadata.
      Dataset:           scrf_csdw_<6 digit PXL Study Code>                       

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1021 $

-----------------------------------------------------------------------------*/

%macro pfestructcompare(
    pfestructcompare_metadata=/projects/std_pfizer/sacq/metadata/scrf_csdw,
    pfestructcompare_confirmedchange=N,
    pfestructcompare_protocol=null,
    pfestructcompare_pxl_code=null,
    pfestructcompare_pathlist=null,
    pfestructcompare_scrf=scrf);

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
          %let pfestructcompare_MacName  = PFESTRUCTCOMPARE;
          %let pfestructcompare_MacVer   = 1.0;
          %let pfestructcompare_MacVerDT = 20150824;
          %let pfestructcompare_MacPath  = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
          %*let pfestructcompare_MacPath  = /opt/pxlcommon/stats/macros/unittesting/testing_area/macros/partnership_macros/pfe;
          %let pfestructcompare_RunDTE   = %sysfunc(left(%sysfunc(datetime(), IS8601DT.))); * Datetime as YYYY-MM-DDTHH:MM:SS;
          %let pfestructcompare_RunDT    = %sysfunc(left(%sysfunc(compress(%sysfunc(date(), yymmddn8.), '-')))); * Date as YYYYMMDD;
          %*let pfestructcompare_RunDateTime      = %sysfunc(compress(%sysfunc(left(%sysfunc(datetime(), IS8601DT.))), '-:'));

        * Global return macros - used with submacro call from a parent;
          %global 
              pfestructcompare_PassFail  
              pfestructcompare_NumDiff
              pfestructcompare_ListName
              pfestructcompare_ErrMsg;

          %let pfestructcompare_PassFail = FAIL; * PASS or FAIL final outcome, Any Err ors then FAIL;
          %let pfestructcompare_NumDiff  = null; * Number of differences found;
          %let pfestructcompare_ListName = null; * Path and name of output listing created;
          %let pfestructcompare_ErrMsg   = null; * If program run has issues, lists what the issue was;

        * Log output input parameters;
          %put INFO:[PXL]----------------------------------------------;
          %put INFO:[PXL] &pfestructcompare_MacName: Macro Started;
          %put INFO:[PXL] File Location: &pfestructcompare_MacPath ;
          %put INFO:[PXL] Version Number: &pfestructcompare_MacVer ;
          %put INFO:[PXL] Version Date: &pfestructcompare_MacVerDT ;
          %put INFO:[PXL] Run DateTime: &pfestructcompare_RunDTE;        
          %put INFO:[PXL] ;
          %put INFO:[PXL] Purpose: Compare SAS structure against a transfer standard ; 
          %put INFO:[PXL] Input Parameters:;
          %put INFO:[PXL]   1) pfestructcompare_metadata = &pfestructcompare_metadata;
          %put INFO:[PXL]   2) pfestructcompare_confirmedchange = &pfestructcompare_confirmedchange;
          %put INFO:[PXL]   3) pfestructcompare_protocol = &pfestructcompare_protocol;
          %put INFO:[PXL]   4) pfestructcompare_pxl_code = &pfestructcompare_pxl_code;
          %put INFO:[PXL]   6) pfestructcompare_pathlist = &pfestructcompare_pathlist;
          %put INFO:[PXL]   7) pfestructcompare_scrf = &pfestructcompare_scrf;
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
                %let pfestructcompare_ErrMsg = Global macro GMPXLERR = 1, macro not executed;
                %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg;
                %goto MacErr;
            %end; 

        %put NOTE:[PXL] 3) Verify Input Parameter pfestructcompare_metadata directory exists;
            %if %mu_direxist(pathdir=&pfestructcompare_metadata) = 0 %then %do;
                %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_metadata does not exist: &pfestructcompare_metadata;
                %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg;
                %goto MacErr;
            %end;

            * Location of study structure datasets;
            libname md "&pfestructcompare_metadata";

            * Holds archives of study structure datasets;
            %sysexec %str(mkdir -p  &pfestructcompare_metadata/archive);
            libname md_arch "&pfestructcompare_metadata/archive";

        %put NOTE:[PXL] 4) Verify Input Parameter pfestructcompare_confirmedchange is Y or N;
            %if %str("&pfestructcompare_confirmedchange") ne %str("Y") 
                and %str("&pfestructcompare_confirmedchange") ne %str("N") %then %do;

                %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_confirmedchange is Y or N: &pfestructcompare_confirmedchange;
                %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg;
                %goto MacErr;
            %end;

        %put NOTE:[PXL] 5) Verify pfestructcompare_protocol;
            %if %str("&pfestructcompare_protocol")=%str("null") %then %do;
                * Default, check if can get from global macro protocol;

                * First check if macro protocol exists;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vmacro 
                    where name="PROTOCOL";
                quit;
                %if &exists=0 %then %do;
                    %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_protocol is null and global macro protocol does not exist;
                    %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg; 
                    %goto MacErr;
                %end;
                %else %do;
                    %let pfestructcompare_protocol = &protocol;
                %end;
                %let pfestructcompare_protocol = %left(%trim(&pfestructcompare_protocol));
            %end;

        %put NOTE:[PXL] 6) Verify pfestructcompare_pxl_code;
            %if %str("&pfestructcompare_pxl_code")=%str("null") %then %do;
                * Default, check if can get from global macro PXL_CODE;

                * First check if macro PXL_CODE exists;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vmacro 
                    where name="PXL_CODE";
                quit;
                %if &exists=0 %then %do;
                    %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_pxl_code is null and global macro PXL_CODE does not exist;
                    %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg; 
                    %goto MacErr;
                %end;
                %else %do;
                    %let pfestructcompare_pxl_code = &pxl_code;
                %end;
                %let pfestructcompare_pxl_code = %left(%trim(&pfestructcompare_pxl_code));
            %end;            

        %put NOTE:[PXL] 7) Verify pfestructcompare_pathlist is valid directory for listing output;
            %if %str("&pfestructcompare_pathlist")=%str("null") %then %do;
                * Get listing path from global macro path_listings if exists
                  this is global macro created by pfizer standard setup, should point to /projects/pfizrNNNNNN/dm/listings;
                proc sql noprint;
                    select count(*) into :exists
                    from sashelp.vmacro 
                    where name="PATH_LISTINGS";
                quit;
                %if &exists=0 %then %do;
                    %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_pathlist is null and global macro PATH_LISTINGS does not exist;
                    %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg; 
                    %goto MacErr;
                %end;
                %else %do;
                    %put NOTE:[PXL] Global macro path_listings exists, creating symbolic link current to today dated folder;
                    %sysexec %str(mkdir -p  &PATH_LISTINGS/%sysfunc(today(),yymmddn8.)); * Create new dated folder;
                    %sysexec %str(rm -rf &PATH_LISTINGS/current 2> /dev/null); * Delete current symbolic link;
                    %sysexec %str(ln -s &PATH_LISTINGS/%sysfunc(today(),yymmddn8.) &PATH_LISTINGS/current 2> /dev/null); * Create new symbolic link;

                    %let pfestructcompare_pathlist = &PATH_LISTINGS/current;
                %end;                
            %end;
            %else %do;
                * Check if given path is valid directory;
                %if %mu_direxist(pathdir=&pfestructcompare_pathlist) = 0 %then %do;
                    %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_pathlist is not a valid directory: &pfestructcompare_pathlist;
                    %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg; 
                    %goto MacErr;
                %end;               
            %end;
            %let pfestructcompare_pathlist = %left(%trim(&pfestructcompare_pathlist));

        %put NOTE:[PXL] 8) Verify libname pfestructcompare_scrf and derive path_scrf;
            * Check if libname &pfestructcompare_scrf exists;
            proc sql noprint;
                select count(*) into: cnt
                from sashelp.vslib
                where libname = "%upcase(&pfestructcompare_scrf)";
            quit;            
            %if %eval(&cnt = 0) %then %do;
                %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_scrf is not a valid SAS library: &pfestructcompare_scrf;
                %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg;                      
                %goto MacErr;                
            %end; 

            * Get actual path of SAS library;
            proc sql noprint;
                select distinct
                    path into :path_scrf
                from sashelp.vlibnam 
                where libname="%upcase(&pfestructcompare_scrf)";
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

        %put NOTE:[PXL] 9) Verify libname pfestructcompare_scrf contains SAS datasets;
            proc sql noprint;
                select count(*) into: exists
                from sashelp.vtable 
                where libname="%upcase(&pfestructcompare_scrf)";
            quit;
            %if %eval(&exists = 0) %then %do;
                %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_scrf does not contain datasets;
                %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: &pfestructcompare_ErrMsg;                      
                %goto MacErr; 
            %end;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Compare Structure;
    %put NOTE:[PXL] ***********************************************************************;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Compare Structure - Setup;
        %put NOTE:[PXL] ***********************************************************************;
            %let expected_structure_ds = SCRF_CSDW_%left(%trim(&pfestructcompare_pxl_code));
            %let compared_data = N/A Previous Metadata File Does Not Exist;
            %let compared_data_updated = No;
            %let pfestructcompare_NumDiff = 0;

            %put NOTE:[PXL] expected_structure_ds = &expected_structure_ds;
            %put NOTE:[PXL] pfestructcompare_confirmedchange = &pfestructcompare_confirmedchange;
            %put NOTE:[PXL] pfestructcompare_NumDiff = &pfestructcompare_NumDiff;

            data elisting_tab3; delete; run;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Compare Structure - Derive Metadata and Differences;
        %put NOTE:[PXL] ***********************************************************************;

            %put NOTE:[PXL] Get current structure metadata;
                proc sql noprint;
                    create table current_metadata as
                    select
                        a.memname as dataset,
                        b.memlabel as dataset_label,
                        a.name as variable,
                        a.type as type,
                        a.length as length,
                        a.format as format,
                        a.label as label
                    from sashelp.vcolumn as a 
                         inner join 
                         sashelp.vtable as b 
                    on a.memname = b.memname 
                    where a.libname="%upcase(&pfestructcompare_scrf)"
                          and b.libname="%upcase(&pfestructcompare_scrf)"
                    order by 1, 3;
                quit;

            %put NOTE:[PXL] Set Differences dataset;
                proc sql noprint;
                    select count(*) into: previous_metadata_exists
                    from sashelp.vtable
                    where libname="MD"
                          and memname="%upcase(&expected_structure_ds)";
                quit;
                %if %eval(&previous_metadata_exists = 1) %then %do;
                    * Get dataset label for previous_metadata_exists; 
                    proc sql noprint;
                        select memlabel into: dataset_label
                        from sashelp.vtable
                        where libname="MD"
                              and memname="%upcase(&expected_structure_ds)";
                    quit;

                    %let compared_data = &expected_structure_ds &dataset_label;

                    proc sort data=current_metadata; by dataset dataset_label variable type length format label; run;
                    proc sort data=MD.&expected_structure_ds out=previous_metadata; by dataset dataset_label variable type length format label; run;

                    data elisting_tab3;
                        attrib
                            diff          length=$17 label="Source Data"
                            dataset       label="Dataset"
                            dataset_label label="Dataset Label"
                            variable      label="Variable"
                            type          label="Type"
                            length        label="Length"
                            format        label="Format"
                            label         label="Label"
                        ;                      
                    merge current_metadata(in=a) previous_metadata(in=b);
                    by dataset dataset_label variable type length format label;
                        if a and b then delete;
                        if a and not b then do;
                            diff = 'Current Metadata';
                            output;
                        end;
                        if b and not a then do;
                            diff = 'Previous Metadata';
                            output;
                        end;                    
                    run;
                    proc sort data=elisting_tab3; by dataset variable dataset_label; run;

                    proc sql noprint;
                        select count(*) into: pfestructcompare_NumDiff
                        from elisting_tab3;
                    quit;
                %end;

        %put NOTE:[PXL] ***********************************************************************;
        %put NOTE:[PXL] Compare Structure - Derive Listing Based On Possible Situation;
        %put NOTE:[PXL] ***********************************************************************;
            * 6 Possible Situations:
              S1) ConfirmedChange=Y  | PreviousStruct=N | Differences=N/A
              S2) ConfirmedChange=Y  | PreviousStruct=Y | Differences=Y
              S3) ConfirmedChange=Y  | PreviousStruct=Y | Differences=N
              S4) ConfirmedChange=N  | PreviousStruct=N | Differences=N/A
              S5) ConfirmedChange=N  | PreviousStruct=Y | Differences=N
              S6) ConfirmedChange=N  | PreviousStruct=Y | Differences=Y;

            %if %str("&pfestructcompare_confirmedchange") = %str("Y") %then %do;
                %put NOTE:[PXL] User confirmed expected change to structure;

                * Check if previous structure metadata exists for study;
                %if %eval(&previous_metadata_exists = 1) %then %do;
                    %put NOTE:[PXL] Expected structure file exists, compare current structure against it;

                    %if %eval(&pfestructcompare_NumDiff = 0) %then %do;
                        %put NOTE:[PXL] S3) ConfirmedChange=Y  | PreviousStruct=Y | Differences=N;
                        %let pfestructcompare_PassFail = FAIL;
                        %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_confirmedchange is Y but no structure differences found;

                    %end;
                    %else %do;
                        %put NOTE:[PXL] S2) ConfirmedChange=Y  | PreviousStruct=Y | Differences=Y;
                        %let pfestructcompare_PassFail = PASS - CONFIRMED STRUCTURE CHANGE;
                    %end;

                %end;
                %else %do;
                    %put NOTE:[PXL] S1) ConfirmedChange=Y  | PreviousStruct=N | Differences=N/A;
                    %let pfestructcompare_PassFail = PASS - FIRST RUN;
                %end;

            %end;
            %else %do;
                %if %eval(&previous_metadata_exists = 0) %then %do;
                    %put NOTE:[PXL] S4) ConfirmedChange=N  | PreviousStruct=N | Differences=N/A;
                    %let pfestructcompare_PassFail = FAIL;
                    %let pfestructcompare_ErrMsg = Input Parameter pfestructcompare_confirmedchange is N but no previous structure metadata found;
                %end;
                %else %do;
                    %if %eval(&pfestructcompare_NumDiff = 0) %then %do;
                        %put NOTE:[PXL] S5) ConfirmedChange=N  | PreviousStruct=Y | Differences=N;
                        %let pfestructcompare_PassFail = PASS - NO DIFFERENCES;
                    %end;
                    %else %do;
                        %put NOTE:[PXL] S6) ConfirmedChange=N  | PreviousStruct=Y | Differences=Y;
                        %let pfestructcompare_PassFail = FAIL;
                        %let pfestructcompare_ErrMsg =  Input Parameter pfestructcompare_confirmedchange is N but differences found;
                    %end;
                %end; 
            %end;

            %if %substr(&pfestructcompare_PassFail,1,4) = PASS %then %do;
                %put NOTE:[PXL] Create/Update previous metadata file to standards and archive;
                data MD.&expected_structure_ds(label="&pfestructcompare_RunDT");
                set current_metadata;
                run;

                data md_arch.&expected_structure_ds._&pfestructcompare_RunDT(label="&pfestructcompare_RunDT");
                set current_metadata;
                run;

                %let compared_data_updated = Yes - &expected_structure_ds %left(%trim(&pfestructcompare_RunDT));

            %end;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Create Listing Output;
    %put NOTE:[PXL] ***********************************************************************;

            %let pfestructcompare_ListName = &pfestructcompare_pathlist/&pfestructcompare_pxl_code &pfestructcompare_protocol PFESTRUCTCOMPARE Listing - &pfestructcompare_PassFail &pfestructcompare_RunDT..xls;

            data elisting_tab1;
                attrib
                    metadata length=$200 label="Metadata"
                    values   length=$200 label="Values"
                ;

                metadata = "Macro Info"; Values = ""; output;
                metadata = "Name:"; Values = "&pfestructcompare_MacName"; output;
                metadata = "Version Number:"; Values = "&pfestructcompare_MacVer"; output;
                metadata = "Version Date:"; Values = "&pfestructcompare_MacVerDT"; output;
                metadata = "Macro Location:"; Values = "&pfestructcompare_MacPath"; output;
                metadata = "Run By:"; Values = "%upcase(&sysuserid)"; output;
                metadata = "Date & Time Run:"; Values = "&pfestructcompare_RunDTE"; output;
                
                metadata = ""; Values = ""; output;
                metadata = "Global Macro Variables"; Values = ""; output;
                metadata = "DEBUG:"; Values = "&DEBUG"; output;
                metadata = "GMPXLERR:"; Values = "&GMPXLERR"; output;

                metadata = ""; Values = ""; output;
                metadata = "Input Parameters"; Values = ""; output;
                metadata = "pfestructcompare_metadata:"; Values = "&pfestructcompare_metadata"; output;
                metadata = "pfestructcompare_metadata previous data:"; Values = "&compared_data"; output;

                metadata = "pfestructcompare_confirmedchange:"; Values = "&pfestructcompare_confirmedchange"; output;
                metadata = "pfestructcompare_protocol:"; Values = "&pfestructcompare_protocol"; output;
                metadata = "pfestructcompare_pxl_code:"; Values = "&pfestructcompare_pxl_code"; output; 
                metadata = "pfestructcompare_pathlist:"; Values = "&pfestructcompare_pathlist"; output;
                metadata = "pfestructcompare_scrf:"; Values = "&pfestructcompare_scrf"; output;
                metadata = "pfestructcompare_scrf PATH:"; Values = "&path_scrf"; output;
                metadata = "pfestructcompare_scrf Symbolic Link current PATH (if used):"; Values = "&path_scrf_sl"; output;

                metadata = ""; Values = ""; output;
                metadata = "Output Listing"; Values = ""; output;
                metadata = "Output Path:"; Values = "&pfestructcompare_pathlist"; output;
                metadata = "Output File Name:"; Values = "&pfestructcompare_pxl_code &pfestructcompare_protocol PFESTRUCTCOMPARE Listing - &pfestructcompare_PassFail &pfestructcompare_RunDT..xls"; output;
                metadata = "Metadata Overwritten:"; Values = "&compared_data_updated"; output;

                metadata = ""; Values = ""; output;
                metadata = "Overall"; Values = ""; output;
                metadata = "Overall Structure Comparision: (PASS/FAIL)"; Values = "&pfestructcompare_PassFail"; output;
                metadata = "Number Differences Found:"; Values = "%left(%trim(&pfestructcompare_NumDiff))"; output;
                %if %str("&pfestructcompare_ErrMsg") ne %str("null") %then %do;
                    metadata = "Issues Note:"; Values = "&pfestructcompare_ErrMsg"; output;
                %end;
            run;

            data elisting_tab2;
                attrib
                    dataset       label="Dataset"
                    dataset_label label="Dataset Label"
                    variable      label="Variable"
                    type          label="Type"
                    length        label="Length"
                    format        label="Format"
                    label         label="Label"
                ;
                set current_metadata;
            run;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Output Listing;
    %put NOTE:[PXL] ***********************************************************************;    

        ods listing close;
        ods tagsets.excelxp file= "&pfestructcompare_ListName";

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
                row_repeat = "3");

            ods tagsets.excelxp options ( sheet_name = "Overview" Default_column_width= "40, 50");
                title j=l "&pfestructcompare_pxl_code &pfestructcompare_protocol Structure Compare Overview";
                proc report data = elisting_tab1 nowd; 
                    column metadata values; 
                run;

            ods tagsets.excelxp options ( sheet_name = "Metadata" Default_column_width= "6, 10, 10, 10, 10, 10, 20, 50");
                title j=l "&pfestructcompare_pxl_code &pfestructcompare_protocol Structure Compare Metadata";
                proc report data = elisting_tab2 nowd; 
                    column OBS dataset dataset_label variable type length format label; 
                    define OBS / computed;
                    compute OBS;
                        DSOBS + 1;
                        OBS = DSOBS;
                    endcompute;
                run;

            %if %eval(&pfestructcompare_NumDiff = 0) %then %do;
                data elisting_tab3;
                    attrib message label="Differences";
                    message = "No Differences Found";
                run;

                ods tagsets.excelxp options ( sheet_name = "Differences" Default_column_width= "60");
                    title j=l "&pfestructcompare_pxl_code &pfestructcompare_protocol Structure Compare Differences";
                    proc report data = elisting_tab3 nowd; 
                        column message; 
                    run;                 
            %end;
            %else %do;
                ods tagsets.excelxp options ( sheet_name = "Differences" Default_column_width= "6, 12, 10, 10, 10, 10, 10, 15, 50");
                    title j=l "&pfestructcompare_pxl_code &pfestructcompare_protocol Structure Compare Differences";
                    proc report data = elisting_tab3 nowd; 
                        column OBS diff dataset dataset_label variable type length format label; 
                        define OBS / computed;
                        compute OBS;
                            DSOBS + 1;
                            OBS = DSOBS;
                        endcompute;
                    run;
            %end;

        ods tagsets.excelxp close;
        ods listing;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Macro End and Cleanup;
    %put NOTE:[PXL] ***********************************************************************;
        %goto MacEnd;
        %MacErr:;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: Abnormal end to macro;
        %put %str(ERR)OR:[PXL] &pfestructcompare_MacName: See log for details;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %global GMPXLERR;
        %let GMPXLERR=1;

        %MacEnd:;
        title;
        footnote;
        OPTIONS fmterr quotelenmax;; * Reset Ignore format notes in log;
        OPTIONS missing=.;

        %if %sysfunc(exist(_dirlist)) %then %do;
            proc datasets lib=work nolist; delete _dirlist; quit; run;  
        %end;

        %if %sysfunc(exist(current_metadata)) %then %do;
            proc datasets lib=work nolist; delete current_metadata; quit; run;  
        %end;        

        %if %sysfunc(exist(previous_metadata)) %then %do;
            proc datasets lib=work nolist; delete previous_metadata; quit; run;  
        %end;

        proc sql noprint;
            select count(*) into: exists
            from sashelp.vslib
            where libname="MD";
        quit;
        %if %eval(&exists > 0) %then %do;
            libname MD clear;
        quit;
        %end;     

        proc sql noprint;
            select count(*) into: exists
            from sashelp.vslib
            where libname="MD_ARCH";
        quit;
        %if %eval(&exists > 0) %then %do;
            libname MD_ARCH clear;
        %end;

        %put INFO:[PXL]----------------------------------------------;
        %put INFO:[PXL] &pfestructcompare_MacName: Macro Completed; 
        %put INFO:[PXL] Output: ;
        %put INFO:[PXL]    pfestructcompare_PassFail = &pfestructcompare_PassFail;
        %put INFO:[PXL]    pfestructcompare_ListName = &pfestructcompare_ListName;
        %put INFO:[PXL]    pfestructcompare_ErrMsg = &pfestructcompare_ErrMsg;        
        %put INFO:[PXL]----------------------------------------------;

%mend pfestructcompare;

