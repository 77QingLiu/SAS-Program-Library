*--------------------------------------------------------------------------------------------------
Program Purpose:       The macro %ut_DataAttrib Generate attrib statements from a template dataset

    Macro Parameters:

        Name:                DATA
            Allowed Values:    Any valid SAS dataset
            Default Value:     REQUIRED
            Description:       The name of SAS dataset

        Name:                KEEP
            Allowed Values:    Any valid SAS variable name in SAS dataset
            Default Value:     
            Description:       The name of SAS variable to be keeped

        Name:                DROP
            Allowed Values:    Any valid SAS variable name in SAS dataset
            Default Value:     
            Description:       The name of SAS variable to be dropped

        Name:                DISPLAY
            Allowed Values:    0|1
            Default Value:     1
            Description:       display generated attrib code        
--------------------------------------------------------------------------------------------------;

%macro ut_DataAttrib(DATA=
                     ,KEEP=
                     ,DROP=
                     ,DISPLAY=0);

    %pv_Start(ut_DataAttrib)
    %local  ut_macroname;
    %let    ut_macroname  = &SYSMACRONAME;

    %local macro parmerr;
    %local attrib name type length format informat label varlist;

    %* Parameter validation %*;
    %pv_Define( &ut_macroname ,DATA ,_pmRequired = 1 ,_pmAllowed = DATASET)
    %pv_Define( &ut_macroname ,KEEP ,_pmRequired = 0 ,_pmAllowed = SASNAME)
    %pv_Define( &ut_macroname ,DROP ,_pmRequired = 0 ,_pmAllowed = SASNAME)
    %pv_Define( &ut_macroname ,DISPLAY ,_pmRequired = 1 ,_pmAllowed = 1 0)

    %* Check if dataset exist, abort if not %*;
    %Let SYSCC=0;    
    %If ~( %Sysfunc(EXIST(&DATA.)) OR %Sysfunc(EXIST(&DATA.,VIEW))) %Then %Do;
        %pv_Message( MessageLocation = MACRO:  &ut_macroname - to check input dataset
                    , MessageDisplay = @Dataset or View &DATA. does not exists. Number of observations can not be determined.
                    , MessageType   = ERROR
                    )
    %end;

    %* initialize varlist ;
    %let varlist=;

    %Let ut_VarAttrib_dsid = %Sysfunc(OPEN(&DATA.,I));
    %Let ut_VarAttrib_numvars  = %Sysfunc(attrn(&ut_VarAttrib_dsid.,nvars));

    %do i=1 %to &ut_VarAttrib_numvars;
        %let name      =%sysfunc(varname(&ut_VarAttrib_dsid,&i));
        %let type      =%sysfunc(vartype(&ut_VarAttrib_dsid,&i));
        %let length    =%sysfunc(varlen(&ut_VarAttrib_dsid,&i));
        %let format    =%sysfunc(varfmt(&ut_VarAttrib_dsid,&i));
        %let informat  =%sysfunc(varinfmt(&ut_VarAttrib_dsid,&i));
        %let label     =%sysfunc(varlabel(&ut_VarAttrib_dsid,&i));

        %* use a marker token (~) to preserve spacing by the macro tokenizer ;
        %let name=~%sysfunc(putc(&name,$32.))~;

        %let length=length=$%sysfunc(putn(&length,6.-R));
        %if (&type eq N) %then
        %let length=%sysfunc(translate(&length,%str( ),%str($)));
        %let length=~&length~;

        %if (&format ne ) %then
        %let format=~format=%sysfunc(putc(&format,$35.))~;
        %else
        %let format=~       %sysfunc(repeat(%str( ),34))~;

        %if (&informat ne ) %then
        %let informat=~informat=%sysfunc(putc(&informat,$35.))~;
        %else
        %let informat=~         %sysfunc(repeat(%str( ),34))~;

        %if (%superq(label) ne ) %then
        %let label=label="&label";

        %* use a diffent marker token for the label, ;
        %* since a valid label can contain ~ ;
        %let attrib=attrib;
        %let attrib=&attrib&name&length&format&informat#####;
        %let attrib=%sysfunc(translate(&attrib,%str( ),%str(~)));
        %let attrib=%sysfunc(strip(&attrib))&label;
        %let attrib=%sysfunc(transtrn(&attrib,%str(#####),));

        %* remove ~ from name for varlist processing ;
        %let name=%sysfunc(translate(&name,%str( ),%str(~)));
        %let name=%left(&name);
        
        %if (&keep ne ) %then %do;
            %if (%index(&keep,%upcase(&name))) %then %do;
                %if (&DISPLAY) %then %do;
                    %put %str(&attrib;);
                %end;
                %else %do;
                    &attrib;
                    %let varlist=&varlist &name;
                %end;
            %end;
        %end;
        %else
        %if (&drop ne ) %then %do;
            %if ^(%index(&drop,%upcase(&name))) %then %do;
                %if (&DISPLAY) %then %do;
                    %put %str(&attrib;);
                %end;
                %else %do;
                    &attrib;
                    %let varlist=&varlist &name;
                %end;
            %end;
        %end;
        %else %do;
            %if (&DISPLAY) %then %do;
                %put %str(&attrib;);
            %end;
            %else %do;
                &attrib;
                %let varlist=&varlist &name;
            %end;
        %end;
    %end;
    %if ^(&DISPLAY) %then %do;
    call missing(of &varlist);  %* prevents uninitialized variable messages ;
    %end;

    %let ut_VarAttrib_dsid=%sysfunc(close(&ut_VarAttrib_dsid));

    %pv_End(ut_DataAttrib)

%mend;
