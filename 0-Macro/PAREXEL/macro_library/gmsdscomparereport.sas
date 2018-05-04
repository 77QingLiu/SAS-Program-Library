/*-----------------------------------------------------------------------------
  PAREXEL INTERNATIONAL LTD

  Sponsor / Protocol No: PAREXEL / Macro and Application Development committee
  PXL Study Code:        80386

  SAS Version:           9.3
  Operating System:      UNIX
-------------------------------------------------------------------------------

  Author:                Nathan Johnson  $LastChangedBy: kolosod $ 
  Creation Date:         13JAN2016 / $LastChangedDate: 2016-02-01 04:02:47 -0500 (Mon, 01 Feb 2016) $  

  Program Location/name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsdscomparereport.sas $ 

  Files Created:         Compare results report file (.xls)

  Program Purpose:       Compare two versions of SDS file for differences 

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
 
                         This macro has been validated for use only in PAREXEL's
                         working environment.
  
  Macro Parameters:      

    Name:                pathIn
      Allowed Values:    Valid system path
      Default Value:     (null)
      Description:       Specifies the location of SDS files to be processed
 
    Name:                fileSdsBase
      Allowed Values:    Valid file name with extension
      Default Value:     (null)
      Description:       Specifies the name of SDS file 1. Must be a .xlsx file.

    Name:                fileSdsCompare
      Allowed Values:    Valid file name with extension
      Default Value:     (null)
      Description:       Specifies the name of SDS file 2. Must be a .xlsx file.

    Name:                pathOut
      Allowed Values:    Valid system path
      Default Value:     (null)
      Description:       Specifies the location to which the report file will be 
                         written.

    Name:                fileOut
      Allowed Values:    Valid file name without extension
      Default Value:     SDS_compare_report
      Description:       Specifies the root of the output file name. The date time
                         stamp of creation will be appended to the name and it
                         will be stored as .xls (Excel xml spreadsheet)

                         
  Macro Returnvalue:     N/A

  Macro Dependencies:    gmExecuteUnixCmd (called)
                         gmMessage (called)
                         gmStart (called)
                         gmEnd (called)
  
-------------------------------------------------------------------------------
MODIFICATION HISTORY:    Subversion $Rev: 1803 $ 
-----------------------------------------------------------------------------*/

%macro gmsdscomparereport
        (
           pathIn=
          ,fileSdsBase=
          ,fileSdsCompare=
          ,pathOut=
          ,fileOut=SDS_compare_report
        );

/*******************************************************************************
* INITIALIZE ENVIRONMENT
*******************************************************************************/
    %let sdscr_tempLib = %gmStart(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsdscomparereport.sas $,
                            revision=$Rev: 1803 $,
                            libRequired=1,
                            checkMinSasVersion=9.3
                           );

    %local  sdscr_cdatetime     /* Current date time stamp for use in file names */
    ;
                               
    * Generate run date time for output listing;
    data _null_;
        format _cdatetime E8601DT.;
        _cdatetime = datetime();
        call symput('sdscr_cdatetime',compress(put(_cdatetime, E8601DT.),'-:'));
    run;
      
    %let fileOut        = &fileOut._&sdscr_cdatetime..xls;

    * if pathOut not specified, set to pathIn;
    %if %str("&pathOut") = %str("") %then %do;
        %let pathOut = &pathIn;
    %end;
    
/*******************************************************************************
* PARAMETER CHECKS
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] Parameter Checks";
    /***************************************************************************
    * CHECK THAT SDS FILE 1 EXISTS
    ***************************************************************************/
    %if %eval(%sysfunc(fileexist(&pathIn./&fileSdsBase)) = 0) %then %do;
        x "echo [GMSDSCOMPAREREPORT] -- Parameter fileSdsBase= &fileSdsBase. has an invalid value.";
        %gmMessage( codeLocation = gmSdsCompareReport/Parameter checks
                , linesOut     = %str(Parameter fileSdsBase= &fileSdsBase. has an invalid value.
                                      @Base SDS file does not exist.)
                , selectType   = ABORT
                );
    %end;

    /***************************************************************************
    * CHECK THAT SDS FILE 2 EXISTS
    ***************************************************************************/
    %if %eval(%sysfunc(fileexist(&pathIn./&fileSdsCompare)) = 0) %then %do;
        x "echo [GMSDSCOMPAREREPORT] -- Parameter fileSdsBase= &fileSdsCompare. has an invalid value.";
        %gmMessage( codeLocation = gmSdsCompareReport/Parameter checks
                , linesOut     = %str(Parameter fileSdsCompare= &fileSdsCompare. has an invalid value.
                                      @Compare SDS file does not exist.)
                , selectType   = ABORT
                );
    %end;

    /***************************************************************************
    * CHECK THAT OUTPUT PATH EXISTS
    ***************************************************************************/
    %if %eval(%sysfunc(fileexist(&pathOut)) = 0) %then %do;
        x "echo [GMSDSCOMPAREREPORT] -- Parameter pathOut= &pathOut. has an invalid value.";
        %gmMessage( codeLocation = gmSdsCompareReport/Parameter checks
                , linesOut     = %str(Parameter pathOut= &pathOut. has an invalid value.
                                      @Output directory path does not exist.)
                , selectType   = ABORT
                );
    %end;
    

    
/*******************************************************************************
* FORM STRUCTURE: DEFINE FIELDS TO CHECK
*******************************************************************************/
    data &sdscr_tempLib..fs_items;
        length n 8. field item $32.;
        field='sas_field'        ;  n = 5;  item='SAS Field'        ;  output;
        field='sdtm_name'        ;  n = 6;  item='SDTM Name'        ;  output;
        field='question_prompt'  ;  n = 7;  item='Question Prompt'  ;  output;
        field='short_prompt'     ;  n = 8;  item='Short Prompt'     ;  output;
        field='sas_label'        ;  n = 9;  item='SAS Label'        ;  output;
        field='table'            ;  n =10;  item='Is Table'         ;  output;
        field='table_type'       ;  n =11;  item='Table Type'       ;  output;
        field='max_no_of_rows'   ;  n =12;  item='Max No. of Rows'  ;  output;
        field='key_seq_no'       ;  n =13;  item='Key Seq No'       ;  output;
        field='table_name'       ;  n =14;  item='Table Name'       ;  output;
        field='column_label'     ;  n =15;  item='Column Label'     ;  output;
        field='hidden'           ;  n =16;  item='Hidden'           ;  output;
        field='data_group_name'  ;  n =17;  item='Data Group Name'  ;  output;
        field='pde_verify'       ;  n =18;  item='PDE Verify'       ;  output;
        field='Condition_name'   ;  n =19;  item='Condition Name'   ;  output;
        field='condition'        ;  n =20;  item='Condition'        ;  output;
        field='domain_name'      ;  n =21;  item='Domain Name'      ;  output;
        field='sas_dataset_name' ;  n =22;  item='SAS Dataset Name' ;  output;
        field='source'           ;  n =23;  item='Source'           ;  output;
        field='Data_type'        ;  n =24;  item='Data Type'        ;  output;
        field='display_option'   ;  n =25;  item='Display Option'   ;  output;
        field='code_list'        ;  n =26;  item='Code List'        ;  output;
        field='max_length'       ;  n =27;  item='Max Length'       ;  output;
        field='min_length'       ;  n =28;  item='Min Length'       ;  output;
        field='max_prec'         ;  n =29;  item='Max Prec'         ;  output;
        field='min_prec'         ;  n =30;  item='Min Prec'         ;  output;
        field='derivation_name'  ;  n =31;  item='Derivation Name'  ;  output;
        field='coding_dictionary';  n =32;  item='Coding Dictionary';  output;
        field='comments'         ;  n =33;  item='Comments'         ;  output;
    run;
        
    proc sql noprint;
        select min(n), max(n) into:fs_minitem, :fs_maxitem
        from &sdscr_tempLib..fs_items;
    quit;
    %let fs_minitem = %sysfunc(strip(&fs_minitem));
    %let fs_maxitem = %sysfunc(strip(&fs_maxitem));

    proc sql noprint;
        select n, field, item 
                into:fs_n&fs_minitem - :fs_n&fs_maxitem, 
                  :fs_field&fs_minitem - :fs_field&fs_maxitem, 
                  :fs_item&fs_minitem - :fs_item&fs_maxitem
        from &sdscr_tempLib..fs_items
        ;
    quit;
  
  
/*******************************************************************************
* FORM STRUCTURE: DEFINE MACRO TO READ FORM STRUCTURE TAB OF SDS FILE
*******************************************************************************/
    %macro sdscomparereport_get_formstruct(file,ver);

        /* IMPORT FORM STRUCTURE TAB */
        proc import out=&sdscr_tempLib..fs&ver.in

                    datafile="&file"
                    dbms=xlsx
                    replace
                    ;
            sheet="Form (Screen) Structure";
            getnames=no;
        run;


        data &sdscr_tempLib..fs&ver.a;
            length form_label $500. item_name $100. ;
            set &sdscr_tempLib..fs&ver.in;
            if _n_ > 1 and anyalpha(A);



            form_label = strip(compress(A,,"kw"));
            item_name = compress(B,,'kw');
            E = compress(E,,'kw');
          
            rename
                C = SAS_Field&ver
                D = SDTM_Name&ver
                E = Question_Prompt&ver
                F = Short_Prompt&ver
                G = SAS_Label&ver
                H = Table&ver
                I = Table_Type&ver
                J = Max_No_of_Rows&ver
                K = Key_Seq_No&ver
                L = Table_Name&ver
                M = Column_Label&ver
                N = Hidden&ver
                O = Data_Group_Name&ver
                P = PDE_Verify&ver
                Q = Condition_Name&ver
                R = Condition&ver
                S = Domain_Name&ver
                T = SAS_Dataset_Name&ver
                U = Source&ver
                V = Data_Type&ver
                W = Display_Option&ver
                X = Code_List&ver
                Y = Max_Length&ver
                Z = Min_Length&ver
                AA = Max_Prec&ver
                AB = Min_Prec&ver
                AC = Derivation_Name&ver
                AD = Coding_Dictionary&ver
                AE = Comments&ver
            ;

            drop a b;
        run;

        proc sort data=&sdscr_tempLib..fs&ver.a;
            by form_label;
        run;
        
        /* CHECK IMPORT OF FORM STRUCTURE */
        %let countfs&ver = 0;
        proc sql noprint;
            select count(*) into: countfs&ver
            from &sdscr_tempLib..fs&ver.a
            ;
        quit;
        %if %eval(&countfs&ver = 0) %then %do;
            x "echo [GMSDSCOMPAREREPORT] -- Unable to read Form Structure from SDS&ver";
            %gmMessage( codeLocation = gmSdsCompareReport/Read Form Structure Tab
                    , linesOut     = %str(Unable to read Form Structure from SDS&ver
                                          @Please ensure that file is a valid SDS file saved as .XLSX)
                    , selectType   = ABORT
                    );
        %end;


        /* IMPORT EVENT STRUCTURE TAB */
        proc import out=&sdscr_tempLib..evt&ver
                    datafile="&file"
                    dbms=xlsx
                    replace
                    ;
            sheet="Event Structure";
            getnames=no;
        run;

        data &sdscr_tempLib..evt&ver.a;
            set &sdscr_tempLib..evt&ver;
            if _n_ > 1 and anyalpha(A);
            length 
                Event_Label $100.
                Form_Name_&ver $50.
                Form_Name_root $50.
                Form_Label $500.
                Publish_Type $50.
                Planned_Optional $50.
                Restricted $10.
                pScript_Name $100.
                ;
            Event_Label = compress(A,,'kw');
            Form_Name_&ver = compress(B,,"kw");
            Form_Label = strip(compress(C,,'kw'));
            Publish_Type = D;
            Planned_Optional = E;
            Restricted  = F;
            pScript_Name = G;

            if prxmatch('/\_\d$/',strip(Form_Name_&ver)) > 0  then form_name_root = substr(form_name_&ver,1,length(Form_Name_&ver)-2);
            else form_name_root = strip(Form_Name_&ver);

            drop a b c d e f g;

        run;

        proc sort data=&sdscr_tempLib..evt&ver.a nodupkey;
            by form_label;
        run;
        
        proc sql;
            create table &sdscr_tempLib..evt&ver.b as
            select distinct form_label, Form_Name_&ver, form_name_root
            from &sdscr_tempLib..evt&ver.a
            ;
        quit;

        
        /* CHECK IMPORT OF EVENT STRUCTURE */
        %let countevt&ver = 0;
        proc sql noprint;
            select count(*) into: countevt&ver
            from &sdscr_tempLib..evt&ver.b
            ;
        quit;
        %if %eval(&countevt&ver = 0) %then %do;
            x "echo [GMSDSCOMPAREREPORT] -- Unable to read Event Structure from SDS&ver";
            %gmMessage( codeLocation = gmSdsCompareReport/Read Event Structure Tab
                    , linesOut     = %str(Unable to read Event Structure from SDS&ver
                                          @Please ensure that file is a valid SDS file saved as .XLSX)
                    , selectType   = ABORT
                    );
        %end;

        

        
        /* MERGE FORM STRUCTURE AND EVENT STRUCTURE */
        data &sdscr_tempLib..fs&ver.b;
            length form_name_&ver form_name_root $50. form_label $500.;
            merge &sdscr_tempLib..fs&ver.a (in=a) &sdscr_tempLib..evt&ver.b;
            by form_label;

            if a;
        run;

        proc sort data=&sdscr_tempLib..fs&ver.b
                  out=&sdscr_tempLib..fs&ver nodupkey dupout=&sdscr_tempLib.._check0_&ver;
            by form_name_root item_name question_prompt&ver Form_Name_&ver;
        run;
        
        /* CREATE DATA CHECK DATASETS */
        data &sdscr_tempLib.._check0_&ver;
            set &sdscr_tempLib.._check0_&ver;
            if item_name ne "Table Prompt";
        run;

        proc sql noprint;
            create table &sdscr_tempLib.._check1_&ver as
            select form_label, count(*) as n
            from &sdscr_tempLib..fs&ver
            where form_name_root = "" and form_label ne "Date of Visit"
            group by form_label
            ;
        quit;
        
    %mend sdscomparereport_get_formstruct;


/*******************************************************************************
* FORM STRUCTURE: INPUT FORM STRUCTURE TAB
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] Read Form Structure";
    %gmMessage( codeLocation = gmSdsCompareReport/Form Structure
            , linesOut     = %str(Reading Form Structure Tab of &filesdsbase)
            , selectType   = N
            );


    %sdscomparereport_get_formstruct(&pathIn./&fileSdsBase,1);
  
  
    %gmMessage( codeLocation = gmSdsCompareReport/Read Form Structure Tab
            , linesOut     = %str(Reading Form Structure Tab of &filesdscompare)
            , selectType   = N
            );

  
    %sdscomparereport_get_formstruct(&pathIn./&fileSdsCompare,2);

    

/*******************************************************************************
* FORM STRUCTURE: COMBINE DATA
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Merge Form Structure Data";
    %gmMessage( codeLocation = gmSdsCompareReport/Form Structure
            , linesOut     = %str(Merge data from SDS1 and SDS2)
            , selectType   = N
            );

    * GET LIST OF FORMS FROM SDS2;
    proc sql;
        create table &sdscr_tempLib..form_name_2_list as
        select distinct form_name_2, form_name_root
        from &sdscr_tempLib..fs2
        where form_name_root in (select distinct form_name_root from &sdscr_tempLib..fs1)
            and form_name_2 ne "";
        ;
    quit;

    * LOOP THROUGH EACH FORM AND JOIN WITH FORM FROM SDS1;
    data &sdscr_tempLib..form_name_2_list;
        set &sdscr_tempLib..form_name_2_list;
        n = _n_;
        call symput('n_forms',strip(put(_n_,best.)));
    run;

    %do i=1 %to &n_forms;
        data _null_;
            set &sdscr_tempLib..form_name_2_list (where=(n=&i));
            call symput('iformname',strip(form_name_2));

            call symput('iformnameroot',strip(form_name_root));
        run;
        %put NOTE:[PXL] &i form = &iformname (&iformnameroot);

        data &sdscr_tempLib..f&i;
            merge &sdscr_tempLib..fs2 (where=(form_name_2="&iformname" and item_name not in ("InfoTag","Table Prompt")) in=a)
                  &sdscr_tempLib..fs1 (where=(form_name_root = "&iformnameroot" and item_name not in ("InfoTag","Table Prompt")) in=b)
                ;
            by form_name_root item_name;
            form_name_2 = "&iformname";
            in2 = a;
            in1 = b;
        run;

        %if %eval(&i=1) %then %do;
            data &sdscr_tempLib..f_all;
                set &sdscr_tempLib..f1;
            run;
        %end;
        %else %do;
            proc append base=&sdscr_tempLib..f_all data=&sdscr_tempLib..f&i;
            run;
        %end;
        
        proc sql;
            drop table &sdscr_tempLib..f&i;
        quit;
    %end;

    proc sort data=&sdscr_tempLib..f_all out=&sdscr_tempLib..fs_both;
        by form_name_root form_name_2 item_name;
    run;




/*******************************************************************************
* FORM STRUCTURE: CHECKS
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Perform Form Structure Checks";
    %gmMessage( codeLocation = gmSdsCompareReport/Form Structure
            , linesOut     = %str(Perform Checks)
            , selectType   = N
            );

    * create flag for entire form being present;
    proc sql;
        create table &sdscr_tempLib..fs_form_name_check as
        select form_name_root, max(in1) as maxin1, max(in2) as maxin2
        from &sdscr_tempLib..fs_both
        group by form_name_root
        ;
    quit;

    * merge full list and codelist flags, output difference list;
    data &sdscr_tempLib..fs_both2;
        merge &sdscr_tempLib..fs_both &sdscr_tempLib..fs_form_name_check;
        by form_name_root;
    run;


    * create holder dataset for output;
    data &sdscr_tempLib..fs_report;
        length form_root sds1form sds2form $500. order1 order2 8. issuename issue1item issue2item $500.;
        form_root = "";
        sds1form = "";
        sds2form = "";
        order1 = .;
        order2 = .;
        issuename = "";
        issue1item = "";
        issue2item = "";
        delete;
    run;

    
    proc sql;
        * 1. forms not found in event structure;
        insert into &sdscr_tempLib..fs_report
            select 
                "" as form_root
                ,form_label as sds1form
                ,"" as sds2form
                ,1 as order1
                ,1 as order2
                ,"Form not found in Event Structure. Ensure that Form Label in Form Structure tab (Col A) matches Form Label in Event Structure tab (Col C)." as issuename
                ,form_label as issue1item
                ,"" as issue2item
            from &sdscr_tempLib.._check1_1
            ;

        insert into &sdscr_tempLib..fs_report
            select 
                "" as form_root
                ,"" as sds1form
                ,form_label as sds2form
                ,1 as order1
                ,2 as order2
                ,"Form not found in Event Structure. Ensure that Form Label in Form Structure tab (Col A) matches Form Label in Event Structure tab (Col C)." as issuename
                ,"" as issue1item
                ,form_label as issue2item
            from &sdscr_tempLib.._check1_2
        ;

        * 2. DUPLICATE ITEMS FOUND;
        insert into &sdscr_tempLib..fs_report
            select 
                "" as form_root
                ,form_label as sds1form
                ,"" as sds2form
                ,2 as order1
                ,1 as order2
                ,"Duplicate Item Found" as issuename
                ,compress(item_name,,'kw') as issue1item
                ,"" as issue2item
            from &sdscr_tempLib.._check0_1
            where form_label not in (select form_label from &sdscr_tempLib.._check1_1)
        ;

        insert into &sdscr_tempLib..fs_report
            select 
                "" as form_root
                ,"" as sds1form
                ,form_label as sds2form
                ,2 as order1
                ,2 as order2
                ,"Duplicate Item Found" as issuename
                ,"" as issue1item
                ,compress(item_name,,'kw') as issue2item
            from &sdscr_tempLib.._check0_2
            where form_label not in (select form_label from &sdscr_tempLib.._check1_2)
        ;


        * 3. FORMS IN ONE BUT NOT THE OTHER;
        insert into &sdscr_tempLib..fs_report
            select distinct
                form_name_root as form_root
                ,form_name_1 as sds1form
                ,form_name_2 as sds2form
                ,3 as order1
                ,. as order2
                ,"Form not found in both SDS files" as issuename
                ,form_name_1 as issue1item
                ,form_name_2 as issue2item
            from &sdscr_tempLib..fs_both2
            where maxin1 ne maxin2
        ;


        * 4. ITEMS IN ONE BUT NOT THE OTHER;
        insert into &sdscr_tempLib..fs_report
            select distinct
                form_name_root as form_root
                ,form_name_1 as sds1form
                ,form_name_2 as sds2form
                ,4 as order1
                ,. as order2
                ,"Item found in SDS1 and not SDS2" as issuename
                ,strip(compress(item_name,,'kw')) as issue1item
                ,"" as issue2item
            from &sdscr_tempLib..fs_both2
            where maxin1 = maxin2 AND in1 and not in2
        ;

        insert into &sdscr_tempLib..fs_report
            select distinct
                form_name_root as form_root
                ,form_name_1 as sds1form
                ,form_name_2 as sds2form
                ,4 as order1
                ,. as order2
                ,"Item found SDS2 and not SDS1" as issuename
                ,"" as issue1item
                ,strip(compress(item_name,,'kw')) as issue2item
            from &sdscr_tempLib..fs_both2
            where maxin1 = maxin2 AND in2 and not in1
        ;

        * 5. ITEM ATTRIBUTE DIFFERENCES;
        %do v=&fs_minitem %to &fs_maxitem;
            insert into &sdscr_tempLib..fs_report
                select distinct
                    form_name_root as form_root
                    ,form_name_1 as sas1form
                    ,form_name_2 as sds2form
                    ,5 as order1
                    ,&v as order2
                    ,"Form Item " || strip(item_name) || " &&&fs_item&v differs" as issuename
                    ,strip(compress(%str(&&&fs_field&v)1,,'kw')) as issue1item
                    ,strip(compress(%str(&&&fs_field&v)2,,'kw')) as issue2item
                from &sdscr_tempLib..fs_both2
                where maxin1 = maxin2 AND in1 = in2 
                    and compress(strip(%str(&&&fs_field&v)1),,'kw') ne compress(strip(%str(&&&fs_field&v)2),,'kw')
            ;
        %end;
        
    quit;

    
/*******************************************************************************
* FORM STRUCTURE: CREATE REPORT DATASET
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Create Form Structure Report Dataset";
    %gmMessage( codeLocation = gmSdsCompareReport/Form Structure
            , linesOut     = %str(Create report dataset)
            , selectType   = N
            );


    proc sql;
        create table &sdscr_tempLib..fs_form_counts as
        select distinct form_name_root as form_root length=500
                    , form_name_2 as sds2form length=500
                    , max(form_name_1) as sds1form length=500
        from &sdscr_tempLib..fs_both2
        group by form_name_root, form_name_2
        ;
        
        create table &sdscr_tempLib..fs_report_counts as
        select distinct form_root length=500, sds2form length=500, count(*) as total_issues
        from &sdscr_tempLib..fs_report
        where form_root ne ""
        group by form_root, sds2form
        ;
        
        create table &sdscr_tempLib..fs_report_header_counts as
        select distinct form_root  length=500, "" as sds2form length=500, count(*) as total_issues
        from &sdscr_tempLib..fs_report
        where form_root = ""
        group by form_root
        ;
    quit;

    data &sdscr_tempLib..fs_report_allcounts;
        merge   &sdscr_tempLib..fs_form_counts 
                &sdscr_tempLib..fs_report_counts 
                &sdscr_tempLib..fs_report_header_counts
                ;
        by form_root sds2form;
        if total_issues = . then total_issues = 0;
        order1 = 0;
        order2 = 0;
    run;

    data &sdscr_tempLib..fs_report2;
        set &sdscr_tempLib..fs_report_allcounts 
            &sdscr_tempLib..fs_report
            ;
    run;
    
    proc sort data=&sdscr_tempLib..fs_report2;
        by form_root sds2form order1 order2;
    run;

    data &sdscr_tempLib..fs_report3;
        set &sdscr_tempLib..fs_report2;
        by form_root sds2form;
        if form_root ne "" and not first.sds2form then do;
            sds1form = "";
            sds2form = "";
        end;
        length totalissues $10. col3 col4 col5 col6 col7 $100.;
        if total_issues ne . then totalissues = strip(put(total_issues,best.));
        else totalissues = "";
        col3 = "";
        col4 = "";
        col5 = "";
        col6 = "";
        col7 = "";
    run;

    proc sql noprint;
        select count(distinct form_name_2) into:_n_total_forms2
        from &sdscr_tempLib..fs2
        where form_name_2 ne ""
        ;

        select count(distinct form_name_1) into:_n_total_forms1
        from &sdscr_tempLib..fs1
        where form_name_1 ne ""
        ;

        select count(*) into:_n_total_items1
        from &sdscr_tempLib..fs_both2
        where in1
        ;

        select count(*) into:_n_total_items2
        from &sdscr_tempLib..fs_both2
        where in2
        ;

        select sum(total_issues) into:_n_total_issues
        from &sdscr_tempLib..fs_report3
        where order1 ge 0
        ;

        insert into &sdscr_tempLib..fs_report3 (sds1form,sds2form,order1,issuename)
            values 
                ("&fileSdsBase"
                ,"&fileSdsCompare"
                ,-1
                ,"Form Name"
                )
        ;

        insert into &sdscr_tempLib..fs_report3 (sds1form,sds2form,order1,order2,issuename)
            values 
                ("&_n_total_forms1"
                ,"&_n_total_forms2"
                ,-2
                ,1
                ,"Total Forms"
                )
        ;
        
        insert into &sdscr_tempLib..fs_report3 (sds1form,sds2form,order1,order2,issuename)
            values 
                ("&_n_total_items1"
                ,"&_n_total_items2"
                ,-2
                ,2
                ,"Total Items"
                )
        ;
        
        insert into &sdscr_tempLib..fs_report3 (totalissues,order1,order2,issuename)
            values 
                ("&_n_total_issues"
                ,-2
                ,3
                ,"Total Issues"
                )
        ;

    quit;


    x "echo [GMSDSCOMPAREREPORT] -- Total Form Structure Issues: &_n_total_issues";
    %gmMessage( codeLocation = gmSdsCompareReport/Form Structure
            , linesOut     = %str(Form Structure Comparison Summary
                                  @total forms 1 = %trim(%left(&_n_total_forms1))
                                  @total forms 2 = %trim(%left(&_n_total_forms2))
                                  @total items 1 = %trim(%left(&_n_total_items1))
                                  @total items 2 = %trim(%left(&_n_total_items2))
                                  @total form structure issues  = %trim(%left(&_n_total_issues))
                                  )
            , selectType   = N
            );

    
/*******************************************************************************
* CODELISTS: DEFINE MACRO TO READ CODELIST TAB OF SDS FILE
*******************************************************************************/
    %macro sdscomparereport_get_codelist(file,ver);

        proc import out=&sdscr_tempLib..cdl&ver
                    datafile="&file"
                    dbms=xlsx
                    replace
                    ;
            sheet="Codelists";
            getnames=no;
        run;

        data &sdscr_tempLib..cdl&ver.a;
            length  Code_List $100. Entry_Prefix&ver $50.
                    Code_Label&ver $150. Code_Value $50.;
            set &sdscr_tempLib..cdl&ver;
            if _n_ > 1 and compress(A,,"npk") ne "";
            Code_List = compress(A,,"kw");
            Entry_Prefix&ver = compress(B,,"kw");
            Code_Label&ver = compress(C,,"kw");
            Code_Value = compress(D,,"kw");

            drop A B C D;
        run;

        proc sort data=&sdscr_tempLib..cdl&ver.a nodupkey;
            by code_list code_value;
        run;

    %mend sdscomparereport_get_codelist;

/*******************************************************************************
* CODELISTS: INPUT CODELIST TAB
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] Codelists";
    %gmMessage( codeLocation = gmSdsCompareReport/Codelists
            , linesOut     = %str(Reading Form Codelist Tab of &filesdsbase)
            , selectType   = N
            );

    %sdscomparereport_get_codelist(&pathIn./&fileSdsBase,1);
    
    
    %gmMessage( codeLocation = gmSdsCompareReport/Codelists
            , linesOut     = %str(Reading Form Codelist Tab of &filesdscompare)
            , selectType   = N
            );
    
    %sdscomparereport_get_codelist(&pathIn./&fileSdsCompare,2);

  
/*******************************************************************************
* CODELISTS: CHECK THAT IMPORT SUCCEEDED
*******************************************************************************/
    %let count1 = 0;
    %let count2 = 0;
  
    proc sql noprint;
        select count(*) into: count1
        from &sdscr_tempLib..cdl1a
        ;

        select count(*) into: count2
        from &sdscr_tempLib..cdl2a
        ;
    quit;
  
    %if %eval(&count1 = 0) %then %do;
        %gmMessage( codeLocation = gmSdsCompareReport/Codelist
                , linesOut     = %str(Unable to read Codelist Tab from &fileSdsBase
                                      @Please ensure that file is a valid SDS file saved as .XLSX)
                , selectType   = ABORT
                );
    %end;

    %if %eval(&count2 = 0) %then %do;
        %gmMessage( codeLocation = gmSdsCompareReport/Codelist
                , linesOut     = %str(Unable to read Codelist Tab from &fileSdsCompare
                                      @Please ensure that file is a valid SDS file saved as .XLSX)
                , selectType   = ABORT
                );
    %end;


/*******************************************************************************
* CODELISTS: COMBINE DATA
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Combine Codelist Datasets";
    %gmMessage( codeLocation = gmSdsCompareReport/Codelist
            , linesOut     = %str(Merge data from SDS1 and SDS2)
            , selectType   = N
            );

    data &sdscr_tempLib..cdl_both;
        length code_list codelist1 codelist2 $100.;
        merge &sdscr_tempLib..cdl1a (in=a) &sdscr_tempLib..cdl2a (in=b);
        by code_list code_value;
        in1 = a;
        in2 = b;
        if a then codelist1 = code_list;
        if b then codelist2 = code_list;
    run;

    * create flag for entire code list being present;
    proc sql;
        create table &sdscr_tempLib..codelist_check as
        select code_list, max(in1) as maxin1, max(in2) as maxin2
        from &sdscr_tempLib..cdl_both
        group by code_list
        ;
    quit;

    * merge full list and codelist flags, output difference list;
    data &sdscr_tempLib..cdl_both2;
        merge &sdscr_tempLib..cdl_both &sdscr_tempLib..codelist_check;
        by code_list;
    run;


/*******************************************************************************
* CODELISTS: CHECKS
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Perform Codelist Checks";
    %gmMessage( codeLocation = gmSdsCompareReport/Codelist
            , linesOut     = %str(Perform Checks)
            , selectType   = N
            );

    * create holder dataset for output;
    data &sdscr_tempLib..cdl_report;
        length code_list sds1codelist sds2codelist $500. order1 order2 8. 
                issuename issue1item issue2item $500.;
        code_list = "";
        sds1codelist = "";
        sds2codelist = "";
        order1 = .;
        order2 = .;
        issuename = "";
        issue1item = "";
        issue2item = "";
        delete;
    run;

    * 1. DUPLICATE CODE VALUES FOUND;
    proc sql;
        insert into &sdscr_tempLib..cdl_report
            select 
                code_list as form_root
                ,codelist1 as sds1codelist
                ,"" as sds2codelist
                ,1 as order1
                ,1 as order2
                ,"Duplicate Code Values Found in SDS1" as issuename
                ,compress(code_value,,'kw') as issue1item
                ,"" as issue2item
            from &sdscr_tempLib..cdl_both2
            where codelist1 ne ""
            group by code_list,code_value
            having count(*) > 1
        ;
        insert into &sdscr_tempLib..cdl_report
            select 
                code_list as form_root
                ,"" as sds1codelist
                ,codelist2 as sds2codelist
                ,1 as order1
                ,2 as order2
                ,"Duplicate Code Values Found in SDS2" as issuename
                ,"" as issue1item
                ,compress(code_value,,'kw') as issue2item
            from &sdscr_tempLib..cdl_both2
            where codelist2 ne ""
            group by code_list,code_value
            having count(*) > 1
        ;
    quit;

    * 2. CODELIST FOUND IN ONLY ONE SDS;
    proc sql;
        insert into &sdscr_tempLib..cdl_report
            select distinct
                code_list as form_root
                ,codelist1 as sds1codelist
                ,codelist2 as sds2codelist
                ,2 as order1
                ,1 as order2
                ,"Codelist found in only one SDS file" as issuename
                ,"" as issue1item
                ,"" as issue2item
            from &sdscr_tempLib..cdl_both2
            where maxin1 ne maxin2
        ;
    quit;


    * 3. CODE VALUE FOUND IN ONLY ONE SDS;
    proc sql;
        insert into &sdscr_tempLib..cdl_report
            select distinct
                code_list as form_root
                ,codelist1 as sds1codelist
                ,codelist2 as sds2codelist
                ,3 as order1
                ,1 as order2
                ,"Code Value found in SDS1 but not SDS2" as issuename
                ,code_value as issue1item
                ,"" as issue2item
            from &sdscr_tempLib..cdl_both2
            where maxin1 = maxin2 and in1 and not in2
        ;
        insert into &sdscr_tempLib..cdl_report
            select distinct
                code_list as form_root
                ,codelist1 as sds1codelist
                ,codelist2 as sds2codelist
                ,3 as order1
                ,2 as order2
                ,"Code Value found in SDS2 but not SDS1" as issuename
                ,"" as issue1item
                ,code_value as issue2item
            from &sdscr_tempLib..cdl_both2
            where maxin1 = maxin2 and in2 and not in1
        ;
    quit;

    * 4. CODE LABEL DIFFERS;
    proc sql;
        insert into &sdscr_tempLib..cdl_report
            select distinct
                code_list as form_root
                ,strip(codelist1) || " - " || strip(code_value) as sds1codelist
                ,strip(codelist2) || " - " || strip(code_value) as sds2codelist
                ,4 as order1
                ,1 as order2
                ,"Code Label differs between SDS1 and SDS2" as issuename
                ,code_label1 as issue1item
                ,code_label2 as issue2item
            from &sdscr_tempLib..cdl_both2
            where maxin1 = maxin2 and in1 and in2 and code_label1 ne code_label2
        ;
    quit;
    * 5. CODE ENTRY PREFIX DIFFERS;
    proc sql;
        insert into &sdscr_tempLib..cdl_report
            select distinct
                code_list as form_root
                ,strip(codelist1) || " - " || strip(code_value) as sds1codelist
                ,strip(codelist2) || " - " || strip(code_value) as sds2codelist
                ,5 as order1
                ,1 as order2
                ,"Code Entry Prefix differs between SDS1 and SDS2" as issuename
                ,entry_prefix1 as issue1item
                ,entry_prefix2 as issue2item
            from &sdscr_tempLib..cdl_both2
            where maxin1 = maxin2 and in1 and in2 and entry_prefix1 ne entry_prefix2
        ;
    quit;

/*******************************************************************************
* CODELISTS: CREATE REPORT DATASET
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Create Codelist Report Dataset";
    %gmMessage( codeLocation = gmSdsCompareReport/Codelist
            , linesOut     = %str(Create report dataset)
            , selectType   = N
            );

    * get list of all codelists for output;
    proc sql;
        create table &sdscr_tempLib..cdl_codelists as
        select distinct code_list length=500
        from &sdscr_tempLib..cdl_both2
        ;

        create table &sdscr_tempLib..cdl_issue_count as
        select code_list length=500, count(*) as total_issues
        from &sdscr_tempLib..cdl_report
        where code_list ne ""
        group by code_list
        ;
    quit;

    data &sdscr_tempLib..cdl_report_allcounts;
        merge &sdscr_tempLib..cdl_codelists &sdscr_tempLib..cdl_issue_count;
        by code_list;
        if total_issues = . then total_issues = 0;
        order1 = 0;
        order2 = 0;
    run;

    data &sdscr_tempLib..cdl_report2;
        set &sdscr_tempLib..cdl_report_allcounts &sdscr_tempLib..cdl_report;
    run;

    proc sort data=&sdscr_tempLib..cdl_report2;
        by code_list order1 order2;
    run;

    data &sdscr_tempLib..cdl_report3;
        set &sdscr_tempLib..cdl_report2;
        by code_list;
        if code_list ne "" and not first.code_list then do;
            code_list = "";
        end;
        length totalissues $10. col3 col4 col5 col6 col7 $100.;
        if total_issues ne . then totalissues = strip(put(total_issues,best.));
        else totalissues = "";
        col3 = "";
        col4 = "";
        col5 = "";
        col6 = "";
        col7 = "";
    run;

    proc sql noprint;
        select count(distinct codelist2) into:_n_codelist2
        from &sdscr_tempLib..cdl_both2
        where codelist2 ne ""
        ;

        select count(distinct codelist1) into:_n_codelist1
        from &sdscr_tempLib..cdl_both2
        where codelist2 ne ""
        ;

        select count(*) into:_n_codevalues1
        from &sdscr_tempLib..cdl_both2
        where in1
        ;

        select count(*) into:_n_codevalues2
        from &sdscr_tempLib..cdl_both2
        where in2
        ;

        select sum(total_issues) into:_n_total_cdlissues
        from &sdscr_tempLib..cdl_report3
        where order1 ge 0
        ;


        insert into &sdscr_tempLib..cdl_report3 (sds1codelist,sds2codelist,order1,issuename)
            values 
                ("&fileSdsBase"
                ,"&fileSdsCompare"
                ,-1
                ,"Form Name"
                )
        ;

        insert into &sdscr_tempLib..cdl_report3 (sds1codelist,sds2codelist,order1,order2,issuename)
            values 
                ("&_n_codelist1"
                ,"&_n_codelist2"
                ,-2
                ,1
                ,"Total Codelists"
                )
        ;
        
        insert into &sdscr_tempLib..cdl_report3 (sds1codelist,sds2codelist,order1,order2,issuename)
            values 
                ("&_n_codevalues1"
                ,"&_n_codevalues2"
                ,-2
                ,2
                ,"Total Code Values"
                )
        ;
        
        insert into &sdscr_tempLib..cdl_report3 (totalissues,order1,order2,issuename)
            values 
                ("&_n_total_cdlissues"
                ,-2
                ,3
                ,"Total Issues"
                )
        ;

    quit;


    
    x "echo [GMSDSCOMPAREREPORT] -- Total Codelist Issues: &_n_total_cdlissues";
    %gmMessage( codeLocation = gmSdsCompareReport/Codelist
            , linesOut     = %str(Codelist Comparison Summary
                                  @total code lists 1 = %trim(%left(&_n_codelist1))
                                  @total code lists 2 = %trim(%left(&_n_codelist2))
                                  @total code values 1 = %trim(%left(&_n_codevalues1))
                                  @total code values 2 = %trim(%left(&_n_codevalues2))
                                  @total codelist issues  = %trim(%left(&_n_total_cdlissues))
                                  )
            , selectType   = N
            );





  
/*******************************************************************************
* REPORT GLOBAL SETP
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] Generate Report";
    %gmMessage( codeLocation = gmSdsCompareReport/Report Creation
            , linesOut     = %str(Create Report File)
            , selectType   = N
            );
    
    * Set file name as xls even though tagsets.excelxp creates an XML doc;
    ods listing close;

    ods tagsets.excelxp file= "&pathIn./&fileOut";

  
/*******************************************************************************
* FORM STRUCTURE: CREATE REPORT
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Form Structure Report";
    %gmMessage( codeLocation = gmSdsCompareReport/Report Creation
            , linesOut     = %str(Output Form Structure Report)
            , selectType   = N
            );
    
    ods tagsets.excelxp options (
              Orientation = "landscape"
              Embedded_Titles = "Yes"
              Row_Repeat = "Header"
              Autofit_Height = "Yes"
              Gridlines = "Yes"
              Zoom = "70"
              frozen_headers = "16"
              row_repeat = "4"
              sheet_interval='none'
              
              sheet_name = "Form Structure Tab Results"
          );

    * GLOBAL FOOTERS;
    footnote1 j=l "PAREXEL International Confidential";
    footnote2 j=l "Produced by %upcase(&sysuserid) on &sysdate9";


    * GLOBAL HEADERS;
    title;
    title1 justify=left "SDS Comparison Report";
    title2 j=l "SDS File 1: &pathIn./&fileSdsBase";
    title3 j=l "SDS File 2: &pathIn./&fileSdsCompare";
    title4 j=l " ";


    * FILE DETAIL SECTION;
    title5 j=l "Form Structure Comparison Summary";

    proc report data=&sdscr_tempLib..fs_report3 (where=(order1 < 0)) 
                style(column)={tagattr='Format:Text'} split="@";
        columns sds1form sds2form totalissues issuename 
              issue1item issue2item
              col3 col4 col5
              col6 col7;
        define sds1form / display "SDS1 Form" width=20;
        define sds2form / display "SDS2 Form" width=20;
        define totalissues / display "" width=5 center;
        define issuename / display "Description" width=40;
        define issue1item / display "" width=20;
        define issue2item / display "" width=20;
        define col3    / display "" width=20;
        define col4    / display "" width=10;
        define col5    / display "" width=10;
        define col6    / display "" width=10;
        define col7    / display "" width=10;

        compute totalissues; 
            if input(totalissues,best.) > 0 then
                call define(_row_,"style","style={background=verylightred}");
            if input(totalissues,best.) = 0 then
                call define(_row_,"style","style={background=verylightblue}");
        endcomp;                
    run;

    title1 j=left "Form Structure Comparison Details";

    proc report data=&sdscr_tempLib..fs_report3 (where=(order1 ge 0)) 
                style(column)={tagattr='Format:Text'} split="@";
        columns sds1form sds2form totalissues issuename 
              ("Item" issue1item issue2item) 
              ("CDA Review" col3 col4 col5) 
              ("PDS Review" col6 col7);
        define sds1form / display "SDS1 Form" width=20;
        define sds2form / display "SDS2 Form" width=20;
        define totalissues / display "Total@Issues@Found" width=5 center;
        define issuename / display "Issue Name" width=40;
        define issue1item / display "SDS 1 Item Value" width=20;
        define issue2item / display "SDS 2 Item Value" width=20;
        define col3    / display "Comments" width=20;
        define col4    / display "Reviewer@Name" width=10;
        define col5    / display "Review@Date" width=10;
        define col6    / display "Approver@Name" width=10;
        define col7    / display "Approval@Date" width=10;

        compute totalissues; 
            if input(totalissues,best.) > 0 then
                call define(_row_,"style","style={background=verylightred}");
            if input(totalissues,best.) = 0 then
                call define(_row_,"style","style={background=verylightblue}");
        endcomp;                
    run;

            
/*******************************************************************************
* CODELIST: CREATE REPORT
*******************************************************************************/
    x "echo [GMSDSCOMPAREREPORT] -- Codelist Report";
    %gmMessage( codeLocation = gmSdsCompareReport/Report Creation
            , linesOut     = %str(Output Codelist Report)
            , selectType   = N
            );
    

    ods tagsets.excelxp options (
              Orientation = "landscape"
              Embedded_Titles = "Yes"
              Row_Repeat = "Header"
              Autofit_Height = "Yes"
              Gridlines = "Yes"
              Zoom = "70"
              frozen_headers = "16"
              row_repeat = "4"
              sheet_interval='none'
              
              sheet_name = "Codelist Tab Results"
          );

    * GLOBAL FOOTERS;
    footnote1 j=l "PAREXEL International Confidential";
    footnote2 j=l "Produced by %upcase(&sysuserid) on &sysdate9";


    * GLOBAL HEADERS;
    title;
    title1 justify=left "SDS Comparison Report";
    title2 j=l "SDS File 1: &pathIn./&fileSdsBase";
    title3 j=l "SDS File 2: &pathIn./&fileSdsCompare";
    title4 j=l " ";


    * FILE DETAIL SECTION;
    title5 j=l "Codelist Comparison Summary";

    proc report data=&sdscr_tempLib..cdl_report3 (where=(order1 < 0)) 
                style(column)={tagattr='Format:Text'} split="@";
        columns code_list sds1codelist sds2codelist totalissues issuename 
              issue1item issue2item
              col3 col4 col5
              col6 col7;
        define code_list / display "" width=20;
        define sds1codelist / display "SDS1 Form" width=20;
        define sds2codelist / display "SDS2 Form" width=20;
        define totalissues / display "" width=5 center;
        define issuename / display "Description" width=40;
        define issue1item / display "" width=20;
        define issue2item / display "" width=20;
        define col3    / display "" width=20;
        define col4    / display "" width=10;
        define col5    / display "" width=10;
        define col6    / display "" width=10;
        define col7    / display "" width=10;

        compute totalissues; 
            if input(totalissues,best.) > 0 then
                call define(_row_,"style","style={background=verylightred}");
            if input(totalissues,best.) = 0 then
                call define(_row_,"style","style={background=verylightblue}");
        endcomp;                
    run;

    title1 j=left "Codelist Comparison Details";

    proc report data=&sdscr_tempLib..cdl_report3 (where=(order1 ge 0)) 
              style(column)={tagattr='Format:Text'} split="@";
        columns code_list sds1codelist sds2codelist totalissues issuename 
              ("Item" issue1item issue2item) 
              ("CDA Review" col3 col4 col5) 
              ("PDS Review" col6 col7);
        define code_list / display "Codelist" width=20;
        define sds1codelist / display "SDS1 Codelist" width=20;
        define sds2codelist / display "SDS2 Codelist" width=20;
        define totalissues / display "Total@Issues@Found" width=5 center;
        define issuename / display "Issue Name" width=40;
        define issue1item / display "SDS 1 Code Value" width=20;
        define issue2item / display "SDS 2 Code Value" width=20;
        define col3    / display "Comments" width=20;
        define col4    / display "Reviewer@Name" width=10;
        define col5    / display "Review@Date" width=10;
        define col6    / display "Approver@Name" width=10;
        define col7    / display "Approval@Date" width=10;

        compute totalissues; 
            if input(totalissues,best.) > 0 then
                call define(_row_,"style","style={background=verylightred}");
            if input(totalissues,best.) = 0 then
                call define(_row_,"style","style={background=verylightblue}");
        endcomp;                
    run;


   
/*******************************************************************************
* END REPORT
*******************************************************************************/
    
    ods tagsets.excelxp close;
    ods listing;
    
    title;
    footnote;

  
/*******************************************************************************
* END MACRO
*******************************************************************************/

    x "echo [GMSDSCOMPAREREPORT] End of Macro";
%gmEnd(headURL=$HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/macro_library/gmsdscomparereport.sas $);


    
%mend gmsdscomparereport;

