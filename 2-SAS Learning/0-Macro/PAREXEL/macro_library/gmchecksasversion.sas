/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD
 
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee 
  PXL Study Code:        80386
 
  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------
 
  Author:                Tristan Denness $LastChangedBy: kolosod $
  Creation Date:         12JUL2012       $LastChangedDate: 2015-08-06 13:13:13 -0400 (Thu, 06 Aug 2015) $
 
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmchecksasversion.sas $
 
  Files Created:         N/A                     
 
  Program Purpose:       gmCheckSasVersion cross-checks the open SAS session against 
                         a user defined version number and aborts SAS if the incorrect
                         version is being used.  This is to be used in project setup to
                         avoid the wrong version of SAS being used on a study. 
 
                         This macro is PAREXEL's intellectual property and shall 
                         not be used outside of contractual obligations without 
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:
 
    Name:                CheckSasVersion
      Default Value:     REQUIRED
      Description:       Select the version of SAS that is required.

  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)
 
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 914 $
-----------------------------------------------------------------------------*/
                                     
%MACRO gmCheckSasVersion(CheckSasVersion=);
  /* Print version and location information */
  %gmStart( headURL   = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmchecksasversion.sas $
          , revision  = $Rev: 914 $
  )
  %IF &gmpxlerr. %THEN %RETURN;

  %LOCAL gmCheckSasVersion_SLine1 gmCheckSasVersion_SLine2 gmCheckSasVersion_SLine3 gmCheckSasVersion_ULine1 
           gmCheckSasVersion_ULine2 gmCheckSasVersion_ULine3 gmCheckSasVersion_version gmCheckSasVersion_ULine4;
  
  %LET gmCheckSasVersion_version=%QSYSFUNC(COMPRESS(%BQUOTE(&CheckSasVersion.),%str(%'%")));
  
  %IF "&sysVer." = "%BQUOTE(&gmCheckSasVersion_version.)" %THEN %DO;
    %gmEnd(headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmchecksasversion.sas $);
    %RETURN;
  %END;
  %ELSE %DO;
    %IF "%BQUOTE(&gmCheckSasVersion_version.)"= "" %THEN %DO;
      %LET gmCheckSasVersion_SLine1=The SAS version for the project was not specified in gmchecksasversion.;
  %END;
  %ELSE %DO;
      %LET gmCheckSasVersion_SLine1=The SAS version %BQUOTE(&sysVer.) is invalid for the project.;
  %END;
    %LET gmCheckSasVersion_SLine2=The current version is &sysVer. therefore SAS is shutting down.;
    %LET gmCheckSasVersion_ULine1=echo ERROR:[PXL];
    %LET gmCheckSasVersion_ULine2=echo ERROR:[PXL] &gmCheckSasVersion_SLine1.;
    %LET gmCheckSasVersion_ULine3=echo ERROR:[PXL] &gmCheckSasVersion_SLine2.;
    %IF %LENGTH(%QSYSFUNC(COMPRESS(%BQUOTE(&gmCheckSasVersion_version.),".kd"))) = 2 %THEN %DO;
      %LET gmCheckSasVersion_SLine3=Start SAS with sasXX [e.g. sas%QSYSFUNC(COMPRESS(%BQUOTE(&gmCheckSasVersion_version.),".kd"))] or multirunXX [e.g. multirun%QSYSFUNC(COMPRESS(%BQUOTE(&gmCheckSasVersion_version.),".kd"))];
      %LET gmCheckSasVersion_ULine4=echo ERROR:[PXL] &gmCheckSasVersion_SLine3.;
    %END;
    %ELSE %DO;
      %LET gmCheckSasVersion_SLine3=Start SAS with sasXX [e.g. sas92] or multirunXX [e.g. multirun92];
      %LET gmCheckSasVersion_ULine4=echo ERROR:[PXL] &gmCheckSasVersion_SLine3.;
    %END;
    %gmMessage(selectType=E, linesOut=&gmCheckSasVersion_SLine1.@&gmCheckSasVersion_SLine2.@&gmCheckSasVersion_SLine3.)
    %SYSCALL SYSTEM(gmCheckSasVersion_ULine1);        
    %SYSCALL SYSTEM(gmCheckSasVersion_ULine2);       
    %SYSCALL SYSTEM(gmCheckSasVersion_ULine3);   
    %SYSCALL SYSTEM(gmCheckSasVersion_ULine4);   
    %ABORT ABeND;
  %END;
%MEND gmCheckSasVersion;

