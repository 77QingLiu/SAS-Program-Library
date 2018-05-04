/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        112253

  SAS Version:           9.1 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Roman Igla, Sergey Proskurnin $LastChangedBy: iglar $
  Creation Date:         24APR2015       $LastChangedDate: 2016-02-26 03:53:12 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmscreatepopds.sas $

  Files Created:         <path if different from calling program> <filename>.<ext>
                         <path if different from calling program> <filename>.<ext>

  Program Purpose:       This macro creates dataset with population counts. Resulting dataset
                         can be used as an input for BMSFreq for PopDS parameter;

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters:

    Name:                popds
      Default Value:     REQUIRED
      Description:       Disposition and name of input dataset

    Name:                dataOut
      Default Value:     _bms_popds
      Description:       Name of resulting dataset

    Name:                popCond
      Default Value:     REQUIRED
      Description:       Condition to select population for analysis, e.g. %quote(SAFFL="Y")

    Name:                popTrtCode
      Default Value:     REQUIRED
      Description:       Treatment variable (num) as it is named popds dataset (e.g. trt01an)

    Name:                byVars
      Default Value:     N/A
      Description:       The variable for group analysis with list of values,
                         e.g. byvar1(%nrbquote("q1", "q2"))@byvar2(%nrbquote("w1", "w2"))

    Name:                TrtCode
      Default Value:     N/A
      Description:       Treatment variable (num) as it is named other domain datasets (e.g. trtan).
                         If trtCode is not specified then variable from popTrtCode parameter will be used

    Name:                TrtValues
      Default Value:     N/A
      Description:       Treatment values are needed if some zero count treatment(s) need to be include into the table.
                         TrtValues must be digits, e.g.: %quote(1, 2, 3).

    Name:                delimeter
      Default Value:     @
      Description:       Delimeter for condition in byVars,
                         e.g. %quote(byvarq1(%nrbquote('by1', 'by2'))@byvarf2(%nrbquote('by8', 'by9')))

  Macro Returnvalue:     N/A
      Description:       N/A

  Macro Dependencies:    no dependencies

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1874 $
-----------------------------------------------------------------------------*/

%macro bmsCreatePopDs(popds=, dataOut=_bms_popds, popCond=, popTrtCode=, trtCode=, trtValues=, byVars=, delimeter = @);

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmscreatepopds.sas $
          , revision = $Rev: 1874 $
          );

%let SYSCCnull = &SYSCC.;
%let SYSCC = 0;

%let codefile=%quote(bmscreatepopds.sas);

    *Checking that all required parameters are specified;
    %if %length(&popds.) lt 1 %then
        %gmMessage(codelocation=&codefile.,
                    linesout=Empty parameter popds,
                    selectType=ABORT);
    %if %length(&popCond.) lt 1 %then
        %gmMessage(codelocation=&codefile.,
                    linesout=Empty parameter popCond,
                    selectType=ABORT);
    %if %length(&popTrtCode.) lt 1 %then
        %gmMessage(codelocation=&codefile.,
                    linesout=Empty parameter popTrtCode,
                    selectType=ABORT);
    %if %superQ(trtValues) ^= %then %do;
        %if %sysfunc(prxMatch(%sysfunc(prxparse(/[a-zA-Z\x22\x27]/)), %superQ(trtValues))) %then %do;
            %gmMessage(codelocation=&codefile.,
                    linesout=TrtValues are invalid,
                    selectType=ABORT);
        %end;
    %end;

    *Verifying the existence of a dataset;
    %macro existds(ds=&popds.);
    %if %sysfunc(exist(&ds.)) %then
        %let dsid=%sysfunc(open(&ds.,i));
    %else %gmMessage(codelocation = &codefile.,
                         linesout = Input dataset &popds. does not exist.,
                       selectType = ABORT);
    %let rc = %sysfunc(close(&dsid.));
    %mend existds;
    %existds();

    *Verifying the existence and type of popTrtCode;
    %let dsid  = %sysfunc(open(&popds., i));

    %let check_exists_trt = %sysfunc(varnum(&dsid., &popTrtCode.));
    %if &check_exists_trt. eq 0 %then %do;
        %gmMessage(codelocation=&codefile.,
                   linesout=Variable &popTrtCode. does not exist in input dataset &popds.,
                   selectType=ABORT);
    %end;

    *Verifying the existence of by-variables;
    %if %superQ(byVars) ^= %then %do;
        data _null_;
            ExpressionID = prxparse('/[\w]+(\(.*?\))?/');
            start = 1;
            stop = length("&byVars.");
            call prxnext(ExpressionID, start, stop, "&byVars.", position, length);
              j = 1;
              do while (position > 0);
                 found = substr("&byVars.", position, length);
                 call symput("part"||strip(put(j, 8.)), found);
                 call prxnext(ExpressionID, start, stop, "&byVars.", position, length);
                 j = j + 1;
              end;
        run;

        %let numparts = %eval(%sysfunc(countc("&byVars.", &delimeter.))+1);
        %do j = 1 %to &numparts.;
            %let byvar&j.  = %sysfunc(prxChange(%sysfunc(prxparse(s/(\w+)(?:\((.*)\))?/$1/)),1, %quote(&&part&j.)));
            %let bylist&j. = %sysfunc(prxChange(%sysfunc(prxparse(s/(\w+)(?:\((.*)\))?/$2/)),1, %quote(&&part&j.)));
        %end;

        %do k = 1 %to &numparts.;
            %let check_exists_byvar&k. = %sysfunc(varnum(&dsid., &&byvar&k.));
            %if &&check_exists_byvar&k. eq 0 %then %do;
            %gmMessage(codelocation=&codefile.,
                       linesout=Variable &&byvar&k. does not exist in input dataset &popds.,
                       selectType=ABORT);
            %end;

            *Create length statments for determine BY variables length;
            %let length&k. = %sysfunc(tranwrd(%sysfunc(tranwrd(%sysfunc(vartype(&dsid,%sysfunc(varnum(&dsid,&&byvar&k.))))%sysfunc(
                varlen(&dsid,%sysfunc(varnum(&dsid,&&byvar&k.)))),C,$)),N,)).;

            %let lenstat&k. = length &&byvar&k. &&length&k.;

        %end;
    %end;

    *Close dataset after variable checking;
    %let rc = %sysfunc(close(&dsid.));

    %if &trtCode.= %then
        %let trtCode=&popTrtCode;

    *Obtain records which satisfying conditions;
    data _popds_frq_0;
        set &popds. (where = (&popCond.));
        proc sort; by &poptrtCode.;
    run;

    %if not (&SYSERR. < 4) %then %do;
        %gmMessage(codelocation=&codefile.,
                       linesout=Invalid condition in popCond parameter,
                     selectType=ABORT);
    %end;

    %let sqlby =;
    %let byvariables_b =;
    %if %superQ(trtValues) ^= or %superQ(byVars) ^= %then %do;

        *** BY VARS PROCESSING ***;
        %if %superQ(byVars) ^= %then %do;
            %do j = 1 %to &numparts.;
                %if &&bylist&j. ne %then %do;
                    data _popds_frq_byds&j.; &&lenstat&j.;
                        do &&byvar&j. = %unquote(&&bylist&j.);
                            output;
                        end;
                run;
                %end;
                %else %do;
                    proc sort data=&popds.(where = (&popCond.)) out=_popds_frq_byds&j.(keep=&&byvar&j.) nodupkey;
                        by &&byvar&j.;
                    run;
                %end;

                %if &j. = 1 %then %let sqlby = ,_popds_frq_byds&j.;
                %else %let sqlby = &sqlby., _popds_frq_byds&j.;

                %if &j = 1 %then %let byvariables_b = &&byvar&j.;
                %else %let byvariables_b = &byvariables_b. &&byvar&j.;

            %end;
        %end;
        %else %do;

        %end;
        *** END OF BYVARS PROCESSING, OUTs: _popds_frq_BYDS\d ***;

        *Obtain trtValues from input dataset if argument has not been given;
        %if %length(&trtValues.) < 1 %then %do;
            proc sort data=&popDs.(where = (&popCond.)) out=_popds_frq_popDSsort nodupkey; by &popTrtCode.; run;
            data _popds_frq_dummy1(rename=(&popTrtCode.=&trtCode.));
                set _popds_frq_popDSsort(keep=&popTrtCode.);
                popCount = 0;
            run;
        %end;
        %else %do;
            data _popds_frq_dummy1;
                do &trtCode = &trtValues;
                    popCount = 0; output;
                end;
            run;
        %end;

        proc sql noprint;
            create table _popds_frq_dummy2 as
            select *
            from _popds_frq_dummy1 &sqlby.
            order by &trtCode.;
        quit;

        data _popds_frq_dummy;
            set _popds_frq_dummy2;
            popCount = 0;
            proc sort nodupkey;
                by &trtCode. &byvariables_b.;
        run;
    %end;

    *Counting records by treatment and by group variables;
    %if &byvariables_b. ^= %then %do;
        proc sort data=_popds_frq_0; by &byvariables_b.; run;
    %end;
    proc freq data=_popds_frq_0 noprint;
        %if &byvariables_b. ^= %then %do;
            by &byvariables_b.;
        %end;
        tables &poptrtcode.
            /out=_popds_frq_1(drop=percent rename=(count=popCount &poptrtcode.=&trtcode.));
    run;

    proc sort data=_popds_frq_1;
        by &trtCode. &byvariables_b.;
    run;

    data &dataOut.;
        %if &trtValues. ^= or &byVars. ^= %then %do;
            update _popds_frq_dummy _popds_frq_1;
            by &trtCode. &byvariables_b.;
        %end;
        %else %do;
            set _popds_frq_1;
        %end;
        label popCount = " ";
        proc sort;
            by &trtCode. &byvariables_b.;
    run;

    %if not (&SYSCC. < 4) %then %do;
        %gmMessage(codelocation=&codefile.,
                       linesout=The type of &trtCode. is different,
                       selectType=ABORT);
    %end;

    %let SYSCC = %sysfunc(max(&SYSCC,&SYSCCnull));

    proc datasets library=work nolist memtype=data;
        delete _popds_frq_:;
    quit;

    %gmEnd(headURL  = $    $);

%mend bmsCreatePopDs;
