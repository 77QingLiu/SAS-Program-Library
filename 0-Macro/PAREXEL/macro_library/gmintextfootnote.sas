/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dan Higgins $LastChangedBy: kolosod $
  Creation Date:         12AUG2016  $LastChangedDate: 2016-09-21 04:59:45 -0400 (Wed, 21 Sep 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextfootnote.sas $

  Files Created:         None     

  Program Purpose:       The macro is used to create footnote/s using required fonts and styles for use in 
                         PAREXEL standard In-Text Tables.   Footnotes are created using a compute block and will
                         appear only on last page.
                         
                         The macro must be executed within a proc report after the define statements
                       
  Macro Parameters:

    Name:                footnotes
      Allowed Values:     
      Default Value:     
      Description:       Footnote/s for the In-Text Table.  Multiple footnotes should be separated with the 
                         specified splitChar.  Footnotes should contain relevant RTF codes where indenting is 
                         required.

    Name:                splitChar
      Allowed Values:     
      Default Value:     @
      Description:       Split character to separate footnotes.

    Name:                metadataIn
      Allowed Values:     
      Default Value:     metadata.global
      Description:       Dataset containing metadata.
  
  Macro Returnvalue:     Macro does not return any values 

  Global Macrovariables: Macro does not require any global macro variables to be created

  Metadata Keys:

    Name:                inTextFootnoteAbbrBold
      Description:       Value (0 or 1) is used to bold occurrences of the string 'Abbreviations:' within the
                         footnotes.  Default is not to use bold (value=0).  Set value to 1 to use bolding.
      Dataset:           global (dataset specified in metadataIn=)

    Name:                inTextFootnoteSourceItalic 
      Description:       Value (0 or 1) is used to italicize footnotes that contain the string 'Source:'. 
                         Default is not to use italic (value=0).  Set value to 1 to use italicizing.
      Dataset:           global (dataset specified in metadataIn=)

    Name:                inTextFootnoteBottomBorder 
      Description:       Value (0 or 1) is used to specify if a border is output after the footnotes. 
                         Default is not to display a border (value=0).  Set value to 1 to output a border.
      Dataset:           global (dataset specified in metadataIn=)

  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)    

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2610 $
-----------------------------------------------------------------------------*/
%macro gmInTextFootnote
(
   footnotes=,
   splitChar=@,
   metadataIn=metadata.global
);

   * call gmStart;
   %gmStart( headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextfootnote.sas $
                       ,revision           = $Rev: 2610 $
                       ,checkMinSasVersion = 9.2
                       ,librequired        = 0
   );

   * define local macro variables;
   %local itf_mprint itf_mlogic itf_symbolgen itf_source itf_notes itf_fn itf_abbrfn itf_abbrfnb itf_blank
      itf_abbrBold itf_sourceItalic itf_FNum itf_i itf_mg itf_varnum itf_fetchrc itf_rc itf_abbrfn1 itf_abbrfn2
      itf_brk itf_bottomBorder;

   * save options;
   %let itf_mprint=%sysfunc(getoption(mprint));
   %let itf_mlogic=%sysfunc(getoption(mlogic));
   %let itf_symbolgen=%sysfunc(getoption(symbolgen));
   %let itf_source=%sysfunc(getoption(source));
   %let itf_notes=%sysfunc(getoption(notes));
   
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
            %gmMessage(codeLocation=gmInTextFootnote/ABORT
             , linesOut=Macro aborted as GMPXLERR is set to 1.
             , selectType=ABORT
             , printStdOut=1             
             );
      %end;
   %end;
   %else %do;
      %global gmPxlErr;
      %let gmPxlErr=0;
   %end;

   * check if metadata.global dataset exists read values if present;
   * otherwise default to sysdate;
   %let itf_abbrBold=0;
   %let itf_sourceItalic=0;
   %let itf_bottomBorder=0;
   %if "&metaDataIn" ^= "" and %sysFunc(exist(&metaDataIn)) %then %do;
      %let itf_mg=%sysfunc(open(&metadataIn (where=(upcase(key)='INTEXTFOOTNOTEABBRBOLD' and value ^= '')),i));
      %if &itf_mg=1 %then %do;
         %let itf_varnum=%sysfunc(varnum(&itf_mg,value));
         %let itf_fetchrc=%sysfunc(fetch(&itf_mg));
         %if &itf_fetchrc ^= -1 %then %do;
            %let itf_abbrBold=%sysfunc(getvarc(&itf_mg,&itf_varnum));
         %end;            
         %let itf_rc=%sysfunc(close(&itf_mg));
      %end;
      %let itf_mg=%sysfunc(open(&metadataIn (where=(upcase(key)='INTEXTFOOTNOTESOURCEITALIC' and value ^= '')),i));
      %if &itf_mg=1 %then %do;
         %let itf_varnum=%sysfunc(varnum(&itf_mg,value));
         %let itf_fetchrc=%sysfunc(fetch(&itf_mg));
         %if &itf_fetchrc ^= -1 %then %do;
            %let itf_sourceItalic=%sysfunc(getvarc(&itf_mg,&itf_varnum));
         %end;
         %let itf_rc=%sysfunc(close(&itf_mg));
      %end;
      %let itf_mg=%sysfunc(open(&metadataIn (where=(upcase(key)='INTEXTFOOTNOTEBOTTOMBORDER' and value ^= '')),i));
      %if &itf_mg=1 %then %do;
         %let itf_varnum=%sysfunc(varnum(&itf_mg,value));
         %let itf_fetchrc=%sysfunc(fetch(&itf_mg));
         %if &itf_fetchrc ^= -1 %then %do;
            %let itf_bottomBorder=%sysfunc(getvarc(&itf_mg,&itf_varnum));
         %end;
         %let itf_rc=%sysfunc(close(&itf_mg));
      %end;
   %end;
   %else %if "&metaDataIn" ^= "" %then %do;
      %gmMessage(codeLocation=gmInTextFootnote/ABORT
          , linesOut=Macro aborted as &metaDataIn does not exist.
          , selectType=ABORT
       );
   %end;
  
   * validate parameters;
   %if "&itf_abbrBold" ^= "0" and "&itf_abbrBold" ^= "1" %then %do;
      %gmMessage(codeLocation=gmInTextFootnote/ABORT
             , linesOut=Macro aborted as InTextFootnoteAbbrBold metadata value is not set to 0 or 1
             , selectType=ABORT
      );
   %end;
   %if "&itf_sourceItalic" ^= "0" and "&itf_sourceItalic" ^= "1" %then %do;
      %gmMessage(codeLocation=gmInTextFootnote/ABORT
             , linesOut=Macro aborted as InTextFootnoteSourceItalic metadata value is not set to 0 or 1
             , selectType=ABORT
      );
   %end;
   %if "&itf_bottomBorder" ^= "0" and "&itf_bottomBorder" ^= "1" %then %do;
      %gmMessage(codeLocation=gmInTextFootnote/ABORT
             , linesOut=Macro aborted as InTextFootnoteBottomBorder metadata value is not set to 0 or 1
             , selectType=ABORT
      );
   %end;

   %if %length(%superQ(splitChar)) ^= 1 %then %do;
       %gmMessage(codeLocation = gmInTextFootnote/ABORT
               , linesOut    = %str(Value of macro parameter SplitChar is invalid, must be a single character.)
               , selectType  = ABORT
               );
   %end;

   %if "&footnotes"="" %then %do;
      %gmMessage(codeLocation=gmInTextFootnote/ABORT
             , linesOut=Macro aborted as no footnotes are specified
             , selectType=ABORT
      );
   %end;
        
   * separate footnotes;
   %let itf_FnNum=0;
   %let itf_FnNum=%eval(%sysFunc(countc(%superQ(footnotes),%superQ(splitChar)))+1);
   %do itf_i = 1 %to &itf_fnNum;
      %local itf_footnote&itf_i.;
      * split;
      %let itf_footnote&itf_i. = %qScan(%superQ(footnotes),&itf_i.,%superQ(splitChar),m);
      * convert single quotes to double single quotes incase they are used in footnote;
      %let itf_footnote&itf_i. = %qSysFunc(tranwrd(%superQ(itf_footnote&itf_i.),%str(%'),''));

   %end;

   * set footnotes;
   %if &itf_fnNum ^= 0 %then %do;
      compute after _page_ / 
         style=[ just=left
                 bordertopcolor=black 
                 bordertopwidth=1
                 %if &itf_bottomBorder=1 %then %do;
                    borderbottomcolor=black 
                    borderbottomwidth=1
                 %end;
               ];
         %do itf_fn=1 %to &itf_FnNum;
            %if "&itf_sourceItalic"="1" and %sysfunc(index(%superq(itf_footnote&itf_fn),%str(Source:))) %then %do;
               line @1 "^R'\s25\i '"%str(%')%superq(itf_footnote&itf_fn.)%str(%')"^R'\i0\par\pard\intbl'";
            %end;
            %else %if "&itf_abbrBold"="1" and %sysfunc(index(%superq(itf_footnote&itf_fn),%str(Abbreviations:))) %then %do;
               %let itf_brk=%eval(%sysfunc(index(%superq(itf_footnote&itf_fn),%str(Abbreviations:)))+13);
               %let itf_abbrfn1=%qsubstr(%superq(itf_footnote&itf_fn),1,&itf_brk);
               %let itf_abbrfn2=%qsubstr(%superq(itf_footnote&itf_fn),%eval(&itf_brk+2));
               line @1 "^R'\s25\b '"%str(%')%superq(itf_abbrfn1)%str(%')"^R'\b0\ ' "%str(%')%superq(itf_abbrfn2)%str(%')"^R'\par\pard\intbl'";
            %end;
            %else %do;
               line @1 "^R'\s25 '"%str(%')%superq(itf_footnote&itf_fn.)%str(%')"^R'\par\pard\intbl'";             
            %end;
         %end;
      endcomp;
   %end;

   * restore options;
   options &itf_mprint &itf_mlogic &itf_symbolgen &itf_source &itf_notes;

   * call gmEnd;
   %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextfootnote.sas $);

%mend gmIntextFootnote;
