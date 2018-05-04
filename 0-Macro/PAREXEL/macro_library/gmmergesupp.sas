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

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmergesupp.sas $

  Files Created:         work.&dataOut..sas7bdat

  Program Purpose:       This macro is designed to perform a standard task of merging SDTM dataset with it's supplemental part. 
                         As a result of this macro there is a dataset created containing all variables from the original dataset and transposed variables from the SUPP dataset. 

  Macro Parameters:

    Name:                dataMain
      Allowed Values:    LIBRARY.DATASET
      Default Value:     REQUIRED
      Description:       Name of the main dataset. Library is optional.

    Name:                dataSupp
      Allowed Values:    LIBRARY.DATASET
      Default Value:     <Main Dataset Library>.SUPP<Main Dataset Name>
      Description:       Name of the supplementary dataset. Library is optional.

    Name:                dataOut
      Allowed Values:    LIBRARY.DATASET
      Default Value:     REQUIRED
      Description:       Name of the resulting dataset. Library is optional.

    Name:                varsNum
      Allowed Values:    @ seperated list of <QNAM> values
      Default Value:     OPTIONAL
      Description:       List of SUPP variables which will be converted to numeric when the supplementary dataset is merged. All of the values are input using the BEST. informat.

    Name:                selectType
      Allowed Values:    All values allowed by the selectType parameter from gmMessage.
      Default Value:     ERROR
      Description:       Behaviour of the macro when the supplementary dataset to be used is not present.

  Macro Returnvalue:     N/A
                                
  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                         gmMessage (called)
                         gmGetNObs (called)
                         gmCheckValueExists (called)
                         gmTrimVarLen (called)
-------------------------------------------------------------------------------
  MODIFICATION HISTORY: Subversion $Rev: 2560 $
-------------------------------------------------------------------------------*/

%macro gmMergeSupp( 
   dataMain   = /*Input main SDTM dataset*/
  ,dataSupp   = /*Input supplementary SDTM dataset*/
  ,dataOut    = /*Output dataset*/
  ,varsNum    = /*List of variables which should be numeric*/
  ,selectType = ERROR /*Behaviour when supplementary dataset is missing*/
);

  %local gmMergeSupp_templib;

  %let gmMergeSupp_templib = %gmStart(
     headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmergesupp.sas $
    ,revision=$Rev: 2560 $
    ,libRequired=1
  );

  %local 
    gmMergeSupp_macro
    gmMergeSupp_mainnobs
    gmMergeSupp_suppnobs
    gmMergeSupp_rdomain
    gmMergeSupp_sdtmlib
    gmMergeSupp_data
    gmMergeSupp_i
    gmMergeSupp_n
    gmMergeSupp_numVarList
    gmMergeSupp_idvar
    gmMergeSupp_idvarType
    gmMergeSupp_idvars
    gmMergeSupp_varsChar
    gmMergeSupp_dsid 
    gmMergeSupp_label
    gmMergeSupp_rc
    gmMergeSupp_domain
  ;

  %let gmMergeSupp_macro = %sysfunc(lowcase(&sysmacroname.));  

  /*[CHECKS] If the argument dataOut exists. 
    If not ABORT the macro.
  */
  %gmCheckValueExists( 
     codeLocation = &gmMergeSupp_macro./Parameter checks (dataOut)
    ,selectMethod = EXISTS
    ,value        = &dataOut.
  );

  /*[CHECKS] If the arugument dataMain exists. 
    If not ABORT the macro.
  */
  %gmCheckValueExists( 
     codeLocation = &gmMergeSupp_macro./Parameter checks (dataMain)
    ,selectMethod = EXISTS
    ,value        = &dataMain.
  );

  /*Seperates Library from main Dataset, if given.*/
  data _NULL_;
    length LIB DSET $200;
    if find("&dataMain.",'.') then 
      LIB = upcase(scan("&dataMain.",1,'.'));
    else LIB = 'WORK';
    DSET = upcase(scan("&dataMain.",-1,'.'));
    call symput('gmMergeSupp_data',DSET);
    call symput('gmMergeSupp_sdtmlib',LIB);
  run;
  %let gmMergeSupp_data = &gmMergeSupp_data.;
  %let gmMergeSupp_sdtmlib = &gmMergeSupp_sdtmlib.;

  %if &dataSupp. eq %then %do;
    %let dataSupp = &gmMergeSupp_sdtmlib..SUPP&gmMergeSupp_data.;
    %gmMessage(
       codeLocation = &gmMergeSupp_macro./Parameter checks
      ,linesOut     = dataSupp defaulted to &dataSupp..
      ,selectType   = N
    );   
  %end;

  /*[CHECKS] If the main dataset exists or has zero observations. 
    If it doesn't exist, ABORT the macro. 
    On zero observations a note is issued. 
  */
  %let gmMergeSupp_mainnobs = %gmGetNObs(dataIn=&dataMain.,selectType=N); 

  %if &gmMergeSupp_mainnobs. eq 0 %then %do;
    %gmMessage(
       codeLocation = &gmMergeSupp_macro./Parameter checks
      ,linesOut     = Dataset &dataMain. is empty.
      ,selectType   = N
    );      
  %end;
  %else %if &gmMergeSupp_mainnobs. eq -1 %then %do;
    %gmMessage(
       codeLocation = &gmMergeSupp_macro./Parameter checks
      ,linesOut     = Dataset &dataMain. does not exist.
      ,selectType   = ABORT
    );     
  %end;
  %else %do;
    proc sql noprint;
      select distinct DOMAIN into: gmMergeSupp_domain from &dataMain.;
    quit;
  %end;

  %let gmMergeSupp_dsid = %sysfunc(open(&dataMain.,I));
  %let gmMergeSupp_label = %bquote(%sysfunc(attrc(&gmMergeSupp_dsid.,label))) ;
  %let gmMergeSupp_rc = %sysfunc(close(&gmMergeSupp_dsid.));

  /*[CHECKS] If the supplementory exists or has zero observations. 
    If it doesn't exist, selectType determines the behaviour of the macro (ERROR by defualt). 
    On zero observations a note is issued.
  */
  %let gmMergeSupp_suppnobs = %gmGetNObs(dataIn=&dataSupp.,selectType=N); 

  %if &gmMergeSupp_suppnobs. eq 0 %then %do;
    %gmMessage(
       codeLocation = &gmMergeSupp_macro./Parameter checks
      ,linesOut     = Dataset &dataSupp. is empty.
      ,selectType   = N
    );      
  %end;
  %else %if &gmMergeSupp_suppnobs. eq -1 %then %do;
    %gmMessage(
       codeLocation = &gmMergeSupp_macro./Parameter checks
      ,linesOut     = Dataset &dataSupp. does not exist.
      ,selectType   = &selectType.
    );      
  %end;
  %else %if &gmMergeSupp_suppnobs. ne -1 %then %do;
    /*Call supplementary dataset and gain information about number of IDVARs.*/
    %let gmMergeSupp_numVarList=%str(%')%qsysfunc(tranwrd(%qsysfunc(compress(%upcase(&varsNum.),%str( ))),@,%str(%' %')))%str(%');
    data &gmMergeSupp_templib..SUPP;
      set &dataSupp.;
      where RDOMAIN eq "&gmMergeSupp_domain.";
      QNAM=upcase(QNAM); 
      QVALN=.;
      %if %superq(varsNum) ne %then %do;
        if QNAM in (%unquote(&gmMergeSupp_numVarList.)) then QVALN=input(QVAL,best.);
      %end; 
    run;

    %let gmMergeSupp_rdomain = %gmGetNObs(dataIn=&gmMergeSupp_templib..SUPP); 

    %if &gmMergeSupp_suppnobs. ne &gmMergeSupp_rdomain. %then %do;
      %if &gmMergeSupp_rdomain. eq 0 %then %do;
        %gmMessage(
           codeLocation = &gmMergeSupp_macro.
          ,linesOut     = Dataset &dataSupp. is empty after data from non-related domains was deleted.
          ,selectType   = N
        );      
      %end;
      %else %do;
        %gmMessage(
           codeLocation = &gmMergeSupp_macro.
          ,linesOut     = Data from non-related domains was deleted from dataset &dataSupp..
          ,selectType   = N
        ); 
      %end; 
      %let gmMergeSupp_suppnobs = &gmMergeSupp_rdomain.; 
    %end;

    %if &gmMergeSupp_rdomain. ne 0 and &gmMergeSupp_mainnobs. eq 0 %then %do;
      %gmMessage(
         codeLocation = &gmMergeSupp_macro./Parameter checks
        ,linesOut     = Dataset &dataMain. is empty%str(,) but &dataSupp. contains related entries.
        ,selectType   = E
      );      
    %end;
  %end;

  /*If dataMain is not empty and dataSupp is not empty and exists, loop through all possible IDVARs (usually only one).*/
  %if &gmMergeSupp_mainnobs. ne 0 and &gmMergeSupp_suppnobs. gt 0 %then %do;
    data &gmMergeSupp_templib..MAIN0;
      set &dataMain.;
      _ORIGSORT=_N_;
    run;

    proc sort data=&gmMergeSupp_templib..SUPP out=&gmMergeSupp_templib..IDVARS(keep=IDVAR) nodupkey;
      by IDVAR;
    run;

    proc sql noprint;
      select IDVAR 
        into: gmMergeSupp_idvars separated by '@' 
        from &gmMergeSupp_templib..IDVARS
      ;
    quit;
    %let gmMergeSupp_n = %eval(1 + %sysfunc(count(&gmMergeSupp_idvars.,@))) ;

    proc sort data=&gmMergeSupp_templib..SUPP ;
      by USUBJID IDVARVAL;
    run;

    %do gmMergeSupp_i = 1 %to &gmMergeSupp_n.;
      %let gmMergeSupp_idvar = %scan(&gmMergeSupp_idvars.,&gmMergeSupp_i.,@);

      proc transpose data=&gmMergeSupp_templib..SUPP out=&gmMergeSupp_templib..SUPPC&gmMergeSupp_i.(drop=_NAME_ _LABEL_);
        by USUBJID IDVARVAL;
        where IDVAR eq "&gmMergeSupp_idvar." and missing(QVALN);
        id QNAM;
        idl QLABEL;
        var QVAL;
      run;

      proc transpose data=&gmMergeSupp_templib..SUPP out=&gmMergeSupp_templib..SUPPN&gmMergeSupp_i.(drop=_NAME_);
        by USUBJID IDVARVAL;
        where IDVAR eq "&gmMergeSupp_idvar." and not missing(QVALN);
        id QNAM;
        idl QLABEL;
        var QVALN;
      run;

      data _null_;
        set &gmMergeSupp_templib..MAIN%eval(&gmMergeSupp_i.-1);
        %if &gmMergeSupp_idvar. ne %then %do;
          call symput('gmMergeSupp_idvarType',vtype(&gmMergeSupp_idvar.));
        %end;
        if _N_ > 1 then stop;
      run;

      data &gmMergeSupp_templib..TEMP&gmMergeSupp_i.;
        length IDVARVAL $200;
        set &gmMergeSupp_templib..MAIN%eval(&gmMergeSupp_i.-1);
        %if &gmMergeSupp_idvar. ne %then %do;
          %if &gmMergeSupp_idvarType. eq C %then %do;
            IDVARVAL = &gmMergeSupp_idvar.;
          %end;
          %else %do;
            IDVARVAL = strip(put(&gmMergeSupp_idvar.,best.));
          %end;
        %end;
        %else %do;
          IDVARVAL = ' ';
        %end;
      run;

      proc sort data=&gmMergeSupp_templib..TEMP&gmMergeSupp_i.;
        by USUBJID IDVARVAL;
      run;

      data &gmMergeSupp_templib..MAIN&gmMergeSupp_i.(drop=IDVARVAL);
        merge 
          &gmMergeSupp_templib..TEMP&gmMergeSupp_i.(in=A) 
          &gmMergeSupp_templib..SUPPC&gmMergeSupp_i. 
          &gmMergeSupp_templib..SUPPN&gmMergeSupp_i.
        ;
        by USUBJID IDVARVAL ;
        if A;
      run;
    %end;

    /* Trim the character SUPP variables*/
    proc sort 
        data=&gmMergeSupp_templib..SUPP(where =(missing(QVALN)))
        out=&gmMergeSupp_templib..IDVARSCHAR(keep=QNAM) nodupkey
      ;
      by QNAM;
    run;

    proc sql noprint;
      select QNAM 
        into: gmMergeSupp_varsChar separated by '|' 
        from &gmMergeSupp_templib..IDVARSCHAR
      ;
    quit;
    %let gmMergeSupp_varsChar = &gmMergeSupp_varsChar;

    %gmTrimVarLen(dataIn=&gmMergeSupp_templib..MAIN&gmMergeSupp_n.,excludeVars = (?!(&gmMergeSupp_varsChar.)$).*);

    /*Return final dataset*/
    proc sort 
        data=&gmMergeSupp_templib..MAIN&gmMergeSupp_n.
        out=&dataOut.(drop=_ORIGSORT 
        %if %superq(gmMergeSupp_label) ne %then %do;
          label="&gmMergeSupp_label."
        %end;
      );
      by _ORIGSORT;
    run;
  %end;
  %else %do;
    /*If dataMain is empty or dataSupp is empty or does not exists, the final dataset is the main dataset.*/
    data &dataOut. 
        %if %superq(gmMergeSupp_label) ne %then %do;
          (label="&gmMergeSupp_label.")
        %end;
      ;
      set &dataMain.;
    run;
  %end;

  %gmEnd(
    headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmmergesupp.sas $
  );
%mend gmMergeSupp;
