/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Dmitry Kolosov $LastChangedBy: kusserj $
  Creation Date:         06NOV2011  $LastChangedDate: 2016-06-13 03:09:38 -0400 (Mon, 13 Jun 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscancore.sas $

  Files Created:         None


  Program Purpose:       gmLogScanCore macro is used to process logs and identify
                         potential errors/warning and other messages which must be
                         checked by user.

                         This macro implements 2 algorithms: black list
                         (old miglogchk approach) and white list (EP approach).

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                dataIn

      Description:       Input dataset which contains LOGTEXT variable


    Name:                dataOut

      Description:       Output dataset

    Name:                selectList

      Allowed Values:    White|Black

      Default Value:     Black

      Description:       Processing algorithm. See the wiki page for details.

    Name:                maxLen

      Allowed Values:    1-32767

      Default Value:     1024

      Description:       Max length of united variable, must not exceed 32767.

    Name:                customWhitelistIn

      Description:       Full path to a custom white list. See the wiki page for details.

  Macro Returnvalue:     N/A

  Macro Dependencies:    gmExecuteUnixCmd (called)
                         gmMessage (called)
                         gmStart (called)
                         gmEnd (called)


-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2307 $
-----------------------------------------------------------------------------*/
%macro gmLogScanCore(dataIn=,
                     dataOut=,
                     selectList=BLACK,
                     maxLen=1024,
                     customWhiteListIn=
                    );


%let glsc_tempLib = %gmStart(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscancore.sas $,
                        revision=$Rev: 2307 $,
                        libRequired=1
                       );

***********************************************************************************;
* Checks;
***********************************************************************************;

* Check the input dataset exists;
%if not %sysFunc(exist(&dataIn.)) or &dataIn. eq %then %do;
    %gmMessage( codeLocation= gmLogCheckCore/Parameter checks
          , linesOut    = Invalid input dataset. dataIn=&dataIn.
          , selectType  = ABORT
          );
%end;

* Check the output parameter is specified;
%if &dataOut. eq %then %do;
    %gmMessage( codeLocation= gmLogCheckCore/Parameter checks
          , linesOut    = Invalid output dataset. dataOut=&dataOut.
          , selectType  = ABORT
          );
%end;

* Check the select list parameter is valid;
%if %upcase(&selectList.) ne BLACK and %upcase(&selectList.) ne WHITE  %then %do;
    %gmMessage( codeLocation= gmLogCheckCore/Parameter checks
          , linesOut    = Invalid value of the list parameter. selectList=&selectList.
          , selectType  = ABORT
          );
%end;

* Check the max length parameter is valid;
%if &maxLen < 1 or &maxLen > 32767 %then %do;
    %gmMessage( codeLocation= gmLogCheckCore/Parameter checks
          , linesOut    = Invalid value of the maximum length parameter. maxLen=&maxLen.
          , selectType  = ABORT
          );
%end;

%local glsc_pathToWhiteList glsc_noWhiteListMsg;

* Check whitelist exists, in case it does not exist change the algorithm to black list;
%if %qUpcase(&selectList.) eq WHITE %then %do;
    data _null_;
        length glsc_pathToWhiteList $1024;
        glsc_pathToWhiteList = prxChange("s#.*/svnrepo/\w*/(.*)/\w*\.sas.*#/opt/pxlcommon/stats/macros/$1/whitelist.xls#",1,
'$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscancore.sas $'
                                        );
        call symput("glsc_pathToWhiteList",strip(glsc_pathToWhiteList));
    run;

    data _null_;
        if not fileExist("&glsc_pathToWhiteList.") then do;
            call symput("selectList","BLACK");
            call symput("glsc_noWhiteListMsg",
                        "White list is not found. Please contact macro and application development team for support."
                        || " Black list is used instead."
                       );
        end;
    run;

    %if "&glsc_noWhiteListMsg." ne "" %then %do;
        %gmMessage( codeLocation= gmLogCheckCore/Parameter checks
              , linesOut    = &glsc_noWhiteListMsg.
              , selectType  = W
              );
    %end;
    %else %do;
        * Copy the white list to a temporary folder, in order to resolve 9.1.3 issue;
        %let glsc_rc = %gmExecuteUnixCmd(cmds=cp &glsc_pathToWhiteList. %sysFunc(pathname(&glsc_tempLib.)));
        %let glsc_pathToWhiteList = %sysFunc(pathname(&glsc_tempLib))/whitelist.xls;
    %end;
%end;

* Check the custom white list exists in case it was specified;
* If the file exists, collect size and modification date;
%if %qLeft(&customWhiteListIn.) ne %then %do;
    %local glsc_cWL_name glsc_cWL_date glsc_cWL_size glsc_noCustomWhiteListMsg;
    data _null_;
        if not fileExist("&customWhiteListIn.") then do;
            call symput("glsc_noCustomWhiteListMsg",
                        "The custom white list is not found. Please check the correct location and file name are specified: "
                        || "&customWhiteListIn."
                       );
        end;
        else do;
            * Get name, location, size and date;
            rc = fileName("custWL","&customWhiteListIn.");
            fId = fOpen("custWL");
            call symput("glsc_cWL_name",fInfo(fId,fOptName(fId,1)));
            call symput("glsc_cWL_date",fInfo(fId,fOptName(fId,5)));
            call symput("glsc_cWL_size",fInfo(fId,fOptName(fId,6)));
            rc = fClose(fId);
            rc = fileName("custWL","");
        end;
    run;

    %if %qLeft(&glsc_noCustomWhiteListMsg.) ne %then %do;
        %gmMessage( codeLocation= gmLogCheckCore/Parameter checks
              , linesOut    = &glsc_noCustomWhiteListMsg.
              , selectType  = ABORT
              );
    %end;
%end;

***********************************************************************************;
* Processing the log;
***********************************************************************************;

* Step one, flag code/title lines;
data &glsc_tempLib..glsc1/ view=&glsc_tempLib..glsc1;
    set &dataIn.(keep=logText) end=eof;

    * Line number. This number to be used in reports;
    logLineNumOriginal = _n_;

    * Check if message is source code/mprint/macrogen/comment;
    * If MPRINT/MACROGEN are on multiple lines then lines are united first
    * SYMBOLGEN/MLOGIC is united till the next message
    * and then dropped;
    if prxMatch("/^\d[\d ]{4,}(?:!|\s)/",logText)
       or left(logText) eq: '%*'
       or (logText in: ("MACROGEN(","MPRINT(") and prxMatch("/.*;$/",strip(logText)))
    then do;
        codeFlag = 1;
    end;
    else if logText in: ("MACROGEN(","MPRINT(","MLOGIC","SYMBOLGEN:") then do;
        codeFlag = 0;
        multiLineMacroMsgStart = 1;
    end;
    else do;
        codeFlag = 0;
    end;

    * Flag title line and blank line after it;
    * In case of LS=256, \f will be added to the title and last character may be truncated.;
    * To handle that situation year pattern changed to \d{3,4};
    retain titleFlag 0;
    if prxMatch("/^(\f)?\d*\s*The SAS System(?:\s*\d{2}:\d{2}\s\w+,\s\w+\s\d+,\s\d{3,4})?\s*$/"
                ,logText)
    then do;
        titleFlag = 1;
        deleteLineFlag = 1;
    end;
    * Sometimes first line can be \f\n (need to investigate what causes it);
    else if logText eq byte(12) then do;
        deleteLineFlag = 1;
    end;
    else do;
        if titleFlag eq 1 and logText = " " then do;
            * Blank line after title;
            deleteLineFlag = 1;
        end;
        titleFlag = 0;
    end;

run;

* Get the maximum line size;
%local glsc_maxLS;
%let glsc_maxLS = 64;
data _null_;
    set &dataIn.(keep=logText) end=eof;

    * Get the maximum line size;
    retain glsc_maxLS 64;
    glsc_maxLS = max(glsc_maxLS,length(logText));

    if eof then do;
        call symputx("glsc_maxLS",glsc_maxLS);
    end;
run;

* Drop title/blank line after the title, enumerate new lines;
* This is required to correctly unite messages which are shown on different pages;
data &glsc_tempLib..glsc2(drop = titleFlag deleteLineFlag callExecuteLine) / view=&glsc_tempLib..glsc2;
    set &glsc_tempLib..glsc1(where = (deleteLineFlag ne 1));

    logLineNum = _n_;
    prevLogLineNum = max(1,_n_-1);

    * Mark all lines where previous line was call execute line;
    if codeFlag and prxMatch("/^\d+\s+\+/",logText) then do;
        callExecuteLine = 1;
    end;

    if lag(callExecuteLine) eq 1 then do;
        callExecutePrevLine = 1;
    end;
run;

* Unite lines of one message;
data &glsc_tempLib..glsc3(drop = prevlogLineNum uniteFlag codeFlag logText lagLogLineNum prevLineIsMissing
                  sumLength lagmultiLineMacroMsgStop lagStartMessageFlag multiLine: startMessageFlag)
    / view=&glsc_tempLib..glsc3
    ;
    * Drop all code lines from the log;
    set &glsc_tempLib..glsc2(where = (codeFlag ne 1));

    * Remove form feed from the text;
    logText = compress(logText,byte(12));

    * Check if previous line was missing;
    prevLineIsMissing=lag(missing(logText));

    * Flag where to start message;
    %if %upcase(&selectList.) eq WHITE %then %do;
        ** If line starts with:
        ** "WARNING:" or "WARNING 111-115:"
        ** "ERROR:" or "ERROR 111-115:"
        ** "NOTE:" or "NOTE 111-115:"
        ** "111: ";
        if prxMatch("/^(\d+:\s|INFO:|(WARNING|ERROR|NOTE)([\s\d-]*)?:)/",logText)
    %end;
    %if %upcase(&selectList.) eq BLACK %then %do;
        ** For black list rules are not so strict;
        if prxMatch("/^(\d+:\s)/",logText)
           or upcase(logText) in: ("WARNING","ERROR","NOTE","INFO:")
    %end;
       or multiLineMacroMsgStart eq 1
       or (prevLineIsMissing eq 1 and not missing(logText))
    then do;
        startMessageFlag = 1;
    end;

    * Multiple MPRINT/MACROGEN/SYMBOLGEN/MLOGIC lines, unite until semicolon or a new message;
    retain multiLineMacroMsgFlag 0 lagmultiLineMacroMsgStop lagStartMessageFlag;

    if multiLineMacroMsgStart eq 1 then do;
        multiLineMacroMsgFlag = 1;
    end;
    ** Stop if line ends with a semicolon for MPRINT/MACROGEN message
    ** Stop if line does not start with 6 spaces for SYMBOLGEN, MLOGIC message
    ** or if next message starts (case when multi line does end with a semicolon);
    else if multiLineMacroMsgFlag eq 1 and
            (
             ( prxMatch("/.*;$/",strip(logText)) and logTextUnited in: ("MPRINT","MACROGEN") )
             or ( trim(logText) ne: "      " and logTextUnited in: ("MLOGIC","SYMBOLGEN") )
             or startMessageFlag eq 1
            ) 
    then do;
        multiLineMacroMsgStop = 1;
        multiLineMacroMsgFlag = 0;
    end;
    ** Create variable with the value of multiple line stop flag
    ** from the previous line;
    lagmultiLineMacroMsgStop = lag(multiLineMacroMsgStop);
    lagStartMessageFlag = lag(startMessageFlag);
    ** Start a new message if previous multi line MPRINT/MACROGEN stopped not due to a new message;
    if lagmultiLineMacroMsgStop eq 1 and lagStartMessageFlag ne 1 and logTextUnited in: ("MPRINT","MACROGEN")  then do;
        startMessageFlag = 1;
    end;
    ** Start a new message if current multi line SYMBOLGEN/MLOGIC stopped not due to a new message;
    if multiLineMacroMsgStop eq 1 and startMessageFlag ne 1 and logTextUnited in: ("MLOGIC","SYMBOLGEN")then do;
        startMessageFlag = 1;
    end;

    ** For those lines which start a new message and have a word with length > (line size - 4), set
    ** a special flag to 1. Later, if such messages are identified as unassessed, risk type is changed
    ** to check manually. This is caused by the fact that extra blank lines can be reported by SAS
    ** when a line contains very long word;
    retain glsc_longWordFn 0;
    *** Reset the flag;
    if startMessageFlag eq 1 then do;
        glsc_longWordFn = 0;
    end;
    *** Set it to 1 in case the line contains a long word;
    if startMessageFlag eq 1 and prxMatch("/\S{%eval(&glsc_maxLS-4),}/",logText) then do;
        glsc_longWordFn = 1;
    end;

    * Unite lines. Do not unite lines if there is a blank line or code between them;
    * Code lines are dropped at set;
    lagLogLineNum = lag(logLineNum);
    if (prevLogLineNum ne lagLogLineNum)
       or missing(logText)
    then do;
        uniteFlag = 0;
    end;
    else do;
        uniteFlag = 1;
    end;

    * Check for length overflow;
    retain sumLength 0;
    ** Reset when a new messages starts;
    ** Length overflow is ok for multi line MPRINT/MACROGEN/SYMBOLGEN lines as they will
    ** not be analysed;
    if uniteFlag eq 0
       or startMessageFlag eq 1
       or multiLineMacroMsgFlag eq 1
    then do;
        sumLength = length(logText);
    end;
    else do;
        sumLength = length(logText)+sumLength;
    end;
    ** In case a new text can not fit into united variable start a new message;
    if sumLength > &maxLen. then do;
        startMessageFlag = 1;
        sumLength = length(logText);
    end;

    * Unite text where united flag is checked;
    length logTextUnited $&maxLen.;
    retain logTextUnited " " messageId 0 messageStartLine 0;

    if startMessageFlag eq 1 then do;
        logTextUnited = logText;
        messageStartLine = logLineNumOriginal;
        messageId = messageId + 1;
    end;
    else if uniteFlag eq 1 then do;
        logTextUnited = strip(logTextUnited) || " " || strip(logText);
    end;
    else do;
        logTextUnited = logText;
        messageStartLine = logLineNumOriginal;
        messageId = messageId + 1;
    end;
    * Error printed flag - if ERROR or ERROR:[PXL] was printed;
    * Required to understand whether "Errors printed" message can be dropped;
    retain errorPrintedFl 0;
    if logTextUnited eq: "ERROR" and logTextUnited ne: "ERROR: Errors printed on page" then do;
        errorPrintedFl = 1;
    end;
run;

* Leave one line per message;
data &glsc_tempLib..glsc4(drop=messageId logLineNum:)
    / view = &glsc_tempLib..glsc4;
    set &glsc_tempLib..glsc3;
    by messageId logLineNum;

    * Drop multi line MACROGEN/MPRINT/SYMBOLGEN/MLOGIC messages;
    if logTextUnited not in: ("SYMBOLGEN:","MPRINT(","MLOGIC","MACROGEN(")
       and (last.messageId and not missing(logTextUnited)) then do;
        output;
    end;
run;

***********************************************************************************;
* Black list;
***********************************************************************************;
%if %upcase(&selectList.) eq BLACK %then %do;
    data &glsc_tempLib..blackList;
         length chktext $50;
         chktext="ABNORMALLY TERMINATED"; output;
         chktext="ANNOTATION"; output;
         chktext="APPARENT"; output;
         chktext="CONVERSION"; output;
         chktext="CONVERTED"; output;
         chktext="ERROR"; output;
         chktext="EXTRANEOUS"; output;
         chktext="HARD CODE"; output;
         chktext="HARD-CODE"; output;
         chktext="HARDCODE"; output;
         chktext="IN ANNOTATE"; output;
         chktext="INVALID"; output;
         chktext="MERGE STATEMENT"; output;
         chktext="MULTIPLE"; output;
         chktext="NOT EXIST"; output;
         chktext="NOT RESOLVED"; output;
         chktext="NOTE: THE SAS SYSTEM"; output;
         chktext="OUTSIDE"; output;
         chktext="REPLACED"; output;
         chktext="SAS SET OPTION OBS=0"; output;
         chktext="SAS WENT"; output;
         chktext="STOPPED"; output;
         chktext="TOO LONG"; output;
         chktext="TRUNCATED"; output;
         chktext="UNINIT"; output;
         chktext="UNKNOWN"; output;
         chktext="W.D FORMAT"; output;
         chktext="WARNING"; output;
         chktext="WHERE CLAUSE"; output;
         chktext="_ERROR_"; output;
    run;

    * Put all messages in macro variables;
    %local glsc_blackListText glsc_nBlackList;
    data _null_;
         set &glsc_tempLib..blackList end=eof;
         call symput("glsc_blackListText" || compress(put(_n_, 8.)), trim(chktext));
         if eof then call symput("glsc_nBlackList", compress(put(_n_, 8.)));
    run;

    data &glsc_tempLib..glsc5(keep = type risk code logTextUnited messageStartLine listType
               rename = (messageStartLine = lineNum)) / view = &glsc_tempLib..glsc5;
        length type $50. risk $30. code $5.;

        retain anyMessageFlag 0;

        length listType $10;
        retain listType "Main";

        * Process case without log messages;
        if _n_ eq 1 and eof eq 1 then do;
             risk ="Empty Log";
             type ="Log does not contain executed SAS code.";
             code = "-1";
             output;
        end;

        set &glsc_tempLib..glsc4 end=eof;

        * First exclude messages which are not errors;
        if index(upcase(logTextUnited),"YOU ARE RUNNING SAS 9. SOME SAS 8 FILES WILL BE AUTOMATICALLY CONVERTED")
            or index(upcase(logTextUnited),"WARNING: UNABLE TO COPY SASUSER REGISTRY TO WORK REGISTRY.")
            or index(upcase(logTextUnited),"WARNING: DMS BOLD FONT METRICS FAIL TO MATCH DMS FONT.")
            or index(upcase(logTextUnited),"NOTE: THE SAS SYSTEM USED:")
            or index(upcase(logTextUnited),"ERROR: ERRORS PRINTED ON PAGE")
            or index(upcase(logTextUnited),"WARNING: YOUR SYSTEM IS SCHEDULED TO EXPIRE")
            or index(upcase(logTextUnited),"WARNING: WILL BE EXPIRING SOON, AND IS CURRENTLY IN WARNING MODE")
            or index(upcase(logTextUnited),"WARNING: THIS UPCOMING EXPIRATION. PLEASE RUN")
            or index(upcase(logTextUnited),"WARNING: INFORMATION ON YOUR WARNING PERIOD.")
            or index(upcase(logTextUnited),"NOTE: MULTIPLE CONCURRENT THREADS WILL BE USED TO SUMMARIZE")
            or prxMatch("/^WARNING: The [\w\s\/]+ product with which/",logTextUnited)
        then do;
            * Nothing;
        end;
        * Check for PXL messages, and not HARDCODE messages;
        else if upcase(logTextUnited) in: ("ERROR","WARNING","NOTE")
                and index(upcase(substr(logTextUnited,1,20)),"[PXL]")
                and not index(upcase(compress(logTextUnited," -")),"HARDCODE")
        then do;
            * Scan first word and add [PXL];
            type = strip(prxChange("s/^(\w+).*$/$1/",1,logTextUnited))||":[PXL]";
            risk = "Data Issue";
            if upcase(logTextUnited) eq: "ERROR" then do;
                 risk = "Check Manually";
                code = "9999";
            end;
            if upcase(logTextUnited) eq: "WARNING" then do;
                code = "9998";
            end;
            * Do not report NOTE:[PXL] in results;
            if upcase(logTextUnited) ne: "NOTE" then do;
                anyMessageFlag = 1;
                output;
            end;
        end;
        * Check all other messages;
        else do;
            %do glsc_i=1 %to &glsc_nBlackList.;
                if index(upcase(logTextUnited),"&&glsc_blackListText&glsc_i.") then do;
                    type = "&&glsc_blackListText&glsc_i.";
                    risk = "ERROR-like Condition";
                    code = "&glsc_i.";
                    anyMessageFlag = 1;
                    output;
                end;
            %end;
            if index (upcase(logTextUnited),"MISSING")
               and not index(upcase(compress(logTextUnited)),"MISSING(")
            then do;
                    type = "MISSING";
                    risk = "ERROR-like Condition";
                    code = "%eval(&glsc_nBlackList.+1)";
                    anyMessageFlag = 1;
                    output;
            end;
        end;
        * If black list is used as a back-up for missing white list;
        %if "&glsc_noWhiteListMsg." ne "" %then %do;
             if _n_ eq 1 then do;
                 logTextUnited = "&glsc_noWhiteListMsg.";
                 type =" ";
                 messageStartLine = .;
                 risk =" ";
                 type ="";
                 code = "-1";
                 output;
             end;
        %end;
        * If no messages found then create one observation;
        if eof and anyMessageFlag ne 1 then do;
             risk =" ";
             logTextUnited = " ";
             type ="No errors found.";
             messageStartLine = .;
             code = "0";
             output;
        end;
    run;
    * Black list end;
%end;
***********************************************************************************;
* White list;
***********************************************************************************;
%if %upcase(&selectList.) eq WHITE %then %do;
    proc import file = "&glsc_pathToWhiteList." dbms=xls out = &glsc_tempLib..whiteListRaw replace;
        textSize = &maxLen.;
    run;

    * Load custom white list;
    %if "&customWhiteListIn." ne "" %then %do;
        proc import file = "&customWhiteListIn." dbms=xls out = &glsc_tempLib..whiteListCustom replace;
            textSize = &maxLen.;
        run;

        * Check if the custom list was already saved for WhiteList development;
        %let glsc_customWhiteList_Checked = 0;

        data _null_;
            infile "/opt/pxlcommon/stats/macros/logging/gmlogscancore_custom_whitelists.log" lrecl = 2056;
            input;
            length line name date size $2056;
            line = _inFile_;
            name = prxChange("s/<name>(.*)<\/name><date>(.*)<\/date><size>(.*)<\/size>/$1/i",1,line);
            date = prxChange("s/<name>(.*)<\/name><date>(.*)<\/date><size>(.*)<\/size>/$2/i",1,line);
            size = prxChange("s/<name>(.*)<\/name><date>(.*)<\/date><size>(.*)<\/size>/$3/i",1,line);

            if strip(name) = "&glsc_cWL_name" and strip(size) = "&glsc_cWL_size" and strip(date) = "&glsc_cWL_date"
            then do;
                call symPut("glsc_customWhiteList_Checked","1");
            end;
        run;
        * If it was not saved, dump everything and update the list of checked files;
        %if &glsc_customWhiteList_Checked = 0 %then %do;

            %gmMessage(linesOut=A new custom checklist was found.
                                @It is saved to a logging directory for further development of the whitelist.
                      );

            data _null_;
                set &glsc_tempLib..whiteListCustom;

                length message $32767;
                message = "echo """
                          ||"<user>&sysUserId.</user><customWhiteList>&customWhiteListIn.</customWhiteList>"
                          ||"<regex>"||strip(regex)||"</regex><typeNum>"||strip(put(typeNum,best.))
                          ||"</typeNum><priority>"||strip(put(priority,best.))
                          ||"</priority><type>"||strip(type)||"</type><risk>"||strip(risk)||"</risk><comment>"||strip(comment)||"</comment>"
                          || """ >>  /opt/pxlcommon/stats/macros/logging/gmlogscancore_custom_whitelist_messages.log";
                * Append to the list of messages avoiding file lock;
                rc = system(strip(message));
            run;

            data _null_;
                length message $2056;
                message = "echo """
                          ||"<name>&glsc_cWL_name</name><date>&glsc_cWL_date</date><size>&glsc_cWL_size</size>"
                          || """ >>  /opt/pxlcommon/stats/macros/logging/gmlogscancore_custom_whitelists.log" ;

                * Append to the list of messages avoiding file lock;
                rc = system(strip(message));
            run;
        %end;
    %end;

    * Add code (first line is used for variables names, that is why +1 is added);
    data &glsc_tempLib..whiteListCode;
        %if "&customWhiteListIn." ne "" %then %do;
            length regex $&maxLen. type $50 risk $30 comment $512;
        %end;
        set &glsc_tempLib..whiteListRaw(in=inMain)
            %if "&customWhiteListIn." ne "" %then %do;
                &glsc_tempLib..whiteListCustom
            %end;
        ;
        code = _n_ + 1;
        length listType $10;
        if inMain then do;
            listType = "Main";
        end;
        else do;
            listType = "Custom";
        end;
    run;

    * Sort to check most severe first;
    * Drop records with missing risk;
    proc sort data = &glsc_tempLib..whitelistCode(where = (not missing(priority))) out = &glsc_tempLib..whiteList;
        by descending priority descending typeNum;
    run;

    * Check the whitelist for consistency, in case a custom whitelist is used;
    %if "&customWhitelistIn" ne "" %then %do;
        proc SQL noprint;

        create table &glsc_tempLib..whiteListCheck as
            select risk 
            from &glsc_tempLib..whiteList
            group by risk
            having count(distinct int(priority)) > 1
        ;
        quit;
        %if &sqlObs > 0 %then %do;
            %gmMessage( codeLocation = gmLogCheckCore/Custom whitelist Check
                        ,linesOut = Inconsistent priorities in the custom and main whitelists
                        ,selectType=E
                       );
            %let glsc_wrongCustomWhiteList = 1; 

            data &dataOut.;
                length type $50 risk $30 code $5 listType $10 logTextUnited $&maxLen.; 

                risk ="High Risk";
                type ="Inconsistent priorities in main and custom lists";
                code = "-1";
                logTextUnited = " ";
                messageStartLine = .;
                lineNum = .;
                listType = " ";
            run;

            * Stop macro execution;
            %gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscancore.sas $);
            %return;
        %end;
        
    %end;

    * Put all messages in macro variables;
    %local  glsc_whiteListRegEx glsc_whiteListType glsc_whiteListRisk glsc_whiteListCode glsc_nWhiteList;
    data _null_;
         set &glsc_tempLib..whiteList end=eof;
         call symput("glsc_whiteListRegEx"     || compress(put(_n_, 8.)), trim(regEx));
         call symputx("glsc_whiteListType"     || compress(put(_n_, 8.)), trim(type));
         call symputx("glsc_whiteListRisk"     || compress(put(_n_, 8.)), trim(risk));
         call symputx("glsc_whiteListListType" || compress(put(_n_, 8.)), trim(listType));
         call symputx("glsc_whiteListCode"     || compress(put(_n_, 8.)), trim(put(code,best.)));
         if eof then call symput("glsc_nWhiteList", compress(put(_n_, 8.)));
    run;

    data &glsc_tempLib..glsc5(keep = type risk code logTextUnited messageStartLine listType
               rename = (messageStartLine = lineNum)
              ) / view=&glsc_tempLib..glsc5;
        length type $50 risk $30 code $5 listType $10;

        retain anyMessageFlag 0;

        set &glsc_tempLib..glsc4 end=eof;

        * White list messages;
        %do glsc_i=1 %to &glsc_nWhiteList.;
            %if &glsc_i. ne 1 %then %do;
                else
            %end;
            if prxMatch("&&glsc_whiteListRegex&glsc_i.",strip(logTextUnited)) then do;
                type = "&&glsc_whiteListType&glsc_i.";
                risk = "&&glsc_whiteListRisk&glsc_i.";
                code = "&&glsc_whiteListCode&glsc_i.";
                listType = "&&glsc_whiteListListType&glsc_i.";
                * If at least one error message was printed to the log, drop the; 
                * "ERRORs were printed on pages xxx" message;
                if risk ne "No Risk" and
                   not (errorPrintedFl eq 1 and logTextUnited eq: "ERROR: Errors printed on page")
                then do;
                    anyMessageFlag = 1;
                    output;
                end;
            end;
        %end;
        * If message did not match any from the white list and the lines contains very long word;
        else if glsc_longWordFn then do;
                type = "Unknown";
                listType = " ";
                risk = "Check Manually";
                code = "-3";
                anyMessageFlag = 1;
                output;
        end;
        * If message did not match any from the white list;
        * If previous line was unassessed line, do not show it as unassessed message;
        else if callExecutePrevLine ne 1 then do;
                type = "Unknown";
                risk = "Unassessed";
                listType = " ";
                code = "-2";
                anyMessageFlag = 1;
                output;
        end;

        * If no messages found then create one observation;
        if eof and anyMessageFlag ne 1 then do;
             risk =" ";
             logTextUnited = " ";
             type ="No errors found.";
             listType = " ";
             messageStartLine = .;
             code = "0";
             output;
        end;
    run;
    * White list end;
%end;

* Process case without log messages;
data &dataOut.;
    length type $50. risk $30. code $5.;
    if _n_ eq 1 and eof eq 1 then do;
        risk ="Empty Log";
        type ="Log does not contain executed SAS code.";
        code = "-1";
        output;
    end;
    set &glsc_tempLib..glsc5 end=eof;
    output;
run;

%gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmlogscancore.sas $);

%mend gmLogScanCore;
