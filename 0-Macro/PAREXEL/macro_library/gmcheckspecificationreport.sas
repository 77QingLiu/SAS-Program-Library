/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        222354 

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dmitry Kolosov  $LastChangedBy: kolosod $
  Creation Date:         09SEP2014       $LastChangedDate: 2016-10-25 05:12:55 -0400 (Tue, 25 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcheckspecificationreport.sas $

  Files Created:         Report with all of the issues found.
                         * gmSpecificationReport.pdf
                         * gmSpecificationReport.xls (optional)

  Program Purpose:       The macro runs PXL checks against datasets created by gmImportSpecification

  Macro Parameters:

    Name:                datasCheck
      Default Value:     BLANK
      Description:       List of datasets to be checked. Contains one or more datasets without a library name, e.g., adsl@adlb@lb.
                         If left missing, then all datasets are checked.

    Name:                pathOut
      Default Value:     &_global.
      Description:       Path to a folder where the report should be saved.

    Name:                fileOut   
      Allowed Values:    default \suffix=text | projarea \suffix=text | full \suffix=text | user \suffix=text
      Default Value:     default
      Description:       Naming convention for report filename: 
                         # default: gmSpecificatonReport.pdf
                         # user: dependent on user executing macro, e.g. gmSpecificationReport_{user}.pdf
                         # projarea: dependant on project area, e.g. gmSpecificationReport_{&_type.}.pdf
                         # full: dependent on project area and run date/time, e.g. gmSpecificationReport_{&_type}_{date/time}.pdf
                         #Option \suffix adds a text to the end of the filename.       

    Name:                sendEmail
      Allowed Values:    1 | 0
      Default Value:     0
      Description:       Controls whether an e-mail is send to the user.

    Name:                libSpecIn
      Default Value:     metadata
      Description:       Name of the library with datasets created by gmImportSpecification.

    Name:                libDataIn
      Default Value:     &_global.
      Description:       Name of SDTM/ADaM library which will be used to autoload datasets for additional checks.

    Name:                createXLS
      Allowed Values:    1 | 0
      Default Value:     0
      Description:       Controls whether a XLS file is created. 1 - create xls, 0 - do not create.

    Name:                escapeChar
      Allowed Values:    
      Default Value:     ~
      Description:       Separator character for linking CRF, SAP, Dataguide or other documents.
                         Can be used to control other functionality within the spec. 
                         #See gmDefineXml macro for details.


    Name:                splitChar
      Default Value:     @
      Description:       Split character to separate datasCheck/libsIn values.

    Name:                lockWait
      Allowed Values:    0 - 600
      Default Value:     30
      Description:       Number of seconds SAS waits in case output dataset is locked.


  Macro Returnvalue:

      Description:       Macro does not return any values.

  Metadata Keys:


  Macro Dependencies:    gmMessage (called)
                         gmStart (called)
                         gmEnd (called)
                         gmReplaceText (called)
                         gmModifySplit (called)
                         gmGetUserName (called)
                         gmTrimVarLen (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2798 $
-----------------------------------------------------------------------------*/

%macro gmCheckSpecificationReport( datasCheck=
                            ,pathOut=&_global.
                            ,fileOut=default
                            ,libSpecIn=metadata
                            ,libDataIn=
                            ,checkData=1
                            ,sendEmail=0
                            ,createXls=0
                            ,escapeChar=~
                            ,splitChar=@
                            ,lockWait=30
                           );

%local gcs_libName;

%let gcs_libName = %gmStart(
    headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcheckspecificationreport.sas $
    ,checkMinSasVersion = 9.2
    ,revision = $Rev: 2798 $
    ,libRequired = 1
);

%*let gcs_libName = work;

%* Save options;
proc optsave out=&gcs_libName..options;
run;

%local 
    gcs_dsList
    gcs_libNum
    gcs_asDatanObs
    gcs_libIn
    gcs_i
    gcs_currDs
    gcs_keepReportVars
    gcs_locksyserrbefore
    gcs_locksyserrafter
    gcs_errortext
    gcs_model
;

* Redirect working library to the GML library;
options user=&gcs_libName compress=Y;

%*-------------------------------------------------------------------------------------------------
 Parameter checks
---------------------------------------------------------------------------------------------------;

* Check the pathOut;

%if not %sysfunc(fileExist(%nrbQuote(&pathOut))) %then %do;
        %gmMessage(codeLocation = gmCheckSpecificationReport/Parameter checks
                  , linesOut     = PathOut directory %nrbQuote(&pathOut) does not exist.
                  , selectType   = ABORT
                  , printStdOut  = 1
                  , sendEmail    = &sendEmail
                  );
%end;
%else %do;
    %let pathOut=%nrbQuote(&pathOut./);
    /* Remove repeating slashes */
    %let pathOut=%sysfunc(prxChange(s#/+#/#, -1, %nrbQuote(&pathOut)));
    /* Symbolic link path */
    %let pathOut=%sysfunc(prxChange(s#^(/project\d+/)#/projects/#, 1, %nrbQuote(&pathOut)));
%end;

%if %length(%superQ(splitChar)) ne 1 %then %do;
    %gmMessage(codeLocation = gmCheckSpecificationReport/Parameter checks
               , linesOut    = %str(Value of macro parameter SplitChar is invalid, must be a single character.)
               , selectType  = ABORT
               , printStdOut = 1
               , sendEmail   = &sendEmail
               );
%end;

%if %superQ(sendEmail) ne 0 and %superQ(sendEmail) ne 1 %then %do;
    %gmMessage(codeLocation = gmCheckSpecificationReport/Parameter checks
              , linesOut     = %str(Value of macro parameter sendEmail is invalid, valid values are 0, 1.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              ); 
%end;

%if %superQ(createXls) ne 0 and %superQ(createXls) ne 1 %then %do;
    %gmMessage(codeLocation = gmCheckSpecificationReport/Parameter checks
              , linesOut     = %str(Value of macro parameter createXls is invalid, valid values are 0, 1.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              ); 
%end;

%if %superQ(lockWait) < 0 or %superQ(lockWait) > 600 %then %do;
    %gmMessage(codeLocation = gmCheckSpecificationReport/Parameter checks
              , linesOut     = %str(Value of macro parameter lockWait is invalid, valid values are 0 - 600.)
              , selectType   = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
              );
%end;

* Check fileOut parameter;
%if not %sysFunc(prxMatch(/(default|user|projarea|full)(\s*\\suffix\s*=\s*\S+)?/i,%superQ(fileOut)))
    %then %do;
    %gmMessage( codeLocation = gmCheckSpecificationReport/Parameter checks
              , linesOut = Incorrect value of the fileOut parameter: %superQ(fileOut)
              , selectType = ABORT
              , printStdOut  = 1
              , sendEmail    = &sendEmail
             );                 
%end;

%* Check datasets exist;
%if not %sysFunc(exist(&libSpecIn..specCoverPage))
    or
    not %sysFunc(exist(&libSpecIn..specData))
    or
    not %sysFunc(exist(&libSpecIn..specVar))
    or
    not %sysFunc(exist(&libSpecIn..specCodelist))
    %then %do;
    %gmMessage(codeLocation = gmCheckSpecificationReport/Parameter checks
               ,linesOut = %str(This macro requires specCoverPage, specData, specVar, specCodelist datasets to run.)
               ,selectType=ABORT     
              );
%end;

%*-------------------------------------------------------------------------------------------------
 Constants
---------------------------------------------------------------------------------------------------;

%let gcs_dsList = "%upcase(%qSysFunc(tranWrd(&datasCheck,%superQ(splitChar)," ")))";
%let gcs_keepReportVars = dsname vname recId code;
data _null_;
    length escapeCharRegex $10;

    * Escape character for regular expressions;
    if index("&escapeChar.","\().+*[]@{}|?$^/") then do;
        escapeCharRegex = "\&escapeChar.";
    end;
    else do;
        escapeCharRegex = "&escapeChar.";
    end;
    call symputx("gcs_escapeCharRegex",strip(escapeCharRegex),"L");

    * Output filename;
    length reportFileLocationPdf reportFileLocationXls $4096 reportFileName fileNameSuffix $256;

    if lowcase("&fileOut") =: "default" then do;
        reportFileName = "gmCheckSpecificationReport";
    end;
    else if lowcase("&fileOut") =: "user" then do;
        reportFileName = "gmCheckSpecificationReport_&sysUserId.";
    end;
    else if lowcase("&fileOut") =: "projarea" then do;
        reportFileName = "gmCheckSpecificationReport_"||symGet("_type");
    end;
    else if lowcase("&fileOut") =: "full" then do;
        reportFileName = "gmCheckSpecificationReport_"||symGet("_type") || "_" 
                         || put(date(), yymmddn8.)||"T"||compress(cats(tranwrd(put(time(), tod5.), ":", "")));
    end;

    ** Get suffix value if it was provided;
    if prxMatch("/\\suffix/","&fileOut") then do;
        fileNameSuffix = "_" || strip(prxChange("s/\w+\s*\\suffix\s*=\s*(.*)/$1/i",1,"&fileOut"));
    end;

    if not missing(fileNameSuffix) then do;
        reportFileName = cats(reportFileName,fileNameSuffix);
    end;

    * Full path to file;
    reportFileLocationPdf = cats(symGet("pathOut"),reportFileName,".pdf");
    call symputx("gcs_reportFileLocationPdf",strip(reportFileLocationPdf),"L");
    * Samba link path;
    call symputx("gcs_sambaLinkPdf"
                 ,strip(prxChange("s#^/projects/#\\kennet.na.pxl.int#",1,reportFileLocationPdf))
                 ,"L"
                );

    if symGet("createXls") eq "1" then do;
        reportFileLocationXls = cats(symGet("pathOut"),reportFileName,".xls");
        call symputx("gcs_reportFileLocationXls",strip(reportFileLocationXls),"L");
        call symputx("gcs_sambaLinkXls"
                     ,strip(prxChange("s#^/projects/#\\kennet.na.pxl.int#",1,reportFileLocationXls))
                     ,"L"
                    );
    end;
run;

filename gcs_rPdf "&gcs_reportFileLocationPdf.";
* Delete current output file if exists;
%if %sysFunc(fexist(gcs_rPdf)) %then %do;
    data _null_;
        x=fdelete("gcs_rPdf");
    run;
%end;

%if &createXls = 1 %then %do;
    filename gcs_rXls "&gcs_reportFileLocationXls.";
    * Delete current output file if exists;
    %if %sysFunc(fexist(gcs_rXls)) %then %do;
        data _null_;
            x=fdelete("gcs_rXls");
        run;
    %end;
%end;

%*-------------------------------------------------------------------------------------------------
 Copy and update spec datasets
---------------------------------------------------------------------------------------------------;

%* Copy the dataset to the working library;
proc copy in = &libSpecIn. out = &gcs_libName;
    select specVar specCodelist specData specCoverPage;
run;

%* Keep only datasets specified in datasCheck;
%if %superQ(datasCheck) ne %then %do;
    data specVarFiltered(where = (upcase(dsName) in (&gcs_dsList.) and upcase(vKey) ne "NOT USED"));
        set specVar;

        paramId = strip(paramId);
        recId = _n_;
    run;

    data specData;
        set specData(where = (upcase(dsName) in (&gcs_dsList.)));
    run;
%end;
%else %do;
    data specVarFiltered(where = (upcase(vKey) ne "NOT USED"));
        set specVar;

        paramId = strip(paramId);
        recId = _n_;
    run;
%end;

%* Replace special characters;
%do gcs_i = 1 %to 4;
    %if &gcs_i = 1 %then %do;
        %let gcs_currDs = specVarFiltered;
    %end;
    %else %if &gcs_i = 2 %then %do;
        %let gcs_currDs = specCodelist;
    %end;
    %else %if &gcs_i = 3 %then %do;
        %let gcs_currDs = specData;
    %end;
    %else %if &gcs_i = 4 %then %do;
        %let gcs_currDs = specCoverPage;
    %end;

    %* remove excel cell breaks ;
    %if &gcs_currDs = specVarFiltered %then %do;
        %gmReplaceText(  dataIn   = &gcs_currDs
                       , dataOut  = &gcs_currDs
                       , textSearch = [\xA\xD]
                       , textReplace = %str( )
                       , useRegex = 1
                       , selectType = QUIET
                       , includeVars = paramId@vcodes@vrcodes
        );
    %end;
    %else %if &gcs_currDs = specCodelist %then %do;
        %gmReplaceText(  dataIn   = &gcs_currDs
                       , dataOut  = &gcs_currDs
                       , textSearch = [\xA\xD]
                       , textReplace = %str( )
                       , useRegex = 1
                       , selectType = QUIET
                       , includeVars = code@decode
        );
    %end;
%end;

* Get real data values;
%if %superQ(libDataIn) ne and &checkData eq 1 %then %do;
    proc contents noprint data = &libDataIn.._all_ 
                  out = libInfoRaw(keep = libName memLabel memName name length format formatL formatD varNum label type);
    run;

    * Derive format;
    data libInfoFull;
        set libInfoRaw;

        name = upcase(name);
        memName = upcase(memName);

        lengthAsData = length;
        %* Derive format;
        length formatAsData $32;
        if not missing(format) then do;
            formatAsData = format;
        end;
        if formatL > 0 then do;            
            formatAsData = strip(format)||strip(put(formatL,best.));
        end;
        if formatD > 0 then do;
            formatAsData = strip(formatAsData) || "." || strip(put(formatD,best.));
        end;
    run;
%end;

* Derive length/parameter based on dataset values;
* Get number of observations with ASDATA length;
proc sql noprint;
    select count(*) into :gcs_asDatanObs
    from specVarFiltered
    where upcase(vLength) = "&escapeChar.ASDATA"
;
quit;

%if &gcs_asDatanObs > 0 and %superQ(libDataIn) ne and &checkData eq 1 %then %do;

    data adVarLengthAsData0;
        set specVarFiltered(where = (upcase(vLength) = "&escapeChar.ASDATA"));    
    run;

    data libInfo(keep = memName name lengthAsData formatAsData);
        set libInfoFull;
    run;
   
    proc SQL noprint;
        create table adVarLengthAsData1 as
        select a.*, b.lengthAsData, b.formatAsData
        from adVarLengthAsData0 as a 
             left join        
             libInfo as b
             on (a.vName = b.name and a.dsName = b.memName)
        ;
    quit;

    data adVarLengthAsData2(drop = lengthAsData formatAsData);
        set adVarLengthAsData1;
        vLength = strip(put(lengthAsData,best.));
        if missing(vFormat) then do;
            vFormat = formatAsData;
        end;
    run;

    data specVarFiltered;
        set specVarFiltered(where = (upcase(vLength) ne "&escapeChar.ASDATA")) adVarLengthAsData2;
        proc sort; by recId;
    run;
%end;

***********************************************************************************;
*  Load study and model information
***********************************************************************************;

data coverPage(keep = key value);
    set specCoverPage;

    length value key $32767;

    value = c;
    key = b;
run;

data modelInfo;
    set coverPage end = lastObs;   

    length studyName protocolName $200 sponsorName $60 cdiscVer cdiscIgVer $40;

    retain studyName studyDesc protocolName sponsorName cdiscModel cdiscVer cdiscIgVer;

    if upcase(key) eq "STUDY NAME" then do;
        studyName = value;
    end;
    else if upcase(key) eq "STUDY DESCRIPTION" then do;
        studyDesc = value;
    end;
    else if upcase(key) eq "SPONSOR NAME:" then do;
        sponsorName = value;
    end;
    else if upcase(key) eq "PROTOCOL NAME" then do;
        protocolName = value;
    end;
    else if upcase(key) eq "CDISC MODEL" then do;
        cdiscModel = value;
        if upcase(value) eq "SDTM" then do;
            call symputx("gcs_model","SDTM","L"); 
        end;
        else if upcase(value) eq "ADAM" then do;
            call symputx("gcs_model","ADaM","L"); 
        end;
    end;
    else if upcase(key) eq "CDISC MODEL VERSION" then do;
        cdiscVer = value;
    end;
    else if upcase(key) eq "CDISC IMPLEMENTATION GUIDE VERSION" then do;
        cdiscIgVer = value;
    end;

    if lastObs then do;
        output;
    end;
run;

data chkStdStudyAndModel(keep = code details);
    set modelInfo;

    length code $8 details $2048;

    if upcase(cdiscModel) not in ("SDTM" "ADAM") then do;
        code = "STD001";
        details = catx(" ","Model: ", cdiscModel);
        output;
    end;

    if missing(sponsorName) then do;
        details = " ";
        code = "STD002";
        output;
    end;

    if missing(studyName) 
       or strip(studyName) = "The short, external name assigned to the Study." then do;
        details = " ";
        code = "STD003";
        output;
    end;

    if missing(studyDesc) 
       or strip(studyDesc) =: "A text description of the contents of the Study." then do;
        details = " ";
        code = "STD004";
        output;
    end;

    if missing(protocolName) 
       or prxMatch("/The sponsor.?s internal name assigned to the Study/i",strip(protocolName))
    then do;
        details = " ";
        code = "STD005";
        output;
    end;

    if missing(cdiscVer) then do;
        details = " ";
        code = "STD006";
        output;
    end;
    else if not prxMatch("/^\d+(\.\d+)?$/",strip(cdiscVer)) then do;
        details = " ";
        code = "STD007";
        output;
    end;

    if not missing(protocolName) and protocolName = studyName then do;
        details = " ";
        code = "STD008";
        output;
    end;

    if missing(cdiscIgVer) then do;
        details = " ";
        code = "STD009";
        output;
    end;
    else if not prxMatch("/^\d+(\.\d+)?$/",strip(cdiscIgVer)) then do;
        details = " ";
        code = "STD010";
        output;
    end;
run;

***********************************************************************************;
* Prepare the Variable Metadata tab for analysis
***********************************************************************************;

data varMeta;
    set specVarFiltered;

    * Extract governance variable;
    length vNameFull govVar $32 vTypeSas $4;
    govVar = upcase(scan(vrCodes,1,",","m"));
    if prxMatch("/^\(/",strip(govVar)) or govVar eq: "&escapeChar.EXTERNAL" then do;
        * Only codelist is specified;
        govVar = "";
    end;
    * Full variable name for SQL;
    vNameFull = upcase(catx(".",dsName,vName));

    * Upcase *ALL* and *DEFAULT*;
    if upcase(paramId) in ("*ALL*", "*DEFAULT*") then do;
        paramId = upcase(paramId);
    end;

    * VLM Type;
    if paramId ne "*ALL*" then do;
        if index(paramId, "&escapeChar.WHERE") ne 0 then do; 
            vlmType = 2;
        end;
        else do;
            vlmType = 1;
        end;
    end;
    else do;
        vlmType = 0;
    end;

    * Default flag;
    if paramId = "*DEFAULT*" then do;
        defaultFl = 1;
    end;
    else do;
        defaultFl = 0;
    end;

    * SAS variable type;
    if upcase(vType) in ("FLOAT","INTEGER") then do;
        vTypeSas = "num";
    end;
    else if not missing(vType) then do;
        vTypeSas = "char";
    end;
run;

***********************************************************************************;
* Basic Variable Attribute Checks
***********************************************************************************;

data chkVarBasicAttributeChecks(keep = &gcs_keepReportVars details);
    set varMeta;

    length code $8 details $2048;

    if missing(dsName) then do;
        code = "VAR001";
        output;
    end;

    if missing(paramId) then do;
        code = "VAR002";
        output;
    end;

    if length(vName) > 8 or missing(vName) then do;
        code = "VAR003";
        output;
    end;

    if missing(vPos) or not prxMatch("/^\d+$/",strip(vPos)) then do;
        code = "VAR004";
        if not missing(vPos) then do;
            details = catx(" ","Variable Position:",vPos);
        end;
        output;
    end;

    if not missing(vKey) and strip(vKey) ne "1" then do;
        code = "VAR005";
        output;
    end;

    if strip(vKey) eq "1" and not prxMatch("/^\d+$/",strip(vSort))
    then do;
        code = "VAR006";
        if not missing(vSort) and strip(vKey) eq "1" then do;
            details = catx(" ","Sort:",vSort);
        end;
        output;
    end;

    if missing(vLabel) or length(vLabel) > 40 then do;
        code = "VAR007";
        output;
    end;

    if prxMatch("/[^\x20-\x7F]/",strip(vLabel)) then do;
        code = "VAR008";
        details = catx(" ","Label:",vLabel);
        output;
    end;

    if strip(vType) not in ("text" "integer" "float" "datetime" "date" "time" 
                            "partialDate" "partialTime" "partialDatetime" 
                            "incompleteDatetime" "durationDatetime")
       or (missing(vType) and paramId = "*ALL*")
    then do;
        code = "VAR009";
        details = catx(" ","Type:",vType);
        output;
    end;

    if not prxMatch("/^\$?(\d{1,2}|1\d{2}|200)$/",strip(vLength))  and vLength ne "&escapeChar.ASDATA" 
       or (missing(vLength) and paramId = "*ALL*")
    then do;
        code = "VAR010";
        details = catx(" ","Length:",vLength);
        output;
    end;

    if vType eq "float" and not prxMatch("/&gcs_escapeCharRegex.S|\.\d/",strip(vFormat)) 
       and vLength ne "&escapeChar.ASDATA" 
    then do;
        code = "VAR011";
        output;
    end;

    if prxMatch("/0{4}|9{4}/",strip(vFormat)) then do;
        code = "VAR025";
        details = "Resulting format imported in SAS: " || strip(vFormat);
        output;
    end;

    if prxMatch("/^[^\$].+/",strip(vFormat)) and vTypeSas eq "char" then do;
        code = "VAR028";
        details = catx(" ","Format:",vFormat);
        output;
    end;

    if prxMatch("/^\$.+/",strip(vFormat)) and vTypeSas eq "num" then do;
        code = "VAR029";
        details = catx(" ","Format:",vFormat);
        output;
    end;

    if prxMatch("/.+\.$/",strip(vFormat)) then do;
        code = "VAR030";
        details = catx(" ","Format:",vFormat);
        output;
    end;

    if (vCore not in ("Req","Perm","Cond","") and "&gcs_model" eq "ADaM")
       or 
       (vCore not in ("Req","Perm","Exp","") and "&gcs_model" eq "SDTM")
    then do;
        code = "VAR012";
        details = catx(" ","Core:",vCore);
        output;
    end;

    if strip(vNotNull) not in ("1","") then do;
        code = "VAR013";
        details = catx(" ","Not NULL:",vNotNull);
        output;
    end;

    if (vOrigin not in ("Derived","Assigned","Predecessor","") and "&gcs_model" eq "ADaM")
       or 
       (vOrigin not in ("Derived","Assigned","Predecessor","eDT","Protocol","") and vOrigin ne: "CRF" and "&gcs_model" eq "SDTM")
       or 
       (vOrigin =: "CRF" and not prxMatch("/^CRF Page(s)? \d|^CRF$/",strip(vOrigin)))
    then do;
        code = "VAR014";
        details = catx(" ","Origin:",vOrigin);
        output;
    end;

    if strip(vOrigin) eq "Derived" and missing(vSource) then do;
        code = "VAR036";
        output;
    end;
    
    if strip(vOrigin) eq "Predecessor" and missing(vSource) then do;
        code = "VAR037";
        output;
    end;
run;

proc SQL;
* Both basic and advanced where clause methods are used for VLM;
create table chkVarBothWhereTypes as
    select distinct dsName, vName, "VAR024" as code
    from varMeta
    where vNameFull in (select vNameFull from varMeta where vlmType = 1)
          and vlmType = 2
;
* At least one Key per dataset;
create table chkVarNoKeyVar as
    select distinct dsName, "VAR027" as code
    from varMeta
    where dsName not in (select dsName from varMeta where vKey = "1")
;
* Duplicate rows by columns "Dataset Name", "Parameter Identifier" and "Variable Name";
create table chkVarDupByDPV as
    select distinct dsName, vName, "VAR035" as code, paramId as details length = 2048
    from varMeta
    group by dsName, vName, paramId
    having count(*) > 1
;
* Variable has the same Variable Position as another variable;
create table chkVarSameVarPos as
    select distinct dsName, vName, "VAR038" as code, "Position: " || strip(vPos) as details length = 2048
    from varMeta as a
    where not missing(vPos) 
          and 
          catx("#",dsName,vPos) in (select catx("#",dsName,vPos) from varMeta where vName ne a.vName)
;
quit;

* Sort Variable values have gaps or repeat;
data invalidsortVars0;
    set varMeta(where = (not missing(vSort) and paramId eq "*ALL*"));
    if not missing(vSort) then do;
        vSortN = input(vSort,best.);
    end;

    proc sort;
        by dsName vSortN;
run;

data chkInvalidSort(keep = dsName code details);
    set invalidsortVars0;
    by dsName vSortN;

    length code $8 details $2048;

    retain count invalidFl details;

    if first.dsName then do;
        count = 1; 
        invalidFl = 0;
        details = "";
    end;
    else do;
        count = count + 1;
    end;

    if count ne vSortN then do;
        invalidFl = 1;
    end;

    details = catx(" ",details,vSort);

    if last.dsName and invalidFl then do;
        code = "VAR026";
        details = "Sort Variable values: " || strip(details);
        output;
    end;
run;

* Dataset names are not listed contiguously;
data contigChk;
    set varMeta;
    by recId;

    if _n_ = 1 or lag(dsName) ne dsName then do;
        output;
    end;
run;

proc SQL;
create table chkVarNotContDs as
    select dsName, "VAR031" as code
    from contigChk
    group by dsName
    having count(*) > 1
;    
quit;

* Check Origin column for consistency;
data originChecks;
    set varMeta;
    * Remove CRF pages;
    if vOrigin =: "CRF" then do;
        vOrigin = "CRF";
    end;
run;

proc SQL;
* Origin value is inconsistent within a variable;
create table chkVarInconsistentOrigin as
    select distinct dsName, vName, "VAR032" as code
    from originChecks as a
    where vlmType = 0 and not missing(vOrigin)
          and vNameFull in (select vNameFull from originChecks 
                            where vlmType ne 0 and vOrigin ne a.vOrigin and not missing(vOrigin)
                           )
;
* Origin value must not be missing on a value level;
create table chkVarMissingVLMOrigin as
    select distinct dsName, vName, recId, "VAR033" as code
    from originChecks
    where vlmType ne 0 and missing(vOrigin)
;
* Origin value must not be missing on a variable level, when no value level is provided;
create table chkVarMissingVarOrigin as
    select distinct dsName, vName, "VAR034" as code
    from originChecks
    where vlmType = 0 and missing(vOrigin) 
          and vNameFull not in (select vNameFull from originChecks where vlmType ne 0)
;
quit;
    
***********************************************************************************;
* Basic Dataset Attribute Checks
***********************************************************************************;

data basicDatasetChecks(keep = dsName code details);
    set specData;

    length code $8 details $2048;

    if length(scan(dsName,1,"&escapeChar.","m")) > 8 then do;
        code = "DST001";
        output;
    end;

    if missing(scan(dsLabel,1,"&escapeChar.","m")) or length(scan(dsLabel,1,"&escapeChar.","m")) > 40 then do;
        code = "DST002";
        output;
    end;

    if prxMatch("/[^\x20-\x7F]/",strip(scan(dsLabel,1,"&escapeChar.","m"))) then do;
        code = "DST003";
        details = catx(" ","Label:",dsLabel);
        output;
    end;
    * If there is a split domain, verify it is correct and label is specified;
    if index(dsLabel,"&escapeChar.") then do;
        if not index(dsName,"&escapeChar.") then do;
            code = "DST004";
            output;
        end;
        else if length(scan(dsName,2,"&escapeChar.","m")) > 8 then do;
            code = "DST005";
            output;
        end;

        if missing(scan(dsLabel,2,"&escapeChar.","m")) or length(scan(dsLabel,2,"&escapeChar.","m")) > 40 then do;
            code = "DST006";
            output;
        end;

        if prxMatch("/[^\x20-\x7F]/",strip(scan(dsLabel,2,"&escapeChar.","m"))) then do;
            code = "DST007";
            details = catx(" ","Label:",strip(scan(dsLabel,2,"&escapeChar.","m")));
            output;
        end;
    end;
    else do;
        if length(scan(dsName,2,"&escapeChar.","m")) > 8 then do;
            code = "DST005";
            output;
        end;

    end;

    if lowcase(dsLocat) in: ("//" "/proje" "\\") then do;
        code = "DST008";
        output;
    end;

    if not prxMatch("/^One record per \S+/i",dsStruc) then do;
        code = "DST009";
        details = catx(" ","Structure:",dsStruc);
        output;
    end;

    if upcase(dsClass) not in ("EVENTS" "FINDINGS" 
        "INTERVENTIONS" "RELATIONSHIP" 
        "SPECIAL PURPOSE" "TRIAL DESIGN" 
        ) and "&gcs_model" eq "SDTM"
        or
       upcase(dsClass) not in ("ADAM OTHER" "BASIC DATA STRUCTURE" 
        "OCCURRENCE DATA STRUCTURE"
        "SUBJECT LEVEL ANALYSIS DATASET" 
        "ADSL" "BDS" "OCCDS"
        ) and "&gcs_model" eq "ADaM"

    then do;
        code = "DST010";
        details = catx(" ","Class:",dsClass);
        output;
    end;
run;

data chkDstBasicDatasetChecks;
    set basicDatasetChecks;
    * Remove domain label;
    dsName = scan(dsName,1,"&escapeChar.","m");
run;

proc SQL;
* Dataset is listed in Dataset Metadata, but not in Variable Metadata;
create table chkDstInDsnotVar as
    select distinct scan(dsName,1,"&escapeChar.") as dsName length = 40, "DST011" as code
    from specData
    where scan(dsName,1,"&escapeChar.") not in (select dsName from varMeta)
;
* Dataset is listed in Variable Metadata, but not in Dataset Metadata;
create table chkDstInVarnotDs as
    select distinct dsName, "DST012" as code
    from varMeta
    where dsName not in (select scan(dsName,1,"&escapeChar.") from specData)
;
create table chkDstInDupDsName as
    select scan(dsName,1,"&escapeChar.","m") as dsName length = 40, "DST013" as code
    from specData
    group by calculated dsName
    having count (calculated dsName) > 1
;
quit;

***********************************************************************************;
* Perform checks of Specification metadata against dataset;
***********************************************************************************;

%if &checkData eq 1 %then %do;

    * Get metadata about the datasets;    
    data realData(rename=(memname=dsname name=vname));
        set libInfoFull(keep=libName memname memLabel name length libname label varnum format type formatAsData
                        where=(
                               upcase(libname)=upcase("&libDataIn.")
                               %if %superQ(datasCheck) ne %then %do;
                                   and upcase(memName) in (%upcase(&gcs_dsList.))
                               %end;
                              ));
        name = upcase(name);
        memname = upcase(memname);
        proc sort;
        by dsname vname;
    run;

    ***********************************************************************************;
    * Check attributes;
    ***********************************************************************************;
    * Keep only variable level;
    data varLevel;
        set varMeta(where = (vlmType = 0));
        proc sort;
        by dsname vname;
    run;

    * Compare length;
    data chkDatVarLength(keep = &gcs_keepReportVars details);
        merge varLevel(in=inSpec) realData(in=inData);
        by dsname vname;

        if inSpec and inData;

        length details $2048 code $8;
        details = "Specification: " || strip(vLength) || " Dataset: " || strip(put(length,best.));
        vlengthnum=input(vlength,best.);

        if abs(vlengthnum-length) > 0.01 then do;
            code = "DAT001";
            output;
        end;
    run;

    * Compare labels;
    data chkDatVarLabel (keep = &gcs_keepReportVars details);
        merge varLevel(in = inSpec) realData(in = inData);
        by dsname vname;

        if inSpec and inData;

        length details $2048 code $8;
        details = "Specification: " || strip(vLabel) || " Dataset: " || strip(label);

        if label ne vlabel and (inSpec and inData) then do;
            code = "DAT002";
            output;
        end;
    run;

    * Compare types;
    data chkDatVarType(keep = &gcs_keepReportVars details);
        merge varLevel(in = inSpec) realData(in = inData);
        by dsname vname;

        if inSpec and inData;

        length details $2048 code typeC $8;

        if type eq 1 then do;
            typeC  = "num";
        end;
        else if type eq 2 then do;
            typeC  = "char";
        end;

        details = "Specification: " || strip(vType) || " Dataset: " || strip(typeC);

        if  not (
                    ( vTypeSas eq "num" and type eq 1)
                    or
                    ( vTypeSas eq "char" and type eq 2)
                ) 
        then do;
            code = "DAT003";
            output;
        end;
    run;

    * Check formats;
    data chkDatVarFormat(keep = &gcs_keepReportVars details);
        merge varLevel(in = inSpec) realData(in = inData);
        by dsname vname;

        if inSpec and inData;

        length details $2048 code $8 vFormatModified $200;

        * Generate format for numeric values;
        if type eq 1 and missing(format) then do;
        end;

        * Delete trailing dots;
        vFormatModified = upcase(prxChange("s/\.$//",1,strip(vFormat)));
        * Exclude Sx format;
        if index(vFormatModified,"&escapeChar.") then do;
            vFormatModified = scan(vFormatModified,1,"&escapeChar.","m");
        end;
        * Delete default text formats;
        if missing(formatAsData) and prxMatch("/^\$\d+$/",strip(vFormatModified)) then do;
            delete;
        end;
        if vFormatModified ne formatAsData then do;
            details = "Specification: " || strip(vFormat) || " Dataset: " || strip(formatAsData);
            code = "DAT004";
            output;
        end;

    run;

    * Check variable order in datasets;
    proc sort data = varLevel out = orderCheck 
              sortseq = linguistic(numeric_collation = on);
        by dsName vPos;
    run;

    data specVarChecksOrder1;
        set orderCheck;
        by dsName vPos;

        retain sortOrder;
        if first.dsName then do;
            sortOrder = 1;
        end;
        else do;
            sortOrder = sortOrder + 1;
        end;
        proc sort; by dsname vname;
    run;

    data specVarOrder (keep = dsname vname varnum sortOrder recId);
        merge specVarChecksOrder1(in=inSpec) realData(in=inData);
        by dsname vname;
        if varnum ne sortOrder and inSpec and inData;
        proc sort; by dsname varNum;
    run;

    data chkDatVarOrd(keep = &gcs_keepReportVars details);
        set specVarOrder;
        by dsName;

        length details $2048 code $8;
        details = "Variable " || strip(vName) || " has position " || strip(put(sortOrder,best.))
                  || " in specification and position " || strip(put(varNum,best.)) || " in dataset.";

        if first.dsName then do;
            code = "DAT005";
            output;
        end;
    run;

    * Check dataset labels;
    data dsLabel(where = (varNum eq 1));
        set realData;
    run;

    proc sort data = dsLabel;
        by dsName;
    run;

    data specDataLabel;
        set specData;
        * Remove domain name/label;
        dsName = scan(dsName,1,"&escapeChar.","m");
        dsLabel = scan(dsLabel,1,"&escapeChar.","m");
    run;

    proc sort data = specDataLabel;
        by dsName;
    run;

    data chkDatDSLabel(keep = dsName code details);
        merge specDataLabel(in = inSpec) dsLabel(in=inData);
        by dsName;


        if inSpec and inData;

        length details $2048 code $8;
        details = "Specification: " || strip(dsLabel) || " Dataset: " || strip(memLabel);

        if dsLabel ne memLabel then do;
            code = "DAT006";
            output;
        end;
    run;

    * Variable is not present in spec/dataset;
    proc sql;
        create table chkDatDsNotInSpec as
            select distinct dsName as details length = 2048, "DAT007" as code length = 8 
            from realData
            where dsName not in (select dsName from varLevel)
            ;
        create table chkDatDsNotInData as
            select distinct dsName, "DAT008" as code length = 8 
            from varLevel 
            where dsName not in (select dsName from realData)
            ;
        create table chkDatVarNotInSpec as
            select dsName, vName, "DAT009" as code length = 8 
            from realData
            where catx(".",dsName, vName) not in (select catx(".",dsName, vName) from varLevel)
                  and dsName not in (select details from chkDatDsNotInSpec)
            ;
        create table chkDatVarNotInData as
            select dsName, vName, recId, "DAT010" as code length = 8 
            from varLevel 
            where catx(".",dsName, vName) not in (select catx(".",dsName, vName) from realData)
                  and dsName not in (select dsName from chkDatDsNotInData)
            ;
    quit;

%end; * Dataset checks condition;

***********************************************************************************;
* Check codelists;
***********************************************************************************;

* Add type to a codelist: numeric/character;
proc SQL;
create table varMetaCodelistTypes as
    select distinct codelistId, vTypeSas, vType 
    from varMeta
;
create table codelistData as
    select a.*, vTypeSas, vType
    from specCodelist as a natural left join varMetaCodelistTypes as b
    order by codelistId, code, decode
;
create table codelistType as
    select distinct codelistId, vTypeSas, vType
    from codelistData
    order by codelistId
;
quit;

* Codelist is assigned to variables of different types.;
data chkCdlMultipleType(keep = code details);
    set codelistType;
    by codelistId;

    length code $8 details $2048;

    retain details;

    if first.codelistId then do;
        details = "";
    end;

    details = catx(", ",details,vType);

    if last.codelistId and not first.codelistId then do;
        details = "Codelist ID: " || strip(codelistId) || " Types: " || strip(details);
        code = "CDL001";
        output; 
    end;
run;


proc SQL;
* Duplicate codes;
create table dataCdlDupCode as
    select codelistId, code as dupCode
    from specCodelist
    where not missing(code)
    group by codelistId, code
    having count(*) > 1
;
* Duplicate decodes;
create table dataCdlDupDecode as
    select codelistId, decode
    from specCodelist
    where not missing(decode)
    group by codelistId, decode
    having count(*) > 1
;
create table chkCdlMissingCode as
    select distinct catx(" ","Codelist ID: ",codelistId) as details length = 2048, "CDL007" as code length = 8
    from specCodelist
    where missing(code)
;
create table chkCdlMissAndNotMissDecodes as
    select distinct catx(" ","Codelist ID: ",codelistId) as details length = 2048, "CDL008" as code length = 8
    from specCodelist
    where codelistId in (select codelistId from specCodelist where missing(decode))
          and 
          codelistId in (select codelistId from specCodelist where not missing(decode))
;
quit;


data chkCdlDupCode(keep = details code);
    set dataCdlDupCode;
    by codelistId dupCode;

    length code $8 details $2048;
    retain details;

    if first.codelistId then do;
        details = "";
    end;

    details = catx(",",details,dupCode);

    if last.codelistId then do;
        code = "CDL002";
        details = catx(" ","Codelist ID:",codelistId,"Duplicates for the following codes:",details);
        output;
    end;
run;

data chkCdlDupDecode(keep = details code);
    set dataCdlDupDecode;
    by codelistId decode;

    length code $8 details $2048;
    retain details;

    if first.codelistId then do;
        details = "";
    end;

    details = catx(",",details,decode);

    if last.codelistId then do;
        code = "CDL003";
        details = catx(" ","Codelist ID:",codelistId,"Duplicates for the following decodes:",details);
        output;
    end;
run;

data adCodelistCheck1(where = (not missing(clName)));
    set varMeta(keep = dsname vname vrCodes vCodes paramId recId);
    * Extract codelist name;
    length clName $200;
    if prxMatch("/\(.*\)/",vrCodes) then do;
        * Remove any possible white space symbols (like \n\c);
        vrCodes = prxChange("s/\s//",-1,strip(vrCodes));
        clName = prxChange("s/^.*\((.*)\).*$/$1/",1,strip(vrCodes));
    end;
    if missing(vrCodes) and not missing(prxChange("s/\s//",-1,strip(vCodes))) then do;
        clName = compress(upcase(dsName) || "." ||upcase(vName));
        if paramID ne "*ALL*" then do;
            clName = strip(clName)||prxChange("s/[^w]//",-1,strip(paramId));
        end;
    end;
run;

** Check if "," and "=" characters were escaped correctly (doubled) in decodes;
data chkCdlwrongEscapeCodelist(keep = &gcs_keepReportVars);
    set adCodelistCheck1(where = (not missing(vCodes) and upcase(vCodes) ne: "&escapeChar.EXTERNAL"));
    length code $8;
    * Code escaped characters;
    vCodes = tranWrd(vCodes,'==','{defxml:equal}');
    vCodes = tranWrd(vCodes,',,','{defxml:comma}');
    *** If there is more than one decode;
    if indexc(vCodes,"=") > 0 and indexc(vCodes,",") > 0 then do;
        *** Number of comma characters should be number of equal signs + 1;
        if countc(vCodes,"=") ne countc(vCodes,",") + 1 then do;
                code = "CDL004";
                output;
        end;
    end;
run;

* Check proper syntax is used for external codelists;
data chkCdlwrongExternalCodelist(keep = &gcs_keepReportVars);
    set varMeta(keep = dsname vname vrCodes vCodes paramId recId
                 where = (upcase(vCodes) eq: "&escapeChar.EXTERNAL")
                );
    length extName extVer $200 code $8;
    * Check required elements are present; 
    extName = prxChange("s/&escapeChar.EXTERNAL:(.*?)(?:&escapeChar.VER|&escapeChar.HREF|&escapeChar.REF|$).*$/$1/i",1,strip(vCodes));
    extVer  = prxChange("s/.*&escapeChar.VER:(.*?)(?:&escapeChar.HREF|&escapeChar.REF|$).*$/$1/i",1,strip(vCodes));

    if missing(extName) or extName eq: "&escapeChar." then do;
        code = "CDL005";
        output;
    end;
    if missing(extVer) or extVer eq: "&escapeChar." then do;
        code = "CDL006";
        output;
    end;
run;

* Check there are codelists with the same type, codes and decodes, but different names;
data sameCodelists0;
    set codelistData;
    by codelistId;

    length codelistMd5 $32;

    retain codelistMd5;

    if first.codelistId then do;
        * Use type as an attribute;
        codelistMd5 = put(md5(vType),hex32.);
    end;

    codelistMd5 = put(md5(trim(code) || "#SEP#" || trim(decode) || "#SEP#" || strip(codelistMd5)),hex32.);

    if last.codelistId then do;
        output;
    end;
run;

* Select codelists having the same md5 hash;
proc SQL;
create table sameCodelists1 as
    select codelistMd5, codelistId 
    from sameCodelists0
    where codelistMd5 in
        (
            select codelistMd5
            from sameCodelists0
            group by codelistMd5
            having count(distinct codelistId) > 1
        )
    order by codelistMd5
    ;
quit;

data chkCdlSameCodelist(keep = code details);
    set sameCodelists1;
    by codelistMd5;

    length details $2048 code $8;
    retain details;

    if first.codelistMd5 then do;
        details = " ";
    end;

    details = catx(", ",details,codelistId);

    if last.codelistMd5 then do;
        code = "CDL009";
        details = "Codelist IDs: " || strip(details);
        output;
    end;
run;

***********************************************************************************;
* Check parameters;
***********************************************************************************;

* Check governance variable is properly used;
data chkVarGovWrongUse(keep = &gcs_keepReportVars.);
    set varMeta;

    length code $8;

    *  Governance variable is not provided for VLM record in the Related Codelist Variables / (Controlled Terms) column;
    if not prxMatch("/^\*ALL\*$|^&gcs_escapeCharRegex.WHERE/i",strip(paramId)) 
       and 
       missing(govVar)  
    then do;
        code = "VAR015";
        output;
    end;

    *  Governance variable is provided for non-VLM/WHERE clause record in the Related Codelist Variables / (Controlled Terms) column;
    if prxMatch("/^\*ALL\*$|^&gcs_escapeCharRegex.WHERE/i",strip(paramId)) 
       and 
       not missing(govVar)  
    then do;
        code = "VAR016";
        output;
    end;

    * Incorrect format of the governance variable. Must be in a format DS.VAR;
    if not missing(govVar) and not prxMatch("/^\w+\.\w+$/",strip(govVar)) then do;
        code = "VAR017";
        output;
    end;

    * Governance variable is from a different dataset;
    if prxMatch("/^\w+\.\w+$/",strip(govVar)) and not prxMatch("/^" || strip(dsName) ||"\.\w+/i",strip(govVar)) then do;
        code = "VAR018";
        output;
    end;
run;

proc SQL;
%* Select variables with value level data (base dataset for flagging) ;
create table vlmVars as
    select dsname, vname, govVar, paramId, recId, vlmType
    from varMeta(where=(paramId ne "*ALL*"))
    order by dsname, vname
;
* Check governance variable exists;
create table chkVarNoGovVar(keep = &gcs_keepReportVars.) as
    select *, "VAR019" as code length = 8, "Governance variable: " || strip(govVar) as details length 2048
    from vlmVars
    where govVar not in (select vNameFull from varMeta) and not missing(govVar)
          and vlmType eq 1
    ;
%* Get all values for paramId variables;
create table governanceCodes0 as
    select dsName, vName, codelistId 
    from varMeta
    where vNameFull in 
     (select govVar 
      from varMeta 
      where not missing(govVar) 
     )
     and not missing(codelistId)
;
%* Get all codelist values paramId variables;
create table governanceCodes1 as
    select distinct dsName, vName, code
    from governanceCodes0 natural left join specCodelist (keep = codelistId code)
    order by dsName, vName;
quit;

%* Unite all codes into one variable;
data governanceCodes2(keep = relCodes dsName vName vlmFl);
    set governanceCodes1;
    by dsName vName;

    
    length relCodes $32767;
    retain relCodes;

    if first.vName then do;
        relCodes  = code;        
    end;
    else do;
        relCodes = catx(byte(10),relCodes,code);
    end;

    vlmFl = 1;

    %*  Keep only one record per paramId variable;
    if last.vName;
run;

* Add the recCodes to each VLM record with simple paramId;
%* Get all paramId values;
proc SQL;
%* Get all codelist values  paramId variables;
create table vlmParamIds0 as
    select distinct x.*, y.relCodes, y.vlmFl
    from varMeta as x 
         left join
         governanceCodes2 as y
    on upcase(catx("." ,y.dsName, y.vName)) = x.govVar 
    where  x.paramid ne "*ALL*" and x.vlmType ne 2
    order by dsname, vname, defaultFl, recId descending;
quit;
 
 
%* Join non *default* items together in order to subtract from *all* item ;
data vlmParamIds1(drop = i nonDefaultIds paramIdCount paramIdItem:);
    set vlmParamIds0;
    by dsname vname defaultFl;
    length nonDefaultIds $32767 paramIdItem paramIdItemRegex $2048;
    %* Combine nonDefaultIds codes into one cell ;
    retain nonDefaultIds "";
    if first.vName then nonDefaultIds = "";
    if vlmFl eq 1 and defaultFl ne 1 then do;
        nonDefaultIds = strip(nonDefaultIds) || ", " || strip(paramid);
    end;
    %* Remove nonDefaultIds codes from *DEFAULT* codes list ;
    if defaultFl eq 1 then do;
        paramIdCount = countC(nonDefaultIds,',');
        do i = 1 to paramIdCount;
            paramIdItem = strip(scan(nonDefaultIds,i,','));
            %* Escape characters \/@$ which are not quoted by \Q\E;
            paramIdItemRegex = "s/(^|,)\s*\Q" || strip(prxChange("s/([\@\$\\\/])/\\E\\$1\\Q/",-1,trim(paramIdItem))) || "\E\s*(?=$|,)//";
            %* Remove zero-length quotes: \Q\E;
            paramIdItemRegex = prxChange("s/\\Q\\E//",-1,trim(paramIdItemRegex));
            if "&gmDebug." = "1" then do;
                put "NOTE:[PXL] Processing code: " paramIdItem i=;
            end;
            relCodes = prxChange(strip(paramIdItemRegex), -1, trim(relCodes));
        end;
    end;
    proc sort; by paramid;
run;

* Check paramIds;
data chkVarWrongParamId(keep = &gcs_keepReportVars details);
    set vlmParamIds1(where = (defaultFl eq 0));

    length code $8 details $2048 paramIdItem $2048;
    * Parameter Identifier starts or ends with comma or has repeating commas;
    if prxMatch("/^,|,$|,\s*,/",strip(paramId)) then do;
        code = "VAR020";
        details = "Value: " || strip(paramId);
        output;
    end;

    * Parameter Identifier contains a value not from the governance variable codelist;
    ** Surround with special character for matching;
    relCodes = byte(10) || strip(relCodes) || byte(10);
    do i = 1 to countC(paramId,",")+1;
        paramIdItem = scan(paramId,i,",");
        if not index(relCodes,byte(10) || strip(paramIdItem) || byte(10)) 
           and not missing(paramIdItem) and not missing(govVar) 
        then do;
            code = "VAR021";
            details = "Value: " || strip(paramIdItem);
            output;
        end;
    end;
run;

* There is no variable level record (where parameter identifier = *ALL*);
proc SQL;
    create table chkVarNoVarLev as
        select distinct dsName, vName, "VAR022" as code length = 8
        from varMeta
        where vNameFull not in ( select vNameFull
                                 from varMeta 
                                 where paramId = "*ALL*"
                               )
    ;
quit;

* *DEFAULT* record resolves to 0 tests;
data chkVarMissingDefault(keep = &gcs_keepReportVars);
    set vlmParamIds1(where = (defaultFl eq 1));

    if missing(relcodes) then do;
        code = "VAR023";
        output;
    end;
run;

***********************************************************************************;
* Compare codelist values with dataset values;
***********************************************************************************;
%if &checkData eq 1 %then %do;
    * Replace *DEFAULT* param ID with real codes;
    data clValueCheck0(keep = vName dsName codeListId vCodes paramId vTypeSas govVar vlmType recId vType);
        set varMeta     (where = (defaultFl = 0))
            vlmParamIds1 (where = (defaultFl = 1))
        ;

        if defaultFl = 1 then do;
            paramId = tranWrd(relCodes,byte(10),",");
        end;
        proc sort;
            by dsName vName vlmType;
    run;


    * For all Value-level records apply SAS type from the variable level; 
    data clValueCheck1;
        set clValueCheck0;
        by dsName vName vlmType;

        length vTypeSasVar $4;

        retain vTypeSasVar;

        if first.vName then do;
            vTypeSasVar  = "";
        end;

        if vlmType = 0 then do;
            vTypeSasVar = vTypeSas;
        end;

        if missing(vTypeSasVar) then do;
            * *ALL* is not present, delete such rows;
            delete;
        end;
    run;

    * Select all variables with codelists, exclude external codelistas;
    * Exclude WHERE Clauses with advanced syntax;
    data clValueCheck2;
        set clValueCheck1(where = (not missing(codelistId) and upcase(vCodes) ne: "EXTERNAL" and vlmType ne 2));
        by dsName vName vlmType;

        * For all Value-level records use variable level SAS type;        
        retain vTypeSasVar "";
        if first.vName and vlmType = 0 then do;
            vTypeSasVar = vTypeSas;
        end;


        length whereClause $32767 govVarVName $8;

        * Form the WHERE clauses; 
        if paramId ne "*ALL*" then do;
            govVarVName = prxChange("s/\w+\.(\w+)/$1/",1,strip(govVar)); 
            whereClause = strip(govVarVName)
                          || " in ('" || prxChange("s/\s*,\s*/','/",-1,strip(paramId)) || "')";
        end;
    run;

    * Keep only the variables which are present in realData;
    proc SQL;
    create table clValueCheck3 as
        select a.* 
        from clValueCheck2 as a inner join realData as b
             on a.dsName eq b.dsName and a.vName eq b.vName
    ;
    quit;

    * Create a dummy dataset;
    data clNonCodelistValues;
        if 0 then do;
            length gcs_recId $8 gcs_vName gcs_dsName $40 gcs_codelistId $50 nonClValue $200;
            gcs_vName = "";
            gcs_recId = "";
            gcs_dsName = "";
            gcs_codelistId = "";
            nonClValue = "";
            output;
        end;
    run;

    %if &gmDebug ne 1 %then %do;  
        option nosource;
    %end;

    * Generate call execute statements;
    * Create a hash table of codes and use it to identify values in a dataset which are not in this codelist;
    * Hash is created from codelistData table, code is used as a key.
    * For each variable with a codelist in the checked dataset the variable value is looked up in the hash table
    * using codelist.Find();
    * If there is at least one value which is not in the hash table, it is output to the dataset
    * which is later sorted to remove duplicates and appended to the main dataset;
    * This does not look nice, but it is faster than other methods;
    data clValueCallExecuteCode;
        set clValueCheck3 end=eof;
        length sasCode $32767;
        sasCode = compbl( 
          "data clCurrentNonCodelistValues(keep =gcs_:);                                                   "
        ||"    if 0 then set codelistData;                                                                 "
        ||"    retain gcs_notMissingDataset 0;                                                             "
        ||"    drop gcs_notMissingDataset;                                                                 "
        ||"    if _n_ eq 1 then do;                                                                        "
        ||"        declare hash codeList                                                                   "
        ||"            (dataset:'codelistData(where = (codelistId = """||strip(codelistId)||""")"
        ||"                                            rename = (code = gcs_valueCheckVar))'               "
        ||"            )                                                                                   "
        ||"        ;                                                                                       "
        ||"        codeList.definekey('gcs_valueCheckVar');                                                "
        ||"        codeList.definedone();                                                                  "
        ||"    end;                                                                                        "
        ||"                                                                                                "
        ||"    do until(eof);                                                                              "
        ||"        length gcs_recId $8 gcs_vName gcs_dsName $40 gcs_codelistId $50;                        "
        ||"        gcs_vName = '" || strip(vName) || "';                                                   "
        ||"        gcs_recId = '" || strip(put(recId,best.)) || "';                                        "
        ||"        gcs_dsName= '" || strip(dsName) || "';                                                  "
        ||"        gcs_codelistId= '" || strip(codelistId) || "';                                          "
        ||"                                                                                                ");
        if vTypeSasVar eq "char" then do;
            * For character variables rename the variable to match key in the hash table;
             sasCode = strip(sasCode)
            ||"        set &libDataIn.." || strip(dsName) || "(keep = " || catx(" ", vName,  govVarVName) 
            || " rename = (" || strip(vName) || "=gcs_valueCheckVar)";
        end;
        else if vTypeSasVar eq "num" then do;
            * For numeric variables variable will be generated in the dataset to match key in the hash table;
             sasCode = strip(sasCode)
            ||"        set &libDataIn.." || strip(dsName) || "(keep = " || catx(" ", vName,  govVarVName);
        end;
        if not missing(whereClause) then do;
             sasCode = strip(sasCode)
            ||"                       where = ("|| strip(whereClause) ||")";
        end;
        sasCode = strip(sasCode)
            ||") end=eof; ";
        if vTypeSasVar eq "num" then do;
            * For numeric variables generate variable to match hash key;
            * Numbers below 1E-5 will not work properly as BEST converts them to scientific format;
             sasCode = strip(sasCode)
            ||"        length gcs_valueCheckVar $32; "
            ||"        if not missing("|| strip(vName) || ") then do; "
            ||"          gcs_valueCheckVar = strip(put(round("|| strip(vName) || ",1E-9),best32.));"
            ||"        end;";
        end;
        sasCode = strip(sasCode) || compbl(
          "        if codeList.find() = 0 then do;                                                         "
        ||"        end;                                                                                    "
        ||"        else if not missing(gcs_valueCheckVar) then do;                                         "
        ||"            gcs_notMissingDataset = 1;                                                          "
        ||"            output;                                                                             "
        ||"        end;                                                                                    "
        ||"    end;                                                                                        "
        ||"    if gcs_notMissingDataset then do;                                                           "
        ||"        call execute('proc sort data = clCurrentNonCodelistValues nodupkey; by _all_; run;');   "
        ||"        call execute('data clCurrentNonCodelistValues(drop=gcs_valueCheckVar); set clCurrentNonCodelistValues;');"
        ||"        call execute('length nonClValue $200; nonClValue=gcs_valueCheckVar; run;');            "
        ||"        call execute('proc append base=clNonCodelistValues data=clCurrentNonCodelistValues; run;');"
        ||"    end;                                                                                        " 
        ||"    stop;                                                                                       "
        ||"run;                                                                                            "
        );

        call execute(sasCode);
    run;

    %if &gmDebug ne 1 %then %do;  
        option source;
    %end;

    proc sort data =clNonCodelistValues(rename = (gcs_dsName=dsName gcs_vName=vName));
        by dsName vName gcs_recId;
    run;    

    data chkCdlValuesNotInCodelist(keep = &gcs_keepReportVars details);
        set clNonCodelistValues;
        by dsName vName gcs_recId;

        recId = input(gcs_recId,best.);

        length code $8 details $2048;

        retain details;

        if first.gcs_recId then do;
            details = "";
        end;

        details = catx("','",details,nonClValue);

        if last.gcs_recId then do;
            code = "DAT011";
            details = "The following dataset values were not found in the codelist " || strip(gcs_codelistId) 
                      || ": '" || strip(details) || "'" ;
            output;
        end;
    run;
%end; * Dataset checks condition;

***********************************************************************************;
* Combine all checks and format them;
***********************************************************************************;

%gmMessage(linesOut = Generating summary report, selectType = N);

proc format library = &gcs_libName.;
    value $ gcs_desc
        'STD001' = 'Model must be either SDTM or ADaM'
        'STD002' = 'Sponsor name must be provided'
        'STD003' = 'Study Name must be provided'
        'STD004' = 'Study Description must be provided'
        'STD005' = 'Protocol Name must be provided'
        'STD006' = 'Model Version must be provided'
        'STD007' = 'Check Model Version (should be valid version in format "x.x")'
        'STD008' = 'Study and protocol name are the same'
        'STD009' = 'Model IG Version must be provided'
        'STD010' = 'Check Model IG Version (should be valid IG version in format "x.x")'
        'DST001' = 'Dataset name must not be missing and must have length <= 8'
        'DST002' = 'Dataset label must not be missing and must have length <= 40'
        'DST003' = 'Dataset label must not contain special characters'
        'DST004' = 'If parent domain label is provided for the split dataset, then the domain name must be specified in the Dataset Name column'
        'DST005' = 'In case of a split dataset parent domain name must not be missing and must have length <= 8'
        'DST006' = 'In case of a split dataset parent domain label must not be missing and must have length <= 40'
        'DST007' = 'In case of a split dataset parent domain label must not contain special characters'
        'DST008' = 'Location must not contain path to a dataset'
        'DST009' = 'Dataset structure must be in a format "One record per XXX per YYY ..."'
        'DST010' = 'Class value does not match standard values allowed for the model'
        'DST011' = 'Dataset is listed in Dataset Metadata, but not in Variable Metadata'
        'DST012' = 'Dataset is listed in Variable Metadata, but not in Dataset Metadata'
        'DST013' = 'There is more than one record for the dataset in the Dataset metadata'
        'VAR001' = 'Dataset name must not be missing'
        'VAR002' = 'Parameter Identifier must not be missing'
        'VAR003' = 'Variable name must not be missing and must have length <= 8'
        'VAR004' = 'Variable Position must be an integer'
        'VAR005' = 'Invalid Key column value'
        'VAR006' = 'Sort Variables column must be populated when variable is marked as Key and be an integer'
        'VAR007' = 'Variable label must not be missing and must have length <= 40'
        'VAR008' = 'Variable label must not contain special characters'
        'VAR009' = 'Variable Type must be one of the valid Define-XML datatypes'
        'VAR010' = 'Length must be either a number < 200 or ~ASDATA value'
        'VAR011' = 'Variable with float data type must have either W.D format or ~Sx modifier used in the Format column'
        'VAR012' = 'The core attribute value is not one of the values allowed for the Model'
        'VAR013' = '"Not NULL" is either 1 or blank'
        'VAR014' = 'The Origin value is not one of the values allowed for the Model'
        'VAR015' = 'Governance variable is not provided for VLM record in the Related Codelist Variables / (Controlled Terms) column'
        'VAR016' = 'Governance variable is provided for non-VLM/WHERE clause record in the Related Codelist Variables / (Controlled Terms) column'
        'VAR017' = 'Incorrect format of the governance variable. Must be in format DS.VAR'
        'VAR018' = 'Governance variable is from a different dataset'
        'VAR019' = 'Governance variable does not exist'
        'VAR020' = 'Parameter Identifier starts or ends with comma or has repeating commas'
        'VAR021' = 'Parameter Identifier contains a value not from the governance variable codelist'
        'VAR022' = 'There is no variable level record (where parameter identifier = *ALL*)'
        'VAR023' = '*DEFAULT* record resolves to 0 parameters'
        'VAR024' = 'Both basic and advanced where clause methods are used for VLM. Currently this is not supported in gmDefineXml and only one method can be used'
        'VAR025' = 'Type of the Format cell is not text in the Excel file'
        'VAR026' = 'Sort Variables values have gaps or are repeating'
        'VAR027' = 'There must be at least one variable marked as a "Key Variable" for each dataset'
        'VAR028' = 'Numeric format used for character value'
        'VAR029' = 'Character format used for numeric value'
        'VAR030' = 'Format must not contain dot at the end'
        'VAR031' = 'Dataset records are not listed contiguously in the Variable Metadata'
        'VAR032' = 'Origin value is inconsistent within a variable'
        'VAR033' = 'Origin value must not be missing on a value level'
        'VAR034' = 'Origin value must not be missing on a variable level, when no value level is provided'
        'VAR035' = 'Duplicate rows by columns "Dataset Name", "Parameter Identifier" and "Variable Name"'
        'VAR036' = 'For origin "Derived" there must be a derivation method provided'
        'VAR037' = 'For origin "Predecessor" there must be a description provided'
        'VAR038' = 'Variable has the same Variable Position as another variable'
        'VAR039' = 'Invalid characters in the specification'
        'CDL001' = 'Codelist is assigned to variables of different types'
        'CDL002' = 'Codelist has duplicate codes'
        'CDL003' = 'Codelist has duplicate decodes'
        'CDL004' = 'Equal and comma characters may be inconsistently used in the Codelist column'
        'CDL005' = 'Missing required name attribute in the external codelist definition'
        'CDL006' = 'Missing required version attribute in the external codelist definition'
        'CDL007' = 'Codelist has a missing code value'
        'CDL008' = 'Codelist has both missing and non-missing decodes'
        'CDL009' = 'Codelists have the same values, but different names'
        'DAT001' = 'Length in Specification is different from the variable length in dataset.'
        'DAT002' = 'Label in Specification is different from the variable label in dataset.'
        'DAT003' = 'Type in Specification is not consistent with type in dataset.'
        'DAT004' = 'Format in Specification is different from the variable format in dataset.'
        'DAT005' = 'Order of variables in specification is different from the order in dataset.'
        'DAT006' = 'Dataset label in specification is different from the dataset label.'
        'DAT007' = 'Dataset is not in the specification, but is in the library.'
        'DAT008' = 'Dataset is not in the library, but is in the specification.'
        'DAT009' = 'Variable is not in the specification, but is in the library.'
        'DAT010' = 'Variable is not in the library, but is in the specification.'
        'DAT011' = 'Variable/Value level has a dataset value which is not in the codelist.'
        'DAT012' = 'Data selected via where clauses overlaps.'              
        'INF001' = 'Overall summary of datasets scanned'
        'INF002' = 'Summary of issues'
        'INF003' = 'Summary of check-manually issues'
        'INF004' = 'Summary of excluded datasets'
        'INF005' = 'Summary of variables scanned'
        'INF006' = 'Summary of issues'
        'INF007' = 'Summary of check-manually issues'        
    ;
    value $ gcs_type
        'STD001' = 'Error'
        'STD002' = 'Error'
        'STD003' = 'Error'
        'STD004' = 'Error'
        'STD005' = 'Error'
        'STD006' = 'Error'
        'STD007' = 'Check Manually'
        'STD008' = 'Check Manually'
        'STD009' = 'Error'
        'STD010' = 'Check Manually'
        'DST001' = 'Error'
        'DST002' = 'Error'
        'DST003' = 'Error'
        'DST004' = 'Error'
        'DST005' = 'Error'
        'DST006' = 'Error'
        'DST007' = 'Error'
        'DST008' = 'Check Manually'
        'DST009' = 'Error'
        'DST010' = 'Check Manually'
        'DST011' = 'Error'
        'DST012' = 'Error'
        'DST013' = 'Error'
        'VAR001' = 'Error'
        'VAR002' = 'Error'
        'VAR003' = 'Error'
        'VAR004' = 'Error'
        'VAR005' = 'Error'
        'VAR006' = 'Error'
        'VAR007' = 'Error'
        'VAR008' = 'Error'
        'VAR009' = 'Error'
        'VAR010' = 'Error'
        'VAR011' = 'Error'
        'VAR012' = 'Error'
        'VAR013' = 'Error'
        'VAR014' = 'Error'
        'VAR015' = 'Error'
        'VAR016' = 'Error'
        'VAR017' = 'Error'
        'VAR018' = 'Check Manually'
        'VAR019' = 'Error'
        'VAR020' = 'Error'
        'VAR021' = 'Error'
        'VAR022' = 'Error'
        'VAR023' = 'Check Manually'
        'VAR024' = 'Error'
        'VAR025' = 'Error'
        'VAR026' = 'Check Manually'
        'VAR027' = 'Error'
        'VAR028' = 'Error'
        'VAR029' = 'Error'
        'VAR030' = 'Error'
        'VAR031' = 'Check Manually'
        'VAR032' = 'Error'
        'VAR033' = 'Error'
        'VAR034' = 'Error'
        'VAR035' = 'Error'
        'VAR036' = 'Error'
        'VAR037' = 'Error'
        'VAR038' = 'Error'
        'VAR039' = 'Check Manually'
        'CDL001' = 'Error'
        'CDL002' = 'Error'
        'CDL003' = 'Check Manually'
        'CDL004' = 'Check Manually'
        'CDL005' = 'Error'
        'CDL006' = 'Error'
        'CDL007' = 'Error'
        'CDL008' = 'Check Manually'
        'CDL009' = 'Check Manually'
        'DAT001' = 'Error'
        'DAT002' = 'Error'
        'DAT003' = 'Error'
        'DAT004' = 'Error'
        'DAT005' = 'Error'
        'DAT006' = 'Error'
        'DAT007' = 'Check Manually'
        'DAT008' = 'Error'
        'DAT009' = 'Error'
        'DAT010' = 'Error'
        'DAT011' = 'Error'
        'DAT012' = 'Error'
        'INF001' = 'Info'
        'INF002' = 'Error'
        'INF003' = 'Check Manually'
        'INF004' = 'Check Manually'
        'INF005' = 'Info'
        'INF006' = 'Error'
        'INF007' = 'Check Manually'        
    ;
    invalue gcs_sort
        "INF" = 1
        "STD" = 2
        "CDL" = 3
        "DST" = 4
        "DAT" = 5
        "VAR" = 6
    ;
run;

option fmtSearch=(&gcs_libName.);

data checkSummary0;
    set chk:;

    length type $32 description $512;

    if not missing(recId) then do;
        * Line is recID + 1 due to the header row;
        line = strip(put(recId+1,5.));
    end;

    if missing(type) then do;
        type = put(code,$gcs_type.);
        description = put(code,$gcs_desc.);
    end;
run;

* Get general information about scanned data;

proc SQL noprint;
create table chkInfAllDataChecked as
    select catx(" ","Total number of datasets checked:",count(distinct(dsName))
                ,"~nTotal number of variables checked:",count(distinct(vName))
               ) as details length = 2048
           , "INF001" as code  
    from varMeta
;
create table chkInfTotalError as
    select catx(" ","Total number of issues:",count(*)) as details length = 2048
           , "INF002" as code, count(*) as infCount 
    from checkSummary0
    where type = "Error"
;
create table chkInfTotalCM as
    select catx(" ","Total number of check-manually issues:",count(*)) as details length = 2048
           , "INF003" as code, count(*) as infCount 
    from checkSummary0
    where type = "Check Manually"
;
create table datasetExcluded as
    select distinct dsName 
    from specVar
    where dsName not in (select dsName from specVarFiltered) and upcase(vKey) ne "NOT USED"
    order by dsName
;
create table chkInfByDataset as
    select dsName
           , catx(" ","Total number of variables checked:",count(distinct(vName))) as details length = 2048
           , "INF005" as code  
    from varMeta
    where not missing(dsName)
    group by dsName
;
create table chkInfError as
    select dsName
           , catx(" ","Number of issues:",count(*)) as details length = 2048
           , "INF006" as code, count(*) as infCount 
    from checkSummary0
    where type = "Error" and not missing(dsName)
    group by dsName
;
create table chkInfCM as
    select dsName
           , catx(" ","Number of check-manually issues:",count(*)) as details length = 2048
           , "INF007" as code, count(*) as infCount 
    from checkSummary0
    where type = "Check Manually" and not missing(dsName)
    group by dsName
;
quit;

data chkInfDatasetExcluded(keep = code details);
    set datasetExcluded end = lastObs;

    length code $8 details $2048;

    retain details "";

    details = catx(" ",details,dsName);

    if lastObs then do;
        code = "INF004";
        details = catx(" ","The following datasets are excluded from checks:",details);
        output;
    end;
run;


* Add the info section;
data checkSummary;
    set checkSummary0 chkInf:;

    * Drop lines about number of issues/check-manually issues when there are nonel;
    if infCount = 0 and code in ("INF002","INF003","INF005","INF006") then do;
        delete;
    end;
    drop infCount;

    length type $32 description $512;

    if not missing(recId) then do;
        line = strip(put(recId,5.));
    end;

    if missing(type) then do;
        type = put(code,$gcs_type.);
        description = put(code,$gcs_desc.);
    end;
    category = subStr(code,1,3);
    
    catSort = input(category,gcs_sort.);
    codeSort = input(prxChange("s/^[a-z]+//i",-1,strip(code)),best.);

    if code in ("INF001","INF002","INF003","INF004") then do;
        section = 1;
    end;
    else if missing(dsName) then do;
        section = 2;
    end;
    else do;
        section = 3;
    end;

    attrib _all_ label = " ";

    proc sort; by section dsName catSort code;
run;

***********************************************************************************;
* Output check summary to STDOUT;
***********************************************************************************;

%local gcs_dsCheckedNum gcs_varCheckedNum gcs_errNum gcs_cmNum gcs_excludedNum;

proc SQL noprint;
    select count(distinct(dsName)) into :gcs_dsCheckedNum
    from varMeta
    ;
    select count(distinct(dsName)) into :gcs_excludedNum
    from datasetExcluded
    ;
    select count(distinct(vName)) into :gcs_varCheckedNum
    from varMeta
    ;
    select count(*) into :gcs_errNum
    from checkSummary
    where type = "Error"
    ;
    select count(*) into :gcs_cmNum
    from checkSummary
    where type = "Check Manually"
    ;
quit;

%gmMessage(  codeLocation = gmCheckSpecificationReport
           , linesOut     = %qCmpRes(%str( &gcs_dsCheckedNum datasets checked, &gcs_excludedNum excluded
                                          ,&gcs_varCheckedNum variables checked
                                          ,&gcs_errNum issues, &gcs_cmNum check-manually issues.
                                          Generating a report.
                                         )
                                    )
           , printStdOut  = 1 

          );

***********************************************************************************;
* Save the report to spec library if the library exists;
***********************************************************************************;

* Create a library which directs to spec library and apply lockWait option to it - gcs_det;
%if %sysfunc(libref(&libSpecIn.))=0 %then %do;
    libname %sysfunc(prxchange(s/gm/gs/, 1, &gcs_libName)) "%sysfunc(pathname(&libSpecIn.))" filelockwait=&lockWait compress=y;

    %let gcs_locksyserrbefore=&syserr;

    data %sysfunc(prxchange(s/gm/gs/, 1, &gcs_libName)).gcs_det;
        set &gcs_libName..checkSummary(drop = line catSort codeSort section);
    run;

    %let gcs_locksyserrafter=&syserr;

    libname %sysfunc(prxchange(s/gm/gs/,1,&gcs_libName));

    %if &gcs_locksyserrafter > &gcs_locksyserrbefore %then %do;
         %let gcs_errortext=&syserrortext;

         %gmMessage(codeLocation = gmCompareReport
                   , linesOut     = Macro aborted as gcs_det dataset is locked. %qLeft(&gcs_errortext);
                   , selectType   = ABORT
                   , printStdOut  = 1
                   , sendEmail    = &sendEmail
                   );
    %end;
%end;

***********************************************************************************;
* PDF Report
***********************************************************************************;

* Update the file to be PDF-compliant;
data checkSummaryPDF;
    set checkSummary;

    * Replace new line character;
    if prxMatch("/[\n\r]/",strip(details)) then do;
        details = prxChange("s/[\n\r]+/\n/",-1,strip(details));
    end;

    %gmModifySplit(var=description ,width = 47, selectType=NOTE,delimiter=~n);
    if not index(details,"~n") then do;
        %gmModifySplit(var=details,width = 45, selectType=NOTE,delimiter=~n);
    end;
    proc sort;
        by section dsName vName catSort codeSort line;
run;

* Produce the report;
ods path (prepend) &gcs_libName..templates(read);

proc template;
    define style gcscheck /store=&gcs_libName..templates;
         parent=styles.rtf;
         replace fonts /
            "docfont"=("courier new, Monospace ¨Cencoding latin1",10pt)
            "headingfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "footfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "titlefont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "titlefont2" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "title2font" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "strongfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "emphasisfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "fixedemphasisfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "fixedstrongfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "fixedheadingfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "batchfixedfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "fixedfont" = ("courier new, Monospace ¨Cencoding latin1",10pt)
            "headingemphasisfont" = ("courier new, Monospace ¨Cencoding latin1",10pt);
         style table from container /
            frame=hsides
            rules=groups
            cellpadding=0pt
            cellspacing=0pt
            borderwidth=0.4pt
            asis=on
            linkcolor=_undef_;
         style body from document /
             bottommargin=.5in
             topmargin=.5in
             rightmargin=.5in
             leftmargin=.5in
             font_face = "Courier New, Courier, Monospace ¨Cencoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style header from headersandfooters /
             protectspecialchars=off
             just=center
             font_face = "Courier New, Courier, Monospace ¨Cencoding latin1"
             font_size = 10pt;
         style systemFooter /
             font_face = "Courier New, Courier, Monospace ¨Cencoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style systemTitle /
             font_face = "Courier New, Courier, Monospace ¨Cencoding latin1"
             font_size = 10pt;
         style Data /
             font_face = "Courier New, Courier, Monospace ¨Cencoding latin1"
             font_size = 10pt
             linkcolor=_undef_;
         style systitleandfootercontainer from container/
             asis=on
             linkcolor=_undef_;
         style data from container/
             asis=on
             linkcolor=_undef_;
         end;
run;

ods escapechar="~";
ods listing close;
goptions device=actximg;

options nodate nonumber nobyline orientation=landscape papersize=letter;

ods pdf file=gcs_rPdf style=gcscheck pdftoc=1 uniform;

title1 "Check Performed On %sysfunc(left(%qsysfunc(date(),is8601da.))) %sysfunc(left(%qsysfunc(time(),tod5.)))
 EST [Executed by %gmGetUserName]";

footnote1 j=c "Page ~{thispage} of ~{lastpage}";

ods proclabel="Summary of Checks";

title2 "Summary of Checks";

proc report data=checkSummaryPdf(where = (section = 1)) nowd missing spacing=0 split="@" contents="";
    column dsName catSort codeSort type code description details;

    define dsName      / order noprint;
    define catSort     / order noprint;
    define codeSort    / order noprint;
    define type        / order noprint;
    define code        / style={cellwidth=10% just=l} "Code";
    define description / style={cellwidth=49% just=l} "Check Description";
    define details     / style={cellwidth=40% just=l} "Additional Details";

    break before dsName / contents='' page;

    compute code;
        if type = "Info" then do;
            call define(_row_, "style", "STYLE=[BACKGROUND=lightgreen]");
        end;
        else if type = "Check Manually" then do;
            call define(_row_, "style", "STYLE=[BACKGROUND=yellow]");
        end;
        else do;
            call define(_row_, "style", "STYLE=[BACKGROUND=lightred]");
        end;
    endcomp;
run;

title2 "Global Study and Codelist Issue Summary";
ods proclabel="Study and Codelist";

proc report data=checkSummaryPdf(where = (section = 2)) nowd missing spacing=0 split="@" contents="";
    column dsName catSort codeSort type code description details;

    define dsName      / order noprint;
    define catSort     / order noprint;
    define codeSort    / order noprint;
    define type        / noprint;
    define code        / style={cellwidth=10% just=l} "Code";
    define description / style={cellwidth=49% just=l} "Check Description";
    define details     / style={cellwidth=40% just=l} "Additional Details";

    break before dsName / contents='' page;

    compute details;
        if type = "Info" then do;
            call define(_row_, "style", "STYLE=[BACKGROUND=lightgreen]");
        end;
        else if type = "Check Manually" then do;
            call define(_row_, "style", "STYLE=[BACKGROUND=yellow]");
        end;
        else do;
            call define(_row_, "style", "STYLE=[BACKGROUND=lightred]");
        end;
    endcomp;
run;

* Select the list of datasets in the report;
* Remove domain name;
data specDataNoDomain;
    set specData;

    dsName = scan(dsName,1,"&escapeChar.");
run;

proc SQL noprint;
    select distinct coalesce(a.dsName,b.dsName) as dsName into: gcs_dsList separated by "#"
    from varMeta(keep = dsName) as a natural full join specDataNoDomain(keep = dsName) as b
    where not missing(a.dsName || b.dsName)
    order by calculated dsName 
;
quit;

%do %while (%superQ(gcs_dsList) ne );
    %let gcs_curDs = %scan(%superQ(gcs_dsList),1,#);
    %let gcs_dsList = %sysFunc(prxChange(s/^.+?(#|$)//,1,%superQ(gcs_dsList)));

    title2 "Dataset Issue Summary";
    title3 "Dataset &gcs_curDs";
    ods proclabel="&gcs_curDs";

    proc report data=checkSummaryPdf(where = (section = 3 and dsName eq "&gcs_curDs.")) nowd missing spacing=0 split="@" contents="";
        column dsName catSort vName vNameComp codeSort recId line type code description details;

        define dsName      / order noprint;
        define catSort     / order noprint;
        define vName       / order noprint;
        define vNameComp   / computed style={cellwidth=8% just=l} "Variable";
        define codeSort    / order noprint;
        define recId       / order noprint;
        define line        / style={cellwidth=5% just=l} "Line";
        define type        / order noprint;
        define code        / style={cellwidth=7% just=l} "Code";
        define description / style={cellwidth=40% just=l} "Check Description";
        define details     / style={cellwidth=39% just=l} "Additional Details";

        break before dsName / contents='' page;

        compute before vName;
            vNameTemp = vName;
        endcomp;

        compute vNameComp / character length = 8;
            vNameComp = vNameTemp;
        endcomp;

        compute after catSort;
            line "";
        endcomp;

        compute code;
            if type = "Info" then do;
                call define(_row_, "style", "STYLE=[BACKGROUND=lightgreen]");
            end;
            else if type = "Check Manually" then do;
                call define(_row_, "style", "STYLE=[BACKGROUND=yellow]");
            end;
            else do;
                call define(_row_, "style", "STYLE=[BACKGROUND=lightred]");
            end;
        endcomp;
    run;

%end;

ods pdf close;
ods listing;

***********************************************************************************;
* XLS Report
***********************************************************************************;

%if &createXls = 1 %then %do;

data checkSummaryXls;
    set checkSummary;

    label
        dsName = "Dataset"
        vName  = "Details"
        line   = "Line"
        code   = "Issue Code"
        description = "Issue Description"
        details = "Issue Details"
    ;

    format _all_ ;
run;

%gmTrimVarLen(dataIn=checkSummaryXls);

ods listing close;
ods tagsets.excelXp file=gcs_rXls style=statistical 
    options(autofilter='all' sheet_name="Specification Check Report" width_fudge='0.5');


proc print data = checkSummaryXls noobs label;
    var dsName vName line code description details;
run;

ods tagsets.excelXp close;
ods listing;

%end;

***********************************************************************************;
* E-mail Report
***********************************************************************************;

%if &sendEmail = 1 %then %do;

    %local gcs_userEMail;
    %local gcs_userName;

    data _null_;
        infile "~/.forward" lrecl = 256;
        input;
        if prxMatch("/^\S+@\S+$/",strip(_infile_)) then do;
            call symput("gcs_userEMail",strip(_infile_));
            if prxMatch("/^\S+\.\S+@\S+$/",strip(_infile_)) then do;
                call symput("gcs_userName",strip(prxChange("s/^(\S+?)\..*$/$1/",1,strip(_infile_))));
            end;
        end;
    run;

    filename gcs_eml eMail
        subject = "[Macro execution] gmSpeckSpecification summary"
        from= "&gcs_userEMail."
        to = "&gcs_userEMail."
        ct = "text/html"
    ;

    proc template;
        define style gcsmail /store=&gcs_libName..templates;
        parent=styles.default;
        replace fonts /
            "docfont"=("courier new, Monospace -encodining latin1",10pt)
            "headingfont" = ("courier new, Monospace -encodining latin1",10pt,bold roman)
            "titlefont" = ("courier new, Monospace -encodining latin1",10pt)
            "titlefont2" = ("courier new, Monospace -encodining latin1",10pt)
            "title2font" = ("courier new, Monospace -encodining latin1",10pt)
            "strongfont" = ("courier new, Monospace -encodining latin1",10pt)
            "emphasisfont" = ("courier new, Monospace -encodining latin1",10pt)
            "fixedemphasisfont" = ("courier new, Monospace -encodining latin1",10pt)
            "fixedstrongfont" = ("courier new, Monospace -encodining latin1",10pt)
            "fixedheadingfont" = ("courier new, Monospace -encodining latin1",10pt)
            "batchfixedfont" = ("courier new, Monospace -encodining latin1",10pt)
            "fixedfont" = ("courier new, Monospace -encodining latin1",10pt)
            "headingemphasisfont" = ("courier new, Monospace -encodining latin1",10pt);
        style table from container /
            frame=hsides
            rules=groups
            cellpadding=0pt
            cellspacing=0pt
            borderwidth=0pt
            asis=on;
        style body from document /
            bottommargin=0
            topmargin=0
            rightmargin=0
            leftmargin=0;
        style header from headersandfooters /
            protectspecialchars=off
            just=center;
            style systitleandfootercontainer from container/
            asis=on;
        style data from container/
            asis=on;
        style color_list from color_list/
            'bgA' = cxFFFFFF;
        end;
    run;

    ods listing close;
    ods html body = gcs_eml style = gcsmail;

    title;
    footnote;

    ods text='Execution of gmCheckSpecificationReport has completed.';
    ods text=' ';
    ods text="Full report can be found here: &gcs_sambaLinkPdf.";
    ods text=' ';

    option nocenter;

    proc report data=checkSummary(where = (category = "INF")) nowd headline headskip missing spacing=2 split="@";
        column dsName dsNameComp codeSort type code description details;

        define dsName      / order noprint;
        define dsNameComp  / computed style={cellwidth=7% just=l} "Dataset";
        define codeSort    / order noprint;
        define type        / order noprint;
        define code        / style={cellwidth=6% just=l} "Code";
        define description / style={cellwidth=37% just=l} "Check Description";
        define details     / style={cellwidth=41% just=l} "Additional Details";

        compute before dsName;
            dsNameTemp = dsName;
        endcomp;

        compute dsNameComp / character length = 8;
            dsNameComp = dsNameTemp;
        endcomp;

        compute code;
            if type = "Info" then do;
                call define(_row_, "style", "STYLE=[BACKGROUND=lightgreen]");
            end;
            else if type = "Check Manually" then do;
                call define(_row_, "style", "STYLE=[BACKGROUND=yellow]");
            end;
            else do;
                call define(_row_, "style", "STYLE=[BACKGROUND=lightred]");
            end;
        endcomp;
    run;

    ods html close;
    ods listing;

%end;

***********************************************************************************;
* Tidy environment
***********************************************************************************;
/* Restore options */
/* Drop two options which do not need to be reset - SAS changes them during OPTLOAD */
data &gcs_libName..options;
  set &gcs_libName..options(where = (optName not in ("SET","CMPOPT")));
run;

proc optload data=&gcs_libName..options;
run; 

ods path (remove) &gcs_libName..templates;

title;
footnote;

%gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmcheckspecificationreport.sas $);

%mend;
