/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD
  
  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386
  
  SAS Version:           9.2 and above
  Operating System:      UNIX
-------------------------------------------------------------------------------
  Author:                Brian Shen $LastChangedBy: $
  
  Creation / modified:   27JUL2015 / $LastChangedDate: $
  
  Program Location/name: $HeadURL: $
                                    
  Files Created:         <DOMAIN>.sas                                
  			 
  Program Purpose:       Read the J&J SDTM spec to write the corresponding SAS code automatically.

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.

                         This macro has been validated for use only in PAREXEL's
                         working environment.

  Macro Parameters: 
    Name:                jjautoprog_spec
        Allowed Values:  The location of SDTM mapping spec
        Default Value:   REQUIRED
        Description:     Character string containing existing path for SDTM mapping spec
        
    Name:                jjautoprog_domain
        Allowed Values:  The domain name defined in the SDTM mapping spec
        Default Value:   REQUIRED
        Description:     Character string containing existing domain name         

    Name:                jjautoprog_outpath
        Allowed Values:  The location of automatically generated programs
        Default Value:   REQUIRED
        Description:     Character string containing existing path for automatically generated programs  
                
  Macro Returnvalue:     
      Allowed Values:    NA
      Description:       Macro does not return any values.        
            
  Macro Dependencies:    gmStart (called)
                         gmEnd (called)
                        
-------------------------------------------------------------------------------
  MODIFICATION HISTORY: Subversion $Rev: $
-----------------------------------------------------------------------------*/

%macro gmJJAutoProg(jjautoprog_spec=, jjautoprog_domain=, jjautoprog_outpath=);

/*                       
%gmStart( headURL  = $HeadURL: $
        , revision = $Rev: $
        , checkMinSasVersion=9.2   
         );                       
*/

options missing = "";

%let domain = &jjautoprog_domain;

    PROC IMPORT OUT= work.SPEC_DOMAIN
            DATAFILE= "&jjautoprog_spec.Define_DATADEF.csv"
            DBMS=csv REPLACE;
            delimiter=',';
     GETNAMES=NO;
     DATAROW=6;
     GUESSINGROWS=100;
    RUN;

    proc sql noprint;
        select var3 into: all_domain separated by " "  from SPEC_DOMAIN
    quit;
    
    data _null_;
        infile "&jjautoprog_spec.&domain..csv" recfm=n sharebuffers;
        file "&jjautoprog_spec.&domain..csv" recfm=n;
        retain quote 0;
        input TXT $char1.;
        if TXT = '"' then quote = ^(quote);
        if quote then do;
            if TXT = '0D'x then put ;
            else if TXT = '0A'x then put ' ';
        end;
    run;

    PROC IMPORT OUT= work.SPEC_&domain.
                DATAFILE= "&jjautoprog_spec.&domain..csv"
                DBMS=csv REPLACE;
                delimiter=',';
          DATAROW=4;
         GETNAMES=NO;
         GUESSINGROWS=32676;
    RUN;

    /* Only keep the character columns, so it won't cause issue when transpose the data */
    data _null_;
        set sashelp.vcolumn(in = a where=(libname="WORK" and memname="SPEC_&domain.")) end = eof; 
        if _n_ = 1 then call execute("data SPEC_&domain.; set SPEC_&domain.; ");                
        if type = "num" then call execute("drop "||strip(name)||";");  
        if eof then call execute("run;");                                                                        
    run;       
                
    proc transpose data = SPEC_&domain. out = TSPEC_&domain.;
        var _ALL_;
    run;
                 
    %if %sysfunc(index(&all_domain, SUPP&domain))>0 %then %do;
            data _null_;
                infile "&jjautoprog_spec.SUPP&domain..csv" recfm=n sharebuffers;
                  file "&jjautoprog_spec.SUPP&domain..csv" recfm=n;
                retain quote 0;
                input TXT $char1.;
                if TXT = '"' then quote = ^(quote);
                if quote then do;
                  if TXT = '0D'x then put ;
                  else if TXT = '0A'x then put ' ';
                end;
            run;

            PROC IMPORT OUT= work.SPEC_supp&domain.
                    DATAFILE= "&jjautoprog_spec.SUPP&domain..csv"
                    DBMS=csv REPLACE;
                    delimiter=',';
                 DATAROW=4;
                 GETNAMES=NO;
                 GUESSINGROWS=32676;
            RUN;

        /* Only keep the character columns, so it won't cause issue when transpose the data */
            data _null_;
                set sashelp.vcolumn(in = a where=(libname="WORK" and memname="SPEC_SUPP&domain.")) end = eof; 
                if _n_ = 1 then call execute("data SPEC_SUPP&domain.; set SPEC_SUPP&domain.; ");                
                if type = "num" then call execute("drop "||strip(name)||";");  
                if eof then call execute("run;");                                                                        
            run;  
                
            proc transpose data = SPEC_supp&domain. out = TSPEC_supp&domain.;
                var _ALL_;
            run;            
    %end;
       
************************************************************
*  Create Main Domain                                      *
************************************************************;
                    
    data _null_ ;
        FILE  "&jjautoprog_outpath.&domain..sas";    /* Output Text File */
        put " ";
    run;

    data _null_ ;
        set SPEC_&domain (where=(var2="&domain")) end=eob;
        FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */        
        if _n_ eq 1 then do;
            put '************************************************************';
            put "*  Create dataset: &domain / SUPP&domain" @60 "*";
            put '************************************************************;'/;
            put '%let domain = ' "&domain" ';'/;
            put '%jjattrib;';
            put '%jjdata_type;'/;
        end;
    run; 

    /* set the macro variable to active the macro %jjseqnum / %jjADDBLFL / %jjepoch / %jjvisit / %jjlocallab / %jjludwig / %jjlbnrind */
    %let macro_seq =;
    %let macro_blfl =;
    %let macro_epoch =;
    %let macro_visit =;
    %let macro_locallab =; 
    %let macro_ludwig =;
    %let macro_lbnrind = ;    
                     
    
    data _null_;       
        set SPEC_&domain(where=(^missing(var4))) end=eob;
        array chars {*} _char_;
        do i = 1 to dim(chars );                      
            if index(lowcase(chars(i)), "jjseqnum") then call symputx("macro_seq", '%nrstr('||strip(scan(chars(i), 2, ":"))||')');
            else if index(lowcase(chars(i)), "jjaddblfl") then call symputx("macro_blfl", '%nrstr('||strip(scan(chars(i), 2, ":"))||')'); 
            else if index(lowcase(chars(i)), "jjepoch") then call symputx("macro_epoch", '%nrstr('||strip(scan(chars(i), 2, ":"))||')');               
            else if index(lowcase(chars(i)), "jjvisit") then call symputx("macro_visit", '%nrstr('||strip(scan(chars(i), 2, ":"))||')');  
            else if index(lowcase(chars(i)), "jjlocallab") then call symputx("macro_locallab", '%nrstr('||strip(scan(chars(i), 2, ":"))||')');  
            else if index(lowcase(chars(i)), "jjludwig") then call symputx("macro_ludwig", '%nrstr('||strip(scan(chars(i), 2, ":"))||')');   
            else if index(lowcase(chars(i)), "jjlbnrind") then call symputx("macro_lbnrind", '%nrstr('||strip(scan(chars(i), 2, ":"))||')');          
        end;
    run;         
        
    data unit&domain(keep = COL1 COL4);
        set TSPEC_&domain. %if %sysfunc(index(&all_domain, SUPP&domain))>0 %then TSPEC_supp&domain.;;
        if scan(COL1, 1, "_") = "&domain" and ^missing(scan(COL1, 2, "_"));
        COL1 = catx("_", scan(COL1, 1, "_"), scan(COL1, 2, "_"));
    run; 
    
    proc sort data = unit&domain out = unit&domain  NODUPKEY;
        by COL1 COL4;
    run;                               
    
    /* if source data cotain logline / coding, do the preprocess */
    data unit&domain;        
        set unit&domain;
        length content $2000.;
        if index(COL4, "logline")>0 or index(COL4, "coding")>0 then do;
            content = cats("%", scan(scan(COL4, 2, ":"), 2, "%")); 
            COL4 = scan(scan(COL4, 2, ":"), 1, "%");                    
            FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */  
            put content ';'/;
        end;            
    run;                 
       
    data _null_ ;
        set unit&domain end=eob;
        FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */        
        if _n_ eq 1 then do;
            put 'data &domain;';
            put '   attrib &&&domain._attr_;';
            put '   set ' COL4  '(in = ' COL1  ')' ;
        end;
        else do;
            put '       ' COL4  '(in = ' COL1  ')' ;
        end;
        if eob then do;
            put '    ;';
            put '   format _all_; informat _all_;';
        end; 
        %if %nrbquote(&macro_locallab) ne %then %do;
            if eob then put @13 "length Form $200. AnalyteName $200.;";   /* If there is local lab, assign the length for Form and AnalyteName */
        %end;                   
    run ;                                  
                                
    %let ALLAID = ;
    %let ALLTID = ;  

    proc sql noprint;
        select distinct catx("_", scan(COL1, 1, "_"), scan(COL1, 2, "_"))
        into :ALLAID separated by '@'             
        from TSPEC_&domain.
        where scan(COL1, 1, "_") = "&domain" and ^missing(scan(COL1, 2, "_"));
    quit;                  

    %let aid_count=1;
    %let AID = %scan(%nrbquote(&ALLAID), &aid_count, '@');
                    
    %do %while(&AID NE);
        data _null_ ;
            set SPEC_&domain(where=(^missing(var4))) end=eob;
            FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */   
            if _n_ eq 1 then do;
                put @4 "if &AID then do;";    /* Dataset level do */
                put @9 "_source_ " @32 "= '&AID';";
            end;
        run;
        
        proc sql noprint;
            select COL1
            into :ALLTID separated by '@'             
            from TSPEC_&domain.
            where catx("_", scan(COL1, 1, "_"), scan(COL1, 2, "_"))="&AID";
        quit;          
        
        data _null_;
            set TSPEC_&domain.(where=(catx("_", scan(COL1, 1, "_"), scan(COL1, 2, "_"))="&AID"));
            call symputx(COL1, _NAME_);            
        run;
                                             
        %let tid_count=1;
        %let TID = %scan(%nrbquote(&ALLTID), &tid_count, '@');
            
        %do %while (&TID NE() and %scan(&TID, 1, "_")_%scan(&TID, 2, "_") = &AID); 
            
            %let outvarid = &TID.;
            %let criteria = ;
            %let addinfo = ;
            %let source_ = ;
            
            data _null_;
                set SPEC_&domain;
                if _n_ eq 2 then call symputx("criteria", &&&outvarid.);
                if _n_ eq 4 then call symputx("source_", scan(&&&outvarid., 1, "%"));
                if _n_ eq 5 then call symputx("addinfo", &&&outvarid.); 
            run;                                                
              
            data _null_ ;
                length content $2000.;
                set SPEC_&domain(where=(^missing(VAR4))) end=eob;
                FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */ 
                
                %if %nrbquote(&criteria) ne %then %do;                    
                    if _n_ = 1 then put @9 "&criteria then do;"; /* Test level do */
                %end;
                
                %if %nrbquote(&addinfo) ne %then %do; 
                    %let addinfo = %bquote(%sysfunc(tranwrd(%bquote(&addinfo), %str(|), %str(;))));                                       
                    if _n_ = 1 then put @13 "&addinfo ;";   /* Assgin the additional information. */
                %end;                                
                                  
                /* Main Content */                                                    
                if ^missing(VAR4) and VAR4 ne "&domain.SEQ" then do;                             
                    if VAR4 = "STUDYID" and scan("&source_", 1, ".") = "raw" 
                        then put @13 "_&domain._" VAR4 @32 "=" @34 "strip(compbl(PROJECT));";
                    else if VAR4 = "USUBJID" and scan("&source_", 1, ".") = "raw" 
                        then put @13 "_&domain._" VAR4 @32 "=" @34 "catx('-', PROJECT, SUBJECT);";
                    else if VAR4 = "&domain.SPID" and scan("&source_", 1, ".") = "raw" 
                        then put @13 "_&domain._" VAR4 @32 "=" @34 "catx('-', 'RAVE', upcase(INSTANCENAME), upcase(DATAPAGENAME), PAGEREPEATNUMBER, RECORDPOSITION);";   
                    else if VAR4 = "DOMAIN" 
                        then put @13 "_&domain._" VAR4 @32 "=" @34 "'&domain.';";                                          
                    else if VAR4 = "&domain.TEST" 
                        then put @13 "_&domain._" VAR4 @32 "=" @34 "put(_&domain._&domain.TESTCD, $&domain._TESTCD.);";                    
                    else if VAR4 = "&domain.STRESN" 
                        then put @13 "_&domain._" VAR4 @32 "=" @34 "input(_&domain._&domain.STRESC, ??best.);";                                          
                    else if VAR4 in ("&domain.SEQ", "&domain.BLFL", "EPOCH") or index(&&&outvarid, '%jjvisit') > 0 or missing(&&&outvarid) or index(&&&outvarid, '<blank>') > 0 
                            or index(&&&outvarid, '%jjlocallab') > 0 or index(&&&outvarid, '%jjludwig') > 0 or index(&&&outvarid, '%jjlbnrind') > 0 then do;
                        if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "'';";  
                        else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 ". ;";
                    end;
                    
                    else do;                                                                     
                        if scan(&&&outvarid., 1, ":") = "char" then do;
                            content = strip(scan(&&&outvarid., 2, ":")); 
                            /* Variable from SDTM data */
                            if strip(upcase(scan(content, 1, "."))) = "SDTM" and scan(&&&outvarid., 2, ".") = "&domain" then do; 
                                content = scan(content, -1, ".");                            
                                if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "_&domain._" content " ;";                                                                             
                                else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 "input(_&domain._" content ", ??best.) ;";  
                            end;    
                            /* Variable from RAW data : 
                                Except for Coding and Units variable, use upcase + strip + compbl funciton 
                                For Units variable, use strip + compbl function
                                For Coding variable, map the coding term directly */
                                                                                     
                            else do;                                                                                                                     
                                if VAR6 in ("text", "datetime", "date", "time") then do;
                                    if substr(VAR4,3) not in ("LLT", "DECOD", "HLT", "HLGT", "BODSYS", "SOC", "CLAS", "CLASCD") and substr(strip(reverse(VAR4)), 1, 1) ne "U" then 
                                        put  @13 "_&domain._" VAR4 @32 "=" @34 "strip(compbl(upcase(" content "))) ;";
                                    else if substr(strip(reverse(VAR4)), 1, 1) = "U" then 
                                        put  @13 "_&domain._" VAR4 @32 "=" @34 "strip(compbl(" content ")) ;";
                                    else put  @13 "_&domain._" VAR4 @32 "=" @34 content ";";
                                    end; 
                                else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 "input(" content ", ??best.) ;";
                            end;                                                         
                        end;  
                        else if scan(&&&outvarid., 1, ":") = "num" then do;
                            content = strip(scan(&&&outvarid., 2, ":"));
                            /* Variable from SDTM data */
                            if strip(upcase(scan(content, 1, "."))) = "SDTM" and scan(&&&outvarid., 2, ".") = "&domain" then do; 
                                content = scan(content, -1, ".");                            
                                if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "strip(put(_&domain._" content ", ??best.));";                                
                                else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 "_&domain._" content ";";                                 
                            end;                             
                            else do;
                                if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "strip(put(" content ", ??best.)) ;";  
                                else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 content ";";
                            end;                                                        
                        end;                    
                        else if scan(&&&outvarid., 1, ":") in ("derive") then do;
                            content = strip(scan(&&&outvarid., 2, ":"));
                            put  @13 content ";";
                        end;  
                        else if scan(&&&outvarid., 1, ":") in ("assign") then do;
                            content = strip(scan(&&&outvarid., 2, ":"));
                            put @13 "_&domain._" VAR4 @32 "=" @34 content ";";
                        end;                                     
                        else if scan(&&&outvarid., 1, ":") in ("postprocess") then do; 
                            put @13 "put 'WAR' 'NING:[PXL] The variable " VAR4 "needs postprocess.';";                           
                            if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "'';" +2 "/* postprocess */";  
                            else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 ". ;" +2 "/* postprocess */";                                                        
                        end;                                                                           
                        else do;
                            put  @13 "_&domain._" VAR4 @32 "=" @34 &&&outvarid. ";";
                        end;
                    end;                        
                end; 
                
                if eob then put @13 "output;";
                
                %if %nrbquote(&criteria) ne %then %do;
                    if eob then put @9 "end;";  /* Test level end */
                %end;                                                                         
            run;
        
        %let tid_count = %eval(&tid_count + 1);             
        %let TID = %scan(%nrbquote(&ALLTID), &tid_count, '@');
            
            %if %scan(&TID, 1, "_")_%scan(&TID, 2, "_") ne &AID %then %do;            
                data _null_;
                    FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */
                    put @4 "end;";           /* Dataset level end */
                run;                 
            %end; 
                           
        %end; 
                 
    %let aid_count = %eval(&aid_count + 1);
    %let AID = %scan(%nrbquote(&ALLAID), &aid_count, '@');        
    %end;  
    
    data _null_ ;
        FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */
        put "run;"/;
    run; 
    
    /* Active the outside data step macro %jjseqnum / %jjADDBLFL / %jjepoch / %jjvisit / %jjlocallab / %jjludwig / %jjlbnrind */
                                   
    data _null_ ;        
        FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */
        %if %nrbquote(&macro_locallab) ne %then put @1 "&macro_locallab;"/;;
        %if %nrbquote(&macro_ludwig) ne %then put @1 "&macro_ludwig;"/;;
        %if %nrbquote(&macro_lbnrind) ne %then put @1 "&macro_lbnrind;"/;;                
        %if %nrbquote(&macro_visit) ne %then put @1 "&macro_visit;"/;; 
        %if %nrbquote(&macro_epoch) ne %then put @1 "&macro_epoch;"/;;
        %if %nrbquote(&macro_blfl) ne %then put @1 "&macro_blfl;"/;;  
        %if %nrbquote(&macro_seq) ne %then put @1 "&macro_seq;"/;;        
    run;                              

************************************************************
*  Create SUPP Domain                                      *
************************************************************;
  
    %if %sysfunc(index(&all_domain, SUPP&domain))>0 %then %do;
        %let ALLAID = ;
        %let ALLTID = ;

        proc sql noprint;
            select distinct catx("_", scan(COL1, 1, "_"), scan(COL1, 2, "_"))
            into :ALLAID separated by '@'             
            from TSPEC_supp&domain.
            where scan(COL1, 1, "_") = "&domain" and ^missing(scan(COL1, 2, "_"));
        quit;

        data _null_ ;
            set SPEC_supp&domain.(where=(^missing(var4))) end=eob;
            FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */   
            if _n_ eq 1 then do;
                put "data supp&domain.;";
                put @4 'attrib &&supp' "&domain._attr_;";
                put @4 "set &domain;";
            end;
        run;                          
                                            
        %let aid_count=1;
        %let AID = %scan(%nrbquote(&ALLAID), &aid_count, '@');
                    
        %do %while(&AID NE);
            data _null_ ;
                set SPEC_supp&domain.(where=(^missing(var4))) end=eob;
                FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */   
                if _n_ eq 1 then do;                    
                    put @4 "if _source_ = '&AID' then do;";                                         
                end;
            run;
        
        proc sql noprint;
            select COL1
            into :ALLTID separated by '@'             
            from TSPEC_supp&domain.
            where catx("_", scan(COL1, 1, "_"), scan(COL1, 2, "_"))="&AID";
        quit;          
        
        data _null_;
            set TSPEC_supp&domain.(where=(catx("_", scan(COL1, 1, "_"), scan(COL1, 2, "_"))="&AID"));
            call symputx(COL1, _NAME_);
        run;
                                         
            %let tid_count=1;
            %let TID = %scan(%nrbquote(&ALLTID), &tid_count, '@');
            
            %do %while (&TID NE() and %scan(&TID, 1, "_")_%scan(&TID, 2, "_") = &AID); 
            
                %let outvarid = &TID.;
                %let criteria = ;
                %let addinfo = ;
            
                data _null_;
                    set SPEC_supp&domain;
                    if _n_ eq 2 then call symputx("criteria", &&&outvarid.);
                    if _n_ eq 5 then call symputx("addinfo", &&&outvarid.); 
                run;                                                
              
                data _null_ ;
                    length content $2000.;
                    set SPEC_supp&domain(where=(^missing(VAR4))) end=eob;
                    FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */ 
                
                    %if %nrbquote(&criteria) ne %then %do;                        
                        if _n_ = 1 then put @9 "&criteria then do;"; /* Test level do */
                    %end;
                    
                    %if %nrbquote(&addinfo) ne %then %do;
                        %let addinfo = %bquote(%sysfunc(tranwrd(&addinfo, %str(|), %str(;))));                     
                        if _n_ = 1 then put @13 "&addinfo ;";  /* Assgin the additional information. */
                    %end;                    
                  
                /* Main Content */                                                    
                    if ^missing(VAR4) then do;
                        if VAR4 = "STUDYID" then put @13 "_&domain._" VAR4 @32 "=" @34 "_&domain._" VAR4 ";";
                        else if VAR4 = "RDOMAIN" then put @13 "_&domain._" VAR4 @32 "=" @34 "'&domain.';"; 
                        else if VAR4 = "USUBJID" then put @13 "_&domain._" VAR4 @32 "=" @34 "_&domain._" VAR4 ";";
                        else if VAR4 = "QLABEL"  then put @13 "_&domain._" VAR4 @32 "=" @34 "put(_&domain._QNAM, $&domain._QL.);";                                                                
                        else if missing(&&&outvarid) or index(&&&outvarid, '<blank>') > 0 then do;
                            if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "'';";  
                            else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 ". ;";
                        end;
                        else do;                                                
                            if scan(&&&outvarid., 1, ":") = "char" then do;
                                content = strip(scan(&&&outvarid., 2, ":")); 
                                /* Variable from SDTM data */
                                if strip(upcase(scan(content, 1, "."))) = "SDTM" and scan(&&&outvarid., 2, ".") = "&domain" then do; 
                                    content = scan(content, -1, ".");                            
                                    if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "_&domain._" content ";";
                                    else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 "input(_&domain._" content ", ??best.) ;";  
                                end;    
                                /* Variable from RAW data */                             
                                else do;                                                                                                                     
                                    if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "strip(compbl(upcase(" content "))) ;";
                                    else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 "input(" content ", ??best.) ;";
                                end;                                                         
                            end;  
                            else if scan(&&&outvarid., 1, ":") = "num" then do;
                                content = strip(scan(&&&outvarid., 2, ":"));
                                /* Variable from SDTM data */
                                if strip(upcase(scan(content, 1, "."))) = "SDTM" and scan(&&&outvarid., 2, ".") = "&domain" then do; 
                                    content = scan(content, -1, ".");                            
                                    if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "strip(put(_&domain._" content ", ??best.)) ;";                                
                                    else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 "_&domain._" content ";";                                 
                                end;                             
                                else do;
                                    if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "strip(put(" content ", ??best.)) ;";  
                                    else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 content ";";
                                end;                                                        
                            end;                    
                            else if scan(&&&outvarid., 1, ":") in ("derive") then do;
                                content = strip(scan(&&&outvarid., 2, ":"));
                                put  @13 content ";";
                            end;     
                            else if scan(&&&outvarid., 1, ":") in ("assign") then do;
                                content = strip(scan(&&&outvarid., 2, ":"));
                                put @13 "_&domain._" VAR4 @32 "=" @34 content ";";
                            end;                                       
                            else if scan(&&&outvarid., 1, ":") in ("postprocess") then do;
                                put @13 "put 'WAR' 'NING:[PXL] The variable " VAR4 "needs postprocess.';";                             
                                if VAR6 in ("text", "datetime", "date", "time") then put  @13 "_&domain._" VAR4 @32 "=" @34 "'';" +2 "/* postprocess */";  
                                else if VAR6 in ("integer", "float") then put @13 "_&domain._" VAR4 @32 "=" @34 ". ;" +2 "/* postprocess */";                                                        
                            end;                                                    
                            else do;
                                put  @13 "_&domain._" VAR4 @32 "=" @34 &&&outvarid. ";";
                            end;
                        end;                       
                    end; 
                
                    if eob then put @13 "output;";
                    
                    %if %nrbquote(&criteria) ne %then %do;
                        if eob then put @9 "end;";  /* Test level end */
                    %end;                                                                         
                run;
                      
            %let tid_count = %eval(&tid_count + 1);             
            %let TID = %scan(%nrbquote(&ALLTID), &tid_count, '@');
        
                %if %scan(&TID, 1, "_")_%scan(&TID, 2, "_") ne &AID %then %do;            
                    data _null_;
                        FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */
                        put @4 "end;";           /* Dataset level end */
                    run;                 
                %end; 
                                               
            %end; 
                 
        %let aid_count = %eval(&aid_count + 1);
        %let AID = %scan(%nrbquote(&ALLAID), &aid_count, '@'); 
               
        %end;  
    
    data _null_ ;
        FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */
        put "run;"/;
    run; 
           
    %end; 
    
************************************************************
*  Rename and finalized the domain and supp domain         *
************************************************************;

data _null_ ;        
    set SPEC_&domain(where=(^missing(VAR4))) end=eob;
    FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */ 
    if _n_ = 1 then do;
        put "/* Rename and Finalized &domain */" /;
        put 'data transfer.&domain.(label = &&&domain._label_ &keep_sub);'; 
        put @4 'set &domain(keep = &&&domain._keepvar_' %if &domain ne DM and &domain ne SV %then ' _&domain._&domain.SEQ';');';         
    end;        
    put @4 "rename _&domain._" VAR4 @30 " = " VAR4 ";"; 
    if eob then put "run;"/;
run;    

%if %sysfunc(index(&all_domain, SUPP&domain))>0 %then %do;
    data _null_ ;        
        set SPEC_supp&domain(where=(^missing(VAR4))) end=eob;
        FILE  "&jjautoprog_outpath.&domain..sas" MOD ;    /* Output Text File */ 
        if _n_ = 1 then do; 
            put "/* Rename and Finalized SUPP&domain */" /;
            put 'proc sort nodupkey data = supp&domain; by &&supp&domain._seqvar_; run;'/;
            put 'data transfer.supp&domain.(label = &&supp&domain._label_ &keep_sub);'; 
            put @4 'set supp&domain(keep = &&supp&domain._keepvar_ );';
        end;        
        put @4 "rename _&domain._" VAR4 @30 " = " VAR4 ";"; 
        if eob then put "run;"/;                
    run;             
%end;

/* Change the mode of SAS program to '770' */
x chmod 770 &jjautoprog_outpath.&domain..sas

/*
%gmEnd(headURL = $HeadURL: $);
*/
                     
%mend gmJJAutoProg;
%gmJJAutoProg(jjautoprog_spec=%str(C:\Users\shenb\Desktop\projects\Janssen\Janssen standard library\program\JJ\spec\),
              jjautoprog_domain=AE,
              jjautoprog_outpath=%str(C:\Users\shenb\Desktop\projects\Janssen\Janssen standard library\program\JJ\interim\));                                                               