/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Tristan Denness $LastChangedBy: kolosod $
  Creation Date:         27JUL2011       $LastChangedDate: 2016-07-11 04:30:14 -0400 (Mon, 11 Jul 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcompare.sas $

  Files Created:         &pathOut.&outputQcPrefix.<datasetname>.txt
                         work.&CompareData..sas7bdat

  Program Purpose:       To produce files required for standardised electronic
                         QC of SAS datasets.  Macro will compare two datasets,
                         output a proc compare with standard titles and options.
                         The macro will also check for and present (up to 50) duplicate
                         observations if a ID list is provided.  The variable
                         order within the datasets can also be compared when
                         checkVarOrder=0 is specified.  A series of checks are
                         performed on the input parameters, if issues are found
                         gmpxlerr will be set to 1 and the output will be omitted.
                         Note that differences in the compare does not result in
                         gmpxlerr=1.  A output macro variable (gmCompareSysInfoResult)
                         is created containing the contents of  sysInfo from the
                         proc compare.  GRPX variables are excluded from the Proc
                         Compare.  Output file and QC dataset names are governed by 
                         prefixes defined in metadataIn (outputQcPrefix and dsQcPrefix)
                         where available.

                         Requires study setup.sas to have the following defined:
                         * &_CLIENT
                         * &_TIMS
                         * &_PROJECT
  Macro Parameters:

    Name:                pathOut
      Allowed Values:    Any valid and existing UNIX path
      Default Value:     BLANK
      Description:       Directory where QC txt output is stored.  If not specified 
                         the output will be routed to the same area SAS is started from.

    Name:                dataMain
      Allowed Values:    Library.dataset
      Default Value:     REQUIRED
      Description:       Library.dataset to be eQCed

    Name:                varsId
      Allowed Values:    '@' delimited list
      Default Value:     BLANK
      Description:       ID variables ('@' delimited) for proc compare

    Name:                checkVarOrder
      Allowed Values:    1|0
      Default Value:     0
      Description:       1 to check that the sequence of variables in the
                         production and QC dataset match.
                         Differences are presented in the output window/file

    Name:                libraryQC
      Allowed Values:    Library
      Default Value:     REQUIRED
      Description:       Location of input QC dataset

    Name:                transpose
      Allowed Values:    1|0
      Default Value:     0
      Description:       1 sets the transpose option on the PROC COMPARE

    Name:                compareData
      Allowed Values:    A valid dataset name including library
      Default Value:     BLANK
      Description:       Dataset name of the datasets created in the OUT option
                         of the PROC COMPARE
 
    Name:                selectDataType
      Allowed Values:    '@' delimited list.
      Default Value:     BLANK
      Description:       Control the output data set from the PROC COMPARE. Valid values as follows:
                         * OUTALL: Write an observation for each observation in the BASE= and COMPARE= data sets
                         * OUTBASE: Write an observation for each observation in the BASE= data set
                         * OUTCOMP: Write an observation for each observation in the COMPARE= data set
                         * OUTDIF: Write an observation that contains the differences for each pair of matching observations
                         * OUTNOEQUAL: Suppress the writing of observations when all values are equal
                         * OUTPERCENT: Write an observation that contains the percent differences for each pair of matching observations 

    Name:                metadataIn
      Default Value:     metadata.global
      Description:       Dataset containing metadata.          
                         
    Name:                allowWorkLibrary
      Allowed Values:    DEPRECATED
      Default Value:     DEPRECATED
      Description:       The parameter allowWorkLibrary is
                         deprecated, no longer used and only kept for backward
                         compatibility. For new code do not use this parameter.
                                   
    Name:                debug
      Allowed Values:    DEPRECATED
      Default Value:     DEPRECATED
      Description:       The parameter debug is
                         deprecated, no longer used and only kept for backward
                         compatibility. For new code do not use this parameter.

  Macro Returnvalue:    N/A
                                
  Global Macrovariables:

    Name:                gmCompareSysInfoResult
      Usage:             create/modify
      Description:       Contents of  sysInfo from the proc compare.

    Name:                _client
      Usage:             read
      Description:       Client short name for used in titles.      

    Name:                _tims
      Usage:             read
      Description:       Project number for use in titles.            

    Name:                _project
      Usage:             read
      Description:       Unix project name for use in titles.            

  Metadata Keys:
    Name:                outputQcPrefix 
      Description:       Prefix for a file containing the compare report. If not specified, "qc_" will be used.
      Dataset:           Global

    Name:                dsQcPrefix
      Description:       Prefix for a QC dataset name.
      Dataset:           Global          

  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)
                         gmCheckValueExists (called)
                         gmExecuteUnixCmd (called)
                         gmGetUserName (called)
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2426 $
-----------------------------------------------------------------------------*/

%MACRO GMCOMPARE( pathOut                   =
                , dataMain                  =
                , VarsId                    =
                , checkVarOrder             =0
                , checkCDISCnamingConvention=0
                , libraryQC                 =
                , allowWorkLibrary          =DEPRECATED
                , transpose                 =0
                , compareData               =
                , SelectDataType            = 
                , debug                     =DEPRECATED
                , metaDataIn                =metadata.global 
                );

  %gmStart(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcompare.sas $,
           revision=$Rev: 2426 $, libRequired=0);
  %IF &gmpxlerr. %THEN %RETURN;
%*--- Collect log and title options to reset after output messages         ---*;
  %LOCAL compare_center compare_date compare_number compare_count compare_title_count compare_library
         compare_dataset compare_loop compare_ols compare_progQC compare_VarsIdComma compare_clibrary 
         compare_cdataset compare_VarsIdBlank compare_opends compare_title1 compare_title2 compare_title3
         compare_title4 compare_title5 compare_title6 compare_title7 compare_title8 compare_gmExecuteUnixCmd
         compare_title9 compare_title10 compare_username compare_excl_prod compare_excl_qc compare_ls compare_ps
         compare_outputQcPrefix compare_dsQcPrefix compareExcludeRecordobs compare_selectDataType compare_info compare_ls2;
         
  %GLOBAL gmCompareSysInfoResult;
  %LET compare_center       =%SYSFUNC(GETOPTION(CENTER));
  %LET compare_date         =%SYSFUNC(GETOPTION(DATE));
  %LET compare_number       =%SYSFUNC(GETOPTION(NUMBER));
  %LET compare_ls           =%SYSFUNC(GETOPTION(LINESIZE));
  %LET compare_ps           =%SYSFUNC(GETOPTION(PAGESIZE));
  %LET compare_info         =0;
  %LET gmCompareSysInfoResult=;
  %LET compare_username=%gmGetUserName;
  DATA _NULL_;
    SET sashelp.vtitle (WHERE=(type = 'T'));
    IF MISSING(text) THEN CALL SYMPUT(CATT('compare_title',number),"TITLE"||TRIM(LEFT(PUT(number,best8.)))||";");
    ELSE CALL SYMPUT(CATT('compare_title',number),"TITLE"||TRIM(LEFT(PUT(number,best8.)))||" '"||TRIM(text)||"';");
  RUN;
  OPTIONS CENTER NODATE NONUMBER PS=47;
%*--- Read in prefixs from metadata dataset                               ---*;
   %IF %SYSFUNC(EXIST(&metaDataIn)) %THEN %DO;
     DATA _NULL_;
        SET &metaDataIn;
        IF UPCASE(key)='OUTPUTQCPREFIX' AND MISSING(TRIM(LEFT(value))) EQ 0 THEN CALL SYMPUT ('compare_outputQcPrefix',TRIM(LEFT(value)));
        IF UPCASE(key)='DSQCPREFIX' AND MISSING(TRIM(LEFT(value))) EQ 0 THEN CALL SYMPUT ('compare_dsQcPrefix',TRIM(LEFT(value)));
     RUN;
   %END;
   %IF ~%gmCheckValueExists( codeLocation = gmCompare check compare_outputQcPrefix
                           , selectMethod = BOOLEAN
                           , value        = &compare_outputQcPrefix.) %THEN %DO;
     %LET compare_outputQcPrefix=qc_;
   %END;
   %IF ~%gmCheckValueExists( codeLocation = gmCompare check compare_dsQcPrefix
                           , selectMethod = BOOLEAN
                           , value        = &compare_dsQcPrefix.) %THEN %DO;
     %LET compare_dsQcPrefix=;
   %END;
%*--- Deriving QC program name (for batch mode only) ---*;
  DATA _NULL_;
    CALL SYMPUT('compare_progQC',STRIP(GETOPTION('sysin')));
  RUN;
%*--- Separate macro variables for dataset and library (for vcolumn)      ---*;
  DATA _NULL_ ;
    LENGTH _library _dataset _clibrary _cdataset $32.;
    IF FIND(LEFT("&dataMain."),".") EQ 0 THEN DO;
      CALL EXECUTE('
        %gmMessage( codeLocation = gmcompare
        , linesOut     = LIBRARY OF PRODUCTION DATASET NOT SPECIFIED. MACRO TERMINATING.
        , selectType   = ABORT);');
    END;
    ELSE DO;
        _library=UPCASE(SCAN("&dataMain.",1,"."));
        _dataset=UPCASE(SCAN("&dataMain.",-1,"."));
        CALL SYMPUT("compare_library",TRIM(_library));
        CALL SYMPUT("compare_dataset",TRIM(_dataset));
    END;
    IF FIND(LEFT("&compareData."),".") EQ 0 THEN DO;
        _clibrary="WORK";
        _cdataset=UPCASE(LEFT("&compareData."));
        CALL SYMPUT("compare_clibrary",TRIM(_clibrary));
        CALL SYMPUT("compare_cdataset",TRIM(_cdataset));
    END;
    ELSE DO;
        _clibrary=UPCASE(SCAN("&compareData.",1,"."));
        _cdataset=UPCASE(SCAN("&compareData.",-1,"."));
        CALL SYMPUT("compare_clibrary",TRIM(_clibrary));
        CALL SYMPUT("compare_cdataset",TRIM(_cdataset));
    END;
    
    IF "&allowWorkLibrary." NE "DEPRECATED" THEN DO;
      CALL EXECUTE('
        %gmMessage( codeLocation = gmcompare
        , linesOut = %STR(THE PARAMETER allowWorkLibrary IS DEPRECATED, NO LONGER USED AND ONLY KEPT FOR BACKWARD COMPATIBILITY.)
        @ FOR NEW CODE DO NOT USE THIS PARAMETER.);');
    END;
    IF "&debug." NE "DEPRECATED" THEN DO;
      CALL EXECUTE('
        %gmMessage( codeLocation = gmcompare
        , linesOut = %STR(THE PARAMETER debug IS DEPRECATED, NO LONGER USED AND ONLY KEPT FOR BACKWARD COMPATIBILITY.)
        @ FOR NEW CODE DO NOT USE THIS PARAMETER.);');
    END;
    IF _library EQ "WORK" THEN DO;
      CALL EXECUTE('
        %gmMessage( codeLocation = gmcompare
        , linesOut     = WORK LIBRARY USAGE IS PROHIBITED FOR PRODUCTION DATASET. MACRO TERMINATING.
        , selectType   = ABORT); ');         
    END;
  RUN;
  %IF &gmpxlerr. %THEN %RETURN;
%*--- Remove previous compare output                                 ---*;
  %IF %SYSFUNC(FILEEXIST(&pathOut.%lowcase(&compare_outputQcPrefix.&compare_dataset.).txt)) %THEN %DO;  
    %LET compare_gmExecuteUnixCmd=%gmExecuteUnixCmd(cmds=rm &pathOut.%lowcase(&compare_outputQcPrefix.&compare_dataset.).txt);
  %END;
%*--- Check SelectDataType contains a valid value                         ---*;   
  %LET compare_loop=1;
  %DO %WHILE(%QSCAN(&selectDataType.,&compare_loop,%str(@)) NE %STR());
    %IF "%UPCASE(%SCAN(&selectDataType.,&compare_loop.,%STR(@)))"="" OR 
         %UPCASE(%SCAN(&selectDataType.,&compare_loop.,%STR(@)))=OUTALL OR 
         %UPCASE(%SCAN(&selectDataType.,&compare_loop.,%STR(@)))=OUTBASE OR 
         %UPCASE(%SCAN(&selectDataType.,&compare_loop.,%STR(@)))=OUTCOMP OR 
         %UPCASE(%SCAN(&selectDataType.,&compare_loop.,%STR(@)))=OUTDIF OR 
         %UPCASE(%SCAN(&selectDataType.,&compare_loop.,%STR(@)))=OUTNOEQUAL OR 
         %UPCASE(%SCAN(&selectDataType.,&compare_loop.,%STR(@)))=OUTPERCENT %THEN %DO; %END;
    %ELSE %DO;
      %gmMessage( codeLocation = gmcompare
                , linesOut     = SelectDataType (&SelectDataType.) contains an invalid value(%SCAN(&selectDataType.,&compare_loop.,%STR(@))) .
                , selectType   = ABORT
                , splitchar    = #);
      %RETURN;
    %END;
    %LET compare_loop= %EVAL(&compare_loop+1);
  %END;
  
  DATA _NULL_;
    CALL SYMPUT("compare_selectDataType",TRANSLATE(TRIM("&selectDataType")," ","@"));
  RUN;
%*--- Checks to see if production library exists                          ---*;
  %IF (%SYSFUNC(LIBREF(&compare_library.))) %THEN %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = LIBRARY %UPCASE(&compare_library.) DOES NOT EXIST. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
  %gmMessage( codeLocation = gmcompare, linesOut = LIBRARY %UPCASE(&compare_library.) EXISTS.);
%*--- Checks to see if production dataset exists                          ---*;
  %IF %SYSFUNC(EXIST(&compare_library..&compare_dataset.)) %THEN %DO;
    %gmMessage( codeLocation = gmcompare, linesOut = DATASET %UPCASE(&compare_library..&compare_dataset.) EXISTS.);
  %END;
  %ELSE %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = %UPCASE(&compare_library..&compare_dataset.) DOES NOT EXIST. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
%*--- Checks to see if QC library exists                          ---*;
  %IF "&libraryQC" = "" %THEN %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = REQUIRED PARAMETER libraryQC NOT SPECIFIED. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
  %ELSE %IF (%SYSFUNC(LIBREF(&libraryQC.))) %THEN %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = LIBRARY %UPCASE(&libraryQC.) DOES NOT EXIST. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
  %gmMessage( codeLocation = gmcompare
            , linesOut     = LIBRARY %UPCASE(&libraryQC.) EXISTS.);
%*--- Checks to see if QC dataset exists                          ---*;
  %IF %SYSFUNC(EXIST(&libraryQC..&compare_dsQcPrefix.&compare_dataset.)) %THEN %DO;
    %gmMessage( codeLocation = gmcompare, linesOut = DATASET %UPCASE(&libraryQC..&compare_dataset.) EXISTS.);
  %END;
  %ELSE %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = %UPCASE(&libraryQC..&compare_dsQcPrefix.&compare_dataset.) DOES NOT EXIST. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
%*--- Check to see that production and QC library are not the same---*;
  %IF %UPCASE(&compare_library.) EQ %UPCASE(&libraryQC.) %THEN %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = PRODUCTION AND QC LIBRARY (%UPCASE(&compare_library.)) ARE EQUAL. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
%*--- Check location of production and QC library are not the same---*;
  %IF "%UPCASE(%SYSFUNC(PATHNAME(&compare_library.)))" EQ "%UPCASE(%SYSFUNC(PATHNAME(&libraryQC.)))" %THEN %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = PRODUCTION AND QC LIBRARY (%UPCASE(%SYSFUNC(PATHNAME(&compare_library.)))) ARE THE SAME FOLDER. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
  %IF "&VarsId." NE "" %THEN %DO;
%*--- Check ID vars exist in Production dataset                           ---*;
    %LET compare_loop=1;
    %LET compare_opends=%SYSFUNC(OPEN(&compare_library..&compare_dataset.));
    %DO %WHILE(%QSCAN(&VarsId.,&compare_loop,%str(@)) NE %str());
      %IF %SYSFUNC(VARNUM(&compare_opends.,%SCAN(&VarsId.,&compare_loop.,%STR(@)))) EQ 0 %THEN %DO;
        %LET rc =%SYSFUNC(CLOSE(&compare_opends.));
        %gmMessage( codeLocation = gmcompare
                  , linesOut     = ID VARIABLE %UPCASE(%SCAN(&VarsId.,&compare_loop.,%str(@))) NOT IN PRODUCTION DATASET. MACRO TERMINATING.
                  , selectType   = ABORT);
        %RETURN;
      %END;
      %LET compare_loop= %EVAL(&compare_loop+1);
    %END;
    %LET rc =%SYSFUNC(CLOSE(&compare_opends.));
%*--- Checks to see if CompareData library exists                          ---*;
  %IF (%SYSFUNC(LIBREF(&compare_clibrary.))) %THEN %DO;
    %gmMessage( codeLocation = gmcompare
              , linesOut     = LIBRARY %UPCASE(&compare_clibrary.) DOES NOT EXIST. MACRO TERMINATING.
              , selectType   = ABORT);
    %RETURN;
  %END;
  %gmMessage( codeLocation = gmcompare, linesOut = LIBRARY %UPCASE(&compare_clibrary.) EXISTS.);
%*--- Check ID vars exist in QC dataset                                   ---*;
    %LET compare_loop=1;
    %LET compare_opends=%SYSFUNC(OPEN(&libraryQC..&compare_dsQcPrefix.&compare_dataset.));
    %DO %WHILE(%QSCAN(&VarsId.,&compare_loop,%str(@)) NE %STR());
      %IF %SYSFUNC(VARNUM(&compare_opends.,%SCAN(&VarsId.,&compare_loop.,%STR(@)))) EQ 0 %THEN %DO;
        %LET rc =%SYSFUNC(CLOSE(&compare_opends.));
        %gmMessage( codeLocation = gmcompare
                  , linesOut     = ID VARIABLE %UPCASE(%SCAN(&VarsId.,&compare_loop.,%str(@))) NOT IN QC DATASET. MACRO TERMINATING.
                  , selectType   = ABORT);
        %RETURN;
      %END;
      %LET compare_loop= %EVAL(&compare_loop+1);
    %END;
    %LET rc =%SYSFUNC(CLOSE(&compare_opends.));
  %END;
%*--- Check number of grprxExcludeRecord records                          ---*;
  %LET compare_opends=%SYSFUNC(OPEN(&compare_library..&compare_dataset.));
  %IF (&compare_opends.) %THEN %DO;
    %IF %SYSFUNC(VARNUM(&compare_opends.,grprxExcludeRecord)) %THEN %DO;
      PROC SQL NOPRINT;
        SELECT TRIM(LEFT(PUT(COUNT(*),best.))) INTO: compareExcludeRecordobs
        FROM &compare_library..&compare_dataset. WHERE grprxExcludeRecord=1;
      QUIT;
    %END;
    %ELSE %LET compareExcludeRecordobs=0;  
  %END;
  %LET rc =%SYSFUNC(CLOSE(&compare_opends.));
  
  %IF "&compare_progQC." NE "" %THEN %DO;
    TITLE1 "EQC of &compare_library..&compare_dataset. on &_client. &_tims. (&_project.).  QC produced by &compare_username. on &sysdate9..";
    TITLE2 "Program name = &compare_progQC.";
  %END;
  %ELSE %DO;
    TITLE1 "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
    TITLE2 "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  %END;
%*--- Add dynamic linesize based on title length                          ---*;
	DATA _NULL_;
		CALL SYMPUT("compare_ls2",TRIM(LEFT(PUT(MAX(
		LENGTH("EQC of &compare_library..&compare_dataset. on &_client. &_tims. (&_project.).  QC produced by &compare_username. on &sysdate9.."),
  	LENGTH("Program name = &compare_progQC."),
  	LENGTH("Duplicate recorded within ID variables (&VarsId.) in the production dataset"),
  	LENGTH("Compare Output: Base=Main Dataset [&compare_library.],  Compare=QC Dataset [%UPCASE(&libraryQC.)].  SysInfo:PxlInfo XXXXX:YYYYYY"),
		133),best.))));
	RUN;
	OPTIONS LS=&compare_ls2.;
%*--- Output to txt file compare output                              ---*;
  ODS EXCLUDE NONE;
  PROC PRINTTO NEW FILE="&pathOut.%lowcase(&compare_outputQcPrefix.&compare_dataset.).txt";
  RUN;
%*--- Print duplicates that are in the production and QC datasets    ---*;
  %IF "&VarsId." NE "" %THEN %DO;
    DATA _NULL_;
      CALL SYMPUT("compare_VarsIdComma",TRANSLATE(TRIM("&VarsId"),",","@"));
      CALL SYMPUT("compare_VarsIdBlank",TRANSLATE(TRIM("&VarsId")," ","@"));
    RUN;

    TITLE3 "Duplicate recorded within ID variables (&VarsId.) in the production dataset";
    %IF &compareExcludeRecordobs. NE 0 %THEN %DO;
      TITLE6 "%TRIM(&compareExcludeRecordobs.) records with grprxExcludeRecords=1 excluded from the Base dataset.";
    %END;
    PROC SQL EXEC NONUMBER;
      SELECT *
        FROM (SELECT *, COUNT(*)
              FROM &compare_library..&compare_dataset.
              %IF &compareExcludeRecordobs. NE 0 %THEN %DO;
                WHERE grprxExcludeRecord NE 1
              %END;
            GROUP BY &compare_VarsIdComma.
            HAVING COUNT(*) > 1) 
      WHERE monotonic() < 51;
    QUIT;
    
    TITLE6;
    
    TITLE3 "Duplicate recorded within ID variables (&VarsId.) in the QC dataset";
    %*--- Reset SQLOBS to determine if duplicates are recorded within ID variables ---*;
    %LET SQLOBS=0;
    PROC SQL EXEC NONUMBER;
      SELECT *
        FROM (SELECT *, COUNT(*)
                FROM &libraryQC..&compare_dsQcPrefix.&compare_dataset.
              GROUP BY &compare_VarsIdComma.
              HAVING COUNT(*) > 1)
      WHERE monotonic() < 51;
    QUIT;
    %IF &SQLOBS. > 0 %THEN %LET compare_info=%EVAL(&compare_info.+4);
  %END;
  
  TITLE3;
  %*--- Reset SQLOBS to determine if GRPX variables are excluded from the Base dataset ---*;
  %LET SQLOBS=0;
  PROC SQL NOPRINT;
    SELECT UPCASE(name) INTO :compare_excl_prod SEPARATED BY " "
      FROM DICTIONARY.COLUMNS
      WHERE (libname=UPCASE("&compare_library.") AND memname=UPCASE("&compare_dataset.") AND INDEX(UPCASE(name),"GRPX") EQ 1);
  QUIT;
  %IF &SQLOBS. > 0 %THEN %LET compare_info=%EVAL(&compare_info.+1);
  PROC SQL NOPRINT;
    SELECT UPCASE(name) INTO :compare_excl_qc SEPARATED BY " "
      FROM DICTIONARY.COLUMNS
      WHERE (libname=UPCASE("&libraryQC.") AND memname=UPCASE("&compare_dsQcPrefix.&compare_dataset.") AND INDEX(UPCASE(name),"GRPX") EQ 1);
  QUIT;
  
  PROC COMPARE DATA=&compare_library..&compare_dataset. (DROP=&compare_excl_prod.
                                                         %IF &compareExcludeRecordobs. NE 0 %THEN %DO;
                                                           WHERE=(grprxExcludeRecord NE 1)
                                                         %END;
                                                        )
               COMPARE=&libraryQC..&compare_dsQcPrefix.&compare_dataset. (DROP=&compare_excl_qc.) LISTALL CRITERION=0.00000001 MAXPRINT=(50,32767)

               %IF "&CompareData." NE "" %THEN %DO;    
                 OUT=&compare_clibrary..&compare_cdataset. &compare_selectDataType.
               %END;
               %IF &transpose. %THEN %DO;
                 transpose
               %END;   
               ;
  %IF "&compare_progQC." NE "" %THEN %DO;
    TITLE3 "Compare Output: Base=Main Dataset [&compare_library.],  Compare=QC Dataset [%UPCASE(&libraryQC.)].  SysInfo:PxlInfo XXXXX:YYYYYY";
  %END;
  %ELSE %DO;
    TITLE3 "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX";
  %END;
  %IF "&compare_excl_prod." NE "" %THEN %DO;
    TITLE4 "GRPX variables excluded from the Base dataset: &compare_excl_prod.";
  %END;
  %IF "&compare_excl_qc." NE "" %THEN %DO;
    TITLE5 "GRPX variables excluded from the Compare dataset: &compare_excl_qc.";
  %END;
  %IF &compareExcludeRecordobs. NE 0 %THEN %DO;
    TITLE6 "%TRIM(&compareExcludeRecordobs.) records with grprxExcludeRecords=1 excluded from the Base dataset.";
    %LET compare_info=%EVAL(&compare_info.+8);
  %END;
  %IF "&VarsId." NE "" %THEN %DO;
    ID &compare_VarsIdBlank.;
  %END;
  RUN;
  %LET gmCompareSysInfoResult=&sysInfo.;

  %IF &checkVarOrder. %THEN %DO;
%*--- Reset SQLOBS so it can be determined if variable order between main and QC datasets is different ---*;
    %LET SQLOBS=0;
    TITLE3 "Variable Order";
    PROC SQL;
    SELECT LEFT(put(b.varnum,best.)), COMPBL("Sequence Number for "||b.label||"["||trim(b.name)||"] is specified as "||put(a.varnum,best.)||
                            " in the QC dataset")
      from DICTIONARY.COLUMNS as a inner join DICTIONARY.COLUMNS as b
      ON a.varnum=b.varnum AND a.libname EQ UPCASE("&compare_library.") AND a.memname EQ UPCASE("&compare_dataset.") AND
         b.libname EQ UPCASE("&libraryQC.") AND b.memname EQ UPCASE("&compare_dsQcPrefix.&compare_dataset.") AND UPCASE(a.name) NE UPCASE(b.name)
    UNION
    SELECT LEFT(put(b.varnum,best.)), COMPBL("Sequence Number for "||b.label||"["||trim(b.name)||"] is specified as "||put(a.varnum,best.)||
                            " in the QC dataset - check variable name case")
      from DICTIONARY.COLUMNS as a inner join DICTIONARY.COLUMNS as b
      ON a.varnum=b.varnum AND a.libname EQ UPCASE("&compare_library.") AND a.memname EQ UPCASE("&compare_dataset.") AND
         b.libname EQ UPCASE("&libraryQC.") AND b.memname EQ UPCASE("&compare_dsQcPrefix.&compare_dataset.") AND UPCASE(a.name) EQ UPCASE(b.name) AND
         a.NAME NE b.name;
    QUIT;
    %IF &SQLOBS. > 0 %THEN %LET compare_info=%EVAL(&compare_info.+2);
  %END;

  PROC PRINTTO;
  RUN;
  TITLE;
  %*--- Update XXXXX:YYYYYY with system and pxl bit codes ---*;
  %gmExecuteUnixCmd(cmds=perl -i -pe "s/XXXXX:YYYYYY/&gmCompareSysInfoResult.:&compare_info./" &pathOut.%lowcase(&compare_outputQcPrefix.&compare_dataset.).txt);

%*--- Print the compare to output in interactive mode ---*;
  %IF "&compare_progQC." = "" %THEN %DO;
    DATA _NULL_;
      INFILE "&pathOut.%lowcase(&compare_outputQcPrefix.&compare_dataset.).txt";
      INPUT;
      FILE PRINT;
      PUT _inFile_;
    RUN;
  %END;
   
%*--- Send compare results to log                                    ---*;
  DATA _NULL_;
    ARRAY returnCodeDescription [16] $100 _TEMPORARY_
          ("DATA SET LABELS DIFFER                            " "DATA SET TYPES DIFFER                             "
           "VARIABLE HAS DIFFERENT INFORMAT                   " "VARIABLE HAS DIFFERENT FORMAT                     "
           "VARIABLE HAS DIFFERENT LENGTH                     " "VARIABLE HAS DIFFERENT LABEL                      "
           "BASE DATA SET HAS OBSERVATION NOT IN COMPARISON   " "COMPARISON DATA SET HAS OBSERVATION NOT IN BASE   "
           "BASE DATA SET HAS BY GROUP NOT IN COMPARISON      " "COMPARISON DATA SET HAS BY GROUP NOT IN BASE      "
           "BASE DATA SET HAS VARIABLE NOT IN COMPARISON      " "COMPARISON DATA SET HAS VARIABLE NOT IN BASE      "
           "A VALUE COMPARISON WAS UNEQUAL                    " "CONFLICTING VARIABLE TYPES                        "
           "BY VARIABLES DO NOT MATCH                         " "FATAL ERROR: COMPARISON NOT DONE                  ");
    LENGTH result res $1024 rc $200.;
    DO i = 1 TO 16;
      IF SUBSTR(REVERSE(PUT(&gmCompareSysInfoResult.,binary16.)),i,1) EQ "1" THEN DO;
        res = STRIP ( STRIP(res) || " @" ||STRIP(returnCodeDescription[i]) || " ");
      END;;
    END;
    IF MISSING(res) THEN result="NO DIFFERENCES IDENTIFIED";
    ELSE result=res;
    rc = resolve('%gmMessage(codeLocation = gmcompare, linesOut = sysInfo RESULTS FROM PROC COMPARE: ' || strip(result) || ');');
  RUN;

  OPTIONS &compare_center. &compare_date. &compare_number. LS=&compare_ls. PS=&compare_ps.;
  %DO compare_title_count = 1 %TO 10;
    &&compare_title&compare_title_count..;
  %END;
  %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcompare.sas $);
%MEND gmCompare;
