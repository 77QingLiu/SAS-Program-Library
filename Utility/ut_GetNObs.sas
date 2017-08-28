/*-----------------------------------------------------------------------------
Program Purpose:       The macro %ut_GetNObs returns the number of observations in a dataset or view.

                        The macro by default ABORTs if the dataset is not present. 

                        It is possible to apply a where clause to the dataset. A sysntax error in the where clause leads to an ABORT.

    Macro Parameters:

        Name:                dataIn
            Allowed Values:    Any valid dataset (or view) name
            Default Value:     REQUIRED
            Description:       The name of a dataset (or view) that should be used for reporting its number of logical observations.


        Name:                where
            Allowed Values:    Any String
            Default Value:     1
            Description:       A where condition to be applied to the dataIn parameter before counting lines.

-----------------------------------------------------------------------------*/
%MACRO ut_GetNObs( dataIn =
                , where  = 1
                );
    %local ut_GetNObs_macroname;
    %let ut_GetNObs_macroname = &SYSMACRONAME;
    %Trim(%Left(
                %pv_Start(ut_GetNObs)
                %Local ut_GetNObs_dsid
                       ut_GetNObs_num
                       ut_GetNObs_rc
                       ut_GetNObs_syscc
                ;

                /* Check if dataset exist, abort if not */
                %If ~( %Sysfunc(EXIST(&dataIn.)) OR %Sysfunc(EXIST(&dataIn.,VIEW))) %Then %Do;
                    %pv_Message( MessageLocation = MACRO:  &ut_GetNObs_macroname - to check input dataset
                                , MessageDisplay = @Dataset or View &dataIn. does not exists. Number of observations can not be determined.
                                , MessageType   = ERROR
                                )
                    -1 /* Return -1 if NOBS not available */
                %End;
                %Else %Do;
                    %Let ut_GetNObs_syscc = &syscc.;
                    %Let syscc=0;

                    /*
                    * Get the number of observations in a table, where the number of obs is a stored metadata.
                    * Returns -1 if NOBS is not available.
                    */
                    %Let ut_GetNObs_dsid = %Sysfunc(OPEN(&dataIn.(WHERE=(&where.)),I));
                    %Let ut_GetNObs_num  = %Sysfunc(ATTRN(&ut_GetNObs_dsid.,NLOBSF));
                    %Let ut_GetNObs_rc   = %Sysfunc(CLOSE(&ut_GetNObs_dsid.));

                    %If &SYSCC.>0 %Then %Do;
                        %pv_Message( MessageLocation=MACRO:  &ut_GetNObs_macroname - to do post execution check
                              , MessageDisplay= @After retrieving obs. An Error was detected. Probably the where clause is wrong.
                              , MessageType=ABORT
                              )
                    %End;

                    %Let syscc=&ut_GetNObs_syscc.;

                    %pv_Message( MessageLocation = MACRO:  &ut_GetNObs_macroname - Confirmation Message
                            , MessageDisplay     = @The dataset or view &dataIn.(WHERE=(&where.)) has &ut_GetNObs_num. observations.
                            , MessageType   = NOTE
                            , debugOnly    = N
                            )
                    &ut_GetNObs_num.
                %End;
                %pv_End(ut_GetNObs)
    ))
%MEND ut_GetNObs;
