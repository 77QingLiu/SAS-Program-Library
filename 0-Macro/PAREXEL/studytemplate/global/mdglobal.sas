/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor/Protocol No:   <client> / <protocol>
  PXL Study Code:        <TIME code>

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
  
-------------------------------------------------------------------------------

  Author:                <author> $LastChangedBy: $
  Creation Date:         <date in DDMMMYYYY format> / $LastChangedDate: $

  Program Location/Name: $HeadURL: $

  Files Created:         metadata.global

  Program Purpose:       Define global metadata to be used by study programs

  Macro Parameters:      NA

    Name:                projPre
      Default Value:     &_projPre.
      Description:       Path to the project folder, e.g. /projects/abc123456/stats/ .

    Name:                type
      Default Value:     &_type.
      Description:       Analysis type, a subfolder in the project folder where the analysis is performed, e.g. dlt, primary .
                         Metadata library is created in the <projPre>/<type>/data/metadata subfolder.

    Name:                force
      Allowed Values:    0|1
      Default Value:     0
      Description:       Force the metadata dataset to be overwritten.

-------------------------------------------------------------------------------
  MODIFICATION HISTORY:  see Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro createMetadata(projPre=&_projPre, type=&_type, force=0);

    %*----------------------------------------------------------------------
    Check metadata library
    ------------------------------------------------------------------------;
    %if %sysFunc(libRef(metadata)) %then %do;
        %gmMessage (linesOut=No metadata library found. Creating library METADATA.);

        %if "&type" = "" or "&projPre" = "" %then %do;
            %gmMessage(linesOut = Macro variables _TYPE and _PROJPRE are not created.
                                  @ Cannot determine path of metadata library. Specify the variables
                                  @ directly in the mdglobal.sas or set the _TYPE and _PROJPRE.
                       selectType = abort
                      );
        %end;

        %gmMessage(linesOut = Metadata library is created in the &projPre.&type/data/metadata);

        %if not %sysFunc(fileExist(&projPre./&type./data/metadata)) %then %do;
            %let rc = %gmExecuteUnixCmd(cmds = mkdir -p &projPre./&type./data/metadata);
        %end;

        %* Create the library. Compress option is not set as some clients require not to use it.;
        libName metadata "&projPre./&type./data/metadata";

    %end;

    %*----------------------------------------------------------------------
    Create global metadata
    ------------------------------------------------------------------------;
    %* Create a temporary library - gmStart is not used as not needed for this purpose;
    %let rc = %gmExecuteUnixCmd(cmds = mkdir -p %sysFunc(pathName(work))/mdglobaltemp);
    libName mdGlTemp "%sysFunc(pathName(work))/mdglobaltemp";

    data mdGlTemp.global;

        length key value comment $200;

        %*----------------------------------------------------------------------
        Required metadata keys
        ------------------------------------------------------------------------;

        %* Study Number. Do not autogenerate this number from path way as it will be used to verify global metadata is not copied from
           another study without changes;
        key = "studyNumber";
        value = "<TIME code>";
        comment = "Study number on Kennet";
        output;

        %* Sponsor name;
        key = "sponsorName";
        value = "<client>";
        comment = "Sponsor name";
        output;

        %* SAS Verion used for the study, e.g., 9.2/9.3/9.4;
        key = "SASVer";
        value = "<SAS version>";
        comment = "SAS Version used on the study";
        output;

        %*----------------------------------------------------------------------
        Optional metadata keys, if the values are not specified,
        they will be defauled by each macro
        ------------------------------------------------------------------------;

        %* CDISC Model used in the development area. Valid values: SDTM or ADaM. Must not contain version;
        key = "CDISCModel";
        %if %superQ(_type) = tabulate %then %do;
            value = "SDTM";
        %end;
        %else %if %superQ(_type) = dmc
                  or  
                  %superQ(_type) = interim 
                  or 
                  %superQ(_type) = primary
        %then %do;
            value = "ADaM";
        %end;
        comment = "CDISC Model used for development: SDTM/ADaM";
        output;

        %* MedDRA version, should be equal to one of the folder names in /opt/pxlcommon/stats/dictionaries/MedDRA/;
        key = "MedDRAVer";
        value = "";
        comment = "MedDRA Version";
        output;

        %* ADaM Controlled Terminology, should be equal to one of the folder names in /opt/pxlcommond/stats/dictionaries/CDISC/ADaM;
        key = "ADaMCT";
        value = "";
        comment = "ADaM Controlled Terminology";
        output;

        %* SDTM Controlled Terminology, should be equal to one of the folder names in /opt/pxlcommond/stats/dictionaries/CDISC/SDTM;
        key = "SDTMCT";
        value = "";
        comment = "SDTM Controlled Terminology";
        output;

        %* Default SDTM/ADaM Libraries. For ADaM projects: ANALYSIS(ADaM) and RAW(SDTM), for SDTM projects: TRANSFER(SDTM);
        key = "libSDTM";
        %if %superQ(_type) = tabulate %then %do;
            value = "RAW";
        %end;
        %else %if %superQ(_type) = dmc
                  or  
                  %superQ(_type) = interim 
                  or 
                  %superQ(_type) = primary
        %then %do;
            value = "TRANSFER";
        %end;
        comment = "Default library containing SDTM datasets";
        output;

        key = "libADaM";
        %if %superQ(_type) = dmc
            or  
            %superQ(_type) = interim 
            or 
            %superQ(_type) = primary
        %then %do;
            value = "ANALYSIS";
        %end;
        comment = "Default library containing ADaM datasets";
        output;

        %*----------------------------------------------------------------------
        OpenCDISC/Pinnacle 21 metadata keys
        -----------------------------------------------------------------------;

        %* OpenCDISC/Pinnacle 21 version. Required to be specified in order to run gmExecuteOpenCDISC;
        key = "pinnacle21Ver";
        value = "2.1.3";
        comment = "OpenCDISC/Pinnacle 21 version";
        output;

        %* Path to a custom OpenCDISC/Pinnacle 21 installation. If missing, a default value will be used.;
        %* See gmExecuteOpenCDISC description for details;
        key = "pathPinnacle21";
        value = "";
        comment = "Path to a custom OpenCDISC/Pinnacle 21 installation";
        output;

        %* OpenCDISC/Pinnacle 21 configuration file,
        %* should be equal to one of the configuration files in /opt/pxlcommon/stats/applications/opencdisc/<ver>/config;
        %* If missing a default value will be used. See gmExecuteOpenCDISC description for details;
        key = "pinnacle21Config";
        value = "";
        comment = "OpenCDISC/Pinnacle 21 configuration file";
        output;

        %*----------------------------------------------------------------------
        gmLogScan* metadata keys
        ------------------------------------------------------------------------;

        %* Scan List, specifies whether whitelist of blacklist will be used by default;
        key = "logScanList";
        value = "white";
        comment = "List type used for log scanning";
        output;

        %* Full path and name of a custom White list - supplemental list which will be used together with Whitelist;
        key = "customWhiteList";
        value = "";
        comment = "Path to custom whitelist";
        output;

        %*----------------------------------------------------------------------
        gmCompare* metadata keys
        ------------------------------------------------------------------------;

        %* QC dataset prefix;
        key = "dsQcPrefix";
        value = "";
        comment = "Prefix for QC dataset name";
        output;

        %* QC report prefix;
        key = "outputQcPrefix";
        value = "";
        comment = "Prefix for compare results output";
        output;

        %*----------------------------------------------------------------------
        gmInText* metadata keys
        ------------------------------------------------------------------------;

        key = "inTextTemplateVer";
        value = "";
        comment = "In-Text Table ODS RTF Style Template Version (ISO 8601 date format)";
        output;

        key = "inTextFootnoteAbbrBold";
        value = "0";
        comment = "Bold string Abbreviations: in In-Text Table footnotes";
        output;

        key = "inTextFootnoteSourceItalic";
        value = "0";
        comment = "Italicize Source: footnotes in In-Text Tables";
        output;

        key = "inTextFootnoteBottomBorder";
        value = "0";
        comment = "Insert border under footnotes in In-Text Tables";
        output;

        key = "inTextRtfHeader";
        value = " ";
        comment = "File containing RTF replacement header for using in In-Text Tables";
        output;

        key = "inTextReplaceSymbols";
        value = "1";
        comment = "Replace symbols in In-Text Table post-processing";
        output;

        %*----------------------------------------------------------------------
        gmImportSpecification metadata keys
        ------------------------------------------------------------------------;

        key = "fileSpec";
        %if %superQ(_type) = tabulate %then %do;
            value = "";
        %end;
        %else %if %superQ(_type) = dmc %then %do;
            value = "";
        %end;
        %else %if %superQ(_type) = interim %then %do;
            value = "";
        %end; 
        %else %if %superQ(_type) = primary %then %do;
            value = "";
        %end;
        comment = "WebDAV link to PMED location of the spec or path to the file";
        output;

    run;
    %*----------------------------------------------------------------------
    Perform metadata checks
    ------------------------------------------------------------------------;

    %* Check if metadata.global already exists;
    %if %sysFunc(exist(metadata.global)) %then %do;
        %gmMessage(linesOut=Metadata global already exists.
                            @Checking if a modification is required.
                            );

        %* gmCompare is not used as no output required;
        proc compare noprint base = metadata.global comp = mdGlTemp.global;
        run;

        %* Check if anything but a label is different;
        %if &sysInfo. > 1 %then %do;
            %if &force = 1 %then %do;
                %gmMessage(linesOut=Overwriting the metadata.global dataset.);

                data metadata.global;
                    set mdGlTemp.global;
                run;
            %end;
            %else %do;
                %gmMessage(linesOut=Metadata.global dataset and mdglobal.sas are not consistent.
                                    @Please check if update required. SysInfo = &sysInfo.,
                           selectType = E
                          );
            %end;
        %end;
        %else %do;
            %gmMessage(linesOut=No modification required.);
        %end;
    %end;
    %else %do;
        %* Create the metadata.global;
        data metadata.global;
            set mdGlTemp.global;
        run;
    %end;

    %* Cleanup;
    libName mdGlTemp;

    %* Check required values were populated;
    %local md_noStudyNumber md_studyExample md_noSponsorName md_sponsorExample md_noSASVer;
    %let md_noStudyNumber = 0;
    %let md_noSponsorName = 0;
    %let md_noSASVer = 0;

    data _null_;
        set metadata.global;
        if upcase(key) = "STUDYNUMBER" and missing(value) then do;
            call symputx ("md_noStudyNumber",1);
            call symput ("md_studyExample",prxChange("s/.*project..(\D+)(\d+).*/$2/",1,"&projPre."));
        end;
        if upcase(key) = "SPONSORNAME" and missing(value) then do;
            call symputx ("md_noSponsorName",1);
            call symput ("md_sponsorExample",prxChange("s/.*project..(\D+)(\d+).*/$1/",1,"&projPre."));
        end;
        if upcase(key) = "SASVER" and missing(value) then do;
            call symputx ("md_noSASVer",1);
        end;
    run;

    %if &md_noStudyNumber %then %do;
        %gmMessage(linesOut=Incorrect study number provided. Please remove metadata.global and update the mdglobal.sas.
                            @or set force parameter to 1 in mdglobal.sas. For example &md_studyExample..
                   , selectType = E
                  );
    %end;

    %if &md_noSponsorName %then %do;
        %gmMessage(linesOut=Incorrect sponsor name provided. Please remove metadata.global and update the mdglobal.sas.
                            @or set force parameter to 1 in mdglobal.sas. For example &md_sponsorExample..
                   , selectType = E
                  );
    %end;

    %if &md_noSASVer %then %do;
        %gmMessage(linesOut=Incorrect SAS version provided. Please remove metadata.global and update the mdglobal.sas.
                            @or set force parameter to 1 in mdglobal.sas. For example &sysVer.
                   , selectType = E
                  );
    %end;

%mend createMetadata;

%createMetadata(projPre=&_projPre.,type=&_type.,force=0);
