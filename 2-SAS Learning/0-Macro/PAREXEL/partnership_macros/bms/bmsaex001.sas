/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Roman Igla  $LastChangedBy: iglar $
  Creation Date:         23DEC2015 $LastChangedDate: 2016-02-26 03:53:12 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaex001.sas $

  Files Created:         N/A

  Program Purpose:       Produce the output dataset for Adverse Event tables based on GS_AE_T_X_001
                         standard BMS template.

                         This macro is PAREXEL’s intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL’s senior management.

                         This macro has been validated for use only in PAREXELs
                         working environment.
  Macro Parameters:

    Name:                dataOut
      Default Value:     REQUIRED
      Description:       The name of output dataset.


    Name:                where
      Default Value:     REQUIRED
      Description:       Where-condition to be used to filter the records for the analysis.


    Name:                selectColumns
      Allowed Values:    TRT|TOTAL|ALL
      Default Value:     TRT
      Description:       Specifies which columns will be reported in the output.
                         If selectColumn = TRT only by-treatment columns will be reported.
                         If selectColumn = TOTAL only total columns will be reported.
                         If selectColumn = ALL both by-treatment and total columns will be reported.

    Name:                varsBy
      Description:       The string in the following format:
                         #<variable-1>[\values=<value>, <value>, ...]
                         #@<variable-2>[\values=<value>, <value>, ...][\parent=<variable-name>]
                         #...
                         #Specifies the list of by-variables to be used in the macro.
                         #\values is used to create the blank lines if some values are not present in the
                         input dataset.
                         #\parent option is used to group variables when creating the blank records.
                         #See discussions for more details.

    Name:                dataIn
      Default Value:     analysis.adsl
      Description:       The name of the input dataset.
                         The default value can be reassigned in setup using variable BMSAE_DATAIN.

    Name:                trtNum
      Description:       The string in the following format:
                         #<variable-name>[\values=<value>, <value>, ...]
                         #The name of the numeric varaible with treatment number to be used for analysis.
                         #The list of valued can be specified if not all necessary values exist in the
                         input dataset, or the values should be presented in different order.
                         #See discussions for more details.
                         #The default value can be reassigned in setup using variable BMSAE_TRTNUM.
      Default Value:     trtan

    Name:                aeBodSys
      Default Value:     aeBodSys
      Description:       The name of the variable of System Organ Class.
                         The default value can be reassigned in setup using variable BMSAE_AEBODSYS.

    Name:                aeDecod
      Default Value:     aeDecod
      Description:       The name of the variable of Preferred Term.
                         The default value can be reassigned in setup using variable BMSAE_AEDECOD.

    Name:                popIn
      Default Value:     analysis.adsl
      Description:       The name of the dataset for population counts.
                         The default value can be reassigned in setup using variable BMSAE_POPIN.

    Name:                popTrtNum
      Default Value:     trt01an
      Description:       The name of numeric treatment variable in the population dataset.
                         The default value can be reassigned in setup using variable BMSAE_POPTRTNUM.

    Name:                popFlag
      Default Value:     %quote(saffl = "Y")
      Description:       The condition to be used for calculation the population for the analysis.
                         The condition is also added in the records selection from input dataset.
                         The default value can be reassigned in setup using variable BMSAE_POPFLAG.

    Name:                subjidVar
      Default Value:     usubjid
      Description:       The variable containing the subject ID.
                         The default value can be reassigned in setup using variable BMSAE_SUBJIDVAR.


    Name:                sortSoc
      Allowed Values:    ALPH|FREQ
      Default Value:     FREQ
      Description:       The order in which System Organ Classes are to be sorted.
                         When ALPH the SOCs will be sortd in alphabetic order.
                         #When FREQ the SOCs will be sortd in the oder of descending frequency then
                         alphabetically. The column to be sorted by is specified in sortCol parameter.

    Name:                sortPt
      Allowed Values:    ALPH|FREQ
      Default Value:     FREQ
      Description:       The order in which Preferred Terms are to be sorted.
                         When ALPH the PTs will be sortd in alphabetic order.
                         #When FREQ the PTs will be sortd in the oder of descending frequency then
                         alphabetically. The column to be sorted by is specified in sortCol parameter.

    Name:                sortCol
      Allowed Values:    TOTAL|<treatment number>
      Default Value:     TOTAL
      Description:       Specifies the column to be used for sorting when either sortSOC or sortPT is FREQ.
                         Any Grade column of specifed treatment group will be used for the sorting.

    Name:                cutPct
      Allowed Values:    <number>
      Default Value:
      Description:       If specified the PTs with percentage values below <number> will be removed.
                         The SOC records for SOCS having all the PTs removed will be removed as well.

    Name:                cutCol
      Allowed Values:    TOTAL|<treatment number>
      Default Value:
      Description:       If specified then cutPct will used the specified treatment to check the
                         percanges in. Any Grade column will be checked.
                         If not specified then cutPct will check that the percentage are below <number>
                         in Any Grade columns for all the treatment groups.

    Name:                subgroup
      Description:       The string in the following format:
                         #<variable-name>[\values=<value>, <value>, ...]
                         #Subgroup parameter enables by-subgroup analysis. Population and input datasets are
                         split by subgroup and the analysis is performed for each subgroup separately.
                         #The values option is used to report the subgroups with no data in the
                         population or input datasets
                         #See discussions for more details.

    Name:                subgroupn
      Description:       The string in the following format:
                         #<variable-name>[\values=<value>, <value>, ...]
                         #The numeric variable for subgroups if there is a need to sort other than
                         alpabetically.

    Name:                putLen
      Allowed Values:    <integer number>
      Default Value:     4
      Description:       Number of places to put the incedence count in: put(count, &putLen..)

    Name:                resultColWidth
      Allowed Values:    <integer number>
      Default Value:     Calcualated
      Description:       Specifies the width of the column with numbers.
                         If not specified then is calculated as &putLen.+8.

    Name:                termColWidth
      Allowed Values:    <integer number>
      Default Value:     Calcualated
      Description:       Specifies the width of the column with SOCs and PTs values.
                         The macro splits the terms to fit in this column by inserting ~ symbol.
                         gmModifySplit is used for this purpose.
                         If not specified then is calculated using resultColWidth value, number of
                         columns and dpscing equal to 1. If the resulting width is less than 15 the error
                         is generated and the width is requested to be set directly in the macro call.

    Name:                totalStr
      Default Value:     "TOTAL SUBJECTS WITH AN EVENT"
      Description:       The string to be reported in the first row of the table.

    Name:                selectType
      Allowed Values:    N|NOTE|E|ERROR|ABORT
      Default Value:     E
      Description:       The value for selectType parameter in gmModifySplit macro to be used
                         to split SOC and/or PT values. See gmModifySplit for details.


  Global Macrovariables:

    Name:                nYYY
      Usage:             create/modify
      Description:       Number of subjects in treatment group YYY, calculated based on popIn dataset.
                         The values of YYY are taken from trtNum parameter.
                         These macrovariables are created when no subgroup or subgroupN are specified.

    Name:                subgroupXXXnYYY
      Usage:             create/modify
      Description:       Contains number of subjects in subgroup XXX in treatment group YYY, calculated based on
                         popIn dataset. The values of YYY are taken from trtNum parameter.
                         If subgroupN is specified then the values of XXX are taken from subgroupN parameter, otherwise
                         the values of XXX are the numbers 1, 2, 3, etc that correspond to subgroup parameter values set
                         in aplhabetic order.
                         Created when subgroup and/or subgroupN parameters are specified.

    Name:                bigNList
      Usage:             create/modify
      Description:       The list of values nYYY or subgroupXXXnYYY separated by whitespaces.
                         The order corresponds to the order in which the treatment columns and subgroups should appear
                         in the output.



  Macro Dependencies:    gmMessage (called)
                         #gmStart (called)
                         #gmEnd (called)
                         #gmParseParameters (called)
                         #bmsAeInitData (called)
                         #bmsCreatePopDs (called)
                         #bmsFreq (called)
                         #bmsAeSort (called)
                         #bmsAeCutoff (called)
                         #bmsAeFinalize (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1874 $
-----------------------------------------------------------------------------*/





%macro bmsaex001(dataOut=, where=, selectColumns=TRT, cutPct=, cutCol=,
                 varsBy=, TotalStr="TOTAL SUBJECTS WITH AN EVENT",
                 sortSOC=FREQ, sortPT=FREQ, sortCol=TOTAL,
                 dataIn=, trtNum=, aebodsys=, aedecod=,
                 SubjidVar=, PopIn=, PopTrtNum=, PopFlag=,
                 putLen=4, termColWidth= , resultColWidth=,
                 subgroup=, subgroupn=, selectType=E);

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaex001.sas $
          , revision = $Rev: 1874 $
          ,checkMinSasVersion = 9.2
          );


    %local ds aevars AETemplate;
    %let ds = _aetx001_;
    %let varprefix = _ae_var_;

    %let codeFile = %quote(bmsaex001.sas);

    %let tranPrefix = trt;

    %if %str(&dataOut) =  %str() %then %do;
        %gmMessage(codelocation=&codefile.,
                linesout=%str(The required parameter (dataOut) is not specified.),
                selectType=ABORT);
    %end;

    %if %length(&where) = 0 %then %do;
        %gmMessage(codelocation=&codefile.,
                linesout=%str(The required parameter (where) is not specified.),
                selectType=ABORT);
    %end;



    %* Assign default values for parameters where needed; %*;

    %BMSAEINITDATA(BMS_AE_INPUT_VARS =
        DATAIN
        TRTNUM
        AEBODSYS
        AEDECOD
        SUBJIDVAR
        POPIN
        POPTRTNUM
        POPFLAG);


    %* Process subgroup paramters:                        ; %*;
    %* Subgroups are added to by-variables                ; %*;
    %if %index(&subgroup, @) > 0 %then %do;
        %gmMessage(codelocation=&codefile.,
                linesout=%str(Subgroup parameter cannot contain @ symbol),
                selectType=ABORT,
                splitchar = #);
    %end;

    %if %index(&subgroupn, @) > 0 %then %do;
        %gmMessage(codelocation=&codefile.,
                linesout=%str(SubgroupN parameter cannot contain @ symbol),
                selectType=ABORT,
                splitchar = #);
    %end;

    %if &subgroupN. ne %then
        %let varsby = &varsby.@&subgroupN \type=subgroupN \parent=_ae_subgroup;

    %if &subgroup. ne %then
        %let varsby = &varsby.@&subgroup \type=subgroup \parent=_ae_subgroup;

    %if &varsby. ne %then %do;
        %if %substr(%str(&varsby.), 1, 1) = @ %then %let varsby = %qsubstr(&varsby., 2);
    %end;


    %* Subgroup variable and values are retrieved for later use            ; %*;
    %* Create dataset &ds.varsby with by-variables                         ; %*;

    %let varsbyds=;
    %let subgroupVar=;
    %let subgroupVal=;
    %let subgroupVarType=;
    %if &varsby. ne %then %do;
        %gmParseParameters( parameters        = %quote(&varsby.)
                          , optionsDefinition = values
                                               @parent
                                               @type
                                               @renameFrom
                          , dataOut           = &ds.varsby
        );

        data _null_;
            set &ds.varsby end = last;
            length varsby  subgroupVar subgroupVal subgroupVarType $2000. ;
            retain varsby "" subgroupVar "" subgroupVal "" subgroupVarType "" ;
            varsby = trim(varsby) || " " || parameter;


            if strip(lowcase(typeValue))  = "subgroup" then do;
                if missing(subgroupVar) then subgroupVar = strip(parameter);
                if missing(subgroupVal) then subgroupVal = strip(valuesValue);
                if missing(subgroupVarType) then subgroupVarType = "character";

            end;

            if strip(lowcase(typeValue))  = "subgroupn" then do;
                subgroupVar = strip(parameter);
                subgroupVal = strip(valuesValue);
                subgroupVarType = "numeric";
            end;

            if last then do;
                call symput("varsby", strip(varsby));
                call symput("varsbyds", "&ds.varsby");
                call symput("subgroupVar", strip(subgroupVar));
                call symput("subgroupVarType", strip(subgroupVarType));
                call symput("subgroupVal", strip(subgroupVal));
            end;
        run;
    %end;


    %* Process trtNum parameter: retrieve var and values for later use      ; %*;

    %if %index(&trtNum, @) > 0 %then %do;
        %gmMessage(codelocation=&codefile.,
                linesout=%str(trtNum parameter cannot contain @ symbol),
                selectType=ABORT,
                splitchar = #);
    %end;

    %gmParseParameters( parameters        = %quote(&trtnum.)
                      , optionsDefinition = values
                      , dataOut           = &ds.trtnum
    );

    data _null_;
        set &ds.trtNum;
        call symput("trtnum", trim(parameter));
        call symput("trtValues", strip(valuesValue));
    run;

    %let popFlagUpdated = &popFlag.;
    %if &trtValues ne %then %do;
        %let popFlagUpdated = &popFlag. and &PopTrtNum. in (&trtValues.);
        %let where = &where. and &TrtNum. in (&trtValues.);
    %end;

    %* Prepare the Population dataset for BMSFreq (_bms_popds) ;;
    %let popBy =;
    %if &subgroupVar. ne %then %do;
        %let popby = &subgroupVar.;
        %if %str(&subgroupVal.) ne %then %let popBy = &popBy.(&subgroupVal.);
    %end;

    %BMScreatepopds(popds=&popin., popCond=%str(&popFlagUpdated.), trtValues = %quote(&trtValues.),
                    poptrtCode=&PopTrtNum., trtCode=&trtNum,
                    byvars = %quote(&popBy.));

    %* Calculate global macro-variables with big N values ;;

    %if &trtValues = %then %do;
        proc sort data = _bms_popds out = &ds.trtgroups(keep = &trtNum.) nodupkey;
            by &trtNum.;
        run;

        proc sort data = _bms_popds;
            by &subgroupVar &trtNum;
        run;

        %let toBigNDs = _bms_popds;
    %end;
    %else %do;
        data &ds.trtgroups;
            &varPrefix.trtOrder = 0;
            do &trtNum. = &trtvalues;
                &varPrefix.trtOrder + 1;
                output;
            end;
        run;

        proc sort data = &ds.trtgroups out = &ds.trtgroups_sorted;
            by &trtNum.;
        run;

        data &ds._bms_popds;
            merge _bms_popds &ds.trtgroups_sorted;
            by &trtNum.;
        run;

        proc sort data = &ds._bms_popds;
            by &subgroupVar &varPrefix.trtOrder;
        run;

        %let toBigNDs = &ds._bms_popds;
    %end;

    data _null_;
        length bigNList varname $200.;
        retain bigNList "";
        retain &varPrefix.total 0;
        set &toBigNDs. end = &varPrefix.last;
        %if &subgroupVar ne %then %do;
            by &subgroupVar;
            if first.&subgroupVar then &varPrefix.total = 0;
            %if &subgroupVarType. = character %then %do;
                retain &varPrefix.subgroupNum 0;
                if first.&subgroupVar. then &varPrefix.subgroupNum + 1;
                varname = "subgroup" || compress(put(&varPrefix.subgroupNum, best.))
                    || "N" || compress(put(&trtNum., best.));
            %end;
            %else %do;
                varname = "subgroup" || compress(put(&subgroupVar., best.))
                    || "N" || compress(put(&trtNum., best.));
            %end;
        %end;
        %else %do;
            varname = "N" || compress(put(&trtNum., best.));
        %end;

        %if %upcase(&selectColumns.) = ALL or %upcase(&selectColumns.) = TRT %then %do;
            call execute('%global ' || strip(varName) || ";");
            call symput(strip(varName), compress(put(popCount, best.)));
            bigNList = trim(bigNList) || " " || compress(put(popCount, best.));
        %end;

        &varPrefix.total = &varPrefix.total + popCount;

        %if %upcase(&selectColumns.) = ALL or %upcase(&selectColumns.) = TOTAL %then %do;
            %if &subgroupVar ne %then %do;
                if last.&subgroupVar then do;
                    %if &subgroupVarType. = character %then %do;
                        varname = "subgroup" || compress(put(&varPrefix.subgroupNum, best.))
                            || "NTotal";
                    %end;
                    %else %do;
                              varname = "subgroup" || compress(put(&subgroupVar., best.))
                            || "NTotal";
                    %end;
                    call execute('%global ' || strip(varName) || ";");
                    call symput(strip(varName), compress(put(&varPrefix.total, best.)));
                    bigNList = trim(bigNList) || " " || compress(put(&varPrefix.total, best.));
                end;
            %end;
            %else %do;
                if &varPrefix.last then do;
                    varname = "NTotal";
                    call execute('%global ' || strip(varName) || ";");
                    call symput(strip(varName), compress(put(&varPrefix.total, best.)));
                    bigNList = trim(bigNList) || " " || compress(put(&varPrefix.total, best.));
                end;
            %end;
       %end;


        if &varPrefix.last then do;
            call execute('%global bigNList;');
            call symput("bigNList", strip(bigNList));
        end;
    run;

    %* Create the macro variables columnNumber, columnList and renameColumnList with      ;;
    %* the number and list of columns in the final output                                 ;;
    data _null_;
        set &ds.trtgroups end = _last_trt;
        call symput("trt" || compress(put(_n_, 5.)), compress(put(&trtNum,best.)));
        if _last_trt then call symput("trtCount", compress(put(_n_, 5.)));
    run;

    %let columnNumber = 0;
    %let columnList = ;
    %let renameColumnList = ;
    %let addTotal = No ;
    %if %upcase(&selectColumns.) = ALL or %upcase(&selectColumns.) = TRT %then %do;
        %let columnNumber = &trtCount.;
        %do i = 1 %to &trtCount.;
            %let columnList = &columnList. &tranPrefix.&&trt&i..;
        %end;
    %end;
    %if %upcase(&selectColumns.) = ALL or %upcase(&selectColumns.) = TOTAL %then %do;
        %let columnList = &columnList. &tranPrefix.Total;
        %let columnNumber = %eval(&columnNumber + 1);
        %let addTotal = YES;
    %end;

    %if %lowcase(&sortCol.) = total or %lowcase(&cutCol.) = total %then %let addTotal = YES;


    %* Update the input dataset for use in bmsfreq macro;;
    data &ds.;
        set &dataIn.;
        _aetotstr = &TotalStr.;
    run;

    %* Run bmsfreq macro                                ;;

    %BMSfreq(DataIn=&ds., DataOut=&ds.0, Where=&where., Vars=_aetotstr &aebodsys. &aedecod.,
             Count=&SubjidVar,
             Trt=&trtNum., VarsBy=&varsby., Sorttype=ALPH, Sort=,
             keep_num=YES, keep_vars=YES,
             Percent=POP,  PopDS=_bms_popds, addTotal=&addTotal, popby= &subgroupVar.,
             Putmiss=END,  Missing_word="NOT REPORTED",
             Label="",     FreqPut=&putLen., Shift=0, Transpose=&trtNum.,
             tranPrefix = &tranPrefix.);


    %* Remove the records with percentage smaller than specified          ;;
    %if &cutPct ne %then %do;
        %let cutvarlist=;
        %if &cutCol = %then %do;
            %if %upcase(&selectColumns.) = ALL or %upcase(&selectColumns.) = TRT %then %do;
                %do i = 1 %to &trtCount.;
                    %let cutvarlist = &cutvarlist. _freq_p_&aedecod._&&trt&i..;
                %end;
            %end;
            %if %upcase(&selectColumns.) = ALL or %upcase(&selectColumns.) = TOTAL %then %do;
                %let cutvarlist = &cutvarlist. _freq_p_&aedecod._total;
            %end;

        %end;
        %else %do;
            %let cutColChecked = 0;
            %if %lowcase(&cutCol) = total %then %let cutColChecked = 1;
            %do i = 1 %to &trtCount.;
                %if  %lowcase(&cutCol) = %lowcase(&&trt&i..) %then %let cutColChecked = 1;
            %end;
            %if &cutColChecked. = 0 %then
                %gmMessage(codelocation=&codefile.,
                    linesout=Incorrect value of cutCol parameter. Should be either total or treatment number.,
                    selectType=ABORT);
            %let cutvarlist = _freq_p_&aedecod._&cutCol.;

        %end;

        %bmsAeCutOff(dataIn=&ds.0, dataOut=&ds.cut, cutValue=&cutPct, cutVarList = &cutvarlist.,
                     varsby = &varsby., terms = 2);

        %let toSort = &ds.cut;
    %end;
    %else %let toSort = &ds.0;


    %* Re-Sort the dataset                                               ;;
    %let sortOrder = desc;
    %if %upcase(&sortSoc.) = ALPH %then %let sortOrder = &sortOrder ASCE;
        %else %let sortOrder = &sortOrder DESC;

    %if %upcase(&sortPT.) = ALPH %then %let sortOrder = &sortOrder ASCE;
        %else %let sortOrder = &sortOrder DESC;

    %bmsaesort(
                  SORT_DATAIN = &toSort,
                 SORT_DATAOUT = &ds.1,
                  SORT_BYVARS = &varsby.,
                    SORT_VARS = _aetotstr &aebodsys. &aedecod.,
                    SORT_TYPE = alph &sortSoc. &sortPt.,
                   SORT_ORDER = &sortOrder.,
                  SORT_COLUMN = &sortCol,
                  SORT_SUFFIX =
                );



    %* Finalize the dataset:
        1) add missing rows if need
        2) split the terms to fit the first column
        3) keep and rename the variables ;;
    %bmsAeFinalize(dataIn= &ds.1, dataOut = &dataout., putLen=&putLen,
                   termColWidth= &termColWidth, resultColWidth=&resultColWidth,
                   columnList = &columnList., columnNumber=&columnNumber.,
                   terms = 2, varsby=&varsby., varsbyds=&varsbyds.,
                   popIn = &popIn. , popFlag = %quote(&popFlag.), TotalStr=&TotalStr, selectType = &selectType.);

    proc datasets nolist;
         delete _bms_popds &ds: /mt=data;
    quit;

    %gmEnd(headURL  = $    $);


%mend bmsaex001;
