*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_VarLst Returns a string containing a space separated list of variables in a dataset.

    Macro Parameters:

        Name:                DATA
            Allowed Values:    Any valid SAS dataset
            Default Value:     REQUIRED
            Description:       The name of SAS dataset

        Name:                UPCASE
            Allowed Values:    N|Y
            Default Value:     N
            Description:       return upcase version of variable list

        Name:                SORT
            Allowed Values:    N|Y
            Default Value:     N
            Description:       return sorted version of variable list

        Name:                QUOTE
            Allowed Values:    any string
            Default Value:     "
            Description:       return quoted version of variable list 

        Name:                VarType
            Allowed Values:    ALL|CHAR|NUM
            Default Value:     ALL
            Description:       enable filter variable by type

        Name:                PATTERN
            Allowed Values:    any string
            Default Value:     
            Description:       enable filter variable by regex pattern                       
--------------------------------------------------------------------------------------------------;

%macro ut_VarLst(DATA
                  ,UPCASE = N
                  ,SORT = N
                  ,QUOTE = 
                  ,VarType = ALL
                  ,PATTERN = );
    %pv_Start(ut_VarLst)

    %local  ut_VarLst_macroname
            ut_VarLst_dsid
            ut_VarLst_nvars
            VarLst
            ut_VarLst_var;
    %let    ut_VarLst_macroname  = &SYSMACRONAME;

    %* Parameter validation %*;
    %pv_Define( &ut_VarLst_macroname ,DATA ,_pmRequired = 1 ,_pmAllowed = DATASET)
    %pv_Define( &ut_VarLst_macroname ,UPCASE ,_pmRequired = 1 ,_pmAllowed = N Y)
    %pv_Define( &ut_VarLst_macroname ,SORT ,_pmRequired = 1 ,_pmAllowed = N Y)
    %pv_Define( &ut_VarLst_macroname ,VarType ,_pmRequired = 1 ,_pmAllowed = ALL NUM CHAR)
    %pv_Define( &ut_VarLst_macroname ,QUOTE ,_pmRequired = 0 ,_pmAllowed = any)
    %pv_Define( &ut_VarLst_macroname ,PATTERN ,_pmRequired = 0 ,_pmAllowed = any)    

    %* Check if dataset exist, abort if not %*;
    %If ~(%Sysfunc(EXIST(&DATA.)) OR %Sysfunc(EXIST(&DATA.,VIEW))) %Then %Do;
        %pv_Message( MessageLocation = MACRO:  &ut_VarLst_macroname - to check input dataset
                    , MessageDisplay = @Dataset or View &DATA. does not exists. Number of observations can not be determined.
                    , MessageType   = ABORT
                    )
    %end;

    %* Open dataset to get varaible list %*;
    %Let ut_VarLst_dsid = %Sysfunc(OPEN(&DATA.,I));
    %Let ut_VarLst_nvars  = %Sysfunc(ATTRN(&ut_VarLst_dsid.,nvars));

    %If &ut_VarLst_nvars lt 1 %Then %Do;
        %pv_Message( MessageLocation=MACRO:  &ut_VarLst_macroname - to check variable number
              , MessageDisplay= @(varlst) No variables in dataset &DATA.;
              , MessageType=ABORT
              )
    %End;
    %Else %Do;
        %let VarLst=;
        %Do i=1 %To &ut_VarLst_nvars;
            %let ut_VarLst_var = %sysfunc(varname(&ut_VarLst_dsid,&i));

            %* Filter by type %*;
            %If &VarType = CHAR and "%sysfunc(vartype(&ut_VarLst_dsid,&i))" NE "C" %then %do;
                    %Let ut_VarLst_var =;
            %End;
            %If &VarType = NUM and "%sysfunc(vartype(&ut_VarLst_dsid,&i))" NE "N" %then %do;
                    %Let ut_VarLst_var =;
            %End;
            %* Filter by pattern %*;
            %If %length(&PATTERN) %then %do;
                %If not %sysfunc(prxmatch(/^&PATTERN$/i, &ut_VarLst_var )) %then %do;
                    %Let ut_VarLst_var =;
                %End;
            %End;

            /* Add variable to list if not blank */
            %If %length(&ut_VarLst_var) %Then %Do;
                %If %length(&VarLst) eq 0 %Then %Let VarLst=%sysfunc(varname(&ut_VarLst_dsid,&i));
                %Else %Let VarLst=&VarLst %sysfunc(varname(&ut_VarLst_dsid,&i));
            %End;
        %End;
    %End;

    %Let ut_VarLst_rc   = %Sysfunc(CLOSE(&ut_VarLst_dsid.));
    %pv_End(ut_VarLst)

    %global test;
    %let test = &VarLst;

    %* Post processing %*;
    %If &UPCASE = Y %Then %Do;
        %let VarLst = %upcase(&VarLst);
    %End;

    %If %Length(%Superq(QUOTE)) %Then %Do;
        %let VarLst = %ut_QuoteLST(&VarLst, quote = &QUOTE);
    %End;

    %If &SORT = Y %Then %Do;
        %let VarLst = %ut_SortLST(VarLst);
    %End;

    %* Return sorted list %*;
    &VarLst
%mend;