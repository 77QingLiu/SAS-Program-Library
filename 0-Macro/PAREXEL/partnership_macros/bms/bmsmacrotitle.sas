/*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: BMS / BMS Partnership
  PXL Study Code:        112253

  SAS Version:           9.1.3 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Andrey Maleev $LastChangedBy: kolosod $
  Creation Date:         02JUL2012     $LastChangedDate: 2016-08-29 05:00:26 -0400 (Mon, 29 Aug 2016) $

  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsmacrotitle.sas $

  Files Created:

  Program Purpose:       BMSMacroTitle macro produces cover page and titles for BMS Partnership studies.
                         This macro is PAREXEL's intellectual property and shall not be used outside of
                         contractual obligations without written consent from PAREXEL's senior management.
                         This macro has been validated for use only in PAREXELs working environment.

  Macro Parameters:

    Name:                _tableno
      Allowed Values:    
      Default Value:     BLANK
      Description:       Table number. Text string - output number from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _t1
      Allowed Values:    
      Default Value:     BLANK
      Description:       Title 1. Text string in quotes - Title 1 from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _t2
      Allowed Values:    
      Default Value:     BLANK
      Description:       Title 2. Text string in quotes - Title 2 from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _t3
      Allowed Values:    
      Default Value:     BLANK
      Description:       Title 3. Text string in quotes - Title 3 from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _t4
      Allowed Values:    
      Default Value:     BLANK
      Description:       Title 4. Text string in quotes - Title 4 from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _t5
      Allowed Values:    
      Default Value:     BLANK
      Description:       Title 5. Text string in quotes - Title 5 from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _t6
      Allowed Values:    
      Default Value:     BLANK
      Description:       Title 6. Text string in quotes - Title 6 from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _t7
      Allowed Values:    
      Default Value:     BLANK
      Description:       Title 7. Text string in quotes - Title 7 from the DPP.
                             [will be ignored once DPP Analysis Tool dataset is used: <macrotitle_dpptool> is not missing]

    Name:                _outpath
      Allowed Values:    
      Default Value:     BLANK
      Description:       Path to output file. Valid Unix path specifying the location of <_outname> file.
                             [once explicitly specified - will be in priority]

    Name:                _outname
      Allowed Values:    
      Default Value:     REQUIRED
      Description:       Output file name. Text string - output name from the DPP.

    Name:                _rtype
      Allowed Values:    T,L,F
      Default Value:     BLANK
      Description:       Report type:  T for tables, L for listings, F for figures. Text string specifying the output type.
                            [once explicitly specified - will be in priority]

    Name:                _orientation
      Allowed Values:    L,P
      Default Value:     L
      Description:       Report orientation:  L for landscape, P for portrait. Text string specifying the orientation of the output layout.
                            [once explicitly specified - will be in priority]

  Macro Returnvalue:     No return value.

  Global Macrovariables:

    Name:                macrotitle_protocol
      Usage:             READ
      Description:       Protocol number.

    Name:                macrotitle_projectid
      Usage:             READ
      Description:       Project ID on cover page. If it is not specified the first 5 symbols of <marcotitle_protocol> will be used.

    Name:                macrotitle_status
      Usage:             READ
      Description:       Deliverable status. The possible values are DRAFT or FINAL. Status is displayed on cover page.
                         If status is set to DRAFT then "Draft" word will be added in the first line in the pages starting from page 1.

    Name:                macrotitle_status2
      Usage:             READ
      Description:       Status value on pages starting with page 1. The cover page will still contain FINAL or DRAFT depending on <macrotitle_status> value.

    Name:                macrotitle_libs
      Usage:             READ
      Description:       List of libraries to report on cover page. Library names separated by spaces.

    Name:                macrotitle_mode
      Usage:             READ
      Description:       Type of the deliverable to be produced. The possible values are DMC or Final.

    Name:                macrotitle_reqver
      Usage:             READ
      Description:       Version of GBS General Requirements for Statistical Outputs used in the study.

    Name:                macrotitle_dictae
      Usage:             READ
      Description:       Dictionary name for AE outputs. Will be used for all the outputs in AE domain.

    Name:                macrotitle_dictcm
      Usage:             READ
      Description:       Dictionary name for CM outputs. Will be used for all the outputs in CM domain.

    Name:                macrotitle_aedomain
      Usage:             READ
      Description:       List of AE domains in the study. All the AE tables will have dictionary name displayed on cover page.

    Name:                macrotitle_cmdomain
      Usage:             READ
      Description:       List of CM domains in the study. All the CM tables will have dictionary name displayed on cover page.

    Name:                macrotitle_dpptool
      Usage:             READ
      Description:       Full name of the dataset (e.g. "/projects/<studyname>/<dpptool>.sas7bdat") which contains information from DPP Analysis Tool.
                         This dataset is used to automatically define titles, footnotes and retrieve attributes for displaying on cover page.

    Name:                stdfoot
      Usage:             WRITE
      Description:       Standard footnote for tables, listings and appendices with program path/name and run date-time. Usage: Footnotes.

    Name:                stdline
      Usage:             WRITE
      Description:       Dashed line to be used in tables, listings and appendices. Usage: Titles/Footnotes.

    Name:                pname
      Usage:             WRITE
      Description:       Program name to be used in graphs. Usage: Footnotes.

    Name:                ppath
      Usage:             WRITE
      Description:       Program path to be used in graphs. Usage: Footnotes.

    Name:                rundttm
      Usage:             WRITE
      Description:       Date-time to be used in graphs. Usage: Footnotes.

  Macro Dependencies:    gmMessage (called)

-------------------------------------------------------------------------------
MODIFICATION HISTORY: Subversion $Rev: 2559 $
-----------------------------------------------------------------------------*/


%MACRO BMSMacroTitle(_tableno=, _outpath=, _outname=, _rtype=, _orientation=l,
                     _t1=, _t2=, _t3=, _t4=, _t5=, _t6=, _t7=);

/* Print version and location information */
  %PUT NOTE:[PXL] %SYSFUNC(TRANWRD(%QSCAN($HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/bms/bmsmacrotitle.sas $, -1,:$),
                 7070/svnrepo, %STR())) %STR(,) r%QSCAN($Rev: 2559 $,2);
  %IF %SYMEXIST(gmpxlerr) %THEN %DO;
    %IF &gmpxlerr.=1 %THEN %DO;
      %PUT NOTE:[PXL] Macro terminated because GMPXLERR is set to 1;
      %RETURN;
    %END;
  %END;
  %GLOBAL gmpxlerr;
  %LET    gmpxlerr=0;

/* Declare local macrovariables */
%local pref _maxlen stopexec emptytit _titleq i j l dopvar _char1 macrotitle_libs_q _domain _maxpos titleone titleone1
       _ll_ _pl_ orientation _logloc_ _lstloc_ libnamelist removelist libdata _projectid _studyid _reportstatus pnamefull
       _title2 _title3 _title4 _title5 _title6 _title7 _title8 _t0 _maxtitle_l _maxtitle_p _confs _analysis
       _dpptool _dpptool_nobs _f1 _f2 _f3 _f4 _f5 _f6 _f7 _f8 _footq _fileref _rc _did _ext _maxt _maxf emptyfoot _dpptool_exist _wc000001;

/* Assign values of macro variables */
%let pref = macrotitle_;
%let _maxlen = 1024;
%let stopexec = 0;
%let _dpptool = 0;
%let _footq = 0;
%let _maxt = 7;
%let _maxf = 8;

/* Macro to check that all macro parameters/variables used are valid strings should be added */


/* Set divider */
%if %symexist(_divider) %then %do;
   %if "&_divider." ne "/" and "&_divider." ne "\" %then %do;
      %local _divider;
      %let _divider = /;
   %end;
%end;
%else %do;
   %local _divider;
   %let _divider = /;
%end;

/* Check if DPP Analysis Tool dataset should be used to assign attributes */
%if %symexist(macrotitle_dpptool) %then %do;
   %if %length(%nrbquote(&macrotitle_dpptool)) gt 0 %then %do;
      %if %length(%sysfunc(dequote(&macrotitle_dpptool))) gt 9 %then %do;
         /* check that macrotitle_dpptool is a path to a valid dataset */
         %let _rc=%sysfunc(filename(_fileref,"%sysfunc(dequote(&macrotitle_dpptool.))"));
         %let _did=%sysfunc(dopen(&_fileref.));
         %let _rc=%sysfunc(dclose(&_did.));
         %let _ext=%sysfunc(substr(%sysfunc(dequote(&macrotitle_dpptool.)),%eval(%length(%sysfunc(dequote(&macrotitle_dpptool)))-7),8));
         %if %length(&_ext) eq 0 %then %let _ext=_sas7bdat;
         %if %sysfunc(fileexist(%sysfunc(dequote(&macrotitle_dpptool.)))) eq 0 or
             (%sysfunc(fileexist(%sysfunc(dequote(&macrotitle_dpptool.)))) eq 1 and &_did. gt 0) or
             %quote(%upcase(&_ext.)) ne SAS7BDAT
         %then %do;
            %let stopexec = 1;
            %if %sysfunc(fileexist(%sysfunc(dequote(&macrotitle_dpptool.)))) eq 0 %then %do;
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = File %sysfunc(dequote(&macrotitle_dpptool)) specified as macrotitle_dpptool does not exist.
                , selectType   = E
               );
            %end;
            %else %do;
               %if %sysfunc(fileexist(%sysfunc(dequote(&macrotitle_dpptool.)))) eq 1 and &_did. gt 0 %then %do;
                  %gmMessage
                  ( codelocation  = BMSMacroTitle.sas
                   , linesOut     = Object %sysfunc(dequote(&macrotitle_dpptool)) specified as macrotitle_dpptool is a directory not a file.
                   , selectType   = E
                  );
               %end;
               %else %do;
                  %if %upcase(&_ext.) ne SAS7BDAT %then %do;
                     %gmMessage
                     ( codelocation  = BMSMacroTitle.sas
                      , linesOut     = File %sysfunc(dequote(&macrotitle_dpptool)) specified as macrotitle_dpptool has incorrect extension. Should be .sas7bdat.
                      , selectType   = E
                     );
                  %end;
               %end;
            %end;
         %end;
         %else %do;
            %let _dpptool = 1;
         %end;
      %end;
      %else %do;
         %if %length(%sysfunc(dequote(&macrotitle_dpptool))) ne 0 %then %do;
            %gmMessage
            ( codelocation  = BMSMacroTitle.sas
             , linesOut     = Length of %sysfunc(dequote(&macrotitle_dpptool)) specified as macrotitle_dpptool is too small to be a valid file.
             , selectType   = E
            );
            %let stopexec = 1;
         %end;
      %end;
   %end;
   %else %do;
      %if %length(&_rtype) eq 0 %then %do;
         %let _rtype = t;
      %end;
   %end;
%end;
%else %do;
   %if %length(&_rtype) eq 0 %then %do;
      %let _rtype = t;
   %end;
%end;

/* Check if temporary library WC000001 has been assigned */
%if &_dpptool. eq 1 and %sysfunc(libref(WC000001)) eq 0 %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Library WC000001 had been assigned prior to macro invocation.
    , selectType   = E
   );
   %let stopexec = 1;
%end;
%if %sysfunc(libref(WC000001)) eq 0 %then %do;
   %let _wc000001 = 1;
%end;
%else %do;
   %let _wc000001 = 0;
%end;

/* If DPP Analysis Tool should be used then extract unspecified macro parameters */
%if &_dpptool. eq 1 and &stopexec. eq 0 %then %do;
   %if %length(&_outname.) < 2 %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = File name _outname is not specified or is too short:@_outname = &_outname..
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
   %else %do;
      %if %length(&_rtype) eq 0 %then %do;
         %let _rtype = %sysfunc(substr(&_outname.,2,1));
         %if %upcase(&_rtype.) eq G %then %do;
            %let _rtype = f;
         %end;
      %end;
      %if %upcase(&_rtype.) ne %upcase(%sysfunc(substr(&_outname.,2,1))) and
          (not (%upcase(&_rtype.) eq F and %upcase(%sysfunc(substr(&_outname.,2,1))) eq G)) %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = Specified output type _rtype = &_rtype. is not consistent with output name _outname = &_outname..
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
      %else %do;
         %if %length(&_outpath.) eq 0 %then %do;
            %if %upcase(&_rtype.) eq T %then %do;
               %if %symexist(_otab) %then %do;
                  %if %length(&_otab.) gt 0 %then %do;
                     %let _outpath = &_otab.;
                  %end;
                  %else %do;
                     %gmMessage
                     ( codelocation  = BMSMacroTitle.sas
                      , linesOut     = Default directory for tables _otab is not assigned in setup.
                      , selectType   = E
                     );
                     %let stopexec = 1;
                  %end;
               %end;
               %else %do;
                  %gmMessage
                  ( codelocation  = BMSMacroTitle.sas
                   , linesOut     = Default directory for tables _otab is not defined in setup.
                   , selectType   = E
                  );
                  %let stopexec = 1;
               %end;
            %end;
            %if %upcase(&_rtype.) eq L %then %do;
               %if %symexist(_olis) %then %do;
                  %if %length(&_olis.) gt 0 %then %do;
                     %let _outpath = &_olis.;
                  %end;
                  %else %do;
                     %gmMessage
                     ( codelocation  = BMSMacroTitle.sas
                      , linesOut     = Default directory for listings _olis is not assigned in setup.
                      , selectType   = E
                     );
                     %let stopexec = 1;
                  %end;
               %end;
               %else %do;
                  %gmMessage
                  ( codelocation  = BMSMacroTitle.sas
                   , linesOut     = Default directory for listings _olis is not defined in setup.
                   , selectType   = E
                  );
                  %let stopexec = 1;
               %end;
            %end;
            %if %upcase(&_rtype.) eq F %then %do;
               %if %symexist(_ofig) %then %do;
                  %if %length(&_ofig.) gt 0 %then %do;
                     %let _outpath = &_ofig.;
                  %end;
                  %else %do;
                     %gmMessage
                     ( codelocation  = BMSMacroTitle.sas
                      , linesOut     = Default directory for figures _ofig is not assigned in setup.
                      , selectType   = E
                     );
                     %let stopexec = 1;
                  %end;
               %end;
               %else %do;
                  %gmMessage
                  ( codelocation  = BMSMacroTitle.sas
                   , linesOut     = Default directory for figures _ofig is not defined in setup.
                   , selectType   = E
                  );
                  %let stopexec = 1;
               %end;
            %end;
         %end;
      %end;
      /* Check that there is exactly one record corresponding to specified output */
      data _null_;
         call symputx("_dpptool_nobs", obsNum);
         set "%sysfunc(dequote(&macrotitle_dpptool.))" nObs = obsNum;
         stop;
      run;
      %if &_dpptool_nobs. eq 0 %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = No observations in &macrotitle_dpptool. dataset.
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
      %else %do;
         data _null_;
            set "%sysfunc(dequote(&macrotitle_dpptool.))" (obs=1);
            array cvar {*} _character_;
            length checkvars $22 i j 8 y $1000;
            checkvars=repeat("f",21);
            call missing(i,j,y);
            do i=1 to dim(cvar);
               if (upcase(vname(cvar{i}))="OUTPUTFILENAME") then substr(checkvars,1,1)="s";
               if (upcase(vname(cvar{i}))="TABLENO")        then substr(checkvars,2,1)="s";
               if (index(upcase(vname(cvar{i})),"TITLE")>0) then do;
                  if (substr(upcase(vname(cvar{i})),1,5)="TITLE") then do;
                     call missing(j);
                     j=input(substr(vname(cvar{i}),6),?? best.);
                     if (j in (1:10)) then substr(checkvars,j+2,1)="s";
                  end;
               end;
               if (index(upcase(vname(cvar{i})),"FOOTNOTE")>0) then do;
                  if (substr(upcase(vname(cvar{i})),1,8)="FOOTNOTE") then do;
                     call missing(j);
                     j=input(substr(vname(cvar{i}),9),?? best.);
                     if (j in (1:10)) then substr(checkvars,j+12,1)="s";
                  end;
               end;
            end;
            if (substr(checkvars,1,1)^="s") then y=resolve('
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = Variable OutputFileName does not exist in the dataset '||"%sysfunc(dequote(&macrotitle_dpptool.))"||'.
                , selectType   = E
               );
               ');
            if (substr(checkvars,2,1)^="s") then y=resolve('
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = Variable TableNo does not exist in the dataset '||"%sysfunc(dequote(&macrotitle_dpptool.))"||'.
                , selectType   = E
               );
               ');
            if (index(substr(checkvars,3,10),"f")>0) then y=resolve('
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = Some of variables title1-title10 do not exist in the dataset '||"%sysfunc(dequote(&macrotitle_dpptool.))"||'.
                , selectType   = E
               );
               ');
            if (index(substr(checkvars,13,10),"f")>0) then y=resolve('
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = Some of variables footnote1-footnote10 do not exist in the dataset '||"%sysfunc(dequote(&macrotitle_dpptool.))"||'.
                , selectType   = E
               );
               ');
            if (index(checkvars,"f")>0) then y=resolve('%let stopexec = 1;');
         run;
      %end;
      %if &stopexec. eq 0 %then %do;
         %let stopexec=1;
         %if %length(%nrbquote(&_tableno.)) eq 0 %then %do;
            data _null_;
               set "%sysfunc(dequote(&macrotitle_dpptool.))" (where=(upcase(OutputFileName)=upcase("&_outname."))) end=eof;
               if (eof=1 and _n_=1) then do;
                  call symputx("stopexec","0");
                  call symputx("_tableno",TableNo);
                  call missing(TableNo);
               end;
               if (eof=1 and _n_>1) then call symputx("stopexec",strip(put(_n_,best.)));
            run;
            %if &stopexec. eq 1 %then %do;
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = No records in the DPP Analysis Tool dataset corresdponding to the output &_outname. found.
                , selectType   = E
               );
               %let stopexec = 1;
            %end;
            %if &stopexec. eq 0 and %length(%nrbquote(&_tableno.)) eq 0 %then %do;
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = Variable TableNo is not populated for OutputFileName = &_outname..
                , selectType   = E
               );
               %let stopexec = 1;
            %end;
            %if &stopexec. gt 1 %then %do;
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = More than one record in the DPP Analysis Tool dataset corresdponding to the output &_outname. found.
                , selectType   = E
               );
               %let stopexec = 1;
            %end;
         %end;
         %else %do;
            data _null_;
               set "%sysfunc(dequote(&macrotitle_dpptool.))" (where=(upcase(OutputFileName)=upcase("&_outname.") and upcase(TableNo)=upcase("&_tableno."))) end=eof;
               if (eof=1 and _n_=1) then call symputx("stopexec","0");
               if (eof=1 and _n_>1) then call symputx("stopexec",strip(put(_n_,best.)));
            run;
            %if &stopexec. eq 1 %then %do;
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = No records in the DPP Analysis Tool dataset corresdponding to the output &_outname. and &_tableno. found.
                , selectType   = E
               );
               %let stopexec = 1;
            %end;
            %if &stopexec. gt 1 %then %do;
               %gmMessage
               ( codelocation  = BMSMacroTitle.sas
                , linesOut     = More than one record in the DPP Analysis Tool dataset corresdponding to the output &_outname. and &_tableno. found.
                , selectType   = E
               );
               %let stopexec = 1;
            %end;
         %end;
      %end;
   %end;
%end;

* Set requirement settings according to version ;
%if %symexist(macrotitle_reqver) %then %do;
   %if %length(&macrotitle_reqver.) gt 0 %then %do;
      %let _maxtitle_l = 112;
      %let _maxtitle_p = 60;
      %if &macrotitle_reqver. eq 1.8.3 %then %do;
         %if %upcase(&_orientation) eq L %then %do;
            %let _ll_ = 132;
            %let _pl_ = 43;
            %if %upcase(&_rtype) eq F %then %do;
               %let _maxpos = 84;
            %end;
         %end;
         %if %upcase(&_orientation) eq P %then %do;
            %let _ll_ = 88;
            %let _pl_ = 67;
            %if %upcase(&_rtype) eq F %then %do;
               %let _maxpos = 69;
            %end;
         %end;
      %end;
      %if &macrotitle_reqver. eq 1.8.4 or &macrotitle_reqver. eq 1.8.5 or &macrotitle_reqver. eq 2.0 %then %do;
         %if %upcase(&_orientation) eq L %then %do;
            %let _ll_ = 132;
            %let _pl_ = 48;
            %if %upcase(&_rtype) eq F %then %do;
               %let _maxpos = 84;
            %end;
         %end;
         %if %upcase(&_orientation) eq P %then %do;
            %let _ll_ = 95;
            %let _pl_ = 69;
            %if %upcase(&_rtype) eq F %then %do;
               %let _maxpos = 75;
            %end;
         %end;
      %end;
      %if &macrotitle_reqver. ne 1.8.3 and &macrotitle_reqver. ne 1.8.4 and &macrotitle_reqver. ne 1.8.5 and &macrotitle_reqver. ne 2.0 %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = Unexpected requirement version: reqver = &macrotitle_reqver..
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
      %if %upcase(&_rtype) eq L or %upcase(&_rtype) eq T %then %do;
         %if %symexist(_ls)  %then %do;
            %if &_ls. ne &_ll_. and %length(%nrbquote(&_ll_.)) gt 0 %then %do;
                %gmMessage
                ( codelocation  = BMSMacroTitle.sas
                 , linesOut     = Incorrect line size _ls: _ls = &_ls. _orientation = &_orientation. reqver = &macrotitle_reqver..
                 , selectType   = E
                );
               %let stopexec = 1;
            %end;
         %end;
         %else %do;
            %gmMessage
            ( codelocation  = BMSMacroTitle.sas
             , linesOut     = Line size _ls not assigned in setup.
             , selectType   = E
            );
            %let stopexec = 1;
         %end;
         %if %symexist(_ps) %then %do;
            %if &_ps. ne &_pl_. and %length(%nrbquote(&_pl_.)) gt 0 %then %do;
                %gmMessage
                ( codelocation  = BMSMacroTitle.sas
                 , linesOut     = Incorrect page size _ps: _ps = &_ps. _orientation = &_orientation. reqver = &macrotitle_reqver..
                 , selectType   = E
                );
               %let stopexec = 1;
            %end;
         %end;
         %else %do;
            %gmMessage
            ( codelocation  = BMSMacroTitle.sas
             , linesOut     = Page size _ps not assigned in setup.
             , selectType   = E
            );
            %let stopexec = 1;
         %end;
         %let _maxpos = %eval(&_ll_.-19);
      %end;
   %end;
   %else %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_reqver is empty.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;
%else %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macrotitle_reqver not defined in setup.
    , selectType   = E
   );
   %let stopexec = 1;
%end;

/* Check input variables */
%if %upcase(&_orientation.) ne P and %upcase(&_orientation) ne L %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Incorrect value of _orientation variable (not P or L):@_orientation = &_orientation..
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %upcase(&_rtype.) ne T and %upcase(&_rtype.) ne L and %upcase(&_rtype.) ne F %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Incorrect value of _rtype variable (not in T L F):@_rtype = &_rtype..
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %length(&_outname.) = 0 %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = File name _outname is not specified.
    , selectType   = E
   );
   %let stopexec = 1;
%end;
%if %length(&_outname.) gt &_maxlen. %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = File name _outname is longer than &_maxlen..
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %length(&_outpath.) = 0 %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Output location _outpath is not specified.
    , selectType   = E
   );
   %let stopexec = 1;
%end;
%if %length(&_outpath.) gt &_maxlen. %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Output location _outpath is longer than &_maxlen..
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %length(%nrbquote(&_tableno.)) = 0 %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Output ID _tableno is not specified.
    , selectType   = E
   );
   %let stopexec = 1;
%end;
%if %length(%nrbquote(&_tableno.)) gt &_maxlen. %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Output ID _tableno is longer than &_maxlen..
    , selectType   = E
   );
   %let stopexec = 1;
%end;

/* Retrieve titles and footnotes from DPP Analysis Tool dataset */
%if &stopexec. eq 0 and &_dpptool. eq 1 %then %do;
   data _null_;
      set "%sysfunc(dequote(&macrotitle_dpptool.))" (where=(upcase(OutputFileName)=upcase("&_outname.") and upcase(TableNo)=upcase("&_tableno.")));
   %do i=1 %to &_maxt.;
      call symputx("_t&i.",strip(Title&i.));
   %end;
   %do i=1 %to &_maxf.;
      call symputx("_f&i.",strip(Footnote&i.));
   %end;
   %do i=%eval(&_maxt.+1) %to 10;
      if (not missing(Title&i.)) then call symputx("stopexec","2");
   %end;
   %do i=%eval(&_maxf.+1) %to 10;
      if (not missing(Footnote&i.)) then call symputx("stopexec","2");
   %end;
   run;
   %if &stopexec. eq 2 %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Too many titles or footnotes found. Should be assigned in manual mode.
       , selectType   = W
      );
      %let stopexec = 0;
   %end;
   %do i=1 %to &_maxt.;
      %if %length(%nrbquote(&&_t&i.)) gt 0 %then %let _t&i. = "&&_t&i.";
   %end;
%end;

/* Check if temporary library WC000001 has been assigned in macro and unassgne it*/
%if &_dpptool. eq 1 and %sysfunc(libref(WC000001)) eq 0 and &_wc000001. eq 0 %then %do;
   libname WC000001 clear;
%end;

/* Check that titles are defined correctly */
%let emptytit = 1;
%do i = &_maxt. %to 1 %by -1;
   %if &emptytit. eq 0 and %length(%nrbquote(&&_t&i.)) eq 0 %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Title &i. skipped.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
   %if &emptytit. eq 1 and %length(%nrbquote(&&_t&i.)) gt 0 %then %do;
       %let emptytit = 0;
       %let _titleq = &i.;
   %end;
   /* Check that titles are valid strings should be added */
   %if %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %then %do;
      %if %length(%nrbquote(&&_t&i.)) gt %eval(&_maxtitle_l.+2) and %upcase(&_orientation.) eq L %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = Title &i. longer than &_maxtitle_l. symbols.
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
      %if %length(%nrbquote(&&_t&i.)) gt %eval(&_maxtitle_p.+2) and %upcase(&_orientation.) eq P %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = Title &i. longer than &_maxtitle_p. symbols.
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
   %end;
%end;
%if %length(%nrbquote(&_t1.)) eq 0 %then %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Title1 not defined.
    , selectType   = E
   );
   %let stopexec = 1;
%end;
%if %upcase(&_rtype.) eq F %then %do;
   %if &_titleq. gt 1 %then %do;
      %do i = 2 %to &_titleq.;
         %if %length(%nrbquote(&_t1.)) gt 2 and %length(%nrbquote(&&_t&i.)) gt 2 %then %do;
            %if &macrotitle_reqver. eq 1.8.5 or &macrotitle_reqver. eq 2.0 %then %do;
               %let _t1 = "%substr(%nrbquote(&_t1.),2,%length(%nrbquote(&_t1.))-2) - %substr(%nrbquote(&&_t&i.),2,%length(%nrbquote(&&_t&i.))-2)";
            %end;
            %else %do;
               %let _t1 = "%substr(%nrbquote(&_t1.),2,%length(%nrbquote(&_t1.))-2)(*ESC*)\line %substr(%nrbquote(&&_t&i.),2,%length(%nrbquote(&&_t&i.))-2)";
            %end;
         %end;
         %else %do;
            %gmMessage
            ( codelocation  = BMSMacroTitle.sas
             , linesOut     = Title &i. or 1 too short.
             , selectType   = E
            );
            %let stopexec = 1;
         %end;
      %end;
      %let _titleq = 1;
      %if %length(%nrbquote(&_t1.)) gt &_maxlen. %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = United title 1 too long (max = &_maxlen.).
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
   %end;
%end;

/* Check that footnotes are defined correctly */
%let emptyfoot = 1;
%do i = &_maxf. %to 1 %by -1;
   %if &emptyfoot. eq 0 and %length(%nrbquote(&&_f&i.)) eq 0 %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Footnote &i. skipped.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
   %if &emptyfoot. eq 1 and %length(%nrbquote(&&_f&i.)) gt 0 %then %do;
       %let emptyfoot = 0;
       %let _footq = &i.;
   %end;
   /* Check that titles are valid strings should be added */
   %if %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %then %do;
      %if %length(%nrbquote(&&_f&i.)) gt &_ll_. %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = Footnote &i. longer than page length = &_ll_. symbols.
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
   %end;
%end;

/* Check if stdfoot would be correct for tables and listings */
%if %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %then %do;
   %if &_ll_. gt 0 and %length(%SYSFUNC(Getoption(Sysin))) gt 0 %then %do;
      %if %length(%SYSFUNC(Getoption(Sysin))) gt %eval(&_ll_.-%length(Program Source:  01JAN1900:00:00:00)) %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = Program source too long for stdfoot. was:@ %SYSFUNC(Getoption(Sysin)).
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
   %end;
%end;

/* Check external variables */
%if %symexist(macrotitle_mode) %then %do;
   %if not (%upcase(&macrotitle_mode) eq DMC or
            %upcase(&macrotitle_mode) eq FINAL) %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Incorrect macrotitle_mode in setup:@macrotitle_mode = &macrotitle_mode..
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
   %if %upcase(&macrotitle_mode) eq DMC %then %do;
      %if %sysfunc(libref(dta)) ne 0 %then %do;
         %gmMessage
         ( codelocation  = BMSMacroTitle.sas
          , linesOut     = Library dta does not exist.
          , selectType   = E
         );
         %let stopexec = 1;
      %end;
   %end;
%end;
%else %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macrotitle_mode not defined in setup.
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %symexist(macrotitle_status) %then %do;
   %if not (%upcase(&macrotitle_status) eq DRAFT or
            %upcase(&macrotitle_status) eq FINAL) %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Incorrect macrotitle_status in setup:@macrotitle_status = &macrotitle_status..
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;
%else %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macrotitle_status not defined in setup.
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %symexist(macrotitle_status2) %then %do;
   %if %length(&macrotitle_status2.) gt 0 %then %do;
      %let _confs=&macrotitle_status2.;
   %end;
%end;

%if %symexist(macrotitle_protocol) %then %do;
/* Check 1st title length and create info variable reported in the center */
   %if (%upcase(&macrotitle_mode.) eq DMC) %then %do;
      %if %upcase(&_rtype.) ne F %then %do;
         %if %length(&_confs.) gt 0 %then %do;
            Data _NULL_;
               Call symputx("_analysis",cat(strip("&_tableno."),": &_confs."));
            Run;
         %end;
         %else %do;
            Data _NULL_;
               If (strip(upcase("&macrotitle_status.")) eq "FINAL") Then Call symputx("_analysis",cat(strip("&_tableno."),":"));
               If (strip(upcase("&macrotitle_status.")) eq "DRAFT") Then Call symputx("_analysis",cat(strip("&_tableno."),": Draft"));
            Run;
         %end;
      %end;
      %else %do;
        %if %length(&_confs.) gt 0 %then %do;
            Data _NULL_;
               Call symputx("_analysis",strip("&_confs."));
            Run;
         %end;
         %else %do;
            Data _NULL_;
               If (strip(upcase("&macrotitle_status.")) eq "FINAL") Then Call symputx("_analysis","");
               If (strip(upcase("&macrotitle_status.")) eq "DRAFT") Then Call symputx("_analysis","Draft");
            Run;
         %end;
      %end;
   %end;
   %if (%upcase(&macrotitle_mode.) eq FINAL) %then %do;
      %if %length(&_confs.) gt 0 %then %do;
         Data _NULL_;
            Call symputx("_analysis",strip("&_confs."));
         Run;
      %end;
      %else %do;
         Data _NULL_;
            If (strip(upcase("&macrotitle_status.")) eq "FINAL") Then Call symputx("_analysis","");
            If (strip(upcase("&macrotitle_status.")) eq "DRAFT") Then Call symputx("_analysis","Draft");
         Run;
      %end;
   %end;

   Data _NULL_;
   %if %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %then %do;
      %if %length(&_analysis.)>0 %then %do;
         l=&_ll_. - length('PROTOCOL: ') - length(' PAGE XXXXX OF YYYYY') - length("&_analysis.") - length("&macrotitle_protocol.");
         if (l>=5) then do;
            l2=int((&_ll_.-length("&_analysis."))/2 - length('PROTOCOL :') - length("&macrotitle_protocol."));
            l2=max(l2,5);
            Call symputx("titleone", cat("Protocol: &macrotitle_protocol.",repeat(' ', l2-1),"&_analysis.",repeat(' ', l-l2-1),"Page XXXXX of YYYYY"));
         end;
      %end;
      %else %do;
         l=&_ll_. - length('PROTOCOL: ') - length(' PAGE XXXXX OF YYYYY') - length("&macrotitle_protocol.");
         if (l>=5) then do;
            Call symputx("titleone", cat("Protocol: &macrotitle_protocol",repeat(' ', l-1),"Page XXXXX of YYYYY"));
         end;
      %end;
   %end;
   %else %do;
      %if %length(&_analysis)>0 %then %do;
         l=&_maxpos. - length('PROTOCOL: ') - length(' PAGE XXXXX OF YYYYY') - length("&_analysis.") - length("&macrotitle_protocol");
         if (l>=5) then do;
            l2=int((&_maxpos.-length("&_analysis."))/2 - length('PROTOCOL :') - length("&macrotitle_protocol."));
            l2=max(l2,5);
            Call symputx("titleone1", cat("Protocol: &macrotitle_protocol",repeat(' ', l2-1),"&_analysis.",repeat(' ', l-l2-1),"Page XXXXX of YYYYY"));
         end;
      %end;
      %else %do;
         l=&_maxpos. - length('PROTOCOL: ') - length(' PAGE XXXXX OF YYYYY') - length("&macrotitle_protocol");
         if (l>=5) then do;
            Call symputx("titleone1", cat("Protocol: &macrotitle_protocol",repeat(' ', l-1),"Page XXXXX of YYYYY"));
         end;
      %end;
   %end;
   Run;

   %if %length(%nrbquote(&titleone.)) lt 1 and %length(%nrbquote(&titleone1.)) lt 1 %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Information does not fit in the first line. Please update protocol or status values.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;
%else %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macrotitle_protocol not defined in setup.
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %symexist(macrotitle_libs) %then %do;
   %if %bquote(&macrotitle_libs) NE %then %do;
      %let _char1 = %bquote(%substr(&macrotitle_libs,1,1));
      %if %bquote(&_char1) = %str(%')
          or %bquote(&_char1) = %str(%")
      %then %let macrotitle_libs_q = &macrotitle_libs.;
      %else %let macrotitle_libs_q = "&macrotitle_libs.";
   %end;
   %else %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_libs is empty.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;
%else %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macrotitle_libs not defined in setup.
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %symexist(macrotitle_aedomains) %then %do;
%end;
%else %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macrotitle_aedomains not defined in setup.
    , selectType   = E
   );
   %let stopexec = 1;
%end;

%if %symexist(macrotitle_cmdomains) %then %do;
%end;
%else %do;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macrotitle_cmdomains not defined in setup.
    , selectType   = E
   );
   %let stopexec = 1;
%end;

/* Define domain from outname */
%if &stopexec. eq 0 %then %do;
   Data _Null_;
      If length("&_outname") ge 4 and index("&_outname",'-') gt 1 Then Do;
         call symputx("_domain", strip(upcase(substr("&_outname",index("&_outname",'-')+1,2))));
      End;
   Run;

   %if %length(&_domain.) lt 2 %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Failed to define domain from output name: _outname = &_outname..
       , selectType   = W
      );
   %end;

   %if %length(&_domain.) gt 0 %then %do;
      Data _Null_;
         If (index(upcase("&macrotitle_aedomains."),strip("&_domain.")) gt 0) Then call symputx("_domain", strip('AE'));
         If (index(upcase("&macrotitle_cmdomains."),strip("&_domain.")) gt 0) Then call symputx("_domain", strip('CM'));
      Run;
   %end;
%end;

%if %symexist(macrotitle_dictae) %then %do;
   %if %length(&macrotitle_dictae.) gt &_maxlen. %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_dictae is longer than &_maxlen..
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
   %if %length(&macrotitle_dictae.) lt 1 and %str(&_domain) eq AE %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_dictae is empty.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;
%else %do;
   %if %str(&_domain) eq AE %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_dictae not defined in setup.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;

%if %symexist(macrotitle_dictcm) %then %do;
   %if %length(&macrotitle_dictcm.) gt &_maxlen. %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_dictcm is longer than &_maxlen..
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
   %if %length(&macrotitle_dictcm.) lt 1 and %str(&_domain) eq CM %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_dictcm is empty.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;
%else %do;
   %if %str(&_domain) eq CM %then %do;
      %gmMessage
      ( codelocation  = BMSMacroTitle.sas
       , linesOut     = Macrotitle_dictcm not defined in setup.
       , selectType   = E
      );
      %let stopexec = 1;
   %end;
%end;

/* Execute the rest part of code only if all variables are assigned correctly */
%IF &stopexec. eq 0 %THEN %DO;

/* This macros makes the coverpage */
%MACRO COVERPAGE(_data=);

   /* Macroses which are used in coverpage macros */

   /* Counts space delimited substrings in a source string. */
   %MACRO NSTRINGS(string);
      %EVAL(
            %SYSFUNC(Length(%SYSFUNC(Compbl(&string))))
            -
            %SYSFUNC(Length(%SYSFUNC(Compress(%SYSFUNC(Compbl(&string))))))
            +
            1
           )
   %MEND NSTRINGS;

   /* Removes all characters from a variable value except for 0123456789. */
   %MACRO RMLETTERS(variable);
      Compress(&variable, Compress(&variable, '.0123456789'))
   %MEND RMLETTERS;

   /* Removes all characters from a variable value except for 0123456789. */
   %MACRO RMMLETTERS(string);
      %SYSFUNC(Compress("%UNQUOTE(&string)", %SYSFUNC(Compress("%UNQUOTE(&string)", '.0123456789'))))
   %MEND RMMLETTERS;

   /* Setting header varibales for landscape orientation */
   %LET header01 = THIS DOCUMENT IS CONSIDERED BRISTOL-MYERS SQUIBB COMPANY CONFIDENTIAL INFORMATION. THE INFORMATION CONTAINED HEREIN;
   %LET header02 = MAY NOT BE DISCLOSED OR DISTRIBUTED WITHOUT BRISTOL-MYERS SQUIBB %STR(COMPANY%'S) PRIOR APPROVAL.;

   /* Cleaning titles */
   Title;

   /* Setting variable of orientation to be displayed on coverpage */
   %IF %upcase(&_orientation.) eq L %THEN %LET orientation = LANDSCAPE;
   %IF %upcase(&_orientation.) eq P %THEN %LET orientation = PORTRAIT;

   /* Creating variables with output and log locations */
   Data &pref.Voption;
      Set Sashelp.Voption (Keep = Optname Setting Where = (Optname In ('PRINT' 'LOG' 'LIBNAME')));
      Length = Length(Setting);
   Run;

   Data _Null_;
      Set &pref.Voption;
      Call Symput(Optname, Trim(Left(Put(Length, Best.))));
   Run;

   Data _Null_;
      Set &pref.Voption;
      If      Optname = 'LOG'   Then Call Symput('_logloc_', Trim(Put(Setting, $&log..)));
      Else If Optname = 'PRINT' Then Call Symput('_lstloc_', Trim(Put(Setting, $&print..)));
   Run;

   /* Making dataset with format libraries*/
   /* Formats */
   Data &pref.Formats (Keep = Libname);
      Length Libname $ 32766;
      Set Sashelp.Voption (Keep = Optname Setting Where = (Upcase(Trim(Left(Optname))) = 'FMTSEARCH'));
      Setting = Compress(Compbl(Setting), '()');
      Do I = 1 To Length(Trim(Setting)) - Length(Compress(Trim(Setting))) + 1;
         Libname = Scan(Setting, I, ' ');
         Output;
      End;
   Run;

   Data &pref.Formats1;
      Set &pref.Formats;
      If Substr(Left(Libname), 1, 1) = "'" Or Substr(Left(Libname), 1, 1) = '"' Then Delete;
      Fmtorder = _N_;
   Run;

   Proc Sql;
      Create Table &pref.Formats2 (Drop = Fmtorder Where = (Value Ne '') Rename = (Path = Value)) As
      Select &pref.Formats1.*, Path
      From &pref.Formats1
           Left Join
           Sashelp.Vslib Vslib
           On &pref.Formats1.Libname = Vslib.Libname
      Order By Fmtorder
      ;
   Quit;

   Proc Sql Noprint;
      Select Trim(Libname) Into :libnamelist Separated By ' '
      From &pref.Formats2
      ;
   Quit;

   %LET removelist = "WORK";

   %IF &libnamelist Ne   %THEN %DO;
      %DO i = 1 %TO %NSTRINGS(&libnamelist);
         %IF %SYSFUNC(cexist(%SCAN(&libnamelist, &i))) %THEN %DO;

            Proc Format Library = %SCAN(&libnamelist, &i) Cntlout = Cntlout;
            Run;

            %LET records = 0;

            Data _Null_;
               Set Cntlout End = Eof;
               If Eof Then Call Symput('records', Trim(Left(Put(_N_, Best.))));
            Run;

            %IF &records = 0 %THEN %LET removelist = &removelist "%SCAN(&libnamelist, &i)";

         %END;
      %END;
   %END;

   Data &pref.Formats3;
      Set &pref.Formats2 (Where = (Libname Not In (&removelist)));
      Fmtorder = _N_;
      If _N_ = 1 Then Attribute = 'FORMAT:';
      Line = 20;
      Do While(substr(Value, 2, 1) eq "&_divider.");
         Value = substr(Value, 2);
      End;
      Value = upcase(Value);
      Output;
   Run;

   %LET libnamelist = ;

   /* Making dataset with titles */
   /* Titles */
   Data &pref.Alltitles;
      length Order 8 Value $ &_maxlen.;
      %Do i=2 %To %eval(&_titleq.+1);
         Order = &i.;
         Value = "&&_title&i.";
         output;
      %End;
   Run;

   Data &pref.Titles;
      Set &pref.Alltitles;
      If Order In (. 1) Then Delete;
      If  Order = 2 Then Attribute = 'TITLE:';
      Line = 13;
      Libname="";
   Run;

   Proc Sort Data = &pref.Titles Out = &pref.Titles1;
      By Order;
   Run;

   /* Making datasets with used libraries and dictionaries */
   /* Libraries */
   Data &pref.Libdata(Keep=Libname);
      length string $200 libmem $20 libname $8;
      retain string &_data.;
      Do Until(string eq '');
         libmem=scan(string,1,' ,');
         string=substr(string,length(libmem)+2);
         libname=scan(libmem,1,'.');
         Output;
      End;
   Run;

   Proc Sort Data=&pref.libdata nodupkey; By libname; Run;

   Data _null_;
        Set &pref.libdata;
        If _n_=1
        Then Call symput('libdata',quote(trim(upcase(libname))) );
        Else Call symput('libdata',symget('libdata')||' '||quote(trim(upcase(libname))) );
   Run;

   Data &pref.Libnames (Keep = Libname Path Rename = (Path = Value));
      Set Sashelp.Vslib (Where = (Scan(Upcase(Libname), 1, '_') In ('LIB')
                         Or Upcase(Libname) In ('DICTCM' 'DICTAE' &libdata) ));
      Do While(substr(Path, 2, 1) eq "&_divider.");
         Path = substr(Path, 2);
      End;
   Run;

   Data &pref.Dictcm &pref.Dictae &pref.Datalibs;
      Set &pref.Libnames;
      If      Scan(Upcase(Libname), 2, '_') = 'DICTCM' Then Output &pref.Dictcm;
      Else If Scan(Upcase(Libname), 2, '_') = 'DICTAE' Then Output &pref.Dictae;
      Else Output &pref.Datalibs;
   Run;

   Data &pref.Datalibs;
      Set &pref.Datalibs (Where = (Scan(Upcase(Libname), 2, '_') Not In ('META' 'DZS')));
      Line = 19;
      If _N_ = 1 Then Attribute = 'DATABASE:';
      Value = upcase(Value);
   Run;

   Data &pref.Dictcm;
      Set &pref.Dictcm;
      Line = 21;
      If _N_ = 1 Then Attribute = 'DICTIONARY:';
   Run;

   Data &pref.Dictae;
      Set &pref.Dictae;
      Line = 21;
      If _N_ = 1 Then Attribute = 'DICTIONARY:';
   Run;

   %IF %symexist(macrotitle_dictae) %THEN %DO;
      %If %length(&macrotitle_dictae.) and %str(&_domain) eq AE %Then %Do;

         Data &pref.Dictae;
            Libname="";
            Value = "&macrotitle_dictae.";
            Attribute = 'DICTIONARY:';
            Line = 21;
            Output;
         Run;

      %End;
   %END;

   %IF %symexist(macrotitle_dictcm) %THEN %DO;
      %If %length(&macrotitle_dictcm.) and %str(&_domain) eq CM  %Then %Do;

         Data &pref.Dictcm;
            Libname="";
            Value = "&macrotitle_dictcm.";
            Attribute = 'DICTIONARY:';
            Line = 21;
            Output;
         Run;

      %End;
   %END;

   /* Making dataset with other information */
   Data &pref.Null;
      Length Attribute $ 15
             Value     $ &_maxlen.
      ;
      Libname="";

      *** Project Number *;
      Line      = 9;
      Attribute = 'PROJECT:';
      If not missing(resolve('&_projectid'))
      Then Value = "&_projectid";
      Else If not missing(resolve('&_studyid'))
           Then Value = "%substr(%quote(&_studyid), 1, 5)";
           Else Value = 'NO PROJECT ID';
      Output;

      *** Protocol Number *;
      Line      = 10;
      Attribute = 'PROTOCOL:';
      If not missing(resolve('&_studyid'))
      Then Value = "&_studyid";
      Else Value = 'NO PROTOCOL NUMBER';
      Output;

      *** Document Identification *;
      Line      = 11;
      Attribute = 'DOCUMENT ID:';
      If not missing(resolve('&_outname.'))
      Then Value = upcase("&_outname.");
      Else Value = 'NO FILE NAME';
      Output;

      *** Table Number *;
      Line      = 12;
      If upcase("&_rtype") eq "T" Then Attribute = 'TABLE NO.:';
      Else If upcase("&_rtype") eq "F" Then Attribute = 'FIGURE NO.:';
      Else If upcase("&_rtype") eq "L" then Attribute = 'TABLE NO.:';
      If not missing(resolve('_tableno'))
      Then Value = "&_tableno";
      Else Value = 'NO TABLE NUMBER';
      Output;

      *** Title Lines (Line 13) *;

      *** Orientation *;
      Line      = 14;
      Attribute = 'ORIENTATION:';
      Value     = "&orientation";
      Output;

      *** Status *;
      Line      = 15;
      Attribute = 'STATUS:';
      If "&_reportstatus" eq "@"
      Then Value = "";
      Else Value = "&_reportstatus";
      Output;

      *** Author *;
      Line      = 16;
      Attribute = 'AUTHOR:';
      Value     = "&sysuserid";
      Value     = upcase(Value);
      Output;

      *** Date Created *;
      Line      = 17;
      Attribute = 'CREATED:';
      Value     = "&rundttm";
      Output;

      *** Fully Qualified Program Name *;
      Line      = 18;
      Attribute = 'PROGRAM:';
      Value     = "%SYSFUNC(Getoption(Sysin))";
      If (missing(value)) or Value eq "__STDIN__" Then Value = 'WARN'||'ING: The Program was run in interactive mode';
      Value     = upcase(Value);
      Do While(substr(Value, 2, 1) eq "&_divider.");
         Value = substr(Value, 2);
      End;
      Output;

      *** Location of Database(s) (Line 19) *;
      *** Location of Format Catalog(s) (Line 20)*;
      *** Location of Relevant Dictionaries (Line 21) *;

      *** Fully Qualified Name of Log File *;
      Line      = 22;
      Attribute = 'LOG:';
      Value     = "&_logloc_";
      If (missing(Value)) or Value eq "__STDERR__" Then Value = 'WARN'||'ING: The Program was run in interactive mode';
      Value     = upcase(Value);
      Do While(substr(Value, 2, 1) eq "&_divider.");
          Value = substr(Value, 2);
      End;
      Output;

      *** Fully Qualified Name of Output File *;
      Line      = 23;
      Attribute = 'OUTPUT:';
      If resolve('&_outpath') eq " " or resolve('&_outname') eq  " "
      Then Value  = "&_lstloc_";
      Else Do;
           If substr(resolve('&_outpath'),length(resolve('&_outpath')),1) eq "&_divider."
           Then Value = "&_outpath.&_outname.";
           Else Value = "&_outpath.&_divider.&_outname.";
      End;
      If (missing(Value)) Then Value = 'WARN'||'ING: The Program was run in interactive mode';
      Value     = upcase(Value);
      Do While(substr(Value, 2, 1) eq "&_divider.");
          Value = substr(Value, 2);
      End;
      Output;

      *** Version of SAS *;
      Line      = 24;
      Attribute = 'SAS VERSION:';
      Value     = "&sysvlong4";
      Output;

      *** OPERATING SYSTEM *;
      Line      = 25;
      Attribute = 'OS VERSION:';
      Value     = "&sysscpl";
      Output;
   Run;

/* Combining all datasets for coverpage together */
   %MACRO CHANGELEN(dataset=);
      %local long_val long_lib;

      Data &dataset.(Rename=(Attribute_new=Attribute Value_new=Value Libname_new=Libname));
         Set &dataset.;
         Length Attribute_new $ 20
                Value_new     $ &_maxlen.
                Libname_new   $ &_maxlen.;
         Attribute_new = Attribute;
         Value_new     = Value;
         Libname_new   = Libname;
         if (length(Value) gt &_maxlen.) then call symputx("long_val", '1');
         if (length(Libname) gt &_maxlen.) then call symputx("long_lib", '1');
         Drop Attribute Value Libname;
      Run;

      %if &long_val. eq 1 %then %do;
          %gmMessage
          ( codelocation  = BMSMacroTitle.sas
           , linesOut     = Value longer than &_maxlen. will be cut.
           , selectType   = E
          );
      %end;

      %if &long_lib. eq 1 %then %do;
          %gmMessage
          ( codelocation  = BMSMacroTitle.sas
           , linesOut     = Linbame longer than &_maxlen. will be cut.
           , selectType   = E
          );
      %end;
   %MEND CHANGELEN;

   %CHANGELEN(dataset=&pref.Null);
   %CHANGELEN(dataset=&pref.Datalibs);
   %CHANGELEN(dataset=&pref.Dictae);
   %CHANGELEN(dataset=&pref.Dictcm);
   %CHANGELEN(dataset=&pref.Titles1);
   %CHANGELEN(dataset=&pref.Formats3);


   Data &pref.Null2;
      Set &pref.Null &pref.Datalibs &pref.Dictae &pref.Dictcm &pref.Titles1 &pref.Formats3;
   Run;

   Proc Sort Data = &pref.Null2;
      By Line Order;
   Run;

   %IF %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %THEN %DO;

      Data &pref.Null3;
         Set &pref.Null2;
         If missing(Order) Then Order = 0;
         Do While(length(Value) gt &_maxpos.);
            tmpval = Value;
            Value = substr(tmpval,1,&_maxpos.);
            Output;
            Value = substr(tmpval,&_maxpos.+1);
            Order = Order + (int(Order)+1-Order)/2;
            Call missing(Attribute);
         End;
         if (length(Value) gt 0) then output;
         Drop tmpval;
      Run;

   %END;
   %ELSE %DO;

      Data &pref.Null3;
         Set &pref.Null2;
         If missing(Order) Then Order = 0;
      Run;

   %END;

   Proc Sort Data = &pref.Null3;
      By Line Order;
   Run;

/* Outputing coverpage for tables and listings */

   %IF %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %THEN %DO;
      Data _Null_;
         Set &pref.Null3 End = Eof;
         File Print;
         /*Value = Resolve(Value);*/ /* [RJK_002] */ /* To resolve any macro variables */ /* AM: there shouldn't be any */

         *** Lines 1 to 9 *;
         If _N_ = 1 Then Do;
            Put @%EVAL(%SYSFUNC(Getoption(Ls)) - 14) "Page 0 of YYYYY";
            Put;
            Put;
            Put @1 "&header01";
            Put @1 "&header02";
            Put;
            Put;
            Put @1 "#BEGIN REPORT EXECUTION INFORMATION#";
            Put @1 Attribute @20 Value;
        End;
        *** Lines 10 to 25 *;
        Else If Not Eof Then Do;
            if (Line ne 21 or strip("&_domain.") eq "AE" or strip("&_domain.") eq "CM") then Put @1 Attribute @20 Value;
        End;
        *** Line 26 *;
        Else If Eof Then Do;
            Put @1 Attribute @20 Value;
            Put @1 "#END REPORT EXECUTION INFORMATION#";
        End;
      Run;
   %END;

/* Outputing coverpage for figures */

   %IF %upcase(&_rtype.) eq F %THEN %DO;
      Data &pref.Null3a;
         Set &pref.Null3;
         length Attribute2 $20;
         Line2 = 0;
         Attribute2 = Attribute;
         if (Line ne 21 or "&_domain." eq "AE" or "&_domain." eq "CM")  then output;
         Drop Attribute;
         Rename Attribute2 = Attribute;
      Run;

      Proc Sort Data = &pref.Null3a;
         By Line Order;
      Run;

      ods listing close;

      Title1  j=r "Page 0 of YYYYY";
      Title2  ;
      Title3  ;
      %IF %upcase(&_orientation) eq P %THEN %DO;
          Title4 j=l   "THIS DOCUMENT IS CONSIDERED BRISTOL-MYERS SQUIBB COMPANY "
                       "CONFIDENTIAL INFORMATION. THE INFORMATION CONTAINED "
                       "HEREIN MAY NOT BE DISCLOSED OR DISTRIBUTED WITHOUT "
                       "BRISTOL-MYERS SQUIBB COMPANY'S PRIOR APPROVAL.";
      %END;
      %IF %upcase(&_orientation) eq L %THEN %DO;
          Title4  j=l "&header01. "
                     "&header02.";
      %END;

      Proc Report Data = &pref.Null3a noheader split = '~' spacing = 0 missing nocenter nowd
                  style(report) = [cellspacing = 0 cellpadding = 0 borderwidth = 0 bordercolor = blue ]
                  style(column) = [cellspacing = 0 cellpadding = 0 ];

      column Line2 Line Order Attribute Value;
      define Line2 / order order = internal noprint;
      define Line  / order order = internal noprint;
      define Order / order order = internal noprint;

      define Attribute / left flow style(header) = {cellwidth = %sysfunc(int(1900/&_maxpos.+1))%}
                                   style(column) = {cellwidth = %sysfunc(int(1900/&_maxpos.+1))%};
      define Value     / left flow style(header) = {cellwidth = %sysevalf(99.9-%sysfunc(int(1900/&_maxpos.+1)))%}
                                   style(column) = {cellwidth = %sysevalf(99.9-%sysfunc(int(1900/&_maxpos.+1)))%};

      compute before Line2 / style = [asis = on];
         line @1 '';
         line @1 '#BEGIN REPORT EXECUTION INFORMATION#';
      endcomp;
      compute after Line2 / style = [asis = on];
         line @1 '#END REPORT EXECUTION INFORMATION#';
      endcomp;
      Run;

      ods listing;

   %END;
   %ELSE %DO;
      Data &pref.Null3a;
         Empty = 'Yes';
      Run;
   %END;

%MEND COVERPAGE;


/* The following code assignes titles varibles for coverpage */

%GLOBAL stdfoot stdline pname ppath rundttm ;

Data _NULL_;

%if %symexist(macrotitle_projectid) %then %do;
   Call symputx("_projectid", strip("&macrotitle_projectid."));
%end;
%else %do;
   Call symputx("_projectid", substr("&macrotitle_protocol.", 1, min(length("&macrotitle_protocol."), 5)));
%end;
   Call symputx("_studyid", "&macrotitle_protocol.");
   Call symputx("rundttm", cat(put(date(),date9.), ':', put(time(), tod8.)));
   Call symputx("_reportstatus",upcase("&macrotitle_status."));

   %Do i=1 %To &_titleq.;
      tit='_title'||compress(put(&i.+1, best.));
      Call symputx(tit, strip(&&_t&i.));
   %End;
Run;

/* Call of BMS's modified macros %coverpage */
%IF %upcase(&macrotitle_mode) eq FINAL %THEN %DO;

   %COVERPAGE(_data=&macrotitle_libs_q.);

   Proc datasets nolist nodetails;
      Delete &pref.ALLTITLES
             &pref.DATALIBS
             &pref.DICTAE
             &pref.DICTCM
             &pref.FORMATS
             &pref.FORMATS1
             &pref.FORMATS2
             &pref.FORMATS3
             &pref.LIBDATA
             &pref.LIBNAMES
             &pref.NULL
             &pref.NULL2
             &pref.NULL3
             &pref.NULL3A
             &pref.TITLES
             &pref.TITLES1
             &pref.VOPTION
      ;
   Run; Quit;

%END;


/* Title statements for output */
%IF %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %THEN %DO;
   Title1 height=12pt "&titleone.";
%END;
%IF %upcase(&_rtype.) eq F %THEN %DO;
   %let _t0="&_tableno.:";
   Title1 height=12pt "&titleone1.";
%END;

%LET j=1;

%if %upcase(&_rtype) ne F %then %do;  %let dopvar=0; %end;
%else %do;%let dopvar=1; %end;
%DO i=%eval(1-&dopvar.) %TO &_titleq.;
   %Let j=%eval(&j.+1);
    %If %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %Then %Do;
       %Let l=%eval(&_ll_.-%length(%nrbquote(&&_t&i.)));
       Title&j. "%sysfunc(repeat(%str( ), %sysfunc(int(&l./2))))" %UNQUOTE(&&_t&i..)
           "%sysfunc(repeat(%str( ), %sysfunc(int(&l./2))))";
    %End;
    %If %upcase(&_rtype.) eq F %Then %Do;
       title&j. height=12pt j = c %if &sysver. eq 9.2 %then %do; wrap %end; %UNQUOTE(&&_t&i..);
    %End;
%END;
%LET j=%eval(&j + 1);
Title&j. ;

/* Create global variable with dashline */;
%LET stdline=%SYSFUNC(repeat(-, &_ll_.-1));

%IF &_dpptool. eq 1 and (%upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L) %THEN %DO;
   %LET j=%eval(&j + 1);
   Title&j. "&stdline." ;
%END;

/* Create global variables with program name and path */
%LET pnamefull=%SYSFUNC(Getoption(Sysin));

%IF %length(&pnamefull.) ne 0 and %SUPERQ(pnamefull) ne __STDIN__ %THEN %DO;
   Data _NULL_;
      Call symputx("pname",
         reverse(substr(strip(reverse("&pnamefull.")),1, index(strip(reverse("&pnamefull.")), "&_divider.")-1)));
   Run;

   Data _NULL_;
      Call symputx("ppath",
           substr("&pnamefull.", 1, index("&pnamefull.", "&pname.")-2));
   Run;
%END;

%IF %length(&pnamefull.) eq 0 or %SUPERQ(pnamefull) eq __STDIN__ %THEN %DO;
   %let pnamefull=The Program was run in interactive mode;
   %let pname=Program Name: The Program was run in interactive mode;
   %let ppath=Program Source: The Program was run in interactive mode;
%END; %ELSE %DO;
   %let pname=Program Name: &pname.;
   %let ppath=Program Source: &ppath.;
%END;

%LET l=%eval(&_ll_.-%length("&pnamefull.")-%length(PROGRAM SOURCE: )-%length(16NOV2004:10:37:03));

%IF &l. lt 0 %THEN %DO;
   %let l=0;
%END;

Data _NULL_;
   Call symputx("stdfoot", cat("Program Source: &pnamefull.", repeat(' ', &l.), "&rundttm."));
Run;

/* If DPP Analysis Tool is being used then assign footnotes */;
%IF &_dpptool. eq 1 %THEN %DO;
   %IF %upcase(&_rtype.) eq T or %upcase(&_rtype.) eq L %THEN %DO;
      Footnote1 j=left "&stdline.";
      %DO j=1 %TO &_footq.;
         %LET l=%eval(&_ll_.-%length(%nrbquote(&&_f&j.)));
         %LET l=%sysfunc(max(0,&l.));
         Footnote%eval(&j.+1) j=l "&&_f&j. %sysfunc(repeat(%str( ), &l.))";
      %END;
      Footnote%eval(&_footq.+2) j=l "&stdfoot.";
   %END;
   %IF %upcase(&_rtype.) eq F %THEN %DO;
      %DO j=1 %TO &_footq.;
         Footnote&j. j=l "&&_f&j.";
      %END;
      Footnote%eval(&_footq.+1) j=l "&ppath.";
      Footnote%eval(&_footq.+2) j=l "&pname." j=r "&rundttm.";
   %END;
%END;

/* Create dataset for DTA file if macrotitle_mode = DMC */
%IF (%upcase(&macrotitle_mode.) eq DMC) %THEN %DO;
   Data _NULL_;
      call symputx("_outds",strip(tranwrd(substr("&_outname.",1,index("&_outname.",'.')-1),'-','_')));
   Run;

   Data dta.&_outds.;
      length Outno Attribute $1000;
      Outno = strip("&_tableno.");

      Attribute = "&_outname.";
      Output;

      Attribute = '{ Insert path here }';
      Output;

      Attribute = substr(strip("&_tableno."),1,index(strip("&_tableno."),' ')-1);
      Output;

      Attribute = substr(strip("&_tableno."),index(strip("&_tableno."),' ')+1);
      Output;

      Attribute = '';
      Output;

      Attribute = strip("&_tableno.")||':';
      Output;

      %if %upcase("&_rtype.") eq "T" or %upcase("&_rtype.") eq "L" %then %do;
         Attribute = &_t1.;
         %do i=2 %to &_titleq.;
            Attribute = strip(Attribute)||' - '||&&_t&i.;
         %end;
      %end;
      %if %upcase("&_rtype.") eq "F" %then %do;
         Attribute = tranwrd(&_t1.,"(*ESC*)\line"," -");
      %end;
      Output;

      do i=8 to 15;
         Attribute = '';
         Output;
      end;

      keep Outno Attribute;
   Run;

%END;

%END;
%ELSE %DO;
   %gmMessage
   ( codelocation  = BMSMacroTitle.sas
    , linesOut     = Macros BMSMacroTitle stopped executed because of errors above.
    , selectType   = E
   );
%END;

%MEND BMSMacroTitle;
