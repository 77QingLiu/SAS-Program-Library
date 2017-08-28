*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_VarAttrib return attributes of a SAS dataset 
                       ,optionally used to check for the existence of a specified variable

    Macro Parameters:

        Name:                DATA
            Allowed Values:    Any valid SAS dataset
            Default Value:     REQUIRED
            Description:       The name of SAS dataset

        Name:                VAR
            Allowed Values:    Any valid SAS variable name in SAS dataset
            Default Value:     REQUIRED
            Description:       The name of SAS variable

        Name:                ATTRIB
            Allowed Values:    NUM|LEN|FMT|INFMT|LABEL|TYPE
            Default Value:     NUM
            Description:       return attributes of a SAS dataset
--------------------------------------------------------------------------------------------------;

%macro ut_VarAttrib(DATA
                  ,VAR
                  ,ATTRIB = NUM);
    %pv_Start(ut_VarAttrib)
    %local  ut_VarAttrib_macroname 
            ut_VarAttrib_ATTRIB;
    %let    ut_VarAttrib_macroname  = &SYSMACRONAME;
    %let    ut_VarAttrib_ATTRIB     = %unquote(var&ATTRIB);

    %* Parameter validation %*;
    %pv_Define( &ut_VarAttrib_macroname ,DATA ,_pmRequired = 1 ,_pmAllowed = DATASET)
    %pv_Define( &ut_VarAttrib_macroname ,VAR ,_pmRequired = 1 ,_pmAllowed = SASNAME)
    %pv_Define( &ut_VarAttrib_macroname ,ATTRIB ,_pmRequired = 1 ,_pmAllowed = NUM LEN FMT INFMT LABEL TYPE)

    %* Check if dataset exist, abort if not %*;
    %If ~( %Sysfunc(EXIST(&DATA.)) OR %Sysfunc(EXIST(&DATA.,VIEW))) %Then %Do;
        %pv_Message( MessageLocation = MACRO:  &ut_VarAttrib_macroname - to check input dataset
                    , MessageDisplay = @Dataset or View &DATA. does not exists. Number of observations can not be determined.
                    , MessageType   = ERROR
                    )
    %end;
    %Let SYSCC=0;

    %* Get variable attribe %*;

    %Let ut_VarAttrib_dsid = %Sysfunc(OPEN(&DATA.,I));
    %Let ut_VarAttrib_num  = %Sysfunc(VARNUM(&ut_VarAttrib_dsid.,&var));

    %If &SYSCC.>0 %Then %Do;
        %pv_Message( MessageLocation=MACRO:  &ut_VarAttrib_macroname - to do post execution check
              , MessageDisplay= @After retrieving obs. An Error was detected.
              , MessageType=ABORT
              )
    %End;

    %Else %Do;
        %If (&ut_VarAttrib_num) %Then %Do;
            %if (&ATTRIB eq NUM) %Then %Do;
                &ut_VarAttrib_num
            %End;
            %Else %Do;
                %sysfunc(&ut_VarAttrib_ATTRIB(&ut_VarAttrib_dsid,&ut_VarAttrib_num))
            %End;
        %End;
        %Else %Do;
        0
        %End;
    %End;

    %Let ut_VarAttrib_rc   = %Sysfunc(CLOSE(&ut_VarAttrib_dsid.));
    %pv_End(ut_VarAttrib)
%mend;