/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dan Higgins $LastChangedBy: kolosod $
  Creation Date:         12AUG2016  $LastChangedDate: 2016-09-21 04:59:45 -0400 (Wed, 21 Sep 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextpostprocess.sas $

  Files Created:         RTF file containing In-Text Table (based on fileIn/fileOut parameters)     

  Program Purpose:       The macro is used to replace the header within a PAREXEL standard In-Text Table RTF file 
                         to ensure required styles are defined.  In addition the macro offers the following 
                         post-processing functionality:

                         * Remove or replace non-breaking spaces and hyphens 

                         * Remove additional non-required line breaks in footnotes

                         * Replace symbols
                         
                         The macro can apply changes to an existing file or create a new file containing changes
                         and is executed after the initial RTF file has been created via proc report
                       
  Macro Parameters:

    Name:                fileIn
      Allowed Values:     
      Default Value:     
      Description:       Full path and filename of the RTF file to read from.

    Name:                fileOut
      Allowed Values:     
      Default Value:     
      Description:       Full path and filename of the RTF file to output to.  If not specified then macro will
                         output to file specified in fileIn argument.

    Name:                removeExtraLineBreaks
      Allowed Values:    0 | 1 
      Default Value:     1
      Description:       Used to specified whether extra non-required line breaks are removed from RTF file.   
                         These line breaks can occur within footnotes and needed to be removed from final In-Text Table.
                         Set value to 0 if extra non-required line breaks should not be removed.

    Name:                metadataIn
      Allowed Values:     
      Default Value:     metadata.global
      Description:       Dataset containing metadata

  Macro Returnvalue:     Macro does not return any values 

  Global Macrovariables: Macro does not require any global macro variables to be created

  Metadata Keys:

    Name:                inTextRtfHeader
      Description:       Full path and name of RTF header file containing required style definitions for use in 
                         In-Text Table (taken from PAREXEL CSR template).   If not specified latest version of
                         the file will be used.
      Dataset:           global (dataset specified in metadataIn=)

    Name:                inTextReplaceSymbols
      Description:       Value (0 or 1) is used to specify whether symbol replacement is performed during 
                         execution of macro.  Default (value=1) is to replace the following strings with
                         corresponding symbols:  >= <= +/-.
                         Set value to 0 if symbol replacement is not required.

  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)    

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2610 $
-----------------------------------------------------------------------------*/
%macro gmInTextPostProcess
(
   fileIn=,
   fileOut=,
   removeExtraLineBreaks=1,
   metadataIn=metadata.global
);
            
   * call gmStart and create temporary work library;
   %local itpp_templib;
   %let itpp_templib= %gmStart
      (headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextpostprocess.sas $
      ,revision           = $Rev: 2610 $
      ,checkMinSasVersion = 9.2
      ,librequired        = 1
   );

   * define local macro variables;
   %local itpp_mprint itpp_mlogic itpp_symbolgen itpp_source itpp_notes itpp_noquotelenmax itpp_fexist
      itpp_rtfHeader itpp_path itpp_replaceSymbols;

   * save options;
   %let itpp_mprint=%sysfunc(getoption(mprint));
   %let itpp_mlogic=%sysfunc(getoption(mlogic));
   %let itpp_symbolgen=%sysfunc(getoption(symbolgen));
   %let itpp_source=%sysfunc(getoption(source));
   %let itpp_notes=%sysfunc(getoption(notes));
   %let itpp_noquotelenmax=%sysfunc(getoption(noquotelenmax));
   
   * set options;
   options noquotelenmax;

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
            %gmMessage(codeLocation=gmInTextPostProcess/ABORT
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

   * check if metadata.global dataset exists read InTextRtfHeader value if present;
   * if no value found then set to latest file found;
   filename itpphead pipe "ls /data1/optpxlcommon/stats/macros/macro_library/pxl_csr_header*.dat";
   data &itpp_templib..headdat01;
      infile itpphead pad missover lrecl=1024;
      length indat $1024;
      input indat 1-1024;
   run;
   proc sort data=&itpp_templib..headdat01; by indat; run;
   data _null_;
      set &itpp_templib..headdat01 end=eof;
      by indat;
      if eof then call symput ('itpp_rtfHeader',cats(indat));
   run;
   %if "&metaDataIn" ^= "" and %sysFunc(exist(&metaDataIn)) %then %do;
      data _null_;
         set &metaDataIn;
         if upcase(key)='INTEXTRTFHEADER' and value ^= '' then 
            call symput ('itpp_rtfHeader',trim(left(value)));
      run;
   %end;
   %else %if "&metaDataIn" ^= "" %then %do;
      %gmMessage(codeLocation=gmInTextPostProcess/ABORT
          , linesOut=Macro aborted as &metaDataIn does not exist.
          , selectType=ABORT
       );
   %end;

   * create InTextReplaceSymbols value if present;
   %let itpp_replaceSymbols=1;
   %if "&metaDataIn" ^= "" and %sysFunc(exist(&metaDataIn)) %then %do;
      data _null_;
         set &metaDataIn;
         if upcase(key)='INTEXTREPLACESYMBOLS' and value ^= '' then 
            call symput ('itpp_replaceSymbols',trim(left(value)));
      run;
   %end;
  
   * validate parameters;
   %if "&removeExtraLineBreaks" ^= "0" and "&removeExtraLineBreaks" ^= "1" %then %do;
      %gmMessage(codeLocation=gmInTextPostProcess/Parameter checks
             , linesOut=Macro aborted as removeExtraLineBreaks parameter is not set to 0 or 1
             , selectType=ABORT
      );
   %end;
   %if "&itpp_replaceSymbols" ^= "0" and "&itpp_replaceSymbols" ^= "1" %then %do;
      %gmMessage(codeLocation=gmInTextPostProcess/Parameter checks
             , linesOut=Macro aborted as intextReplaceSymbols metadata value is not set to 0 or 1
             , selectType=ABORT
      );
   %end;

   * check fileIn exists;
   filename ittin "&fileIn";
   data _null_;
      call symput ('itpp_fexist',trim(left(put(fexist('ittin'),best.))));
   run;
   %if &itpp_fexist ^= 1 %then %do;
      %gmMessage(codeLocation=gmInTextPostProcess/ABORT
      , linesOut=Macro aborted as specified fileIn (&fileIn) does not exist.
      , selectType=ABORT);
   %end;

   * set fileOut;
   %if "&fileOut" ^= "" %then %do;
      data _null_;
         dir=0;
         do i=length("&fileout") to 1 by -1;
            if substr("&fileout",i,1)='/' and dir=0 then do;
               call symput ('itpp_path',substr("&fileout",1,i));
               dir=1;
            end;
         end;
      run;
      filename itpppath "&itpp_path";
      %if %sysfunc(fexist(itpppath)) ^= 1 %then %do;
         %gmMessage(codeLocation=gmInTextPostProcess/ABORT
         , linesOut=Macro aborted as directory specified in fileOut does not exist.
         , selectType=ABORT);
      %end;
   %end;
   %else %do;
      * if no output file specified then set to same as input file;
      %let fileOut = &fileIn;
   %end;

   * check fileHeader exists;
   %if "&itpp_rtfHeader" ^= "" %then %do;
      *if only filename specified then add standard path;
      data _null_;
         if index("&itpp_rtfHeader",'/')=0 then do;
            call symput ('itpp_rtfHeader','/data1/optpxlcommon/stats/macros/macro_library/'||
               cats("&itpp_rtfHeader"));
         end;
      run;
      filename itthead "&itpp_rtfHeader";
      data _null_;
         call symput ('itpp_fexist',trim(left(put(fexist('itthead'),best.))));
      run;
      %if &itpp_fexist ^= 1 %then %do;
         %gmMessage(codeLocation=gmInTextPostProcess/ABORT
         , linesOut=Macro aborted as specified fileHeader (&itpp_rtfHeader) does not exist.
         , selectType=ABORT);
      %end;
   %end;
   %else %do;
      %gmMessage(codeLocation=gmInTextPostProcess/ABORT
         , linesOut=Macro aborted as fileHeader not specified in metadata.
         , selectType=ABORT);
   %end;
      
   * read in-text table RTF file into SAS datset;
   data &itpp_templib..intext01;
      infile "&fileIn" lrecl=10000 truncover;
      length line $ 10000;
      input line $ 1-10000;
      temp = .;
   run;

   * remove header portion of RTF syntax;
   data &itpp_templib..intext02;
      set &itpp_templib..intext01;
      by temp;
      retain section bracketcount sectionend;
      if _n_ = 1 then do;
         section=0;
         sectionend=0;
      end;

      if index(line,"{\stylesheet") then do;
         section=1;
         firstline=1;
         bracketcount=0;
      end;

      if sectionend=1 then section=section+1;

      if section=1 then do;
         if firstline=1 then firstchar=index(line,"{\stylesheet");
         else firstchar=1;

         do i=firstchar to length(line);
            char=substr(line,i,1);
            if char="}" then bracketcount=bracketcount-1;    
            if char="{" then bracketcount=bracketcount+1;
            if bracketcount = 0 then do;
               lastline=1;
               stopchar=i;
               sectionend=1;
               i=length(line)+1;
            end;
         end;
      end;

      if section=1 and lastline=1 then do;
         line=substr(line,stopchar+1,length(line));
      end;

      * remove non-breaking spaces;
      line=tranwrd(line,"\~"," ");
    
      * insert non-breaking spaces for abbreviations and deliberate non-breaking hyphens;   
      line=tranwrd(line," = ","\~=\~");
      line=tranwrd(line," - ","\~-\~");

      * define regexs for text replacement;
      * transform "single blind" or "double blind" to have non-breaking hyphen;
      prxid1=prxparse("s/([double|single])([\s|-])(blind)/$1\\_$3/");
      * force SF36 to have non-breaking hypehn rather than regular hyphen or space;
      prxid2=prxparse("s/([SF])([\s|-])(36)/$1\\_$3/");
      * replace hyphen between numbers to have non-breaking hyphen;
      prxid3=prxparse("s/([\d])(-)([\d])/$1\\_$3/");
      * replace space between letter and number with non-breaking space;
      prxid4=prxparse("s/([[:alpha:]])( )(\d)/$1\\~$3/");
     
      * execute regexs;
      line=prxchange(prxid1,-1,line);
      line=prxchange(prxid2,-1,line);
      line=prxchange(prxid3,-1,line);
      line=prxchange(prxid4,-1,line);
   
      * source foonote must have non-breaking spaces;
      if index(line,"Source: ") then do;
         line=tranwrd(strip(line)," ","\~");
         line=tranwrd(line,"\~Source:\~","Source: ");
         line=tranwrd(line,"Source:\~","Source: ");
         line=tranwrd(line,"\iSource:","\i Source:");
      end;
      
      * generate greater/less than or equal to symbols if required;
      %if &itpp_replaceSymbols=1 %then %do;
         line=tranwrd(line,">=","\u8805\bin\ ");
         line=tranwrd(line,"<=","\u8804\bin\ ");
         line=tranwrd(line,"+/-","\u177\bin\ ");
      %end;

      * remove extra carriage returns if required;
      %if &removeExtraLineBreaks=1 %then %do;
         line=tranwrd(line,"\par\pard\intbl{\line}","\par\pard\intbl");
      %end;
          
      if section>1 or (section=1 and lastline=1 and line ^= '') then output;
   run;

   * read in standard CSR RTF header;
   data &itpp_templib..header01;
      infile "&itpp_rtfHeader" lrecl=10000 truncover;
      length line $ 10000;
      input line $ 1-10000;
   run;

   * replace header with standard CSR RTF header;
   * split lines if required to avoid RTF tags wrapping across lines (which causes issue in word);
   data &itpp_templib..intext03;
      set &itpp_templib..header01 &itpp_templib..intext02;
      if length(line)>256 and index(substr(line,220,36),"\") then do;
         div=index(substr(line,220,36),"\");
         newline=substr(line,1,220+div-2);
         output;
         newline=substr(line,220+div-1,length(line));
         output;
      end;
      else do;
         newline=line;
         output;
      end;
   run;

   * output modified in-text table RTF file;
   data _null_;
      file "&fileOut";
      set &itpp_templib..intext03;
      put newline;
   run;
   
   * restore options;
   options &itpp_mprint &itpp_mlogic &itpp_symbolgen &itpp_source &itpp_notes &itpp_noquotelenmax;

   * delete datasets if not in debug mode;
   %if &gmdebug ^= 1 %then %do;
      proc datasets lib=&itpp_templib kill memtype=data nolist; run; quit;
   %end;

   * call gmEnd;
   %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmintextpostprocess.sas $);
      
%mend gmInTextPostProcess;
