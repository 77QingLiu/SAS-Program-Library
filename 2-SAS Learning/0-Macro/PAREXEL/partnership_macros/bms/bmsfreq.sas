/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Roman Igla    $LastChangedBy: iglar $
  Creation Date:              $LastChangedDate: 2016-02-26 04:43:28 -0500 (Fri, 26 Feb 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsfreq.sas $

  Files Created:

  Program Purpose:       BMSFreq macro produces the dataset to report in the tables with frequency statistics for categorical data.

  Macro Parameters:

    Name:                dataIn
      Default Value:     REQUIRED
      Description:       The name of the Input Dataset.


    Name:                dataOut
      Default Value:     REQUIRED
      Description:       The name of the Output Dataset. If dataset exists it will be overwritten.

    Name:                vars
      Default Value:     BLANK
      Description:       The name of variable(s) in the input dataset for which the frequency statistics
                         is needed. Multiple variables can be listed, can be left blank.

    Name:                where
      Default Value:     BLANK
      Description:       Condition to filter input dataset.


    Name:                varsBy
      Default Value:     BLANK
      Description:       If specified the patients will be summarized separately by each unique value of
                         the variables specified in varsBy argument.

    Name:                varsRepBy
      Default Value:     BLANK
      Description:       The same as VarsBy, but variable values will be also reported before the
                         summary.

    Name:                trt
      Default Value:     BLANK
      Description:       The name of variable by which percentages should be calculated.


    Name:                count
      Allowed Values:    OBS, the name of key variable, the name of key variable followed by the name of
                         by-max variable
      Default Value:     OBS
      Description:       When OBS: count all observations
                         #When the name of key variable: count only unique occurrence of this key variable
                         #When the name of key variable followed by the name of by-max variable:
                          count only unique occurrence of key variable with the maximum of by-max variable.

    Name:                weight
      Default Value:     BLANK
      Description:       The name of the numeric variable to contain the weights of the observations.
                         If specified the sum of weights will be reported instead of number of observations.
                         Can be used only with coubt = OBS.

    Name:                percent
      Allowed Values:    NO, ALLOBS, NONMIS, POP
      Default Value:     REQUIRED
      Description:       When NO: No percentages reported
                         #When ALLOBS: Percentages based on the all number of records
                         #When NONMIS: Percentages based on the number of non-missing records
                         #When POP: Percentages based on the number of subjects in population

    Name:                popDs
      Default Value:     _bms_popds
      Description:       The name of the dataset containing a number of subjects in population by treatment.
                         This parameter is used only for Percent=POP

    Name:                popName
      Default Value:     BLANK
      Description:       The name of population. Only for Percent=POP and several Popname values present
                         in PopDS dataset

    Name:                popBy
      Allowed Values:    Variable name(s)
      Default Value:     BLANK
      Description:       List of by variables to be used to merge the dataset with population counts.
                         Must be a subset of varsBy parameter.

    Name:                transpose
      Allowed Values:    NO, YES, Variable name(s)
      Default Value:     YES
      Description:       When NO: No transposing
                         #When YES: Transposition by Trt variable. If trt parameter not specified then
                         no transposing is done
                         #When Variable name(s): Transposing by variables listed in Transpose parameter

    Name:                addTotal
      Allowed Values:    NO, YES
      Default Value:     NO
      Description:       When NO: No columns with total reported.
                         #When YES: Creates total columns for all variables in Transpose parameter
                         (or for trt if Transpose = YES).

    Name:                tranTotal
      Default Value:     BLANK
      Description:       Create total columns for the variables listed in tranTotal parameter.
                         The list of variable in tranTotal must be a subset of the list of variables
                         in Tranospose

    Name:                tranPrefix
      Default Value:     col
      Description:       The prefices that will be used on the variables after the transposing. For example
                         if Transpose = %qoute(trtan aetox) and tranPrefix = %qoute(trt tox) then the
                         resulting variables will have the following format: trtXXXtoxYYY, where XXX and
                         YYY are values of trt and and aetox variables correspondently.

    Name:                sortType
      Allowed Values:    ALPH, FREQ, VAR, VAL, DUMMYDS
      Default Value:     ALPH
      Description:       When ALPH: alphabetical sorting by vars values.
                         #When FREQ: order by descending frequency in one of the table columns or totals,
                         then alphabetically.
                         #When VAR: by numeric variable specified in Sort macro parameter.
                         #When VAL: by list of values specified in Sort macro parameter.
                         #When DUMMYDS: by order in the dummy dataset specified in Sort macro parameter.
                         Can be used only if one variable is specified in Vars parameter.

    Name:                sort
      Default Value:     BLANK
      Description:       When sortType = FREQ: Sort parameter can be used to specify the column which
                         will order the records in the output. The column is selected using the following condition:
                         <variable name 1> = <variable value> and <variable name 2> = <variable value> ..., variable
                         names in the condition must be the transpose variables.
                         If any name is not specified then ordering is performed using corresponding total column.
                         #When sortType = VAR: The name of numeric variable which is associated with Vars
                         and by which the sorting should be made.
                         #When sortType = VAL: The list of values separated by spaces which will be present
                         in output dataset with the order they are listed. In case of non-missing values
                         of Vars outside of the list they will be shown at the bottom of the list (right
                         before missings) sorted alphabetically.
                         #When sortType = DUMMYDS: The name of the dummy dataset for sorting. The dataset
                         must contain all the variables from varsBy and vars parameters. Can be used only
                         if vars parameter contains one variable.

    Name:                freqPut
      Allowed Values:    Integer number
      Default Value:     4
      Description:       Number of places the count to be reported

    Name:                Shift
      Allowed Values:    Integer number
      Default Value:     2
      Description:       Number of spaces to shift the reported terms when multiple variables are specified in
                         Vars parameter or when varsRepBy or Label parameter is used.

    Name:                putMiss
      Allowed Values:    END, NO
      Default Value:     END
      Description:       When END: Place missing results at the end of the output
                         #When NO: Removes missing results from the analysis

    Name:                missing_word
      Allowed Values:    Character string in quotes
      Default Value:     "NOT REPORTED"
      Description:       Replace missing values of Vars.


    Name:                id
      Allowed Values:    Integer number
      Default Value:     BLANK
      Description:       A number; in case of non-missing parameter there will be created variable with
                         the name ID which will be equal to this number for all records

    Name:                label
      Allowed Values:    Text in quotes
      Default Value:     BLANK
      Description:       The line in quotes that contains the name to be outputted before the statistics,
                         for example "GENDER (%)"

    Name:                keep_num
      Allowed Values:    YES, NO
      Default Value:     NO
      Description:       Creates the variables in the resulting dataset with prefices _freq_n_ and
                        _freq_p_ which contain numeric results for each column of the table

    Name:                keep_vars
      Allowed Values:    YES, NO
      Default Value:     NO
      Description:       Leaves variables listed in Vars parameter in the resulting dataset


  Macro Dependencies:    gmMessage (called)
                         gmStart (called)
                         gmEnd (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 1879 $
-----------------------------------------------------------------------------*/



%macro BMSfreq(id=, DataIn=, DataOut=, Where=, Vars=, Trt=,
    VarsBy=, VarsRepBy=, Sorttype=ALPH, Sort=,
    Percent=, PopDS=_bms_popds, PopName=, Count=OBS, Putmiss=END, Missing_word="NOT REPORTED",
    Label="", FreqPut=4, Shift=2, Transpose=YES, keep_num = NO, keep_vars = NO,
    tranTotal =, tranPrefix = col, addTotal=, popBy=, weight =);

  %gmStart( headURL  = $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsfreq.sas $
          , revision = $Rev: 1879 $
          );


    %if not %symexist(gmDebug) %then %let gmDebug=0;
    %if &gmDebug=1 %then %do;
        options mprint;
        %put _local_;
    %end;
    %local freq_do_i;
    %local freq_do_j;
    %local freq_temp;
****************************************************************************************************;
* Internal macros                                                                                   ;
****************************************************************************************************;
    * Macro to report messages. Types: NOTE, WAR, ERR (ERR aborts the macro);
    %macro freq_message(type=ERR, message=);
        %local bmserr; %let bmsERR=%cmpres(ERR)%cmpres(OR:);
        %local bmswar; %let bmsWAR=%cmpres(WAR)%cmpres(NING:);
        %if %upcase(&type)=ERR %then %do;
            %gmMessage
                ( codelocation  = bmsfreq.sas
                 , linesOut     = &message
                 , selectType   = ABORT
                );
            1
        %end; %else %if %upcase(&type)=WAR %then %do;
             %gmMessage
                ( codelocation  = bmsfreq.sas
                 , linesOut     = &message
                 , selectType   = W
                );
        %end; %else %if %upcase(&type)=NOTE %then %do;
              %gmMessage
                ( codelocation  = bmsfreq.sas
                 , linesOut     = &message
                 , selectType   = N
                );
        %end; %else %do;
           %gmMessage
                ( codelocation  = bmsfreq.sas
                 , linesOut     = %quote(Wrong parameter type=&type in freq_message macro)
                 , selectType   = ABORT
                );
            1
        %end;
    %mend freq_message;

    %macro freq_parse_error(errType=, freq_sort_i=);
        %let freq_sort_i = %eval(%length(&freq_sorttmp_full) - %length(&freq_sorttmp.) + 1);
        %freq_message(type=WAR, message=Parse error at position &freq_sort_i..);
        %if &errType = 4 %then
           %freq_message(type=ERR, message = Error in Sort parameter: Incorrect variable name);
        %if &errType = 3 %then
           %freq_message(type=ERR, message = Error in Sort parameter: Unmatched quote);
        %if &errType = 2 %then
           %freq_message(type=ERR, message = Error in Sort parameter: Incompatible type of &&freq_tranvar_&freq_varfound.. and its value in Sort parameter);
        %if &errType = 1 %then
           %freq_message(type=ERR, message =%quote(Error in Sort Parameter: For SortType = FREQ Sort value must be in format
"tranVar1 = XXX and tranVar2 = YYY and ..." where tranVar1 and tranVar2 are transpose
variables and XXX and YYY are their values));
    %mend;


    * Macro for checking if variable exists in ds dataset ;
    %macro freq_exist_var(var=, ds=&DataIn.);
        %local freq_GetVardsid;
        %local freq_GetVarrc;
        %let freq_GetVardsid  = %sysfunc(open(&ds.,I));
        %if &freq_GetVardsid=0 %then %do;
            %if %freq_message(type=ERR, message=Dataset &ds. could not be opened)=1 %then %return;
        %end;
        %else %if not %sysfunc(varnum(&freq_GetVardsid.,&var)) %then %do;
            0
        %end; %else %do;
            1
        %end;
        %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
    %mend  freq_exist_var;

    * Macro for getting variable type and length ;
    * Returns 0 for numeric variables, and variable length for character variables;
    %macro freq_type_var(var=);
        %local freq_GetVardsid;
        %local freq_GetVarcolno;
        %local freq_GetVartype;
        %local freq_GetVarrc;
        %let freq_GetVardsid  = %sysfunc(open(&DataIn.,I));
        %if &freq_GetVardsid=0 %then %do;
            %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
            %if %freq_message(type=ERR, message=Dataset &DataIn. could not be opened)=1 %then %return;
        %end;
        %let freq_GetVarcolno = %sysfunc(varnum(&freq_GetVardsid,&var));
        %if not &freq_GetVarcolno %then %do;
            %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
            %if %freq_message(type=ERR, message=No &var variable in &DataIn. dataset)=1 %then %return;
        %end;
        %let freq_GetVartype=%sysfunc(vartype(&freq_GetVardsid,&freq_GetVarcolno));
        %if &freq_GetVartype=N %then %do; 0 %end;
        %else %do; %sysfunc(varlen(&freq_GetVardsid,&freq_GetVarcolno)) %end;
        %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
    %mend  freq_type_var;

    * Checking that variables in the list exist in DataIn dataset;
    %macro freq_check_list(list=, ds = &DataIn.);
        %local freq_do_i; %local freq_temp; %local freq_stop; %let freq_stop=0;
        %let freq_do_i=1;
        %do %while (%length(%qscan(&list,&freq_do_i))>0);
            %let freq_temp=%qscan(&list,&freq_do_i);
            %if not %freq_exist_var(var=&freq_temp, ds=&ds.) %then %do;
                %if %freq_message(type=ERR, message=No %qscan(&list,&freq_do_i) variable in &ds. dataset)=1 %then
                %let freq_stop=1;
            %end;
            %let  freq_do_i = %eval(&freq_do_i+1);
        %end;
    %mend  freq_check_list;

    * Macro to add variables from &new. list to existing &list. ;
    * Macro adds only the variable that are not in the &list. already ;
    %macro freq_add_in_list(list=,new=);
        %local freq_do_i; %local freq_do_j; %local freq_temp;
        %let freq_do_i=1;
        %do %while (%length(%qscan(&new,&freq_do_i))>0);
            %let freq_temp = %upcase(%qscan(&new,&freq_do_i));
            %let freq_do_j=1;
            %do %while (%length(%qscan(&&&list,&freq_do_j))>0 and %upcase(%qscan(&&&list,&freq_do_j)) ne &freq_temp);
                %let  freq_do_j = %eval(&freq_do_j+1);
            %end;
            %if %length(%qscan(&&&list,&freq_do_j))=0 %then %do; %let &list =&&&list &freq_temp.; %end;
            %let  freq_do_i = %eval(&freq_do_i+1);
        %end;
    %mend  freq_add_in_list;

    * Macro to remove variables from the &list., variables listed in &new. are removed.;
    %macro freq_drop_from_list(list=,new=);
        %local freq_newlist; %let freq_newlist=;
        %local freq_do_i; %local freq_do_j; %local freq_temp;
        %let freq_do_i=1;
        %do %while (%length(%qscan(&&&list,&freq_do_i,%str( )))>0);
            %let freq_temp = %upcase(%qscan(&&&list,&freq_do_i,%str( )));
            %let freq_do_j=1;
            %do %while (%length(%qscan(&new,&freq_do_j,%str( )))>0 and %upcase(%qscan(&new,&freq_do_j,%str( ))) ne &freq_temp);
                %let  freq_do_j = %eval(&freq_do_j+1);
            %end;
            %if %length(%qscan(&new,&freq_do_j,%str( )))=0 %then %do;
                %let freq_newlist = &freq_newlist %qscan(&&&list,&freq_do_i,%str( )) ;
            %end;
            %let  freq_do_i = %eval(&freq_do_i+1);
        %end;
        %let &list = &freq_newlist;
    %mend  freq_drop_from_list;

    * Macro to check variables from &new. list exist &list. ;
    %macro freq_check_in_list(list=,new=);
        %local freq_do_i; %local freq_do_j; %local freq_temp freq_return;
        %let freq_do_i=1;
        %let freq_return = 1;
        %do %while (%length(%qscan(&new,&freq_do_i))>0);
            %let freq_temp = %upcase(%qscan(&new,&freq_do_i));
            %let freq_do_j=1;
            %do %while (%length(%qscan(&&&list,&freq_do_j))>0 and %upcase(%qscan(&&&list,&freq_do_j)) ne &freq_temp);
                %let  freq_do_j = %eval(&freq_do_j+1);
            %end;
            %if %length(%qscan(&&&list,&freq_do_j))=0 %then %do; %let freq_return = 0; %end;
            %let  freq_do_i = %eval(&freq_do_i+1);
        %end;
        &freq_return.
    %mend  freq_check_in_list;

    * Macro for percentages;
    %macro bmsfreq_percentages(n=, den=, outvar=, type=BMS, percsign=NO, dp=1, outnum=);
        %if %length(&outvar.) > 0 %then %do;
            %if %upcase(&type) = BMS %then %do;
                if n(&n,&den) and &n>0 then do;
                    if &n*1000 < &den then
                        &outvar="( <0.1)";
                    else
                        &outvar="("||put(round(&n*100/&den,0.1),5.1)||")";
                end;
            %end; %else %if %upcase(&type) = STANDARD %then %do;
                if n(n,den) and n>0 then do;
                    &outvar="("||put(round(&n*100/&den %if &dp=1 %then ,0.1),5.1); %else ).3.);
                        %if &percsign=1 %then %do; ||"%" %end; ||")";
                    &outvar=prxchange("s/\(([\s]+)/$1(/", -1,&outvar);
                end;
            %end;
        %end;
    %mend bmsfreq_percentages;

    %let freq_del_list = ; * list of datasets to delete;

    * Check table exists *;
    %if %length(&DataIn.)<1 %then %if %freq_message(type=ERR, message=Empty parameter DataIn)=1 %then %return;
    %if %length(&DataOut.)<1 %then %if %freq_message(type=ERR, message=Empty parameter DataOut)=1 %then %return;
    %if not ( %sysfunc(exist(&DataIn.)) or  %sysfunc(exist(&DataIn., view)))
        %then %if %freq_message(type=ERR, message=Dataset &DataIn. does not exist)=1 %then %return;

    %if %sysfunc(notdigit(&freqPut))^=0 %then %freq_message(type=ERR, message= FreqPut must be an integer number.);
    %if %sysfunc(notdigit(&shift))^=0 %then %freq_message(type=ERR, message= Shift must be an integer number.);
    %if %length(&id.) > 0 %then
        %if %sysfunc(notdigit(&id))^=0 %then %freq_message(type=ERR, message= ID must be an integer number.);

    %local freq_novar freq_notrt freq_any_records freq_trt_vartype freq_totvalc freq_totvaln;
    %let freq_novar = 0;
    %let freq_notrt = 0;
    %let freq_any_records = 0;
    %let freq_trt_vartype = 0; * 0 - for numeric, length for character;
    %let freq_totvaln = 999.99;
    %let freq_totvalc = "_freq_total";

    %if %length(&vars.) = 0 %then %do; *if VARS parameter is not specified.;
        %let freq_novar=1;
        %let vars = _freq_tmpvar;
        %do %while (%freq_exist_var(var=&vars)); %let vars = &vars.X; %end;
    %end;
    %if %length(&trt.) = 0 %then %do; *if TRT parameter is not specified.;
        %let freq_notrt=1;
        %let trt = _freq_temptrt;
        %let freq_trt_vartype = 0;
    %end;
    %else %do;
        %let freq_trt_vartype = %freq_type_var(var=&trt.);
    %end;
    %if &freq_trt_vartype. = 0 %then %let freq_trttotval = &freq_totvaln;
        %else %let freq_trttotval = &freq_totvalc;

    * Weight parameter;
    %if &weight ne %then %do;
        %if %freq_type_var(var=&weight) > 0 %then
            %freq_message(type=ERR, message = %quote(&weight variable must be numeric. Check weight parameter.));
        %if %upcase(&count.) ne OBS %then
            %freq_message(type=ERR, message = %quote(Weight can only be used with count = OBS));

    %end;


    * AddTotal, TranTotal, Transpose and TranPref parameters;

    %local freq_trantype; %*1 - NO, 2 - YES, 4 - variables; %*;
    %local freq_tranvar freq_tranvarnum;
    %let freq_tranvar =;
    %if %upcase(&Transpose)=NO or %upcase(&Transpose)=YES and &trt. = _freq_temptrt %then %do;
        %let freq_trantype=1;
        %let freq_tranvar=;
        %let freq_tranvarnum = 0;

        %if %length(&AddTotal) > 0 %then
            %freq_message(type=ERR, message = %quote(addTotal parameter cannot be used with Transpose = NO.));
        %if %length(&tranTotal) > 0 %then
            %freq_message(type=ERR, message = %quote(tranTotal parameter cannot be used with Transpose = NO.));
    %end;
    %else %do;
        %if %upcase(&Transpose)=YES or %upcase(&Transpose)=%upcase(&trt) %then %do;
            %let freq_trantype=2;
            %let freq_tranvar=%upcase(&trt);
        %end;
        %else %do;
            %freq_check_list(list=&Transpose);
            %let freq_trantype=4;
            %let freq_tranvar=%upcase(&Transpose);
        %end;

        %if %upcase(&AddTotal) = YES %then %do;
            %if %length(&tranTotal) > 0 %then
                %freq_message(type=ERR, message = %quote(addTotal and tranTotal parameters cannot be used both.));
            %let tranTotal = &freq_tranvar.;
        %end;
        %else %if %upcase(&AddTotal) = NO %then %do;
            %if %length(&tranTotal) > 0 %then
                %freq_message(type=ERR, message = %quote(addTotal and tranTotal parameters cannot be used both.));
            %let tranTotal = ;
        %end;
        %else %if %length(&AddTotal) > 0 %then %do;
            %freq_message(type=ERR, message = %quote(Unhandled value of addTotal parameter, should be either YES or NO.));
        %end;

        %local freq_i;
        %let freq_i = 1;
        %local freq_tranvar_&freq_i. freq_tranvartype_&freq_i. ;
        %let freq_tranvar_&freq_i. = %scan(&freq_tranvar., &freq_i.);
        %let  freq_tranvartype_&freq_i. = %freq_type_var(var=&&freq_tranvar_&freq_i.. );
        %do %while(%length(&&freq_tranvar_&freq_i..)>0);
            %let freq_i = %eval(&freq_i + 1);
            %local freq_tranvar_&freq_i. freq_tranvartype_&freq_i. ;
            %let freq_tranvar_&freq_i. = %scan(&freq_tranvar., &freq_i.);
            %if %length(&&freq_tranvar_&freq_i..) > 0 %then
                %let freq_tranvartype_&freq_i. = %freq_type_var(var=&&freq_tranvar_&freq_i.. );

        %end;
        %let freq_tranvarnum = %eval(&freq_i - 1);

        * create total values and flags if total should be reported. ;

        %do freq_i = 1 %to &freq_tranvarnum.;
            %local freq_totval_&freq_i. freq_addtot_&freq_i. freq_tranpref_&freq_i.;
            %let freq_j = 1;
            %let freq_totvar = %upcase(%scan(&tranTotal., &freq_j.));
            %do %while(%length(&freq_totvar)>0 and &freq_totvar ne &&freq_tranvar_&freq_i..);
                %let freq_j = %eval(&freq_j + 1);
                %let freq_totvar = %upcase(%scan(&tranTotal., &freq_j.));
            %end;
            %if %length(&freq_totvar.) > 0 %then %let freq_addtot_&freq_i. = 1;
                %else %let freq_addtot_&freq_i. = 0;

            %if &&freq_tranvartype_&freq_i.. = 0 %then %let freq_totval_&freq_i. = &freq_totvaln.;
                %else %let freq_totval_&freq_i. = &freq_totvalc.;
            %let freq_tranpref_&freq_i. = %scan(&tranPrefix., &freq_i);
            %if %length(&&freq_tranpref_&freq_i..) = 0 %then
                %freq_message(type=ERR, message = Not enough prefixes specified: check Transpose and TranPrefix parameters.);
        %end;
    %end;



    * Checking by and repby variables;
    %local freq_by; %let freq_by=&VarsBy;              %* By variables list; %*;
    %local freq_repby; %let freq_repby=&VarsRepBy;     %* By variables to be reported in the table; %*;
    %freq_add_in_list(list=freq_by,new=&freq_repby);   %* Variables from both lists will be used for 'by' list; %*;
    %freq_check_list(list=&freq_by);

    %let freq_i = 1;
    %let freq_tmp = %scan(&freq_repby., &freq_i.);
    %do %while(&freq_tmp ne );
        %if %freq_type_var(var=&freq_tmp.) = 0 %then
            %freq_message(type=ERR, message = Variables in varsRepBy parameter cannot be numeric.);
        %let freq_i = %eval(&freq_i + 1);
        %let freq_tmp = %scan(&freq_repby., &freq_i.);
    %end;


    * Add &trt. to byvar list;
    %if &freq_trantype ne 2 %then %freq_add_in_list(list=freq_by,new=&trt.);

    * Division Var to individual variables *;
    %local freq_varnum; %* Number of variables in VARS statement; %*;
    %if &freq_novar. = 1 %then %do;
        %let freq_varnum = 1;
        %local freq_var&freq_varnum.;
        %let freq_var&freq_varnum. = &vars.;
        %let freq_vartype&freq_varnum. = 200;
    %end;
    %else %do;
        %let freq_varnum = 1;
        %local freq_var&freq_varnum.;
        %let freq_var&freq_varnum. = %scan(&vars., &freq_varnum.);
        %let freq_vartype&freq_varnum. = %freq_type_var(var=&&freq_var&freq_varnum.. );
        %do %while(%length(&&freq_var&freq_varnum.)>0);
            %let freq_varnum = %eval(&freq_varnum + 1);
            %local freq_var&freq_varnum.;
            %let freq_var&freq_varnum. = %scan(&vars., &freq_varnum.);
            %if %length(&&freq_var&freq_varnum..) > 0 %then
                    %let freq_vartype&freq_varnum. = %freq_type_var(var=&&freq_var&freq_varnum.. );
        %end;
        %let freq_varnum = %eval(&freq_varnum - 1);
    %end;

    * Sorting processing (&SortType and &Sort parameter);
    %local freq_stype;    %*1 - ALPH or No vars, 2 - FREQ, 3 - VAR, 4 - VAL , 5 - DUMMYDS; %*;
    %local freq_sorttrt;  %*Column number of sorting, only for SortType = FREQ ; %*;
    %if %upcase(&sorttype)=ALPH %then %do; %let freq_stype=1; %end;
    %else %if &freq_novar=1 %then %do;
        %let freq_stype=1;
        %if %length(&sort.) > 0 %then %do;
            %if %freq_message(type=WAR, message=Since no VARS then SORT parameter will be ignored)=1 %then %return;
        %end;
    %end;
    %else %if &sorttype=FREQ %then %do;
        %let freq_stype=2;
        %if &freq_trantype = 1 %then %do;
            %if %length(&sort) > 0 %then
                %freq_message(type=WAR, message= Sort parameter is ignored when SortType = FREQ and Transpose = NO.);
            %let sort= 1 ;
        %end;
        %else %do;
            * Parse Sort value;
            %local freq_sorttmp freq_sortpart freq_sortend;

            %if %length(&sort) > 0 %then %let freq_sorttmp_full = %sysfunc(trim(&sort));
            %let freq_sorttmp = &sort.;
            %do freq_i = 1 %to &freq_tranvarnum.;
                %local freq_sortfilter_&freq_i.;
                %let freq_sortfilter_&freq_i. = 0;
            %end;
            %let freq_sortend = 0;
            %if %length(&freq_sorttmp) = 0 %then %let freq_sortend = 1;
            %do %while(&freq_sortend = 0);

                * Part 1: Transpose variable;
                %do %while(%index(&freq_sorttmp, %quote( )) = 1);
                    %let freq_sorttmp = %substr(&freq_sorttmp, 2);
                %end;
                %if %length(&freq_sorttmp) = 0 %then %freq_parse_error(errType = 1);
                %let freq_sortpart = %scan(&freq_sorttmp., 1, %quote(= ));
                %local freq_varfound; %let  freq_varfound = 0;
                %do freq_i = 1 %to &freq_tranvarnum.;
                    %if %upcase(&&freq_tranvar_&freq_i..) = %upcase(&freq_sortpart) %then %do;
                        %let freq_sortfilter_&freq_i. = 1;
                        %let freq_varfound = &freq_i.;
                    %end;
                %end;
                %if &freq_varfound = 0 %then %freq_parse_error(errType = 4);
                %let freq_sorttmp = %substr(&freq_sorttmp, %length(&freq_sortpart) + 1);

                * Part 2: Equality sign (=);

                %do %while(%index(&freq_sorttmp, %quote( )) = 1);
                    %let freq_sorttmp = %substr(&freq_sorttmp, 2);
                %end;

                %if %length(&freq_sorttmp) = 0 %then %freq_parse_error(errType = 1);

                %if %index(&freq_sorttmp, %quote(=)) ne 1 %then %freq_parse_error(errType = 1);
                %else %do;
                    %let freq_sorttmp = %substr(&freq_sorttmp, 2);
                %end;

                * Part 3: Transpose variable value;
                %do %while(%index(&freq_sorttmp, %quote( )) = 1);
                    %let freq_sorttmp = %substr(&freq_sorttmp, 2);
                %end;

                %if %length(&freq_sorttmp) = 0 %then %freq_parse_error(errType = 1);

                %if &&freq_tranvartype_&freq_varfound.. = 0 %then %do;
                    %let freq_sortpart = %scan(&freq_sorttmp., 1, %quote( ));
                    %if %length(%sysfunc(compress(&freq_sortpart, %quote(.-eE ),d))) > 0 %then
                        %freq_parse_error(errType = 2);
                    %let freq_sorttmp = %substr(%str(&freq_sorttmp. ), %length(&freq_sortpart) + 1);
                %end;
                %else %do;
                    %if %index(&freq_sorttmp, %str(%")) = 1 %then %do;
                        %let freq_cindex = %sysfunc(find(&freq_sorttmp,%str(%"),2));
                        %if &freq_cindex = 0 %then %freq_parse_error(errType = 3);
                        %if &freq_cindex >= %length(&freq_sorttmp) %then %let freq_sorttmp =;
                            %else %let freq_sorttmp = %substr(&freq_sorttmp, &freq_cindex + 1);
                    %end;
                    %else %if %index(&freq_sorttmp, %str(%')) = 1 %then %do;
                        %let freq_cindex = %sysfunc(find(&freq_sorttmp,%str(%'),2));
                        %if &freq_cindex = 0 %then %freq_parse_error(errType = 3);
                        %if &freq_cindex >= %length(&freq_sorttmp) %then %let freq_sorttmp =;
                            %else %let freq_sorttmp = %substr(&freq_sorttmp, &freq_cindex + 1);
                   %end;
                    %else %freq_parse_error(errType = 1);
                %end;

                * Part 4: End of Sort parameter or "and" statement;

                %do %while(%index(&freq_sorttmp, %quote( )) = 1);
                    %let freq_sorttmp = %substr(&freq_sorttmp, 2);
                %end;

                %if %length(&freq_sorttmp) = 0 %then %let freq_sortend = 1;
                %else %if %index(&freq_sorttmp,%str(and))=1 %then %do;
                     %let freq_sorttmp = %substr(&freq_sorttmp, 4);
                %end;
                %else %freq_parse_error(errType = 1);
            %end;
            %do freq_i = 1 %to &freq_tranvarnum.;
                %if &&freq_sortfilter_&freq_i.. = 0 %then %do;
                    %if %length(&sort) = 0 %then %let sort = %quote(&&freq_tranvar_&freq_i.. = &&freq_totval_&freq_i..);
                        %else %let sort = &sort and %quote(&&freq_tranvar_&freq_i.. = &&freq_totval_&freq_i..);
                %end;
            %end;
       %end;
    %end;
    %else %if %upcase(&sorttype)=VAR  %then %do;
        %let freq_stype=3;
        %if not %freq_exist_var(var=&sort) %then %do;
            %if %freq_message(type=ERR, message= No variable &sort in &DataIn. dataset. Check Sort parameter.)=1
            %then %return ;
        %end;
    %end;
    %else %if %upcase(&sorttype)=VAL  %then %do;
        %let freq_stype=4;
        %if %length(%sysfunc(compress(&sort,%quote(.-eE ),d)))=0 %then %do;
            %if &&freq_vartype&freq_varnum.>0 %then %do;
                %freq_message(type=ERR,
                    message=%quote(Incompatible value types. &&freq_var&freq_varnum. is character, Sort values are numeric));
            %end; %else %do;
                %let sort = %sysfunc(tranwrd(%cmpres(&sort.),%str( ),%str(,)));
            %end;
        %end;
        %else %if %index(&sort,%str(%"))=1 or %index(&sort,%str(%'))=1 %then %do;
            %if &&freq_vartype&freq_varnum.=0 %then %do;
                %freq_message(type=ERR,
                    message=%quote(Incompatible value types. &&freq_var&freq_varnum. is numeric, Sort values are character));
            %end; %else %do;
                %let regex = %sysFunc(prxParse(%str(s/(([\x22\x27]).+?\2)(?!$)/$1,/)));
                %let sort = %sysFunc(prxChange(&regex,-1,&sort));
            %end;
        %end;
        %else %do;
            %freq_message(type=ERR, message= %quote(Unexpected value of Sort parameter. For SortType = VAL, Sort should be list of values.));
        %end;
    %end;
    %else %if %upcase(&sorttype)=DUMMYDS  %then %do;
        %let freq_stype=5;
        %let freq_dummyds = &sort.;
        %if &sort. = %then
            %freq_message(type=ERR, message=Sort parameter must be specified.);
        %IF not (%SYSFUNC(EXIST(&freq_dummyds.))) %THEN %DO;
            %if %freq_message(type=ERR, message=Dataset &freq_dummyds. does not exists. Check Sort parameter is correct.)=1
                %then %return;
        %END;

        %if &freq_varnum. > 1 %then
            %freq_message(type=ERR, message= %quote(sortType = DUMMYDS cannot be used with multiple variables in vars parameter.));

        %freq_check_list(list=&varsBy, ds = &freq_dummyds.);
        %freq_check_list(list=&varsRepBy, ds = &freq_dummyds.);
        %freq_check_list(list=&vars, ds = &freq_dummyds.);
    %end;

    %else %do; %if %freq_message(type=ERR, message=%quote(Unexpected value of Sorttype parameter. Should be ALPH, FREQ, VAR or VAL.))=1 %then %return; %end;

    * --- Processing &Count. parameter ---;
    * After this step count contains only the first part of the parameter (OBS or var name);
    * Second part is stored in &freq_bymaxvar. ;
    %local freq_counttype;                      %* 1 - every observation counted, 2 - one record per &count. variable counted; %*;
    %local freq_bymaxvar; %let freq_bymaxvar=;  %* when &freq_counttype. = 2 contains the severity variable, record with max severety counted.; %*;

    %if %length(%scan(&count,2))>0 %then %do;
        %let freq_bymaxvar=%scan(&count,2);
        %if not %freq_exist_var(var=&freq_bymaxvar) %then
            %if %freq_message(type=ERR, message=The second part of Count parameter must be an existing variable.)=1
            %then %return;
        %let count=%scan(&count,1);
    %end;
    %if %upcase(&count)=OBS %then %do;
        %let freq_counttype=1;
        %let freq_bymaxvar=;
        %let count = ;
    %end;
    %else %if %freq_exist_var(var=&count) %then %do; %let freq_counttype=2; %end;
    %else %do; %if %freq_message(type=ERR, message=%quote(Unexpected value of Count parameter. Should be OBS or variable existing in input dataset.))=1
        %then %return;
    %end;

    * --- Processing Percentages parameters (&percent., &popDS., &popName) ---;
    %local freq_perctype; %*1 - POP, 2 - ALLOBS, 3 - NONMISS, 4 - NO; %*;
    %local freq_popds;
    %local freq_popflag;
    %local freq_sqlpopby;
    %if %upcase(&percent)=ALLOBS %then %do; %let freq_perctype=2; %end;
    %else %if %upcase(&percent)=NONMISS %then %do; %let freq_perctype=3; %end;
    %else %if %upcase(&percent)=NO %then %do; %let freq_perctype=4; %end;
    %else %if %upcase(&percent)=POP %then %do;
        %let freq_perctype=1;
        %if %length (&popds)>0 %then %do;
            %let freq_popds=&popds;
            %IF not (%SYSFUNC(EXIST(&freq_popds.))) %THEN %DO;
                %if %freq_message(type=ERR, message=Dataset &freq_popds. does not exists. Check PopDS parameter is correct.)=1
                    %then %return;
            %END;
            %else %do;
                * checking variables PopCount, PopName and &trt. are present in &PopDS. dataset ;
                %local freq_GetVardsid;
                %local freq_GetVarrc;
                %let freq_GetVardsid  = %sysfunc(open(&freq_popds.,I));
                %if not %sysfunc(varnum(&freq_GetVardsid.,PopCount)) %then %do;
                    %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
                    %if %freq_message(type=ERR, message=Variable PopCount is not present in PopDs = &freq_popds. dataset.)=1
                    %then %return;
                %end;
                %if &freq_notrt=0 %then %if not %sysfunc(varnum(&freq_GetVardsid.,&trt)) %then %do;
                    %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
                    %if %freq_message(type=ERR, message=Variable &trt. is not present in PopDs = &freq_popds. dataset.)=1
                    %then %return;
                %end;
                %if not %sysfunc(varnum(&freq_GetVardsid.,PopName)) %then %do;
                    %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
                    %if %length (&popname)>0 %then
                        %if %freq_message(type=WAR, message=Variable PopName is not present in PopDs = &freq_popds. dataset and option PopName=&popname will be ignored)=1
                        %then %return;
                %end; %else %do;
                    %local anypopname; %let anypopname=;
                    %if %length (&popname)>0 %then %do;
                        %let freq_popflag=&popname;
                        proc sql noprint; select distinct PopName into: anypopname from &freq_popds
                            where upcase(Popname)=upcase("&popname."); quit;
                        %if %length(&anypopname)<1 %then
                            %if %freq_message(type=ERR, message=PopName=&popname is not present in PopDs = &freq_popds. dataset.)=1
                            %then %return;
                    %end; %else %do;
                        proc sql noprint; select distinct PopName into: anypopname separated by "@|\" from &freq_popds  quit;
                        %if %index(&anypopname,%str(@|\))>0 %then
                            %if %freq_message(type=ERR,
                                message=%quote(Several PopName values present in PopDs = &freq_popds. dataset, but PopName parameter is not specified.))=1
                            %then %return;
                    %end;
                %end;
                %let freq_GetVarrc = %sysfunc(close(&freq_GetVardsid.));
                %if &popBy. ne  %then %do;
                    %freq_check_list(list=&popBy);
                    %freq_check_list(list=&popBy, ds = &freq_popds.);
                    %if %freq_check_in_list(list=%str(&varsBy &varsRepBy), new=&popBy) = 0 %then
                        %freq_message(type=ERR, message=popBy list must be the subset of varsBy/varsRepBy list.);
                    %let freq_sqlpopby = ,%sysfunc(tranwrd(%cmpres(&popBy.),%str( ),%str(,)));
                %end;
            %end;
        %end;
        %else %freq_message(type=ERR, message= popDs parameter is missing for Percent = POP);
    %end;
    %else %do; %if %freq_message(type=ERR, message=%quote(Unexpected value of Percent parameter. Should be POP, ALLOBS, NONMISS or NO.))=1
        %then %return;
    %end;

    * keep_num and keep_vars param handling;
    %let keep_num = %upcase(&keep_num.);
    %if &keep_num. ne YES and &keep_num. ne NO %then %freq_message(type=ERR, message= Unhandled keep_num value: &keep_num.);
    %let keep_vars = %upcase(&keep_vars.);
    %if &keep_vars. ne YES and &keep_vars. ne NO %then %freq_message(type=ERR, message= Unhandled keep_vars value: &keep_vars.);

    * check the names of the used variables;
    %let used_vars = &trt &varsby &varsrepby &freq_bymaxvar &freq_tranvar &weight.;
    %if &freq_novar = 0 %then %let used_vars = &used_vars &vars.;
    %if &freq_stype=3 %then %let used_vars = &used_vars. &sort ;
    %if &freq_counttype = 2 %then %let used_vars = &used_vars. &count;
    %if &freq_notrt = 1 %then %freq_drop_from_list(list=used_vars,new=&trt.);

    %let freq_do_i=1;
    %let freq_temp = %qscan(&used_vars,%eval(&freq_do_i));
    %do %while (%length(&freq_temp.)>0);
        %if %length(&freq_temp) >= 6 %then %if %lowcase(%substr(&freq_temp,1, 6)) = _freq_ %then
            %freq_message(type=ERR, message= Variables used in macro call cannot start with _freq_: &freq_temp.);
        %if %length(&freq_temp) > 4 %then %if %lowcase(%substr(&freq_temp,1, 4)) = sort %then %do;
            %local freq_temp_sort;
            %let freq_temp_sort = %substr(&freq_temp, 5);
            %if %sysfunc(notdigit(&freq_temp_sort)) = 0 %then %if &freq_temp_sort <= &freq_varnum %then
                %freq_message(type=ERR, message= Variable &freq_temp. cannot be used in macro call. It is sorting variale in output dataset.);
        %end;
        %if %lowcase(&freq_temp) = vars %then
            %freq_message(type=ERR, message= Variable vars is reserved and cannot be used in macro call: &freq_temp.);
        %let freq_do_i=%eval(&freq_do_i. + 1);
        %let freq_temp = %qscan(&used_vars,%eval(&freq_do_i));
    %end;

    %if %upcase(&Putmiss.) = NO and &freq_varnum > 1 %then %do;
        %freq_message(type=ERR, message= Parameter PutMiss = NO cannot be used with more than 1 variable in Vars parameter);
    %end;
    %if &freq_perctype = 3 and &freq_varnum > 1 %then %do;
        %freq_message(type=ERR, message= Parameter Percent = NONMISS cannot be used with more than 1 variable in Vars parameter);
    %end;
    %if %upcase(&Putmiss.) ^= NO and %upcase(&Putmiss.) ^= END %then %do;
        %freq_message(type=ERR, message= %quote(Unexpected value of PutMiss parameter. Should be END or NO.));
    %end;

* Main code;

    * Select variables;
    data freq1; %let freq_del_list=&freq_del_list freq1;

        set &DataIn(%if %length(&where)>0 %then where=(&where);) end=last;
        if last then call symput("freq_any_records","1");
        _freq_total = 0;
        keep &used_vars. _freq_total;

        * populate variable &vars and &trt. if not yet done;
        %if &freq_novar=1 %then %do; &vars.=upcase(&label); keep &vars.; %end;
        %if &freq_notrt=1 %then %do; &trt=1; keep &trt.; %end;
    run;
    %let freq_now_num = 2;
    %if &syserr>6 %then %do;
        %freq_message(type=ERR,
            message= %quote(Errors while reading from input dataset. See above. Most likely it is incorrect Where parameter.));
    %end;

    * Add totals for transpose variables. Totals are added for all variables.;
    %do freq_i = 1 %to &freq_tranvarnum.;
        data freq&freq_now_num;
            %if &&freq_tranvartype_&freq_i.. > 0 %then length &&freq_tranvar_&freq_i.. $200.; ;
            set freq%eval(&freq_now_num - 1);

            output;
            %if %upcase(&&freq_tranvar_&freq_i..) = %upcase(&freq_bymaxvar) %then %do;
                _freq_total = 1;
            %end;
            &&freq_tranvar_&freq_i.. = &&freq_totval_&freq_i.;
            output;
        run;
        %let freq_del_list=&freq_del_list freq&freq_now_num;
        %let freq_now_num = %eval(&freq_now_num. + 1);
    %end;

    proc sort data = freq%eval(&freq_now_num - 1);
        by &freq_by &freq_tranvar. &vars;
    run;

    * Add records for multiple vatiables in VARS value.;
    data freq&freq_now_num;
        set freq%eval(&freq_now_num - 1);
        by &freq_by &freq_tranvar. &vars;

        %do freq_temp_i = 1 %to &freq_varnum.;
            if missing(&&freq_var&freq_temp_i..) then _freq_miss&freq_temp_i. = 2;
                else _freq_miss&freq_temp_i. = 1;
        %end;
        output;
        %do freq_temp_i = %eval(&freq_varnum.-1) %to 1 %by -1;
            %let freq_temp_j = %eval(&freq_temp_i. + 1);
            call missing(&&freq_var&freq_temp_j..);
            _freq_miss&freq_temp_j. = 0;
            output;
        %end;
    run;
    %local freq_vars_sort;
    %let freq_vars_sort = _freq_miss1 &freq_var1;
    %do freq_temp_i = 2 %to &freq_varnum;
        %let freq_vars_sort = &freq_vars_sort _freq_miss&freq_temp_i. &&freq_var&freq_temp_i..;
    %end;

    %let freq_del_list=&freq_del_list freq&freq_now_num;
    %let freq_now_num = %eval(&freq_now_num. + 1);

    %local freq_temp_var_set;

    * Take only maximum value of bymaxvar if necessary;
    %if &freq_bymaxvar ne %then %do;
        %let freq_temp_var_set=&freq_by &trt &freq_vars_sort &freq_tranvar;
        %freq_drop_from_list(list=freq_temp_var_set,new=&freq_bymaxvar);
        proc sort data = freq%eval(&freq_now_num-1);
            by &freq_temp_var_set _freq_total &count &freq_bymaxvar;
        run;

        data freq&freq_now_num ;
            set freq%eval(&freq_now_num-1);
            by &freq_temp_var_set _freq_total &count &freq_bymaxvar;
            if last.&count;
        run;
        %let freq_del_list= &freq_del_list freq&freq_now_num; %let freq_now_num=%eval(&freq_now_num+1);
    %end;


    * Counting incidence;
    %local freq_n; %let freq_n=N; %do %while (%freq_exist_var(var=&freq_n)); %let freq_n=%trim(&freq_n)n; %end;

    %let freq_temp_var_set = &freq_by;
    %freq_add_in_list(list=freq_temp_var_set,new=&trt);
    %freq_add_in_list(list=freq_temp_var_set,new=&freq_tranvar);
    %freq_add_in_list(list=freq_temp_var_set,new=&freq_vars_sort);

    proc sql noprint;
        create table freq&freq_now_num as
        select distinct %sysfunc(tranwrd(%cmpres(&freq_temp_var_set),%str( ),%str(,)))
            , 1 as _freq_temp_var %* temporary variable to re-derive sort1 variable when there are no vars in by-statement;
            %if &freq_stype = 3 %then , &sort ;
            %if &weight. ne %then , sum (&weight) ;
            %else %if &freq_counttype=1 %then , count(*) ; %else , count(distinct &count) ; as &freq_n

        from freq%eval(&freq_now_num - 1)
        group by %sysfunc(tranwrd(%cmpres(&freq_temp_var_set),%str( ),%str(,)))
        order by %sysfunc(tranwrd(%cmpres(&freq_temp_var_set),%str( ),%str(,)))
        ;
    quit;
    %let freq_del_list=&freq_del_list freq&freq_now_num;
    %let freq_now_num = %eval(&freq_now_num. + 1);

    %if &keep_num = YES or &freq_stype = 2 %then %do;
        * Add variables with incidence for each variable in VARS parameter;
        data freq&freq_now_num ;
            set freq%eval(&freq_now_num-1);
            by &freq_by &trt &freq_tranvar &freq_vars_sort;
            retain
                %do freq_temp_i = 1 %to &freq_varnum;
                    _freq_n_&&freq_var&freq_temp_i
                %end;
            ;

            %do freq_temp_i = 1 %to &freq_varnum;
                if first.&&freq_var&freq_temp_i and _freq_miss&freq_temp_i > 0 then do;
                    _freq_n_&&freq_var&freq_temp_i = &freq_n;
                    %if &freq_temp_i. < &freq_varnum %then %do;
                        if _freq_miss%eval(&freq_temp_i.+1) > 0 then _freq_n_&&freq_var&freq_temp_i = 0;
                    %end;

                end;

                if  _freq_miss&freq_temp_i = 0 then _freq_n_&&freq_var&freq_temp_i = .;
            %end;
        run;
        %let freq_del_list=&freq_del_list freq&freq_now_num;
        %let freq_now_num = %eval(&freq_now_num. + 1);
    %end;

    *Sorting;
    %local freq_by_vars;

    %let freq_by_vars = _freq_temp_var &freq_by &freq_tranvar &trt.;
    %if &freq_notrt = 1 %then %freq_drop_from_list(list=freq_by_vars,new=&trt);
    %freq_drop_from_list(list=freq_by_vars, new=&freq_tranvar);

    %local freq_vars_sort freq_vars_sort_stat;
    %let freq_vars_sort = _freq_miss1 &freq_var1;
    %do freq_temp_i = 2 %to %eval(&freq_varnum-1);
        %let freq_vars_sort = &freq_vars_sort _freq_miss&freq_temp_i. &&freq_var&freq_temp_i..;
    %end;
    %if &freq_varnum > 1 %then %do;
        %let freq_vars_sort_stat = &freq_vars_sort;
        %let freq_vars_sort = &freq_vars_sort _freq_miss&freq_varnum. &&freq_var&freq_varnum..;
    %end;
    %else %let freq_vars_sort_stat =;


    %local freq_sort_order_ds;
    %local freq_sort_order_byvars;

    * part 1 - create sort dataset;
    %if &freq_stype = 1 %then %do;  *alphabetic sorting;
        proc sort data = freq%eval(&freq_now_num-1)
                  out = freq_sort_varnames(keep = &freq_by_vars &freq_vars_sort)
                  nodupkey;
            by  &freq_by_vars &freq_vars_sort;
        run;
        %let freq_sort_order_ds = freq_sort_varnames;
        %let freq_sort_order_byvars = &freq_by_vars &freq_vars_sort;

        %let freq_del_list=&freq_del_list freq_sort_varnames ;
    %end;
    %else %if &freq_stype = 2 %then %do; * sorting by frequency;
        proc sort data = freq%eval(&freq_now_num-1)
                  out = freq_sort_varnames(keep = &freq_by_vars &freq_vars_sort)
                  nodupkey;
            by  &freq_by_vars &freq_vars_sort;
        run;

        proc sort data = freq%eval(&freq_now_num-1);
            by &freq_by_vars &freq_vars_sort;
        run;

        data freq_sort_0;
            merge freq%eval(&freq_now_num-1) (where = (&sort.) in = _freq_insort)
                  freq_sort_varnames ;
            by  &freq_by_vars &freq_vars_sort;
            *_freq_temp_var = 1;
        run;

        data freq_sort_1;
            set freq_sort_0;
            by  &freq_by_vars &freq_vars_sort;
            %do freq_temp_j = 1 %to &freq_varnum;
                retain _freq_np&&freq_var&freq_temp_j..;
                drop _freq_np&&freq_var&freq_temp_j..;

                if first.&&freq_var&freq_temp_j. and  _freq_miss&freq_temp_j > 0 and
                    missing(_freq_n_&&freq_var&freq_temp_j..)
                then do;
                    _freq_n_&&freq_var&freq_temp_j.. = 0;
                end;
                if _freq_miss&freq_temp_j > 0 and missing(_freq_n_&&freq_var&freq_temp_j..)
                then do;
                    _freq_n_&&freq_var&freq_temp_j.. = _freq_np&&freq_var&freq_temp_j..;
                end;
                _freq_np&&freq_var&freq_temp_j.. = _freq_n_&&freq_var&freq_temp_j..;
            %end;
        run;

        %let freq_vars_sort_freq = _freq_miss1 descending _freq_n_&freq_var1. &freq_var1;
        %do freq_temp_i = 2 %to &freq_varnum;
            %let freq_vars_sort_freq = &freq_vars_sort_freq _freq_miss&freq_temp_i. descending _freq_n_&&freq_var&freq_temp_i.. &&freq_var&freq_temp_i..;
        %end;

        proc sort data = freq_sort_1;
            by  &freq_by_vars &freq_vars_sort_freq;
        run;

        %let freq_sort_order_ds = freq_sort_1;
        %let freq_sort_order_byvars = &freq_by_vars &freq_vars_sort_freq;

        %let freq_del_list=&freq_del_list freq_sort_0 freq_sort_1 freq_sort_varnames;
    %end;
    %else %if &freq_stype = 3 %then %do;  *using SORT variable;
        proc sort data = freq%eval(&freq_now_num-1)
                  out = freq_sort_varnames(keep = &freq_by_vars &freq_vars_sort _freq_temp_var &sort.)
                  nodupkey;
            by  &freq_by_vars &freq_vars_sort_stat
                _freq_miss&freq_varnum &sort. &&freq_var&freq_varnum..;
        run;

        %let freq_sort_order_ds = freq_sort_varnames;
        %let freq_sort_order_byvars = &freq_by_vars &freq_vars_sort_stat
                                      _freq_miss&freq_varnum &sort. &&freq_var&freq_varnum..;

        %let freq_del_list=&freq_del_list freq_sort_varnames;
    %end;
    %else %if &freq_stype = 4 %then %do; * by values;
        proc sort data = freq%eval(&freq_now_num-1)
                  out = freq_sort_varnames(keep = &freq_by_vars &freq_vars_sort _freq_temp_var)
                  nodupkey;
            by &freq_by_vars &freq_vars_sort_stat &&freq_var&freq_varnum.. _freq_miss&freq_varnum.;
        run;

        proc sort data = freq_sort_varnames
                  out = freq_sort_byvars(keep = &freq_by_vars &freq_vars_sort_stat _freq_temp_var)
                  nodupkey;
            by &freq_by_vars &freq_vars_sort_stat;
        run;

        %if &&freq_vartype&freq_varnum.. > 0 %then %do;
            %let freq_maxlen = 1;
            data freq_sort_values;
                set freq_sort_byvars;
                _freq_miss&freq_varnum. = 1;
                length &&freq_var&freq_varnum.. $200.; ;
                _freq_maxlen = 0;
                _freq_sort0 = 0;
                do &&freq_var&freq_varnum.. = &sort. ;
                    _freq_sort0 = _freq_sort0 + 1;
                    output;
                    if length(&&freq_var&freq_varnum..) > _freq_maxlen then _freq_maxlen = length(&&freq_var&freq_varnum..);
                end;
                if _N_ = 1 then call symput("freq_maxlen", compress(put(max(_freq_maxlen, &&freq_vartype&freq_varnum..), 8.)));
            run;
        %end;
        %else %do;
            data freq_sort_values;
                set freq_sort_byvars;
                _freq_miss&freq_varnum. = 1;
                _freq_sort0 = 0;
                do &&freq_var&freq_varnum.. = &sort. ;
                    _freq_sort0 = _freq_sort0 + 1;
                    output;
                end;
            run;
        %end;

        proc sort data = freq_sort_values;
            by &freq_by_vars &freq_vars_sort_stat &&freq_var&freq_varnum..;
        run;


        data freq_sort_0;
            %if &&freq_vartype&freq_varnum.. > 0 %then length &&freq_var&freq_varnum.. $200; ;
            merge freq_sort_varnames freq_sort_values(in = _freq_inval);
            by &freq_by_vars &freq_vars_sort_stat &&freq_var&freq_varnum.. _freq_miss&freq_varnum.;


            if _freq_inval then _freq_in_sortval = 1;
            else _freq_in_sortval = 0;

            %if &&freq_vartype&freq_varnum.. > 0 %then %do;
                length _freq_varc $&freq_maxlen.;
                _freq_varc = &&freq_var&freq_varnum..;
                rename _freq_varc = &&freq_var&freq_varnum..;
                drop &&freq_var&freq_varnum..;
            %end;
        run;

        proc sort data = freq_sort_0;
            by &freq_by_vars &freq_vars_sort_stat
              _freq_miss&freq_varnum descending _freq_in_sortval _freq_sort0 &&freq_var&freq_varnum..;
        run;

        %let freq_sort_order_ds = freq_sort_0;
        %let freq_sort_order_byvars =
                    &freq_by_vars &freq_vars_sort_stat
                    _freq_miss&freq_varnum descending _freq_in_sortval _freq_sort0 &&freq_var&freq_varnum..;

        %let freq_del_list=&freq_del_list freq_sort_0 freq_sort_varnames freq_sort_values freq_sort_byvars;
    %end;
    %else %if &freq_stype = 5 %then %do; * by dummy dataset;
        proc sort data = freq%eval(&freq_now_num-1)
                  out = freq_sort_varnames(keep = &freq_by_vars &freq_vars_sort _freq_temp_var)
                  nodupkey;
            by &freq_by_vars &freq_vars_sort_stat &&freq_var&freq_varnum.. _freq_miss&freq_varnum.;
        run;


        data freq_sort_values;
            set &freq_dummyds.;
            %do freq_temp_i = 1 %to &freq_varnum.;
                _freq_miss&freq_temp_i. = 1;
            %end;
            _freq_sort0 = _N_;
            _freq_temp_var = 1;
        run;

        proc sort data = freq_sort_values;
            by &freq_by_vars &freq_vars_sort_stat &&freq_var&freq_varnum..;
        run;

        data freq_sort_0;
            merge freq_sort_varnames freq_sort_values(in = _freq_inval);
            by &freq_by_vars &freq_vars_sort_stat &&freq_var&freq_varnum.. _freq_miss&freq_varnum.;


            if _freq_inval then _freq_in_sortval = 1;
            else _freq_in_sortval = 0;
        run;

        proc sort data = freq_sort_0;
            by &freq_by_vars &freq_vars_sort_stat
              _freq_miss&freq_varnum descending _freq_in_sortval _freq_sort0 &&freq_var&freq_varnum..;
        run;

        %let freq_sort_order_ds = freq_sort_0;
        %let freq_sort_order_byvars =
                    &freq_by_vars &freq_vars_sort_stat
                    _freq_miss&freq_varnum descending _freq_in_sortval _freq_sort0 &&freq_var&freq_varnum..;

        %let freq_del_list=&freq_del_list freq_sort_varnames
                           freq_sort_values freq_sort_0;
    %end;

    * part 2 - create sort1-sortn variables in sort dataset;
    data freq_sort;
        set &freq_sort_order_ds;
        by &freq_sort_order_byvars;
        retain sortx1 - sortx&freq_varnum 0;

        if first.%scan(&freq_by_vars, -1) then sortx1 = 0;

        %do freq_temp_i = 1 %to &freq_varnum.;
            _freq_sum&freq_temp_i. = (_freq_miss&freq_temp_i. > 0);
            if first.&&freq_var&freq_temp_i.. then do;
                sortx&freq_temp_i. + 1;
                %do freq_temp_j = %eval(&freq_temp_i + 1) %to &freq_varnum.;
                     sortx&freq_temp_j. = -1;
                %end;
            end;
        %end;
        %do freq_temp_i = 1 %to &freq_varnum.;
            if _freq_miss&freq_temp_i. > 0 then sort&freq_temp_i. = sortx&freq_temp_i.;
                else sort&freq_temp_i. = sum(of _freq_sum:) - &freq_varnum.;
        %end;
        keep &freq_by_vars sort1-sort&freq_varnum &vars. _freq_temp_var _freq_miss1 - _freq_miss&freq_varnum;
    run;
    %let freq_del_list=&freq_del_list freq_sort;

    * part 3 - re-merge sort dataset;
    %if &freq_trantype = 2 or &freq_trantype = 4 %then %do;
        proc sort data = freq%eval(&freq_now_num-1) out = freq_tranvalues(keep = &freq_tranvar) nodupkey;
            by &freq_tranvar.;
        run;

        proc sql noprint;
            create table freq_sortall as
            select * from freq_sort, freq_tranvalues;
        quit;

        proc sort data = freq_sortall;
            by &freq_by_vars. &vars. _freq_miss1 - _freq_miss&freq_varnum &freq_tranvar.;
        run;

        proc sort data = freq%eval(&freq_now_num-1) out = freq&freq_now_num;
            by &freq_by_vars. &vars. _freq_miss1 - _freq_miss&freq_varnum &freq_tranvar.;
        run;
        %let freq_del_list=&freq_del_list freq&freq_now_num freq_sortall freq_tranvalues;
        %let freq_now_num = %eval(&freq_now_num. + 1);

        data freq&freq_now_num ;
            merge freq%eval(&freq_now_num-1)(in = _freq_inds)
                  freq_sortall;
            by &freq_by_vars. &vars. _freq_miss1 - _freq_miss&freq_varnum &freq_tranvar.;


        run;
        %let freq_del_list=&freq_del_list freq&freq_now_num;
        %let freq_now_num = %eval(&freq_now_num. + 1);
    %end;
    %else %do;
        proc sort data = freq_sort;
            by &freq_by_vars. &vars. _freq_miss1 - _freq_miss&freq_varnum;
        run;

        proc sort data = freq%eval(&freq_now_num-1) out = freq&freq_now_num;
            by &freq_by_vars. &vars. _freq_miss1 - _freq_miss&freq_varnum;
        run;
        %let freq_del_list=&freq_del_list freq&freq_now_num;
        %let freq_now_num = %eval(&freq_now_num. + 1);

        data freq&freq_now_num ;
            merge freq%eval(&freq_now_num-1)(in = _freq_inds)
                  freq_sort;
            by &freq_by_vars. &vars. _freq_miss1 - _freq_miss&freq_varnum;

        run;
        %let freq_del_list=&freq_del_list freq&freq_now_num;
        %let freq_now_num = %eval(&freq_now_num. + 1);

    %end;

    %freq_drop_from_list(list=freq_by_vars, new=_freq_temp_var);


    * Remove unnecessary total records;

    data freq&freq_now_num ;
        set freq%eval(&freq_now_num-1);
        %do freq_i = 1 %to &freq_tranvarnum.;
            %if &&freq_addtot_&freq_i.. = 0 %then %do;
                if &&freq_tranvar_&freq_i.. = &&freq_totval_&freq_i.. then delete;
            %end;
        %end;
    run;
    %let freq_del_list=&freq_del_list freq&freq_now_num;
    %let freq_now_num = %eval(&freq_now_num. + 1);



    * Counting denominator                                                                       *;
    %if &freq_perctype<4 %then %do;
        %local freq_by_wotrt;
        %let freq_by_wotrt = &freq_by;
        %freq_drop_from_list(list=freq_by_wotrt,new=&trt);

        %if &freq_perctype=1 %then %let freq_temp_var_set=&trt &popBy.;
        %else %do;
            %let freq_temp_var_set = &freq_by;
            %freq_add_in_list(list=freq_temp_var_set,new=&trt);
        %end;


        proc sql noprint;
            create table freq_den as
            %if &freq_perctype=1 %then %do; %*for Percent = POP take the numbers from PopDS dataset; %*;
                select
                    %if &freq_notrt=1 %then 1 as &trt ;
                        %else &trt ;
                    ,sum(PopCount) as den
                    &freq_sqlPopBy
                from &freq_popds
                %if %length(&freq_popflag)>0 %then where upcase(PopName)=upcase("&freq_popflag.") ;
                group by &trt &freq_sqlPopBy
                union
                select distinct &freq_trttotval as &trt, sum(PopCount) as den &freq_sqlPopBy
                from &freq_popds
                %if %length(&freq_popflag)>0 %then where upcase(PopName)=upcase("&freq_popflag.") ;
                %if &popBy. ne %then group by %sysfunc(tranwrd(%cmpres(&popBy.),%str( ),%str(,))) ;

                order by &trt &freq_sqlPopBy
                ;
            %end; %else %do; %*for Percent = ALLOBS, NONMIS calculate denominators based on data; %*;
                select %sysfunc(tranwrd(%cmpres(&freq_by_wotrt &trt ),%str( ),%str(,))) ,
                    %if &weight ne %then sum(&weight.) ;
                    %else %if &freq_counttype=1 %then count(*) ;
                    %else count(distinct &count);
                    as den
                from freq1
                %if &freq_perctype=3 %then %do; where not missing(&&freq_var&freq_varnum..)
                %end;
                group by %sysfunc(tranwrd(%cmpres(&freq_by_wotrt &trt),%str( ),%str(,)))
                union
                select
                    %if %length(&freq_by_wotrt) > 0 %then %do;
                        %sysfunc(tranwrd(%cmpres(&freq_by_wotrt),%str( ),%str(,))) ,
                    %end;
                    &freq_trttotval as &trt,
                    %if &freq_counttype=1 %then count(*) ; %else count(distinct &count); as den
                from freq1
                %if &freq_perctype=3 %then %do; where not missing(&&freq_var&freq_varnum..)
                %end;
                %if %length(&freq_by_wotrt) > 0 %then %do;
                    group by %sysfunc(tranwrd(%cmpres(&freq_by_wotrt),%str( ),%str(,)))
                %end;
                order by %sysfunc(tranwrd(%cmpres(&freq_temp_var_set.),%str( ),%str(,))) ;
            %end;
        quit;
        %let freq_del_list= &freq_del_list freq_den;
        * Merge denominators to original data;
        proc sort data = freq%eval(&freq_now_num-1);
            by &freq_temp_var_set.;
        run;

        data freq&freq_now_num ;
            merge freq%eval(&freq_now_num-1)(in=a) freq_den;
            by &freq_temp_var_set.;
            if a;
        run;
        %let freq_del_list= &freq_del_list freq&freq_now_num; %let freq_now_num=%eval(&freq_now_num+1);
    %end;

    *************************************************************************************************;
    * Counting percentages                                                                          *;
    %local freq_enoughput;
    %let freq_enoughput = 1;
    %let freq_pctaval = 1;

    proc sort data = freq%eval(&freq_now_num-1);
        by &freq_by_vars. &freq_tranvar. sort1-sort&freq_varnum;
    run;


    data freq&freq_now_num (drop = _freq_pctaval);
        set freq%eval(&freq_now_num-1);
        by &freq_by_vars. &freq_tranvar. sort1-sort&freq_varnum;
        length col $200;
        col="";
        _freq_pctaval = 1;
        if &freq_n. >= 10**&FreqPut. then call symput("freq_enoughput", "0");
        %if &freq_PERCTYPE<4 %then %do;

            if den>0 then do;
                %bmsfreq_percentages(n=&freq_n, den=den, outvar=col);
            end;
            else do;
                _freq_pctaval = 0;
            end;

            %if &keep_num. = YES %then %do;
                if den > 0 then do;
                    %do freq_temp_i = 1 %to &freq_varnum.;
                        %if &freq_perctype=3 %then %do; if _freq_miss&freq_temp_i. = 1 then %end;
                            %else %do; if _freq_miss&freq_temp_i. in (1 2) then %end;
                            if not missing(_freq_n_&&freq_var&freq_temp_i..) then
                                _freq_p_&&freq_var&freq_temp_i.. = _freq_n_&&freq_var&freq_temp_i../den*100;
                    %end;
                end;
            %end;
        %end;

        %if &keep_num = YES %then %do;
            %do freq_j = 1 %to &freq_varnum;
                retain _freq_np_&freq_j.;
                drop _freq_np_&freq_j.;
                %if &freq_perctype < 4 %then %do;
                    retain _freq_pp_&freq_j.;
                    drop _freq_pp_&freq_j.;
                %end;
                if first.sort&freq_j and  sort&freq_j > 0 and
                    missing(_freq_n_&&freq_var&freq_j..)
                then do;
                    _freq_n_&&freq_var&freq_j.. = 0;
                    %if &freq_perctype = 3 %then %do;
                         if _freq_miss&freq_j. = 1 then _freq_p_&&freq_var&freq_j.. = 0;
                    %end;
                    %else %if &freq_perctype <= 2 %then _freq_p_&&freq_var&freq_j.. = 0; ;
                end;
                if sort&freq_j > 0 and missing(_freq_n_&&freq_var&freq_j..)
                then do;
                    _freq_n_&&freq_var&freq_j.. = _freq_np_&freq_j.;
                    %if &freq_perctype < 4 %then
                    _freq_p_&&freq_var&freq_j.. = _freq_pp_&freq_j.;
                    ;
                end;
                _freq_np_&freq_j. = _freq_n_&&freq_var&freq_j..;
                %if &freq_perctype < 4 %then
                _freq_pp_&freq_j. = _freq_p_&&freq_var&freq_j..;
                ;
            %end;
        %end;



        if missing(&freq_n.) then &freq_n. = 0;

        if &freq_n.>0
            %if &freq_perctype=3 %then and _freq_miss&freq_varnum. ^= 2 ;
        then do;
            if _freq_pctaval = 1 then col=put(&freq_n,&FreqPut..)||" "||col;
            else call symput("freq_pctaval", "0");
        end;
        else col=put(&freq_n,&FreqPut..);

    run;
    %if &freq_enoughput=0 %then %do;
        %freq_message(type=ERR,
            message= %quote(There is not enough space to put the results. Check FreqPut value.));
    %end;
    %if &freq_pctaval=0 %then %do;
        %freq_message(type=ERR,
            message= %quote(Cannot calculate percentages. The denominator is either zero or missing.));
    %end;

    %let freq_del_list= &freq_del_list freq&freq_now_num; %let freq_now_num=%eval(&freq_now_num+1);



    *Adding records for label and repby variables, calculating shifts;
    * Create VARS variable;
    proc sort data = freq%eval(&freq_now_num-1);
        by _freq_temp_var &freq_tranvar. &freq_by_vars.;
    run;

    data freq&freq_now_num ;
        set freq%eval(&freq_now_num-1);
        by _freq_temp_var &freq_tranvar. &freq_by_vars.;
        length vars $200;

        %do freq_temp_i = 1 %to &freq_varnum;
            if
                %if &freq_temp_i = &freq_varnum %then %do; sort&freq_varnum > 0 %end;
                %else %do; sort&freq_varnum = %eval(&freq_temp_i - &freq_varnum) %end;
            then do;
                %if &&freq_vartype&freq_temp_i.. = 0 %then %do;
                    vars = left(put(&&freq_var&freq_temp_i.., best.));
                %end;
                %else %do;
                    vars = &&freq_var&freq_temp_i..;
                %end;
                %if %upcase(&PutMiss.) = NO %then %do;
                    if missing(&&freq_var&freq_temp_i..) then delete;
                %end;
                %else %do;
                    if missing(&&freq_var&freq_temp_i..) then vars = &missing_word.;
                %end;
            end;
        %end;

        %if %length(&freq_repby)>0 or %length(%qscan(&label,1,%str(%"%')))>1 and &freq_novar=0 %then %do;
            output;
            col = "";

            %do freq_temp_j = 1 %to &freq_varnum;
                %if &keep_num =YES %then %do;
                    _freq_n_&&freq_var&freq_temp_j.. = .;
                    %if &freq_perctype. < 4 %then
                        _freq_p_&&freq_var&freq_temp_j.. = .;
                    ;
                %end;
                _freq_miss&freq_temp_j. = 0;
                call missing(&&freq_var&freq_temp_j..);
            %end;
        %end;

        %let freq_shift = %eval(&freq_varnum - 1);

        * Adding LABEL into VARS *;
        %if %length(%qscan(&label,1,%str(%"%')))>1 and &freq_novar=0 %then %do;

           if first.%qscan(_freq_temp_var &freq_tranvar. &freq_by_vars,-1) then do;
               vars=left(upcase(&label));
               %do freq_do_j= 1 %to &freq_varnum;
                   sort&freq_do_j. = -%eval(&freq_shift+1);
               %end;
               output;
           end;
           %let freq_shift=%eval(&freq_shift+1);
        %end;

        %if %length(&freq_repby)>0 %then %do;
            %let freq_do_i=1;
            %do %while (%length(%qscan(&freq_repby,-&freq_do_i))>0);
                if first.%qscan(&freq_repby,-&freq_do_i) then do;
                    %do freq_temp_j = 1 %to &freq_varnum;
                        sort&freq_temp_j. = -%eval(&freq_shift+1);
                    %end;
                    vars=upcase(%qscan(&freq_repby,-&freq_do_i)); if missing(vars) then vars=upcase(&missing_word);
                    *set to missing all internal by-vars in added line;
                    %let freq_do_j=1;
                    %local freq_startmiss;
                    %let freq_startmiss = 0;
                    %do %while (%length(%qscan(&freq_by,&freq_do_j))>0);
                        %if &freq_startmiss = 1 %then call missing(%qscan(&freq_by,&freq_do_j)); ;
                        %if %qscan(&freq_repby,-&freq_do_i) = %qscan(&freq_by,&freq_do_j) %then %let freq_startmiss = 1;
                        %let freq_do_j = %eval(&freq_do_j+1);
                    %end;
                    output;
                end;
                %let freq_do_i = %eval(&freq_do_i+1); %let freq_shift=%eval(&freq_shift + 1);
            %end;
        %end;
    run;
    %let freq_del_list= &freq_del_list freq&freq_now_num; %let freq_now_num=%eval(&freq_now_num+1);

    proc sort data = freq%eval(&freq_now_num - 1);
        by &freq_by_vars. sort1-sort&freq_varnum;
    run;

    %if &freq_trantype = 2 or &freq_trantype = 4 %then %do;
        * Transposing;
        data freq&freq_now_num ;
            set freq%eval(&freq_now_num-1);
            length _freq_tran_var $200.;
            * create transpose variable;
            _freq_tran_var = "";
            %do freq_i = 1 %to &freq_tranvarnum;
                _freq_tran_var = compress(_freq_tran_var) || "&&freq_tranpref_&freq_i..";
                if &&freq_tranvar_&freq_i.. = &&freq_totval_&freq_i.. then _freq_tran_var =  trim(_freq_tran_var) || "Total";
                else
                %if &&freq_tranvartype_&freq_i.. = 0 %then %do;
                    _freq_tran_var =  compress(_freq_tran_var) || translate(compress(put(&&freq_tranvar_&freq_i., best20.)), '___', '.-+');
                %end;
                %else %do;
                    %*change to underscores all except alphabetic chars and digits; %*;
                    _freq_tran_var = compress(_freq_tran_var) || prxChange("s/\W/_/",-1, strip(&&freq_tranvar_&freq_i.));
                %end;
            %end;
        run;

        proc sql noprint;
            %do freq_i = 1 %to &freq_tranvarnum;

                %if &freq_perctype = 1 and %upcase(&trt.) = %upcase(&&freq_tranvar_&freq_i..) %then %do;
                    create table freq_tranlist_&freq_i. as
                    select distinct &trt, max(den) as den
                    from ( select coalesce(a.&trt., b.&trt.) as &trt., a.den
                           from freq_den a full join
                                (select distinct &trt. from freq%eval(&freq_now_num-1)) b
                            on a.&trt. = b.&trt.
                          )
                    %if &&freq_addtot_&freq_i.. = 0 %then %do;
                        where &trt. ne &&freq_totval_&freq_i..
                    %end;
                    group by &trt.
                    ;
                %end;
                %else %do;
                    create table freq_tranlist_&freq_i. as select distinct &&freq_tranvar_&freq_i..
                    from freq%eval(&freq_now_num-1)
                    %if &&freq_addtot_&freq_i.. = 0 %then %do;
                        where &&freq_tranvar_&freq_i.. ne &&freq_totval_&freq_i..
                    %end;
                    ;
                %end;
                %let freq_del_list= &freq_del_list freq_tranlist_&freq_i.;
            %end;

            create table freq_tranlist as
            select * from freq_tranlist_1
            %do freq_i = 2 %to &freq_tranvarnum;
                , freq_tranlist_&freq_i.
            %end;
            ;

            select count(*) into :freq_trannum from freq_tranlist ;
        quit;


        data _null_;
            den = 1; * Will be overwritten if there is den variable in freq_trtlist dataset, will be 1 otherwise;
            set freq_tranlist nobs = _freq_nobs;

            length _freq_tran_var $200.;
            length _freq_tran_short $200.;
            * create transpose variable;
            _freq_tran_var = "";
            _freq_tran_short = "";
            %do freq_i = 1 %to &freq_tranvarnum;
                _freq_tran_var = trim(_freq_tran_var) || "&&freq_tranpref_&freq_i..";
                _freq_tran_short = trim(_freq_tran_short) || "_";
                if &&freq_tranvar_&freq_i.. = &&freq_totval_&freq_i.. then do;
                    _freq_tran_var =  trim(_freq_tran_var) || "Total";
                    _freq_tran_short =  trim(_freq_tran_short) || "Total";
                end;
                else do;
                    %if &&freq_tranvartype_&freq_i. = 0 %then %do;
                        _freq_tran_var =  trim(_freq_tran_var)
                                       || translate(compress(put(&&freq_tranvar_&freq_i.., best20.)), '___', '.-+');
                        _freq_tran_short = trim(_freq_tran_short)
                                        || translate(compress(put(&&freq_tranvar_&freq_i.., best20.)), '___', '.-+');
                    %end;
                    %else %do;
                        %*change to underscores all except alphabetic chars and digits; %*;
                        _freq_tran_var = trim(_freq_tran_var) || prxChange("s/\W/_/",-1, strip(&&freq_tranvar_&freq_i..));
                        _freq_tran_short = trim(_freq_tran_short) || prxChange("s/\W/_/",-1, strip(&&freq_tranvar_&freq_i..));
                    %end;
                end;
            %end;

            nonzerotrt = "1";
            %if &freq_perctype = 1 %then %do;
                 if den <= 0 then nonzerotrt = "0";
            %end;
            call symput("freq_tran_" || compress(put(_N_, 8.)), compress(_freq_tran_var));
            call symput("freq_tran_short_" || compress(put(_N_, 8.)), compress(_freq_tran_short));
            call symput("freq_nztrt" || compress(put(_N_, 8.)), nonzerotrt);
        run;
        %let freq_del_list= &freq_del_list freq_tranlist freq&freq_now_num; %let freq_now_num=%eval(&freq_now_num+1);
        proc sort data = freq%eval(&freq_now_num - 1)
                  out = freq_base(keep = &freq_by_vars. sort1-sort&freq_varnum &vars _freq_miss1-_freq_miss&freq_varnum vars)
                  nodupkey;
            by &freq_by_vars. sort1-sort&freq_varnum;
        run;

        data freq&freq_now_num;
            merge
                freq_base

            %do freq_i = 1 %to &freq_trannum;
                freq%eval(&freq_now_num - 1) (
                    keep = &freq_by_vars. &vars. sort1 - sort&freq_varnum _freq_miss1 - _freq_miss&freq_varnum
                           _freq_tran_var col
                    rename = (_freq_tran_var = _freq_tran_var_&freq_i. col = &&freq_tran_&freq_i..)

                    %if &keep_num =YES %then %do;
                    keep = _freq_n:
                           %if &freq_perctype < 4 %then _freq_p: ;

                    rename = (
                        %do freq_temp_j = 1 %to &freq_varnum;
                            _freq_n_&&freq_var&freq_temp_j.. =
                            _freq_n_&&freq_var&freq_temp_j..&&freq_tran_short_&freq_i..
                            %if &freq_perctype < 4 %then %do;
                                _freq_p_&&freq_var&freq_temp_j.. =
                                _freq_p_&&freq_var&freq_temp_j..&&freq_tran_short_&freq_i..
                            %end;
                        %end;
                        )
                    %end;
                    where = (_freq_tran_var_&freq_i. = "&&freq_tran_&freq_i..")
                )
            %end;
            ;
        by &freq_by_vars. sort1-sort&freq_varnum &vars _freq_miss1-_freq_miss&freq_varnum;
        %if &freq_trannum > 0 %then   drop _freq_tran_var_:;  ;
        run;

        %let freq_del_list= &freq_del_list freq&freq_now_num  freq_base; %let freq_now_num=%eval(&freq_now_num+1);
    %end;
    %else %let freq_trannum = 0;

    *Shifting values in VARS variable, putting zeroes for missing results after transpoing;
    data freq&freq_now_num ;
        set freq%eval(&freq_now_num-1);
        by &freq_by_vars. sort1-sort&freq_varnum;

        if sort&freq_varnum. < 0 and sort&freq_varnum > -&freq_shift then do;
            if (&freq_shift+sort&freq_varnum)*&shift - 1 >= 0 then
                vars = repeat(' ', (&freq_shift+sort&freq_varnum)*&shift - 1) || vars;
        end;
        else if sort&freq_varnum. > 0 and &freq_shift > 0 then do;
            if &freq_shift*&shift - 1 >= 0 then
                vars = repeat(' ', &freq_shift*&shift - 1) || vars;
        end;

        %if &freq_trantype = 2 or &freq_trantype = 4 %then %do;
            %do freq_i = 1 %to &freq_trannum;
                %if &&freq_nztrt&freq_i.. = 1 %then %do;
                    if sort1 > 0 then do;
                        if missing(&&freq_tran_&freq_i..) then &&freq_tran_&freq_i.. = put(0, &freqput..);
                    end;
                    %if &keep_num = YES %then %do;
                        %do freq_j = 1 %to &freq_varnum;
                            retain _freq_np_&freq_j._&freq_i.;
                            drop _freq_np_&freq_j._&freq_i.;
                            %if &freq_perctype < 4 %then %do;
                                retain _freq_pp_&freq_j._&freq_i.;
                                drop _freq_pp_&freq_j._&freq_i.;
                            %end;
                            if first.sort&freq_j and  sort&freq_j > 0 and
                                missing(_freq_n_&&freq_var&freq_j..&&freq_tran_short_&freq_i..)
                            then do;
                                _freq_n_&&freq_var&freq_j..&&freq_tran_short_&freq_i.. = 0;
                                %if &freq_perctype = 3 %then %do;
                                     if _freq_miss&freq_j. = 1 then _freq_p_&&freq_var&freq_j..&&freq_tran_short_&freq_i.. = 0;
                                %end;
                                %else %if &freq_perctype <= 2 %then _freq_p_&&freq_var&freq_j..&&freq_tran_short_&freq_i.. = 0; ;
                            end;
                            if sort&freq_j > 0 and missing(_freq_n_&&freq_var&freq_j..&&freq_tran_short_&freq_i..)
                            then do;
                                _freq_n_&&freq_var&freq_j..&&freq_tran_short_&freq_i.. = _freq_np_&freq_j._&freq_i.;
                                %if &freq_perctype < 4 %then
                                _freq_p_&&freq_var&freq_j..&&freq_tran_short_&freq_i.. = _freq_pp_&freq_j._&freq_i.;
                                ;
                            end;
                            _freq_np_&freq_j._&freq_i. = _freq_n_&&freq_var&freq_j..&&freq_tran_short_&freq_i..;
                            %if &freq_perctype < 4 %then
                            _freq_pp_&freq_j._&freq_i. = _freq_p_&&freq_var&freq_j..&&freq_tran_short_&freq_i..;
                            ;
                        %end;
                    %end;
                %end;
            %end;
        %end;

    run;
    %let freq_del_list= &freq_del_list freq&freq_now_num; %let freq_now_num=%eval(&freq_now_num+1);


    %if &freq_notrt = 1 %then %freq_drop_from_list(list=freq_by_vars, new=&trt.);

    * Output Dataset *;
    data &DataOut(keep=&freq_by_vars  vars sort:
            %if %length(&id)>0 %then %do; id %end;
            %if &keep_vars = YES and &freq_novar = 0 %then %do; &vars %end;
            %if &freq_trantype > 1 %then %do;
                %if &freq_trannum > 0 %then %do;
                   %do freq_i = 1 %to &freq_trannum;
                        &&freq_tran_&freq_i..
                    %end;
                    %if &keep_num = YES %then %do;
                        _freq_n_:
                        %if &freq_perctype < 4 %then _freq_p_: ;
                    %end;
                %end;
            %end;
            %else %if &freq_trantype. = 1 %then %do;
                 &tranPrefix.
                 %if &keep_num = YES %then %do;
                     _freq_n_:
                     %if &freq_perctype < 4 %then _freq_p_: ;
                 %end;
            %end;

            %if &keep_num = YES and &freq_novar = 1 and &freq_trannum > 0 %then %do;
                rename = (
                %do freq_trt_i = 1 %to &freq_trannum;
                    _freq_n__freq_tmpvar&&freq_tran_short_&freq_trt_i.. = _freq_n&&freq_tran_short_&freq_trt_i.
                    %if &freq_perctype < 4 %then %do;
                        _freq_p__freq_tmpvar&&freq_tran_short_&freq_trt_i.. = _freq_p&&freq_tran_short_&freq_trt_i.
                    %end;
                %end;
                )
            %end;
            %else %if &keep_num = YES and &freq_novar = 1 and &freq_trantype = 1 %then %do;
                rename = (
                    _freq_n__freq_tmpvar = _freq_n
                    %if &freq_perctype < 4 %then %do;
                        _freq_p__freq_tmpvar= _freq_p
                    %end;
                )
            %end;

        );
        set freq%eval(&freq_now_num-1);

        %if %length(&id.) > 0 %then id = &id.; ;
        rename sort&freq_varnum = sort0;

        %if &freq_trantype. = 1 %then %do;
             rename col = &tranPrefix.;
        %end;

    run;

%if &gmDebug>0 %then %do;
    %put NOTE: [PXL] _local_;
%end; %else %do;
    proc datasets nolist lib=work memtype=data;
        delete &freq_del_list;
    quit;
%end;

    %gmEnd(headURL  = $    $);


%mend BMSfreq;
