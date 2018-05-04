%macro miglogchk(setup=%str(setup.sas),
                 setupdir=&_PROJPRE.&_SUFFIX.,
                 exclude=%str(_DBREV _DATADM _DATARAW _DATASTAT _MACROS),
                 papersz=A4);
%******************************************************************************;
%*                          PAREXEL INTERNATIONAL                              ;
%*                                                                             ;
%* CLIENT:            PAREXEL                                                  ;
%*                                                                             ;
%* PROJECT:           SAS standard log checking macro                          ;
%*                                                                             ;
%* TIMS CODE:         80386                                                    ;
%*                                                                             ;
%* SOPS FOLLOWED:     1213                                                     ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* PROGRAM NAME:      miglogchk.sas                                         
%*                                                                             ;
%* PROGRAM LOCATION:  /opt/pxlcommon/stats/macros/sas/code/miglogchk/ver004/;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* USER REQUIREMENTS: (1) Scan log files in defined directories for a wide     ;
%*                        range of SAS errors, warnings and notes, as follows: ;
%*                                                                             ;
%*                        ABNORMALLY TERMINATED, ANNOTATION, APPARENT,         ;
%*                        CONVERSION, CONVERTED, ERROR, EXTRANEOUS, HARD CODE, ;
%*                        HARD-CODE, HARDCODE, IN ANNOTATE, INVALID,           ;
%*                        MERGE STATEMENT, MULTIPLE, NOT EXIST, NOT RESOLVED,  ;
%*                        NOTE: THE SAS SYSTEM, OUTSIDE, REPLACED,             ;
%*                        SAS SET OPTION OBS=0, SAS WENT, STOPPED, TOO LONG,   ;
%*                        TRUNCATED, UNINIT, UNKNOWN, W.D FORMAT, WARNING,     ;
%*                        WHERE CLAUSE, _ERROR_.                               ;
%*                                                                             ;
%*                    (2) Scan all directories listed in the study-specific    ;
%*                        SETUP program.  Provide the option to exclude        ;
%*                        specific directories.                                ;
%*                                                                             ;
%*                    (3) Report a summary of the number of each category of   ;
%*                        issue found.                                         ;
%*                                                                             ;
%*                    (4) Report a full listing of all directories searched    ;
%*                        and the issues found in each log file.               ;
%*                                                                             ;
%*                    (5) The program must be executable in Windows, VMS and   ;
%*                        Unix programming environments in accordance with     ;
%*                        the timing specified in the Migration Plan.          ;
%*                                                                             ;
%* TECHNICAL          Refer to comments in code.                               ;
%* SPECIFICATIONS:                                                             ;
%*                                                                             ;
%* INPUT:             Macro parameter definition:                              ;
%*                                                                             ;
%*                 SETUP    =   Name of the study specific setup program that  ;
%*                              defines the project programming environment.   ;
%*                              <default = setup.sas>                          ;
%*                              NB: Unix file and directory names are case     ;
%*                              sensitive.                                     ;
%*                                                                             ;
%*                 SETUPDIR =   Full path specifying location of the project   ;
%*                              SETUP.SAS program.                             ;
%*                              <default = &_PROJPRE.&_SUFFIX>                 ;
%*                              NB: Unix file and directory names are case     ;
%*                              sensitive.                                     ;
%*                                                                             ;
%*                 EXCLUDE    = List of directories to exclude from the search.;
%*                              The standard setup program creates macro       ;
%*                              parameters for each directory path that is     ;
%*                              defined in the project environment. To exclude ;
%*                              directories from the search specify the macro  ;
%*                              parameter names, separated by a single space,  ;
%*                              in this parameter.                             ;
%*                              <default = _DBREV _DATADM _DATARAW _DATASTAT   ;
%*                                         _MACROS>                            ;
%*                                                                             ;
%*                 PAPERSZ    = Paper size for output file. Options:           ;
%*                                                                             ;
%*                                A4 <default>                                 ;
%*                                LETTER                                       ;
%*                                                                             ;
%* OUTPUT:            Summary and detailed reports are written to the SAS      ;
%*                    Output window.                                           ;
%*                                                                             ;
%* PROGRAMS CALLED:   None.                                                    ;
%*                                                                             ;
%* ASSUMPTIONS/       The standard project environment setup program must be   ;
%* REFERENCES:        created. Within this program, macro parameters must be   ;
%*                    defined for each directory path using the methodology    ;
%*                    defined within the standard project environment setup    ;
%*                    program.                                                 ;
%*                                                                             ;
%******************************************************************************;
%*                                                                             ;
%* MODIFICATION HISTORY                                                        ;
%*-----------------------------------------------------------------------------;
%* VERSION:           1                                                        ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          High   [X]: System has direct impact on the provision of ;
%*                                business critical services either globally   ;
%*                                or at a regional level.                      ;
%*                    Medium [ ]: System has direct impact on the provision of ;
%*                                business critical services at a local level  ;
%*                                only.                                        ;
%*                    Low    [ ]: System used to indirectly support the        ;
%*                                provision of a business critical service or  ;
%*                                operation at a global, regional or local     ;
%*                                level.                                       ;
%*                    None   [ ]: System has no impact on the provision of a   ;
%*                                business critical service or operation.      ;
%*                                                                             ;
%* Regulatory:        High   [ ]: System has a direct impact on GxP data and/  ;
%*                                or directly supports a GxP process.          ;
%*                    Medium [x]: System has an indirect impact on GxP data    ;
%*                                and supports a GxP process.                  ;
%*                    Low    [ ]: System has an indirect impact on GxP data or ;
%*                                supports a GxP process.                      ;
%*                    None   [ ]: System is not involved directly or           ;
%*                                indirectly with GxP data or a GxP process.   ;
%*                                                                             ;
%* TESTING            peer code review and review of the test output           ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         SANDY MEEK                        Date : 11MAY2005       ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     PHIL RILEY                        Date : 04OCT2005       ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              PHIL RILEY                        Date : 04OCT2005       ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           2                                                        ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          High   [X]: System has direct impact on the provision of ;
%*                                business critical services either globally   ;
%*                                or at a regional level.                      ;
%*                    Medium [ ]: System has direct impact on the provision of ;
%*                                business critical services at a local level  ;
%*                                only.                                        ;
%*                    Low    [ ]: System used to indirectly support the        ;
%*                                provision of a business critical service or  ;
%*                                operation at a global, regional or local     ;
%*                                level.                                       ;
%*                    None   [ ]: System has no impact on the provision of a   ;
%*                                business critical service or operation.      ;
%*                                                                             ;
%* Regulatory:        High   [ ]: System has a direct impact on GxP data and/  ;
%*                                or directly supports a GxP process.          ;
%*                    Medium [X]: System has an indirect impact on GxP data    ;
%*                                and supports a GxP process.                  ;
%*                    Low    [ ]: System has an indirect impact on GxP data or ;
%*                                supports a GxP process.                      ;
%*                    None   [ ]: System is not involved directly or           ;
%*                                indirectly with GxP data or a GxP process.   ;
%*                                                                             ;
%* REASON FOR CHANGE: (1) Macro parameter added (SETUPDIR) to allow the        ;
%*                        location of the SETUP.SAS program to be specified    ;
%*                        differently from the default. This is required to    ;
%*                        allow flexibility in the macro usage and remove the  ;
%*                        need for SETUP.SAS to be placed in the root of the   ;
%*                        project directory.                                   ;
%*                                                                             ;
%*                    (2) Error in presentation of number of errors in each    ;
%*                        category versus line numbers corrected.              ;
%*                                                                             ;
%*                    (3) Removal of VMS code as PAREXEL no longer support SAS ;
%*                        on this platform.                                    ;
%*                                                                             ;
%*                    (4) Code added to allow programmer defined errors,       ;
%*                        identified by [PXL], to be identified on the program ;
%*                        output                                               ;
%*                                                                             ;
%*                    (5) Code used to remove unwanted SAS ERRORS/WARNINGS     ;
%*                        that appear during batch execution of programs moved ;
%*                        within program. Previously, where this code was      ;
%*                        placed prevented files that had no other errors      ;
%*                        being reported correctly.                            ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output           ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         SANDY MEEK                        Date : 20-JUN-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     ANDREW COLTMAN                    Date : 21-JUN-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              ANDREW COLTMAN                    Date : 21-JUN-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           3                                                        ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          High   [X]: System has direct impact on the provision of ;
%*                                business critical services either globally   ;
%*                                or at a regional level.                      ;
%*                    Medium [ ]: System has direct impact on the provision of ;
%*                                business critical services at a local level  ;
%*                                only.                                        ;
%*                    Low    [ ]: System used to indirectly support the        ;
%*                                provision of a business critical service or  ;
%*                                operation at a global, regional or local     ;
%*                                level.                                       ;
%*                    None   [ ]: System has no impact on the provision of a   ;
%*                                business critical service or operation.      ;
%*                                                                             ;
%* Regulatory:        High   [ ]: System has a direct impact on GxP data and/  ;
%*                                or directly supports a GxP process.          ;
%*                    Medium [X]: System has an indirect impact on GxP data    ;
%*                                and supports a GxP process.                  ;
%*                    Low    [ ]: System has an indirect impact on GxP data or ;
%*                                supports a GxP process.                      ;
%*                    None   [ ]: System is not involved directly or           ;
%*                                indirectly with GxP data or a GxP process.   ;
%*                                                                             ;
%* REASON FOR CHANGE: (1) Correction of a formatting error where errors on     ;
%*                        multiple lines are indicated by a series of dots     ;
%*                        (.....). It should only be presented once per error, ;
%*                        but is occassionally being presented multiple times. ;
%*                                                                             ;
%*                    (2) V2: Code used to remove unwanted SAS ERRORS/WARNINGS ;
%*                        that appear during batch execution of programs moved ;
%*                        within program.                                      ;
%*                        An additional error encountered during batch         ;
%*                        execution of programs in Unix that is reported at    ;
%*                        the foot of each log file when errors are found at   ;
%*                        any point in the log file.                           ;
%*                                                                             ;
%*                    (3) The output requires a review/sign-off line on each   ;
%*                        page, and facility to comment on issues found.       ;
%*                                                                             ;
%*                    (4) Output format converted to RTF with use of ODS.      ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output           ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         SANDY MEEK                        Date : 24-NOV-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Paul Walters                      Date : 30-Nov-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Paul Walters                      Date : 30-Nov-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           3.1                                                      ;
%*                                                                             ;
%* REASON FOR CHANGE: Default value for the setupdir parameter was incorrectly ;
%*                    changed as part of the version 3 updates. Value returned ;
%*                    to the default value specified in the earlier version.   ;
%*                                                                             ;
%* RISK ASSESSMENT:   None. The default value set in v3 is incorrect and based ;
%*                    on the set-up of a non-standard project. Returning the   ;
%*                    default value to the previous correct value means that   ;
%*                    exisiting miglogchk macro calls can remain unaltered.    ;
%*                                                                             ;
%* TESTING            No testing required                                      ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         SANDY MEEK                        Date : 06-DEC-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Paul Walters                      Date : 06-DEC-2006     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Not applicable                    Date :                 ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%*                                                                             ;
%* VERSION:           4                                                        ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          Yes [X]: The Computerized System has significant impact  ;
%*                             on business critical services or processes.     ;
%*                    No  [ ]: The Computerized System has no significant      ;
%*                             impact on business critical servizes or         ;
%*                             processes.                                      ;
%*                                                                             ;
%* Regulatory:        Yes [X]: The Computerized System has significant impact  ;
%*                             on GxP data and/ or supports a GxP process.     ;
%*                    No  [ ]: The Computerized System is not involved         ;
%*                             directly or indirectly with GxP data or a GxP   ;
%*                             process.                                        ;
%*                                                                             ;
%* REASON FOR CHANGE: 1) include log file date into report                     ;
%*                    2) exclude keywords in comments and strings              ;
%*                    3) produce output as landscaped pdf document             ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output           ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         Michael Cartwright                Date : 18-SEP-2007     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Karl Neufeldt                     Date : 07-JAN-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Chris Speck                       Date :   -JAN-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           4.1                                                      ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          Yes [X]: The Computerized System has significant impact  ;
%*                             on business critical services or processes.     ;
%*                    No  [ ]: The Computerized System has no significant      ;
%*                             impact on business critical servizes or         ;
%*                             processes.                                      ;
%*                                                                             ;
%* Regulatory:        Yes [X]: The Computerized System has significant impact  ;
%*                             on GxP data and/ or supports a GxP process.     ;
%*                    No  [ ]: The Computerized System is not involved         ;
%*                             directly or indirectly with GxP data or a GxP   ;
%*                             process.                                        ;
%*                                                                             ;
%* REASON FOR CHANGE: ensure files without issues are reported                 ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output           ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         Michael Cartwright                Date : 29-JAN-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Karl Neufeldt                     Date : 29-JAN-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Michael Cartwright                Date : 30-JAN-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           4.2                                                      ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          Yes [X]: The Computerized System has significant impact  ;
%*                             on business critical services or processes.     ;
%*                    No  [ ]: The Computerized System has no significant      ;
%*                             impact on business critical servizes or         ;
%*                             processes.                                      ;
%*                                                                             ;
%* Regulatory:        Yes [X]: The Computerized System has significant impact  ;
%*                             on GxP data and/ or supports a GxP process.     ;
%*                    No  [ ]: The Computerized System is not involved         ;
%*                             directly or indirectly with GxP data or a GxP   ;
%*                             process.                                        ;
%*                                                                             ;
%* REASON FOR CHANGE: While bug fiexed version 4.1 generally reported files    ;
%*                    without issues, it omitted files where the only issue(s) ;
%*                    were related to reported MISSING() function.             ;
%*                    Version 4.2 will report "MISSING ", will not report the  ;
%*                    function MISSING() and report all files either with their;
%*                    issues or as without issues ("No errors found").         ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output           ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         Karl Neufeldt                     Date : 28-FEB-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Michael Cartwright                Date : 28-FEB-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Jennifer Reid                     Date : 28-FEB-2008     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%*-----------------------------------------------------------------------------;
%* VERSION:           4.3  (made from miglogchk 4.2 mod(2) from 15.10.2010)    ;
%*                                                                             ;
%* RISK ASSESSMENT                                                             ;
%* Business:          Yes [X]: The Computerized System has significant impact  ;
%*                             on business critical services or processes.     ;
%*                    No  [ ]: The Computerized System has no significant      ;
%*                             impact on business critical servizes or         ;
%*                             processes.                                      ;
%*                                                                             ;
%* Regulatory:        Yes [X]: The Computerized System has significant impact  ;
%*                             on GxP data and/ or supports a GxP process.     ;
%*                    No  [ ]: The Computerized System is not involved         ;
%*                             directly or indirectly with GxP data or a GxP   ;
%*                             process.                                        ;
%*                                                                             ;
%* REASON FOR CHANGE: 1) Year from UNIX ll command bug                         ;
%*                    2) Furthermore: It is assumed that LC_TIME               ;
%*                       was not modified and  is set to default of "C"        ;
%*                    3) PC SAS compatibility                                  ;
%*                    4) SAS Expiration messages to be omitted                 ;
%*                    5) Blank in filename bug                                 ;
%*                    6) program names length increased to 250 chars           ;
%*                    7) "MSGLEVEL" options message suppressed                 ;
%*                                                                             ;
%* TESTING            Peer code review and review of the test output           ;
%* METHODOLOGY:                                                                ;
%*                                                                             ;
%* DEVELOPER:         Ralf Ludwig                       Date : 18-FEB-2011     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* CODE REVIEWER:     Dmitry Kolosov                    Date : 18-FEB-2011     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%* USER:              Dmitry Kolosov                    Date : 18-FEB-2011     ;
%*                                                                             ;
%* SIGNATURE:         ................................  Date : ............... ;
%*                                                                             ;
%******************************************************************************;


     %let exclude=%upcase(&exclude);

     options nomprint nosymbolgen nomlogic;

     *****************************************************************;
     ** CREATE MACRO PARAMETERS CONTAINING LOG CHECK SEARCH STRINGS **;
     *****************************************************************;
     data core;
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
          chktext="MISSING"; output;
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

     data _null_;
          set core end=eof;
          call symput("chktext" || compress(put(_n_, 8.)), trim(chktext));
          if eof then call symput("nchktxt", compress(put(_n_, 8.)));
     run;



     ********************************************;
     ** IDENTIFY DIRECTORIES TO BE LOG CHECKED **;
     ********************************************;
     data fpaths;
          ** GRAB LIST OF FILENAME MACRO PARAMETERS SPECIFIED IN THE SETUP.SAS PROGRAM **;
          infile "&setupdir.&setup" length=reclen;
          input @1 record $varying200. reclen;
          if index(compress(upcase(record)), "OS_FVARS(MVAR") and
             not(index(upcase(translate(record, "!", "%")), "!MACRO")) then do;
               fname=upcase(scan(substr(record, index(record, "=")+1), 1, ","));
               output;
          end;
     run;

     %let inc=0;

     data exclude;
          ** EXCLUDE DIRECTORIES WHERE LOG CHECK IS NOT REQUIRED **;
          length fname $200;
          %do %while (%qscan(&exclude, %eval(&inc+1), " ") ne );
               fname = "%qscan(&exclude, %eval(&inc+1), ' ')";
               output;
               %let inc=%eval(&inc+1);
          %end;
     run;

     proc sort data=fpaths;
          by fname;
     run;

     proc sort data=exclude;
          by fname;
     run;

     data fpaths1;
          merge fpaths(in=infp) exclude(in=inex);
          by fname;
          if infp and not inex;
     run;

     data _null_;
          ** POPULATE MACRO PARAMETERS WITH DIRECTORY PATHS TO BE SEARCHED **;
          set fpaths1 end=eof;
          call symput("fpath" || compress(put(_n_, 8.)), "&" || compress(fname));
          if eof then call symput("nfpaths", compress(put(_n_, 8.)));
     run;



     ********************************************************************;
     ** CREATE A DATASET SHELL THAT WILL HOLD THE RESULTS OF LOG CHECK **;
     ** PERFORMED ON EACH INDIVIDUAL DIRECTROY.                        **;
     ********************************************************************;
     data all_logs;
          length dir $200. lognam $250. line 8. chktxt $50. logtxt $200. filedate $15.;
          dir=dir;
          lognam=lognam;
          line=line;
          chktxt=chktxt;
          logtxt=logtxt;
          filedate=filedate;
          delete;
     run;


     ***************************************************;
     ** PERFORM LOG CHECK ON EACH SPECIFIED DIRECTORY **;
     ***************************************************;
     %DO I=1 %TO &NFPATHS;
          ** IDENTIFY ALL LOG FILES IN THE SPECIFIED DIRECTORY **;
          ** CREATE A DIRECTORY LISTING FILE DEPENDANT UPON    **;
          ** OPERATING SYSTEM THAT DISPLAYS A VERTICAL LIST OF **;
          ** LOG FILES WITH MINIMUL ADDITIONAL DETAILS.        **;
          %if &sysscp=%str(HP IPF) %then %do;
               ** UNIX PLATFORM ***;
               data _null_;
                    call system("cd &&fpath&i");
                    /*** ll format set to iso, 11.03.2010, RL ***/ 
                    call system("LC_TIME=en_GB.iso88591 ls -ll *.log > logfiles.txt");
               run;

               data logfiles1;
                    infile "&&fpath&i...logfiles.txt" length=reclen;
                    input @1 record $varying200. reclen;
                    if index(upcase(record), ".LOG");
               run;

               data logfiles2(keep = fle date1-date3);
                    set logfiles1;
                    length temp1-temp2 perm num usr grp size date1-date3 fle $200.;
                    array cols{20} 3.;
                    array vars{*} perm num usr grp size date1-date3 fle;
                    temp1 = tranwrd(trim(record), " ", "#");
                    temp2 = temp1;
                    do until (index(temp2, "##")=0);
                         temp2 = tranwrd(temp2, "##", "#");
                    end;
                    cols{1} = index(temp2, "#");
                    do j = 2 to dim(cols);
                         cols{j} = index(substr(temp2, cols{j-1}+1), "#") + cols{j-1};
                    end;
                    vars{1} = substr(temp2, 1, cols{1}-1);
                    do k = 2 to dim(vars)-1;
                         vars{k} = substr(temp2, cols{k-1}+1, (cols{k} - cols{k-1})-1);
                    end;
                    vars{dim(vars)} = substr(temp2, cols{dim(vars)-1}+1);
               run;

               data logfiles(keep = record recdate);
                    length record $200. recdate $20. dd mon yyyy tim $5.;
                    set logfiles2(rename=(fle=record date1=mon));
                    dd = put(input(trim(date2), 3.), z2.);
                    if index(date3, ":") gt 0 then do;
                         tim = trim(date3);
                         yyyy = put(year(input("&sysdate9", date9.)), 4.);
                    end;
                    else do;
                         yyyy = trim(date3);
                         tim = "00:00";
                    end;
                    
                    /*** Year from ls bug, 11.03.2010, RL ***/         
                    dRecdate=INPUT(COMPRESS(dd)||COMPRESS(mon)||COMPRESS(yyyy), DATE9.);
                    IF dRecdate GT DATE() THEN yyyy=PUT(INPUT(yyyy, BEST4.)-1, BEST4.);
                    DROP dRecdate;
                    /*** Year from ls bug, 11.03.2010, RL ***/         
                    
                    recdate = compress(upcase(cat(dd, mon, yyyy)) || ":" || tim);
               run;
          %end;
          %else %if &sysscp=WIN %then %do;
               ** WINDOWS PLATFORM ***;
               options noxwait xsync;

               filename filelist pipe "dir ""&&fpath&i\*.log"" /T:W";

               DATA logfiles;
                  LENGTH sCol1 sCol2 sCol3 $40 sCol4 sCol5 $200 record $200 recdate $20;
                  INFILE filelist PAD TRUNCOVER;
                  INPUT sCol1 sCol2 sCol3 sCol4 $CHAR200. sCol5 $CHAR200.  ;
                  %*** remove heading and summary information ***;
                  IF INPUT(sCol1, ?? DDMMYY10.) < .Z /* EU */ AND
                     INPUT(sCol1, ?? MMDDYY10.) < .Z /* US */ THEN DELETE;
                  %*** american datetime format ***;
                  IF COMPRESS(sCol3) IN("AM" "PM") THEN DO;
                     sCol2=TRIMN(sCol2)||" "||TRIMN(sCol3); 
                     sCol4=sCol5; 
                  END;
                  recdate=TRIMN(sCol1)||":"||TRIMN(sCol2);
                  record=TRIMN(sCol4);
                  KEEP record recdate;
               RUN;

               /*** OLD, 11.02.2008 RL ***
               data _null_;
                    root=substr("&&fpath&i",1,2);
                    call system(root);
                    call system("cd &&fpath&i");
                    call system("dir *.log /n > logfiles.txt");
               run;
               /***/
          %end;


          ** CREATE A SAS LIST OF LOG FILES TO SEARCH **;
          %let nfiles=0;

          data _null_;
               set logfiles end=eof;
               record=TRANSLATE(record, " ", "#");
               call symput("file" || compress(put(_n_, 8.)), TRIMN(record));
               %*** OLD, 20.01.2011 RL *** call symput("file" || compress(put(_n_, 8.)), compress(record));
               call symputx("filedat" || compress(put(_n_, 8.)), compress(recdate));
               if eof then call symput("nfiles", compress(put(_n_, 8.)));
          run;



          ** DELETE THE EXTERNAL FILE LISTING LOG FILES IN A SPECIFIED DIRECTORY **;
          ** AS THIS FILE IS NO LONGER REQUIRED.                                 **;
          ** V3 (24NOV2006): TEXT CONTAINING ERRORS PRINTED ON PAGE SUPPRESSED.  **;
          data _null_;
               rc=filename("delfile", "&&fpath&i...logfiles.txt");
               rc=fdelete("delfile");
               rc=filename("delfile");
          run;

          data _null_;
               length y $15;
               do i=9 to 10, 12 to 13, 27, 127 to 129, 141 to 144, 157 to 158;
                    x = byte(i);
                    y = compress(y||x);
                    z = compress('"' || y || '"');
                    call symput ('_compr', z);
                    output;
               end;
          run;

          * KN: LOAD LOG FILE DATA INTO DATASET ON A LINE BY LINE BASIS ;
          %IF %EVAL(&NFILES)>0 %THEN %DO;
               %DO J=1 %TO &NFILES;
               data logchk0(drop = _x _xn logt);
                    format _x logt $150. _xn _com 8.;
                    infile "&&fpath&i...&&file&j" length=reclen pad missover end=eof;
                    input @1 logtxt $varying200. reclen;
                    logt = compress(logtxt, &_compr);
                    _x = scan(logt, 1, " ");
                    if _x ne "" then do;
                         if anyalpha(_x) = 0 and anypunct(_x) = 0 and
                              substr(logtxt, 1, 1) ne " " then _xn = input(trim(_x), best10.);
                         if _xn gt .z then _com = 1;
                         else if trim(_x) = "%*" then do;
                              if substr(left(reverse(trim(logt))), 1, 1) = ";" then _com = 1;
                         end;
                    end;
               run;

               * RL, 18.02.2011: Remove " The SAS System " and their following rows from log;
               data logchk0(DROP=bTheSAS);
                    set logchk0;
                    RETAIN bTheSAS 0; 
                    IF logtxt NE ' ' THEN DO; 
                       IF PRXMATCH("/^\f?\s*\d*\s*The SAS System.*$/", logtxt) NE 0 THEN bTheSAS=1;
                       ELSE bTheSAS=0;
                    END;
                    ELSE DO;
                       IF bTheSAS=1 THEN DELETE;
                    END;
               RUN;
                    
               * KN: CHECK LINES FOR KEYWORDS EXCLUDING DEFAULT FINDINGS ;
               data logchk(drop=any _com);
                    length dir $200. lognam $250. line 8. chktxt $50. logtxt $200. filedate $15.;
                    set logchk0 end=eof;
                    filedate = "&&filedat&j";
                    
                     %*** suppress special log messages, 15.10.2010 RL ***;
                     %LOCAL filter1 filter2 filter3;
                     %LET filter1=%NRBQUOTE((^WARNING: The [\w\s\/]+ product with which.*$));     
                     %LET filter2=%NRBQUOTE(warning\s*[^:\[]);                     
                     %LET filter3=%NRBQUOTE(warning\s*[^:\[]);                     

                     RETAIN nFilter 0; DROP nFilter;
                     IF logtxt eq: "WARNING: The" or nFilter > 0 THEN DO;  /* 09.02.2011 RL: v4.3 */
                        IF PRXMATCH("/&filter1/", logtxt) NE 0 THEN DO; 
                           nFilter=1; 
                           logtxt=PRXCHANGE("s/&filter1/ /i", -1, logtxt); 
                        END;
                        ELSE IF nFilter=1 AND PRXMATCH("/&filter2/", logtxt) NE 0 THEN DO; 
                           nFilter=2; 
                           logtxt=PRXCHANGE("s/&filter2/ /i", -1, logtxt); 
                        END; 
                        ELSE IF nFilter GE 1 AND PRXMATCH("/&filter3/", logtxt) NE 0 THEN DO; 
                           nFilter=nFilter+1; 
                           IF nFilter LT 5 THEN logtxt=PRXCHANGE("s/&filter3/ /i", -1, logtxt); 
                        END; 
                        ELSE IF nFilter GE 1 AND logtxt NE ' ' THEN;  /* 15.02.2011 RL: v4.3 */
                        ELSE nFilter=0;
                     END; 
                    
                    if _n_=1 then any=0;
                    %do x=1 %to &nchktxt;
                         if index(upcase(logtxt),"&&chktext&x") then do;
                           if not(
                                  index(upcase(logtxt),"YOU ARE RUNNING SAS 9. SOME SAS 8 FILES WILL BE AUTOMATICALLY CONVERTED")
                               or index(upcase(logtxt),"WARNING: UNABLE TO COPY SASUSER REGISTRY TO WORK REGISTRY.")
                               or index(upcase(logtxt),"WARNING: DMS BOLD FONT METRICS FAIL TO MATCH DMS FONT.")
                               or index(upcase(logtxt),"NOTE: THE SAS SYSTEM USED:")
                               or index(upcase(logtxt),"ERROR: ERRORS PRINTED ON PAGE")
                               or index(upcase(compress(logtxt)),"MISSING(") /*KN: v4.2 */
                               or index(upcase(logtxt),"WARNING: YOUR SYSTEM IS SCHEDULED TO EXPIRE") /* 09.02.2011 RL: v4.3 */
                               or index(upcase(logtxt),"NOTE: MULTIPLE CONCURRENT THREADS WILL BE USED TO SUMMARIZE") /* 09.02.2011 RL: v4.3 */
                                  ) then do;
                                /* any+1; ver 4.0 */
                                   if _com ne 1 then any+1; /* KN: v4.1 */
                                   dir="&&fpath&i";
                                   lognam="&&file&j";
                                   line=_n_;
                                   if _com = 1 then chktxt="COMMENT/CODE: " || "&&chktext&x";
                                   else chktxt="&&chktext&x";
                                   if _com ne 1 then output;
                              end;
                         end;
                    %end;
                    if eof and any=0 then do;
                         dir="&&fpath&i";
                         lognam="&&file&j";
                         line=.;
                         chktxt="No errors found";
                         logtxt="";
                         output;
                    end;
               run;



               ** APPEND ERROR DETAILS FOR EACH FILE TO THE ALL_LOGS DATASET **;
               proc append base=all_logs data=logchk;
               run;


               ** TIDY ENVIRONMENT AT END OF EACH ITERATION OF DO LOOP**;
               proc datasets lib=work nolist;
                    delete logchk0 logchk;
               run;
               quit;
          %END;
          %END;
          %ELSE %DO;
          data logchk;
               length dir $200. lognam $250. line 8. chktxt $50. logtxt $200. filedate $15.;
               dir="&&fpath&i";
               lognam=lognam;
               line=line;
               chktxt="No LOG files found";
               logtxt=logtxt;
               filedate=filedate;
          run;

          ** APPEND ERROR DETAILS FOR DIRECTORIES WITH NO FILES TO THE ALL_LOGS DATASET **;
          proc append base=all_logs data=logchk;
          run;


          ** TIDY ENVIRONMENT AT END OF EACH ITERATION OF DO LOOP**;
          proc datasets lib=work nolist;
               delete logchk;
          run;
          quit;
     %END;

     ** TIDY ENVIRONMENT AT END OF EACH ITERATION OF DO LOOP**;
     proc datasets lib=work nolist;
          delete logfiles1 logfiles2 logfiles;
     run;
     quit;
     %END;



     ***************************;
     ** PRODUCE ERROR REPORTS **;
     ***************************;
     * KN: ID/ HANDLE WANTED ERRORS, WARNINGS AND NOTES ;
     data all_logs1;
          ** PROCESS ALL_LOGS DATASET TO PREPARE FOR REPORT PRODUCTION **;
          set all_logs;
          if (chktxt="ERROR" or chktxt="WARNING" or chktxt="NOTE") and
          index(upcase(logtxt),"[PXL]") then chktxt=trim(chktxt) || "[PXL]";

          * KN: v4 - exclude missing() call routine from report;
          * if chktxt = "MISSING" and index(upcase(compress(logtxt)), "MISSING(") gt 0 then delete;
          * KN: removed this condition for v4.2 ;
     run;


     ** OVERALL SUMMARY AND FULL DETAILS **;
     proc sort data=all_logs1;
          by dir lognam chktxt line;
     run;

     data fqcount1;
          set all_logs1;
          by dir lognam chktxt line;
          if first.line then output;
     run;

     proc sort data=fqcount1;
          by chktxt dir lognam line;
     run;



     ** COUNT TOTAL ERRORS AND ERRORS BY LOGNAME **;
     proc freq data=fqcount1 noprint;
          tables chktxt / out=summary (drop=percent rename=(count=totcount));
          tables chktxt*dir*lognam / out=full (drop=percent rename=(count=chkcnt));
     run;



     ** GROUP LINES **;
     data gline1(drop = line);
          set all_logs1(keep = dir lognam chktxt line where=(line gt .z));
          by dir lognam chktxt line;
          retain fstline;
          if first.chktxt then fstline = line;
          if last.chktxt then do;
               lastline = line;
               output;
          end;
     run;

     data gline2 (drop = fstline lastline);
          set gline1;
          do line = fstline to lastline;
               output;
          end;
     run;

     data gline3;
          merge all_logs1(in=A) gline2;
          by dir lognam chktxt line;
          if A then orig=1;
     run;

     data gline4(where=(orig = 1));
          set gline3;
          by dir lognam chktxt orig line notsorted;
          retain minline;
          if first.chktxt then minline = .;
          if first.orig then minline = line;
          if last.orig then do;
               maxline = line;
               output;
         end;
     run;

     data gline5(drop = minline maxline);
          set gline4(drop = orig);
          length lineg $20.;
          if minline gt .z then do;
               if maxline ne minline then lineg =
                    compress(put(minline, 8.)) || "-" || compress(put(maxline, 8.));
               else lineg = compress(put(minline, 8.));
          end;
     run;



     ** ADD LINE NUMBERS ONTO ERRORS BY LOG FREQENCY COUNTS **;
     ** V3 (24NOV2006): CORRECTION TO FORMATTING WHERE MULTIPLE PAGE NUMBERS PRESENTED **;
     data full1(drop = lineg);
          retain lines fline;
          set gline5;
          by dir lognam chktxt line;
          length lines $200;
          if first.chktxt then do;
               lines="";
               fline=lineg;
          end;
          if lineg ne "" then lines=left(compbl(lines) || compress(lineg) || ", ");
          if last.chktxt then do;
               if lines^='' then do;
                    if index(left(reverse(lines)), ",")=1 then
                      lines=left(reverse(substr(left(reverse(lines)), 2)));
                    else if compress(scan(lines,-1, ",")) ne compress(lineg) then
                      substr(lines, length(lines)-index(reverse(lines), ",")+1)="...";
               end;
               output;
          end;
     run;

     proc sort data=full;
          by dir lognam chktxt;
     run;

     data full2;
          merge full(in=inf) full1;
          by dir lognam chktxt;
          if inf then output;
     run;

     data full3(drop = onlynam filedate);
          length lognam $500.;
          set full2 (rename=(lognam=onlynam));
          length review $45;
          lognam = catx("/~n", onlynam, filedate);
          chkcnt_=compress(put(chkcnt, best.));
          if upcase(chktxt)="NO LOG FILES FOUND" or upcase(chktxt)="NO ERRORS FOUND" then chkcnt_="";
          else review="=>(       )";
     run;

     proc sort data=full3;
          by dir lognam chktxt;
     run;

     data full4(drop = j temp newl1-newl100 pos1-pos100);
          set full3;
          length temp $200. newline $500.;
          array newl [100] $38.;
          array pos [100] 8.;
          newl1 = "";
          pos1 = 0;
          temp = trim(lines);
          if length(trim(lines)) gt 38 then do;
               do j = 2 to dim(newl);
                    temp = left(substr(temp, pos{j-1}+1));
                    pos{j} = 38-index(reverse(left(trim(substr(temp, 1, 38)))), " ");
                    newl{j} = substr(temp, 1, pos{j});
               end;
               newline = catx("~n", of newl1-newl100);
          end;
          else if lines ne "" then newline = trim(lines);
     run;

     ** PRODUCE REPORTS **;
     ** V3 (24NOV2006): FOOTNOTE ADDED TO INCLUDE REVIEW/SIGN-OFF LINE.       **;;
     **                 COLUMN ADDED TO PROVIDE PROMPT AND SPACE FOR COMMENT. **;;
     **                 OUTPUT CONVERTED TO USE OF ODS, INCLUDING CREATION OF **;;
     **                 AN RTF OUTPUT FILE.                                   **;;
     **                 PAGE NUMBERING ADDED.                                 **;;


     ods path sasuser.templat(update)
          sashelp.tmplmst(read);
     run;

     proc template;
          define style miglogchk;
          parent=styles.rtf;
          replace fonts /
              "docfont"=("courier new",10pt)
              "headingfont" = ("courier new",10pt,bold roman)
              "titlefont" = ("courier new",10pt)
              "titlefont2" = ("courier new",10pt)
              "title2font" = ("courier new",10pt)
              "strongfont" = ("courier new",10pt)
              "emphasisfont" = ("courier new",10pt)
              "fixedemphasisfont" = ("courier new",10pt)
              "fixedstrongfont" = ("courier new",10pt)
              "fixedheadingfont" = ("courier new",10pt)
              "batchfixedfont" = ("courier new",10pt)
              "fixedfont" = ("courier new",10pt)
              "headingemphasisfont" = ("courier new",10pt);
          style table from container /
               frame=hsides
               rules=groups
               cellpadding=.4pt
               cellspacing=0pt
               borderwidth=.4pt
               asis=on;
          style body from document/
               bottommargin=.5in
               topmargin=.5in
               rightmargin=.5in
               leftmargin=.5in;
          style header from headersandfooters /
               protectspecialchars=off
               just=center;
          style systitleandfootercontainer from container/
               asis=on;
          style data from container/
               asis=on;
          end;
     run;

     ods escapechar = "~";
     ods listing close;

     %if &papersz ne LETTER %then %let papersz=A4;;

     * V4 (18SEP2007) PDF OUTPUT PREFERABLE ;
     options nodate nonumber nobyline orientation=landscape papersize=&papersz ;

     ods pdf file="&setupdir.logcheck.pdf" style=miglogchk notoc;

     title1 "Logcheck Performed On %sysfunc(left(%qsysfunc(date(),date9.))) %sysfunc(left(%qsysfunc(time(),time5.)))";
     footnote1 j=l "Reviewed by:" j=c "Date:" j=r "Page ~{thispage} of ~{lastpage}";

     title2 "Summary of Errors Found";
     title4 "&_PROJPRE.&_SUFFIX";

     proc report data=summary nowd headline headskip missing spacing=2 split="@";
          column chktxt totcount;
          where not(upcase(chktxt)="NO LOG FILES FOUND" or upcase(chktxt)="NO ERRORS FOUND");
          define chktxt   / style={cellwidth=40% just=l} "Search String";
          define totcount / style={cellwidth=15% just=l} "Number of Occurrences";
     run;
     quit;

     title2 "Summary of Errors by Log File Name";
     title4 "#byval1" ;
     proc report data=full4 nowd headline headskip missing spacing=2 split="@";
          column dir lognam chktxt chkcnt_ newline review;
          by dir;
          define dir     / order noprint;
          define lognam  / group style={cellwidth=17% just=l} order order=data "Log File/@Log Date" width=30 flow;
          define chktxt  / style={cellwidth=18% just=l} "Search String" width=25 flow;
          define chkcnt_ / style={cellwidth=10% just=l} "Number of Occurrences" width=11 flow;
          define newline / style={cellwidth=27% just=l} "Found on Line Numbers" width=50 flow;
          define review  / style={cellwidth=21% just=l} "Comment on all issues found (initials)" width=45 flow;
          compute after lognam;
               line "";
               line "";
          endcomp;
     run;

     ods pdf close;
     ods listing;


     ** TIDY ENVIRONMENT **;
     proc datasets lib=work nolist;
          delete all_logs all_logs1 core fpaths fpaths1 exclude fqcount1 summary full full1
          full2 full3 full4 gline1-gline5;
     run;
     quit;

     title;
     footnote;
%mend miglogchk;

