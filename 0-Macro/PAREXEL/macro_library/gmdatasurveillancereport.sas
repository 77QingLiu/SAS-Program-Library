/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dmitry Kolosov  $LastChangedBy: kolosod $
  Creation Date:         01MAR2016 $LastChangedDate: 2016-04-23 05:22:50 -0400 (Sat, 23 Apr 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmdatasurveillancereport.sas $

  Files Created:         N/A

  Program Purpose:       Check datasets agains standard PAREXEL checks. 
                         The macro runs gmExecuteOpenCdisc with a custom configuration file used for
                         data surveillance (SOP-GPL-WW-012).

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                pathXptIn
      Default Value:     BLANK
      Description:       Path to a folder which contains XPT files. All datasets from this folder are validated.
                         Folder and file names are case-sensitive in Unix.

    Name:                libsIn
      Default Value:     BLANK
      Description:       Contains a library names. By default all datasets from these libraries are validated. To filter
                         specific datasets, parameters includePattern and excludePattern can be used.

    Name:                includePattern
      Default Value:     BLANK
      Description:       Regular expression which will be used to include datasets. Works only with libsIn parameter.

    Name:                excludePattern
      Default Value:     BLANK
      Description:       Regular expression which will be used to exclude datasets. Works only with libsIn parameter.
                         See the includePattern description for examples.

    Name:                pathOut
      Default Value:     &_global.
      Description:       Path to a folder where the report is saved.

    Name:                sendEmail
      Allowed Values:    1 | 0
      Default Value:     0
      Description:       Controls whether an e-mail is send to a user.

    Name:                splitChar
      Default Value:     @
      Description:       Split character to separate libsIn values.

  Macro Returnvalue:

      Description:       Macro does not return any values.

  Macro Dependencies:    gmExecuteOpenCdisc (called)
                         gmStart (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2195 $
-----------------------------------------------------------------------------*/

%macro gmDataSurveillanceReport( libsIn=
                                ,pathXptIn=
                                ,pathOut=&_global.
                                ,includePattern=
                                ,excludePattern=
                                ,sendEmail=0
                                ,splitChar=@
                               );

    %local survRep_libName;

    %* Initiate environment; 
    %let survRep_libName = %gmStart(headURL   = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmdatasurveillancereport.sas $
                 ,revision  = $Rev: 2195 $
                 ,libRequired = 1
                 ,checkMinSasVersion=9.2
                );

    %* Metadata for data governance checks;
    data &survRep_libName..survRep_survMetadata;
        length key value $200;
        key = "OpenCDISCVer";
        value = "2.1.0";
        output;
        key = "OpenCDISCConfig";
        value = "surveillance_sdtm.xml";
        output;
        key = "CDISCModel";
        value = "SDTM";
        output;
    run;

    %* Run data surveillance checks using OpenCDISC;    
    %gmExecuteOpenCdisc( libsIn=&libsIn
                        ,pathXptIn=&pathXptIn.
                        ,pathOut=&pathOut.
                        ,includePattern=&includePattern.
                        ,excludePattern=&excludePattern.
                        ,sendEmail=&sendEmail.
                        ,executeInBatch=1
                        ,splitChar=&splitChar.
                        ,autoLoadData=0
                        ,metadataIn=&survRep_libName..survRep_survMetadata
                       );

    %gmEnd(headUrl=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmdatasurveillancereport.sas $);
%mend;

