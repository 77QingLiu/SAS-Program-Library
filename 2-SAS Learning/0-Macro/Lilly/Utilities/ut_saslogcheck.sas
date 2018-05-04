%macro ut_saslogcheck(logfile=_default_,logref=_default_,outfile=_default_,
 outfileref=_default_,msgdata=_default_,out=_default_,debug=_default_);
/*soh***************************************************************************
Eli Lilly and Company - Global Statistical Sciences                    
CODE NAME           : ut_saslogcheck  
CODE TYPE           : Broad-use Module   
PROJECT NAME        : 
DESCRIPTION         : The ut_saslogcheck is a platform independent
                      macro that scans the SAS log for occurrences of
                      certain text messages (e.g. ERROR, WARNING, 
                      selected NOTEs, etc.) that may indicate a problem
                      with the code or the data, and produces a report
                      (summary and detail) of the findings.
SOFTWARE/VERSION#   : SAS v9.1.3 and SAS v9.2
INFRASTRUCTURE      : SDD v3.4 and MS Windows 
LIMITED-USE MODULES : N/A                
BROAD-USE MODULES   : none - this BUM was designed to be stand-alone
                       and not require other BUMs or data sets
INPUT               : A SAS log file as defined by the parameters
                       LOGFILE and LOGREF.  On MVS the log file is
                       found in the path referenced by the DDNAME 
                       altlog1.
                      A SAS data set named by the MSGDATA parameter
                       containing additional text strings to search for.
OUTPUT              : As defined by the parameters OUTFILE and
                       OUTFILEREF.  The default output is the SAS 
                       print file.
VALIDATION LEVEL    : 6                  
REQUIREMENTS        : /lillyce/qa/general/bums/ut_saslogcheck/documentation
                      ut_saslogcheck_rd.doc                   
ASSUMPTIONS         :  
  In MS Windows, a SAS configuration setting can cause a problem with
   the use of the DM command that this macro uses.  This applies when
   running SAS in display manager mode when your program uses the ODS
   statement.  To resolve the problem, start SAS display manager, click
   on "Tools ... Options ... Preferences".  When the resulting dialog
   box appears, click on "Results".  At the bottom of this dialog box
   select "Preferred web browser" in the "View results using:" section.
   If "Internal browser" is selected then SAS will not be able to 
   evaluate the contents of the log window when you call this macro

  In SDD the log is referenced by the fileref _idxlog_.  The SDD application
   defines this fileref - the user should not do so.
--------------------------------------------------------------------------------
BROAD-USE MODULE SPECIFIC INFORMATION:                       
BROAD-USE MODULE TEMPORARY OBJECT PREFIX: _CL                       
                      
  Parameters:
   Name     Type     Default  Description and Valid Values
  --------- -------- -------- -------------------------------------------------
   LOGFILE  optional          Full name of a file that contains a
                               SAS log
   LOGREF   optional          Fileref previously defined by a FILENAME
                               statement that points to a file
                               containing a SAS log
   OUTFILE  optional          The name of file to write the report to.
                               If this is not specified then the report 
                               will be written to the print file, except
                               for MVS when executing the saslchk JCL
                               procedure, in which case it will be 
                               written to the checklog ddname.
                               OUTPUT to PDS members is not supported
   OUTFILEREF optional        Fileref previously defined by a FILENAME
                               statement that points to a file where the
                               report will be written.
   MSGDATA  optional          Name of a data set that contains text strings
                               to search the log for.  These text strings
                               are added to the strings this macro searches
                               for.  This data set must contain a variable
                               named lookfor that is a character variable of
                               length 80.
   OUT      optional          Name of output data set containing information
                               also found in the report sent to OUTFILE or
                               OUTFILEREF.
   DEBUG    required 0        Specifies whether debug mode is on=1 or off=0
  -----------------------------------------------------------------------------
  Usage Notes:

       If neither LOGFILE nor LOGREF are specified then ...
        When running SAS for MS windows in DMS the contents of
         the log window in display manager is scanned by this macro.  Note 
         that SAS writes log lines to a buffer prior to writing those lines
         to the log window.  This may result in some of the most recent log
         lines to be in the buffer and not in the log window when
         ut_saslogcheck is called.  Thus, messages in these buffered log lines
         will not be reported.
        When running an SDD process the contents of the log file of the current
         process execution is scanned by this macro.

       The ddname/fileref "altlog1" is reserved for MVS and should not 
       be created by users.

       The code author will maintain the core list of text to be scanned
       for in the macro itself.  Additional text to be scanned for may
       optionally be defined by the user with the MSGDATA parameter.

       In MVS (batch and interactive), by using the SASLCHK
       JCL PROC and clist (see 'Typical macro call' below),
       the current SAS log is scanned as a second 'step' in
       the SAS session. There is therefore no need to specify
       the SAS log filename. In MVS the call to the SASLCHK
       macro is automatic and thus not explicitly coded by
       the user.

       The BUM macro does not call any utility BUM macros such as
       ut_parmdef or ut_logical.  This decision was made so that
       the ut_saslogcheck can stand alone and not require other macros
       to be executable.

  -----------------------------------------------------------------------------
  Typical Macro Call(s) and Description:

    MSWindows - %ut_saslogcheck(logfile=h:\myprogram.log)

                fileref mylog 'h:\myprogram.log';
    MSWindows - %ut_saslogcheck(logref=mylog)

    MSWindows - %ut_saslogcheck    in display manager

    SDD       -  %ut_saslogcheck   no parameters required when scanning your
                                   current process log.

    MSWindows from DOS prompt - you can create a bat file like this and run
     it as "saslchk <filename>" where saslchk is the bat file and 
     <filename> is the name of the log file (without the .log filetype)
 
        echo off
        set file=%~f1
        if "%~x1"=="" set file=%file%.log
        if not exist "%file%" (
         echo File does not exist param=%1 file=%file%
         goto end
        )
        echo Processing SAS log file %file%
        sas -initstmt "%%ut_saslogcheck(logfile=%file%); %%put Processed %file%;"
        :end

    MVS batch -
              //SAS        EXEC SASLCHK,SOUT=T
              //SYSPRINT   DD SYSOUT=*
              //SYSIN      DD *
              ...your...usual....SAS....code...;

    MVS interactive/TSO - Enter TSO or Workstation commands:
     ===>saslchk

--------------------------------------------------------------------------------
REVISION HISTORY SECTION:                 
                      
        Author &
  Ver#   Peer Reviewer   Request #         Broad-Use MODULE History Description
  ----  ---------------- ----------------- -------------------------------------
  1.0   Gregory Steffens BMRMSR28May2007   Original version of the broad-use
         Michael Fredericksen               module. This BUM started with the
                                            ut_sas8lchk BUM code - see that 
                                            BUM header for history of its code.
  2.0   Gregory Steffens BMRGCS27Feb2008   Added OUT parameter
         Craig Hansen                      Added segmentation violation to list
                                            of messages searched for
  3.0   Craig Hansen     BMRCSH01DEC2010d  Updated header to reflect code 
         Keyi Wu                            validated for SAS v9.2.  Modified
                                            header to maintain compliance with
                                            current SOP Code Header.
  **eoh************************************************************************/
%if %bquote(%upcase(&logfile))    = %upcase(_default_) %then %let logfile =;
%if %bquote(%upcase(&logref))     = %upcase(_default_) %then %let logref =;
%if %bquote(%upcase(&outfile))    = %upcase(_default_) %then %let outfile =;
%if %bquote(%upcase(&outfileref)) = %upcase(_default_) %then %let outfileref =;
%if %bquote(%upcase(&msgdata))    = %upcase(_default_) %then %let msgdata =;
%if %bquote(%upcase(&out))        = %upcase(_default_) %then %let out =;
%if %bquote(%upcase(&debug))      = %upcase(_default_) %then %let debug = 0;
%if %sysfunc(indexw(%str(Y T YES TRUE  ON  OUI JA),%upcase(&debug)))
 %then %let debug = 1;
%else %if %sysfunc(indexw(%str(N F NO  FALSE OFF NON NEIN),%upcase(&debug)))
 %then %let debug = 0;
%if &debug ^= 1 & &debug ^= 0 %then %do;
  %put UNOTE(ut_saslogcheck):
   INVALID LOGICAL VALUE OF DEBUG = %nrbquote(&debug);
  %let debug = 0;
%end;
%put (ut_saslogcheck) logfile=&logfile;
%put (ut_saslogcheck) logref=&logref;
%put (ut_saslogcheck) outfile=&outfile;
%put (ut_saslogcheck) outfileref=&outfileref;
%put (ut_saslogcheck) msgdata=&msgdata;
%put (ut_saslogcheck) debug=&debug;
%local options checklog lookfors mvs_saslchk_entry altlog1_ddname_path
 log_file_path rc i numtitles numfootnotes fid rc outfile_spec os sdd endmac
 userid;
%if &sysscp = SUN 4 | &sysscp = SUN 64 | &sysscp = RS6000 | &sysscp = ALXOSF |
 &sysscp = HP 300 | &sysscp = HP 800 | &sysscp = LINUX | &sysscp = RS6000 | 
 &sysscp = SUN 3 | &sysscp = ALXOSF %then %let os = unix;
%else %let os = %sysfunc(lowcase(&sysscp));
%if &sysver ^= 8.2 %then %do;
  %if %symglobl(_sddusr_) | %symglobl(_sddprc_) | %symglobl(sddparms) %then
   %let sdd = 1;
  %else %let sdd = 0;
%end;
%else %let sdd = 0;
%let endmac = 0;
%*-----------------------------------------------------------------------------;
%* Save original values of changed options.;
%*-----------------------------------------------------------------------------;
%let options = %sysfunc(getoption(formdlim));
%let options = formdlim="&options";
%let options = &options 
 %sysfunc(getoption(center))
 %sysfunc(getoption(caps))
 %sysfunc(getoption(sgen))
 %sysfunc(getoption(pageno,keyword))
 %sysfunc(getoption(date))
 %sysfunc(getoption(notes))
 %sysfunc(getoption(mprint))
 %sysfunc(getoption(source))
 %sysfunc(getoption(source2))
 %sysfunc(getoption(mlogic))
;
%if ^ &debug %then %do;
  options nomprint nosource nosource2 nomlogic nonotes;
%end;
options FORMDLIM='-' nocenter nosgen pageno=1 nodate;
*==============================================================================;
* Save pre-existing titles and foonotes for later restoration;
*  and clear all title and footnote lines;
*==============================================================================;
proc sql;
  create table _cltitles as select * from dictionary.titles;
quit;
%let numtitles = 0;
%let numfootnotes = 0;
data _null_;
  if eof then do;
    call symput('numtitles',trim(left(put(title_num,2.0))));
    call symput('numfootnotes',trim(left(put(footnote_num,2.0))));
  end;
  set _cltitles end=eof;
  if type = 'T' then do;
    title_num + 1;
    if index(text,'"') <= 0 then
     call symput('title' || trim(left(put(title_num,2.0))),
     'title' || trim(left(put(number,2.0))) || ' "' || trim(text) || '"');
    else if index(text,"'") <= 0 then
     call symput('title' || trim(left(put(title_num,2.0))),
     'title' || trim(left(put(number,2.0))) || " '" || trim(text) || "'");
    else call symput('title' || trim(left(put(title_num,2.0))),
     'title' || trim(left(put(number,2.0))) || ' ' || trim(text));
  end;
  else if type = 'F' then do;
    footnote_num + 1;
    if index(text,'"') <= 0 then
     call symput('footnote' || trim(left(put(footnote_num,2.0))),
     'footnote' || trim(left(put(number,2.0))) || ' "' || trim(text) || '"');
    else if index(text,"'") <= 0 then
     call symput('footnote' || trim(left(put(footnote_num,2.0))),
     'footnote' || trim(left(put(number,2.0))) || " '" || trim(text) || "'");
    else call symput('footnote' || trim(left(put(footnote_num,2.0))),
     'footnote' || trim(left(put(number,2.0))) || ' ' || trim(text));
  end;
run;
%if &numtitles > 0 %then %do;
  title;
%end;
%if &numfootnotes > 0 %then %do;
  footnote;
%end;
%*-----------------------------------------------------------------------------;
%* Verify LOGFILE and LOGREF parameters;
%*-----------------------------------------------------------------------------;
%if %bquote(&logfile) ^= %then %do;
  %if &sdd %then %do;
    %put UWARNING(ut_saslogcheck): The LOGFILE parameter is not supportable in
     SDD logfile=&logfile;
    %if %bquote(&logref) = %then %do;
      %put UWARNING(ut_saslogcheck): The LOGREF parameter is also null;
      %let endmac = 1;
      %goto endmac;
    %end;
  %end;
  %else %if ^ %sysfunc(fileexist(&logfile)) %then %do;
    %put UWARNING(ut_saslogcheck): specified log file does not exist
     &logfile;
    %let endmac = 1;
    %goto endmac;
  %end;
%end;
%if %bquote(&logref) ^= %then %do;
  %let rc = %sysfunc(fileref(&logref));
  %if &debug %then
   %put UNOTE(ut_saslogcheck): logref fileref (&logref) exist rc=&rc;
  %if &rc < 0 %then %do;
    %put UWARNING(ut_saslogcheck): specified log fileref exists but the
     file it points to does not exist - &logref;
    %let endmac = 1;
    %goto endmac;
  %end;
  %if &rc > 0 %then %do;
    %put UWARNING(ut_saslogcheck): specified log fileref does not exist
     &logref;
    %let endmac = 1;
    %goto endmac;
  %end;
%end;
%if %bquote(&logfile) ^= & %bquote(&logref) ^= %then %do;
  %put UNOTE(ut_saslogcheck): LOGFILE and LOGREF parameters have both
   been specified - at most one should be specified;
%end;
*------------------------------------------------------------------------------;
*                                                                      ;
* Determine Operating system and assign appropriate                    ;
* output destination.                                                  ;
%*                                                                     ;
%* MVS will write LOG scan report to fileref CHECKLOG                  ;
%* to be viewed in IOF.                                                ;
%* W2K will write report to PRINT fileref.                             ;
*------------------------------------------------------------------------------;
%if &sysscp = OS %then %do;
  *----------------------------------------------------------------------------;
  *                                                                    ;
  * In MVS, determine if user invoked SAS via the standard SAS clist   ;
  * or by using the SASLCHK clist. The SASLCHK clist                   ;
  * allocates an eyecatcher file with fileref/ddname                   ;
  * altlog1. A non-blank value for this PATHNAME                       ;
  * indicates entry via SASLCHK clist, which enables                   ;
  * the automatic SAS log checking and exit. Use of the                ;
  * ut_saslogcheck macro is therefore possible in normal SAS           ;
  * entry.                                                             ;
  *                                                                    ;
  *----------------------------------------------------------------------------;
  option caps;
  %let altlog1_ddname_path = %sysfunc(pathname(altlog1));
  *----------------------------------------------------------------------------;
  *                                                                    ;
  * If macro variable altlog1_ddname_path is blank, then the user      ;
  * is using the std SAS clist. Otherwise, the user                    ;
  * is using the SASLCHK clist. If they are using the                  ;
  * SAS clist, then allow use of the SASLCHK macro                     ;
  * just like W2K by using the macro variables                         ;
  * LOGREF or LOGFILE passed by the user.                              ;
  *                                                                    ;
  *----------------------------------------------------------------------------;
  %if %bquote(&altlog1_ddname_path) = %then %do;  /* Entry via SAS    */
    %if %bquote(&logfile) ne %then %do;         /* Use user logfile   */
      filename altlog1 "&logfile" disp=shr;
    %end;
    %let mvs_saslchk_entry = 0;
    %let checklog = print;                      /* Output to PRINT    */
  %end;
  %else %do;                                    /* Entry via SASLCHK  */
    %let mvs_saslchk_entry = 1;
    %let checklog = checklog;
  %end;
%end;
%else %if &sysscp = WIN %then %do;
  %if %bquote(&logfile) ^=  %then %do;
    filename altlog1 "&logfile";
  %end;
  %let checklog = print;
  %let mvs_saslchk_entry = 0;
%end;
%else %if &os = unix %then %do;
  %if %bquote(&logfile) ^=  %then %do;
    filename altlog1 "&logfile";
  %end;
  %let checklog = print;
  %let mvs_saslchk_entry = 0;
%end;
%else %do;
  %put UNOTE(ut_saslogcheck): operating system not recognised = &sysscp;
  %let endmac = 1;
  %goto endmac;
%end;
%* ----------------------------------------------------------------------------;
%* Define output file specification where report will be written;
%* ----------------------------------------------------------------------------;
%if %bquote(&outfile) = & %bquote(&outfileref) = %then %do;
  %let outfile_spec = &checklog;
%end;
%else %if %bquote(&outfileref) ^= %then %do;
  %let outfile_spec = &outfileref;
%end;
%else %if %bquote(&outfile) ^= %then %do;
  %let outfile_spec = "&outfile";
%end;
%*-----------------------------------------------------------------------------;
%* If LOGREF and LOGFILE are both absent, then write log window to;
%* a temporary file for input to the macro. This action is;
%* only necessary if the user is NOT using the SASLCHK clist;
%* (or batch) on MVS and is not in SDD where the default log location;
%* is reference by the fileref _ibxlog_.;
%*-----------------------------------------------------------------------------;
%if %bquote(&logref) = & %bquote(&logfile) = & ^ &mvs_saslchk_entry %then %do;
  %if &sysprocessname = %str(DMS Process) %then %do;
    filename _lclchk temp;
    dm log 'log; file _lclchk replace';
    %let logref = _lclchk;
    %if &debug %then %do;
      filename _lclchk list;
      data _null_;
        infile _lclchk;
        input;
        put 'UNOTE(ut_saslogcheck): debug ' _infile_;
      run;
    %end;
  %end;
  %else %if &sdd %then %do;
    %let logref = _ibxlog_;
  %end;
  %else %do;
    %put UNOTE(ut_saslogcheck): neither LOGFILE nor LOGREF parameters
     have been specified - one must be specified when not executing
     in display manager or SDD;
    %let endmac = 1;
    %goto endmac;
  %end;
%end;
%if %bquote(&logref) ^= %then
 %let log_file_path = %sysfunc(pathname(&logref));
%else %if %bquote(&logfile) ^= %then %let log_file_path = &logfile;
%if &sdd %then %do;
  %let log_file_path = &_sddprc_;
  %if %index(&log_file_path,_ from SAS) > 0 %then %let log_file_path
   = %substr(&log_file_path,1,%eval(%index(&log_file_path,_ from SAS) - 1));
  %let userid = &_sddusr_;
%end;
%else %let userid = &sysuserid;
%*=============================================================================;
%* Verify that the log file can be opened in read mode;
%*=============================================================================;
%if &logref ^= %then %do;     /* Use user logref if supplied */
  %let fid = %sysfunc(fopen(&logref,i));
%end;
%else %do;                    /* else use logfile file       */
  %let fid = %sysfunc(fopen(altlog1,i));
%end;
%if &debug %then %put fid = &fid;
%if &fid > 0 %then %do;
  %let rc = %sysfunc(fclose(&fid));
  %if &debug %then %put close rc=&rc;
%end;
%else %do;
  data _null_;
    file &outfile_spec;
    date = today();
    time = time();
    put "SAS LOG FILE SCANNED &log_file_path";
    %if &sysscp = OS  %then %do;
      put @3 "Jobname:                   &sysjobid";
    %end;
    put @3 "User                     : &userid";
    put @3 "Date(of SCAN)            : " date date9.;
    put @3 "Time(of SCAN)            : " time time8.0;
    put @3 "Operating System(of SCAN): &sysscp &sysscpl"
      %if &sdd %then %do;
        " SDD - SAS Drug Development"
      %end;
    ;
    put @3 "SAS Version(of SCAN)     : &sysver";
    put //// @ 20 'Unable to open log file.  Log check not performed.';
    stop;
  run;
  %let endmac = 1;
  %goto endmac;
%end;
*------------------------------------------------------------------------------;
*                                                                      ;
* Create a data set containing things to look for in the log.          ;
*                                                                      ;
* Each text string will be assigned to a macro variable                ;
* (lookfor1, lookfor2, lookfor3, etc).                                 ;
*                                                                      ;
*------------------------------------------------------------------------------;
data _clsrchfor;
  length lookfor $ 80. count 8;
  count = 0;
  lookfor = 'er' || 'ror';                                       output;
  lookfor = 'war' || 'ning';                                     output;
  lookfor = 'unin' || 'itialized';                               output;
  lookfor = 'mis' || 'sing values were generated';               output;
  lookfor = 'uer' || 'ror';                                      output;
  lookfor = 'more th' || 'an one data set with repeats of BY values';
                                                                 output;
  lookfor = 'arg' || 'ument to function';                        output;
  lookfor = 'inva' || 'lid argument';                            output;
  lookfor = 'exper' || 'imental in release';                     output;
  lookfor = 'valu' || 'es have been converted to';               output;
  lookfor = 'mathema' || 'tical operations could not be performed';
                                                                 output;
  lookfor = 'lost ' || 'card';                                   output;
  lookfor = 'not' || ' found';                                   output;
  lookfor = 'not' || ' previously';                              output;
  lookfor = '_error_' || '=1';                                   output;
  lookfor = 'end' || 'sas';                                      output;
  lookfor = 'uwar' || 'ning';                                    output;
  lookfor = 'division by' || ' zero detected';                   output;
  lookfor = 'sas went' || ' to a new line';                      output;
  lookfor = 'in' || 'valid numeric data';                        output;
  lookfor = 'On' || 'e or more lines were truncated';            output;
  lookfor = 'format was too' ||' small for the number to be printed';
                                                                 output;
  lookfor = 'shifted' || ' by the ""best"" format';              output;
  lookfor = 'note: format' || 'ted values of';                   output;
  lookfor = 'could not' || ' be written';                        output;
  lookfor = 'SAS System' || ' stopped processing this step';     output;
  lookfor = 'already' || ' exists';                              output;
  lookfor = 'does not' || ' exist';                              output;
  lookfor = 'outside the' || ' axis range';                      output;
  lookfor = 'The meaning of an identifier' ||
  ' after a quoted string may change';                           output;
  lookfor = 'abnor' || 'mally terminated';                       output;
  lookfor = 'Segment' || 'ation Violation';                      output;
  stop;
run;
%if %bquote(&msgdata) ^= %then %do;
  %if %sysfunc(exist(&msgdata)) %then %do;
    data _clsrchfor;
      set _clsrchfor  &msgdata (keep=lookfor);
      count = 0;
    run;
  %end;
  %else %do;
    %put;
    %put (ut_saslogcheck) the MSGDATA data set does not exist - msgdata=&msgdata;
    %put;
    data _null_;
      file &outfile_spec;
      put
       "(ut_saslogcheck) the MSGDATA data set does not exist - msgdata=&msgdata";
      stop;
    run;
  %end;
%end;
proc sort data = _clsrchfor;
  by lookfor;
run;
%let lookfors = 0;
data _clsrchfor;
  set _clsrchfor end=last;
  if lookfor ^= ' ';
  lookfor = upcase(lookfor);
  looknum + 1;
  call symput('lookfor' || trim(left(put(looknum,8.0))),trim(left(lookfor)));
  if last then call symput('lookfors',trim(left(put(looknum,8.0))));
  lookfor = tranwrd(lookfor,'""BEST""','"BEST"');
  drop looknum;
run;
%if &debug %then %do;
  %put lookfors=&lookfors;
  %do i = 1 %to &lookfors;
    %put lookfor&i=&&lookfor&i;
  %end;
  %put;
%end;
data _cllines (keep=logrec logrecline)
     _clmsg (keep=date time msg_found logrecline);
  date = today();
  time = time();
  length msg msg_found $80.;
  %if &logref ^= %then %do;     /* Use user logref if supplied */
    infile &logref end=last missover length=lv;
  %end;
  %else %do;                    /* else use logfile file       */
    infile altlog1 end=last missover length=lv;
  %end;
  input @1 logrec $varying132. lv;
  %if &debug %then %do;
    file log;
    if _n_ = 1 then put 'UNOTE(ut_saslogcheck): starting debug list of log file:'/;
    put _infile_;
    if last then put 'UNOTE(ut_saslogcheck): ending debug list of log file:'/;
  %end;
  file &outfile_spec;
  if _n_ = 1 then do;
    put "SAS LOG FILE SCANNED &log_file_path";
    %if &sysscp = OS  %then %do;
      put @3 "Jobname:                   &sysjobid";
    %end;
    put @3 "User                     : &userid";
    put @3 "Date(of SCAN)            : " date date9.;
    put @3 "Time(of SCAN)            : " time time8.0;
    put @3 "Operating System(of SCAN): &sysscp &sysscpl"
      %if &sdd %then %do;
        " SDD - SAS Drug Development"
      %end;
    ;
    put @3 "SAS Version(of SCAN)     : &sysver";
    put ;
  end;
  logrecline = _n_;
  badrec = 0;
  *----------------------------------------------------------------------------;
  * Scan for er-ror and wa-rning in column 1 only;
  * Scan for other messages anywhere in the log line;
  *----------------------------------------------------------------------------;
  %do i = 1 %to &lookfors;
    *--------------------------------------------------------------------------;
    %bquote(* Message &i;)
    *--------------------------------------------------------------------------;
    msg = "%substr(&&lookfor&i,1,2)" || "%substr(&&lookfor&i,3)";
    found_at = index(upcase(logrec),trim(msg));
    msg_found = ' ';
    if found_at in (1 2) and ((msg = 'ER' || 'ROR' | msg = 'WAR' || 'NING')
     & upcase(left(logrec)) ^=: 'UER' ||'ROR' &
     upcase(left(logrec)) ^=: 'UWA' || 'RNING'
     & upcase(left(logrec)) ^=: '_ER' ||'ROR_=')
     then do;
      if index(logrec,trim(msg)) in (1 2) then do;
        msgs_found + 1;
        if index(upcase(logrec),'PRODUCT WITH' || ' WHICH') = 0 &
         index(upcase(logrec),'SCHEDULED TO' || ' EXPIRE') = 0 then
         msg_found = msg;
        else msg_found = 'License Expiration';
        if ^ badrec then do;
          recs_found + 1;
          badrec = 1;
          if index(upcase(logrec),'PRODUCT WITH' || ' WHICH') = 0 &
           index(upcase(logrec),'SCHEDULED TO' || ' EXPIRE') = 0 then
           output _cllines;
        end;
      end;
    end;
    else if found_at ge 1 and
     (msg ^= 'ER' || 'ROR' and MSG ^= 'WAR' || 'NING') then do;
      msgs_found + 1;
      msg_found = msg;
      if ^ badrec then do;
        recs_found + 1;
        badrec = 1;
        output _cllines;
      end;
    end;
    if msg_found ^= ' ' then output _clmsg;
  %end;
  if last then do;
    put 'Total log file lines read                                ' _n_;
    if . < recs_found < 1 & . < msgs_found < 1 then
     put 'No searched messages found.';
    else put      'Number of lines containing at least one searched message '
     recs_found / 'Number of searched messages found                        '
     msgs_found // ;
    %if %bquote(&out) ^= %then %do;
      call symput('total_log_lines',trim(left(put(_n_,32.0))));
      call symput('recs_found',trim(left(put(max(recs_found,0),32.0))));
      call symput('msgs_found',trim(left(put(max(msgs_found,0),32.0))));
    %end;
  end;
run;
proc freq data=_clmsg;
  tables msg_found / noprint out=_clmsg_found(keep=msg_found count);
run;
proc sort data = _clsrchfor;
  by lookfor;
run;
%if &debug %then %do;
  proc print data = _clmsg  width=minimum;
    title '(ut_saslogcheck) debug: _clmsg data set';
  run;
  proc print data = _clmsg_found  width=minimum;
    title '(ut_saslogcheck) debug: _clmsg_found data set';
  run;
  proc print data = _clsrchfor  width=minimum;
    title '(ut_saslogcheck) debug: _clsrchfor data set';
  run;
  title;
%end;
data _clmsg_found;
  merge _clsrchfor (rename=(lookfor=msg_found))  _clmsg_found;
  by msg_found;
run;
proc sort data = _clmsg_found;
  by descending count msg_found;
run;
%if &outfile_spec ^= print %then %do;
  proc printto print = &outfile_spec;
  run;
%end;
proc print noobs data=_clmsg_found label;
  label msg_found='Searched Message'
   count = 'Frequency';
run;
data _null_;
  file print;
  if eof then do;
    if _n_ = 1 then
     put //// @20 'N o    s e a r c h e d    m e s s a g e s    f o u n d  !';
  end;
  set _cllines  end=eof;
  if _n_ <= 1000 then put @2 'Record=' logrecline '-->' / logrec /;
  else do;
    put // @20 'Further records will not be printed';
    stop;
  end;
  run;
%if &outfile_spec ^= print %then %do;
  proc printto
   %if &sdd %then %do;
     print = _ibxout_
   %end;
  ;
  run;
%end;
%if %bquote(&out) ^= %then %do;
  *----------------------------------------------------------------------------;
  * Create output data set;
  *----------------------------------------------------------------------------;
  data &out;
    userid          = "&userid";
    sysscp          = "&sysscp &sysscpl";
    sdd             = "&sdd";
    sysver          = "&sysver";
    log_file_path   = "&log_file_path";
    %if %sysfunc(exist(work._cllines)) %then %do;
      total_log_lines = &total_log_lines;
      recs_found      = &recs_found;
      msgs_found      = &msgs_found;
      if eof & _n_ = 1 then do;
        date = date();
        time = time();
        output;
      end;
      merge _clmsg _cllines end=eof;
      by logrecline;
      output;
    %end;
    %else %do;
      total_log_lines = 0;
      recs_found      = .;
      msgs_found      = .;
      output;
      stop;
    %end;
    format date date9. time time8.;
    label
     date          = ''
     time          = ''
     userid        = ''
     sysscp        = ''
     sdd           = ''
     sysver        = ''
     log_file_path = ''
     total_log_lines = ''
     recs_found    = ''
     msgs_found    = ''
     msg_found     = ''
     logrec        = ''
     logrecline    = ''
    ;
    keep date time userid sysscp sdd sysver log_file_path
     total_log_lines recs_found msgs_found msg_found logrec logrecline;
  run;
%end;
*------------------------------------------------------------------------------;
* Check for OS before clearing a fileref. You cannot clear a;
* fileref that was assigned via JCL (you will get a warning).;
* Only do the FILENAME CLEAR in MVS if it is a non-temp dataset.;
* A temporary data set (i.e. JCL defined) will begin with SYS.;
*------------------------------------------------------------------------------;
%if &sysscp = OS %then %do;
  %if %substr(%str(&altlog1_ddname_path   ),1,3) ^= SYS %then %do;
    %if %sysfunc(fileref(altlog1)) <= 0 %then %do;
      filename altlog1 clear;
    %end;
  %end;
%end;
%else %if &sysscp = WIN | &os = unix %then %do;
  %if %sysfunc(fileref(altlog1)) <= 0 %then %do;
    filename altlog1 clear;
  %end;
%end;
%endmac:
%if &endmac %then %put UWARNING(ut_saslogcheck) Ending macro execution;
*------------------------------------------------------------------------------;
* Return options to their original value.;
*------------------------------------------------------------------------------;
proc datasets lib = work nolist;
  delete _cl:;
run; quit;
%if &sysscp = OS & &sysenv = FORE & &mvs_saslchk_entry = 1 %then %do;
  *----------------------------------------------------------------------------;
  * If OS is MVS and environment is foreground,;
  * and we are in the SASLCHK clist, then ENDSAS.;
  *----------------------------------------------------------------------------;
  endsas;
%end;
%if &numtitles > 0 %then %do i = 1 %to &numtitles;
  &&title&i;
%end;
%if &numfootnotes > 0 %then %do i = 1 %to &numfootnotes;
  &&footnote&i;
%end;
options &options;
%mend;
/******PACMAN****** DO NOT EDIT BELOW THIS LINE ******PACMAN******/
/*<?xml version="1.0" encoding="UTF-8"?>*/
/*<process sessionid="186793e:12512463a02:58c5" sddversion="3.4" cdvoption="N" parseroption="B">*/
/* <parameters>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LOGFILE" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="1">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LOGREF" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="2">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OUTFILE" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="3">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OUTFILEREF" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="4">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="MSGDATA" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="5">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OUT" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="6">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="DEBUG" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="7">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OPTIONS" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="8">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="CHECKLOG" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="9">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LOOKFORS" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="10">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="MVS_SASLCHK_ENTRY" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="11">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="ALTLOG1_DDNAME_PATH" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="12">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LOG_FILE_PATH" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="13">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="RC" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="14">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="I" maximum="9999999" advanced="N" enable="Y" obfuscate="N" tabname="Parameters" minimum="-9999999" numtype="real" resolution="INPUT" protect="N" label="Numeric field" required="Y"*/
/*   type="NUMERIC" order="15">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="NUMTITLES" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="16">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="NUMFOOTNOTES" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="17">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="FID" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="18">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OUTFILE_SPEC" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="19">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="OS" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="20">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="SDD" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="21">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="ENDMAC" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="22">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="USERID" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="23">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_SDDPRC_" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="24">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="_SDDUSR_" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="25">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="LOOKFOR" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="26">*/
/*  </parameter>*/
/*  <parameter id="TOTAL_LOG_LINES" resolution="INTERNAL" type="TEXT" order="27">*/
/*  </parameter>*/
/*  <parameter id="RECS_FOUND" resolution="INTERNAL" type="TEXT" order="28">*/
/*  </parameter>*/
/*  <parameter id="MSGS_FOUND" resolution="INTERNAL" type="TEXT" order="29">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="TITLE" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y" type="TEXT"*/
/*   order="30">*/
/*  </parameter>*/
/*  <parameter canlinktobasepath="N" dependsaction="ENABLE" id="FOOTNOTE" cdvenable="Y" cdvrequired="Y" advanced="N" enable="Y" obfuscate="N" maxlength="256" tabname="Parameters" resolution="INPUT" protect="N" label="Text field" required="Y"*/
/*   type="TEXT" order="31">*/
/*  </parameter>*/
/* </parameters>*/
/*</process>*/
/**/
/******PACMAN******************************************PACMAN******/
