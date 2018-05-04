/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Sergey Proskurnin $LastChangedBy: iglar $
  Creation Date:         24APR2015       $LastChangedDate: 2016-02-26 03:53:12 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaecutoff.sas $

  Files Created:         N/A

  Program Purpose:       This macro modifies input dataset through deleting records which not satisfy the cut-condition;

                         This macro is PAREXEL’s intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL’s senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                dataIn
      Default Value:     REQUIRED
      Description:       Disposition and name of input dataset

    Name:                dataOut
      Default Value:     REQUIRED
      Description:       Name of resulting dataset

    Name:                cutValue
      Default Value:     REQUIRED
      Description:       Threshold level for cut-off, in percents: fraction number, in number of patients: integer

    Name:                cutVarList
      Default Value:     REQUIRED
      Description:       List of variables on by cut-off

    Name:                varsBy
      Description:       List of by variables

    Name:                terms
      Allowed Values:    1|2
      Default Value:     REQUIRED
      Description:       Number of terms to be reported in AE table.
                         #terms should be set to 1 if either SOCs or PTs are reported in the table.
                         #terms should be set to 2 if both SOCs and PTs are reported in the table.

  Macro Dependencies:    gmMessage (called)
                         #gmStart (called)
                         #gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1874 $
-----------------------------------------------------------------------------*/

%macro bmsAeCutOff(dataIn=, dataOut=, cutVarList=, cutValue=, varsby=, terms=);

  %let socsort=sort2;
  %let union=or;

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaecutoff.sas $
          , revision = $Rev: 1874 $
          ,checkMinSasVersion = 9.2
          );

    * Test of terms parameter;
    %if &terms ne 1 and &terms ne 2 %then %do;
           %gmMessage(codelocation=bmsaecutoff.sas,
                    linesout=%str(Terms not in (1,2)),
                    selectType=ABORT);
    %end;

    *Creating condition for cutting input dataset;
    data _null_;
        length condition cutVarListWC $200.;

        condition = prxChange("s/\ / >= %sysevalf(&cutValue.) &union. /",-1,
                              prxChange("s/\ \ */ /",-1, "&cutVarList.")) || " >= %sysevalf(&cutValue.)";
        call symput("condition", condition);

        cutVarListWC = prxChange("s/\ /%str(,)/", -1, "&cutVarList.");
        call symput("cutVarListWC", cutVarListWC);
        call symput("lencvl", strip(put(countw("&cutVarList."), 2.)));

        if strip("&varsby.")="" then do;
            call symput("varsbystat_sql", " ");
        end;
        else do;
            call symput("varsbystat_sql", "%sysfunc(prxChange(%sysfunc(prxparse(s/\ /%str(,)/)),-1,&varsby.)),");
        end;
    run;

    proc sql noprint;
        create table _bmscutoff1 as
        select *
        from &dataIn.
        (where = (%if &terms. eq 2 %then %do; &socsort. eq -2 or %end; %else %do; sort1 < 0 or %end;
                  cmiss(&cutVarListWC.) eq &lencvl. or &condition.));
    quit;

    %if &terms eq 2 %then %do;
        proc sql noprint;
            create table _bmscutoff2 as
            select *, count(&socsort.) as reccount
            from _bmscutoff1
            group by  &varsbystat_sql. &socsort.;
        quit;

        proc sql noprint;
            create table &dataOut. as
            select *
            from _bmscutoff2
            where not (reccount eq 1 and &socsort. ne -2);

            alter table &dataOut. drop reccount;
        quit;
    %end;
    %else %do;
        data &dataOut.;
            set _bmscutoff1;
        run;
    %end;

    %if not %symExist(gmDebug) %then %let gmDebug = 0;
    %if &gmDebug. = 0 %then %do;
        proc datasets library=work nolist memtype=data;
            delete _bmscutoff:;
        quit;
    %end;

    %gmEnd(headURL  = $    $);

%mend bmsAeCutOff;
