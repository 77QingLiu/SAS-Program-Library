/*-----------------------------------------------------------------------------
Program Purpose:       The macro %ut_Nobs returns the number of observations in a dataset or view.

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
%MACRO ut_Nobs( dataIn =
                , where  = 1
                , debugOnly = 
                );
    %local _macroname;
    %let _macroname = &SYSMACRONAME;
    %Trim(%Left(
                %pv_Start(ut_Nobs)
                %Local _dsid
                       _num
                       _rc
                       _syscc
                ;
                /* Check if dataset exist, abort if not */
                %If ~( %Sysfunc(EXIST(&dataIn.)) OR %Sysfunc(EXIST(&dataIn.,VIEW))) %Then %Do;               
                    %pv_Message( MessageLocation = MACRO:  &_macroname - to check input dataset
                                , MessageDisplay = @Dataset or View &dataIn. does not exists. Number of observations can not be determined.
                                , MessageType   = ERROR
                                )
                    -1 /* Return -1 if NOBS not available */
                %End;
                %Else %Do;
                    %Let _syscc = &syscc.;
                    %Let syscc=0;
                    /*
                    * Get the number of observations in a table, where the number of obs is a stored metadata.
                    * Returns -1 if NOBS is not available.
                    */
                    %Let _dsid = %Sysfunc(OPEN(&dataIn.(WHERE=(&where.)),I));
                    %Let _num  = %Sysfunc(ATTRN(&_dsid.,NLOBSF));
                    %Let _rc   = %Sysfunc(CLOSE(&_dsid.));

                    %If &SYSCC.>0 %Then %Do;
                        %pv_Message( MessageLocation=MACRO:  &_macroname - to do post execution check
                              , MessageDisplay= @After retrieving obs. An Error was detected. Probably the where clause is wrong.
                              , MessageType=ABORT
                              )
                    %End;

                    %Let syscc=&_syscc.;
                    %pv_Message( MessageLocation = MACRO:  &_macroname - Confirmation Message
                            , MessageDisplay     = @The dataset or view &dataIn.(WHERE=(&where.)) has &_num. observations.
                            , MessageType   = NOTE
                            , debugOnly    = N
                            )
                    &_num.
                %End;
                %pv_End(ut_Nobs)
    ))
%MEND ut_Nobs;
