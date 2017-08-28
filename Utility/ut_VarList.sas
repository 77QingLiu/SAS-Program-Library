*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_VarList Returns a string containing a space separated list of variables in a dataset.

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
--------------------------------------------------------------------------------------------------;

%macro ut_VarList(DATA
                  ,UPCASE = N
                  ,SORT = N
                  ,QUOTE = 
                  ,VarType = ALL);
    %pv_Start(ut_VarList)

    %local  ut_VarList_macroname
            ut_VarList_dsid
            ut_VarList_nvars
            VarList;
    %let    ut_VarList_macroname  = &SYSMACRONAME;

    %* Parameter validation %*;
    %pv_Define( &ut_VarList_macroname ,DATA ,_pmRequired = 1 ,_pmAllowed = DATASET)
    %pv_Define( &ut_VarList_macroname ,UPCASE ,_pmRequired = 1 ,_pmAllowed = N Y)
    %pv_Define( &ut_VarList_macroname ,SORT ,_pmRequired = 1 ,_pmAllowed = N Y)
    %pv_Define( &ut_VarList_macroname ,VarType ,_pmRequired = 1 ,_pmAllowed = ALL NUM CHAR)
    %pv_Define( &ut_VarList_macroname ,QUOTE ,_pmRequired = 0 ,_pmAllowed = any)

    %* Check if dataset exist, abort if not %*;
    %If ~( %Sysfunc(EXIST(&DATA.)) OR %Sysfunc(EXIST(&DATA.,VIEW))) %Then %Do;
        %pv_Message( MessageLocation = MACRO:  &ut_VarList_macroname - to check input dataset
                    , MessageDisplay = @Dataset or View &DATA. does not exists. Number of observations can not be determined.
                    , MessageType   = ERROR
                    )
    %end;
    %Let SYSCC=0;

    %* Open dataset to get varaible list %*;
    %Let ut_VarList_dsid = %Sysfunc(OPEN(&DATA.,I));
    %Let ut_VarList_nvars  = %Sysfunc(ATTRN(&ut_VarList_dsid.,nvars));

    %If &SYSCC.>0 %Then %Do;
        %pv_Message( MessageLocation=MACRO:  &ut_VarList_macroname - to do post execution check
              , MessageDisplay= @After retrieving obs. An Error was detected. %sysfunc(sysmsg())
              , MessageType=ABORT
              )
    %End;
    %Else %If &ut_VarList_nvars lt 1 %Then %Do;
        %pv_Message( MessageLocation=MACRO:  &ut_VarList_macroname - to check variable number
              , MessageDisplay= @(varlist) No variables in dataset &DATA.;
              , MessageType=ABORT
              )
    %End;
    %Else %Do;
        %let VarList=;
        %Do i=1 %To &ut_VarList_nvars;
            %If &VarType = CHAR %Then %Do;
                %if "%sysfunc(vartype(&ut_VarList_dsid,&i))" EQ "C" %then %do;
                    %If %length(&VarList) eq 0 %Then %Let VarList=%sysfunc(varname(&ut_VarList_dsid,&i));
                    %Else %Let VarList=&VarList %sysfunc(varname(&ut_VarList_dsid,&i));
                %End;
            %End;
            %Else %If &VarType = NUM %Then %Do;
                %if "%sysfunc(vartype(&ut_VarList_dsid,&i))" EQ "N" %then %do;
                    %If %length(&VarList) eq 0 %Then %Let VarList=%sysfunc(varname(&ut_VarList_dsid,&i));
                    %Else %Let VarList=&VarList %sysfunc(varname(&ut_VarList_dsid,&i));
                %End;
            %End;
            %Else %Do;
                %If %length(&VarList) eq 0 %Then %Let VarList=%sysfunc(varname(&ut_VarList_dsid,&i));
                %Else %Let VarList=&VarList %sysfunc(varname(&ut_VarList_dsid,&i));
            %End;
        %end;
    %End;

    %Let ut_VarList_rc   = %Sysfunc(CLOSE(&ut_VarList_dsid.));
    %pv_End(ut_VarList)

    %global test;
    %let test = &VarList;

    %* Post processing %*;
    %If &UPCASE = Y %Then %Do;
        %let VarList = %upcase(&VarList);
    %End;

    %If %Length(%Superq(QUOTE)) %Then %Do;
        %let VarList = %ut_QuoteLST(&VarList, quote = &QUOTE);
    %End;

    %If &SORT = Y %Then %Do;
        %let VarList = %ut_SortLST(VarList);
    %End;

    %* Return sorted list %*;
    &VarList
%mend;