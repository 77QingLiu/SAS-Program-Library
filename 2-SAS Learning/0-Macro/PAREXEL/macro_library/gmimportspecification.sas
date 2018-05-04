/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Matthias Lehrkamp, Carlos Pang $LastChangedBy: kolosod $
  Creation Date:         20Mar2013       $LastChangedDate: 2016-10-25 05:12:55 -0400 (Tue, 25 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmimportspecification.sas $

  Files Created:         &libOut..specdata (include specifications about the
                                            datasets)

                         &libOut..specvar (include specifications about the
                                           variables)

                         &libOut..speccodelist (include specifications about
                                                the codelists)

  Program Purpose:       This macro imports specifications from a standard PXL
                         template. This macro can import XLS Excel 97-2000 files
                         and the XLSX Excel file format using SAS 9.3 and above.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters:

    Name:                fileIn
      Description:       Full path to a specification. XLS files are supported
                         in SAS 9.2+. XLSX are supported in SAS 9.3+.
                         # A WebDav link can be used to download a specification
                         from PMED.

    Name:                libOut
      Default Value:     metadata
      Description:       Library used to store generated datasets

    Name:                dataTermIn
      Default Value:     metadata.cdiscTerminology
      Description:       CDISC terminology dataset to be joined with Codelist
                         tab

    Name:                lockWait
      Allowed Values:    0 - 600
      Default Value:     30
      Description:       Number of seconds SAS waits for an output dataset if it
                         is locked

    Name:                escapeChar
      Allowed Values:    Any single character
      Default Value:     ~
      Description:       Special character used to separate codelist and subset
                         name.

    Name:                checkCodelist
      Allowed Values:    1|0
      Default Value:     1
      Description:       Enable/Disable two checks below (0=Disable, 1=Enable)
                         #1. The same codelist can't be provided both on the
                            "Variable Metadata" and "Codelist" tabs.
                         #2. The codelists having the same name can't have
                            different values.

    Name:                selectType
      Allowed Values:    ERROR|E|ABORT
      Default Value:     ABORT
      Description:       Message type of the codelist checking result in log

    Name:                metadataIn
      Default Value:     metadata.global
      Description:       Dataset containing metadata

    Name:                keepStandardColumns
      Allowed Values:    1|0
      Default Value:     1
      Description:       Only keep standard columns in the resulting datasets
                         (0=No, 1=Yes)

  Macro Returnvalue:

      Description:       Macro does not return any values.

  Metadata Keys:

    Name:                fileSpec
      Description:       Specification file to be imported with a full path.
                         Can be overridden in macro call if required. A note is
                         written to the log if a parameter value in macro call
                         is different from a value specified in metadata
                         dataset.
      Dataset:           global (dataset specified in metadataIn=).

  Macro Dependencies:    gmStart (called)
                         gmMessage (called)
                         gmCheckValueExists (called)
                         gmTrimVarLen (called)
                         gmExecuteUnixCmd (called)
                         gmReplaceText (called)
                         gmEnd (called)
-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2798 $
-----------------------------------------------------------------------------*/

%MACRO gmImportSpecification( fileIn              =
                            , libOut              = metadata
                            , dataTermIn          = metadata.cdiscTerminology
                            , lockWait            = 30
                            , escapeChar          = ~
                            , checkCodelist       = 1
                            , selectType          = ABORT
                            , metaDataIn          = metadata.global
                            , keepStandardColumns = 1
);

  %LOCAL is_templib;

  %* create temporary library;
  %LET is_templib= %gmStart( headURL            = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmimportspecification.sas $
                           , revision           = $Rev: 2798 $
                           , librequired        = 1
                           , checkMinSasVersion = 9.2
                           );

  %LOCAL is_fileSpec is_fileSuffix is_saveValidvarname is_specCodeListVars
         is_requestPwd is_rc is_pwd is_curlrcCreated
         is_checkCodelistId1 is_checkCodelistId2
         is_speccoverpageLockInfo is_specdataLockInfo is_specvarLockInfo is_speccodelistLockInfo;

  %* check whether &libOut exists;
  %IF %SYSFUNC(LIBREF(%BQUOTE(&libOut.))) NE 0 %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/libOut check
              , linesOut     = The libname %BQUOTE(&libOut.) specified in parameter libOut does not exist
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %END;

  %*check whether dataTermIn exists;
  %IF NOT %SYSFUNC(EXIST(%BQUOTE(&dataTermIn.))) %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/CDISC terminology dataset check
              , linesOut     = %BQUOTE(&dataTermIn.) does not exist
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %END;

  %* check lockWait argument;
  %IF &lockWait < 0 or &lockWait > 600 %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/lockWait check
              , linesOut     = Parameter lockWait= &lockWait. has an invalid value.
                               @Please choose a number between 0 and 600.
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %END;

  %* Check whether escapeChar is a single character;
  %IF %LENGTH(%SUPERQ(escapeChar)) NE 1 %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/escapeChar check
              , linesOut     = Parameter escapeChar must be a single character
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %END;

  %* Check selectType is ERROR, E, ABORT;
  %IF %QSYSFUNC(PRXMATCH(/^(ERROR|E|ABORT)$/,%UPCASE(%SUPERQ(selectType)))) NE 1 %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/selectType checks
              , linesOut     = %str(Parameter selectType= &selectType. has an invalid value.
                                    @Please choose E,ERROR or ABORT.)
              , selectType   = ABORT
              , printStdOut  = 1
              )
  %END;

  %* check if checkCodelist is 1 or 0;
  %IF %BQUOTE(&checkCodelist.) NE 1 AND %BQUOTE(&checkCodelist.) NE 0 %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/checkCodelist checks
              , linesOut     = %str(Parameter checkCodelist= &checkCodelist. has an invalid value.
                                    @Please choose 1 or 0.)
              , selectType   = ABORT
              , printStdOut  = 1
              )
  %END;

  %* check if keepStandardColumns is 1 or 0;
  %IF %BQUOTE(&keepStandardColumns.) NE 1 AND %BQUOTE(&keepStandardColumns.) NE 0 %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/keepStandardColumns checks
              , linesOut     = %str(Parameter keepStandardColumns= &keepStandardColumns. has an invalid value.
                                    @Please choose 1 or 0.)
              , selectType   = ABORT
              , printStdOut  = 1
              )
  %END;

  %* check if metadata.global dataset exists, read fileSpec value if present;
  %IF %SYSFUNC(EXIST(&metaDataIn)) %THEN %DO;
    DATA _NULL_;
      SET &metaDataIn;
      IF UPCASE(key)='FILESPEC' and value ne '' then CALL SYMPUT('is_fileSpec',STRIP(value));
    RUN;
  %END;
  %*check if custom metadata dataset specified that it exists;
  %ELSE %IF &metaDataIn NE metadata.global %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/metadata dataset check
              , linesOut     = &metaDataIn does not exist
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %END;

  %* if fileSpec specified in metadata.global then use if fileIn not passed to macro;
  %* if fileIn from macro parameter differ from the value in metadata.global then put message in log;
  %IF NOT %gmCheckValueExists( codeLocation = gmImportSpecification/fileIn check
                             , value        = %STR(&fileIn.) ) %THEN %DO;
    %LET fileIn=&is_fileSpec.;
  %END;
  %ELSE %IF %BQUOTE(&fileIn.) NE %BQUOTE(&is_fileSpec.) %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/fileIn
              , linesOut     = Macro parameter fileIn differs from metadata.global fileSpec value.
                               @The macro parameter has been used.
              , selectType   = NOTE
              );
  %END;

  %* check if either metadata or macro parameter has value to specify imported file;
  %IF NOT %gmCheckValueExists( codeLocation = gmImportSpecification/fileIn check
                             , value        = %STR(&fileIn.) ) %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/fileIn
              , linesOut     = Please specify the location of the file to be imported in metadata or macro parameter
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %END;

  %*get file suffix from fileIn;
  %LET is_fileSuffix=%SYSFUNC(PRXCHANGE(s/^.+\.(\S+)\s*$/$1/,1,&fileIn.));

  %*when spec is from PMED;
  %IF %INDEX(&fileIn,http://p-med.pxl.int/pmeddav/) %THEN %DO;
    %* flag indicating whether password request is needed;
    %LET is_requestPwd = 0;

    %* get the file from PMED if .curlrc exists;
    %IF %SYSFUNC(FILEEXIST(/home/users/&sysUserId./.curlrc)) %THEN %DO;
      X "/opt/pdag/bin/curl -k -s --ntlm %superQ(fileIn) > %sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.";
    %END;
    %ELSE %DO;
      %gmMessage(linesOut = File /home/users/&sysUserId./.curlrc does not exist, selectType=N);
      %let is_requestPwd = 1;
    %END;

    %IF &is_requestPwd EQ 0 %THEN %DO;
      %* check if file exists or the credentials were correct;
      %LET is_rc = %gmExecuteUnixCmd(cmds= head -2 %sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.
                                           | tail -1 | grep ">HTTP Error<" | wc -l);
      %IF %SUBSTR(&is_rc,1,1) NE 0 %THEN %DO;
        %gmMessage(linesOut = Could not find the file on PMED, selectType=ABORT, printStdOut = 1);
      %END;

      %LET is_rc = %gmExecuteUnixCmd(cmds= head -2 %sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.
                                           | tail -1 | grep ">You are not authorized to view this page<" | wc -l);
      %IF %SUBSTR(&is_rc,1,1) NE 0 %THEN %DO;
        %gmMessage(linesOut = Credentials are incorrect, selectType=N);
        %LET is_requestPwd = 1;
      %END;
    %END;

    %IF &is_requestPwd EQ 1 AND (%QUOTE(&SYSPROCESSNAME.) EQ Object Server) %THEN %DO;
      %gmMessage( linesOut    = %STR(For SAS EG, file /home/users/&sysUserId./.curlrc must be created and controlled manually.)
                , selectType  = ABORT
                , sendEmail   = 1);
    %END;
    %ELSE %IF &is_requestPwd EQ 1 %THEN %DO;
      %*ask user to input password, then store is in .curlrc file;
      DATA _NULL_;
        LENGTH is_pwd $32;
        WINDOW is_pwdInput ROWS=15 COLUMNS=85
          #2 @1 'Authentication is required to download the file from PMED.'
          #3 @1 'The password will be saved to a .curlrc file in your home folder.'
          #4 @1 'It is recommended to manually create and control the .curlrc file.'
          #5 @1 'Details can be found on the statwiki.pxl.int in H&T section:'
          #6 @1 'Article "Using cURL to transfer files between PMED and Kennet"'
          #8 @1 'Incorrect password can result in your account being locked.'
          #9 @1 'If you entered an incorrect password, visit PMED before running the macro again.'
          #10 @1 'Leave blank to ABORT the macro execution.'
          #11 @1 'Please enter your Windows (not UNIX) password:' +1 is_pwd $32. DISPLAY=NO ATTR=UNDERLINE;
        DISPLAY is_pwdInput;

        IF LENGTH(is_pwd) LT 8 THEN
          y=RESOLVE('%gmMessage(linesOut = Input password is less than 8 characters, selectType=ABORT, printStdOut=1)');
        ELSE DO;
          CALL SYSTEM("rm -f /home/users/&sysUserId./.curlrc;"
                      ||'echo -n "'||"-u &sysUserId.:"||STRIP(is_pwd)||'"'||" > /home/users/&sysUserId./.curlrc;"
                      ||"chmod 600 /home/users/&sysUserId./.curlrc;"
                      ||"history -c");
          CALL SYMPUT('is_curlrcCreated','1');
        END;
        STOP;
      RUN;
    %END;

    %IF &is_requestPwd EQ 1 AND &is_curlrcCreated EQ 1 %THEN %DO;
      %*try to download spec file again;
      X "rm -f %sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.";
      X "/opt/pdag/bin/curl -k -s --ntlm %superQ(fileIn) > %sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.";

      %* check if file exists or the credentials were correct;
      %LET is_rc = %gmExecuteUnixCmd(cmds= head -2 %sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.
                                           | tail -1 | grep ">HTTP Error<" | wc -l);
      %IF %SUBSTR(&is_rc,1,1) NE 0 %THEN %DO;
        %gmMessage(linesOut = Could not find the file on PMED, selectType=ABORT, printStdOut = 1);
      %END;

      %LET is_rc = %gmExecuteUnixCmd(cmds= head -2 %sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.
                                           | tail -1 | grep ">You are not authorized to view this page<" | wc -l);
      %IF %SUBSTR(&is_rc,1,1) NE 0 %THEN %DO;
        X "rm -f /home/users/&sysUserId./.curlrc";
        %gmMessage(linesOut = Credentials are incorrect. Please visit PMED before running the macro again, to avoid locking your account.
                       @WINDOWS password in /home/users/&sysUserId./.curlrc is not correct or you do not have access to the file on PMED.
                   , selectType = ABORT
                   , printStdOut = 1);
      %END;
    %END;

    %*assign fileIn to the path of the download file;
    %LET fileIn=%sysFunc(pathName(&is_templib.))/spec.&is_fileSuffix.;
  %END;

  %* check if the file specified exists;
  %IF NOT %SYSFUNC(FILEEXIST(&fileIn)) %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/fileIn
              , linesOut     = The file you specified does not exist at %BQUOTE(&fileIn.)
              , selectType   = ABORT
              , printStdOut  = 1
              );
  %END;

  %* check if file suffix is xls or xlsx;
  %IF %LOWCASE("&is_fileSuffix.") NE "xls" AND %LOWCASE("&is_fileSuffix.") NE "xlsx" %THEN %DO;
    %gmMessage( codeLocation = adsImport/ADSFileType
              , linesOut     = %STR(The file type "&is_fileSuffix." is not supported. Please use xlsx(SAS 9.3) or xls.)
              , selectType   = ABORT
              , printStdOut  = 1
              )
  %END;
  %* check if SAS version is 9.3 or higher to import XLSX file;
  %ELSE %IF %LOWCASE("&is_fileSuffix.") EQ "xlsx" and "&sysVer." EQ "9.2" %THEN %DO;
    %gmMessage( codeLocation = gmImportSpecification/ADSFileType
              , linesOut     = %STR(SAS version must be 9.3 or higher to import XLSX file.)
              , selectType   = ABORT
              , printStdOut  = 1
              )
  %END;

  %* stores the current option to restore it after import;
  %LET is_saveValidvarname= %SYSFUNC(GETOPTION(VALIDVARNAME));
  %* set option to import Excel file correctly;
  OPTION VALIDVARNAME=ANY;

  %* Import the Cover Page sheet;
  PROC IMPORT DATAFILE= "&fileIn"
              OUT=&is_templib..speccoverpage (Label = "Cover Page")
              DBMS=&is_fileSuffix.
              REPLACE;
    SHEET="Cover Page";
    GETNAMES=NO;
    MIXED=YES;
  RUN;

  %* Import the Dataset Metadata sheet;
  PROC IMPORT DATAFILE= "&fileIn"
              OUT=&is_templib..specdata1
              %IF &keepStandardColumns. %THEN ( KEEP= a--j );
              DBMS=&is_fileSuffix.
              REPLACE;
    SHEET="Dataset Metadata";
    GETNAMES=NO;
    MIXED=YES;
  RUN;

  %* Import the Variable Metadata sheet;
  PROC IMPORT DATAFILE= "&fileIn"
              OUT=&is_templib..specvar1
              %IF &keepStandardColumns. %THEN ( KEEP= a--s );
              DBMS=&is_fileSuffix.
              REPLACE;
    SHEET="Variable Metadata";
    GETNAMES=NO;
    MIXED=YES;
  RUN;

  %* Import the Codelist sheet;
  PROC IMPORT DATAFILE= "&fileIn"
              OUT=&is_templib..speccodelist1a
              %IF &keepStandardColumns. %THEN ( KEEP= a--c );
              DBMS=&is_fileSuffix.
              REPLACE;
    SHEET="Codelist";
    GETNAMES=NO;
    MIXED=YES;
  RUN;

  %*remove NULL characters for xlsx file;
  %IF %LOWCASE("&is_fileSuffix.") = "xlsx" %THEN %DO;
    %gmReplaceText(  dataIn   = &is_templib..speccoverpage
                   , dataOut  = &is_templib..speccoverpage
                   , textSearch = [\x0]+
                   , textReplace =
                   , useRegex = 1
                   , selectType = QUIET
    );

    %gmReplaceText(  dataIn   = &is_templib..specdata1
                   , dataOut  = &is_templib..specdata1
                   , textSearch = [\x0]+
                   , textReplace =
                   , useRegex = 1
                   , selectType = QUIET
    );

    %gmReplaceText(  dataIn   = &is_templib..specvar1
                   , dataOut  = &is_templib..specvar1
                   , textSearch = [\x0]+
                   , textReplace =
                   , useRegex = 1
                   , selectType = QUIET
    );

    %gmReplaceText(  dataIn   = &is_templib..speccodelist1a
                   , dataOut  = &is_templib..speccodelist1a
                   , textSearch = [\x0]+
                   , textReplace =
                   , useRegex = 1
                   , selectType = QUIET
    );
  %END;

  %* Get nonstandard variables from speccodelist1a;
  DATA _NULL_;
    LENGTH vars $200;
    dsid=OPEN("&is_templib..speccodelist1a","i");
    nvars=ATTRN(dsid,"nvars");
    DO i=1 TO nvars;
      IF UPCASE(VARNAME(dsid,i)) NOT IN ("A", "B", "C") THEN vars=STRIP(vars)||", a."||VARNAME(dsid,i);
    END;
    CALL SYMPUT("is_specCodeListVars",vars);
    rc=CLOSE(dsid);
  RUN;

  %* Check labels *;
  DATA _NULL_;
    LENGTH y $200;
    SET &is_templib..specdata1( OBS=2 );
    message1='%gmMessage( codeLocation = gmImportSpecification, selectType = ABORT, printStdOut = 1, linesOut = Column';
    message2='in the sheet "Dataset Metadata" has a different name than';
    retain _2rowsfl 0;
    IF _N_ = 1 THEN DO;
      IF COMPRESS(a, BYTE(13)||BYTE(10)) NE "Dataset Name" THEN
        y=RESOLVE(CATX(' ', message1, 'A' , message2, '"Dataset Name" A='||a, ')'));
      IF COMPRESS(b, BYTE(13)||BYTE(10)) NE "Dataset Label" THEN
        y=RESOLVE(CATX(' ', message1, 'B' , message2, '"Dataset Label" B='||b, ')'));
      IF COMPRESS(c, BYTE(13)||BYTE(10)) NE "Location(link label, leave missing for default)" THEN
        y=RESOLVE(CATX(' ', message1, 'C' , message2, '"Location(link label, leave missing for default)" C='||c, ')'));
      IF COMPRESS(d, BYTE(13)||BYTE(10)) NE "Dataset Structure" THEN
        y=RESOLVE(CATX(' ', message1, 'D' , message2, '"Dataset Structure" D='||d, ')'));
      IF COMPRESS(e, BYTE(13)||BYTE(10)) NE "Class of Dataset" THEN
        y=RESOLVE(CATX(' ', message1, 'E' , message2, '"Class of Dataset" E='||e, ')'));
      IF COMPRESS(f, BYTE(13)||BYTE(10)) NE "Documentation(presented in define.xml)" THEN
        y=RESOLVE(CATX(' ', message1, 'F' , message2, '"Documentation(presented in define.xml)" F='||f, ')'));
      IF COMPRESS(g, BYTE(13)||BYTE(10)) NE "Comments / Mapping instructions(not presented in define.xml)" THEN
        y=RESOLVE(CATX(' ', message1, 'G' , message2, '"Comments / Mapping instructions(not presented in define.xml)" G='||g, ')'));
      IF COMPRESS(h, BYTE(13)||BYTE(10)) NE "PAREXEL Standard Library Object Used?" THEN
        y=RESOLVE(CATX(' ', message1, 'H' , message2, '"PAREXEL Standard Library Object Used?" H='||h, ')'));
      IF COMPRESS(i, BYTE(13)||BYTE(10)) EQ "If Yes:" THEN _2rowsfl=1;
      ELSE DO;
        IF COMPRESS(i, BYTE(13)||BYTE(10)) NE "Standard Object ID" THEN
          y=RESOLVE(CATX(' ', message1, 'I' , message2, '"If Yes:" or "Standard Object ID" I='||i, ')'));
        IF COMPRESS(j, BYTE(13)||BYTE(10)) NE "Used without modification?" THEN
          y=RESOLVE(CATX(' ', message1, 'J' , message2, '"Used without modification?" J='||j, ')'));
      END;
    END;

    IF _2rowsfl AND _N_ = 2 THEN DO;
      IF COMPRESS(i, BYTE(13)||BYTE(10)) NE "Standard Object ID" THEN
        y=RESOLVE(CATX(' ', message1, 'I' , message2, '"Standard Object ID" I='||i, ')'));
      IF COMPRESS(j, BYTE(13)||BYTE(10)) NE "Used without modification?" THEN
        y=RESOLVE(CATX(' ', message1, 'J' , message2, '"Used without modification?" J='||j, ')'));
    END;
  RUN;

  DATA _NULL_;
    LENGTH y $200;
    SET &is_templib..specvar1( OBS=1 );
    message1='%gmMessage( codeLocation = gmImportSpecification, selectType = ABORT, printStdOut = 1, linesOut = Column';
    message2='in the sheet "Variable Metadata" has a different name than';

    IF COMPRESS(a, BYTE(13)||BYTE(10)) NE "Dataset Name" THEN
      y=RESOLVE(CATX(' ', message1, 'A' , message2, '"Dataset Name" A='||a, ')'));
    IF COMPRESS(b, BYTE(13)||BYTE(10)) NE "Parameter Identifier" THEN
      y=RESOLVE(CATX(' ', message1, 'B' , message2, '"Parameter Identifier" B='||b, ')'));
    IF COMPRESS(c, BYTE(13)||BYTE(10)) NE "Variable Name" THEN
      y=RESOLVE(CATX(' ', message1, 'C' , message2, '"Variable Name" C='||c, ')'));
    IF COMPRESS(d, BYTE(13)||BYTE(10)) NE "Variable Position" THEN
      y=RESOLVE(CATX(' ', message1, 'D' , message2, '"Variable Position" D='||d, ')'));
    IF COMPRESS(e, BYTE(13)||BYTE(10)) NE "Key / Unused Variable (1/NOT USED)" THEN
      y=RESOLVE(CATX(' ', message1, 'E' , message2, '"Key / Unused Variable (1/NOT USED)" E='||e, ')'));
    IF COMPRESS(f, BYTE(13)||BYTE(10)) NE "Sort Variables" THEN
      y=RESOLVE(CATX(' ', message1, 'F' , message2, '"Sort Variables" F='||f, ')'));
    IF COMPRESS(g, BYTE(13)||BYTE(10)) NE "Variable Label" THEN
      y=RESOLVE(CATX(' ', message1, 'G' , message2, '"Variable Label" G='||g, ')'));
    IF COMPRESS(h, BYTE(13)||BYTE(10)) NE "Variable Type" THEN
      y=RESOLVE(CATX(' ', message1, 'H' , message2, '"Variable Type" H='||h, ')'));
    IF COMPRESS(i, BYTE(13)||BYTE(10)) NE "Length" THEN
      y=RESOLVE(CATX(' ', message1, 'I' , message2, '"Length" I='||i, ')'));
    IF COMPRESS(j, BYTE(13)||BYTE(10)) NE "Display Format" THEN
      y=RESOLVE(CATX(' ', message1, 'J' , message2, '"Display Format" J='||j, ')'));
    IF COMPRESS(k, BYTE(13)||BYTE(10)) NE "Codelist" THEN
      y=RESOLVE(CATX(' ', message1, 'K' , message2, '"Codelist" K='||k, ')'));
    IF COMPRESS(l, BYTE(13)||BYTE(10)) NE "Related Codelist Variables / (Controlled Terms)" THEN
      y=RESOLVE(CATX(' ', message1, 'L' , message2, '"Related Codelist Variables / (Controlled Terms)" L='||l, ')'));
    IF COMPRESS(m, BYTE(13)||BYTE(10)) NE "Core" THEN
      y=RESOLVE(CATX(' ', message1, 'M' , message2, '"Core" M='||m, ')'));
    IF COMPRESS(n, BYTE(13)||BYTE(10)) NE "Role(SDTM)" THEN
      y=RESOLVE(CATX(' ', message1, 'N' , message2, '"Role(SDTM)" N='||n, ')'));
    IF COMPRESS(o, BYTE(13)||BYTE(10)) NE "Not NULL(1/NULL)(ADaM)" THEN
      y=RESOLVE(CATX(' ', message1, 'O' , message2, '"Not NULL(1/NULL)(ADaM)" O='||o, ')'));
    IF COMPRESS(p, BYTE(13)||BYTE(10)) NE "Origin" THEN
      y=RESOLVE(CATX(' ', message1, 'P' , message2, '"Origin" P='||p, ')'));
    IF COMPRESS(q, BYTE(13)||BYTE(10)) NE "Source / Derivation / Comment(presented in define.xml)" THEN
      y=RESOLVE(CATX(' ', message1, 'Q' , message2, '"Source / Derivation / Comment(presented in define.xml)" Q='||q, ')'));
    IF COMPRESS(r, BYTE(13)||BYTE(10)) NE "Comments / Mapping instructions(not presented in define.xml)" THEN
      y=RESOLVE(CATX(' ', message1, 'R' , message2, '"Comments / Mapping instructions(not presented in define.xml)" R='||r, ')'));
    IF COMPRESS(s, BYTE(13)||BYTE(10)) NE "Validation Checks" THEN
      y=RESOLVE(CATX(' ', message1, 'S' , message2, '"Validation Checks" S='||s, ')'));
  RUN;

  DATA _NULL_;
    LENGTH y $200;
    SET &is_templib..speccodelist1a( OBS=1 );
    message1='%gmMessage( codeLocation = gmImportSpecification, selectType = ABORT, printStdOut = 1, linesOut = Column';
    message2='in the sheet "Codelist" has a different name than';

    IF COMPRESS(a, BYTE(13)||BYTE(10)) NE "Codelist Name" THEN
      y=RESOLVE(CATX(' ', message1, 'A' , message2, '"Codelist Name" A='||a, ')'));
    IF COMPRESS(b, BYTE(13)||BYTE(10)) NE "Code" THEN
      y=RESOLVE(CATX(' ', message1, 'B' , message2, '"Code" B='||b, ')'));
    IF COMPRESS(c, BYTE(13)||BYTE(10)) NE "Decode" THEN
      y=RESOLVE(CATX(' ', message1, 'C' , message2, '"Decode" C='||c, ')'));
  RUN;

  %* Format specdata;
  DATA &is_templib..specdata( LABEL='Dataset Metadata' COMPRESS=Y );
    ATTRIB
    dsname LABEL="Dataset Name" LENGTH=$40 FORMAT=$40. INFORMAT=$40. /* column a */
    dslabel LABEL="Dataset Label" LENGTH=$256 FORMAT=$256. INFORMAT=$256. /* column b */
    dslocat LABEL="Location (link label, leave missing for default)"
            LENGTH=$320 FORMAT=$320. INFORMAT=$320. /* column c */
    dsstruc LABEL="Dataset Structure" LENGTH=$2000 FORMAT=$2000. INFORMAT=$2000. /* column d */
    dsclass LABEL="Class of Dataset" LENGTH=$80 FORMAT=$80. INFORMAT=$80. /* column e */
    dsdoc LABEL="Documentation (presented in define.xml)" LENGTH=$32767 FORMAT=$32767. INFORMAT=$32767. /* column f */
    dsco LABEL="Comments / Mapping instructions (not presented in define.xml)"
         LENGTH=$32767 FORMAT=$32767. INFORMAT=$32767. /* column g */
    dspxstfl LABEL="PAREXEL Standard Library Object Used?" LENGTH=$3 FORMAT=$3. INFORMAT=$3. /* column h */
    dspxstid LABEL="Standard Object ID" LENGTH=$80 FORMAT=$80. INFORMAT=$80. /* column i */
    dspxstmo LABEL="Used without modification?" LENGTH=$3 FORMAT=$3. INFORMAT=$3. /* column j */;
    SET &is_templib..specdata1( WHERE=(COMPRESS(UPCASE(a)) NOT IN ("", "ADDROWSABOVETHISONE"))
                               FIRSTOBS=2 );
    dsname   = a;
    dslabel  = b;
    dslocat  = c;
    dsstruc  = d;
    dsclass  = e;
    dsdoc    = f;
    dsco     = g;
    dspxstfl = h;
    dspxstid = i;
    dspxstmo = j;

    DROP a--j;
  RUN;

  %* Format specvar1;
  DATA &is_templib..specvar2;
    ATTRIB
    dsname   LABEL="Dataset Name" LENGTH=$40 FORMAT=$40. INFORMAT=$40. /* column a */
    paramid  LABEL="Parameter Identifier" LENGTH=$32767 FORMAT=$32767. INFORMAT=$32767. /* column b */
    vname    LABEL="Variable Name" LENGTH=$40 FORMAT=$40. INFORMAT=$40. /* column c */
    vpos     LABEL="Variable Position" LENGTH=$8 FORMAT=$8. INFORMAT=$8. /* column d */
    vkey     LABEL="Key / Unused Variable (1/NOT USED)" LENGTH=$8 FORMAT=$8. INFORMAT=$8. /* column e */
    vsort    LABEL="Sort Variables" LENGTH=$16 FORMAT=$16. INFORMAT=$16. /* column f */
    vlabel   LABEL="Variable Label" LENGTH=$256 FORMAT=$256. /* column g */
    vtype    LABEL="Variable Type" LENGTH=$32 FORMAT=$32. INFORMAT=$32. /* column h */
    vlength  LABEL="Length" LENGTH=$16 FORMAT=$16. INFORMAT=$16. /* column i */
    vformat  LABEL="Display Format" LENGTH=$32 FORMAT=$32. INFORMAT=$32. /* column j */
    vcodes   LABEL="Codelist" LENGTH=$32767 FORMAT=$32767. INFORMAT=$32767. /* column k */
    vrcodes  LABEL="Related Codelist Variables / (Controlled Terms)" LENGTH=$200 FORMAT=$200. INFORMAT=$200. /* column l */
    vcore    LABEL="Core" LENGTH=$40 FORMAT=$40. INFORMAT=$40. /* column m */
    vrole     LABEL="Role (SDTM)" LENGTH=$40 FORMAT=$40. INFORMAT=$40. /* column n */
    vnotnull LABEL="Not NULL (1/NULL) (ADaM)" LENGTH=$24 FORMAT=$24. INFORMAT=$24. /* column o */
    vorigin  LABEL="Origin" LENGTH=$200 FORMAT=$200. INFORMAT=$200. /* column p */
    vsource  LABEL="Source / Derivation (presented in define.xml)" LENGTH=$32767 FORMAT=$32767. INFORMAT=$32767. /* column q */
    vco      LABEL="Comments (not presented in define.xml)" LENGTH=$32767 FORMAT=$32767. INFORMAT=$32767. /* column r */
    vvalchk  LABEL="Validation Checks" LENGTH=$32767 FORMAT=$32767. INFORMAT=$32767. /* column s */;
    SET &is_templib..specvar1( WHERE=(COMPRESS(UPCASE(a)) NOT IN ("", "ADDROWSABOVETHISONE"))
                              FIRSTOBS=2 );
    dsname   = a;
    paramid  = b;
    vname    = c;
    vpos     = d;
    vkey     = e;
    vsort    = f;
    vlabel   = g;
    vtype    = h;
    vlength  = i;
    vformat  = j;
    vcodes   = k;
    vrcodes  = l;
    vcore    = m;
    vrole    = n;
    vnotnull = o;
    vorigin  = p;
    vsource  = q;
    vco      = r;
    vvalchk  = s;

    DROP a--s;
  RUN;

  %*derive codelistId;
  DATA &is_templib..specvar3;
    SET &is_templib..specvar2;
    %*record the orignal order;
    orignalOrder = _n_;
    %*remove \r \n;
    vrcodes = PRXCHANGE("s/\s+/ /",-1,strip(vrcodes));

    LENGTH codelistId $200;
    IF PRXMATCH("/\(.+\)/",STRIP(vrcodes)) THEN DO;
      codeListId = PRXCHANGE("s/.*\(\+?(.+)\).*/\1/",1,vrcodes);
      codelistId = TRANWRD(codelistId, "&escapeChar.", '.');
    END;
    ELSE IF NOT MISSING(vcodes) THEN DO;
      IF UPCASE(paramId) = "*ALL*" THEN
        codelistId = STRIP(dsname) || "." || STRIP(vname);
      ELSE IF UPCASE(paramId) = "*DEFAULT*" THEN
        codelistId = STRIP(dsname) || "." || STRIP(vname) || ".DEFAULT";
      ELSE IF PRXMATCH("/^\w{1,16}$/",STRIP(paramId)) and UPCASE(paramId) NE "DEFAULT" THEN
        codelistId = STRIP(dsname) || "." || STRIP(vname) || "." || STRIP(paramid);
      ELSE DO;
        codelistId = STRIP(dsname) || "." || STRIP(vname) || "." || PUT(MD5(COMPRESS(paramid)),HEX16.);
        MD5FL = 1;
      END;
    END;
  RUN;

  PROC SORT DATA=&is_templib..specvar3 OUT=&is_templib..specvar4;
    BY dsname vname codelistId paramid;
  RUN;

  %*add .1, .2, .3 in case codelistId is the same;
  DATA &is_templib..specvar5;
    SET &is_templib..specvar4;
    BY dsname vname codelistId;
    RETAIN addId 0;
    IF NOT (FIRST.codelistId AND LAST.codelistId) AND MD5FL THEN DO;
      IF FIRST.codelistId THEN addId = 1;
      ELSE addId + 1;
      codelistId = STRIP(codelistId) || "." || STRIP(PUT(addId,BEST.));
    END;
  RUN;

  %*Sort back to orignal Order;
  PROC SORT DATA=&is_templib..specvar5
             OUT=&is_templib..specvar(drop=orignalOrder addId MD5FL LABEL='Variable Metadata' COMPRESS=Y);
    BY orignalOrder;
  RUN;

  %*start to create the second part of speccodelist;
  DATA &is_templib..speccodelist2a;
    SET &is_templib..specvar;
    %*remove \r \n;
    vcodes = PRXCHANGE("s/[\xA\xD]+//",-1,strip(vcodes));
  RUN;

  %*separate codes in single lines, and replace ",,", "==" with ",", "=";
  DATA &is_templib..speccodelist2b( KEEP = codelistId vrcodes code decode vcodes_sep checkId vcodes_sepId);
    SET &is_templib..speccodelist2a(WHERE=(NOT MISSING(vcodes) AND INDEX(STRIP(vcodes),"&escapeChar.EXTERNAL") NE 1
                                           AND vkey NE "NOT USED"));
    %*for Check codelist and sort code whose codelists start with +;
    checkId = _n_;

    LENGTH vcodes_sep $32767 code decode $400;
    vcodes_sepId = 0;
    DO WHILE (vcodes NE "");
      vcodes_sep = PRXCHANGE("s/^(([^,]|,,)+),?.*$/\1/", 1, STRIP(vcodes));

      code = PRXCHANGE("s/^(([^=]|==)+)=?(([^=]|==)*).*$/\1/", 1, STRIP(vcodes_sep));
      decode = PRXCHANGE("s/^(([^=]|==)+)=?(([^=]|==)*).*$/\3/", 1, STRIP(vcodes_sep));

      code = STRIP(TRANWRD(TRANWRD(code, ",,", ","), "==", "="));
      decode = STRIP(TRANWRD(TRANWRD(decode, ",,", ","), "==", "="));
      OUTPUT;

      vcodes = PRXCHANGE("s/^([^,]|,,)+,?//", 1, STRIP(vcodes));
      vcodes_sepId + 1;
    END;
  RUN;

  %*check Codelists without + prefix in specvar have the same name, but different values;
  %IF &checkCodelist. %THEN %DO;
    PROC SORT DATA=&is_templib..speccodelist2b(WHERE=( PRXMATCH("/\(\+/",vrcodes) = 0 ))
              OUT=&is_templib..speccodelistCheck1(KEEP = checkId codelistId vcodes_sep);
      BY checkId codelistId vcodes_sep;
    RUN;

    DATA &is_templib..speccodelistCheck2;
      SET &is_templib..speccodelistCheck1;
      BY checkId codelistId;
      LENGTH vcodes1 $32767;
      RETAIN vcodes1 "";
      IF FIRST.codelistId THEN vcodes1=vcodes_sep;
      ELSE vcodes1=CATX(",", vcodes1, vcodes_sep);
      IF LAST.codelistId THEN OUTPUT;
    RUN;

    PROC SORT DATA=&is_templib..speccodelistCheck2
               OUT=&is_templib..speccodelistCheck3 NODUPKEY;
      BY codelistId vcodes1;
    RUN;

    DATA _NULL_;
      SET &is_templib..speccodelistCheck3 END=eof;
      BY codelistId;
      LENGTH checkCodelistId1 $32767;
      RETAIN checkCodelistId1 "";
      IF FIRST.codelistId AND NOT LAST.codelistId THEN
        checkCodelistId1=CATX(", ", checkCodelistId1, codelistId );
      IF eof AND NOT MISSING(checkCodelistId1) THEN
        CALL SYMPUT("is_checkCodelistId1", "The Codelist(s) "||STRIP(checkCodelistId1)
                    ||" have the same name but different values.");
    RUN;
  %END;

  %* Format speccodelist1;
  DATA &is_templib..speccodelist1b;
    SET &is_templib..speccodelist1a( WHERE=(COMPRESS(UPCASE(a)) NOT IN ("", "ADDROWSABOVETHISONE"))
                                     FIRSTOBS=2 );
    LENGTH codelistId $200;
    codelistId = TRANWRD(COMPRESS(a," ()+"), "&escapeChar.", ".");

    vcodes_sepId = _n_;

    RENAME a = vrcodes
           b = code
           c = decode;
  RUN;

  %*check whether a codelist exists in both "Variable Metadata" and "Codelist" tabs;
  %*speccodelist2b is from specvar where vcode is not missing;
  %IF &checkCodelist. %THEN %DO;
    PROC SQL NOPRINT;
      CREATE TABLE &is_templib..speccodelistCheck4 as
      SELECT DISTINCT b.codelistId
      FROM &is_templib..speccodelist2b AS a
      JOIN &is_templib..speccodelist1b AS b
      ON a.codelistId=b.codelistId;
    QUIT;

    DATA _NULL_;
      SET &is_templib..speccodelistCheck4 END=eof;
      LENGTH checkCodelistId2 $32767;
      RETAIN checkCodelistId2 "";
      checkCodelistId2=CATX(", ", checkCodelistId2, codelistId );

      IF eof AND NOT MISSING(checkCodelistId2) THEN DO;
        IF %gmCheckValueExists( codeLocation = gmImportSpecification/Check codelist
                              , value        = %BQUOTE(&is_checkCodelistId1.) ) THEN at="@";
        ELSE at="";
        CALL SYMPUT("is_checkCodelistId2", STRIP(at)||"The Codelist(s) "||STRIP(checkCodelistId2)
                    ||' exist in both "Variable Metadata" and "Codelist" tabs.');
      END;
    RUN;

    %IF %gmCheckValueExists( codeLocation = gmImportSpecification/Check codelist
                           , value        = %BQUOTE(&is_checkCodelistId1.&is_checkCodelistId2.) ) %THEN %DO;
      %gmMessage( codeLocation = gmImportSpecification/Check codelist
                , selectType   = &selectType.
                , linesOut     = %BQUOTE(&is_checkCodelistId1.&is_checkCodelistId2.)
                %IF &selectType EQ ABORT %THEN , printStdOut = 1;
                );
    %END;
  %END;

  DATA &is_templib..speccodelist3a;
    LENGTH codelistId name subset vrcodes $200 code decode $400;
    SET &is_templib..speccodelist2b( KEEP = codelistId vrcodes code decode checkId vcodes_sepId)
        &is_templib..speccodelist1b( IN = in1b ) NOBS=totobs;

    IF PRXMATCH("/\(.+\)/",STRIP(vrcodes)) THEN vrcodes = PRXCHANGE("s/.*\(\+?(.+)\).*/\1/",1,vrcodes);
    name = STRIP(SCAN(vrcodes, 1, "&escapeChar."));
    subset = STRIP(SCAN(vrcodes, 2, "&escapeChar."));

    IF in1b THEN  DO;
      vcodes_sepId = vcodes_sepId + totobs;
      checkId = totobs + 1;
    END;

    LABEL codelistId = "Codelist ID"
          subset     = "Subset Name"
          code       = "Code"
          decode     = "Decode";

    INFORMAT _ALL_;
    FORMAT _ALL_;
  RUN;

  PROC SORT DATA=&is_templib..speccodelist3a
             OUT=&is_templib..speccodelist3b NODUPKEY;
    BY codelistId subset code decode;
  RUN;

  PROC SQL NOPRINT;
    %*merge codelist IDs;
    CREATE TABLE &is_templib..speccodelist3c AS
    SELECT a.*, b.codelistId AS codelistIdRef, b.listcode, b.extensibleFlag,
      CASE WHEN NOT MISSING(b.codelistName) AND MISSING(a.subset) THEN
             STRIP(b.codelistName)
           WHEN MISSING(b.codelistName) AND NOT MISSING(a.subset) THEN
             STRIP(a.codelistId)||" (Subset "||STRIP(a.subset)||")"
           WHEN NOT MISSING(b.codelistName) AND NOT MISSING(a.subset) THEN
             STRIP(b.codelistName)||" (Subset "||STRIP(a.subset)||")"
           ELSE ""
      END AS label LABEL="Codelist Label"
    FROM &is_templib..speccodelist3b AS a
    LEFT JOIN (SELECT DISTINCT listCode, codelistId, codelistName, extensibleFlag
               FROM &dataTermIn.) AS b
    ON a.name = b.codelistId;

    %*merge value IDs;
    CREATE TABLE &is_templib..speccodelist(DROP=checkId vcodes_sepId LABEL="Codelist" COMPRESS=Y) AS
    SELECT a.checkId, a.vcodes_sepId,
      a.codelistId, a.label, a.subset, a.code, a.decode,
      a.codelistIdRef, a.listcode, b.valueCode, a.extensibleFlag
      &is_specCodeListVars.
    FROM &is_templib..speccodelist3c AS a
    LEFT JOIN &dataTermIn. AS b
    ON a.name = b.codelistId and a.code = b.codes
    ORDER BY codelistId, checkId, vcodes_sepId;
  QUIT;

  %*associatie output library with a temporary libref;
  %*to set the waiting seconds if an imported dataset is locked;
  LIBNAME gmMeta&gmLibCount. "%SYSFUNC(PATHNAME(&libOut.))" FILELOCKWAIT=&lockWait.;

  %IF NOT %SYSFUNC(EXIST(gmMeta&gmLibCount..speccoverpage)) %THEN %DO;
    %*copy speccoverpage to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT speccoverpage;
    QUIT;
  %END;
  %ELSE %DO;
    %*try to lock gmMeta&gmLibCount..speccoverpage;
    LOCK gmMeta&gmLibCount..speccoverpage;

    %*copy speccoverpage to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT speccoverpage;
    QUIT;

    %*unlock gmMeta&gmLibCount..speccoverpage;
    LOCK gmMeta&gmLibCount..speccoverpage CLEAR;
  %END;

  %IF NOT %SYSFUNC(EXIST(gmMeta&gmLibCount..specdata)) %THEN %DO;
    %*copy specdata to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT specdata;
    QUIT;
  %END;
  %ELSE %DO;
    %*try to lock gmMeta&gmLibCount..specdata;
    LOCK gmMeta&gmLibCount..specdata;

    %*copy specdata to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT specdata;
    QUIT;

    %*unlock gmMeta&gmLibCount..specdata;
    LOCK gmMeta&gmLibCount..specdata CLEAR;
  %END;

  %IF NOT %SYSFUNC(EXIST(gmMeta&gmLibCount..specvar)) %THEN %DO;
    %*copy specvar to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT specvar;
    QUIT;
  %END;
  %ELSE %DO;
    %*try to lock gmMeta&gmLibCount..specvar;
    LOCK gmMeta&gmLibCount..specvar;

    %*copy specvar to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT specvar;
    QUIT;

    %*unlock gmMeta&gmLibCount..specvar;
    LOCK gmMeta&gmLibCount..specvar CLEAR;
  %END;

  %IF NOT %SYSFUNC(EXIST(gmMeta&gmLibCount..speccodelist)) %THEN %DO;
    %*copy speccodelist to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT speccodelist;
    QUIT;
  %END;
  %ELSE %DO;
    %*try to lock gmMeta&gmLibCount..speccodelist;
    LOCK gmMeta&gmLibCount..speccodelist;

    %*copy speccodelist to gmMeta&gmLibCount. library;
    PROC COPY IN=&is_templib OUT=gmMeta&gmLibCount.;
      SELECT speccodelist;
    QUIT;

    %*unlock gmMeta&gmLibCount..speccodelist;
    LOCK gmMeta&gmLibCount..speccodelist CLEAR;
  %END;

  %*deassign the temporary libref;
  LIBNAME gmMeta&gmLibCount. CLEAR;

  %*check data;
  %*gmCheckSpecification

  %*restore option;
  OPTION VALIDVARNAME=&is_saveValidvarname.;

  %gmEnd( headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmimportspecification.sas $ )

%MEND gmImportSpecification;
