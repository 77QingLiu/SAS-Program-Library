/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dan Higgins $LastChangedBy: kolosod $
  Creation Date:         12AUG2016  $LastChangedDate: 2016-09-21 04:59:45 -0400 (Wed, 21 Sep 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextloadstyletemplate.sas $

  Files Created:         intext_tab.sas7bitm     

  Program Purpose:       The macro is used to create an ODS RTF template containing fonts and style elements
                         for use in creation of PAREXEL standard In-Text Tables
                       
  Macro Parameters:

    Name:                libOut
      Allowed Values:     
      Default Value:     work
      Description:       Library to create ODS RTF template in.

    Name:                metadataIn
      Allowed Values:     
      Default Value:     metadata.global
      Description:       Dataset containing metadata.
  
  Macro Returnvalue:     Macro does not return any values 

  Global Macrovariables: Macro does not require any global macro variables to be created

  Metadata Keys:

    Name:                inTextTemplateVer
      Description:       Used to select required version of ODS RTF template.  Value should be 
                         specified in ISO 8601 date format (e.g. 2016-08-25).   If no is value specified
                         the latest version of template will be used.
      Dataset:           global (dataset specified in metadataIn=)

  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2610 $
-----------------------------------------------------------------------------*/
%macro gmInTextLoadStyleTemplate 
(
   libOut=work, 
   metadataIn=metadata.global
);

   * call gmStart;
   %gmStart( headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextloadstyletemplate.sas $
                       ,revision           = $Rev: 2610 $
                       ,checkMinSasVersion = 9.2
                       ,librequired        = 0
                       );

   * define local macro variables;
   %local itst_mprint itst_mlogic itst_symbolgen itst_source itst_notes ittst_rc ittst_dateVer;

   * save options;
   %let itst_mprint=%sysfunc(getoption(mprint));
   %let itst_mlogic=%sysfunc(getoption(mlogic));
   %let itst_symbolgen=%sysfunc(getoption(symbolgen));
   %let itst_source=%sysfunc(getoption(source));
   %let itst_notes=%sysfunc(getoption(notes));

   * set debugging options;
   %if %symExist(gmDebug) %then %do;
      %if &gmDebug=1 %then %do;
         options mprint mlogic symbolgen source notes;
      %end;
      %else %if &gmDebug=0 %then %do;
         options nomprint nomlogic nosymbolgen nosource nonotes;
      %end;
   %end;

   * check gmpxlerr;
   %if %symExist(gmPxlErr) %then %do;
      %if &gmPxlErr. = 1 %then %do;
            %gmMessage(codeLocation=gmInTextLoadStyleTemplate/ABORT
             , linesOut=Macro aborted as GMPXLERR is set to 1.
             , selectType=ABORT
             );
      %end;
   %end;
   %else %do;
      %global gmPxlErr;
      %let gmPxlErr=0;
   %end;

   * check if metadata.global dataset exists read InTextTemplateVer value if present;
   * otherwise default to sysdate;
   %let ittst_dateVer=;
   %if "&metaDataIn" ^= "" and %sysFunc(exist(&metaDataIn)) %then %do;
      data _null_;
         set &metaDataIn;
         if upcase(key)='INTEXTTEMPLATEVER' and value ^= '' then call symput ('ittst_dateVer',trim(left(value)));
      run;
   %end;
   %else %if "&metaDataIn" ^= "" %then %do;
      %gmMessage(codeLocation=gmInTextLoadStyleTemplate/ABORT
          , linesOut=Macro aborted as &metaDataIn does not exist.
          , selectType=ABORT
          );
   %end;

   * check date corresponds to valid template date or is missing;
   %if "&ittst_dateVer" ^= "" and "&ittst_dateVer" ^= "2016-09-01" %then %do;
      %gmMessage(codeLocation=gmInTextLoadStyleTemplate/ABORT
          , linesOut=Macro aborted as InTextTemplateVer (&ittst_dateVer) is invalid.
          , selectType=ABORT
          );
   %end;

   * check output library exists and prepend ODS path;
   %let ittst_rc=%sysfunc(libref(&libOut));
   %if &ittst_rc ^= 0 %then %do;
       %gmMessage(codeLocation=gmInTextLoadStyleTemplate/ABORT
       , linesOut=Macro aborted as &libOut libname not assigned.
       , selectType=ABORT
       );
   %end;
   %else %do;
      * set ODS paths;
      ods path (prepend) &libOut..intext_tab (write);
   %end;

   * check ittst_dateVer is populated in ISO 8601 format;
   %if %sysFunc(prxMatch(/^\d{4}-[01]\d-[0123]\d$/,%superQ(ittst_dateVer))) ^= 1 and "%superQ(ittst_dateVer)" ^= "" %then %do;
      %gmMessage( codeLocation = gmInTextLoadStyleTemplate/ABORT
                , linesOut     = %str(InTextTemplateVer metadata value must be in ISO 8601 format (yyyy-mm-dd).)
                , selectType   = ABORT
                );
   %end;

   * create template;
   proc template;
      define style pxl_intext_tab  / STORE=&libOut..intext_tab;

         * parent style;
         parent = styles.rtf;

         * fonts;
         replace fonts /
              'docfont' = ("Times New Roman", 10pt)
              'headingfont' = ("Times New Roman", 10pt, bold)
              'titlefont' = ("Times New Roman", 12pt,normal)
              'titlefont2' = ("Times New Roman", 12pt,bold)
              'footfont' = ("Times New Roman", 10pt,normal)
              'strongfont' = ("Times New Roman", 10pt)
              'emphasisfont' = ("Times New Roman", 10pt)
              'fixedemphasisfont' = ("Times New Roman", 10pt)
              'fixedstrongfont' = ("Times New Roman", 10pt)
              'fixedheadingfont' = ("Times New Roman", 10pt)
              'batchfixedfont' = ("Times New Roman", 10pt)
              'fixedfont' = ("Times New Roman", 10pt)
              'headingemphasisfont' = ("Times New Roman", 10pt, bold);

         * table style attributes;
         style table    /
              frame = void
              rules = groups
              cellpadding = 2pt
              cellspacing = 0pt
              borderwidth = 0.5pt
              outputwidth = 100%
              just = c
              vjust = center
              background = _undef_
              foreground = _undef_
              bordertopcolor=black 
              bordertopwidth=1
              ;

         * body style attributes;
         style body from document /
              bottommargin = 1in
              topmargin = 1in
              rightmargin = 1.5in
              leftmargin = 1in
              ;

         * header style attributes;
         style header from headersandfooters /
              protectspecialchars=off 
              pretext="^R'\s62 '"
              font=fonts("headingfont")
              just=c;
              ;

         * footer style attributes;
         style SystemFooter from SystemFooter / 
              pretext="^R'\s25 '"
              ;
              
         * data style attributes;
         style data from Cell / 
              pretext = "^R'\s47 '"
              just = c
              vjust = center
              ;

      end;
   run;

   * set prepended ODS paths back to (read);
   ods path (remove) &libOut..intext_tab;
   ods path (prepend) &libOut..intext_tab (read);

   * restore options;
   options &itst_mprint &itst_mlogic &itst_symbolgen &itst_source &itst_notes;

   * call gmEnd;
   %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextloadstyletemplate.sas $);

%mend gmInTextLoadStyleTemplate;
