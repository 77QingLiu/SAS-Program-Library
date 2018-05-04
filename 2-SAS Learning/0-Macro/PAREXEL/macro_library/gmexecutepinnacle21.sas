/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dmitry Kolosov  $LastChangedBy: kolosod $
  Creation Date:         09SEP2014       $LastChangedDate: 2016-10-03 04:53:09 -0400 (Mon, 03 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecutepinnacle21.sas $

  Files Created:         Pinnacle21 report when the pathOut parameter is specified.
                         * For datasets: <datasIn value>_pinnacle21_validation_report.xls
                         * Other types (library, define, xpt): pinnacle21_validation_report_<data type>_<timestamp>.xls
                         * See fileOut parameter description for more details;

  Program Purpose:       The macro runs OpenCDISC/Pinnacle 21 checks for datasets and sends the resulting
                         report by e-mail or save it on disk. All parameters are case-insensitive,
                         except for path and file names.
                         # This macro is a shell for [[gmExecuteOpenCdisc]] macro.

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
      Description:       Pinnacle21 version to be used for validation. Currently allowed values:
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
%macro gmExecutePinnacle21( datasIn=
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

%gmStart(
headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecutepinnacle21.sas $
,revision = $Rev: 2686 $
        );
* Handle gmPxlErr in SAS 9.1;
%if &gmpxlerr. %then %return;

%local ep21_softwareName;
%let ep21_softwareName = pinnacle21;

%* Call gmExecuteOpenCdisc;
%gmExecuteOpenCdisc( datasIn        = &datasIn.
                    ,fileDefine     = &fileDefine.
                    ,pathXptIn      = &pathXptIn.
                    ,libsIn         = &libsIn.
                    ,excludePattern = &excludePattern.
                    ,includePattern = &includePattern.
                    ,selectStandard = &selectStandard.
                    ,pathOut        = &pathOut.
                    ,fileOut        = &fileOut.
                    ,sendEmail      = &sendEmail.
                    ,autoLoadData   = &autoLoadData.
                    ,libSDTMIn      = &libSDTMIn.
                    ,libADaMIn      = &libADaMIn.
                    ,executeInBatch = &executeInBatch.
                    ,splitChar      = &splitChar.
                    ,metaDataIn     = &metaDataIn.
                   );

%gmEnd(headURL =
$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmexecutepinnacle21.sas $
);

%mend;
