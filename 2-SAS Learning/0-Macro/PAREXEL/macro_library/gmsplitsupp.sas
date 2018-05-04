/*
-------------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Fabian Noelle $LastChangedBy: kolosod $
  Creation Date:         2016-02-29    $LastChangedDate: 2016-08-29 05:01:01 -0400 (Mon, 29 Aug 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsplitsupp.sas $

  Files Created:         &dataMain..sas7bdat &dataSupp..sas7bdat

  Program Purpose:       This macro is designed to perform a standard task of splitting a dataset into 2 datasets which are SDTM compliant. 
                         As a result of this macro there are 2 datasets created: main dataset (standard SDTM dataset) and supplementary dataset (SUPP dataset). 

  Macro Parameters:
    Name:                dataIn
      Allowed Values:    LIBRARY.DATASET
      Default Value:     REQUIRED
      Description:       Name of the input dataset which will be split. Library is optional.

    Name:                varsSupp
      Allowed Values:    @ seperated list of <VARNAME> \IDVAR=<IDVAR> \QORIG=<QORIG> \QEVAL=<QEVAL> \FORMAT=<FORMAT> \KEEPFIRSTPART=<0|1>
      Default Value:     REQUIRED
      Description:       List of variables to be moved to the supplementary dataset, with additional options which specify id vairable, origin and evaluator.
                         * IDVAR option contains the variables which is used to links the supplementary dataset to the main dataset. If this option is omitted or set to missing, then values of the IDVAR and IDVARVAL will be missing in the resulting SUPP dataset. 
                         * QORIG option contains the origin value. Leading spaces are truncated. See SDTM IG for more details on the origin definition.
                         * QEVAL option contains the evaluator value. Leading spaces are truncated. See SDTM IG for more details on the evaluator definition.
                         * FORMAT is a numeric format to convert numeric variables into character variables. It is optional and when it is no specified BEST. format is used.
                         * KEEPFIRSTPART is a flag which instructs to keep the first 200 characters in the main dataset and create 
                           records in SUPP for the remaining characters. If the value is kept missing, it is defaulted to 0.

    Name:                dataMain
      Allowed Values:    LIBRARY.DATASET \LABEL=<LABEL>
      Default Value:     REQUIRED
      Description:       Name of the main dataset. Library is optional. Optionally a label for the new dataset can be provided using \LABEL notation. If the label is not specified, the dataIn dataset label will be kept.

    Name:                dataSupp
      Allowed Values:    LIBRARY.DATASET \LABEL=<LABEL>
      Default Value:     REQUIRED
      Description:       Name of the supplementary dataset. Library is optional. Optionally a label for the new dataset can be provided using \LABEL notation. If the label is not specified, it will be set to ''Supplemental Qualifiers for <Main Dataset Name>''.

    Name:                idVar 
      Allowed Values:    One variable name present in dataIn
      Default Value:     OPTIONAL
      Description:       If the value is provided, it will be used as a default ID variable when option \IDVAR is not specified in the varsSupp parameter.

    Name:                varsTrim 
      Allowed Values:    @ separated list of SUPP variables.
      Default Value:     REQUIRED
      Description:       List of SUPP variables for which length will be set to the length of a maximum value.
                         Currently the parameter is required. Once FDA clarifes their expectation a default value will be added.
                         There is a list of predefined values, which can be used instead of a list:
                         * _NONE_ - do not trim any variables.
                         * _ALL_  - trim all variables.
                         * _SUPP_ - trim all variables, except for those coming from the main dataset.

    Name:                splitCharParameter 
      Allowed Values:    A single character excluding "="
      Default Value:     OPTIONAL
      Description:       The character to split variables in the varsSupp and varsTrim parameter.

    Name:                splitCharOption
      Allowed Values:    A single character not equal to splitCharParameter and not "="
      Default Value:     OPTIONAL
      Description:       The character to split options in the varsSupp parameter.
 

  Macro Returnvalue:     N/A
                                
  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)
                         gmGetNObs (called)
                         gmParseParameters (called)
                         gmCheckValueExists (called)
                         gmTrimVarLen (called)
-------------------------------------------------------------------------------
  MODIFICATION HISTORY: Subversion $Rev: 2560 $
-------------------------------------------------------------------------------*/

%macro gmSplitSupp( 
   dataIn             = /*Input dataset*/
  ,varsSupp           = /*@ seperated list of supplementory variables*/
  ,dataMain           = /*Output main SDTM dataset*/
  ,dataSupp           = /*Output supplementory SDTM dataset*/
  ,idVar              = /*Default idVar*/
  ,splitCharParameter = @ /*Split character for varsSupp parameters*/
  ,splitCharOption    = \ /*Split character for varsSupp options*/
  ,varsTrim           = /*@ seperated list of variables which lengths will be trimmed*/
);

  %local gmSplitSupp_templib;

  %let gmSplitSupp_templib = %gmStart(
     headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsplitsupp.sas $
    ,revision=$Rev: 2560 $
    ,libRequired=1
  );
 
  %local 
    gmSplitSupp_macro
    gmSplitSupp_nobs
    gmSplitSupp_i
    gmSplitSupp_j
    gmSplitSupp_n 
    gmSplitSupp_dsid
    gmSplitSupp_rc
    gmSplitSupp_qnam
    gmSplitSupp_qnamShort
    gmSplitSupp_qnamBreaks
    gmSplitSupp_qnamType
    gmSplitSupp_qnamLabel
    gmSplitSupp_format
    gmSplitSupp_idvar
    gmSplitSupp_idvarType
    gmSplitSupp_var
    gmSplitSupp_unique
    gmSplitSupp_duptest
    gmSplitSupp_lentest
    gmSplitSupp_exists
    gmSplitSupp_qorig
    gmSplitSupp_qorigLength
    gmSplitSupp_qorigDropFlag
    gmSplitSupp_qeval
    gmSplitSupp_qevalLength
    gmSplitSupp_qevalDropFlag
    gmSplitSupp_main
    gmSplitSupp_mainLabel
    gmSplitSupp_supp
    gmSplitSupp_suppLabel
    gmSplitSupp_keepFirstPart
    gmSplitSupp_varOrder
  ;

  %let gmSplitSupp_macro = %sysfunc(lowcase(&sysmacroname.));  

  /*[CHECKS] If the argument dataIn exists. 
    If not ABORT the macro.
  */
  %gmCheckValueExists( 
     codeLocation = &gmSplitSupp_macro./Parameter checks (dataIn)
    ,selectMethod = EXISTS
    ,value        = &dataIn.
  );

  /*[CHECKS] Till FDA gives an instruction check if the argument varsTrim exists. 
    If not ABORT the macro.
  */
  %gmCheckValueExists( 
     codeLocation = &gmSplitSupp_macro./Parameter checks (varsTrim)
    ,selectMethod = EXISTS
    ,value        = &varsTrim.
  );

  /*[CHECKS] If the in dataset does not exist or has zero observations. 
    If it does not exist, ABORT the macro.
    On zero observations a note is issued.
  */
  %let gmSplitSupp_nobs = %gmGetNObs(dataIn=&dataIn.,selectType=N); 

  %if &gmSplitSupp_nobs. eq 0 %then %do;
    %gmMessage(
       codeLocation = &gmSplitSupp_macro./Parameter checks
      ,linesOut     = Dataset &dataIn. is empty.
      ,selectType   = N
    );      
  %end;
  %else %if &gmSplitSupp_nobs. eq -1 %then %do;
    %gmMessage(
       codeLocation = &gmSplitSupp_macro./Parameter checks
      ,linesOut     = Dataset &dataIn. does not exist.
      ,selectType   = ABORT
    );      
  %end;

  /*[CHECKS] If the argument dataMain exists. 
    If not ABORT the macro.
  */
  %gmCheckValueExists( 
     codeLocation = &gmSplitSupp_macro./Parameter checks (dataMain)
    ,selectMethod = EXISTS
    ,value        = &dataMain.
  );

  /*[CHECKS] If the argument dataSupp exists. 
    If not ABORT the macro.
  */
  %gmCheckValueExists( 
     codeLocation = &gmSplitSupp_macro./Parameter checks (dataSupp)
    ,selectMethod = EXISTS
    ,value        = &dataSupp.
  );

  /*Parse label information from dataMain and dataSupp.*/
  %gmParseParameters(  
     parameters        = &dataMain.
    ,optionsDefinition = LABEL
    ,dataOut           = &gmSplitSupp_templib..gmSplitSupp_mainLabel
  );

  %gmParseParameters(  
     parameters        = &dataSupp.
    ,optionsDefinition = LABEL
    ,dataOut           = &gmSplitSupp_templib..gmSplitSupp_suppLabel
  );

  proc sql noprint;
    select parameter, LABELvalue 
      into :gmSplitSupp_main, :gmSplitSupp_mainLabel 
      from &gmSplitSupp_templib..gmSplitSupp_mainLabel 
      where NUMBER eq 1
    ;
    select parameter, LABELvalue 
      into :gmSplitSupp_supp, :gmSplitSupp_suppLabel
      from &gmSplitSupp_templib..gmSplitSupp_suppLabel
      where NUMBER eq 1
    ;
  quit;

  %if %superq(gmSplitSupp_mainLabel) eq %then %do;
    %let gmSplitSupp_dsid = %sysfunc(open(&dataIn.,I));
    %let gmSplitSupp_mainLabel = %bquote(%sysfunc(attrc(&gmSplitSupp_dsid.,label))) ;
    %let gmSplitSupp_rc = %sysfunc(close(&gmSplitSupp_dsid.));
  %end; 
  %else %do;
    %let gmSplitSupp_mainLabel = &gmSplitSupp_mainLabel. ;
  %end;
  %if %superq(gmSplitSupp_suppLabel) eq %then %do;
    %let gmSplitSupp_suppLabel = Supplemental Qualifiers for %upcase(%scan(&gmSplitSupp_main.,-1,.)) ;
  %end; 
  %else %do;
    %let gmSplitSupp_suppLabel = &gmSplitSupp_suppLabel. ;
  %end;

  /*Parse parameter to get origin and evaluator variables.*/
  %gmParseParameters(  
     parameters        = &varsSupp.
    ,optionsDefinition = QORIG &splitCharParameter. QEVAL &splitCharParameter. IDVAR &splitCharParameter. FORMAT &splitCharParameter. KEEPFIRSTPART
    ,dataOut           = &gmSplitSupp_templib..gmSplitSupp_attrib1
    ,splitCharParameter= &splitCharParameter.
    ,splitCharOption   = &splitCharOption.
  );

  %let gmSplitSupp_n = %gmGetNObs(dataIn=&gmSplitSupp_templib..gmSplitSupp_attrib1); 

  data &gmSplitSupp_templib..gmSplitSupp_attrib2(keep=NUMBER QNAM QORIG QEVAL IDVAR FORMAT KEEPFIRSTPART);
    length QNAM IDVAR $8;
    set &gmSplitSupp_templib..gmSplitSupp_attrib1;
    QNAM  = strip(upcase(parameter));
    if QNAM ne strip(upcase(parameter)) then call symput('gmSplitSupp_lentest',parameter);
    QORIG = strip(QORIGvalue);
    QEVAL = strip(QEVALvalue);
    KEEPFIRSTPART = strip(KEEPFIRSTPARTvalue);
    if missing(KEEPFIRSTPART) then do;
      /* Default flag to 0, i.e. disabled */  
      KEEPFIRSTPART = "0";
    end;
    if missing(IDVAR) and (IDVARExists) eq 0 and not missing("&idVar.") then do;
      IDVAR = strip(upcase("&idVar."));
    end; 
    else do;
      IDVAR = strip(upcase(IDVARvalue));
    end;
    FORMAT= strip(upcase(FORMATvalue));
    call symput('gmSplitSupp_qorigLength',put(vlength(QORIGvalue),best.));
    call symput('gmSplitSupp_qevalLength',put(vlength(QEVALvalue),best.));
  run;

  %if &gmSplitSupp_lentest. ne %then %do;
    %gmMessage(
       codeLocation = &gmSplitSupp_macro./Parameter checks
      ,linesOut     = varsSupp contains &gmSplitSupp_lentest., which is longer then 8 characters.
      ,selectType   = ABORT
    );      
  %end;

  %let gmSplitSupp_qorigLength=&gmSplitSupp_qorigLength.;
  %let gmSplitSupp_qevalLength=&gmSplitSupp_qevalLength.;

  proc sort data=&gmSplitSupp_templib..gmSplitSupp_attrib2 nodupkey;
    by QNAM;
  run;

  %let gmSplitSupp_duptest = %gmGetNObs(dataIn=&gmSplitSupp_templib..gmSplitSupp_attrib2); 

  %if &gmSplitSupp_n. ne &gmSplitSupp_duptest. %then %do;
    %gmMessage(
       codeLocation = &gmSplitSupp_macro./Parameter checks
      ,linesOut     = Parameter varsSupp contains duplicated variable names. 
      ,selectType   = ABORT
    );      
  %end;

  proc sql noprint;
    select QNAM, QORIG, QEVAL
      into :gmSplitSupp_qnam separated by ' '
         , :gmSplitSupp_qorig separated by ' '
         , :gmSplitSupp_qeval separated by ' '
      from &gmSplitSupp_templib..gmSplitSupp_attrib2
    ;
  quit;

  /* Get the order of variables in the input dataset */
  proc contents data=&dataIn. out=&gmSplitSupp_templib..gmSplitSupp_mainInfo noprint;
  run;

  proc sql noprint;
    select NAME 
      into :gmSplitSupp_varOrder separated by ","
      from &gmSplitSupp_templib..gmSplitSupp_mainInfo
      where upcase(NAME) not in (select QNAM from &gmSplitSupp_templib..gmSplitSupp_attrib2 where KEEPFIRSTPART ne "1")
      order by varNum
    ;
  quit;

  /*Gives out the reduced main SDTM dataset, unless keepFirstPart option was specified which is handled later in the macro*/
  data &gmSplitSupp_templib..gmSplitSupp_mainUpdated(drop=&gmSplitSupp_qnam.);
    set &dataIn.;
    * Keep the original sorting, which will be used as an ID;
    GSS_ORIGSORT = _N_;
  run;
  
  %if &gmSplitSupp_nobs. ne 0 %then %do;
    /*Creates supplementary SDTM dataset and figure out which variables were originally numeric*/
    %if %cmpres(&gmSplitSupp_qorig.) eq %then %do;
      %let gmSplitSupp_qorigDropFlag=1;
    %end;
    %if %cmpres(&gmSplitSupp_qeval.) eq %then %do;
      %let gmSplitSupp_qevalDropFlag=1;
    %end;

    /* Keep original sorting */
    data &gmSplitSupp_templib..gmSplitSupp_sort;
      set &dataIn.;
      GSS_ORIGSORT = _N_;
    run;

    proc sort data=&gmSplitSupp_templib..gmSplitSupp_sort;
      by STUDYID DOMAIN USUBJID;
    run;
  
    %do gmSplitSupp_i = 1 %to &gmSplitSupp_n.;
      data _null_;
        set &gmSplitSupp_templib..gmSplitSupp_attrib2;
        where NUMBER eq &gmSplitSupp_i.;
        call symput('gmSplitSupp_qnam',QNAM);
        call symput('gmSplitSupp_qorig',QORIG);
        call symput('gmSplitSupp_qeval',QEVAL);
        call symput('gmSplitSupp_idvar',IDVAR);
        call symput('gmSplitSupp_format',FORMAT);
        call symput('gmSplitSupp_keepFirstPart',KEEPFIRSTPART);
      run; 

      %let gmSplitSupp_dsid = %sysfunc(open(&gmSplitSupp_templib..gmSplitSupp_sort,I));
      %let gmSplitSupp_exists = %sysfunc(varnum(&gmSplitSupp_dsid.,&gmSplitSupp_qnam.));
      %let gmSplitSupp_rc = %sysfunc(close(&gmSplitSupp_dsid.));
      %if &gmSplitSupp_exists. eq 0 %then %do;
        %gmMessage(
           codeLocation = &gmSplitSupp_macro./Parameter checks
          ,linesOut     = &gmSplitSupp_qnam. is not a variable of &dataIn..
          ,selectType   = ABORT
        );  
      %end;

      %if %superq(gmSplitSupp_keepFirstPart) ne 0 and %superq(gmSplitSupp_keepFirstPart) ne 1 %then %do;
        %gmMessage(
           codeLocation = &gmSplitSupp_macro./Parameter checks
          ,linesOut     = Incorrect KEEPFIRSTPART option value for &gmSplitSupp_qnam..
          ,selectType   = ABORT
        );  
      %end;

      data &gmSplitSupp_templib..gmSplitSupp_check1;
        set &gmSplitSupp_templib..gmSplitSupp_sort(keep=&gmSplitSupp_qnam. &gmSplitSupp_idvar.);
        call symput('gmSplitSupp_qnamType',vtype(&gmSplitSupp_qnam.));
        %if &gmSplitSupp_idvar. ne %then %do;
          call symput('gmSplitSupp_idvarType',vtype(&gmSplitSupp_idvar.));
        %end;
        if _N_ > 1 then stop;
      run;

      proc contents data=&gmSplitSupp_templib..gmSplitSupp_check1 out=&gmSplitSupp_templib..gmSplitSupp_check2 noprint;
      run;

      data _null_; 
        set &gmSplitSupp_templib..gmSplitSupp_check2;
        where upcase(NAME) eq upcase("&gmSplitSupp_qnam.");
        /* If there is no label, abort the execution as it is required */ 
        if missing(LABEL) then do;
          LABEL = resolve('%gmMessage(codeLocation = '||"&gmSplitSupp_macro./Parameter checks"
            ||",linesOut     = Label of &gmSplitSupp_qnam. is missing."
            ||",selectType   = ABORT);"
          );
        end;
        /* If label is longer than 40 characters, abort the execution as it maximum is 40 */
        else if length(LABEL) > 40 then do;
          LABEL = resolve('%gmMessage(codeLocation = '||"&gmSplitSupp_macro./Parameter checks"
            ||",linesOut     = Label for &gmSplitSupp_qnam. is longer than 40 characters."
            ||",selectType   = ABORT);"
          );
        end;
      run;

      data _null_;
        set &gmSplitSupp_templib..gmSplitSupp_sort(keep=&gmSplitSupp_qnam.);
        length QNAM_SHORT $8 QNAM_VLABEL $40 ;
        retain QNAM_BREAKS 0;
        %if &gmSplitSupp_qnamType. eq C %then %do;
          length GSS_MAX_STRING $32767;
          if length(&gmSplitSupp_qnam.) > 200 then do;
            GSS_MAX_STRING=&gmSplitSupp_qnam.;
            %gmModifySplit(var=GSS_MAX_STRING,width=200,delimiter=#~;`);
            if countw(GSS_MAX_STRING,'#~;`')-1 gt QNAM_BREAKS then QNAM_BREAKS=countw(GSS_MAX_STRING,'#~;`')-1;
          end;
        %end;
        QNAM_SHORT=strip("&gmSplitSupp_qnam.");
        QNAM_VLABEL=strip(vlabel(&gmSplitSupp_qnam.));
        if QNAM_BREAKS lt 10 then QNAM_SHORT=substr(QNAM_SHORT,1,7);
        else if QNAM_BREAKS lt 100 then QNAM_SHORT=substr(QNAM_SHORT,1,6);
        call symput('gmSplitSupp_qnamBreaks',put(QNAM_BREAKS,best.));
        call symput('gmSplitSupp_qnamShort',QNAM_SHORT);
        call symput('gmSplitSupp_qnamLabel',QNAM_VLABEL);
      run;
      %let gmSplitSupp_qnamBreaks=&gmSplitSupp_qnamBreaks.;
      %let gmSplitSupp_qnamShort=&gmSplitSupp_qnamShort.;
      %let gmSplitSupp_qnamLabel=&gmSplitSupp_qnamLabel.;

      %if &gmSplitSupp_qnamBreaks. ge 100 %then %do;
        %gmMessage(
           codeLocation = &gmSplitSupp_macro./Parameter checks
          ,linesOut     = gmSplitSupp is unable to split variables this long properly.
          ,selectType   = E
        );      
      %end;

      %if &gmSplitSupp_qnamType. eq N and &gmSplitSupp_format. eq %then %do;
        %let gmSplitSupp_format=best.;
        %gmMessage(
           codeLocation = &gmSplitSupp_macro./Parameter checks
          ,linesOut     = Numeric value will be converted using best format.
          ,selectType   = N
        );      
      %end;
      %else %if &gmSplitSupp_qnamType. eq C and &gmSplitSupp_format. ne %then %do;
        %gmMessage(
           codeLocation = &gmSplitSupp_macro./Parameter checks
          ,linesOut     = Character variables ignore specified formats.
          ,selectType   = N
        );    
      %end;

      /*Splits character variables so that the maximum length is 200.*/
      data &gmSplitSupp_templib..gmSplitSupp_max200;
        set &gmSplitSupp_templib..gmSplitSupp_sort(keep = STUDYID DOMAIN USUBJID GSS_ORIGSORT &gmSplitSupp_idvar. &gmSplitSupp_qnam.);
        %if &gmSplitSupp_qnamBreaks. eq 0 or &gmSplitSupp_qnamType. eq N %then %do;
          if _N_ eq 1 then call symput('gmSplitSupp_var',"&gmSplitSupp_qnam.");
        %end;
        %else %if &gmSplitSupp_qnamBreaks. lt 10 %then %do;
          if _N_ eq 1 then do; 
            %if &gmSplitSupp_keepFirstPart eq 1 %then %do;
              call symput('gmSplitSupp_var',"&gmSplitSupp_qnamShort.1--&gmSplitSupp_qnamShort.&gmSplitSupp_qnamBreaks.");
            %end;
            %else %do;
              call symput('gmSplitSupp_var',"&gmSplitSupp_qnam. &gmSplitSupp_qnamShort.1--&gmSplitSupp_qnamShort.&gmSplitSupp_qnamBreaks.");
            %end;
          end;
          length GSS_MAX_STRING $32767;
          GSS_MAX_STRING=&gmSplitSupp_qnam.;
          %gmModifySplit(var=GSS_MAX_STRING,width=200,delimiter=#~;`);
          array SPLIT_ARRAY $200 &gmSplitSupp_qnamShort.0-&gmSplitSupp_qnamShort.&gmSplitSupp_qnamBreaks.;
          do i = 1 to countw(GSS_MAX_STRING,'#~;`');
            * Extract current chunk;
            SPLIT_ARRAY[i] = prxchange("s/(.*?)(#~;`|$).*/$1/",1,trim(GSS_MAX_STRING));
            * Remove extracted chunk;
            GSS_MAX_STRING = prxchange("s/.*?(#~;`|$)//",1,trim(GSS_MAX_STRING));
          end; 
          %do gmSplitSupp_j = 0 %to &gmSplitSupp_qnamBreaks.;
            label &gmSplitSupp_qnamShort.%sysfunc(putn(&gmSplitSupp_j.,1.))
              = "&gmSplitSupp_qnamLabel.";
          %end;
          drop GSS_MAX_STRING &gmSplitSupp_qnam.;
          rename &gmSplitSupp_qnamShort.0 = &gmSplitSupp_qnam.;
        %end;
        %else %if &gmSplitSupp_qnamBreaks. lt 100 %then %do;
          if _N_ eq 1 then do; 
            %if &gmSplitSupp_keepFirstPart. eq 1 %then %do;
              call symput(
                 'gmSplitSupp_var'
                ,"&gmSplitSupp_qnamShort.01--&gmSplitSupp_qnamShort.%sysfunc(putn(&gmSplitSupp_qnamBreaks.,z2.)"
              );
            %end;
            %else %do;
              call symput(
                 'gmSplitSupp_var'
                ,"&gmSplitSupp_qnam. &gmSplitSupp_qnamShort.01--&gmSplitSupp_qnamShort.%sysfunc(putn(&gmSplitSupp_qnamBreaks.,z2.))"
              );
            %end;
          end;
          length GSS_MAX_STRING $32767;
          GSS_MAX_STRING=&gmSplitSupp_qnam.;
          %gmModifySplit(var=GSS_MAX_STRING,width=200,delimiter=#~;`);
          array SPLIT_ARRAY $200 &gmSplitSupp_qnamShort.00-&gmSplitSupp_qnamShort.&gmSplitSupp_qnamBreaks.;
          do i = 1 to countw(GSS_MAX_STRING,'#~;`');
            * Extract current chunk;
            SPLIT_ARRAY[i] = prxchange("s/(.*?)(#~;`|$).*/$1/",1,trim(GSS_MAX_STRING));
            * Remove extracted chunk;
            GSS_MAX_STRING = prxchange("s/.*?(#~;`|$)//",1,trim(GSS_MAX_STRING));
          end; 
          %do gmSplitSupp_j = 0 %to &gmSplitSupp_qnamBreaks.;
            label &gmSplitSupp_qnamShort.%sysfunc(putn(&gmSplitSupp_j.,z2.))
              = "&gmSplitSupp_qnamLabel.";
          %end;
          drop GSS_MAX_STRING &gmSplitSupp_qnam.;
          rename &gmSplitSupp_qnamShort.00 = &gmSplitSupp_qnam.;
        %end;
      run;

      /*Remove duplicate entries before transposing.*/
      proc sort data=&gmSplitSupp_templib..gmSplitSupp_max200 out=&gmSplitSupp_templib..gmSplitSupp_nodup nodupkey;
        by STUDYID DOMAIN USUBJID &gmSplitSupp_idvar. &gmSplitSupp_var.;
      run;

      /* Merge back the first part */
      %if &gmSplitSupp_keepFirstPart eq 1 %then %do;          
        proc sort data=&gmSplitSupp_templib..gmSplitSupp_max200;
          by GSS_ORIGSORT;
        run;
     
        data &gmSplitSupp_templib..gmSplitSupp_mainUpdated; 
          merge &gmSplitSupp_templib..gmSplitSupp_mainUpdated &gmSplitSupp_templib..gmSplitSupp_max200(keep = GSS_ORIGSORT &gmSplitSupp_qnam.);
          by GSS_ORIGSORT;
        run;
      %end;

      proc transpose data=&gmSplitSupp_templib..gmSplitSupp_nodup out=&gmSplitSupp_templib..gmSplitSupp_trans;
        by STUDYID DOMAIN USUBJID &gmSplitSupp_idvar. ;
        var &gmSplitSupp_var.;
      run;

      data &gmSplitSupp_templib..gmSplitSupp_map&gmSplitSupp_i.(drop=_NAME_ _LABEL_ COL1 DOMAIN &gmSplitSupp_idvar.);
        length IDVAR QNAM $8 QLABEL $40 IDVARVAL QVAL $200 QEVAL $&gmSplitSupp_qevalLength. QORIG $&gmSplitSupp_qorigLength.;
        set &gmSplitSupp_templib..gmSplitSupp_trans;
        if missing(COL1) then delete;
        else do;
          %if &gmSplitSupp_qnamType. eq C %then %do;
            QVAL = COL1;
          %end;
          %else %do;
            QVAL = strip(put(COL1,&gmSplitSupp_format.));
          %end;
        end;
        QNAM   =upcase(_NAME_);
        QLABEL =_LABEL_;
        RDOMAIN=DOMAIN;
        QORIG  ="&gmSplitSupp_qorig.";
        QEVAL  ="&gmSplitSupp_qeval.";
        %if &gmSplitSupp_idvar. ne %then %do;
          IDVAR = strip("&gmSplitSupp_idvar.");
          %if &gmSplitSupp_idvarType. eq C %then %do;
            IDVARVAL = &gmSplitSupp_idvar.;
          %end;
          %else %do;
            IDVARVAL = strip(put(&gmSplitSupp_idvar.,best.));
          %end;
        %end;
        %else %do;
          IDVAR = ' ';
          IDVARVAL = ' ';
        %end;
      run;

      /*Make sure that idvar is actually a unique identifier.*/
      %let gmSplitSupp_dsid = %sysfunc(open(&gmSplitSupp_templib..gmSplitSupp_map&gmSplitSupp_i.,I));
      %let gmSplitSupp_unique = %sysfunc(varnum(&gmSplitSupp_dsid.,COL2));
      %let gmSplitSupp_rc = %sysfunc(close(&gmSplitSupp_dsid.));
      %if &gmSplitSupp_unique. ne 0 %then %do;
        %gmMessage(
           codeLocation = &gmSplitSupp_macro./Parameter checks
          ,linesOut     = &gmSplitSupp_idvar. is not a unique identifier for &gmSplitSupp_qnam..
          ,selectType   = ABORT
        );  
      %end;

      %if &gmSplitSupp_i. eq 1 %then %do;
        data &gmSplitSupp_templib..gmSplitSupp_map;
          set &gmSplitSupp_templib..gmSplitSupp_map&gmSplitSupp_i.;
          label
            RDOMAIN = 'Related Domain Abbreviation'
            IDVAR   = 'Identifying Variable'
            IDVARVAL= 'Identifying Variable Value'
            QNAM    = 'Qualifier Variable Name'
            QLABEL  = 'Qualifier Variable Label'
            QVAL    = 'Data Value'
            QORIG   = 'Origin'
            QEVAL   = 'Evaluator'
          ;
        run;
      %end;
      %else %do;
        data &gmSplitSupp_templib..gmSplitSupp_map;
          set 
            &gmSplitSupp_templib..gmSplitSupp_map
            &gmSplitSupp_templib..gmSplitSupp_map&gmSplitSupp_i.
          ;
        run;
      %end;
    %end; 

    data &gmSplitSupp_templib..gmSplitSupp_retain; 
      retain STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL QVAL QORIG QEVAL;
      set &gmSplitSupp_templib..gmSplitSupp_map;
      %if &gmSplitSupp_qorigDropFlag. eq 1 %then %do; 
        drop QORIG;
      %end;
      %if &gmSplitSupp_qevalDropFlag. eq 1 %then %do;
        drop QEVAL;
      %end; 
    run;

    /*Gives out the supplementory SDTM dataset*/
    proc sort data=&gmSplitSupp_templib..gmSplitSupp_retain out=&gmSplitSupp_supp. (label="&gmSplitSupp_suppLabel.");
      by STUDYID RDOMAIN USUBJID IDVAR IDVARVAL QNAM QLABEL;
    run;
    /*Trim length of variables*/
    %let varsTrim = %qupcase(%superq(varsTrim));
    %if %superq(varsTrim) ne _NONE_ %then %do;
      %if %superq(varsTrim) eq _ALL_ %then %do;
        /* Trim all variables */  
        %gmTrimVarLen(dataIn=&gmSplitSupp_supp.);
      %end;
      %else %if %superq(varsTrim) eq _SUPP_ %then %do;
        /* Trim all SUPP variables, except for those copied from main */  
        %gmTrimVarLen(dataIn=&gmSplitSupp_supp.,excludeVars=STUDYID@USUBJID@RDOMAIN);
      %end;
      %else %do;
        /* Use the provided list */  
        %let varsTrim = %sysfunc(tranwrd(%superq(varsTrim),%superq(splitCharParameter),|));
        %gmTrimVarLen(dataIn=&gmSplitSupp_supp.,excludeVars=(?!(&varsTrim.)$).*);
      %end;          
    %end;
  %end;
  /* Add label to the main dataset and properly order variables*/
  proc sql;
    create table &gmSplitSupp_main. 
      %if %superq(gmSplitSupp_mainLabel) ne %then %do;
        (label="&gmSplitSupp_mainLabel.")
      %end;
      as
        select &gmSplitSupp_varOrder.
        from &gmSplitSupp_templib..gmSplitSupp_mainUpdated
    ;
  quit;
  /*End*/
  %gmEnd(
    headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsplitsupp.sas $
  );
%mend gmSplitSupp;
