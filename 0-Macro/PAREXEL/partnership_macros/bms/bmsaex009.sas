/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Roman Igla  $LastChangedBy: iglar $
  Creation Date:         23DEC2015 $LastChangedDate: 2016-02-26 03:53:12 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaex009.sas $

  Files Created:         N/A

  Program Purpose:       Produce the output dataset for Adverse Event tables based on GS_AE_T_X_009
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
      Allowed Values:
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

    Name:                trtName
      Description:       The string in the following format:
                         #<variable-name>[\values=<value>, <value>, ...]
                         #The name of the character varaible with treatment value to be used for analysis.
                         #The list of valued can be specified if not all necessary values exist in the
                         input dataset.
                         #See discussions for more details.
                         #The default value can be reassigned in setup using variable BMSAE_TRTNAME.
      Default Value:     trta


    Name:                aeDecod
      Default Value:     aeDecod
      Description:       The name of the variable of Preferred Term.
                         The default value can be reassigned in setup using variable BMSAE_AEDECOD.

    Name:                aeToxGrN
      Default Value:     aeToxGrN
      Description:       The name of the variable of CTC Toxicity Grade.
                         The default value can be reassigned in setup using variable BMSAE_AETOXGRN.

    Name:                popIn
      Default Value:     analysis.adsl
      Description:       The name of the dataset for population counts.
                         The default value can be reassigned in setup using variable BMSAE_POPIN.

    Name:                popTrtNum
      Default Value:     trt01an
      Description:       The name of numeric treatment variable in the population dataset.
                         The default value can be reassigned in setup using variable BMSAE_POPTRTNUM.

    Name:                popTrtName
      Default Value:     trt01a
      Description:       The name of character treatment variable in the population dataset.
                         The default value can be reassigned in setup using variable BMSAE_POPTRTNAME.

    Name:                popFlag
      Default Value:     %quote(saffl = "Y")
      Description:       The condition to be used for calculation the population for the analysis.
                         The condition is also added in the records selection from input dataset.
                         The default value can be reassigned in setup using variable BMSAE_POPFLAG.

    Name:                subjidVar
      Default Value:     usubjid
      Description:       The variable containing the subject ID.
                         The default value can be reassigned in setup using variable BMSAE_SUBJIDVAR.

    Name:                sortPt
      Allowed Values:    ALPH|FREQ
      Default Value:     FREQ
      Description:       The order in which Preferred Terms are to be sorted.
                         When ALPH the PTs will be sortd in alphabetic order.
                         When FREQ the PTs will be sortd in the oder of descending frequency then
                         alphabetically. The dataset will be sorted by Total column.

    Name:                cutPct
      Allowed Values:    <number>
      Description:       If specified the PTs with percentage values below <number> will be removed.

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
      Description:       Specifies the width of the column with PTs values.
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
                         to split PT values. See gmModifySplit for details.


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





%macro bmsaex009(dataOut=, where=, cutPct=,
                varsBy=, TotalStr="TOTAL SUBJECTS WITH AN EVENT",
                sortPT=FREQ,
                dataIn=, trtNum=, trtName=, aedecod=,  aetoxgrn=,
                SubjidVar=, PopIn=, PopTrtNum=, PopTrtName=, PopFlag=,
                putLen=4, termColWidth= , resultColWidth=,
                subgroup=, subgroupn=, selectType=E);

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsaex009.sas $
          , revision = $Rev: 1874 $
          ,checkMinSasVersion = 9.2
          );


    %local ds aevars AETemplate;
    %let ds = _aetx009_;
    %let varprefix = _ae_var_;

    %let codeFile = %quote(bmsaex009.sas);


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
        TRTNAME
        AEDECOD
        AETOXGRN
        SUBJIDVAR
        POPIN
        POPTRTNUM
        POPTRTNAME
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

    %if %index(&trtNum, @) > 0 %then %do;
        %gmMessage(codelocation=&codefile.,
                linesout=%str(trtNum parameter cannot contain @ symbol),
                selectType=ABORT,
                splitchar = #);
    %end;


    %if %index(&trtName, @) > 0 %then %do;
        %gmMessage(codelocation=&codefile.,
                linesout=%str(trtName parameter cannot contain @ symbol),
                selectType=ABORT,
                splitchar = #);
    %end;

    %let varsby = &varsby.@&trtnum  \type=subgroupN \parent=_ae_treatment \renameFrom=&popTrtNum.;
    %let varsby = &varsby.@&trtname \type=subgroup  \parent=_ae_treatment \renameFrom=&popTrtName.;


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
            length varsby varsby subgroupVar subgroupVal subgroupVarType $2000. ;
            retain varsby "" subgroupVar "" subgroupVal "" subgroupVarType "" ;
            varsby = trim(varsby) || " " || parameter;


            if strip(lowcase(typeValue))  = "subgroup" and strip(lowcase(parentValue)) = "_ae_subgroup" then do;
                if missing(subgroupVar) then subgroupVar = strip(parameter);
                if missing(subgroupVal) then subgroupVal = strip(valuesValue);
                if missing(subgroupVarType) then subgroupVarType = "character";

            end;

            if strip(lowcase(typeValue))  = "subgroupn" and strip(lowcase(parentValue)) = "_ae_subgroup" then do;
                subgroupVar = strip(parameter);
                subgroupVal = strip(valuesValue);
                subgroupVarType = "numeric";
            end;

            if strip(lowcase(typeValue)) = "subgroupn" and strip(lowcase(parentValue)) = "_ae_treatment" then do;
                call symput("trtnum", trim(parameter));
                call symput("trtValues", strip(valuesValue));
            end;

            if strip(lowcase(typeValue)) = "subgroup" and strip(lowcase(parentValue)) = "_ae_treatment" then do;
                call symput("trtName", trim(parameter));
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

    %* Update the input dataset for use in bmsfreq macro;;
    data &ds.;
        set &dataIn.;
        _aetotstr = &TotalStr.;
        if missing(&aetoxgrn.) then &aetoxgrn. = 0;
    run;

    %* Run bmsfreq macro                                ;;

    %BMSfreq(DataIn=&ds., DataOut=&ds.0, Where=&where., Vars=_aetotstr &aedecod.,
             Count=&SubjidVar &aetoxgrn.,
             Trt=&trtNum., VarsBy=&varsby., Sorttype=ALPH, Sort=,
             keep_num=YES, keep_vars=YES,
             Percent=POP,  PopDS=_bms_popds, addTotal=YES, popby= &subgroupVar.,
             Putmiss=END,  Missing_word="NOT REPORTED",
             Label="",     FreqPut=&putLen., Shift=0, Transpose=&aetoxgrn.,
             tranPrefix = grade);

    %let DSNId = %sysfunc(open(&ds.0));
    %let DSObs = %sysfunc(attrn(&DSNId.,nobs));
    %let rc = %sysfunc(close(&DSNId.));



    %if &dsObs = 0 %then %do;
         %bmsaesort(
                      SORT_DATAIN = &ds.0,
                     SORT_DATAOUT = &ds.1,
                      SORT_BYVARS = &varsby.,
                        SORT_VARS = _aetotstr &aedecod.,
                        SORT_TYPE = alph alph,
                       SORT_ORDER = asce asce,
                      SORT_COLUMN = ,
                      SORT_SUFFIX =
                    );
    %end;
    %else %do;
        %* Remove the records with percentage smaller than specified          ;;
        %if &cutPct ne %then %do;
            %bmsAeCutOff(dataIn=&ds.0, dataOut=&ds.cut, cutValue=&cutPct,  varsby = &varsby.,
                         cutVarList = _freq_p_&aedecod._total, terms = 1);

            %let toSort = &ds.cut;
        %end;
        %else %let toSort = &ds.0;


        %* Re-Sort the dataset                                               ;;
        %let sortOrder = desc;
        %if %upcase(&sortPT.) = ALPH %then %let sortOrder = &sortOrder ASCE;
            %else %let sortOrder = &sortOrder DESC;

        %bmsaesort(
                      SORT_DATAIN = &toSort,
                     SORT_DATAOUT = &ds.1,
                      SORT_BYVARS = &varsby.,
                        SORT_VARS = _aetotstr &aedecod.,
                        SORT_TYPE = alph &sortPt.,
                       SORT_ORDER = &sortOrder.,
                      SORT_COLUMN = Total,
                      SORT_SUFFIX =
                    );
    %end;


    %* Finalize the dataset:
        1) add missing rows if need
        2) split the terms to fit the first column
        3) keep and rename the variables ;;
    %bmsAeFinalize(dataIn= &ds.1, dataOut = &ds.2, putLen=&putLen,
                   termColWidth= &termColWidth, resultColWidth=&resultColWidth,
                   columnList = grade1 grade2 grade3 grade4 grade5 grade0 gradeTotal, columnNumber=7,
                   terms = 1, varsby=&varsby., varsbyds=&varsbyds.,
                   popIn = &popIn. , popFlag = %quote(&popFlag.),
                   TotalStr=&TotalStr, selectType = &selectType.);

    proc sort data = &ds.2;
        by &trtNum &subgroupVar.;
    run;

    data &ds.3;
        merge &ds.2(in = _inds2) _bms_popds;
        by &trtNum &subgroupVar.;
        if _inds2;
    run;

    data &dataout.;
        set &ds.3;
        length trtline $200.;
        trtline = "Treatment Group: " || trim(&trtName.) || " N = " || compress(put(popCount, best.));
        rename grade0 = gradeMissing;
    run;

    proc sort data = &dataOut;
        by &varsby. grpxSort1 grpxSort2;
    run;

%if not %symExist(gmDebug) %then %let gmDebug = 0;

%if &gmDebug. = 0 %then %do;
    proc datasets nolist;
         delete _bms_popds &ds: /mt=data;
    quit;
%end;

    %gmEnd(headURL  = $    $);


%mend bmsaex009;
