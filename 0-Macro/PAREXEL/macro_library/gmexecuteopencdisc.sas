/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dmitry Kolosov  $LastChangedBy: kolosod $
  Creation Date:         09SEP2014       $LastChangedDate: 2016-10-03 04:53:09 -0400 (Mon, 03 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecuteopencdisc.sas $

  Files Created:         OpenCDISC report when the pathOut parameter is specified.
                         * For datasets: <datasIn value>_openCDISC_validation_report.xls
                         * Other types (library, define, xpt): openCDISC_validation_report_<data type>_<timestamp>.xls
                         * See fileOut parameter description for more details;

  Program Purpose:       The macro runs OpenCDISC/Pinnacle 21 checks for datasets and sends the resulting
                         report by e-mail or save it on disk. All parameters are case-insensitive,
                         except for path and file names.
  Macro Parameters:

    Name:                datasIn
      Default Value:     BLANK
      Description:       Dataset source. Contains one or more datasets with or without library name, e.g., adsl@analysis.adlb@raw.lb.
                         In case a library is not specified, datasets are loaded from the WORK library.

    Name:                pathXptIn
      Default Value:     BLANK
      Description:       Path to a folder which contains XPT files. All datasets from this folder are validated.
                         Folder and file names are case-sensitive in Unix.


    Name:                fileDefine
      Default Value:     BLANK
      Description:       Name of the define file with path to it, e.g. /projects/proj123456/stats/primary/define/define.xml.
                         * When used together with the datasIn/pathXptIn/libsIn parameters,
                         define will be included in the validation to check datasets. When used alone, the define file will be validated.
                         Folder and file names are case-sensitive in Unix.

    Name:                libsIn
      Default Value:     BLANK
      Description:       Contains a library names. By default all datasets from these libraries are validated. To filter
                         specific datasets, parameters includePattern and excludePattern can be used.

    Name:                includePattern
      Default Value:     BLANK
      Description:       Regular expression which will be used to include datasets. Works only with libsIn parameter.
                         * Example values:
                         *  ADSL|ADLB|ADEX will force the macro to check only the 3 listed datasets.
                         *  ADEF.* will force the macro to check only datasets starting with ADEF.

    Name:                excludePattern
      Default Value:     BLANK
      Description:       Regular expression which will be used to exclude datasets. Works only with libsIn parameter.
                         See the includePattern description for examples.

    Name:                selectStandard
      Allowed Values:    ADaM|SDTM|SEND|Define
      Default Value:     See description
      Description:       Data model. Can be controlled by metadata key CDISCModel. If the argument is not specified:
                         * If ''datasIn'' contains a dataset starting with AD or value of ''libADaMIn'', then ADaM is used.
                         * If ''datasIn'' contains a dataset starting with SUPP, value of ''libSDTMIn'', or is 2 characters
                         long, then SDTM is used.
                         * When ''libsIn'' is used, all its members are analyzed using the approach above.

    Name:                pathOut
      Default Value:     BLANK
      Description:       Path to a folder where the report should be saved.

    Name:                fileOut   
      Allowed Values:    default \suffix=<text> | projarea \suffix=<text> | full \suffix=<text> | custom \suffix=<text> | user \suffix=<text>
      Default Value:     default
      Description:       Naming convention for report filename: 
                         # default:
                         * For datasets: <datasIn value>_openCDISC_validation_report.xls
                         * Other types (library, define, xpt): openCDISC_validation_report_<data type>_<timestamp>.xls
                         #- user: dependent on user executing macro, e.g. openCDISC_santac.pdf
                         #- projarea: dependant on project area, e.g. openCDISC_primary.pdf
                         #- full: dependent on project area and run date/time, e.g. openCDISC_primary_20170522T1405.pdf
                         #- custom: Requires the suffix option value. As a result file is named openCDISC_<suffix>.pdf.
                         #Option \suffix adds a text to the end of the filename. 

    Name:                sendEmail
      Allowed Values:    1 | 0
      Default Value:     See description
      Description:       Controls whether an e-mail is send to a user.
                         In interactive mode defaulted to 1,
                         In batch mode defaulted to 0.

    Name:                autoLoadData
      Allowed Values:    1 | 0
      Default Value:     1
      Description:       Controls whether datasets essential for checks are automatically loaded.
                         * For ADaM: DM and ADSL.
                         * For SDTM: DM, TA if there is EPOCH variable in checked datasets,
                         TV and SV if there is VISIT variable in checked datasets.

    Name:                libSDTMIn
      Default Value:     See description
      Description:       Name of SDTM library which will be used to autoload datasets for additional checks.
                         Can be specified in the metadata.
                         * For selectStandard = ADaM default value is RAW
                         * For selectStandard = SDTM default value is TRANSFER

    Name:                libADaMIn
      Default Value:     analysis
      Description:       Name of ADaM library which will be used to autoload datasets for additional checks.
                         Can be specified in the metadata.

    Name:                executeInBatch
      Allowed Values:    1 | 0
      Default Value:     See description
      Description:       Controls whether the macro is run in batch mode.
                         * If pathOut is missing, executeInBatch is defaulted to 0
                         * If pathOut is not missing, executeInBatch is defaulted to 1

    Name:                splitChar
      Default Value:     @
      Description:       Split character to separate datasIn/libsIn values.

    Name:                metadataIn
      Default Value:     metadata.global
      Description:       Dataset containing metadata.

  Macro Returnvalue:

      Description:       Macro does not return any values.

  Metadata Keys:

    Name:                pathOpenCDISC
      Description:       A folder with a custom version of OpenCdisc. Should be used only if a special
                         version of configuration/dictionaries are required. See the discussion section for
                         details.
      Dataset:           Global

    Name:                OpenCDISCVer
      Description:       OpenCDISC version to be used for validation. Currently allowed values:
                         1.4.1 | 1.5 | 2.0.0 | 2.0.1 | 2.0.2 | 2.1.0 | 2.1.1 | 2.1.2 | 2.1.3
      Dataset:           Global

    Name:                OpenCDISCConfig
      Description:       Configuration file. If no value is specified, the following values will be used,
                         depending on the model type:
                         * ADaM: (<2.0.0) config-adam-1.0.xml (>=2.0.0) ADaM 1.0.xml
                         * SDTM: (<2.0.0) config-sdtm-3.2.xml (>=2.0.0) SDTM 3.2.xml
                         * Define: (<2.0.0) config-define-2.0.xml (2.0.0 - 2.0.2) Define.xml 2.0.xml (2.1.0-2.1.3) Define.xml.xml
      Dataset:           Global

    Name:                pathPinnacle21
      Description:       Same as pathOpenCDISC.
      Dataset:           Global

    Name:                pinnacle21Ver
      Description:       Same as OpenCDISCVer.
      Dataset:           Global

    Name:                pinnacle21Config
      Description:       Same as OpenCDISCConfig.
      Dataset:           Global

    Name:                pathPinnacle21
      Description:       Same as pathOpenCDISC.
      Dataset:           Global

    Name:                ADaMCT
      Description:       ADaM Controlled Terminology date. If no value is specified, the following values will be used:
                         * 2011-07-22 (OpenCDISC version < 2.0.0), 2014-09-26 (2.0.0-2.1.0), 2016-03-25 (2.1.1-2.1.3)
      Dataset:           Global

    Name:                SDTMCT
      Description:       SDTM Controlled Terminology date. If no value is specified, the following values will be used:
                         * 2014-03-28 (OpenCDISC version < 2.0.0), 2014-09-26 (2.0.0), 2014-12-19 (2.0.1), 2015-06-26 (2.0.2)
                         2015-09-25 (2.1.0) 2016-03-25 (2.1.1) 2016-06-24 (2.1.2-2.1.3)
      Dataset:           Global

    Name:                MedDRAVer
      Description:       MedDRA version. Should correspond to the folder name in the MedDRA folder,
                         e.g, 17.1, 20.0.
      Dataset:           Global

    Name:                UNIIVer
      Description:       UNII version. Should correspond to the folder name in the UNII folder,
                         e.g, 2016-01-01
      Dataset:           Global

    Name:                NDFRTVer
      Description:       NDF-RT version. Should correspond to the folder name in the NDR-RT folder,
                         e.g, 2016-01-01
      Dataset:           Global

    Name:                SNOMEDVer
      Description:       SNOMED version. Should correspond to the folder name in the SNOMED folder,
                         e.g, 2016-01-01
      Dataset:           Global

    Name:                libSDTM
      Description:       Name of SDTM library which will be used to autoload datasets for additional checks.
      Dataset:           Global

    Name:                libADaM
      Default Value:     ANALYSIS
      Description:       Name of ADaM library which will be used to autoload datasets for additional checks.
      Dataset:           Global

    Name:                CDISCModel
      Default Value:     
      Allowed Values:    ADaM|SDTM|SEND|Define
      Description:       CDISC standard used for validation. 
      Dataset:           Global

  Macro Dependencies:    gmExecuteUnixCmd (called)
                         gmMessage (called)
                         gmCheckValueExists (called)
                         gmStart (called)
                         gmEnd (called)
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2686 $
-----------------------------------------------------------------------------*/
%macro gmExecuteOpenCdisc(datasIn=
                        ,fileDefine=
                        ,pathXptIn=
                        ,libsIn=
                        ,excludePattern=
                        ,includePattern=
                        ,selectStandard=
                        ,pathOut=
                        ,fileOut=default
                        ,sendEmail=
                        ,autoLoadData=1
                        ,libSDTMIn=
                        ,libADaMIn=
                        ,executeInBatch=
                        ,splitChar=@
                        ,metaDataIn = metadata.global
                       );


%let eoc_lib = %gmStart(
headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecuteopencdisc.sas $
,revision = $Rev: 2686 $
,libRequired = 1
        );
* Handle gmPxlErr in SAS 9.1;
%if &gmpxlerr. %then %return;

* Suppress warnings regarding long quoted text - to be removed once gmExecuteUnixCmd is updated;
%let eoc_noQuoteLenMax=%sysfunc(getoption(noQuoteLenMax));
option noQuoteLenMax;

*-------------------------------------------------------------
Basic parameter checks - check for single and double quotes
-------------------------------------------------------------;

%if %sysFunc(indexc(%str(&datasIn. &fileDefine. &pathXptIn. &libsIn. &excludePattern. &libsIn. 
                    &excludePattern. &includePattern. &selectStandard. &fileOut. &pathOut. &sendEmail. 
                    &autoLoadData. &libSDTMIn. &libADaMIn. &executeInBatch. &splitChar. &metaDataIn)
             ,%str(""'')))
%then %do;
        %gmMessage(linesOut=Parameter values must not contain single or double quotes., 
                   selectType = abort
                  );
%end;

*-------------------------------------------------------------
Read in metadata
-------------------------------------------------------------;

%if not %sysFunc(exist(&metaDataIn)) %then %do;
   %gmMessage(linesOut=Cannot find metadata file &metaDataIn..
                @You need to create a metadata library with dataset global. 
                @Create dataset metadata.global with variable KEY containing "OpenCDISCVer" or "Pinnacle21Ver"
                @and variable VALUE containing one of the OpenCDISC/Pinnacle21 %str(versions, e.g., 2.0.0) .
              ,selectType=abort);
%end;
%else %do;
    %local eoc_selectMedDRA eoc_selectSNOMED eoc_selectNDFRT eoc_selectUNII eoc_selectSDTMCT eoc_selectADaMCT eoc_selectVer eoc_selectConfig eoc_pathOpenCdiscIn;
    * To be replaced with gmGetMetadata;
    data _null_;
        set &metaDataIn;
        if upcase(key) in ( "MEDDRAVER","CDISCMODEL","ADAMCT","SDTMCT","PATHOPENCDISC","OPENCDISCCONFIG"
                           ,"OPENCDISCVER","LIBSDTM","LIBADAM","SNOMEDVER","NDFRTVER","UNIIVER"
                           ,"PINNACLE21VER","PINNACLE21CONFIG","PATHPINNACLE21"
                          ) 
        then do;
            select(upcase(key));
                when("LIBSDTM") do;
                    if missing("&libSDTMIn") then
                        call symput("libSDTMIn",strip(value));
                end;
                when("LIBADAM") do;
                    if missing("&libADaMIn") then
                        call symput("libADaMIn",strip(value));
                end;
                when("CDISCMODEL") do;
                    if missing("&selectStandard") then
                        call symput("selectStandard",strip(value));
                end;
                when("MEDDRAVER") call symput("eoc_selectMedDRA",strip(value));
                when("SNOMEDVER") call symput("eoc_selectSNOMED",strip(value));
                when("UNIIVER") call symput("eoc_selectUNII",strip(value));
                when("NDFRTVER") call symput("eoc_selectNDFRT",strip(value));
                when("ADAMCT") call symput("eoc_selectADaMCT",strip(value));
                when("SDTMCT") call symput("eoc_selectSDTMCT",strip(value));
                when("PATHOPENCDISC","PATHPINNACLE21") call symput("eoc_pathOpenCdiscIn",strip(value));
                when("OPENCDISCVER","PINNACLE21VER") call symput("eoc_selectVer",strip(value));
                when("OPENCDISCCONFIG","PINNACLE21CONFIG") call symput("eoc_selectConfig",strip(value));
            end;
        end;
    run;
%end;

*-------------------------------------------------------------
Define constants
-------------------------------------------------------------;

* Create eoc_eoc_selectDataType variable which will contains DATASET/LIBRARY/DEFINE/XPT values;
* Put all input sources into one variable;

%local eoc_selectDataType eoc_source eoc_appPath eoc_openCdiscFolder eoc_workFolder
       eoc_javaPath eoc_noDelimiterSource eoc_selectCT eoc_reportExtension eoc_softwareName
    ;

%if "&datasIn" ne "" %then %do;
    %let eoc_selectDataType = DATASET;
    %let eoc_source = &datasIn;
%end;
%else %if "&libsIn" ne "" %then %do;
    %let eoc_selectDataType = LIBRARY;
    %let eoc_source = &libsIn;
%end;
%else %if "&pathXptIn" ne "" %then %do;
    %let eoc_selectDataType = XPT;
    %let eoc_source = &pathXptIn;
%end;
%else %if "&fileDefine" ne "" %then %do;
    %let eoc_selectDataType = Define;
    %let eoc_source = &fileDefine;
%end;

* Set main OpenCDISC folder;
%let eoc_appPath = /opt/pxlcommon/stats/applications/;

* Software Name used as a prefix for report;
%if %symExist(ep21_softwareName) 
    and %superQ(eoc_selectVer) ne 1.4.1 
    and %superQ(eoc_selectVer) ne 1.5
    and %superQ(eoc_selectVer) ne 2.0.0 
    and %superQ(eoc_selectVer) ne 2.0.1 
    and %superQ(eoc_selectVer) ne 2.0.2 
%then %do;
    %let eoc_softwareName = &ep21_softwareName;
%end;
%else %do;
    %let eoc_softwareName = openCDISC;
%end;

* Set OpenCDISC folder and report format, contains configuration files and OpenCDISC libraries;
%if "&eoc_pathOpenCdiscIn" ne "" %then %do;
    %let eoc_openCdiscFolder = &eoc_pathOpenCdiscIn;
    %if "&eoc_selectVer" ne "2.0.0" and "%subStr(&eoc_selectVer,1,1)" = "2" %then %do; 
        %let eoc_reportExtension = xlsx;
    %end;
    %else %do;
        %let eoc_reportExtension = xls;
    %end;
%end;
%else %if "&eoc_selectVer" = "1.5" or "&eoc_selectVer" = "1.4.1" %then %do;
    %let eoc_openCdiscFolder = &eoc_appPath.opencdisc/1.5/;
    %let eoc_reportExtension = xls;
%end;
%else %if "&eoc_selectVer" = "2.0.0" %then %do;
    %let eoc_openCdiscFolder = &eoc_appPath.opencdisc/2.0.0/;
    %let eoc_reportExtension = xls;
%end;
%else %if "&eoc_selectVer" = "2.0.1" or "&eoc_selectVer" = "2.0.2" 
          or "&eoc_selectVer" = "2.1.0" or "&eoc_selectVer" = "2.1.1" 
          or "&eoc_selectVer" = "2.1.2" or "&eoc_selectVer" = "2.1.3" 
%then %do;
    %let eoc_openCdiscFolder = &eoc_appPath.opencdisc/&eoc_selectVer/;
    %let eoc_reportExtension = xlsx;
%end;
* Work folder, used to store XPT and Excel report;
%let eoc_workFolder = %sysFunc(pathname(&eoc_lib.))/gmexecuteopencdisc/;
* Path to Java;
%let eoc_javaPath=/opt/java7/bin/java;
* Source values without delimiters;
%let eoc_noDelimiterSource = %qSysFunc(prxChange(%qSysFunc(prxParse(s/^\W*\w+\.|^\W+//)),1,%superQ(eoc_source)));
%let eoc_noDelimiterSource = %qSysFunc(prxChange(%qSysFunc(prxParse(s/\W*\w+\.|\W+/_/)),-1,%superQ(eoc_noDelimiterSource)));

*-------------------------------------------------------------
Format arguments, e.g. ADAM -> ADaM, sdtm -> SDTM,
upcase case-insensetive arguments if needed
-------------------------------------------------------------;

data _null_;
    if upcase("&selectStandard") = "ADAM" then do;
        call symput("selectStandard","ADaM");
    end;
    else if upcase("&selectStandard") = "DEFINE" then do;
        call symput("selectStandard","Define");
    end;
    else do;
        call symput("selectStandard",strip(upcase("&selectStandard")));
    end;
    call symput("eoc_selectDataType",strip(upcase("&eoc_selectDataType")));
    call symput("eoc_originalSelectDataType",strip(upcase("&eoc_selectDataType")));
    * Do not upcase for define as Unix path is case sensetive;
    if upcase("&eoc_selectDataType") not in ("DEFINE","XPT") then do;
        call symput("eoc_source",strip(upcase("&eoc_source")));
    end;
    call symput("libADaMIn",strip(upcase("&libADaMIn")));
    call symput("libSDTMIn",strip(upcase("&libSDTMIn")));
run;

*-------------------------------------------------------------
Check if the macro should be run in batch mode
-------------------------------------------------------------;

%if "%sysFunc(getOption(sysIn))" ne "" %then %do;
    %if "&pathOut" ne "" and "&executeInBatch" = "" %then %do;
        %let executeInBatch = 1;
    %end;
    %else %if "&executeInBatch" = "" %then %do;
        %let executeInBatch = 0;
    %end;

    %if "&executeInBatch" = "0" %then %do;
        %gmMessage(linesOut = The macro is not executed in batch mode as
                              @the executeInBatch parameter is not set to 1 and pathOut is not specified.);
        * Stop the macro execution;
        %goTo eoc_exit;
    %end;
    * Default sendEmail to 0 in batch mode;
    %if "&sendEmail." = "" %then %do;
        %let sendEmail = 0;
    %end;
%end;
%else %do;
    * Default sendEmail to 1/executeInBatch to 0 in interactive mode;
    %if "&sendEmail." = "" %then %do;
        %let sendEmail = 1;
    %end;
    %if "&executeInBatch" = "" %then %do;
        %let executeInBatch = 0;
    %end;
%end;

*-------------------------------------------------------------
Check arguments
-------------------------------------------------------------;

* Check fileOut parameter;
%if not %sysFunc(prxMatch(%sysFunc(prxParse(/(default|user|projarea|full)(\s*\\suffix\s*=\s*\S+)?/i)),%superQ(fileOut)))
    and 
    not %sysFunc(prxMatch(%sysFunc(prxParse(/(custom)\s*\\suffix\s*=\s*\S+/i)),%superQ(fileOut)))
    %then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Incorrect value of the fileOut parameter: %superQ(fileOut),
           selectType = ABORT
          );
%end;

* Check files/pathis exist;

** Check pathOut folder exists;
%if "&pathOut" ne "" %then %do;
    %local eoc_pathOutExists;

    %let eoc_pathOutExists = %gmExecuteUnixCmd(cmds= [ -d "&pathOut" ] %str(&)%str(&) echo "Y" || echo "N", splitCharOut =  %str( ));

    %if "%trim(&eoc_pathOutExists)" ne "Y" %then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Folder &pathOut does not exist.,
           selectType = abort
          );
    %end;
%end;


** Check define file exists;
%if "&fileDefine" ne "" %then %do;
    %local eoc_fileDefineExists;

    %let eoc_fileDefineExists = %gmExecuteUnixCmd(cmds= [ -f "&fileDefine" ] %str(&)%str(&) echo "Y" || echo "N", splitCharOut =  %str( ));

    %if "%trim(&eoc_fileDefineExists)" ne "Y" %then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = File &fileDefine does not exist.,
           selectType = abort
          );
    %end;
%end;

* Check parameter values;
** Data source parameter is not missing;
%if not %gmCheckValueExists( codeLocation   = gmExecuteOpenCdisc/Parameter checks
                            , value          = &eoc_source.
                            , selectMethod   = BOOLEAN
                           )
%then %do;
    %gmMessage(linesOut=At least one of parameters datasIn/libsIn/pathXptIn/fileDefine must be provided.,
               selectType = abort
              );
%end;

** Only lib/dataset/xpt source is provided;
%if ("&eoc_source" ne %upcase("&libsIn") and "&libsIn" ne "")
    or
    ("&eoc_source" ne "&pathXptIn" and "&pathXptIn" ne "")
%then %do;
    %gmMessage(linesOut=Only one data source parameter can be used at a time.,
               selectType = abort
              );
%end;

** Check OpenCDISC version;
%if "&eoc_selectVer" ne "1.4.1"
    and "&eoc_selectVer" ne "1.5"
    and "&eoc_selectVer" ne "2.0.0"
    and "&eoc_selectVer" ne "2.0.1"
    and "&eoc_selectVer" ne "2.0.2"
    and "&eoc_selectVer" ne "2.1.0"
    and "&eoc_selectVer" ne "2.1.1"
    and "&eoc_selectVer" ne "2.1.2"
    and "&eoc_selectVer" ne "2.1.3"
    and "&eoc_pathOpenCdiscIn." = ""
%then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Wrong OpenCDISC version specified: &eoc_selectVer. ,
           selectType = abort
          );
%end;

** Verify additonal dictionaries are used in version supporting them;
%if (      %superQ(eoc_selectUNII)   ne 
        or %superQ(eoc_selectNDFRT)  ne 
        or %superQ(eoc_selectSNOMED) ne 
    ) 
    and 
    (
           "&eoc_selectVer" eq "1.4.1"
        or "&eoc_selectVer" eq "1.5"
        or "&eoc_selectVer" eq "2.0.0"
        or "&eoc_selectVer" eq "2.0.1"
        or "&eoc_selectVer" eq "2.0.2"
    )
%then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = UNII/NDF-RT/SNOMED can be used only in version 2.1.0 and above.,
           selectType = abort
          );
%end;

** Model Type;
%if "&selectStandard" ne "ADaM" and "&selectStandard" ne "SDTM"
    and "&selectStandard" ne "SEND" and "&selectStandard" ne "Define"
    and "&selectStandard" ne ""
%then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Wrong selectStandard value: &selectStandard. Valid values: ADaM/SDTM/SEND/Define. ,
           selectType = abort
          );
%end;

** Check flags;
%if "&sendEmail" ne "0" and "&sendEmail" ne "1"
%then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Wrong sendEmail value: &sendEmail. Valid values: 0/1. ,
           selectType = abort
          );
%end;

%if "&executeInBatch" ne "0" and "&executeInBatch" ne "1"
%then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Wrong executeInBatch value: &executeInBatch. Valid values: 0/1. ,
           selectType = abort
          );
%end;

%if "&autoLoadData" ne "0" and "&autoLoadData" ne "1"
%then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Wrong autoLoadData value: &autoLoadData. Valid values: 0/1. ,
           selectType = abort
          );
%end;

** Do not execute if no output required;
%if "&sendEmail" = "0" and "&pathOut" = "" %then %do;
        %gmMessage(
           linesOut = No output destination provided.,
           selectType = N
          );
    %goTo eoc_exit;
%end;

** Version-specific checks;
%if (   "&eoc_selectVer" eq "2.1.0" or "&eoc_selectVer" eq "2.1.1" 
     or "&eoc_selectVer" eq "2.1.2" or "&eoc_selectVer" eq "2.1.3"
    ) 
    and %superQ(selectStandard) eq Define %then %do;
    %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
               linesOut = Version &eoc_selectVer. does not support Define.XML validation
@ using CLI.
@ Use GUI version of Pinnacle 21 validated in PXL for that purpose.
               ,
               selectType = ABORT
    );
%end;

*-------------------------------------------------------------
Handle eMail parameter.
-------------------------------------------------------------;

%let eoc_eMail =;

%if "&sendEmail" eq "1" %then %do;

    %local eoc_emailExistsFlag;
    %local eoc_validEmailFlag;
    * Check e-mail file;
    %let eoc_eMailFileExists = %trim(%gmExecuteUnixCmd(cmds = [ -f  ~/.forward ] %str(&)%str(&) echo "Y" || echo "N", splitCharOut=%str( )));

    %if "&eoc_eMailFileExists" = "Y" %then %do;
        %let eoc_eMail = %gmExecuteUnixCmd(cmds=cat ~/.forward, splitCharOut =  %str( ));
    %end;

    ** Check e-mail value;
    %let eoc_validEmailFlag = %qSysFunc(prxMatch(%qSysFunc(prxParse(/^%bQuote([^@]*?@[^@]*$/))),%superQ(eoc_eMail)));

    %if "&eoc_validEmailFlag" ne "1" %then %do;
        %gmMessage(codeLocation = gmExecuteOpenCdisc/Parameter checks,
           linesOut = Cannot get your e-mail address. Please ask IT specialist to update the .forward file in your home directory.,
           selectType = NOTE
          );
        %let sendEmail = 0;
    %end;
%end;

*-------------------------------------------------------------
In case Library is specified, populate eoc_source with all
datasets in that library using excludePattern and
includePattern as filters
-------------------------------------------------------------;
%if "&eoc_selectDataType." = "LIBRARY" %then %do;


    data _null_;
        set sasHelp.vsTable(where = (prxMatch("/\b"
            %if "&splitChar." = "$" or "&splitChar." = "@" %then %do;
                ||strip(prxChange("s/\&splitChar./\b|/i",-1,"&eoc_source."))
            %end;
            %else %do;
                ||strip(prxChange("s/\Q&splitChar.\E/\b|/i",-1,"&eoc_source."))
            %end;
                                     ||"\b/i",libName)
                                    )
                           )
            end=lastRecord;

        * Exclude datasets using excludePattern;
        if not missing("&excludePattern.") then do;
            if prxMatch("/&excludePattern./i",strip(memName)) then do;
                excludeFn = 1;
            end;
        end;

        * Include only datasets specified in the include pattern;
        if not missing("&includePattern.") then do;
            if prxMatch("/&includePattern./i",strip(memName)) then do;
                includeFn = 1;
            end;
        end;
        else do;
            * If include pattern is not specified, include all datasets by default;
            includeFn = 1;
        end;

        length source $32000;
        retain source "";


        * Populate source with datasets;
        if excludeFn ne 1 and includeFn = 1 then do;
            source = catx("&splitChar.",source
                          ,upcase(strip(libName)) || "." || upcase(strip(memName))
                         );
        end;

        * Populate source with datasets and change data type to DATASET;
        if lastRecord then do;
            call symput("eoc_source",strip(source));
            call symput("eoc_selectDataType","DATASET");
        end;

    run;

%end;

*-------------------------------------------------------------
Detect model type based on data source values
-------------------------------------------------------------;

* Set libADaMIn to analysis if no value was provided;
%if "&libADaMIn" = "" %then %do;
    %let libADaMIn = ANALYSIS;
%end;

data _null_;
    * Set type to Define for define data type;
    if missing("&selectStandard.") and "&eoc_selectDataType." = "DEFINE" then do;
        call symput("selectStandard","Define");
    end;
    * Assign type to ADaM if the first argument starts with AD/ADaM library;
    else if missing("&selectStandard.")
       and ("&eoc_source." in: ("&libADaMIn.") or prxMatch("/^(ad\w+|[^.]+\.ad\w+)\b/i","&eoc_source.")
           )
    then do;
        call symput("selectStandard","ADaM");
    end;
    * Assign type to SDTM if the first argument starts with SAP/SDTM library or
    * dataset name is 2 letters;
    else if missing("&selectStandard.")
       and (strip("&eoc_source.") in: ("SUPP","&libSDTMIn.")
           or prxMatch("/^(\w{2}|[^.]+\.\w{2})\b/i","&eoc_source.")
           )
    then do;
        call symput("selectStandard","SDTM");
    end;
run;

* Set standard libSDTMIn to TRANSFER for SDTM type/ RAW for ADaM type;
%if "&selectStandard" = "SDTM" and "&libSDTMIn" = "" %then %do;
    %let libSDTMIn = TRANSFER;
%end;
%else %if "&selectStandard" = "ADaM" and "&libSDTMIn" = "" %then %do;
    %let libSDTMIn = RAW;
%end;

*-------------------------------------------------------------
Set default values.
-------------------------------------------------------------;

data _null_;
    * Configuration;
    if missing("&eoc_selectConfig.") and "&selectStandard" = "ADaM" then do;
        if "&eoc_selectVer." in: ("1") then do;
            call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/config-adam-1.0.xml");
        end;
        else if "&eoc_selectVer." in: ("2") then do;
            call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/ADaM 1.0.xml");
        end;
    end;
    else if missing("&eoc_selectConfig.") and "&selectStandard" = "SDTM" then do;
        if "&eoc_selectVer." in: ("1") then do;
            call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/config-sdtm-3.2.xml");
        end;
        else if "&eoc_selectVer." in: ("2") then do;
            call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/SDTM 3.2.xml");
        end;
    end;
    else if missing("&eoc_selectConfig.") and "&eoc_selectDataType" = "DEFINE" then do;
        if "&eoc_selectVer." in: ("1") then do;
            call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/config-define-2.0.xml");
        end;
        else if "&eoc_selectVer." in ("2.0.0","2.0.1","2.0.2") then do;
            call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/Define.xml 2.0.xml");
        end;
        else if "&eoc_selectVer." in ("2.1.0","2.1.1","2.1.2","2.1.3") then do;
            call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/Define.xml.xml");
        end;
    end;
    else if not missing("&eoc_selectConfig.") and not prxMatch("/\//","&eoc_selectConfig.") then do;
        call symput("eoc_selectConfig","&eoc_openCdiscFolder/config/&eoc_selectConfig.");
    end;
    * Controlled terminology;
    ** ADaM;
    if not missing("&eoc_selectADaMCT") and "&selectStandard" = "ADaM" then do;
        call symput("eoc_selectCT","&eoc_selectADaMCT.");
    end;
    else if "&selectStandard" = "ADaM" then do;
        if "&eoc_selectVer" =: "1." then do;
            call symput("eoc_selectCT","2011-07-22");
        end;
        if "&eoc_selectVer" in ("2.1.1" "2.1.2" "2.1.3") then do;
            call symput("eoc_selectCT","2016-03-25");
        end;
        else if "&eoc_selectVer" =: "2." then do;
            call symput("eoc_selectCT","2014-09-26");
        end;
    end;
    ** SDTM;
    else if not missing("&eoc_selectSDTMCT") and "&selectStandard" = "SDTM" then do;
        call symput("eoc_selectCT","&eoc_selectSDTMCT.");
    end;
    else if "&selectStandard" = "SDTM" then do;
        if "&eoc_selectVer" =: "1." then do;
            call symput("eoc_selectCT","2014-03-28");
        end;
        else if "&eoc_selectVer" = "2.0.0" then do;
            call symput("eoc_selectCT","2014-09-26");
        end;
        else if "&eoc_selectVer" = "2.0.1" then do;
            call symput("eoc_selectCT","2014-12-19");
        end;
        else if "&eoc_selectVer" = "2.0.2" then do;
            call symput("eoc_selectCT","2015-06-26");
        end;
        else if "&eoc_selectVer" = "2.1.0" then do;
            call symput("eoc_selectCT","2015-09-25");
        end;
        else if "&eoc_selectVer" = "2.1.1" then do;
            call symput("eoc_selectCT","2016-03-25");
        end;
        else if "&eoc_selectVer" in ("2.1.2" "2.1.3") then do;
            call symput("eoc_selectCT","2016-06-24");
        end;
    end;
    else if not missing("&eoc_selectSDTMCT.&eoc_selectADaMCT.") then do;
        call symput("eoc_selectCT",coalescec("&eoc_selectSDTMCT.","&eoc_selectADaMCT."));
    end;
run;

*-------------------------------------------------------------
Remove possible XPT/XLS files in the work folder
-------------------------------------------------------------;

* Create a working folder if it does not exists;
%gmExecuteUnixCmd(cmds=mkdir -p &eoc_workFolder);

%let rc = %gmExecuteUnixCmd(cmds= cd &eoc_workFolder $ rm -f &eoc_softwareName._validation_report.xls*, splitCharIn=$);

%if "&eoc_selectDataType" = "DATASET" or "&eoc_selectDataType" = "LIBRARY" %then %do;
    %let rc = %gmExecuteUnixCmd(cmds= cd &eoc_workFolder $ rm -f %str(*).xpt, splitCharIn=$);
%end;

*-------------------------------------------------------------
Dataset section
-------------------------------------------------------------;
%if "&eoc_selectDataType." = "DATASET" %then %do;

    *--------------------------------------------------------------
    Check all listed datasets exist
    Check if datasets required for checks are listed in the source
    --------------------------------------------------------------;

    %local eoc_noBaseForSupp eoc_listOfRequiredDatasets eoc_sortedDatasets eoc_notSortedDatasets;

    data _null_;
        * Check all listed datasets exist, identify those with SORTEDBY attribute;
        i = 1;
        length missingDatasets sortedDatasets notSortedDatasets $32000 dataset sortedBy $128;
        do while(scan("&eoc_source.",i,"&splitChar.") ne "");
            * Iterate through datasets;
            dataset = scan("&eoc_source.",i,"&splitChar.");
            dsId = open(dataset);
            * Identify datasets which does not exist ;
            if dsId <= 0 then do;
                missingDatasets = strip(missingDatasets) || " " || scan("&eoc_source.",i,"&splitChar.");
            end;
            * Identify datasets with sortedBy attribute;
            else do;
                sortedBy = attrc(dsId,"SORTEDBY");
                if not missing(sortedBy) then do;
                    sortedDatasets = strip(sortedDatasets) || " " || scan("&eoc_source.",i,"&splitChar.");
                end;
                else do;
                    notSortedDatasets = strip(notSortedDatasets) || " " || scan("&eoc_source.",i,"&splitChar.");
                end;
            end;
            rc = close(dsId);
            i = i + 1;
        end;
        call symput("eoc_missingDatasets",strip(missingDatasets));
        call symput("eoc_sortedDatasets",strip(sortedDatasets));
        call symput("eoc_notSortedDatasets",strip(notSortedDatasets));
        * Stop datastep execution in case there is at least one missing dataset;
        if not missing(missingDatasets) then do;
            stop;
        end;

        if "&autoLoadData" = "0" then do;
            * Stop if it is not required to autoload datasets;
            stop;
        end;

        * Datasets essential for OpenCDISC checks;
        length listOfRequiredDatasets $32000;
        ** ADaM;
        if "&selectStandard." = "ADaM" then do;
            * Check if ADSL is listed;
            if not prxMatch("/\bADSL\b/i","&eoc_source") then do;
                listOfRequiredDatasets = "&libADaMIn..ADSL";
            end;
            * Add DM;
            listOfRequiredDatasets =  strip(listOfRequiredDatasets) || " &libSDTMIn..DM";
        end;
        ** SDTM;
        if "&selectStandard." = "SDTM" then do;
            ** Check if DM is listed;
            if  not prxMatch("/\bDM\b/i","&eoc_source") then do;
                * If not listed, then it is always required;
                listOfRequiredDatasets = "&libSDTMIn..DM";
            end;

            ** Check if SV is listed;
            if  not prxMatch("/\bSV\b/i","&eoc_source") then do;
                * If not listed, then it is required only if there is a VISIT variable in
                * checked datasets;
                svListedFn = 0;
            end;
            else do;
                svListedFn = 1;
            end;

            ** Check if TV is listed;
            if  not prxMatch("/\bTV\b/i","&eoc_source") then do;
                * If not listed, then it is required only if there is a VISIT variable in
                * checked datasets;
                tvListedFn = 0;
            end;
            else do;
                tvListedFn = 1;
            end;

            ** Check if TA is listed;
            if  not prxMatch("/\bTA\b/i","&eoc_source") then do;
                * If not listed, then it is required only if there is a EPOCH variable in
                * checked datasets;
                taListedFn = 0;
            end;
            else do;
                taListedFn = 1;
            end;

            * If either TV or SV is listed, then both are required;
            if tvListedFn or svListedFn then do;
                if not tvListedFn then do;
                    listOfRequiredDatasets =  strip(listOfRequiredDatasets) || " &libSDTMIn..TV";
                end;
                if not svListedFn then do;
                    listOfRequiredDatasets =  strip(listOfRequiredDatasets) || " &libSDTMIn..SV";
                end;
            end;
            * If both are not listed, then check if there is any dataset with VISIT/EPOCH variables;
            ** Avoid SASHELP usage as it is slow;
            else do;
                i = 1;
                visitFound = 0;
                epochFound = 0;
                do while(scan("&eoc_source.",i,"&splitChar.") ne "");
                    * Iterate through datasets and check for required variable;
                    dsId = open(scan("&eoc_source.",i,"&splitChar."));
                    if varNum(dsId,"visit") > 0 and not visitFound then do;
                        * VISIT variable found, add SV and TV to the list;
                        listOfRequiredDatasets =  strip(listOfRequiredDatasets) || " &libSDTMIn..SV";
                        listOfRequiredDatasets =  strip(listOfRequiredDatasets) || " &libSDTMIn..TV";
                        visitFound = 1;
                    end;
                    if varNum(dsId,"epoch") > 0 and not epochFound then do;
                        * EPOCH variable found, add TA to the list;
                        listOfRequiredDatasets =  strip(listOfRequiredDatasets) || " &libSDTMIn..TA";
                        epochFound = 1;
                    end;
                    if epochFound and visitFound then do;
                        * Exit the loop;
                        rc = close(dsId);
                        leave;
                    end;
                    rc = close(dsId);
                    i = i + 1;
                end;
            end;

            * Check if there is no base dataset for SUPPxx;
            i = 1;
            length  noBaseForSupp $1024 basePart $128;
            do while(scan("&eoc_source.",i,"&splitChar.") ne "");
                * Iterate through datasets;
                dataset = scan("&eoc_source.",i,"&splitChar.");
                if prxMatch("/SUPP/i",dataset) then do;
                    basePart = prxChange("s/.*SUPP(.+).*/$1/i",1,strip(dataset));
                    if not prxMatch("/\b"||strip(basePart)||"\b/","&eoc_source.") then do;
                        * Add the missing base name for a message;
                        noBaseForSupp = strip(noBaseForSupp) || " " || strip(basePart);
                        * Add the missing base dataset to the required list;
                        listOfRequiredDatasets = strip(listOfRequiredDatasets) || " &libSDTMIn.."
                                                 || strip(basePart);
                    end;
                end;
                i = i + 1;
            end;
        end;

        call symput("eoc_noBaseForSupp",strip(noBaseForSupp));
        call symput("eoc_listOfRequiredDatasets",strip(listOfRequiredDatasets));

    run;

    %if "&eoc_missingDatasets" ne "" %then %do;
        %gmMessage(linesOut = The following datasets are not found or corrupted: &eoc_missingDatasets..
                   , selectType=abort);
    %end;

    %if "&eoc_noBaseForSupp" ne "" %then %do;
        %gmMessage(linesOut = SUPP dataset does not have a corresponding base dataset specified for: &eoc_noBaseForSupp..
                              @These datasets are loaded from the &libSDTMIn. library.
                   , selectType=N);
    %end;
    *-------------------------------------------------------------
    Create XPT files for datasets listed in the source argument
    -------------------------------------------------------------;

    %local eoc_rc eoc_dsId eoc_i;

    * For datasets without SORTEDBY attribute perform direct copy to XPT;
    %let eoc_i = 1;
    %do %while (%scan(&eoc_notSortedDatasets,&eoc_i.,%str( )) ne);

        %let eoc_dataset = %scan(&eoc_notSortedDatasets,&eoc_i.,%str( ));

        * Check the dataset contains library name;
        %if %scan(&eoc_dataset.,2,.) ne %then %do;
            %let eoc_libds = %scan(&eoc_dataset.,1,.);
            %let eoc_ds = %scan(&eoc_dataset.,2,.);
        %end;
        %else %do;
            %let eoc_libds = work;
            %let eoc_ds = &eoc_dataset;
            %gmMessage(codeLocation = gmExecuteOpenCdisc/Dataset export,
                       linesOut = Dataset &eoc_dataset is loaded from the WORK library.,
                       selectType = N
                      );
        %end;

        * Create an xpt file;
        libname eocXptL xport "&eoc_workFolder/&eoc_ds..XPT";

        proc copy in = &eoc_libds. out = eocXptL ;
            select &eoc_ds.;
        run;

        libname eocXptL clear;
        %let eoc_i = %eval(&eoc_i.+1);
    %end;

    * For datasets with SORTEDBY attribute, remove attribute first and then copy to XPT;
    * Otherwise PROC COPY produces a WARNING that this attribute cannot be saved;
    %let eoc_i = 1;
    %do %while (%scan(&eoc_sortedDatasets,&eoc_i.,%str( )) ne);

        %let eoc_dataset = %scan(&eoc_sortedDatasets,&eoc_i.,%str( ));

        * Check the dataset contains library name;
        %if %scan(&eoc_dataset.,2,.) ne %then %do;
            %let eoc_libds = %scan(&eoc_dataset.,1,.);
            %let eoc_ds = %scan(&eoc_dataset.,2,.);
        %end;
        %else %do;
            %let eoc_libds = work;
            %let eoc_ds = &eoc_dataset;
            %gmMessage(codeLocation = gmExecuteOpenCdisc/Dataset export,
                       linesOut = Dataset &eoc_dataset is loaded from the WORK library.,
                       selectType = N
                      );
        %end;

        * Remove SORTEDBY attribute;
        data &eoc_lib..&eoc_ds.(sortedBy=_null_ compress=Y);
            set &eoc_libds..&eoc_ds.;
        run;

        * Create an xpt file;
        libname eocXptL xport "&eoc_workFolder/&eoc_ds..XPT";

        proc copy in = &eoc_lib. out = eocXptL ;
            select &eoc_ds.;
        run;

        libname eocXptL clear;
        %let eoc_i = %eval(&eoc_i.+1);
    %end;

    *---------------------------------------------------------------
    Create XPT for datasets which are essential for OpenCDISC checks
    ---------------------------------------------------------------;
    %let eoc_i = 1;
    %do %while (%scan(&eoc_listOfRequiredDatasets,&eoc_i.,%str( )) ne);

        %let eoc_dataset = %scan(&eoc_listOfRequiredDatasets,&eoc_i.,%str( ));

        * Check the dataset contains library name;
        %if %scan(&eoc_dataset.,2,.) ne %then %do;
            %let eoc_libds = %scan(&eoc_dataset.,1,.);
            %let eoc_ds = %scan(&eoc_dataset.,2,.);
        %end;
        %else %do;
            %let eoc_libds = work;
            %let eoc_ds = &eoc_dataset;
        %end;

        %if %sysFunc(exist(&eoc_libds..&eoc_ds.)) %then %do;
            * Check whether the dataset has the SORTEDBY attribute;
            %let eoc_dsId = %sysFunc(open(&eoc_libds..&eoc_ds.));
            %if %qSysFunc(attrc(&eoc_dsId.,SORTEDBY)) ne %then %do;
                * Copy the dataset to a temporary library, remove SORTEDBY attribute, and reassign library;
                data &eoc_lib..&eoc_ds.(sortedBy=_null_ compress=Y);
                    set &eoc_libds..&eoc_ds.;
                run;
                %let eoc_libds = &eoc_lib.;
            %end;
            %let eoc_rc = %sysFunc(close(&eoc_dsId.));

            * Create an xpt file;
            libname eocXptL xport "&eoc_workFolder/&eoc_ds..XPT";

            proc copy in = &eoc_libds. out = eocXptL ;
                select &eoc_ds.;
            run;

            libname eocXptL clear;
        %end;
        %else %do;
            %gmMessage(linesOut = Dataset &eoc_libds..&eoc_ds. is not found. Some OpenCDISC checks will not be performed.,
                       selectType = N
                      );
        %end;

        %let eoc_i = %eval(&eoc_i.+1);
    %end;
%end;

*-------------------------------------------------------------
Create commands for OpenCDISC CLI
-------------------------------------------------------------;

%local eoc_openCdiscCmd;
%local eoc_eMailCmd;
%local eoc_eMailLogCmd;

data _null_;
    length openCdiscCmd eMailCmd eMailLogCmd $32000
           subject source define report reportFileName $1024 fileNameSuffix $256 medDra snomed unii ndfrt $200 ;

    * Source;
    if "&eoc_selectDataType" = "DATASET" then do;
        source =  " -source=""&eoc_workFolder/" ||'%str(*).xpt"';
    end;
    else if "&eoc_selectDataType" = ("DEFINE") then do;
        source =  " -source=""&eoc_source.""";
    end;
    else if "&eoc_selectDataType" = ("XPT") then do;
        source =  " -source=""&eoc_source./" ||'%str(*).xpt"';
    end;

    * MedDRA configuration;
    if not missing("&eoc_selectMedDRA.") then do;
        medDra = " -config:meddra=""&eoc_selectMedDRA.""";
    end;

    if not missing("&eoc_selectSNOMED.") then do;
       snomed = " -config:snomed=""&eoc_selectSNOMED.""";
    end;

    if not missing("&eoc_selectUNII.") then do;
       unii = " -config:unii=""&eoc_selectUNII.""";
    end;

    if not missing("&eoc_selectNDFRT.") then do;
       ndfrt = " -config:ndfrt=""&eoc_selectNDFRT.""";
    end;

    * Define file;
    if not missing("&fileDefine.") then do;
        define = " -config:define=""&fileDefine.""";
    end;

    * Output filename;
    ** Get suffix value if it was provided;
    fileNameSuffix = " ";
    if prxMatch("/\\suffix/","&fileOut") then do;
        fileNameSuffix = "_" || strip(prxChange("s/\w+\s*\\suffix\s*=\s*(.*)/$1/i",1,"&fileOut"));
    end;
    if lowcase("&fileOut") =: "default" then do;
        if not missing("&pathOut.") and "&eoc_originalSelectDataType" = "DATASET" then do;
            reportFileName = "&eoc_noDelimiterSource._&eoc_softwareName._validation_report"
                             || strip(fileNameSuffix) || ".&eoc_reportExtension.";
        end;
        else if not missing("&pathOut.")
                and "&eoc_originalSelectDataType" in ("LIBRARY","DEFINE","XPT")
        then do;
            reportFileName = "&eoc_softwareName._validation_report_%lowcase(&eoc_originalSelectDataType.)_"
                             || trim(left(put(date(),yymmddn8.)))||'T'||compress(tranwrd(put(time(),tod5.),':',''))
                             || strip(fileNameSuffix) || ".&eoc_reportExtension.";
        end;
        else do;
            reportFileName = "&eoc_softwareName._validation_report"
                             || strip(fileNameSuffix) || ".&eoc_reportExtension.";
        end;
    end;
    else if lowcase("&fileOut") =: "user" then do;
        reportFileName = "&eoc_softwareName._&sysUserId."
                         || strip(fileNameSuffix) || ".&eoc_reportExtension.";
    end;
    else if lowcase("&fileOut") =: "projarea" then do;
        reportFileName = "&eoc_softwareName._"||symGet("_type")
                         || strip(fileNameSuffix) || ".&eoc_reportExtension.";
    end;
    else if lowcase("&fileOut") =: "full" then do;
        reportFileName = "&eoc_softwareName._"||symGet("_type") || "_" 
                         || put(date(), yymmddn8.)||"T"||compress(cats(tranwrd(put(time(), tod5.), ":", "")))
                         || strip(fileNameSuffix) ||".&eoc_reportExtension.";
    end;
    else if lowcase("&fileOut") =: "custom" then do;
        reportFileName = "&eoc_softwareName." || strip(fileNameSuffix) || ".&eoc_reportExtension.";
    end;
    else do;
        reportFileName = "&eoc_softwareName._validation_report."
                         || strip(fileNameSuffix) || "&eoc_reportExtension.";
    end;
    * Add output folder;   
    if not missing("&pathOut.") then do;
        reportFileName = "&pathOut./"||strip(reportFileName);
    end;
    else do;
        reportFileName = "&eoc_workFolder./"||strip(reportFileName);
    end;
    * Form report parameter;
    report = ' -report="'||strip(reportFileName)||'"';

    * E-mail subject;
    if "&eoc_originalSelectDataType" = "DATASET" then do;
        subject = prxChange("s/[^\w\.]/ /",-1,"&eoc_source.");
    end;
    else if "&eoc_originalSelectDataType" = "LIBRARY" then do;
        subject = prxChange("s/[^\w\.]/ /",-1,"&libsIn.");
    end;
    else do;
        subject = "&eoc_source.";
    end;

    openCdiscCmd =
      "LD_LIBRARY_PATH=/opt/java7/jre/lib:/opt/java7/jre/lib/IA64:/opt/java7/jre/lib/IA64N/server;"||
      "export LD_LIBRARY_PATH;"||
      "&eoc_javaPath -Xms256m -Xmx1024m -jar &eoc_openCdiscFolder/lib/validator-cli-&eoc_selectVer..jar" ||
      " -task=Validate" ||
      " -type=&selectStandard." ||
      trim(source) ||
      " -source:type=SAS" ||
      " -config=""&eoc_selectConfig.""" ||
      " -config:cdisc=""&eoc_selectCT.""" ||
      trim(
          trim(report) ||
          trim(medDra) ||
          trim(snomed) ||
          trim(unii) ||
          trim(ndfrt) ||
          trim(define) 
          ) ||
      " -report:type=Excel" ||
      " -report:overwrite=Yes" ||
      " > &eoc_workFolder/opencdisc.log || echo 'Execution failed.'"
    ;

    * In version 2.0.2 jar file is named with 2.0.1 in its name, update the command to handle it;
    openCdiscCmd = prxChange("s/validator-cli-2\.0\.2/validator-cli-2.0.1/",1,strip(openCdiscCmd));

    eMailCmd= "uuencode "||'"'||strip(reportFileName) || '" ' || strip(prxChange("s/(.*\/)?([^\/]+)/$2/",1,strip(reportFileName))) ||
              " | mailx -m -s '[Macro Execution] " || propCase("&eoc_softwareName.") 
                           || " report for "||strip(subject)||"' '"||strip("&eoc_eMail")||"'"
    ;

    eMailLogCmd= "perl -i -pe 's/\n/\r\n/' '&eoc_workFolder/opencdisc.log' $ "||
              " uuencode "||'"'||"&eoc_workFolder/opencdisc.log"||'" opencdisc.log'||
              " | mailx -m -s '[Macro Execution] " || propCase("&eoc_softwareName.") 
                           || " log for "||strip(subject)||"' '"||strip("&eoc_eMail")||"'"
    ;

    call symPut("eoc_openCdiscCmd",strip(openCdiscCmd));
    call symPut("eoc_eMailCmd",strip(eMailCmd));
    call symPut("eoc_eMailLogCmd",strip(eMailLogCmd));
run;

* Run OpenCDISC;
%let eoc_rc = %gmExecuteUnixCmd(cmds=%bquote(&eoc_openCdiscCmd),splitCharIn=`);

* Check the validation went as expected;
%let eoc_rc = %gmExecuteUnixCmd(cmds=grep -i "The validation has completed." "&eoc_workFolder/opencdisc.log" || echo "FALSE");

* If not, report and send an e-mail with log if needed;
%if not %index("&eoc_rc.",The validation has completed.) %then %do;
    %if "&sendEmail" = "1" %then %do;
        %let eoc_rc = %gmExecuteUnixCmd(cmds= &eoc_eMailLogCmd, splitCharIn=$);
        %gmMessage(linesOut=The validation was not completed. The log was sent to your e-mail.
                   , selectType=abort);
    %end;
    %else %do;
        %gmMessage(linesOut=The validation was not completed. Set gmDebug to 1 and review the log:
                            @ &eoc_workFolder/opencdisc.log.
                   , selectType=abort);
    %end;
%end;
%else %do;
    * Send an e-mail with the report attached;
    %if "&sendEmail" = "1" %then %do;
        %let eoc_rc = %gmExecuteUnixCmd(cmds= &eoc_eMailCmd, splitCharIn=`);
    %end;
%end;

*-------------------------------------------------------------
Clean-up
-------------------------------------------------------------;
%if &gmDebug ne 1 %then %do;
    %let eoc_rc = %gmExecuteUnixCmd(cmds= cd &eoc_workFolder/.. $ rm -rf gmexecuteopencdisc, splitCharIn=$);
%end;

*-------------------------------------------------------------
Inform the user about end of the execution
-------------------------------------------------------------;
%gmMessage(linesOut=gmExecuteOpenCdisc has finished execution., splitChar=$);
%if "&sendEmail" = "1" %then %do;
    %gmMessage(linesOut=E-mail with the report was sent to &eoc_eMail., splitChar=$);
%end;
%if "&pathOut" ne "" %then %do;
    %gmMessage(linesOut=OpenCDISC report was saved to &pathOut., splitChar=$);
%end;

%eoc_exit:
* Reset options;
options &eoc_noQuoteLenMax;

%gmEnd(headURL =
$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecuteopencdisc.sas $
);

%mend;
