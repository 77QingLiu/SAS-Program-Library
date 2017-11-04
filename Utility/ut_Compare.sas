/*-----------------------------------------------------------------------------
Program Purpose:       The macro %ut_Compare Either Base and Compare datasets or Base and Compare libraries

    Macro Parameters:

    Name:                pathOut
        Allowed Values:    Any valid and existing UNIX path
        Default Value:     BLANK
        Description:       Directory where compare report txt output is stored.  If not specified 
                            the output will be routed to the same area SAS is started from.

    Name:                BASE
        Allowed Values:    Library.dataset
        Default Value:     REQUIRED
        Description:       base Library.dataset to be compared

    Name:                COMPARE
        Allowed Values:    Library.dataset
        Default Value:     REQUIRED
        Description:       compare Library.dataset to be compared

    Name:                ID
        Allowed Values:    '@' delimited list
        Default Value:     BLANK
        Description:       ID variables ('@' delimited) for proc compare

    Name:                checkVarOrder
        Allowed Values:    1|0
        Default Value:     0
        Description:       1 to check that the sequence of variables in the
                         production and QC dataset match.
                         Differences are presented in the output window/file

    Name:                transpose
        Allowed Values:    1|0
        Default Value:     0
        Description:       1 sets the transpose option on the PROC COMPARE
 
    Name:                selectDataType
        Allowed Values:    '@' delimited list.
        Default Value:     BLANK
        Description:       Control the output data set from the PROC COMPARE. Valid values as follows:
                         * OUTALL: Write an observation for each observation in the BASE= and COMPARE= data sets
                         * OUTBASE: Write an observation for each observation in the BASE= data set
                         * OUTCOMP: Write an observation for each observation in the COMPARE= data set
                         * OUTDIF: Write an observation that contains the differences for each pair of matching observations
                         * OUTNOEQUAL: Suppress the writing of observations when all values are equal
                         * OUTPERCENT: Write an observation that contains the percent differences for each pair of matching observations 

-----------------------------------------------------------------------------*/
%MACRO ut_Compare( pathOut                  = 
                , BASE                      =
                , COMPARE                   =
                , ID                        =
                , checkVarOrder             = 0
                , transpose                 = 0
                , SelectDataType            = 
                );

    %let _macroname = &SYSMACRONAME;      
    %pv_Start(ut_Compare);

    /* Validate pathout */
    %pv_Define(ut_Compare ,pathOut ,_pmRequired = 1 ,_pmAllowed = any);
    %IF %SYSFUNC(FILEEXIST(&pathOut)) = 0 %THEN %DO;  
        %pv_Message( MessageLocation = MACRO: &_macroname - check required macro parameter[pathOut]
                    , MessageDisplay = %str(@Parameter[pathOut] does not exist - ending macro);
                    , MessageType   = ABORT
                    )
    %END;

    /* Validate BASE dataset */
    %pv_Define(ut_Compare ,BASE ,_pmRequired = 1 ,_pmAllowed = DATASET);
    %IF %SYSFUNC(EXIST(&BASE)) = 0 %THEN %DO;  
        %pv_Message( MessageLocation = MACRO: &_macroname - check required macro parameter[BASE]
                    , MessageDisplay = %str(@Parameter[BASE] does not exist - ending macro);
                    , MessageType   = ABORT
                    )
    %END;    

    /* Validate COMPARE dataset */
    %pv_Define(ut_Compare ,COMPARE ,_pmRequired = 1 ,_pmAllowed = DATASET);
    %IF %SYSFUNC(EXIST(&COMPARE)) = 0 %THEN %DO;  
        %pv_Message( MessageLocation = MACRO: &_macroname - check required macro parameter[COMPARE]
                    , MessageDisplay = %str(@Parameter[COMPARE] does not exist - ending macro);
                    , MessageType   = ABORT
                    )
    %END;

    %pv_Define(ut_Compare ,ID ,_pmRequired = 0 ,_pmAllowed = SASNAME)
    %ut_VarAttrib(&BASE ,ID)
    %ut_VarAttrib(&COMPARE ,ID)

    %pv_Define(ut_Compare ,SelectDataType ,_pmRequired = 0 ,_pmAllowed = OUTALL OUTBASE OUTCOMP OUTDIF OUTNOEQUAL OUTPERCENT);

    %LOCAL
         _dataset 
         _title9 _title10 _username _excl_prod _excl_qc
         _outputQcPrefix _dsQcPrefix compareExcludeRecordobs _selectDataType;
         
    %GLOBAL gmCompareSysInfoResult;
    %LET gmCompareSysInfoResult =;
    %LET _username              =%gmGetUserName;
    %LET _outputQcPrefix        = ir;
    %LET _dataset               = %SYSFUNC(prxchange(s/^ *(\w+\.)?(\w+) *$/\2/, -1, &BASE));
    %LET _dropvar               = %ut_VarLst(sashelp.air, PATTERN = grpx.* );

    OPTIONS CENTER NODATE NONUMBER PS=47;

    *---------------------------------------------- Compare ------------------------------------------------;
    TITLE1 "EQC of Base: &BASE, Compare: &Compare.. Validation produced by &_username. on &sysdate9..";

    DATA _NULL_;
        CALL SYMPUT("_ls2",TRIM(LEFT(PUT(LENGTH("EQC of Base: &BASE, Compare: &Compare.. Validation produced by &_username. on &sysdate9.."),best.))));
    RUN;
    OPTIONS LS=&_ls2.;

    /* Output to txt file */
    ODS EXCLUDE NONE;
    PROC PRINTTO NEW FILE="&pathOut.%lowcase(&_outputQcPrefix.&_dataset.).txt";
    RUN;
  
    PROC COMPARE DATA=&BASE(%if %LENGTH(&_dropvar) %Then DROP= &_dropvar ;)
               COMPARE=&COMPARE((%if %LENGTH(&_dropvar) %Then DROP= &_dropvar ;)) 
               LISTALL CRITERION=0.00000001 MAXPRINT=(50,32767)

                %IF "&SelectDataType." NE "" %THEN %DO;    
                    OUT = &_selectDataType.
                %END;
                %IF &transpose. %THEN %DO;
                    transpose
                %END;   
               ;
                %IF "&_dropvar." NE "" %THEN %DO;
                    TITLE2 "Variables excluded from dataset: &_dropvar.";
                %END;
                %IF "&ID." NE "" %THEN %DO;
                    ID &_IDBlank.;
                %END;
    RUN;

    %IF &checkVarOrder. %THEN %DO;
        /*  */
    %END;

    PROC PRINTTO;
    RUN;
    TITLE;
    %*--- Print the compare to output in interactive mode ---*;
    DATA _NULL_;
        INFILE "&pathOut.%lowcase(&_outputQcPrefix.&_dataset.).txt";
        INPUT;
        FILE PRINT;
        PUT _inFile_;
    RUN;
    %pv_End(ut_Compare);
%MEND ut_Compare;
