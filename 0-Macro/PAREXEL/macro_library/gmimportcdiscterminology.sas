/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Tim Schwarz, Dmitry Kolosov $LastChangedBy: kolosod $
  Creation Date:         04JUL2014  $LastChangedDate: 2016-10-03 04:53:09 -0400 (Mon, 03 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmimportcdiscterminology.sas $

  Files Created:         &dataOut dataset.

  Program Purpose:       The imports CDISC terminology from a standard dictionary library.
                         It also allows to import terminology from a custom xls file.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                standards
      Description:       String containing information about CDISC standards to import:
                         #standard1 \VER=yyyy-mm-dd \SHEETNAME= \FILEIN=
                         #@standard2 \VER=yyyy-mm-dd \SHEETNAME= \FILEIN=
                         # Where standard is name of terminology standards, e.g, SDTM, ADaM, QRS.
                         The name is case sensitive. 
                         * In order to load standards from the Kennet
                         dictionary (/opt/pxlcommon/stats/dictionaries/CDISC/), use one of the 
                         following names: ADaM, CDASH, COA, QRS, QS, QS-FT, SDTM, SEND.
                         # Where VER is a standard version in the ISO8601 format, in case it 
                         is loaded from the Kennet dictionary library.
                         * If it is required to load a custom terminology, a full path 
                         with a filename to an XLS file, should be provided in the FILEIN option
                         and SHEETNAME should contain name of the sheet with the terminology in
                         that file.

    Name:                dataOut
      Allowed Values:    
      Default Value:     metadata.cdiscTerminology
      Description:       Output dataset.

    Name:                splitCharParameter
      Allowed Values:    
      Default Value:     @
      Description:       The character to split standards in the input value. Cannot be "=".

    Name:                splitCharOption
      Allowed Values:    
      Default Value:     \
      Description:       The character to split options in the standards input value. Cannot be "=".

    Name:                maxLen
      Default Value:     200
      Description:       The maximum length of columns from the terminology spreadsheet. Also used to specify 
                         maximum option value length of the STANDARDS parameter.

    Name:                metadataIn
      Default Value:     metadata.global
      Description:       Dataset containing metadata.

  Macro Returnvalue:     N/A

  Metadata Keys:

    Name:                ADaMCT
      Description:       ADaM Controlled Terminology version, date in ISO8601 format.
      Dataset:           Global

    Name:                SDTMCT
      Description:       SDTM Controlled Terminology version, date in ISO8601 format.
      Dataset:           Global

    Name:                QRSCT
      Description:       QRS Controlled Terminology version, date in ISO8601 format.
      Dataset:           Global

  Macro Dependencies:    gmParseParameters (called)
                         gmCheckValueExists (called)
                         gmMessage (called)
                         gmStart (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2686 $
-----------------------------------------------------------------------------*/

%macro gmImportCdiscTerminology
(
        standards = 
      , dataOut = metadata.cdiscTerminology
      , maxLen =200
      , splitCharParameter = @
      , splitCharOption = \
      , metadataIn = metadata.global
);

%* Initialized the macro and create a temporary library;
%local ct_lib;
%let ct_lib = %gmStart(headURL   = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmimportcdiscterminology.sas $
                       , revision  = $Rev: 2686 $
                       , checkMinSasVersion=9.2
                       , libRequired = 1
                       );

%* Define local macro variables;
%local ct_i;

%* Update QuoteLenMax option to avoid extra message for long parameters;
%let ct_quoteLenMax =%sysFunc(getOption(quoteLenMax));
option noquotelenmax;

%* Check parameters;
%* Check for missing parameters;

%gmCheckValueExists( codeLocation = standards, value = &standards., 
                     selectMethod = EXISTS );

%gmCheckValueExists( codeLocation = dataOut, value = &dataOut., 
                     selectMethod = EXISTS );


%* Parse the main parameter;
%gmParseParameters(  parameters         = &standards.
                   , optionsDefinition  = VER&splitCharParameter.SHEETNAME&splitCharParameter.FILEIN
                   , dataOut = &ct_lib..standardsRaw
                   , splitCharParameter = &splitCharParameter.                   
                   , splitCharOption    = &splitCharOption.
                   );

%* Check there are no duplicate standards;
proc sort data = &ct_lib..standardsRaw;
    by parameter;
run;

data _null_;
    set &ct_lib..standardsRaw;
    by parameter;
    length gmCtImpSRc $200;

    if not (first.parameter and last.parameter) then do;
        gmCtImpSRc = resolve('%gmMessage(codeLocation=gmImportTerminology/options check, linesOut='
                           ||'Standard '||strip(parameter)||' is listed more than once.' 
                           ||', selectType = ABORT);'
                          );
    end;
run;


%* Change length for expected options;
data &ct_lib..standards0;
    set &ct_lib..standardsRaw;

    length ver sheetName fileIn $&maxLen.;

    ver = strip(verValue);
    sheetName = strip(sheetNameValue);
    fileIn = strip(fileInValue);
run;

%* Load metadata;
%if %sysFunc(exist(&metadataIn)) %then %do;

    data &ct_lib..metadata;
        set &metadataIn.;
        length parameter $5;

        if upcase(key) = "ADAMCT" and not missing(value) then do;
            parameter = "ADaM";
            output;
        end;

        if upcase(key) = "SDTMCT" and not missing(value) then do;
            parameter = "SDTM";
            output;
        end;

        if upcase(key) = "QRSCT" and not missing(value) then do;
            parameter = "QRS";
            output;
        end;
    run;
    %* Merge metadata with the provided values;
    proc SQL noprint;
    create table &ct_lib..standardsMeta as
        select * 
        from &ct_lib..standards0 natural left join &ct_lib..metaData
        ;
    quit;

    data &ct_lib..standards1(drop = value);
        set &ct_lib..standardsMeta;
        length gmCtImpSRc $200;

        if not missing(value) then do;
            if missing(ver) then do;
                ver = value;
            end;
            else if ver ne value then do;
                gmCtImpSRc = resolve('%gmMessage(codeLocation=gmImportTerminology/metadata check, linesOut='
                                   ||'VER option for '||strip(parameter)||' differs from metadata.global' 
                                   ||'@CT version value. VER option value has been used.);'
                                  );
            end;
        end;
        proc sort; by number;
    run;
%end;
%else %do;
    %* Copy dataset;
    data &ct_lib..standards1;
        set &ct_lib..standards0;

        length gmCtImpSRc $200;
        gmCtImpSRc = " ";
        proc sort; by number;
    run;
%end;

%* Set default path to controlled terminology;
data &ct_lib..standards2;
    set &ct_lib..standards1 end = lastRecord;
    by number;

    %* Standard name cannot be missing;
    if missing(parameter) then do;
        gmCtImpSRc = resolve('%gmMessage(codeLocation=gmImportTerminology/options check, linesOut='
                           ||'There is a missing standard name in item '||strip(put(number,best.))||' ' 
                           ||', selectType = ABORT);'
                          );
    end;

    * In case path was not provided, load terminology from the standard library;
    if missing(fileIn) then do;
        if parameter in ("ADaM","SDTM","COA","SEND","CDASH","QRS","QS","QS-FT") then do;
            if not prxMatch("/^\d{4}-\d{2}-\d{2}$/",strip(ver)) then do;
                gmCtImpSRc = resolve('%gmMessage(codeLocation=gmImportTerminology/options check, linesOut='
                                     ||'VER option or metadata key value '||strip(ver)||' for '||strip(parameter)||' ' 
                                     ||'@is not in ISO8601 format., selectType = ABORT);'
                                    );
            end;
            else do;
                sheetName = strip(parameter)||" Terminology "||strip(ver);
                fileIn = catx("/","/opt/pxlcommon/stats/dictionaries/CDISC",parameter,ver
                              ,strip(sheetName)||".xls"
                             );
            end;
        end;
        else do;
            gmCtImpSRc = resolve('%gmMessage(codeLocation=gmImportTerminology/options check, linesOut='
                                 ||'There are not default values for standard '||strip(parameter)||' ' 
                                 ||'@populate FILEIN and SHEETNAME option for it., selectType = ABORT);'
                                );
        end;
    end;
    else do;
        if missing(sheetName) then do;
            gmCtImpSRc = resolve('%gmMessage(codeLocation=gmImportTerminology/options check, linesOut='
                                 ||'Missing sheetName for for standard '||strip(parameter)||' ' 
                                 ||', selectType = ABORT);'
                                );
        end;
    end;

    * Check the terminology file exists;
    if not fileExist(fileIn) then do;
            gmCtImpSRc = resolve('%gmMessage(codeLocation=gmImportTerminology/options check, linesOut='
                                 ||'File '||strip(fileIn)||' does not exist.' 
                                 ||', selectType = ABORT);'
                                );
    end;

    %* Generate import lines; 
    length importCode $32767 datasetName $32;

    %* Copy file to the work library and use it as an input;
    rc = system("cp -f '"||strip(fileIn) || "' " || strip(pathName("work")) );
    fileIn = strip(pathName("work")) || "/" || prxChange("s/(.*\/)?([^\/]+)$/$2/",1,strip(fileIn));

    %* Replace possible special characters;
    datasetName = "&ct_lib..term"||prxChange("s/\W/_/",-1,strip(parameter));
    call symputx("ct_datasetName"||strip(put(number,best.)),strip(datasetName),'L');

    importCode =  "proc import dataFile = '" || strip(fileIn) || "' out = "|| strip(datasetName)  ||" dbms = xls replace;"
                  ||"sheet ='" || strip(sheetName) || "';"
                  ||" textSize = &maxLen.;"
                  ||" getNames = No;"
                  ||"run;";
    call symputx("ct_importCode"||strip(put(number,best.)),strip(importCode),'L');

    %* Get number of standards to process;
    if lastRecord then do;
        call symputx("ct_stdNum",number,'L');
    end;
run;

%*Import the data;
%do ct_i = 1 %to &ct_stdNum.;
    &&ct_importCode&ct_i.
%end;
    
%* Compile all codelists into 1 dataset ;
data &ct_lib..term_cdiscTermRaw ;
    attrib    a label="Code" length=$40 format=$40.
              b label="Codelist Code" length=$40 format=$40.
              c label="Codelist Extensible " length=$40 format=$40.
              d label="Codelist Name" length=$&maxLen. format=$&maxLen..
              e label="CDISC Submission Value" length=$&maxLen. format=$&maxLen..
              standard label="Standard" length=$32 format=$32.
    ;
    set 
        %do ct_i = 1 %to &ct_stdNum.;
            &&ct_datasetName&ct_i. (keep = a b c d e where = (upcase(a) not in ("CODE"," ")))
        %end;
        inDsName=fullDsName
    ;    
    standard = prxChange("s/.*?\.term(.*)/$1/i",1,fullDsName);
run;


%* Separate code lists and code values ;
data &ct_lib..term_cdiscTermValuesInitial(keep = listCode valueCode codes standard)
    &ct_lib..term_cdiscTermCodeLists(keep = listCode codelistID extensibleFlag codelistName codelistID standard);
    set &ct_lib..term_cdiscTermRaw;

    attrib valueCode label="Value Code" length=$40 format=$40.
        listCode label="Codelist Code" length=$40 format=$40.
        extensibleFlag label="Codelist Extensible " length=$1 format=$1.
        codelistName label="Codelist Name" length=$&maxLen. format=$&maxLen..
        codelistID label="CDISC Submission Value (List ID)" length=$&maxLen. format=$&maxLen..
        codes label="CDISC Submission Value" length=$&maxLen. format=$&maxLen..
    ;

    codelistName = d;
    if missing(b) then do;
        %* Keep only the first char Y/N;
        extensibleFlag = substr(c,1,1);
        codelistID = e;
        listCode = a;
        output &ct_lib..term_cdiscTermCodeLists;
    end;
    else do;
        codes = e;
        valueCode = a;
        listCode = b;
        output &ct_lib..term_cdiscTermValuesInitial;
    end;
run;

%* Remove repeated code lists/values ;
proc sort data = &ct_lib..term_cdiscTermValuesInitial nodupkey;
    by standard listCode valueCode codes;
run;

proc sort data = &ct_lib..term_cdiscTermCodeLists nodupkey;
    by _all_;
run;

proc sort data = &ct_lib..term_cdiscTermCodeLists nodupkey;
    by standard listCode;
run;

%* Add code list ID to the values dataset ;
data &ct_lib..term_cdiscTermAll;
    merge &ct_lib..term_cdiscTermValuesInitial 
    &ct_lib..term_cdiscTermCodeLists(keep = standard listCode codelistId codelistName extensibleFlag);
    by standard listCode;
run;  
  
%* Sort and store in metadata library ;
proc sql;
    create table &dataOut as
    select valueCode, codes, listCode, codelistId, codelistName, extensibleFlag, standard 
    from   &ct_lib..term_cdiscTermAll
    order by codelistId, listCode, valueCode, standard;
quit;

%* Restore options;
option &ct_quotelenMax.;

%gmEnd(
            headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmimportcdiscterminology.sas $
);

%mend gmImportCdiscTerminology;
