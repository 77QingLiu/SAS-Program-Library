/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        3000-G&A-TRNG

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Alexander Shakhlo $LastChangedBy: kolosod $
  Creation Date:         03JUN2014         $LastChangedDate: 2014-10-21 08:01:27 -0400 (Tue, 21 Oct 2014) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmssortcolumns.sas $

  Files Created:         N/A

  Program Purpose:       BMSSortColumns macros orders variables in an analysis
                         dataset in a correct manner and checks that sorting key
                         is a unique one.
                         Required inputs:  - name of analysis dataset;
                                           - a list of sorting variables (the unique sorting key).
                         Expected outputs: - modified analysis dataset;
                                           - no additional files are created.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                AdsLib
      Allowed Values:    Valid SAS-library name
      Default Value:     WORK
      Description:       Character string containing existing SAS library name.

    Name:                AdsName
      Allowed Values:    Valid SAS-dataset name
      Default Value:     REQUIRED
      Description:       Character string containing existing analysis dataset name.

    Name:                KeyVarsList
      Allowed Values:    Character string
      Default Value:     REQUIRED
      Description:       Character string containing the list of existing key-variables separated with blanks.

  Macro Dependencies:    gmStart (called)
                         gmMessage (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 249 $
-----------------------------------------------------------------------------*/

%macro BMSSortColumns(
                      AdsLib      = WORK,
                      AdsName     = ,
                      KeyVarsList =
                     );

    %let EnvErr=0;

%let BMSSortColumnsLib = %gmStart(
                                  headURL     = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmssortcolumns.sas $,
                                  revision    = $Rev: 249 $,
                                  libRequired = 1
                                 );


    data _NULL_;
        if(not %SYMEXIST(_pxlwar)) then do;
            call symputx("_PXLWAR",cat("WAR","NING:[PXL]"));
        end;
    run;

    data _NULL_;
        if(not %SYMEXIST(_comvars)) then do;
            put "&_PXLWAR. Macro variable '_COMVARS' is not defined in SETUP!";
            call symputx("_comvars","");
        end;
    run;

    data _NULL_;
        if(ANYPUNCT("&AdsLib.") OR ANYSPACE(strip("&AdsLib.")) OR length(strip("&AdsLib."))>8 OR length(strip("&AdsLib."))<1) then do;
            put "&_PXLWAR. 'AdsLib=' macro parameter has invalid length OR contains invalid symbol!";
            call symputx("EnvErr",1);
        end;

        if(ANYPUNCT("&AdsName.") and not prxMatch("/(\_|\-)/","&AdsName.") OR ANYSPACE(strip("&AdsName."))
           OR length(strip("&AdsName."))>8 OR length(strip("&AdsName."))<1) then do;
            put "&_PXLWAR. 'AdsName=' macro parameter is not specified OR has invalid length OR contains invalid symbol!";
            call symputx("EnvErr",1);
        end;

        if(ANYPUNCT("&KeyVarsList.") and not prxMatch("/(\:|\-)/","&KeyVarsList.")) then do;
            put "&_PXLWAR. 'KeyVarsList=' macro parameter contains invalid symbol!";
            call symputx("EnvErr",1);
        end;

        if(prxMatch("/[0-9A-Za-z]{9,}/","&KeyVarsList.")) then do;
            put "&_PXLWAR. 'KeyVarsList=' macro parameter contains variable name with invalid length!";
            call symputx("EnvErr",1);
        end;
    run;



    %IF(&EnvErr.=0) %THEN %DO;


        %if ^%sysfunc(exist(&AdsLib..&AdsName.)) %then %do;
            %GmMessage(
                       CodeLocation = BMSSortColumns/Dataset existence check,
                           LinesOut = The &AdsName. dataset does not exist!,
                         SelectType = ABORT
                      );
        %end;


        data _NULL_;
            set &AdsLib..&AdsName.;
            by &KeyVarsList.;
        run;

        %if &SysErr. gt 0 %then %do;
            %GmMessage(
                       CodeLocation = BMSSortColumns/Dataset sorting check,
                           LinesOut = The &AdsName. dataset has incorrect sorting!,
                         SelectType = ABORT
                      );
        %end;



        proc contents data=&AdsLib..&AdsName. out=&BMSSortColumnsLib..&AdsName._VarList(keep=MEMNAME NAME MEMLABEL)
            directory mt=data
            noprint;
        run;

        %IF(&sysinfo.=0 and &syserr.=0) %THEN %DO;

            data &BMSSortColumnsLib..&AdsName._VarList;
                set &BMSSortColumnsLib..&AdsName._VarList;
                NAME=upcase(NAME);
            run;

            proc sort data=&BMSSortColumnsLib..&AdsName._VarList;
                by MEMNAME NAME;
            run;

            %let ADSL_Detected=0;
            data _NULL_;
                if(prxMatch("/adsl|addm/i","&AdsName.")) then do;
                    call symputx("ADSL_Detected",1);
                end;
            run;

            %if(&ADSL_Detected.=1) %then %do;
                %if("&KeyVarsList."^="") %then %do;
                    %let KeyVarsList=%sysfunc(tranwrd(%str(&KeyVarsList.),TRTP,TRT01P));
                    %let KeyVarsList=%sysfunc(tranwrd(%str(&KeyVarsList.),TRTA,TRT01A));
                %end;
                %if("&_comvars."^="") %then %do;
                    %let _comvarsLocal=%sysfunc(tranwrd(%str(&_comvars.),TRTP,TRT01P));
                    %let _comvarsLocal=%sysfunc(tranwrd(%str(&_comvarsLocal.),TRTA,TRT01A));
                %end;
            %end;
            %else %do;
                %let _comvarsLocal=&_comvars.;
            %end;

            %let REST_VAR_ORD_TMP=;
            %let AdsLabel=_EMPTY_;
            data _NULL_;
                set &BMSSortColumnsLib..&AdsName._VarList END=EOF;
                by MEMNAME NAME;
                length MacroVarIndCnt 8.;
                retain MacroVarIndCnt 1;

                if(first.MEMNAME) then do;
                    call symputx(cat("TMP_VAR_ORD",strip(put(MacroVarIndCnt,BEST.)))," ");
                    call symputx("MacroVarInd",strip(put(MacroVarIndCnt,BEST.)));
                    call symputx("REST_VAR_ORD_TMP",cat("&","TMP_VAR_ORD1","."));
                end;

                if(NAME ne "") then do;
                    if((length(resolve('&&TMP_VAR_ORD&MacroVarInd..'))+length(strip(NAME)))<259) then do;
                        call symputx(cat("TMP_VAR_ORD",strip(put(MacroVarIndCnt,BEST.))),cat(resolve('&&TMP_VAR_ORD&MacroVarInd..')," ",strip(NAME)));
                    end;
                    else if((length(resolve('&&TMP_VAR_ORD&MacroVarInd..'))+length(strip(NAME)))>=259) then do;
                        MacroVarIndCnt=MacroVarIndCnt+1;
                        call symputx(cat("TMP_VAR_ORD",strip(put(MacroVarIndCnt,BEST.)))," ");
                        call symputx("MacroVarInd",strip(put(MacroVarIndCnt,BEST.)));
                        call symputx(cat("TMP_VAR_ORD",strip(put(MacroVarIndCnt,BEST.))),cat(resolve('&&TMP_VAR_ORD&MacroVarInd..')," ",strip(NAME)));
                        call symputx("REST_VAR_ORD_TMP",cat(resolve('&REST_VAR_ORD_TMP.')," &","TMP_VAR_ORD",resolve('&MacroVarInd.'),"."));
                    end;
                end;
                if(EOF) then do;
                    if(MEMLABEL ne "") then do;
                        call symputx("AdsLabel",strip(MEMLABEL));
                    end;
                    else do;
                        put "&_PXLWAR. Analysis dataset has no label!";
                    end;
                end;
            run;

            %let REST_VAR_ORD=;
            %let REST_VAR_ORD=%upcase(&KeyVarsList. &_comvarsLocal. &REST_VAR_ORD_TMP.);



            data &AdsLib..&AdsName. %if("&AdsLabel."^="_EMPTY_") %then %do; (label="&AdsLabel.") %end;;
                retain &REST_VAR_ORD.;
                set &AdsLib..&AdsName.;
                by &KeyVarsList.;
            run;



            proc sort data=&AdsLib..&AdsName. out=&BMSSortColumnsLib..&AdsName._out
                                              dupout=&BMSSortColumnsLib..&AdsName._dup nodupkey;
                by &KeyVarsList.;
            run;

            data _NULL_;
                set &BMSSortColumnsLib..&AdsName._dup END=EOF;
                length cnt 8.;
                retain cnt 0;
                cnt=cnt+1;
                if(EOF) then do;
                    if(cnt>0) then do;
                        put "&_PXLWAR. The sorting key is not unique!";
                    end;
                end;
            run;

            %let      KeyVarsList=;
            %let    ADSL_Detected=;
            %let    _comvarsLocal=;
            %let REST_VAR_ORD_TMP=;
            %let         AdsLabel=;
            %let     TMP_VAR_ORD1=;
            %let     REST_VAR_ORD=;

        %END;

    %END;


%gmEnd(headURL = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmssortcolumns.sas $);

%mend BMSSortColumns;
