/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Roman Igla  $LastChangedBy: iglar $
  Creation Date:         02JAN2016 $LastChangedDate: 2016-02-26 03:53:12 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaefinalize.sas $

  Files Created:         N/A

  Program Purpose:       Macro bmsAeFinalize performs the final modifications of the dataset in
                         the macros that create output datasets for BMS standard AE templates.
                         It adjusts and splits System Organ Class and Preferred Term values and adds
                         rows and columns with zeroes where necessary.

                         This macro is PAREXEL’s intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL’s senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.

  Macro Parameters:

    Name:                dataIn
      Default Value:     REQUIRED
      Description:       The name of input dataset.

    Name:                dataOut
      Default Value:     REQUIRED
      Description:       The name of output dataset.


    Name:                varsBy
      Description:       Specifies the list of by-variables separated by spaces to be used in the macro.

    Name:                varsByDs
      Description:       The name of the dataset with additional information on by-variables.
                         #The dataset must have the format format of the gmParseParameters output
                         dataset with the following options:
                         #\values - list of values of by-variable;
                         #\parent - the name of the variable to group the by-variables in;
                         #\type = subgroup or subgroupn for subgroups (&popIn will be used to take values
                         in this case), <missing> for all other cases (&dataIn will be used to take values
                         from);
                         #\renameFrom - the name of the origial variable in popIn dataset, option is
                         used only together with \type = subgroup or subgroupn.

    Name:                popIn
      Description:       The name of the dataset for population counts.
                         &popIn. is used to take the list of values for subgroups.


    Name:                popFlag
      Description:       The condition to be used for calculation the population for the analysis.
                         &popFlag. is used to take the list of values for subgroups.

    Name:                putLen
      Allowed Values:    <integer number>
      Default Value:     4
      Description:       Number of places to put the incedence count in: put(count, &putLen..)

    Name:                resultColWidth
      Allowed Values:    <integer number>
      Default Value:     Calculated
      Description:       Specifies the width of the column with numbers.
                         If not specified then is calculated as &putLen.+8.

    Name:                termColWidth
      Allowed Values:    <integer number>
      Default Value:     Calculated
      Description:       Specifies the width of the column with SOCs and PTs values.
                         The macro splits the terms to fit in this column by inserting ~ symbol.
                         gmModifySplit is used for this purpose.
                         If not specified then is calculated using resultColWidth value, number of
                         columns and dpscing equal to 1. If the resulting width is less than 15 the error
                         is generated and the width is requested to be set directly in the macro call.

    Name:                columnNumber
      Default Value:     REQUIRED
      Allowed Values:    <integer number>
      Description:       Number of columns with results.

    Name:                columnList
      Default Value:     REQUIRED
      Description:       The list of variables containing incedence and percentages in dataIn dataset.

    Name:                renameColumnList
      Description:       Optional. The list of new names for &columnList. variables. If specified, must be
                         consistent with &columnList.

    Name:                terms
      Allowed Values:    1|2
      Default Value:     REQUIRED
      Description:       Number of terms to be reported in the table.
                         #terms should be set to 1 if either SOCs or PTs are reported in the table.
                         #terms should be set to 2 if both SOCs and PTs are reported in the table.

    Name:                shift
      Allowed Values:    <integer number>
      Default Value:     2
      Description:       Number of spaces to adjust PT values if both SOCs and PTs are reported in
                         the table.

    Name:                totalStr
      Default Value:     "TOTAL SUBJECTS WITH AN EVENT"
      Description:       The string to be reported in the first row of the table.

    Name:                selectType
      Allowed Values:    N/NOTE/E/ERROR/ABORT
      Default Value:     E
      Description:       The value for selectType parameter in gmModifySplit macro to be used
                         to split SOC and/or PT values.  See gmModifySplit for details.

  Macro Returnvalue:     N/A

  Metadata Keys:

    Name:
      Description:
      Dataset:

  Macro Dependencies:    gmMessage (called)
                         #gmStart (called)
                         #gmEnd (called)
                         #gmModifySplit (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1874 $
-----------------------------------------------------------------------------*/


%macro bmsAeFinalize(dataIn =, dataOut=, putLen=4, termColWidth= , resultColWidth=,
                          columnList = , columnNumber=, renameColumnList=, shift = 2, terms =,
                          varsby=, varsbyds=, popIn =, popFlag=, TotalStr="TOTAL SUBJECTS WITH AN EVENT",
                          selectType = E);

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaefinalize.sas $
          , revision = $Rev: 1874 $
          ,checkMinSasVersion = 9.2
          );


    %let CodeFile = %str(bmsaefinalize.sas);

    %let aeplxerr = ERROR: [PXL];

    %macro get_var_type(var=, ds=);
        %local freq_GetVardsid;
        %local freq_GetVarcolno;
        %local freq_GetVartype;
        %local freq_GetVarrc;
        %let freq_GetVardsid  = %sysfunc(open(&ds.,I));
        %let freq_GetVarcolno = %sysfunc(varnum(&freq_GetVardsid,&var));
        %let freq_GetVartype=%sysfunc(vartype(&freq_GetVardsid,&freq_GetVarcolno));

        %if &freq_GetVartype=N %then %do; 0 %end;
        %else %do; %sysfunc(varlen(&freq_GetVardsid,&freq_GetVarcolno)) %end;
        %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
    %mend  get_var_type;

    %if &terms ne 1 and &terms. ne 2 %then
        %gmMessage(codelocation=&codefile.,
                   linesout=%str(Incorrect value of Terms parameter: must be either 1 or 2.),
                   selectType=ABORT);


    %let dsPrefix = _gsae_final_;

    %if &varsbyds ne %then %do;

        %let byvarCount = 1;
        %let byvar1 = %scan(&varsby, 1);
        %do %while (&&byvar&byvarCount.. ne );
            %let byvar&byvarCount.type =  %get_var_type(var=&&byvar&byvarCount.., ds=&dataIn.);
            %let byvarCount = %eval(&byvarCount+1);
            %let byvar&byvarCount. = %scan(&varsby, &byvarCount.);
        %end;
        %let byvarCount = %eval(&byvarCount-1);


        data &dsPrefix.varsbyDsupdated;
            set &varsbyds.;
            length parent $200.;
            if parentExists = 1 then parent = strip(parentValue);
                else parent = parameter;

            %do i = 1 %to &byvarCount.;
                if %lowcase(parameter) = lowcase("&&byvar&i..")
                    then parameterType = &&byvar&i.type..;
            %end;
        run;

        proc sort data = &dsPrefix.varsbyDsupdated;
            by parent valuesExists number;
        run;


        %let dummyErrs = 0;

        data _null_;
            set &dsPrefix.varsbyDsupdated end = last;
            retain dummyErrs 0;
            by parent valuesExists;
            if first.parent ne first.valuesExists and dummyErrs = 0 then do;
                put "&aeplxerr. Incorrect use of values option, should be set either for all or no variables
 within one parent group: " parent=;
                dummyErrs = 1;
                call symput("dummyErrs", "1");
                stop;
            end;

            if valuesExists = 1 then do;
                if parameterType = 0 and (index(valuesValue, "'") > 0 or index(valuesValue, '"') > 0)
                    or parameterType > 0 and (index(valuesValue, "'") = 0 and index(valuesValue, '"') = 0)
                then do;
                    put "&aeplxerr. Inconsistent types of variables and values for by-variable " parameter;
                    dummyErrs = 1;
                    call symput("dummyErrs", "1");
                    stop;
                end;

                call execute("data &dsPrefix.dummy" || compress(put(number, best.)) || ";");
                if parameterType > 0 then do;
                    call execute("length " || trim(parameter) || " $"
                                || compress(put(parameterType, best.))
                                || ".;");
                end;
                if not (first.parent and last.parent) then
                    call execute("_bms_aefin_obsCount = 0;");
                call execute("do " || trim(parameter) || " = " || trim(valuesValue) || ";");
                if not (first.parent and last.parent) then
                    call execute("_bms_aefin_obsCount = _bms_aefin_obsCount + 1;");
                call execute("output; end; run;");
            end;
            else do;
                length paramlist renameList inds $2000.;
                retain paramlist renameList;
                if first.parent then do;
                    paramlist = "";
                    renameList = "";
                end;
                if renameFromExists then do;
                    paramlist = trim(paramlist) || " " || trim(renameFromValue);
                    renameList = trim(renameList) || " " || strip(renameFromValue) || "=" || strip(parameter);
                end;
                else paramlist = trim(paramlist) || " " || trim(parameter);

                if last.parent then do;
                    if lowcase(strip(typeValue)) in ("subgroup" "subgroupn") then
                        inds = '&popIn. (where = (%str(&popFlag.)))';
                    else inds = '&dataIn.';
                    call execute("proc sort data = " || trim(inds) || " out = &dsPrefix.dummy"
                                ||trim(parent) );
                    call execute("(keep = " || trim(paramlist)
                                || ifc(not missing(renameList), " rename = (" || strip(renameList) || ")", "")
                                || ") nodupkey;");
                    call execute("by " || trim(paramlist) || "; run;");
                end;
            end;

            length dsListForSql $2000.;
            retain dsListForSql;
            if first.parent and last.parent and valuesExists = 1 then
                dsListForSql = trim(dsListForSql) || ", &dsPrefix.dummy" || compress(put(number, best.));
            else if last.parent then
                dsListForSql = trim(dsListForSql) || ", &dsPrefix.dummy" || strip(parent);

            if last then call symput("dsListForSql", substr(dsListForSql, 3));

            if not (first.parent and last.parent) and valuesExists = 1 then do;
                length dsSetList inSumLine $200;
                retain dsSetList inSumLine inCount; * to set the dummy datasets for the same parent together.;

                if first.parent then do;
                    dsSetList = "";
                    inSumLine = "_bms_aefin_in" || compress(put(number, best.));
                    inCount = 1;
                end;
                else do;
                    inSumLine = trim(inSumLine) || "+_bms_aefin_in" || compress(put(number, best.));
                    inCount = inCount + 1;
                end;

                dsSetList = trim(dsSetList) || "&dsPrefix.dummy" || compress(put(number, best.))
                    || "(in = _bms_aefin_in"  || compress(put(number, best.)) || ")";



                if last.parent then do;
                    call execute("data &dsPrefix.dummy" || strip(parent) || ";");
                    call execute("merge " || strip(dsSetList) || ";");
                    call execute("by _bms_aefin_obsCount;");
                    call execute("if " || strip(inSumLine) || " < " || compress(put(inCount, best.))
                                 || " then do;"
                                );
                    call execute('put "ERR" "OR: [PXL] Different number of values for the same parent group: '
                                 || strip(parent) ||'";');
                    call execute("call symput('dummyErrs' , '1');");
                    call execute("end;");
                    call execute("drop _bms_aefin_obsCount;");
                    call execute("run;");

                end;
            end;

        run;

        %if &dummyErrs. = 1 %then %do;
            %gmMessage(codelocation=&codefile.,
                    linesout=%str(Macro stopped working due to the errors above.),
                    selectType=ABORT);
        %end;

        proc sql noprint;
            create table &dsPrefix.dummyPrep as
            select * from &dsListForSql.
            ;
        quit;

        proc sort data = &dsPrefix.dummyPrep;
            by &varsby.;
        run;


        data &dsPrefix.dummy;
            set &dsPrefix.dummyPrep;
            %do i = 1 %to %eval(&terms+1);
                grpxSort&i. = 1;
            %end;
            length vars $200.;
            vars = &TotalStr.;
        run;

        proc sort data = &dataIn. out = &dsPrefix.dataInSorted;
            by &varsby. grpxSort1 - grpxSort%eval(&terms+1) vars;
        run;




        data &dsPrefix.dataInUpdated;
            merge &dsPrefix.dataInSorted &dsPrefix.dummy;
            by &varsby. grpxSort1 - grpxSort%eval(&terms+1) vars;
        run;

        %if &syserr>6 %then %do;
            %gmMessage(codelocation=&codefile.,
                           linesout=Incorrect type of values used. See above.,
                           selectType=ABORT);
        %end;

        proc sort data = &dsPrefix.dataInUpdated;
            by &varsBy grpxSort1 - grpxSort%eval(&terms+1);
        run;

    %end;
    %else %do;
        data &dsPrefix.dummy;
            %do i = 1 %to %eval(&terms+1);
                grpxSort&i. = 1;
            %end;
            length vars $200.;
            vars = &TotalStr.;
        run;

        proc sort data = &dataIn. out = &dsPrefix.dataInSorted;
            by grpxSort1 - grpxSort%eval(&terms+1) vars;
        run;

        data &dsPrefix.dataInUpdated;
            merge &dsPrefix.dataInSorted &dsPrefix.dummy;
            by grpxSort1 - grpxSort%eval(&terms+1) vars;
        run;

        proc sort data = &dsPrefix.dataInUpdated;
            by &varsBy grpxSort1 - grpxSort%eval(&terms+1);
        run;

    %end;




    %if &resultColWidth = %then %let resultColWidth = %eval(&putLen + 8);
    %if &termColWidth = %then %do;
        %let termColWidth = %eval(&_ls. - (&resultColWidth + 1) * &columnNumber.);
        %if &termColWidth < 15 %then
            %gmMessage(codelocation=&codefile.,
                linesout=%str(The macro cannot autofit the columns correctly, please assign parameter termColWidth manually),
                selectType=ABORT);
    %end;

    data &dsPrefix.final;
        set &dsPrefix.dataInUpdated;
        length &columnList. $200.;

        %if &terms = 1 %then %do;
            %gmModifySplit(var = vars, width = &termColWidth., delimiter = ~, selectType = &selectType.);
        %end;
        %else %if &terms = 2 %then %do;
            if grpxSort3 = 1 then do;
                %gmModifySplit(var = vars, width = &termColWidth., delimiter = ~, selectType = &selectType.);
            end;
            else do;
                %gmModifySplit(var = vars, width = &termColWidth., delimiter = ~, indentSize = &shift., selectType = &selectType.);
            end;
        %end;
        vars = trim(vars) || "~";


        %do i = 1 %to &columnNumber;
            %let column = %scan(&columnList., &i.);
            if missing(&column) then &column. = put(0, &putlen..);
        %end;

        keep &varsBy. vars &columnList grpxSort: ;

        %if &renameColumnList ne %then %do;
            %do i = 1 %to &columnNumber;
                %let column = %scan(&columnList., &i.);
                %let renameColumn = %scan(&renameColumnList., &i.);
                rename &column = &renameColumn;
            %end;
        %end;

    run;


    %let keep_vars = &varsBy. ;
    %do i = 1 %to %eval(&terms + 1);
        %let keep_vars = &keep_vars. grpxSort&i.;
    %end;
    %if &renameColumnList = %then %let renameColumnList = &columnList.;
    %let keep_vars = &keep_vars. vars &renameColumnList;


    proc sql noprint;
        create table &dataOut. as
        select %sysfunc(tranwrd(%cmpres(&keep_vars.),%str( ),%str(,))) from &dsPrefix.final;
    quit;

%if not %symExist(gmDebug) %then %let gmDebug = 0;

%if &gmDebug. = 0 %then %do;
    proc datasets nolist;
         delete &dsPrefix.: /mt=data;
    quit;
%end;

    %gmEnd(headURL  = $    $);


%mend bmsAeFinalize;
