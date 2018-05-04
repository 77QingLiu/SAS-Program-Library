/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Tim Schwarz, Dmitry Kolosov $LastChangedBy: kolosod $
  Creation Date:         18DEC2012  $LastChangedDate: 2016-10-25 05:12:55 -0400 (Tue, 25 Oct 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmdefinexml.sas $

  Files Created:         define.xml

  Program Purpose:       The macro is used to create define.xml.
                         It uses the metadata from the PAREXEL ADS/DTMS specs.
                         It is based on Define 2.0.0 standard from March 2013.


                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                documents                    
      Allowed Values:    
      Default Value:     
      Description:       List of reference documents in the following format:
                         #DOCREF \href=<relative path/fileName> \title=<title>
                         #Example:
                         CRF \href=/docs/pxl80386_blankcrf.pdf \title=CRF
                         @SAP \href=/docs/sap.pdf \title=Statistical Analysis Plan

    Name:                libSpecIn 
      Allowed Values:    
      Default Value:     metadata
      Description:       Library containing specification datasets.

    Name:                libsDataIn 
      Allowed Values:    
      Default Value:     
      Description:       Dataset libraries. When specified, datasets from these libraries are used to populate 
                         length and format where ~ASDATA is specified.

    Name:                pathOut 
      Allowed Values:    
      Default Value:     
      Description:       Location (physical path) of the resulting define.xml file,
                         e.g., &_projpre./primary/define/

    Name:                pathXptIn
      Allowed Values:    
      Default Value:     
      Description:       Location of the XPT SAS files relative to define.xml
                         #If left as missing, it is assumed that datasets are in the same folder
                         as define.xml

    Name:                pathXslIn
      Allowed Values:    
      Default Value:     stylesheets/
      Description:       Location of the XSL style sheet relative to define.xml.
                         #stylesheets : expects the stylesheet define2-0-0.xsl 
                         #If set to missing, it is assumed that the stylesheet is in the same folder as the
                         define.xml file

    Name:                escapeChar
      Allowed Values:    
      Default Value:     ~
      Description:       Separator character for linking CRF, SAP, Dataguide or other documents.
                         Also is used to control other functionality within the macro. 
                         This character must not be used in the specs for any purposes, other than 
                         escaping special keywords for define.xml generation.


    Name:                xptNameType
      Allowed Values:    _UPCASE_|_LOWCASE_
      Default Value:     _LOWCASE_
      Description:       Specifies if the stored xpt file names are in upper or
                         lower case. It is needed to create links to correponding
                         datasets.

    Name:                createDefinePdf
      Allowed Values:    0|1
      Default Value:     0
      Description:       defines whether a define.pdf report is created in addition
                         to the define.xml. This functionality is not yet validated. 

    Name:                maxFieldLength
      Allowed Values:    1-32767
      Default Value:     32000
      Description:       Maximum field length used within the macro.
                         Is set by default to 32000 during ADS import.

    Name:                splitCharParameter
      Allowed Values:    A single character excluding "="
      Default Value:     @
      Description:       The character to split documents in the documents parameter.

    Name:                splitCharOption
      Allowed Values:    A single character not equal to splitCharParameter and not "="
      Default Value:     \
      Description:       The character to split options in the documents parameter.

  Macro Returnvalue:     N/A

  Macro Dependencies:    gmParseParameters (called)
                         gmCheckValueExists (called)
                         gmReplaceText (called)
                         gmMessage (called)
                         gmStart (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2798 $
-----------------------------------------------------------------------------*/

%macro gmDefineXml
    (
        documents                  =,
        libSpecIn                  =metadata,
        libsDataIn                 =,
        pathOut                    =,
        pathXptIn                  =,
        pathXslIn                  =stylesheets/,
        createDefinePdf            =0,
        xptNameType                =_LOWCASE_,
        escapeChar                 =%str(~),
        maxFieldLength             =32000,
        splitCharParameter         =@, 
        splitCharOption            =\
    );

%local defxml_libName;

%let defxml_libName = %gmStart(
    headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmdefinexml.sas $
    ,checkMinSasVersion = 9.2
    ,revision = $Rev: 2798 $
    ,libRequired = 1
);

%* Save options;
proc optsave out=&defxml_libName..options;
run;

%local 
    defxml_dsname
    defxml_dsno
    defxml_i
    defxml_compileTime
    defxml_userOpt 
    defxml_documentsFl
    defxml_maxLengthValItemId
    defxml_userName
    defxml_docRegex
    defxml_escapeCharRegex
    defxml_asDatanObs
    defxml_libNum
    defxml_libIn
;

%let defxml_maxLengthValItemId = 40;

%let defxml_compileTime=%sysFunc(time(), time8.);

* Redirect working library to the GML library;
options user=&defxml_libName compress=Y;

%*-------------------------------------------------------------------------------------------------
Parameter checks
---------------------------------------------------------------------------------------------------;

%* Check datasets exist;

%if not %sysFunc(exist(&libSpecIn..specCoverPage))
    or
    not %sysFunc(exist(&libSpecIn..specData))
    or
    not %sysFunc(exist(&libSpecIn..specVar))
    or
    not %sysFunc(exist(&libSpecIn..specCodelist))
    %then %do;
    %gmMessage(codeLocation = gmDefineXml/Parameter checks
               ,linesOut = %str(This macro requies specCoverPage, specData, specVar, specCodelist datasets to run.)
               ,selectType=ABORT     
              );
%end;

%if %qLeft(&maxFieldLength.) < 1 or %qLeft(&maxFieldLength) > 32767 %then %do;
    %gmMessage( codeLocation = gmDefineXml/Parameter checks
              , linesOut     = %str(Parameter width= &maxFieldLength. has an invalid value, please choose a value between 1 and 32767)
              , selectType   = ABORT
              )
%end;

%let xptNameType = %bQuote(%upcase(&xptNameType));
%if %qSysFunc(prxMatch(/^(_LOWCASE_|_UPCASE_)$/,&xptNameType)) ~= 1 %then %do;
    %gmMessage(
          codeLocation = gmDefineXml/Parameter checks
        , linesOut     = %str(Parameter xptNameType = &xptNameType. has an invalid value.@Please choose _LOWCASE_ or _UPCASE_)
        , selectType   = ABORT
        , splitChar    = @
            )
%end;

%if %length(%superQ(escapeChar)) > 1 %then %do;
    %gmMessage( codeLocation = gmDefineXml/Parameter checks
              , linesOut     = %str(Parameter escapeChar must be a single character.)
              , selectType   = ABORT
              , splitChar    = @
              );
%end;

%*-------------------------------------------------------------------------------------------------
Prepare var metadata
---------------------------------------------------------------------------------------------------;

%* reduce length of some spec variables (which are set to 32000 per default) to improve performance 
  and remove NOT USED variables from specs;
data advar(drop =vSortC vPosC);
    length paramid $&maxFieldLength.;
    format paramid $&maxFieldLength..;
    set &libSpecIn..specvar(rename = (paramid=paramIdRaw vSort=vSortC vPos=vPosC));

    paramid = paramIdRaw;
    %* Convert sorting variables to numbers;
    if not missing(vSortC) then do;
        vSort = input(vSortC,best.);
    end;
    if not missing(vPosC) then do;
        vPos = input(vPosC,best.);
    end;

    %* Remove trailing whitespace char from the vSource column;
    vSource = prxChange("s/\s*$//",1,trim(vSource));

    %* Remove NOT USED items ;
    where strip(upcase(vkey)) ne "NOT USED"; 
run;

%* Get all codelists;
data codelist;
    set &libSpecIn..speccodelist;
run;

data specdata;
    set &libSpecIn..specdata;
    %* Remove trailing whitespace char from the vSource column;
    dsco = prxChange("s/\s*$//",1,trim(dsco));
run;

data specCoverPage(keep = key value);
    set &libSpecIn..specCoverPage;

    length value key $&maxFieldLength.;

    value = c;
    key = b;
run;
%* Replace special characters;
%do defxml_i = 1 %to 4;

    %if &defxml_i = 1 %then %do;
        %let defxml_currDs = adVar;
    %end;
    %else %if &defxml_i = 2 %then %do;
        %let defxml_currDs = codelist;
    %end;
    %else %if &defxml_i = 3 %then %do;
        %let defxml_currDs = specData;
    %end;
    %else %if &defxml_i = 4 %then %do;
        %let defxml_currDs = specCoverPage;
    %end;

    %* remove excel cell breaks ;
    %if &defxml_currDs = adVar %then %do;
        %gmReplaceText(  dataIn   = &defxml_currDs
                       , dataOut  = &defxml_currDs
                       , textSearch = [\xA\xD]+
                       , textReplace = %str( )
                       , useRegex = 1
                       , selectType = QUIET
                       , includeVars = paramId@vcodes@vrcodes
        );
    %end;

    %*--- prepare text fields for html usage (replace non xml conform characters) ---;

    %* & needs to be replaced first with xml conform &amp;
    %gmReplaceText(  dataIn   = &defxml_currDs
                   , dataOut  = &defxml_currDs
                   , textSearch = [\x26]
                   , textReplace = %nrStr(&amp;)
                   , useRegex = 1
                   , selectType = QUIET
    );

    %gmReplaceText(  dataIn   = &defxml_currDs
                   , dataOut  = &defxml_currDs
                   , textSearch = [\x3C]
                   , textReplace = %nrStr(&lt;)
                   , useRegex = 1
                   , selectType = QUIET
    );

    %gmReplaceText(  dataIn   = &defxml_currDs
                   , dataOut  = &defxml_currDs
                   , textSearch = [\x3E]
                   , textReplace = %nrStr(&gt;)
                   , useRegex = 1
                   , selectType = QUIET
    );

    %gmReplaceText(  dataIn   = &defxml_currDs
                   , dataOut  = &defxml_currDs
                   , textSearch = [\x22]
                   , textReplace = %nrStr(&quot;)
                   , useRegex = 1
                   , selectType = QUIET
    );

    %* “ will be replaced with normal double quotes ;
    %gmReplaceText(  dataIn   = &defxml_currDs
                   , dataOut  = &defxml_currDs
                   , textSearch = [\x93\x94]
                   , textReplace = %nrStr(&quot;)
                   , useRegex = 1
                   , selectType = QUIET
    );

    %* long dash will be replaced by normal dash (could possibly be removed if output file is UTF8 format);
    %gmReplaceText(  dataIn   = &defxml_currDs
                   , dataOut  = &defxml_currDs
                   , textSearch = [\x13]
                   , textReplace = -
                   , useRegex = 1
                   , selectType = QUIET
    );
%end;

%* Generate ID for each record;
data adVarId0;
    set adVar;

    originalSort = _n_;

    length recId $64;
    if upcase(paramId) = "*ALL*" then do;
        recId = strip(upcase(dsName)) || "." || strip(upcase(vName));
    end;
    else if upcase(paramId) = "*DEFAULT*" then do;
        recId = strip(upcase(dsName)) || "." || strip(upcase(vName)) || ".DEFAULT";
    end;
    else if prxMatch("/^\w{1,16}$/",strip(paramId)) and upcase(paramId) ne "DEFAULT" then do;
        recId = strip(upcase(dsName)) || "." || strip(upcase(vName)) || "." || strip(upcase(paramId));
    end;
    else do;
        recId = strip(upcase(dsName)) || "." || strip(upcase(vName)) || "." || put(md5(compress(paramId)),hex16.) ;
    end;
    proc sort; by recId paramId;
run;

%* In case there are the same MD5 hash codes, add .1, .2, .3, .. etc;
data adVar;
    set adVarId0;
    by recId paramId;

    retain i 0;

    if not first.recId and last.recId then do;
        if first.recId then do;
            i = 1;
        end;
        else do;
            i = i + 1;
        end;
        recId = strip(recId) ||"."  || strip(put(i,best.));
    end;
run;

proc sort data = adVar out = adVar;
    by originalSort;
run;


%* Derive length/parameter based on dataset values;
%* Get number of observations with ASDATA length;
proc sql noprint;
    select count(*) into :defxml_asDatanObs
    from adVar
    where upcase(vLength) = "&escapeChar.ASDATA"
;
quit;

%if &defxml_asDatanObs > 0 and %superQ(libsDataIn) ne %then %do;

    data adVarLengthAsData0;
        set adVar (where = (upcase(vLength) = "&escapeChar.ASDATA"));    
    run;

    %* Read all libraries;
    %let defxml_libNum = %eval(%sysFunc(countc(&libsDataIn,&splitCharParameter.)) + 1);

    %do defxml_i = 1 %to &defxml_libNum.;
        %let defxml_libIn = %scan(&libsDataIn.,&defxml_i.,&splitCharParameter.);
        proc contents noprint data = &defxml_libIn.._all_ 
                      out = libInfo_&defxml_libIn.(keep = libName memName name length format formatL formatD);
        run;
    %end;
    %* Unite into one dataset;
    data libInfo(keep = memName name lengthAsData formatAsData);
        set libInfo_:;

        name = upcase(name);
        memName = upcase(memName);

        lengthAsData = length;
        %* Derive format;
        length formatAsData $32;
        formatAsData = strip(format)||strip(put(formatL,best.));
        if not missing(formatD) then do;
            formatAsData = strip(formatAsData) || "." || strip(put(formatD,best.));
        end;
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

    data adVar;
        set adVar(where = (upcase(vLength) ne "&escapeChar.ASDATA")) adVarLengthAsData2;
        proc sort; by originalSort;
    run;
%end;

%*--- prepare headdata section (SECTION 1) ---;
* Get cover page information;
data _defxml_sec01_headmeta_01;
    set specCoverPage (where = (upcase(key) in ("STUDY NAME", "STUDY DESCRIPTION", 
                                                "PROTOCOL NAME", "CDISC MODEL", "SPONSOR NAME:" 
                                                "CDISC MODEL VERSION", "CDISC IMPLEMENTATION GUIDE VERSION"
                                               )
                               )
                      )
        end = lastObs
    ;   

    length studyName protocolName $200 sponsorName $60 cdiscVer cdiscIgVer $40 rc $1;

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
        call symputx("defxml_protocolName",trim(value),"L"); 
    end;
    else if upcase(key) eq "CDISC MODEL" then do;
        cdiscModel = value;
        if upcase(value) eq "SDTM" then do;
            call symputx("defxml_defineType","_SDTM_","L"); 
        end;
        else if upcase(value) eq "ADAM" then do;
            call symputx("defxml_defineType","_ADaM_","L"); 
        end;
    end;
    else if upcase(key) eq "CDISC MODEL VERSION" then do;
        cdiscVer = value;
    end;
    else if upcase(key) eq "CDISC IMPLEMENTATION GUIDE VERSION" then do;
        cdiscIgVer = value;
    end;

    if lastObs then do; 
        if upcase(cdiscModel) not in ("SDTM" "ADAM") then do;
            rc = resolve('%gmMessage(linesOut=Specify CDISC model (ADaM or SDTM) on the cover page.'
                                     || ',selectType=ABORT)'
                        );
        end;
        if cMiss(studyName,studyDesc,protocolName,sponsorName,cdiscVer,cdiscIgVer) ne 0 then do;
            rc = resolve('%gmMessage(linesOut=%str(Study name, description, protocol and sponsor names, model and model IG versions'
                                     || '@must be specified on the cover page).,selectType=ABORT)'
                        );
        end;
        output;
    end;
run;

data Defxml_sec01_headmeta;
    set _defxml_sec01_headmeta_01;

    format section $50.
    order best.
    studyId $260.
    ;

    section   = 'SEC01_GLOBAL';
    order     = 1;
    studyId   = compress(upcase(sponsorName)||"/"||upcase(protocolName));
    output;
run;


%*--- prepare doc definition section (SECTION 2/20) ---;

%* Parse the DOCUMENTS parameter;
%gmParseParameters(   parameters=&documents.
                    , optionsDefinition= HREF&splitCharParameter.TITLE
                    , dataOut= documents 
                    , splitCharParameter = &splitCharParameter.
                    , splitCharOption = &splitCharOption.
                  );

%* Initialize documents flag;
%let defxml_documentsFl = 0;
data _defxml_sec02_docdef_01 defxml_sec20_docref;
    format section $50. itemOrder best. defid $100. defhref $200. deftitle $200. rc $1.;
    keep section itemOrder defid defhref deftitle; 
    set documents end = lastObs;

    itemOrder = number;
    defId = parameter;
    defHref = strip(hRefValue);
    defTitle = strip(titleValue);

    %* Set document flag to 1 for further reference;
    if _n_ = 1 then do;
        call symputx("defxml_documentsFl",1,"L");
    end;

    section   = 'SEC02_DOCDEF';
    output _defxml_sec02_docdef_01;

    section   = 'SEC20_DOCREF';
    output defxml_sec20_docref;

    if not (hRefExists and titleExists) then do;
        rc = resolve('%gmMessage(linesOut=File name and title must be specified for '|| strip(parameter) || ' in the DOCUMENTS parameter.'
                                || ',selectType=ABORT)'
                    );
    end;

    * Concatenate all documents into one a regex, which will be used to identify them in the description;
    length docRegex $1024 escapeCharRegex $10;
    drop docRegex escapeCharRegex;

    retain docRegex "";
    if not missing(docRegex) then do;
        docRegex = strip(docRegex) || "|" || strip(parameter);
    end;
    else do;
        docRegex = strip(parameter);
    end;

    if lastObs then do;
        * Create control char, which is regex compliant;
        if index("&escapeChar.","\().+*[]@{}|?$^/") then do;
            docRegex = "\&escapeChar.(?:"||strip(docRegex)||")";
            escapeCharRegex = "\&escapeChar.";
        end;
        else do;
            docRegex = "&escapeChar.(?:"||strip(docRegex)||")";
            escapeCharRegex = "&escapeChar.";
        end;
        call symputx("defxml_docRegex",strip(docRegex),"L");
        call symputx("defxml_escapeCharRegex",strip(escapeCharRegex),"L");
    end;
run;

%* Create start/end flags for supplemental docs;
data _defxml_sec02_docdef_02;
    set _defxml_sec02_docdef_01;

    if upcase(defId) = "CRF" then do;
        itemOrder = 1;
    end;
    else do;
        itemOrder = 2;
    end;
    proc sort; 
        by itemOrder defId;
run;

data defxml_sec02_docdef;
    set _defxml_sec02_docdef_02;
    by itemOrder;

    suppDocStart = 0;
    suppDocEnd = 0;

    if first.itemOrder and itemOrder = 2 then do;
        suppDocStart = 1;
    end;
    if last.itemOrder and itemOrder = 2 then do;
        suppDocEnd = 1;
        itemOrder = 4;
    end;
    %* All other documents need to be withing start and end;   
    if itemOrder = 2 and suppDocStart ne 1 then do;
        itemOrder = 3;
    end;
run;
%*--- prepare value level meta section (section 3) ---;

%* Select variables with value level data (base dataset for flagging) ;
proc sql noprint;
    create table _defxml_sec03_valuemetabase_00 as
    select distinct dsname, vname, 
    case 
        when index(paramid, "&escapeChar.WHERE") ne 0 then 2
        else 1
    end as vlMetaType
    from   adVar (where=(upcase(paramid) ne "*ALL*"))
    order by dsname, vname;
quit;

%*--- create value level meta data (SECTION 3) for *DEFAULT* / PARAMID syntax ---;

%* create base dataset while removing unwanted blanks ;
data _defxml_sec03_valuemeta_00;
    length paramid $&maxFieldLength.;
    set adVar(rename=paramid=paramid2);
    paramid = STRIP(paramid2);
    temporder=_N_;
    * Add flag for *DEFAULT* records;
    if upcase(paramId) eq "*DEFAULT*" then do;
        defaultFl = 1;
    end;
    else do;
        defaultFl = 0;
    end;
    drop paramid2;
run;

proc SQL;
%* Get all values for paramId variables;
create table _defxml_sec03_valuemeta_00_1 as
    select dsName, vName, vrCodes, codelistId 
    from adVar
    where upcase(catx("." ,dsName, vName)) in 
     (select upcase(prxChange("s/^(\w+\.\w+).*/$1/",1,strip(vrcodes))) 
      from adVar
      where prxMatch("/^(\w+\.\w+).*/",strip(vrcodes))
     )
     and not missing(codelistId)
;
%* Get all codelist values paramId variables;
create table _defxml_sec03_valuemeta_00_2 as
    select distinct dsName, vName, code
    from _defxml_sec03_valuemeta_00_1 natural left join codelist (keep = codelistId code)
    order by dsName, vName;
quit;

%* Unite all codes into one variable;
data _defxml_sec03_valuemeta_00_3(keep = relcodes dsName vName vlmFl);
    set _defxml_sec03_valuemeta_00_2;
    by dsName vName;

    
    length relcodes $&maxFieldLength.;
    retain relcodes;

    if first.vName then do;
        relcodes  = code;        
    end;
    else do;
        relcodes = catx(",",relcodes,code);
    end;

    vlmFl = 1;

    %*  Keep only one record per paramId variable;
    if last.vName;
run;
%* Collect all possible codelist values;

%* select value level items ;
proc sql noprint;
    create table _defxml_sec03_valuemeta_01 as
    select distinct *
    from   _defxml_sec03_valuemeta_00
    where  strip(upcase(paramid)) ne "*ALL*" and index(paramid, "&escapeChar.WHERE") = 0
    order by dsname, temporder;
quit;

%* merge related value ids ;
proc sql noprint;
    create table _defxml_sec03_valuemeta_02 as
    select x.*, y.relcodes, y.vlmFl
    from _defxml_sec03_valuemeta_01 as x 
         left join
         _defxml_sec03_valuemeta_00_3 as y
    on upcase(catx("." ,y.dsName, y.vName)) = upcase(prxChange("s/^(\w+\.\w+).*/$1/",1,strip(x.vrcodes)))
    order by dsname, vname, defaultFl, temporder descending;
quit;


%* join non *default* items together in order to subtract from *all* item ;
data _defxml_sec03_valuemeta_02_;
    set _defxml_sec03_valuemeta_02;
    by dsname vname;
    length nondefault $&maxFieldLength. nosep_ 8 vcodes_sep vcodes_sep_regex $&maxFieldLength.;
    %* compile nondefault codes into one cell ;
    retain nondefault;
    if first.vname then nondefault = "";
    if vlmFl eq 1 and strip(paramid) ne "*DEFAULT*" then do;
        nondefault = strip(nondefault) || ", " || strip(paramid);
    end;
    %* remove nondefault codes from *default* codes list ;
    if strip(paramid) eq "*DEFAULT*" then do;
        nosep_ = countc(nondefault,',');
        do i = 1 to nosep_;
            vcodes_sep = strip(scan(nondefault,i,','));
            %* Escape characters \/@$ which are not quoted by \Q\E;
            vcodes_sep_regex = "s/(^|,)\s*\Q" || strip(prxChange("s/([\@\$\\\/])/\\E\\$1\\Q/",-1,trim(vcodes_sep))) || "\E\s*(?=$|,)//";
            %* Remove zero-length quotes: \Q\E;
            vcodes_sep_regex = prxChange("s/\\Q\\E//",-1,trim(vcodes_sep_regex));
            if "&gmDebug." = "1" then do;
                put "NOTE:[PXL] processing code: " vcodes_sep i=;
            end;
            relcodes = prxChange(strip(vcodes_sep_regex), -1, trim(relcodes));
        end;
    end;
    proc sort; by paramid;
run;

%* separate related value ids ;
data _defxml_sec03_valuemeta_03(drop = vcodes_sep_regex);
    set _defxml_sec03_valuemeta_02_;
    by paramid;
    nosep_ = countc(relcodes,',')+1;
    do j = 1 to nosep_;
        vcodes_sep = strip(scan(relcodes,j,','));
        %* Escape characters \/@$ which are not quoted by \Q\E;
        vcodes_sep_regex = "/(^|,)\s*\Q" || strip(prxChange("s/([\@\$\\\/])/\\E\\$1\\Q/",-1,trim(vcodes_sep))) || "\E\s*($|,)/";
        %* Remove zero-length quotes: \Q\E;
        vcodes_sep_regex = prxChange("s/\\Q\\E//",-1,trim(vcodes_sep_regex));
        if not missing(vcodes_sep) then do;
            if prxMatch(strip(vcodes_sep_regex), trim(paramid)) or
                paramid = "*DEFAULT*" then do;
                output;
            end;
        end;
    end;
    proc sort; by dsname vname paramid j;
run;

%* select needed items (for sections 3 and 4) ;
data _defxml_sec03_valuemeta_04;
    length section $50 valItemId $100 wcmethod 8 mandatory $3;
    set _defxml_sec03_valuemeta_03(where=(not missing(vcodes_sep)));
    section = "SEC03_VALUEMETA";
    valItemId = recId;
    %*TODO:;
    %* calculate method tagging (all non predecessor items) ;
    if upcase(vOrigin) eq "DERIVED" then wcMethod = 1;
    else if upcase(vOrigin) eq "ASSIGNED" then wcMethod = 2;
    else if upcase(vOrigin) eq "PREDECESSOR" then wcMethod = 0;
    else wcMethod = 0;
    %* calculate mandatory tag ;
    if (upcase(vcore) eq "REQ" and "&defxml_defineType." eq "_SDTM_") or 
       vNotNull = "1" 
    then mandatory = "Yes";
    else mandatory = "No";
    %* select items and sort ;
    keep section dsname vname paramid vcodes_sep valItemID wcmethod mandatory vPos vRole temporder;
    proc sort; by dsname vname valItemId vcodes_sep;
run;


%*--- create value level meta data (section 3) for ~where syntax ---;  

%* select value level items ;
proc sql noprint;
    create table _defxml_sec03_valuemeta_05 (keep=paramid dsname vname vpos vcodes vrcodes vorigin vcore temporder recId vRole) as
    select distinct *
    from   _defxml_sec03_valuemeta_00 
    where  index(paramid, "&escapeChar.WHERE")
    order by dsname, temporder;
quit;

%* select substrings separated by 'AND' ;
data _defxml_sec03_valuemeta_06;
    ExpressionID = prxparse("/&defxml_escapeCharRegex.AND/");
    set _defxml_sec03_valuemeta_05;
    by paramid notsorted;
    start = 1;
    stop = length(strip(paramid));
    nosep_and = 0;
    retain last_sep;
    if first.paramid then last_sep = 3;

    call prxnext(ExpressionID, start, stop, paramid, position, length);
    if position > 0 then do;
        do while (position > 0);
            found = substr(paramid, position, length);
            substring = substr(paramid, last_sep+5, position-(last_sep+5));
            if "&gmDebug." = "1" then do;
                put "NOTE:[PXL] " found= position= length= substring=;
            end;
            output _defxml_sec03_valuemeta_06;
            last_sep = position;

            call prxnext(ExpressionID, start, stop, paramid, position, length);
            nosep_and + 1;
        end;
        substring = substr(paramid, start+1);
        output _defxml_sec03_valuemeta_06;
    end;
    else do;
        substring = substr(paramid, 8);
        output _defxml_sec03_valuemeta_06;
    end;
run;

%* further select single items from the substrings ;
data _defxml_sec03_valuemeta_07;
    length valSubItemId comparator $20 argument1 argument2 $300;
    set _defxml_sec03_valuemeta_06;
    valSubItemId = strip(scan(substring,1,"&escapeChar."));
    comparator = prxChange("s/.+&defxml_escapeCharRegex.(LT|LE|GT|GE|EQ|NE|IN|NOTIN).+/$1/", -1, trim(substring));
    argument1 = prxChange("s/.+&defxml_escapeCharRegex.(?:LT|LE|GT|GE|EQ|NE|IN|NOTIN)\s+(.+)/$1/", -1, trim(substring));
    argument1 = prxChange("s/&defxml_escapeCharRegex.,/{defxml:comma}/", -1, trim(argument1));
    if comparator in ("IN","NOTIN") then do;
        nosep_ = countc(argument1,',');
        do i = 1 to nosep_+1;
            argument2 = strip(scan(argument1,i,','));
            %* Remove quotation marks and escape char;
            argument2 = prxChange("s/(?<!&defxml_escapeCharRegex.)"||'(?:&quot;|\(|\))//',-1,trim(argument2));
            argument2 = prxChange("s/&defxml_escapeCharRegex.//",-1,trim(argument2));
            argument2 = prxChange("s/{defxml:comma}/,/", -1, trim(argument2));
            output;
        end;
    end;
    else do;
        argument2 = prxChange("s/(?<!&defxml_escapeCharRegex.)"||'&quot;//',-1,argument1);
            argument2 = prxChange("s/&defxml_escapeCharRegex.//",-1,argument2);
        output;
    end;
run;

%* select needed items (for sections 3 and 4) ;
data _defxml_sec03_valuemeta_08;
    length section $50 valItemId $100 valSubItemId $200 wcMethod 8 mandatory $3 vcodes_sep $&maxFieldLength.;
    set _defxml_sec03_valuemeta_07;
    section = "SEC03_VALUEMETA";
    valItemID = recId;
    %* calculate method tagging (all non predecessor items) ;
    if upcase(vOrigin) eq "DERIVED" then wcMethod = 1;
    else if upcase(vOrigin) eq "ASSIGNED" then wcMethod = 2;
    else if upcase(vOrigin) eq "PREDECESSOR" then wcMethod = 0;
    else wcMethod = 0;
    %* calculate mandatory tag ;
    if upcase(vcore) eq "REQ" then mandatory = "Yes";
    else mandatory = "No";
    vcodes_sep = argument2;
    %* select items and sort ;
    keep section dsname vname paramid vcodes_sep comparator valItemId valSubItemId wcMethod mandatory vPos nosep_and vRole tempOrder;
    proc sort; by dsname vname valItemId;
run;

%* join both syntax sections and create section 3 dataset ;
data _defxml_sec03_valuemeta_09;
    set _defxml_sec03_valuemeta_04
    _defxml_sec03_valuemeta_08;
    by dsname vname valItemId;
    %* for section 3 only 1 base entry per valItem is needed ;
    if first.valItemId;
    drop vcodes_sep valSubItemId paramid nosep_and comparator;

    proc sort;
        by dsName vName tempOrder valItemId;
run;

%* Add item order;
data defxml_sec03_valuemeta(drop=tempOrder);
    set _defxml_sec03_valuemeta_09;
    by dsName vName tempOrder valItemId;

    retain itemOrder;
    if first.vname then do; 
        itemOrder=1; 
    end;
    else do;
        itemOrder = itemOrder+1;
    end;
run;

%*--- prepare whereClause definitions section for value level meta section (section 4) ---;

%*--- *default* / paramid syntax ---;

%* use section 3 dataset and derive comparator information ;
proc sql noprint;
    create table _defxml_sec04_valuemeta_01 as
    select *, count(*) as nosep
    from   _defxml_sec03_valuemeta_03(where=(not missing(vcodes_sep)))
    group by dsname, vname, paramid;
quit;

proc sort data=_defxml_sec04_valuemeta_01; by dsname vname paramid vcodes_sep; run;

%* derive needed items for section 4 ;
data _defxml_sec04_valuemeta_02;
    length section $50 itemOrderCheckValue 8 valItemId $100 rangeItemId 8 comparator $20 vrcodes $200;
    set _defxml_sec04_valuemeta_01;
    section = "SEC04_VALUEMETAWHERECLAUSE";
    itemOrderCheckValue = _N_;
    %* derive comparator ;
    if nosep = 1 then comparator = "EQ";
    if nosep > 1 then comparator = "IN";
    %* set item id ;
    valItemId = recId;
    %* set rangeItemId (set to 1 for standard *default*-paramid method) ;
    rangeItemID = 1;
    %* remove codelist information from reference item ;
    vrcodes = strip(scan(vrcodes,1,','));
    keep section dsname vname itemorderCheckValue vcodes_sep valItemID rangeItemId vrcodes comparator
    paramid; 
    %*needed items for define.pdf report;     

    proc sort; by dsname vname valitemid itemOrderCheckValue;
run;

%*--- ~where syntax ---;

%* derive needed items for section 4 ;
data _defxml_sec04_valuemeta_03;
    length section $50 itemOrderCheckValue 8 valItemId $100 rangeItemId 8 comparator $20 vrcodes $200;
    set _defxml_sec03_valuemeta_08;
    section = "SEC04_VALUEMETAWHERECLAUSE";
    itemOrderCheckValue = _N_ ;
    %* set vrcodes (subValItem) ;
    if index(valSubItemId,'.') then vrcodes = valSubItemId;
    else vrcodes = strip(dsname) || "." || strip(valSubItemId);
    %* set rangeItemId (increase by 1 for each 'AND' substring per variable) ;
    rangeItemID = nosep_and + 1;
    keep section dsname vname itemOrderCheckValue vcodes_sep valItemID rangeItemId vrcodes comparator
    paramid; 
    %*needed items for define.pdf report;
proc sort; by dsname vname valItemId itemOrderCheckValue;
run;

%* put both datasets together ;
data _defxml_sec04_valuemeta_04;
    set _defxml_sec04_valuemeta_02
        _defxml_sec04_valuemeta_03;
run;

proc sort data = _defxml_sec04_valuemeta_04 out = defxml_sec04_valuemeta; 
    by dsname vname valItemId itemOrderCheckValue;
run;


%*--- prepare item definitions for value level meta section ---;

%* see section 7 below ;


%*--- prepare panelmeta section for xml source generation (section 5) ---;

data _defxml_sec05_panelmeta_00;
    length paramid $&maxFieldLength.;
    set adVar(where=(paramid in ("*ALL*")));
    temporder=_N_;
run;

%* join vlMetaType ;
proc sql noprint;
    create table _defxml_sec05_panelmeta_01 as
    select distinct x.*, y.vlMetaType
    from   _defxml_sec05_panelmeta_00(drop=paramid vcodes vrcodes vvalchk) as x
    left join
    _defxml_sec03_valuemetabase_00 as y
    on     x.dsname = y.dsname and
    x.vname = y.vname
    order by dsname, vPos;
quit;

%* Get domain data ;
data _defxml_sec05_panelmeta_02;
    set specdata;
    length domainName $40;

    %* Get domain name;
    if index(dsName,"&escapeChar.") then do;
        domainName = scan(dsName,2,"&escapeChar.");
        dsName = scan(dsName,1,"&escapeChar.");
    end;
    else do;
        domainName = dsName;
    end;
    proc sort;
        by dsName;
run;

%* Set variable order as given in specs;
data _defxml_sec05_panelmeta_03_1;
    set _defxml_sec05_panelmeta_01;
    length varOrder 8;        
    by dsname vpos;
    retain varOrder;
    if first.dsname then varOrder=1; 
    else varOrder=varOrder+1;
    proc sort; 
        by dsName vSort;
run;

%* Create keySequence variable;
data _defxml_sec05_panelmeta_03_2(drop=keySeqTemp);
    set _defxml_sec05_panelmeta_03_1;
    length  keySequence 8.;
    by dsname vSort;
    retain keySeqTemp;

    if first.dsname then do;
        keySeqTemp=0; 
    end;
    if strip(vkey) = "1" then do; 
        keySeqTemp = keySeqTemp+1; 
        keySequence = keySeqTemp; 
    end;
    proc sort;
        by dsName varOrder;
run;

%* combine domain level and variable level data ;
data _defxml_sec05_panelmeta_04;
    merge _defxml_sec05_panelmeta_02 (in=a) 
    _defxml_sec05_panelmeta_03_2 (in=b);
    by dsname;
run;

%* extract key variables (as combined string) and store in separate parameter ;
proc sql noprint;
    create table _defxml_sec05_panelmeta_05 as
    select distinct *
    from   _defxml_sec05_panelmeta_03_2(
    keep=dsname vname vkey varorder
    where=(vkey='1'))
    order by dsname, varorder;
quit;

data _defxml_sec05_panelmeta_06;
    set _defxml_sec05_panelmeta_05;
    length keyvars $400;
    by dsname;
    retain keyvars;
    if first.dsname then do;
        keyvars=vname;
    end;
    else do;
        keyvars=strip(keyvars) || " " || strip(vname);
    end;
run;

data _defxml_sec05_panelmeta_07;
    set _defxml_sec05_panelmeta_06;
    by dsname;
    if last.dsname then output;
run;

%* merge keys to other vars ;
data _defxml_sec05_panelmeta_08;
    merge _defxml_sec05_panelmeta_04 (in=a)
    _defxml_sec05_panelmeta_07 (in=b keep=dsname keyvars);
    by dsname;
run;

%* create section 5 dataset ;
data defxml_sec05_panelmeta;
    length section $50 panelOrder 8 repeating isReference $3 class purpose $100 dsstructure dsnameLabel $200 methodId dsnamexpt $50
    mandatory $3 parentLabel $40;
    set _defxml_sec05_panelmeta_08;
    section = "SEC05_PANELMETA";

    %* create dataset sorting order according to define specification ;
    select;
        %* ADaM classes ;
        when (upcase(dsclass) in ("ADSL" "SUBJECT LEVEL ANALYSIS DATASET")) do;
            panelOrder=1; class="SUBJECT LEVEL ANALYSIS DATASET";
        end;
        when (upcase(dsclass) in ("OCCDS" "OCCURENCE DATA STRUCTURE" "OCCURRENCE DATA STRUCTURE" "ADAE" "ADVERSE EVENT ANALYSIS DATASET")) do;
            panelOrder=2; class="OCCURRENCE DATA STRUCTURE";
        end;
        when (upcase(dsclass) in ("BDS" "BASIC DATA STRUCTURE")) do;
            panelOrder=3; class="BASIC DATA STRUCTURE";
        end;
        when (upcase(dsclass) in ("ADAM OTHER")) do;
            panelOrder=4; class="ADAM OTHER";
        end;
        %* sdtm classes ;
        when (upcase(dsclass) in ("TRIAL DESIGN")) do;
            panelOrder=1; class="TRIAL DESIGN";
        end;
        when (upcase(dsclass) in ("SPECIAL PURPOSE")) do;
            panelOrder=2; class="SPECIAL PURPOSE";
        end;
        when (upcase(dsclass) in ("INTERVENTIONS")) do;
            panelOrder=3; class="INTERVENTIONS";
        end;
        when (upcase(dsclass) in ("EVENTS")) do;
            panelOrder=4; class="EVENTS";
        end;
        when (upcase(dsclass) in ("FINDINGS")) do;
            panelOrder=5; class="FINDINGS";
        end;
        when (upcase(dsclass) in ("FINDINGS ABOUT")) do;
            panelOrder=6; class="FINDINGS ABOUT";
        end;
        when (upcase(dsclass) in ("RELATIONSHIP")) do;
            panelOrder=7; class="RELATIONSHIP";
        end;
        otherwise do;
            panelOrder=10;
            class=dsclass;
        end;
    end;

    %* reduce length of dsstruc ;
    dsstructure = strip(dsstruc);

    %* calculate isReference tag ;
    if upcase(dsclass) eq "TRIAL DESIGN" then isReference = "Yes";
    else isReference = "No";

    %* calculate repeating tag ;
    %* If there are at least PERs and not PER STUDY;
    if prxMatch("/(\bper\b).*\1/si",prxChange("s/\bper\s+study\b//",-1,dsStruc)) 
       and prxMatch("/subj/i",dsStruc) 
    then do;
        repeating = "Yes";
    end;
    else do;
        repeating = "No";
    end;

    %* set purpose tag ;
    %if &defxml_defineType=_ADaM_ %then %do; purpose = "Analysis"; %end;
    %else %if &defxml_defineType=_SDTM_ %then %do; purpose = "Tabulation"; %end;

    %* calculate mandatory tag ;
    if (upcase(vcore) eq "REQ" and "&defxml_defineType"="_SDTM_") 
       or strip(vnotNull) eq "1"
    then mandatory = "Yes";
    else mandatory = "No";

    %* calculate method tagging for derived items (without value level meta data assigned) ;
    if upcase(vOrigin) = "DERIVED" 
    then methodId = strip(dsname) || "." || strip(vname);

    %* for Unix systems the file names are case sensitive ;
    if "&xptNameType"="_LOWCASE_" then do; 
        dsnamexpt = strip(lowcase(dsname)) || ".xpt"; 
    end;
    if "&xptNameType"="_UPCASE_" then do; 
        dsnamexpt = strip(upcase(dsname)) || ".XPT"; 
    end;
    %* Dataset link label in the Location column;
    if not missing(dslocat) then do;
        dsnameLabel = dslocat;
    end;
    else do;
        dsnameLabel = dsnamexpt;
    end;

    * Remove line breaks where they are not expected;
    dsStructure = prxChange("s/\s+/ /",-1,trim(dsStructure));
    dsLabel = prxChange("s/\s/ /",-1,trim(dsLabel));
    dsClass = prxChange("s/\s/ /",-1,trim(dsClass));

    * Remove trailing whitespaces;
    dsDoc = prxChange("s/\s*$//",1,trim(dsDoc));

    * Label of the parent dataset in case a split is perfored;
    if index(dsLabel,"&escapeChar.") then do;
        parentLabel = strip(scan(dsLabel,2,"&escapeChar."));
        dsLabel = strip(scan(dsLabel,1,"&escapeChar."));
    end;

    keep section panelOrder repeating isReference class purpose dsStructure methodId dsnamexpt domainName
    mandatory dsname dslabel vname varOrder vlMetaType keyvars keySequence vsource dsnamelabel vRole
    dsdoc dsclass parentLabel; %*needed for define.pdf;

run;

%*--- prepare variablemeta section (section 6) ---;

%* keep one record per row ;
proc sql noprint;
    create table _defxml_sec06_varmeta_01 as
    select x.*, y.vlmetatype
    from   adVar(rename=vlength=vlength_spec) as x
    left join
    _defxml_sec03_valuemetabase_00 as y
    on     x.dsname = y.dsname and
    x.vname = y.vname
    where  paramid in ("*ALL*")
    order by dsname, vpos;
quit;

%* add order variable ;
data _defxml_sec06_varmeta_02;
    set _defxml_sec06_varmeta_01;
    length varOrder 8.;
    by dsname vpos;
    retain varOrder;
    if first.dsname then varOrder=1; else varOrder=varOrder+1;
run;

%* derive section 6 variables ;
data defxml_sec06_varmeta;
    length section $50 origin $50 vlength $20 displayFormat $20 significantDigits $20
    documentRef $50 pageRef $10 crfPageRef $100 comment $&maxFieldLength.;
    set _defxml_sec06_varmeta_02;
    section = "SEC06_VARMETA";

    if upcase(vOrigin) not in ("DERIVED","PREDECESSOR") and not missing(vSource) then do;
        comment = vSource;
        vSource = " ";
    end;
    else if index(vSource,"&escapeChar.COMMENT&escapeChar.") then do;
        comment = prxChange("s/(.*)&defxml_escapeCharRegex.COMMENT&defxml_escapeCharRegex.(.*)/$2/s",1,trim(vSource));
        vSource = prxChange("s/(.*)&defxml_escapeCharRegex.COMMENT&defxml_escapeCharRegex.(.*)/$1/s",1,trim(vSource));
    end;

    %* readout document and page reference ;
    
    if prxMatch("/&defxml_docRegex./",vsource) then do;
        documentRef = scan(vsource,2,"&escapeChar.");
        pageRef = scan(vsource,3,"&escapeChar.");
    end;
    %* remove link references ;
    vsource = scan(vsource,1,"&escapeChar.");
    %* Remove trailing whitespace chars; 
    vSource = prxChange("s/\s*$//",1,trim(vSource));
    %* readout crf page reference ;
    if index(upcase(vorigin), "CRF PAGE") then crfPageRef = translate(prxChange("s/CRF Page\w?\s//i",-1, vorigin)," ",",");

    %* calculate origin ;
    if index(upcase(vOrigin),"CRF") = 1 then origin = "CRF";
    else origin = vOrigin;

    %* length;
    if lowcase(vtype) in ("float","integer","text") then do;
        if not missing(vlength_spec) then do;
            vlength = vlength_spec;
        end;
        else do;
            if vtype in ("float") then vlength = "8";
            if vtype in ("integer") then vlength = compress(scan(vformat,1,"."),'','kd');
            if vtype in ("text") then vlength = compress(vformat,'','kd');    
        end;
    end;
    else do;
        vlength  = " ";
    end;
    %* float display format, sig digits ;
    if vtype in ("float") then do;
        if prxMatch("/&defxml_escapeCharRegex.S\d*$/",strip(vformat)) then do;
            displayFormat = prxChange("s/(.*)&defxml_escapeCharRegex.S\d*/$1/s",1,vformat);
            significantDigits = prxChange("s/.*&defxml_escapeCharRegex.S(\d*)/$1/s",1,vformat);
        end;
        else do;
            displayFormat = vformat;
            significantDigits = scan(vformat,2,".");
        end;
    end;
    if vtype in ("integer") then do;
        displayFormat = vformat;
    end;
run;


%*--- prepare item definitions for value level meta section (section 7) ---;

%* *default* / paramid syntax ;
data _defxml_sec07_valuemeta_01;
    length section $50 origin $50 vType $40 vLength $20 displayFormat $20 significantDigits $20
    valItemId $100 valItem $50 valDesc comment $&maxFieldLength. documentRef $50 pageRef $10 crfPageRef $100;
    set _defxml_sec03_valuemeta_02(where=(not missing(relcodes)) rename=(vlength=vlength_spec));
    section = "SEC07_VALUEMETAITEMDEF";
    %* Separate comments;
    if upcase(vOrigin) not in ("DERIVED","PREDECESSOR") and not missing(vSource) then do;
        comment = vSource;
        vSource = " ";
    end;
    else if index(vSource,"&escapeChar.COMMENT&escapeChar.") then do;
        comment = prxChange("s/(.*)&defxml_escapeCharRegex.COMMENT&defxml_escapeCharRegex.(.*)/$2/s",1,trim(vSource));
        vSource = prxChange("s/(.*)&defxml_escapeCharRegex.COMMENT&defxml_escapeCharRegex.(.*)/$1/s",1,trim(vSource));
    end;
    %* readout document and page reference ;
    if prxMatch("/&defxml_docRegex./",vsource) then do;
        documentRef = scan(vsource,2,"&escapeChar.");
        pageRef = scan(vsource,3,"&escapeChar.");
    end;
    %* remove link references ;
    vsource = scan(vsource,1,"&escapeChar.");
    %* Remove trailing whitespace chars; 
    vSource = prxChange("s/\s*$//",1,trim(vSource));

    %* readout crf page reference ;
    if index(upcase(vorigin), "CRF PAGE") then crfPageRef = translate(prxChange("s/CRF Page\w?\s//i",-1, vorigin)," ",",");
    %* calculate origin ;
    if index(upcase(vOrigin),"CRF") = 1 then origin = "CRF";
    else origin = vOrigin;
    %* length ;
    if lowcase(vtype) in ("float","integer","text") then do;
        if not missing(vlength_spec) then do;
            vlength = vlength_spec;
        end;
        else do;
            if vtype in ("float") then vlength = "8";
            if vtype in ("integer") then vlength = compress(scan(vformat,1,"."),'','kd');
            if vtype in ("text") then vlength = compress(vformat,'','kd');    
        end;
    end;
    else do;
        vlength  = " ";
    end;

    %* float and date display format, sig digits ;
    if vtype in ("float") then do;
        if prxMatch("/&defxml_escapeCharRegex.S\d*$/",strip(vformat)) then do;
            displayFormat = prxChange("s/(.*)&defxml_escapeCharRegex.S\d*/$1/s",1,vformat);
            significantDigits = prxChange("s/.*&defxml_escapeCharRegex.S(\d*)/$1/s",1,vformat);
        end;
        else do;
            displayFormat = vformat;
            significantDigits = scan(vformat,2,".");
        end;
    end;
    if vtype in ("integer") then do;
        displayFormat = vformat;
    end;

    %* itemID;
    if upcase(paramid) = "*DEFAULT*"
        then do;
        valItemID = recId;
        valItem = "DEFAULT";
        valDesc = relcodes;
    end;
    else do;
        valItemID = recId;
        valItem = substr(compress(paramid,' ,'),1,min(&defxml_maxLengthValItemId.,length(compress(paramid,' ,'))));
        valDesc = paramid;
    end;

    %* Relcodes dsname vname valDesc -needed items for section 11;
    %* ParamId VrCodes vFormat - needed items for define.pdf report;
    keep section origin vType vLength displayFormat significantDigits codelistId valItemId valItem documentRef
    pageRef crfPageRef vSource comment recId 
    relcodes dsname vname valDesc 
    paramid vrcodes vformat;

run;

%* ~where syntax ;
proc sql noprint;
    create table _defxml_sec07_valuemeta_02 as
    select distinct *
    from   _defxml_sec03_valuemeta_00 
    where  index(paramid, "&escapeChar.WHERE")
    order by dsname, temporder;
quit;

    %* map needed information ;
data _defxml_sec07_valuemeta_03;
    length section $50 origin $50 vType $40 vLength $20 displayFormat $20 significantDigits $20
    valItemId $100 valItem $50 documentRef $50 pageRef $10 crfPageRef $100 
    valDesc comment $&maxFieldLength.;
    set _defxml_sec07_valuemeta_02 (rename=(vlength=vlength_spec)) ;
    valOID = upcase(strip(compress(substr(paramid,8),,'ka')));
    section = "SEC07_VALUEMETAITEMDEF";
    %* Separate comments;
    if upcase(vOrigin) not in ("DERIVED","PREDECESSOR") and not missing(vSource) then do;
        comment = vSource;
        vSource = " ";
    end;
    else if index(vSource,"&escapeChar.COMMENT&escapeChar.") then do;
        comment = prxChange("s/(.*)&defxml_escapeCharRegex.COMMENT&defxml_escapeCharRegex.(.*)/$2/s",1,trim(vSource));
        vSource = prxChange("s/(.*)&defxml_escapeCharRegex.COMMENT&defxml_escapeCharRegex.(.*)/$1/s",1,trim(vSource));
    end;
    %* readout document and page reference ;
    if prxMatch("/&defxml_docRegex./",vsource) then do;
        documentRef = scan(vsource,2,"&escapeChar.");
        pageRef = scan(vsource,3,"&escapeChar.");
    end;
    %* remove link references ;
    vSource = scan(vsource,1,"&escapeChar.");
    %* Remove trailing whitespace chars; 
    vSource = prxChange("s/\s*$//",1,trim(vSource));
    %* readout crf page reference ;
    if index(upcase(vorigin), "CRF PAGE") then crfPageRef = translate(prxChange("s/CRF Page\w?\s//i",-1, vorigin)," ",",");
    %* calculate origin ;
    if index(upcase(vOrigin),"CRF") = 1 then origin = "CRF";
    else origin = vOrigin;
    %* length ;
    if not missing(vlength_spec) then do;
        vlength = vlength_spec;
    end;
    else do;
        if vtype in ("float") then vlength = "8";
        if vtype in ("integer") then vlength = compress(scan(vformat,1,"."),'','kd');
        if vtype in ("text") then vlength = compress(vformat,'','kd');    
    end; 
    %* float and date display format, sig digits ;
    if vtype in ("float") then do;
        if prxMatch("/&defxml_escapeCharRegex.S\d*$/",strip(vformat)) then do;
            displayFormat = prxChange("s/(.*)&defxml_escapeCharRegex.S\d*/$1/s",1,vformat);
            significantDigits = prxChange("s/.*&defxml_escapeCharRegex.S(\d*)/$1/s",1,vformat);
        end;
        else do;
            displayFormat = vformat;
            significantDigits = scan(vformat,2,".");
        end;
    end;
    if vtype in ("integer") then do;
        displayFormat = vformat;
    end;

    %* itemID ;
    valItemID = recId;
    valItem = substr(valOID,1,min(&defxml_maxLengthValItemId.,length(valOID)));
    %* prepare relcodes variable for later use in method definitions (section 11) ;
    valDesc = compress(paramid, "&escapeChar.");

    %* Relcodes dsname vname valDesc -needed items for section 11;
    %* ParamId VrCodes vFormat - needed items for define.pdf report;
    keep section origin vType vLength displayFormat significantDigits codelistId valItemId valItem documentRef
    pageRef crfPageRef vSource comment recId
    dsname vname valDesc
    paramid vrcodes vformat;
run;  

%* join both sections ;
data defxml_sec07_valuemeta;
    set _defxml_sec07_valuemeta_01
    _defxml_sec07_valuemeta_03;
run;

%*--- prepare codelist section (section 8/9) ---;

%* Load main codelists;
data _defxml_sec08_codelist1_01a(drop = code decode);
    set codelist(rename = (label=codelistName));

    %* Add leading non-space character to keep leading spaces in define.xml;
    if not missing(code) then do;
        codes = '"'||code;
    end;
    if not missing(decode) then do;        
        decodes = '>'||decode;
    end;
run;

%* Add section and item order;
data _defxml_sec08_codelist1_01b;
    set _defxml_sec08_codelist1_01a;

    lagCodelistId = lag(codelistId);
    drop lagCodelistId;

    retain itemOrder;

    if lagCodelistId ne codelistId then do;
        itemOrder = 1;
    end;
    else do;
        itemOrder = itemOrder + 1;
    end;

    if missing(codelistName) then do;
        codelistName = codelistID;
    end;
    %* Derive extended flag ;
    length extendedValue $3;
    if not missing(listCode) and missing(valueCode) then do;
        extendedValue = "Yes";
    end;
run;

proc sql;
%* Add section;
create table _defxml_sec08_codelist1_01ba as
    select distinct codelistId, "SEC09_CODELISTS" as section length = 50
    from _defxml_sec08_codelist1_01b
    where not missing(codes) and not missing(decodes)
;
create table _defxml_sec08_codelist1_01bb as
    select distinct codelistId, "SEC08_CODELISTS" as section length = 50
    from _defxml_sec08_codelist1_01b
    where not missing(codes) 
          and 
          codelistId not in (select codelistId 
                             from _defxml_sec08_codelist1_01ba
                            )
;
%* United into one;
create table _defxml_sec08_codelist1_01bc as
    select * from _defxml_sec08_codelist1_01ba
    outer union corr
    select * from _defxml_sec08_codelist1_01bb
;
%* Merge to the main dataset;
create table _defxml_sec08_codelist1_01bd as
    select distinct a.*, b.section
    from _defxml_sec08_codelist1_01b as a
         left join  
         _defxml_sec08_codelist1_01bc as b
         on a.codelistId = b.codelistId
;

%* Add vtype;
create table _defxml_sec08_codelist1_01c as
    select distinct a.*, b.vtype
    from _defxml_sec08_codelist1_01bd as a
         left join adVar as b
         on a.codelistId = b.codelistId
;
quit;

%* Prepare external codelits;
data _defxml_sec08_codelist1_02a;
    set adVar (where = (vCodes eq: "&escapeChar.EXTERNAL"));
    * Keep only codelist name;
    if missing(codelistId) then do;
        codelistId = prxChange("s/^\w+\.\w+|\(|\)|,|\s//",-1,vrCodes);
    end;
run;

%* Keep only unique records;
proc sort data=_defxml_sec08_codelist1_02a out=_defxml_sec08_codelist1_02b nodupkey;
    by vCodes codelistId;
run;

%* Parse attributes;
data _defxml_sec08_codelist1_02c(keep = ext: section codelistId vtype);
    set _defxml_sec08_codelist1_02b;
    length extName section $50  extVer extRef extHref $200 extAttr $600;

    section = "SEC09B_EXTERNALCODELISTS";
    extName = prxChange("s/&escapeChar.EXTERNAL:(.*?)(?:&escapeChar.VER|&escapeChar.HREF|&escapeChar.REF|$).*$/$1/i",1,strip(vCodes));
    extVer  = prxChange("s/.*&escapeChar.VER:(.*?)(?:&escapeChar.HREF|&escapeChar.REF|$).*$/$1/i",1,strip(vCodes));
    extAttr = 'Dictionary="' || STRIP(extName) || '" Version="' || STRIP(extVer)||'"';
    if prxMatch("/&escapeChar.REF:/i",vCodes) then do;
        extRef  = prxChange("s/.*&escapeChar.REF:(.*?)(?:&escapeChar.HREF|&escapeChar.VER|$).*$/$1/i",1,strip(vCodes));
        extAttr = strip(extAttr) || ' Ref="' || STRIP(extRef) || '"' ;
    end;
    if prxMatch("/&escapeChar.HREF:/i",vCodes) then do;
        extHref  = prxChange("s/.*&escapeChar.HREF:(.*?)(?:&escapeChar.REF|&escapeChar.VER|$).*$/$1/i",1,strip(vCodes));
        extAttr = strip(extAttr) || ' Href="' || STRIP(extHRef) || '"' ;
    end;
run;

%* Unite external and main codelists;
data defxml_sec08_codelists(drop = extensibleFlag);
    set _defxml_sec08_codelist1_01c
        _defxml_sec08_codelist1_02c
    ;

    if section = "SEC09B_EXTERNALCODELISTS" then do;
        codelistName = codelistId;
    end;
    %* Updated missing decodes from the codelists with decodes;
    if section = "SEC09_CODELISTS" and missing(decodes) then do;
        decodes = ">";
    end;
run;    


%*--- prepare method definitions for variable meta (section 10) ---;

%* 13MAR2014 - do not create method definition for value level variables ;
data defxml_sec10_varmetamethods;
    length section $50 methodId $50 documentRef $50 pageRef $10;
    set defxml_sec05_panelmeta(where=(not missing(methodId) %*and valueLevelFl ne 1;));
    section = "SEC10_VARMETAMETHOD";
    if prxMatch("/&defxml_docRegex./",vsource) then do;
        %* readout document and page reference ;
        documentRef = scan(vsource,2,"&escapeChar.");
        pageRef = scan(vsource,3,"&escapeChar.");
    end;
    %* remove link references ;
    vsource = scan(vsource,1,"&escapeChar.");
    %* Remove trailing whitespace chars; 
    vSource = prxChange("s/\s*$//",1,trim(vSource));
    keep section dsname vname varorder methodId vsource documentRef pageRef;
run;


%*--- prepare method definitions for value level meta section (section 11) ---;

%* Keep only derived variables in this section ;
data defxml_sec11_valuemetamethods;
    length section $50 valItemId $100 valItem $50 documentRef $50 pageRef $10 valDesc $&maxFieldLength.;
    set defxml_sec07_valuemeta(where=(upcase(origin) = "DERIVED"));
    section = "SEC11_VALUEMETAMETHOD";

    %* In the "Algorithm for" line add spaces to improve readability ;
    valDesc = prxChange("s/\b,\b/, /",-1,valDesc);

    keep section dsname vname %*varorder; valItemId vsource documentRef pageRef relcodes valDesc;
run;


%*--- prepare comment definitions section ---;

%* compile dataset level comments ;
proc sort data=_defxml_sec05_panelmeta_02 out=_defxml_sec12_commentdefds_01;
    by dsname;
run;

data _defxml_sec12_commentdefds_02;
    length documentRef $50 pageRef $10 comment $&maxFieldLength commentId $100;
    set _defxml_sec12_commentdefds_01(keep=dsname dsdoc where = (not missing(dsDoc)));
    %* readout document and page reference ;
    commentId = dsName;
    if prxMatch("/&defxml_docRegex./",dsdoc) then do;
        documentRef = scan(dsdoc,2,"&escapeChar.");
        pageRef = scan(dsdoc,3,"&escapeChar.");
    end;
    %* remove link references from comment ;
    comment = scan(dsdoc,1,"&escapeChar.");
    %* Remove trailing whitespace chars; 
    comment = prxChange("s/\s*$//",1,trim(comment));
    %* show dataset comment before variable comments ;
    varOrder = 1;
run;

%* compile variable level comments ;
data _defxml_sec12_commentdefvar_01;
    length commentId $100 documentRef $50 pageRef $10;
    set defxml_sec06_varmeta(where=(not missing(comment)) drop = vtype);
    %* Get document reference;
    if prxMatch("/&defxml_docRegex./",comment) then do;
        documentRef = scan(comment,2,"&escapeChar.");
        pageRef = scan(comment,3,"&escapeChar.");
        comment = scan(comment,1,"&escapeChar.");
        %* Remove trailing whitespace chars; 
        comment = prxChange("s/\s*$//",1,trim(comment));
    end;
    else do;
        documentRef = "";
        pageRef = "";
        %* Remove trailing whitespace chars; 
        comment = prxChange("s/\s*$//",1,trim(comment));
    end;
    %* if there is no comment and no reference given for the predecessor item, then remove entry from comment section ;
    if missing(strip(comment)) and missing(documentRef) then delete; 

    %* itemID ;
    commentId = recId;
    varOrder = 2;
run;

%* compile value level comments ;
data _defxml_sec12_commentdefvalue_01;
    length commentId $100 documentRef $50 pageRef $10 valOID $200;
    set defxml_sec07_valuemeta(where=(not missing(comment)) drop = vtype);
    %* create temporary valueID ;
    valOID = upcase(strip(compress(substr(paramid,8),,'ka')));
    %* Get document reference;
    if prxMatch("/&defxml_docRegex./",comment) then do;
        documentRef = scan(comment,2,"&escapeChar.");
        pageRef = scan(comment,3,"&escapeChar.");
        comment = scan(comment,1,"&escapeChar.");
        %* Remove trailing whitespace chars; 
        comment = prxChange("s/\s*$//",1,trim(comment));
    end;
    else do;
        documentRef = "";
        pageRef = "";
        %* Remove trailing whitespace chars; 
        comment = prxChange("s/\s*$//",1,trim(comment));
    end;
    %* itemID ;
    commentId = recId;
    varOrder = 3;
run;

%* merge all comments data ;
data defxml_sec12_commentdef (keep=section commentId comment documentRef pageRef varOrder);
    set _defxml_sec12_commentdefds_02 
    _defxml_sec12_commentdefvar_01 
    _defxml_sec12_commentdefvalue_01;
    length section $50;
    section = "SEC12_COMMENT";
run;


%*--- prepare document close section ---;

data Defxml_sec99_close;
    format section $50.;
    section   = 'SEC99_CLOSE';
    output;
run;


%*--- compile overall metapanel (may last some minutes) ---;

%put NOTE:[PXL] Preparing summary dataset ... ;
proc sql noprint;
    create table Defxml_meta_summary( where=(not missing(section)) encoding=UTF8 ) as
    (
    select * from   defxml_sec01_headmeta

    %if &defxml_documentsFl %then %do;
        outer union corr
        select * from   defxml_sec02_docdef
    %end;

    outer union corr
    select * from   defxml_sec03_valuemeta

    outer union corr
    select * from   defxml_sec04_valuemeta

    outer union corr
    select * from   defxml_sec05_panelmeta

    outer union corr
    select * from   defxml_sec06_varmeta

    outer union corr
    select * from   defxml_sec07_valuemeta

    outer union corr
    select * from   defxml_sec08_codelists

    outer union corr
    select * from   defxml_sec10_varmetamethods

    outer union corr
    select * from   defxml_sec11_valuemetamethods

    outer union corr
    select * from   defxml_sec12_commentdef

    %if &defxml_documentsFl. %then %do;
        outer union corr
        select * from   defxml_sec20_docref
    %end;

    outer union corr
    select * from   defxml_sec99_close
    )
    order by section, panelOrder, dsname, varOrder, codelistId,
    vname, itemOrder, valItemId, rangeItemId, itemOrderCheckValue, commentId, codes
    ;
quit;

%*-----------------------------------------------------------------------------------------------
Create define.xml document 
-------------------------------------------------------------------------------------------------;

%* Get the user name;
%let defxml_userName = %bQuote(%gmGetUserName());


options nodate nonumber nocenter pagesize=max ;
%* reset titles/footnotes ;
title;
footnote;

filename outfile "&pathOut./define.xml" encoding="UTF-8";

%gmMessage(linesOut=Writing Define.xml ...); 

data _NULL_;
    file outfile dlm='' lrecl=32000;
    set Defxml_meta_summary;
    actdate = put(today(), yymmdd10.);
    actdatetime = strip(put(datetime(), is8601dt.));
    by section panelOrder dsname varOrder codelistId vname itemOrder valItemId rangeItemId;


    %* SECTION 1 ;
    if section='SEC01_GLOBAL' then do;
        put
        %* For unknown reason sas is not able to produce UTF8 text files
        as long as this is not solved we need to encode as ISO-8859-1 or WINDOWS-1251;
        '<?xml version="1.0" encoding="UTF-8"?>'/ 
        %*'<?xml version="1.0" encoding="ISO-8859-1"?>';
        %if "&pathXslIn" ne "" %then %do; 
            '<?xml-stylesheet type="text/xsl" href="' "&pathXslIn." 'define2-0-0.xsl"?>'/
        %end;
        %else %do;
            '<?xml-stylesheet type="text/xsl" href="define2-0-0.xsl"?>'/
        %end;
        /
        '<!-- ********************************************************************************* -->'/
        '<!-- File: define.xml                                                                  -->'/
        '<!-- Date: ' actdate '                                                                 -->'/
        %if %length(&defxml_userName.) < 51 %then %do;
            '<!-- Author: PAREXEL, generated by ' "&defxml_userName." +(51-%length(&defxml_userName.)) ' -->'/
        %end;
        %else %do;
            '<!-- Author: PAREXEL, generated by ' "&defxml_userName." ' -->'/
        %end;
        '<!-- Description: This is the define.xml document for the study                        -->'/
        %if %length("&defxml_protocolName.") < 82 %then %do;
            '<!--   ' "&defxml_protocolName." +(82-%length("&defxml_protocolName.")) '-->'/
        %end;
        %else %do;
            '<!--   ' "&defxml_protocolName." '-->'/
        %end;
        '<!-- ********************************************************************************* -->'/
        /
        '<ODM xmlns="http://www.cdisc.org/ns/odm/v1.3"'/
        ' xmlns:xlink="http://www.w3.org/1999/xlink"'/
        ' xmlns:def="http://www.cdisc.org/ns/def/v2.0"'/
        ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"'/
        %* 20MAR2014 Commented as the links does not work, this attribute is optional ;
        %*  ' xsi:schemaLocation="http://www.cdisc.org/ns/def/v2.0 schema/cdisc-define-2.0/define2-0-0.xsd"'/ ;

        ' FileType="Snapshot"'/
        ' FileOID="FL.' studyId +(-1) '"'/
        ' ODMVersion="1.3.2" '/
        ' CreationDateTime="' actdatetime +(-1) '"'/
        ' Originator="' sponsorName +(-1) '">'/
        /
        ' <!-- ****************************************** -->'/
        ' <!-- OID conventions used in this file:         -->'/
        ' <!--    FileID                  = FL.           -->'/
        ' <!--    Study                   = ST.           -->'/
        ' <!--    MetaDataVersion         = MDV.          -->'/
        ' <!--    def:leaf, leafID        = LF.           -->'/
        ' <!--    def:ValueListDef        = VL.           -->'/
        ' <!--    def:WhereClauseDef      = WC.           -->'/
        ' <!--    ItemGroupDef            = IG.           -->'/
        ' <!--    ItemDef                 = IT.           -->'/
        ' <!--    CodeList                = CL.           -->'/
        ' <!--    MethodDef               = MT.           -->'/
        ' <!--    def:CommentDef          = COM.          -->'/
        ' <!-- ****************************************** -->'/
        /
        ' <Study OID="ST.' studyId +(-1) '">'/
        '  <GlobalVariables>'/
        '   <StudyName>' studyName +(-1) '</StudyName>'/
        '   <StudyDescription>' studyDesc +(-1) '</StudyDescription>'/
        '   <ProtocolName>' protocolName +(-1) '</ProtocolName>'/
        '  </GlobalVariables>'/
        /
        %if &defxml_defineType=_ADaM_ %then %do;
            '  <MetaDataVersion OID="MDV.CDISC01.ADaMIG.' cdiscIgVer +(-1) '.ADaM.' cdiscVer +(-1) '"'/
            '   Name="Study ' studyname +(-1) ', ADaM Data Definitions"'/
            '   def:DefineVersion="2.0.0"'/
            '   def:StandardName="ADaM-IG"'/
            "   def:StandardVersion=""" cdiscIgVer +(-1) """>";
        %end;
        %if &defxml_defineType=_SDTM_ %then %do;
            '  <MetaDataVersion OID="MDV.CDISC01.SDTMIG.' cdiscIgVer +(-1) '.SDTM.' cdiscVer +(-1) '"'/
            '   Name="Study ' studyname +(-1) ', SDTM Data Definitions"'/
            '   def:DefineVersion="2.0.0"'/
            '   def:StandardName="SDTM-IG"'/
            "   def:StandardVersion=""" cdiscIgVer +(-1) """>";
        %end;

    end;


    %* SECTION 2 ;
    %if &defxml_documentsFl. %then %do;
        if section='SEC02_DOCDEF' then do;
            if first.section then do;
                put
                /
                '   <!-- ******************************** -->'/
                '   <!-- Supporting Documents Section [2] -->'/
                '   <!-- ******************************** -->'/;
            end;
            if defId = "CRF" then do;
                put
                '   <def:AnnotatedCRF>'/
                '    <def:DocumentRef leafID="LF.' defId +(-1) '"/>'/
                '   </def:AnnotatedCRF>'/;
            end;
            else do;
                if suppDocStart then do;
                    put '   <def:SupplementalDoc>';
                end;
                put '    <def:DocumentRef leafID="LF.' defId +(-1) '"/>';
                if suppDocEnd then do;
                    put '   </def:SupplementalDoc>'/;
                end;
            end;
        end;
    %end;


    %* SECTION 3 ;
    if section='SEC03_VALUEMETA' then do;
        if first.vname then do;
            put
            /
            '   <!-- ********************************************************************************************* -->'/
            '   <!-- Value list Definitions Section [3] for ' dsname +(-1) '.' vname                         @103 '-->'/
            '   <!-- ********************************************************************************************* -->'/
            /
            '   <def:ValueListDef OID="VL.' dsname +(-1) '.' vname +(-1) '">';
        end;

        put
        '    <ItemRef ItemOID="IT.' valItemId +(-1) '"'/
        '     OrderNumber="' itemOrder +(-1) '"'/
        '     Mandatory="' mandatory +(-1) '"';
        if wcmethod = 1 then do;
            put
            '     MethodOID="MT.' valItemId +(-1) '"';
        end;
        if not missing(vRole) then do;
            put
            '     Role="' vRole +(-1) '"';
            ;
        end;
        put
        '    >'/
        '     <def:WhereClauseRef WhereClauseOID="WC.' valItemId +(-1) '"/>'/
        '    </ItemRef>'/;

        if last.vname then do;
            put
            '   </def:ValueListDef>';
        end;
    end;


    %* SECTION 4 ;
    if section='SEC04_VALUEMETAWHERECLAUSE' then do;
        if first.section then do;
            put
            /
            '   <!-- ********************************************************************************************* -->'/
            '   <!-- WhereClause Definitions Section [4] (Used/Referenced in Value List Definitions)               -->'/
            '   <!-- ********************************************************************************************* -->'/;
        end;

        if first.valItemId then do;
            put
            '   <def:WhereClauseDef OID="WC.' valItemId +(-1) '">';
        end;

        if first.rangeItemId then do;
            put
            '    <RangeCheck SoftHard="Soft" def:ItemOID="IT.' vrcodes +(-1) '" Comparator="' comparator +(-1) '">';
        end;

        put
        '     <CheckValue>' vcodes_sep +(-1) '</CheckValue>';

        if last.rangeItemId then do;
            put
            '    </RangeCheck>';
        end;

        if last.valItemId then do;
            put
            '   </def:WhereClauseDef>'/;
        end;
    end;


    %* SECTION 5 ;
    if section='SEC05_PANELMETA' then do;

        if first.dsname then do;
            put
            /
            '   <!-- ************************************************************************************************************************ -->'/
            '   <!-- ItemGroupDef Definitions Section [5] for ' dsname +(-1) ' (Datasets and first set of variable properties)' @130 '-->'/
            '   <!-- ************************************************************************************************************************ -->'/
            /
            '   <ItemGroupDef OID="IG.' dsname +(-1) '"'/
            '    Name="' dsname +(-1) '"'/
            %if &defxml_defineType=_SDTM_ %then %do;
            '    Domain="' domainName +(-1) '"'/
            %end;
            '    SASDatasetName="' dsname +(-1) '"'/
            '    Repeating="' repeating +(-1) '"'/
            '    IsReferenceData="' isReference +(-1) '"'/
            '    Purpose="' purpose +(-1) '"'/
            '    def:Structure="' dsstructure +(-1) '"'/
            '    def:Class="' class +(-1) '"';
            if not missing(dsDoc) then do;
                put
                '    def:ArchiveLocationID="LF.DS.' dsname +(-1) '"'/
                '    def:CommentOID="COM.' dsname +(-1) '">';
            end;
            else do;
                put
                '    def:ArchiveLocationID="LF.DS.' dsname +(-1) '">';
            end;
            put
            '    <Description>'/
            '     <TranslatedText xml:lang="en">' dslabel +(-1) '</TranslatedText>'/
            '    </Description>'/
            /
            '    <!-- *************************************************************** -->'/
            '    <!-- Variables for the ItemGroupDef ' dsname +(-1)             @74 '-->'/
            '    <!-- *************************************************************** -->'
            /;
        end;

        put
        '    <ItemRef ItemOID="IT.' dsname +(-1) '.' vname +(-1) '"'/
        '     OrderNumber="' varOrder +(-1) '" Mandatory="' mandatory +(-1) '"';
        if not missing(methodId) then do;
            put
            '     MethodOID="MT.' methodId +(-1) '"';
        end;
        if not missing(vRole) then do;
            put
            '     Role="' vRole +(-1) '"';
            ;
        end;
        if not missing(keySequence) then do;
            put
            '     KeySequence="' keySequence +(-1) '"';
        end;
        put
        '    />';

        if last.dsname then do;
            if not missing(parentLabel) and "&defxml_defineType." = "_SDTM_" then do;
                put '    <Alias Context="DomainDescription" Name="' parentLabel +(-1) '"/> ';
            end;
            put
            /
            '    <!-- ********************************************************************************** -->'/
            '    <!-- def:leaf details for hypertext linking the dataset ' dsname +(-1) @93 '-->'/
            '    <!-- ********************************************************************************** -->'/
            /
            '    <def:leaf ID="LF.DS.' dsname +(-1) """ xlink:href=""&pathXptIn." dsnamexpt +(-1) '">'/
            '     <def:title>' dsnameLabel +(-1) '</def:title>'/
            '    </def:leaf>'/
            '   </ItemGroupDef>';
        end;
    end;


    %* SECTION 6 ;
    if section='SEC06_VARMETA' then do;
        if first.dsname then do;
            put
            /
            '   <!-- ******************************************************************************** -->'/
            '   <!-- ItemDef Section [6] Details of each variable for domain ' dsname            @90 '-->'/
            '   <!-- ******************************************************************************** -->'
            /;
        end;

        put
        '   <ItemDef OID="IT.' dsname +(-1) '.' vname +(-1) '"'/
        '    Name="' vname +(-1) '"'/
        '    DataType="' vtype +(-1) '"';
        if not missing(vLength) then do;
            put '    Length="' vlength +(-1) '"';
        end;
        put
        '    SASFieldName="' vname +(-1) '"';

        if not missing(displayFormat) then do;
            put
            '    def:DisplayFormat="' displayFormat +(-1) '"';
        end;
        if not missing(significantDigits) then do;
            put
            '    SignificantDigits="' significantDigits +(-1) '"';
        end;

        %* The Derived items for variable meta are storde in CompMethod section and 
        Predecessor is also automatically printed without a comment entry (only for var meta);
        if not missing(comment) then do;
            put
            '    def:CommentOID="COM.' dsname +(-1) '.' vname +(-1) '"';
        end;

        put
        '    >';

        put
        '    <Description>'/
        '     <TranslatedText xml:lang="en">' vlabel +(-1) '</TranslatedText>'/
        '    </Description>';

        if not missing(codelistId) then do;
            put
            '    <CodeListRef CodeListOID="CL.' codelistId +(-1) '"/>';
        end;

        if upcase(origin) = "PREDECESSOR" then do;
            put
            '    <def:Origin Type="' origin +(-1) '">'/
            '     <Description>'/
            '      <TranslatedText xml:lang="en">' vSource +(-1) '</TranslatedText>'/
            '     </Description>'/
            '    </def:Origin>';
        end;
        else if upcase(origin) = "CRF" and not missing(crfPageRef) then do;
            put
            '    <def:Origin Type="' origin +(-1) '">'/
            '     <def:DocumentRef leafID="LF.CRF">'/
            '      <def:PDFPageRef PageRefs="' crfPageRef +(-1) '" Type="PhysicalRef"/>'/
            '     </def:DocumentRef>'/
            '    </def:Origin>';
        end;
        else if not missing(origin) then do;
            put
            '    <def:Origin Type="' origin +(-1) '"/>';
        end;

        if vlMetaType NE . then do;
            put
            '    <def:ValueListRef ValueListOID="VL.' dsname +(-1) '.' vname +(-1) '"/>';
        end;

        put
        '   </ItemDef>'/;
    end;


    %* SECTION 7 ;
    if section='SEC07_VALUEMETAITEMDEF' then do;
        if first.section then do;
            put
            /
            '   <!-- ******************************************************************************** -->'/
            '   <!-- ItemDef Section [7] Value level meta definitions                                 -->'/
            '   <!-- ******************************************************************************** -->'
            /;
        end;

        put
        '   <ItemDef OID="IT.' valItemID +(-1) '"'/
        '    Name="' valItem +(-1) '"'/
        '    DataType="' vtype +(-1) '"';
        if not missing(vLength) then do;
            put '    Length="' vlength +(-1) '"';
        end;
        put
        '    SASFieldName="' vname +(-1) '"';

        if not missing(displayFormat) then do;
            put
            '    def:DisplayFormat="' displayFormat +(-1) '"';
        end;
        if not missing(significantDigits) then do;
            put
            '    SignificantDigits="' significantDigits +(-1) '"';
        end;

        %* Predecessor needs to go to comments section (for VL Meta) as the stylesheet does not print it otherwise 
        Derived items will be stored in CompMethod section, otherwise will be displayed twice;
        if not missing(comment) then do;
            put
            '    def:CommentOID="COM.' valItemID +(-1) '"';
        end;

        put
        '    >';

        %* does not seem to have an effect, the description need to be stored in the commentDef;
        %* put
        '    <Description>'/
        '     <TranslatedText xml:lang="en">' vlabel +(-1) '</TranslatedText>'/
        '    </Description>';

        if not missing(codelistId) then do;
            put
            '    <CodeListRef CodeListOID="CL.' codelistId +(-1) '"/>';
        end;

        if upcase(origin) = "PREDECESSOR" then do;
            put
            '    <def:Origin Type="' origin +(-1) '">'/
            '     <Description>'/
            '      <TranslatedText xml:lang="en">' vsource +(-1) '</TranslatedText>'/
            '     </Description>'/
            '    </def:Origin>';
        end;
        else if origin = "CRF" and not missing(crfPageRef) then do;
            put
            '    <def:Origin Type="' origin +(-1) '">'/
            '     <def:DocumentRef leafID="LF.CRF">'/
            '      <def:PDFPageRef PageRefs="' crfPageRef +(-1) '" Type="PhysicalRef"/>'/
            '     </def:DocumentRef>'/
            '    </def:Origin>';
        end;
        else if not missing(origin) then do;
            put
            '    <def:Origin Type="' origin +(-1) '"/>';
        end;

        put
        '   </ItemDef>'/;
    end;


    %* SECTION 8 ;
    if section='SEC08_CODELISTS' then do;
        if first.section then do;
            put
            /
            '   <!-- ************************************************************ -->'/
            '   <!-- Codelist section [8]                                         -->'/
            '   <!-- ************************************************************ -->'/;
        end;

        if first.codelistId then do;
            put
            '   <CodeList OID="CL.' codelistid +(-1) '" Name="' codelistName +(-1) '" DataType="' vtype +(-1) '">';
        end;
        if missing(strip(valueCode) || strip(extendedValue)) then do;
            put
            '    <EnumeratedItem CodedValue=' codes +(-1) '" OrderNumber="' itemOrder +(-1) '"/>';
            if last.codelistId then do;
                put
                '   </CodeList>';
            end;
        end;
        else do;
            if not missing(valueCode) then do;
                put
                '    <EnumeratedItem CodedValue=' codes +(-1) '" OrderNumber="' itemOrder +(-1) '">' /
                '     <Alias Name="' valueCode +(-1) '" Context="nci:ExtCodeID"/>' /
                '    </EnumeratedItem>';
            end;
            else if extendedValue = "Yes" then do;
                put
                '    <EnumeratedItem CodedValue=' codes +(-1) '" OrderNumber="' itemOrder +(-1) '" def:ExtendedValue="Yes"/>';
            end;

            if last.codelistId then do;
                put
                '    <Alias Name="' listCode +(-1) '" Context="nci:ExtCodeID"/>' /
                '   </CodeList>'/;
            end;
        end;
    end;


    %* SECTION 9 ;
    if section='SEC09_CODELISTS' then do;
        if first.section then do;
            put
            /
            '   <!-- ************************************************************ -->'/
            '   <!-- The Codelists (with codes/decodes) [9] are starting here     -->'/
            '   <!-- ************************************************************ -->'/;
        end;

        if first.codelistId then do;
            put
            '   <CodeList OID="CL.' codelistid +(-1) '" Name="' codelistName +(-1) '" DataType="' vtype +(-1) '">';
        end;

        if missing(strip(valueCode)||strip(extendedValue)) then do;
            put
            '    <CodeListItem CodedValue=' codes +(-1) '" OrderNumber="' itemOrder +(-1) '">'/
            '     <Decode>'/
            '      <TranslatedText xml:lang="en"' decodes +(-1) '</TranslatedText>'/
            '     </Decode>'/
            '    </CodeListItem>';

            if last.codelistId then do;
                put
                '   </CodeList>'/;
            end;
        end;
        else do;
            if not missing(valueCode) then do;
                put
                '    <CodeListItem CodedValue=' codes +(-1) '" OrderNumber="' itemOrder +(-1) '">'/
                '     <Decode>'/
                '      <TranslatedText xml:lang="en"' decodes +(-1) '</TranslatedText>'/
                '     </Decode>'/
                '     <Alias Name="' valueCode +(-1) '" Context="nci:ExtCodeID"/>' /
                '    </CodeListItem>';
            end;
            else if extendedValue = "Yes" then do;
                put
                '    <CodeListItem CodedValue=' codes +(-1) '" OrderNumber="' itemOrder +(-1) '" def:ExtendedValue="Yes">'/
                '     <Decode>'/
                '      <TranslatedText xml:lang="en"' decodes +(-1) '</TranslatedText>'/
                '     </Decode>'/
                '    </CodeListItem>';
            end;

            if last.codelistId then do;
                put
                '    <Alias Name="' listCode +(-1) '" Context="nci:ExtCodeID"/>' /
                '   </CodeList>'/;
            end;
        end;
    end;


    %* SECTION 9B (external codelist section) ;
    if section='SEC09B_EXTERNALCODELISTS' then do;
        if first.section then do;
            put
            /
            '   <!-- ************************************************************ -->'/
            '   <!-- External codelist section [9B]                               -->'/
            '   <!-- ************************************************************ -->'/;
        end;

        put
        '   <CodeList OID="CL.' codelistid +(-1) '" Name="' codelistName +(-1) '" DataType="' vtype +(-1) '">';
        put
        '    <ExternalCodeList ' extAttr +(-1)'/>';
        put
        '   </CodeList>'/;
    end;


    %* SECTION 10 ;
    if section='SEC10_VARMETAMETHOD' then do;
        if first.section then do;
            put
            /
            '   <!-- ************************************************************ -->'/
            '   <!-- Variable Methods Section [10]                                -->'/
            '   <!-- ************************************************************ -->'/;
        end;
        put
        '   <MethodDef Type="Computation" OID="MT.' methodId +(-1) '"'/
        '    Name="Algorithm for ' methodId +(-1) '">'/
        '    <Description>'/
        '     <TranslatedText xml:lang="en">' vsource +(-1) '</TranslatedText>'/
        '    </Description>';
        if not missing(documentRef) and not missing(pageRef) then do;
            put
            '    <def:DocumentRef leafID="LF.' documentRef +(-1) '">'/
            '     <def:PDFPageRef PageRefs="' pageRef +(-1) '" Type="PhysicalRef"/>'/
            '    </def:DocumentRef>';
        end;
        if not missing(documentRef) and missing(pageRef) then do;
            put
            '    <def:DocumentRef leafID="LF.' documentRef +(-1) '"/>';
        end;
        put
        '   </MethodDef>'/;
    end;


    %* SECTION 11 ;
    if section='SEC11_VALUEMETAMETHOD' then do;
        if first.section then do;
            put
            /
            '   <!-- ************************************************************ -->'/
            '   <!-- Valuemeta Methods Section [11]                               -->'/
            '   <!-- ************************************************************ -->'/;
        end;
        put
        '   <MethodDef Type="Computation" OID="MT.' valItemID +(-1) '"'/
        '    Name="Algorithm for ' dsname +(-1) '.' vname +(-1) ' (' valDesc +(-1) ')">'/
        '    <Description>'/
        '     <TranslatedText xml:lang="en">' vsource +(-1) '</TranslatedText>'/
        '    </Description>';
        if not missing(documentRef) and not missing(pageRef) then do;
            put
            '    <def:DocumentRef leafID="LF.' documentRef +(-1) '">'/
            '     <def:PDFPageRef PageRefs="' pageRef +(-1) '" Type="PhysicalRef"/>'/
            '    </def:DocumentRef>';
        end;
        if not missing(documentRef) and missing(pageRef) then do;
            put
            '    <def:DocumentRef leafID="LF.' documentRef +(-1) '"/>';
        end;
        put
        '   </MethodDef>'/;
    end;


    %* SECTION 12 ;
    if section='SEC12_COMMENT' then do;
        if first.section then do;
            put
            /
            '   <!-- ************************************************************ -->'/
            '   <!-- Comments definition section [12]                             -->'/
            '   <!-- ************************************************************ -->'/;
        end;

        put
        '   <def:CommentDef OID="COM.' commentId +(-1) '">'/
        '    <Description>'/
        '     <TranslatedText xml:lang="en">' comment +(-1) '</TranslatedText>'/
        '    </Description>';
        if not missing(documentRef) and not missing(pageRef) then do;
            put
            '    <def:DocumentRef leafID="LF.' documentRef +(-1) '">'/
            '     <def:PDFPageRef PageRefs="' pageRef +(-1) '" Type="PhysicalRef"/>'/
            '    </def:DocumentRef>';
        end;
        if not missing(documentRef) and missing(pageRef) then do;
            put
            '    <def:DocumentRef leafID="LF.' documentRef +(-1) '"/>';
        end;
        put
        '   </def:CommentDef>'/;
    end;



    %* placeholder ;



    %* SECTION 20 ;
    %if &defxml_documentsFl. %then %do;
        if section='SEC20_DOCREF' then do;
            if first.section then do;
                put
                /
                '   <!-- *********************************************** -->'/
                '   <!-- Documents Reference section                     -->'/
                '   <!-- *********************************************** -->'/;
            end;
            put
            '   <def:leaf ID="LF.' defId +(-1) '" xlink:href="' defHref +(-1) '">'/
            '    <def:title>' defTitle +(-1) '</def:title>'/
            '   </def:leaf>';
        end;
    %end;


    %* SECTION 99 ;
    if section='SEC99_CLOSE' then do;
        put
        /
        '   <!-- *********************************** -->'/
        '   <!-- End of metadata definitions section -->'/
        '   <!-- *********************************** -->'/
        /
        '  </MetaDataVersion>'/
        ' </Study>'/
        '</ODM>';
    end;

run;


%*-----------------------------------------------------------------------------------------------;

%*--- create define.pdf document ---;

%if &createDefinePdf. eq 1 %then %do;
    %gmMessage(linesOut=Create PDF file functionality experimental and not yet validated.);

    %_gmDefinePdfReport
    (
         definePdfLocation =&pathOut.
        ,pathXptIn         =&pathXptIn.
    )

%end;

%* Restore options;
%* Drop two options which do not need to be reset - SAS changes them during OPTLOAD;
data &defxml_libName..options;
    set &defxml_libName..options(where = (optName not in ("SET","CMPOPT")));
run;

proc optload data=&defxml_libName..options;
run;

%gmMessage(linesOut=-----------------------------------------------);
%if &syserr. = 0 and &gmpxlerr. = 0 %then %do;
    %gmMessage(linesOut=gmDefxml macro execution finished.);
    %gmMessage(linesOut=%str(Document(s) created at &pathOut.));
%end;
%else %do;
    %gmMessage(linesOut=%str(gmDefxml macro execution finished. Program processed with errors, see log.));
%end;
%gmMessage(linesOut=%str(Compilation start: &defxml_compileTime.  end: %sysFunc(time(), time8.)));


%gmEnd(headURL = 
$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmdefinexml.sas $
);
%mend gmDefineXml;
