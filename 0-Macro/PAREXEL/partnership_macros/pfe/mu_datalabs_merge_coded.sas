  /*-----------------------------------------------------------------------------<
  PAREXEL INTERNATIONAL LTD
  
  Sponsor / Protocol No: PFE / Macro and Application Development committee
  PXL Study Code:        N/A - Data Exchange Team for Pfizer Partnership
  
  SAS Version:           9.2 and above
  Operating System:      UNIX
  
  -------------------------------------------------------------------------------
   
  Author:                Nathan Hartley $LastChangedBy: hartlen $
  Creation Date:         20150822       $LastChangedDate: 2016-09-30 10:56:25 -0400 (Fri, 30 Sep 2016) $
  
  Program Location/Name: $HeadURL: http://kennet.na.pxl.int:7070/svnrepo/LP_BLINDED_GLOBALMACROLIBARY_STATS/partnership_macros/pfe/mu_datalabs_merge_coded.sas $
  
  Files Created:         1) Updates download SAS dataset<br />
                         2) Creates PDF listing of special characters in coding term(s) if exist<br />

  Program Purpose:       1) Merge coded terms from ASCII text file to their corresponding SAS Dataset, for DataLabs studies only <br/>
                         2) Create PDF listings if special characters found in coding terms (prevents appended coding data)<br />
                         <br /><br />
                         Example Call: %mu_datalabs_merge_coded(&path_ascii_file, AE, AETERM);

                         This macro is PAREXEL's intellectual property and shall
                         not be used outside of contractual obligations without
                         written consent from PAREXEL's senior management.
  
  Macro Parameters:
  
    Name:                path_ascii_file
      Allowed Values:    UNIX path
      Default Value:     null
      Description:       UNIX path for source and output SAS dataset, should point to 
                         /projects/pfizrNNNNNN/dm/datasets/download/zip/prod/YYYYMMDD

    Name:                data_and_ascii_file_name
      Allowed Values:    SAS dataset name
      Default Value:     null
      Description:       SAS dataset that contains coded term

    Name:                var_terms
      Allowed Values:    List of variable names seperated by a space
      Default Value:     null
      Description:       List of coded var_terms

    Name:                lib_download
      Allowed Values:    SAS library
      Default Value:     download
      Description:       SAS library that contains the data_and_ascii_file_name dataset

    Name:                path_listings_out
      Allowed Values:    UNIX path
      Default Value:     null
      Description:       UNIX path to output listing for special char if found, 
                         if null will try use global macro path_listings

    Name:                path_metadata
      Allowed Values:    UNIX path
      Default Value:     /projects/std_pfizer/sponsor/data/dictionaries/current
      Description:       UNIX path to MEDDRA_REPORTING.dat file                         

  -------------------------------------------------------------------------------
  MODIFICATION HISTORY: Subversion $Rev: 2676 $
  --------------------------------------------------------------------------------

    Version: V1.0 Date: 20151202 Author: Nathan Hartley
        1) Initial Version  
        
    Version: v1.1 Date: 20151105 Author: Berlie Manual
        1) Added Read MEDDRA_REPORTING.dat for MEDDRA data
           
    Version: v2.0 Date: 20160107 Author: Nathan Hartley
        1) Updated to MAN85 logic and attrib corrects

    Version: v3.0 Date: 20160930 Author: Nathan Johnson
        1) Read in data from WHODRUG dictionary DAT file
        2) Merge coded terms from MEDDRA or WHODRUG DAT files
  -----------------------------------------------------------------------------*/

%macro mu_datalabs_merge_coded(
    path_ascii_file,
    data_and_ascii_file_name,
    var_terms,
    lib_download=download,
    path_listings_out=null,
    path_metadata=/projects/std_pfizer/sponsor/data/dictionaries/current);
	
    %let merge_coded_macro_name = MU_DATALABS_MERGE_CODED;
    %let merge_coded_macro_version = 3.0;
    %let merge_coded_macro_version_Date = 20160930;
    %let merge_coded_macro_path = /opt/pxlcommon/stats/macros/partnership_macros/pfe;
    %let merge_coded_macro_RunDateTime = %sysfunc(compress(%sysfunc(left(%sysfunc(datetime(), IS8601DT.))), '-:'));
    %let merge_coded_macro_output = ; * Log note for end of macro run status;

    options noquotelenmax; * Ignore macro variables longer than 256 char;
    options missing="";

    %let total=0;

    %put INFO:[PXL]----------------------------------------------;
    %put INFO:[PXL] &merge_coded_macro_name: Macro Started; 
    %put INFO:[PXL] File Location: &merge_coded_macro_path ;
    %put INFO:[PXL] Version Number: &merge_coded_macro_version ;
    %put INFO:[PXL] Version Date: &merge_coded_macro_version_Date ;
    %put INFO:[PXL] Run DateTime: &merge_coded_macro_RunDateTime;          
    %put INFO:[PXL] ;
    %put INFO:[PXL] Purpose: Merge coded terms from ASCII text file to their corresponding SAS Dataset ;           
    %put INFO:[PXL] Input Parameters:;
    %put INFO:[PXL]     1) path_ascii_file = &path_ascii_file;
    %put INFO:[PXL]     2) data_and_ascii_file_name = &data_and_ascii_file_name;
    %put INFO:[PXL]     3) var_terms = &var_terms;
    %put INFO:[PXL]     4) lib_download = &lib_download;
    %put INFO:[PXL]     5) path_listings_out = &path_listings_out;
    %put INFO:[PXL]     6) path_metadata = &path_metadata;  
    %put INFO:[PXL]----------------------------------------------;  

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Verify Input Parameters;
    %put NOTE:[PXL] ***********************************************************************;

        %put NOTE:[PXL] 1) Check Global MAD macro DEBUG (option statement);
            proc sql noprint;
                select count(*) into: _DEBUG_Exist
                from sashelp.vmacro
                where scope='GLOBAL'
                      and name='DEBUG';
            quit;
            %if &_DEBUG_Exist = 0 %then %do;
                * MAD macro DEBUG does not exist, create and set to 0;
                %global DEBUG;
                %let DEBUG=0;
            %end;
            %else %do;
                %if &DEBUG=0 %then %do;
                    OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN;
                    %* OPTION NOMPRINT NOMLOGIC NOSYMBOLGEN NOSOURCE NONOTES;
                %end;
                %else %do;
                    OPTION MPRINT MLOGIC SYMBOLGEN SOURCE NOTES;
                %end;
            %end;

        %put NOTE:[PXL] 2) Check Global MAD macro GMPXLERR (unsucessiful execution flag);
            proc sql noprint;
                select count(*) into: _GMPXLERR_Exist
                from sashelp.vmacro
                where scope='GLOBAL'
                      and name='GMPXLERR';
            quit;
            %if &_GMPXLERR_Exist = 0 %then %do;
                * MAD macro GMPXLERR does not exist, create and set to 0;
                %global GMPXLERR;
                %let GMPXLERR=0;
            %end;
            %else %if &GMPXLERR = 1 %then %do;
                * Parent macro execution unsuccessful, goto end;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Global macro GMPXLERR = 1, macro not executed;
                %goto MacErr;
            %end;

        %put NOTE:[PXL] 3) Check Input Parameter path_ascii_file is a valid UNIX path;
            %if not %sysfunc(fileexist(&path_ascii_file)) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter path_ascii_file is not a valid directory: &path_ascii_file;
                %goto MacErr;           
            %end;  

        %put NOTE:[PXL] 4) Check Input Parameter lib_download is a valid SAS library;
            proc sql noprint;
                select count(*) into: exists
                from sashelp.vcolumn
                where libname = "%upcase(&lib_download)";
            quit; 
            %if %eval(&exists = 0) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter lib_download is not a valid SAS library: &lib_download;
                %goto MacErr;                 
            %end;

        %put NOTE:[PXL] 5) Check Input Parameter data_and_ascii_file_name is a valid SAS dataset within lib_download;
            proc sql noprint;
                select count(*) into: exists
                from sashelp.vcolumn
                where libname = "%upcase(&lib_download)"
                      and memname = "%upcase(&data_and_ascii_file_name)";
            quit; 
            %if %eval(&exists = 0) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter data_and_ascii_file_name is not a valid SAS dataset: &data_and_ascii_file_name;
                %goto MacErr;                 
            %end;            

        %put NOTE:[PXL] 6) Check Input Parameter data_and_ascii_file_name is a valid file as &path_ascii_file./evw_&data_and_ascii_file_name..txt;
            %if not %sysfunc(fileexist(&path_ascii_file./evw_&data_and_ascii_file_name..txt)) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input parameter data_and_ascii_file_name is not a valid file: &path_ascii_file./evw_&data_and_ascii_file_name..txt;
                %goto MacErr;           
            %end;            

        %put NOTE:[PXL] 7) Check Input Parameter var_terms as coded variable names in data_and_ascii_file_name (should be terms seperated by a space);
            %if %str("&var_terms") = %str("null") or %str("&var_terms") = %str("") %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input parameter var_terms does not have any values: &var_terms;
                %goto MacErr;                 
            %end;

        %put NOTE:[PXL] 8) Check Input Parameter path_listings_out is a valid path;
            %if %str("&path_listings_out") = %str("null") %then %do;
                * If not set, use global macro PATH_LISTINGS if exists;
                proc sql noprint;
                    select count(*) into: exists
                    from sashelp.vmacro
                    where scope = "GLOBAL"
                          and name = "PATH_LISTINGS";
                quit;
                %if %eval(&exists = 0) %then %do;
                    * Global macro not found, exit macro;
                    %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter path_listings_out is null and global macro PATH_LISTINGS not found;
                    %goto MacErr;                   
                %end;
                %else %do;
                    * Global macro found, use it;
                    %let path_listings_out = &PATH_LISTINGS/current;
                %end;
            %end;

            %if not %sysfunc(fileexist(&path_listings_out)) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter path_listings_out is not a valid directory: &path_listings_out;
                %goto MacErr;           
            %end;

            %put NOTE:[PXL] path_listings_out = &path_listings_out;  

        %put NOTE:[PXL] 9) Check run in SAS92 or SAS93, will not work in SAS91;
            %if %str("&SYSVER") = %str("9.1") %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: SAS version must be 9.2 or 9.3: &SYSVER;
                %goto MacErr; 
            %end;

        %put NOTE:[PXL] 10) Check Input Parameter path_metadata is a valid path;
            %if not %sysfunc(fileexist(&path_metadata)) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter path_metadata is not a valid directory: &path_metadata;
                %goto MacErr;           
            %end;

            %put NOTE:[PXL] path_metadata = &path_metadata;  

        %put NOTE:[PXL] 11) Check Input parameter path_metadata/MEDDRA_REPORTING.dat does not exist;
            %if not %sysfunc(fileexist(&path_metadata/MEDDRA_REPORTING.dat)) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter path_metadata/MEDDRA_REPORTING.dat is not a valid file: &path_metadata/MEDDRA_REPORTING.dat;
                %goto MacErr;           
            %end;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Process Input Parameter var_terms;
    %put NOTE:[PXL] ***********************************************************************;

        * Get list of parameter var_terms
          Example ..., var_terms=AETERM AETERM1 AETERM2);
        %let total = ;
        data null;
            flag=0;
            do i=1 by 1 until(flag=1);
                call symput(cats('var', i), scan("&var_terms", i, ' '));
                if scan("&var_terms", i, ' ') = " " then flag=1;
                call symput('total', put(i-1, 8.));
            end;
        run;
        
        * Display total and list of parameter var_terms in log;
        %put NOTE:[PXL] Total var_terms= %left(%trim(&total));
        %put NOTE:[PXL] var_terms:;
        %do i=1 %to &total;
            %put NOTE:[PXL] var&i= &&var&i;
        %end;

        * Verify var_terms each exist in the SAS dataset;
        %do i=1 %to &total;
            proc sql noprint;
                select count(*) into: exists 
                from sashelp.vcolumn
                where libname = "%upcase(&lib_download)"
                      and upcase(memname) = "%upcase(&data_and_ascii_file_name)"
                      and upcase(name) = "%upcase(&&var&i)";
            quit;
            
            %if %eval(&exists = 0) %then %do;
                %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Input Parameter var_terms lists a term that does not exist: &&var&i;
                %goto MacErr;
            %end;            
        %end;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Readin ASCII Text File;
    %put NOTE:[PXL] ***********************************************************************;

        * Readin the ASCII file;
        filename infile "&path_ascii_file./evw_&data_and_ascii_file_name..txt" termstr=CRLF;
        
        %put NOTE:[PXL] Read in text file &path_ascii_file./evw_&data_and_ascii_file_name..txt;
        proc sql noprint;
            select count(*) into: exists 
            from &lib_download..&data_and_ascii_file_name;
        quit;
        %put NOTE:[PXL] &lib_download..&data_and_ascii_file_name Number of Obs: %left(%trim(&exists));

        %if %eval(&exists > 0) %then %do;
            * Only read in if has 1 or more records;
            proc import datafile= infile
                dbms= dlm out= &data_and_ascii_file_name._coded replace;
                delimiter= '|';
                getnames= yes;
                guessingrows= 1000;
                datarow= 2;
            run;

            * Check length greater than 300;
            data _null_;
                set &data_and_ascii_file_name._coded;
                %do i=1 %to &total;
                    if length(&&var&i) > 300 then do;
                        put "%str(WARN)ING:[PXL] &merge_coded_macro_name: Variable &&var&i has a length of data greater than 300";
                    end;
                %end;
            run;
		
            %put NOTE:[PXL] Modify length of coded data to 300;
            proc sql noprint;
                alter table &data_and_ascii_file_name._coded 
                    modify 
                    %do i=1 %to &total;
                        &&var&i.._Enc_TERM char(300),
                        &&var&i.._Enc_CODE char(300),
                        &&var&i.._Enc_TYPE char(300),
                        &&var&i.._Enc_CAT1 char(300),
                        &&var&i.._Enc_CAT2 char(300),
                        &&var&i.._Enc_CAT3 char(300),
                        &&var&i.._Enc_CAT4 char(300),
                        &&var&i.._Enc_CAT5 char(300),
                        &&var&i.._Enc_CAT6 char(300),
                        &&var&i.._Enc_CAT7 char(300),
                        &&var&i.._Enc_CAT8 char(300),
                        &&var&i.._Enc_CAT9 char(300)

                        %if &i < &total %then %do; , %end;
                    %end;
                    ;
            quit;
        %end;
        %else %do;
            * No obs, create empty coded vars;
            data coded_vars;
                %do i=1 %to &total;
                    length &&var&i.._Enc_TERM $300.;
                    length &&var&i.._Enc_CODE $300.;
                    length &&var&i.._Enc_TYPE $300.;
                    length &&var&i.._Enc_CAT1 $300.;
                    length &&var&i.._Enc_CAT2 $300.;
                    length &&var&i.._Enc_CAT3 $300.;
                    length &&var&i.._Enc_CAT4 $300.;
                    length &&var&i.._Enc_CAT5 $300.;
                    length &&var&i.._Enc_CAT6 $300.;
                    length &&var&i.._Enc_CAT7 $300.;
                    length &&var&i.._Enc_CAT8 $300.;
                    length &&var&i.._Enc_CAT9 $300.;

                    &&var&i.._Enc_TERM = ''; 
                    &&var&i.._Enc_CODE = ''; 
                    &&var&i.._Enc_TYPE = ''; 
                    &&var&i.._Enc_CAT1 = ''; 
                    &&var&i.._Enc_CAT2 = ''; 
                    &&var&i.._Enc_CAT3 = ''; 
                    &&var&i.._Enc_CAT4 = ''; 
                    &&var&i.._Enc_CAT5 = ''; 
                    &&var&i.._Enc_CAT6 = ''; 
                    &&var&i.._Enc_CAT7 = ''; 
                    &&var&i.._Enc_CAT8 = ''; 
                    &&var&i.._Enc_CAT9 = ''; 
                %end;
                delete;
            run;
        %end;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Reading MEDDRA_REPORTING DAT File;
    %put NOTE:[PXL] ***********************************************************************;
        
        %put NOTE:[PXL] Read in DAT file &path_metadata./MEDDRA_REPORTING.dat;		    
        data meddra_reporting;
        infile "&path_metadata/MEDDRA_REPORTING.dat" delimiter='|' missover dsd termstr=crlf lrecl=32767;

            informat 
                LLT_CODE 8. 
                LLT_NAME $300. 
                LLT_CURRENCY $1. 
                PT_CODE 8. 
                PT_NAME $300. 
                HLT_CODE 8. 
                HLT_NAME $300. 
                HLGT_CODE 8. 
                HLGT_NAME $300. 
                SOC_CODE 8. 
                SOC_NAME $300. 
                SOC_ABBREV $5. 
                PRIMARY_SOC_FG $1. 
                PT_SOC_CODE 8. 
                _INTL_SORT_ORDER 5.
                ;
            format   
                LLT_CODE 8. 
                LLT_NAME $300.  
                LLT_CURRENCY $1. 
                PT_CODE 8. 
                PT_NAME $300. 
                HLT_CODE 8. 
                HLT_NAME $300. 
                HLGT_CODE 8. 
                HLGT_NAME $300. 
                SOC_CODE 8. 
                SOC_NAME $300. 
                SOC_ABBREV $5. 
                PRIMARY_SOC_FG $1. 
                PT_SOC_CODE 8. 
                _INTL_SORT_ORDER 5.
                ;
            input    
                LLT_CODE 
                LLT_NAME $ 
                LLT_CURRENCY $ 
                PT_CODE 
                PT_NAME $ 
                HLT_CODE 
                HLT_NAME $ 
                HLGT_CODE  
                HLGT_NAME $ 
                SOC_CODE 
                SOC_NAME $ 
                SOC_ABBREV $ 
                PRIMARY_SOC_FG $ 
                PT_SOC_CODE 
                _INTL_SORT_ORDER
                ; 
        run;
        
    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Reading WHO_DRUG_REPORTING_ATC DAT File;
    %put NOTE:[PXL] ***********************************************************************;
        
        %put NOTE:[PXL] Read in DAT file &path_metadata./WHO_DRUG_REPORTING_ATC.dat;		    
        
        data whodrug_reporting;
        infile "&path_metadata/WHO_DRUG_REPORTING_ATC.dat" 
            delimiter='|' missover dsd termstr=crlf lrecl=32767;
            informat
                DRUG_CODE   $11.
                DRUG_NAME   $80.
                SE_CODE     $11.
                SE_NAME     $80.
                ATC_5_CODE  $10.
                ATC_5_TEXT  $50.
                ATC_4_CODE  $10.
                ATC_4_TEXT  $50.
                ATC_3_CODE  $10.
                ATC_3_TEXT  $50.
                ATC_2_CODE  $10.
                ATC_2_TEXT  $50.
                ATC_1_CODE  $10.
                ATC_1_TEXT  $50.
                ;
            length
                DRUG_CODE   $11.
                DRUG_NAME   $80.
                SE_CODE     $11.
                SE_NAME     $80.
                ATC_5_CODE  $10.
                ATC_5_TEXT  $50.
                ATC_4_CODE  $10.
                ATC_4_TEXT  $50.
                ATC_3_CODE  $10.
                ATC_3_TEXT  $50.
                ATC_2_CODE  $10.
                ATC_2_TEXT  $50.
                ATC_1_CODE  $10.
                ATC_1_TEXT  $50.
                ;
                
            input
                DRUG_CODE   $
                DRUG_NAME   $
                SE_CODE     $
                SE_NAME     $
                ATC_5_CODE  $
                ATC_5_TEXT  $
                ATC_4_CODE  $
                ATC_4_TEXT  $
                ATC_3_CODE  $
                ATC_3_TEXT  $
                ATC_2_CODE  $
                ATC_2_TEXT  $
                ATC_1_CODE  $
                ATC_1_TEXT  $
                ;
                
            ATC_5_TEXT = upcase(ATC_5_TEXT);
        run;


    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Create Macro Variables CODED as List of Terms;
    %put NOTE:[PXL] ***********************************************************************;
        *% 1) Check if MEDDRA or WHODRUG
           2) Read in &path_metadata/MEDDRA_REPORTING.dat
           3) Modify to previous CODE-NAME format
           4) Set value to CODED macro variable;

      	*% 1) Check if MEDDRA or WHODRUG;
        %let DictType = ;
        %if %eval(&exists > 0) %then %do;
            %let nmeddra = 0;
            %let nwhodrug = 0;
            proc sql noprint;
                select count(distinct &&var1._Enc_TERM) into:nmeddra
                from &data_and_ascii_file_name._coded
                where upcase(&&var1._Enc_TERM) in (
                                    select distinct upcase(llt_name)
                                    from meddra_reporting
                                  )
                ;
                select count (distinct &&var1._Enc_TERM) into:nwhodrug
                from &data_and_ascii_file_name._coded
                where upcase(&&var1._Enc_TERM) in (
                                    select distinct upcase(DRUG_NAME)
                                    from whodrug_reporting
                                  )
                ;
            quit;
                
            %put ***************************************;
            %put * NMEDDRA = &nmeddra;
            %put * NWHODRUG = &nwhodrug;
            %put ***************************************;
            
            %if %eval(&nmeddra ge &nwhodrug) %then %do;
                %let DictType=LLT;
            %end;
            %else %do;
                %let DictType = WHODRUG;
            %end;
                
        %end;
      	
      	*% 2) Read in &path_metadata/MEDDRA_REPORTING.dat;
      	%if &DictType=LLT %then %do;
            %put NOTE:[PXL] Dicttype = MEDDRA;
            *% 3) Modify to previous CODE-NAME format;
            data meddra_reporting(DROP=_LLT_CODE);	
            length LLT_CODE SOC_Code_Name HLGT_Code_Name HLT_Code_Name PT_Code_Name $300;
                    set meddra_reporting(rename=(LLT_CODE=_LLT_CODE));
                    LLT='LLT';
                    LLT_CODE=put(_LLT_CODE,8.);
                    SOC_Code_Name=cats(cats(SOC_CODE,'-'),SOC_NAME);
                    HLGT_Code_Name=cats(cats(HLGT_CODE,'-'),HLGT_NAME);
                    HLT_Code_Name=cats(cats(HLT_CODE,'-'),HLT_NAME);
                    PT_Code_Name=cats(cats(PT_CODE,'-'),PT_NAME);
                    DummyVar='';
            run;
      	
            %* 4) Set value to CODED macro variable;
            %let coded=;
            %let coded_ascii=;
            %let coded_meddra=;
            %put NOTE:[PXL] Total Terms=%left(%trim(&total));
            %do i=1 %to &total;  
                %let coded_meddra&i=; 
            %end;
            %do i=1 %to &total;
                %* these two are taken from ASCII file;
                %let coded_ascii = &coded_ascii c.&&var&i.._Enc_Term length=300 label="&&var&i.._Enc_Term"; 

                %let coded_meddra&i = &&coded_meddra&i c.LLT_NAME length=300 label="", ;
                %let coded_meddra&i = &&coded_meddra&i c.LLT_CODE, ;
                %let coded_meddra&i = &&coded_meddra&i c.LLT as &&var&i.._Enc_TYPE length=300 label="&&var&i.._Enc_TYPE", ;
                %let coded_meddra&i = &&coded_meddra&i c.LLT_CODE as &&var&i.._Enc_CODE label="&&var&i.._Enc_CODE", ;
                %let coded_meddra&i = &&coded_meddra&i c.SOC_Code_Name as &&var&i.._Enc_CAT1 length=300 label="&&var&i.._Enc_CAT1", ;
                %let coded_meddra&i = &&coded_meddra&i c.HLGT_Code_Name as &&var&i.._Enc_CAT2 length=300 label="&&var&i.._Enc_CAT2", ;
                %let coded_meddra&i = &&coded_meddra&i c.HLT_Code_Name as &&var&i.._Enc_CAT3 length=300 label="&&var&i.._Enc_CAT3", ;
                %let coded_meddra&i = &&coded_meddra&i c.PT_Code_Name as &&var&i.._Enc_CAT4 length=300 label="&&var&i.._Enc_CAT4", ;
                %let coded_meddra&i = &&coded_meddra&i c.DummyVar as &&var&i.._Enc_CAT5 length=300 label="&&var&i.._Enc_CAT5", ;
                %let coded_meddra&i = &&coded_meddra&i c.DummyVar as &&var&i.._Enc_CAT6 length=300 label="&&var&i.._Enc_CAT6", ;
                %let coded_meddra&i = &&coded_meddra&i c.DummyVar as &&var&i.._Enc_CAT7 length=300 label="&&var&i.._Enc_CAT7", ;
                %let coded_meddra&i = &&coded_meddra&i c.DummyVar as &&var&i.._Enc_CAT8 length=300 label="&&var&i.._Enc_CAT8", ;
                %let coded_meddra&i = &&coded_meddra&i c.DummyVar as &&var&i.._Enc_CAT9 length=300 label="&&var&i.._Enc_CAT9" ;                   
                %if &i < &total %then %let coded_ascii = &coded_ascii,;
                
            %end; 
            %do i=1 %to &total;  
            	 %let coded_meddra = &coded_meddra &&coded_meddra&i; 
            	 %if &i = &total %then %let coded=&coded_ascii, &coded_meddra;	
            %end;
            
        %end;
        
      	%else %if &DictType=WHODRUG %then %do;
            %put NOTE:[PXL] Dicttype = WHODRUG;
            %* ************ Temporarily deal with multiple records per drug code ********;
            proc sort data=whodrug_reporting;
                by drug_code drug_name ATC_1_CODE;
            run;
            
            
            *% 3) Modify to previous CODE-NAME format;
            data whodrug_reporting;	
                length ATC_1_Code_Name ATC_2_Code_Name ATC_3_Code_Name 
                        ATC_4_Code_Name ATC_5_Code_Name SE_CODE_NAME $300;

                set whodrug_reporting;
                
                %* ************ Temporarily deal with multiple records per drug code ********;
                by drug_code drug_name;
                if last.drug_code;
                
                
                %* Pad codes with leading spaces so hyphens are always in set location;
                ATC_1_CODE = reverse(substr(reverse("        " || strip(ATC_1_CODE)),1,1));
                ATC_2_CODE = reverse(substr(reverse("        " || strip(ATC_2_CODE)),1,3));
                ATC_3_CODE = reverse(substr(reverse("        " || strip(ATC_3_CODE)),1,4));
                ATC_4_CODE = reverse(substr(reverse("        " || strip(ATC_4_CODE)),1,5));
                ATC_5_CODE = reverse(substr(reverse("        " || strip(ATC_5_CODE)),1,8));
                %* Trim longer SE_CODE values to last 8 characters;
                /*SE_CODE = reverse(substr(reverse(strip(SE_CODE)),1,8));*/
                SE_CODE = substr(SE_CODE,1,8);
                
                if strip(ATC_1_CODE) ne "" then ATC_1_CODE_NAME = catt(ATC_1_CODE,"-",ATC_1_TEXT);
                if strip(ATC_2_CODE) ne "" then ATC_2_CODE_NAME = catt(ATC_2_CODE,"-",ATC_2_TEXT);
                if strip(ATC_3_CODE) ne "" then ATC_3_CODE_NAME = catt(ATC_3_CODE,"-",ATC_3_TEXT);
                if strip(ATC_4_CODE) ne "" then ATC_4_CODE_NAME = catt(ATC_4_CODE,"-",ATC_4_TEXT);
                /*if strip(ATC_5_CODE) ne "" then ATC_5_CODE_NAME = catt(ATC_5_CODE,"-",ATC_5_TEXT);*/
                if strip(ATC_5_CODE) ne "" then ATC_5_CODE_NAME = catt(SE_CODE,"-",ATC_5_TEXT);
                if strip(SE_CODE) ne "" then SE_CODE_NAME = catt(SE_CODE,"-",SE_NAME);
                
                DummyVar='';
            run;
      	
            %* 4) Set value to CODED macro variable;
            %let coded=;
            %let coded_ascii=;
            %let coded_meddra=;
            %let coded_whodrug=;
            %put NOTE:[PXL] Total Terms=%left(%trim(&total));
            %do i=1 %to &total;  
                %let coded_meddra&i=; 
                %let coded_whodrug&i=; 
            %end;
            %do i=1 %to &total;
                %* these two are taken from ASCII file;
                %let coded_ascii = &coded_ascii c.&&var&i.._Enc_Term length=300; 
                %if &i < &total %then %let coded_ascii = &coded_ascii,;
                
                %let coded_whodrug&i = &&coded_whodrug&i c.DRUG_NAME,;
                %let coded_whodrug&i = &&coded_whodrug&i c.DRUG_CODE as &&var&i.._Enc_CODE length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i "TRADE" as &&var&i.._Enc_TYPE length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.ATC_1_CODE_NAME as &&var&i.._Enc_CAT1 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.ATC_2_CODE_NAME as &&var&i.._Enc_CAT2 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.ATC_3_CODE_NAME as &&var&i.._Enc_CAT3 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.ATC_4_CODE_NAME as &&var&i.._Enc_CAT4 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.ATC_5_CODE_NAME as &&var&i.._Enc_CAT5 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.SE_CODE_NAME as &&var&i.._Enc_CAT6 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.DummyVar as &&var&i.._Enc_CAT7 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.DummyVar as &&var&i.._Enc_CAT8 length=300 label="", ;
                %let coded_whodrug&i = &&coded_whodrug&i c.DummyVar as &&var&i.._Enc_CAT9 length=300 label="" ;
            %end; 
            %do i=1 %to &total;  
            	 %let coded_whodrug = &coded_whodrug &&coded_whodrug&i; 
            	 %if &i = &total %then %let coded=&coded_ascii, &coded_whodrug;	
            %end;
        %end;
        
        
	    %else %do; 		
            %put NOTE:[PXL] Dicttype = OTHER;
            * Build sql coded var_terms var list statement for WHODRUG;
            %let coded = ;
            %do i=1 %to &total;
                %let coded = &coded c.&&var&i.._Enc_Term, c.&&var&i.._Enc_CODE,;
                %let coded = &coded c.&&var&i.._Enc_TYPE, c.&&var&i.._Enc_CAT1,;
                %let coded = &coded c.&&var&i.._Enc_CAT2, c.&&var&i.._Enc_CAT3,;
                %let coded = &coded c.&&var&i.._Enc_CAT4, c.&&var&i.._Enc_CAT5,; 
                %let coded = &coded c.&&var&i.._Enc_CAT6, c.&&var&i.._Enc_CAT7,;
                %let coded = &coded c.&&var&i.._Enc_CAT8, c.&&var&i.._Enc_CAT9;
                %if &i < &total %then %let coded = &coded.,;
            %end;
        %end;

        
        %put NOTE:[PXL] Coded Statement= [&coded.];

    %put NOTE:[PXL] ;
    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Check for Non-Printable Characters in Coded var_terms;
    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] ;    

        * Non-printable ascii characters are not allowed in coded raw data due to line breaks in ascii text files
          that will cause coding data not to get merged correctly;
        proc sql noprint;
            select count(*) into :varc_total
            from sashelp.vcolumn
            where libname = "%upcase(&lib_download)"
                  and memname = "%upcase(&data_and_ascii_file_name)"
                  and type = "char";

            select name into :varc_1-:varc_%left(%trim(&varc_total))
            from sashelp.vcolumn
            where libname = "%upcase(&lib_download)"
                  and memname = "%upcase(&data_and_ascii_file_name)"
                  and type = "char";
        quit;

        %if &varc_total > 0 %then %do;
            data temp_bad(keep= PATID SITEKEY ROW EVTORDER FORMNAM GRPNAM VARIABLE POSITION ASCII_CODE VALUE);
                length VARIABLE VALUE $200.;
            set &lib_download..&data_and_ascii_file_name;
                * Cycle through each char variable and check for special characters;
                %do i=1 %to &varc_total;
                    if &&varc_&i ne compress(&&varc_&i,,'wk') then do;
                        VARIABLE = "&&varc_&i";
                        VALUE = &&varc_&i;
                        put "NOTE:[PXL]: Special Characters found: PATID SITEKEY ROW EventOrder FormName GroupName <variable>: " PATID SITEKEY ROW EVTORDER FORMNAM GRPNAM " <&&varc_&i..>";

                        * Find special char position and ASCII code for it;
                        bad_var_length = length(&&varc_&i);
                        do j=1 to bad_var_length;
                            ASCII_CODE = rank(substr(&&varc_&i,j,1));
                            %* put "CYCLE THROUGH &&varc_&i " j ASCII_CODE;
                            if 0 <= rank(substr(&&varc_&i,j,1)) <= 31
                               or 127 <= rank(substr(&&varc_&i,j,1)) then do;

                                POSITION = j;
                                output temp_bad;
                            end;
                        end;                        
                    end;
                %end;
            run;
        %end;

        %let cnt = 0;
        proc sql noprint;
            select count(*) into: cnt
            from temp_bad;
        quit;
        %put NOTE:[PXL] Special Characters Found: %left(%trim(&cnt));

        %if &cnt > 0 %then %do;
            * Remove bad records (the overlapped records that special char cause);
            data &data_and_ascii_file_name._coded &data_and_ascii_file_name._coded_del;
            set &data_and_ascii_file_name._coded;
                if missing(PatientIdentity) 
                   or missing(SITEKEY)
                   or missing(DATAROW)
                   or missing(EventOrder)
                   or missing(FormName)
                   or missing(GroupName) then do;
                    output &data_and_ascii_file_name._coded_del;
                end;
                else if missing(input(SITEKEY,?? 8.)) then do;
                    * Special char can cause overlapping data that will not merge back correctly;
                    output &data_and_ascii_file_name._coded_del;
                end;
                else if missing(input(DATAROW,?? 8.)) then do;
                    * Special char can cause overlapping data that will not merge back correctly;
                    output &data_and_ascii_file_name._coded_del;
                end;
                else do;
                    output &data_and_ascii_file_name._coded;
                end;
            run;

            * Output listing of bad data;
                %let listName = &path_listings_out/listing_mu_datalabs_merge_coded_&data_and_ascii_file_name..pdf;

                %put NOTE:[PXL]: -----------------------------------------------------------;
                %put NOTE:[PXL]: Special characters are not allowed in coded records. These will cause the evw_&data_and_ascii_file_name..txt;
                %put NOTE:[PXL]: file to split records and coded data will not be appended to the SAS dataset.;
                %put NOTE:[PXL]: Contact the PCDA to submit queries to correct these before coding data can be appended correctly.;
                %put NOTE:[PXL]: See listing created for details: &listName;
                %put NOTE:[PXL]: -----------------------------------------------------------;            

                * Output pfescrf_auto use text;
                %put NOTE:[PXL] PFESCRF_AUTO: %left(%trim(&cnt)) listing_mu_datalabs_merge_coded_&data_and_ascii_file_name..pdf;

                * Create PDF logcheck results file;
                ods listing close;
                ods pdf file="&listName";
                    data _null_;
                        file print ps=73 ls=172 notitles;
                        put "Purpose:";
                        put "List special characters found in raw SAS datasets used for WHODRUG/MEDDRA coding.";
                        put ;
                        put "Cause:";
                        put "Special characters (such as a carriage return) cause the corresponding ASCII text raw files extracted from DataLabs to split";
                        put "records. This prevents the WHODRUG/MEDDRA coded data to be appended to the corresponding SAS dataset."; 
                        put ;
                        put "Remediation:";
                        put "Contact the PCDA to submit queries for users to delete special characters used.  Because this is raw data directly out of";
                        put "DataLabs, there is no method to correct in SAS mapping.";
                        put "See http://www.asciitable.com/ for Dec=ASCII Code table.";
                        put ;
                        put "---------------------------------------------------------------------------------------";
                        put "Run By: %upcase(&sysuserid)";
                        put "Run On: &merge_coded_macro_RunDateTime";
                        put ;
                        put "Run Macro Name: &merge_coded_macro_name";
                        put "Run Macro Version: &merge_coded_macro_version";
                        put "Run Macro Version Date: &merge_coded_macro_version_Date";
                        put "Run Macro Location: &merge_coded_macro_path";
                        put ;
                        put "---------------------------------------------------------------------------------------";
                        put "Source Data: &path_ascii_file./evw_&data_and_ascii_file_name..txt";
                        put ;
                        put "Output Listing: &listName";
                        put ;
                        put "Total Issues Found: %left(%trim(&cnt))";
                        put ;
                        put "---------------------------------------------------------------------------------------";
                        put "Issue details listed on next page";
                        put ;
                    run;

                    proc report data = temp_bad nowd; 
                        column OBS PATID SITEKEY FORMNAM EVTORDER GRPNAM ROW VARIABLE POSITION ASCII_CODE VALUE; 
                        define OBS / computed;
                        compute OBS;
                            DSOBS + 1;
                            OBS = DSOBS;
                        endcompute;
                    run;

                ods pdf close;
                ods listing;

                %let merge_coded_macro_output = Created special char listing &listName., ;
        %end;

    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Merge Coded Data to Output;
    %put NOTE:[PXL] ***********************************************************************;

        proc sql noprint;
            select count(*) into: exists 
            from &lib_download..&data_and_ascii_file_name;
        quit;
        %put NOTE:[PXL] &lib_download..&data_and_ascii_file_name Number of Obs: %left(%trim(&exists));

        %if %eval(&exists > 0) %then %do;
            %put NOTE:[PXL] Remove formats and informats;
                proc datasets lib=work memtype=data nolist;
                    modify &data_and_ascii_file_name._coded;
                    attrib _all_ format=;
                    attrib _all_ informat=;
                run; 
                
            %let merge_coded_macro_output = &merge_coded_macro_output Appended Coded data to &lib_download..&data_and_ascii_file_name;

            %* MERGE ASCII FILE WITH RAW SAS DATA;
            proc sql noprint;
                create table _temp as
                select a.*, &coded_ascii
                from 
                    &lib_download..&data_and_ascii_file_name as a 
                    left outer join 
                    &data_and_ascii_file_name._coded as c
                on C.PatientIdentity =A.PATID
                    and input(C.SITEKEY, 8.) =A.SITEKEY
                    and input(C.DATAROW, 8.) =A.ROW
                    and C.EventOrder=A.EVTORDER
                    and C.FormName=A.FORMNAM
                    and C.GroupName=A.GRPNAM;
            quit;

            
            %if &DictType = LLT %then %do; 
                %* Handle MEDDRA data;
                %* Merge coded XXXX_ENC_TERM and XXXX_ENC_CODE from ASCII file into SAS dataset;
                data _temp0;
                    set _temp;
                run;

                %* Create different sql statements to read data from the meddra_reporting table based on number of terms passed in the macro call;
                %do i=1 %to &total;
                    proc sql;
                        create table meddra_reporting&i as
                        select c.PRIMARY_SOC_FG, &&coded_meddra&i 
                        from meddra_reporting as c;
                    quit;
                %end;

                %* Merge remaining coded fields from MEDDRA_REPORTING file into the raw SAS dataset;
                %do i=1 %to &total;	
                    proc sql noprint;
                        create table _temp&i as						
                        select a.*, c.*
                        from _temp0 as a left outer join meddra_reporting&i as c 
                        on upcase(strip(C.llt_name)) = upcase(strip(A.&&var&i.._Enc_Term))
                            /*and C.llt_code=A.&&var&i.._Enc_Code*/
                            and C.PRIMARY_SOC_FG='Y';	
                    quit;

                    %put VAR I: A.&&var&i.._Enc_Term;

                    proc sort data=_temp&i out=_temp&i;
                        by  patid sitekey row evtorder formnam grpnam;
                    run;
                %end;	

                %do i=1 %to &total;             
                    %if %eval(&i)=1 %then %do;  
                        data _temp;
                        set _temp&i;
                        run;
                    %end;
                    %else %do;
                        data _temp;
                            merge _temp _temp&i;
                            by patid sitekey row evtorder formnam grpnam;
                        run;
                    %end;
                %end;

                %* drop the variables which were needed only for merging;
                data _temp(drop=llt_name llt_code primary_soc_fg);
                    set _temp;
                run;	
        	%end; %* End IF &DictType = LLT ;
            
            %else %if &DictType = WHODRUG %then %do; 
                %* Handle WHODRUG data;
                %* Merge coded XXXX_ENC_TERM and XXXX_ENC_CODE from ASCII file into SAS dataset;
                data _temp0;
                    set _temp;
                run;

                %* Create different sql statements to read data from the whodrug_reporting table based on number of terms passed in the macro call;
                %do i=1 %to &total;
                    proc sql;
                        create table whodrug_reporting&i as
                        select &&coded_whodrug&i 
                        from whodrug_reporting as c;
                    quit;
                %end;

                %* Merge remaining coded fields from WHODRUG_REPORTING file into the raw SAS dataset;
                %do i=1 %to &total;	
                    proc sql noprint;
                        create table _temp&i as						
                        select a.*, c.*
                        from _temp0 as a left outer join whodrug_reporting&i as c 
                        on upcase(strip(C.drug_name)) = upcase(strip(A.&&var&i.._Enc_Term))
                        ;	
                    quit;

                    proc sort data=_temp&i out=_temp&i;
                        by  patid sitekey row evtorder formnam grpnam;
                    run;
                %end;	

                %do i=1 %to &total;				
                    %if %eval(&i)=1 %then %do;	
                        data _temp;
                            set _temp&i;
                        run;
                    %end;
                    %else %do;									
                        data _temp;
                            merge _temp _temp&i;
                            by patid sitekey row evtorder formnam grpnam;
                        run;
                    %end;
                %end;			  			

                %* drop the variables which were needed only for merging;
                data _temp(drop=drug_name);
                    set _temp;
                run;	
            %end;
            
        %end; %* End of the %eval(&exists > 0) if statement;		
        %else %do;
            %let merge_coded_macro_output = &merge_coded_macro_output Appended Blank Coded data to &lib_download..&data_and_ascii_file_name;
            data _temp;
                set &lib_download..&data_and_ascii_file_name coded_vars;
            run;  
        %end;

        data &lib_download..&data_and_ascii_file_name;
            set _temp;
        run;        
    
    %put NOTE:[PXL] ***********************************************************************;
    %put NOTE:[PXL] Macro End;
    %put NOTE:[PXL] ***********************************************************************;
        %goto MacEnd;
        %MacErr:;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %put %str(ERR)OR:[PXL] &merge_coded_macro_name: Abnormal end to macro;
        %put %str(ERR)OR:[PXL] &merge_coded_macro_name: See log for details;
        %put %str(ERR)OR:[PXL] ---------------------------------------------------;
        %let GMPXLERR=1;
        %let merge_coded_macro_output = None, Issue Found;

        %MacEnd:;
        title;
        footnote;
        OPTIONS missing=.;
        options quotelenmax;
        option PRINTERPATH=""; * Reset to pre-run;

        %macro delcat(catn=null);
            proc sql noprint;
                select count(*) into: exists
                from sashelp.vcatalg
                where libname = "WORK"
                      and memname = "%upcase(&catn)";
            quit;
            %if %eval(&exists > 0) %then %do;
                proc catalog catalog=&catn kill; run; quit;
                %put NOTE:[PXL] Deallocated category &catn;
            %end;            
        %mend delcat;
        %delcat(catn=PARMS);   
        
        %macro delmac(wds=null);
            %if %sysfunc(exist(&wds)) %then %do; 
                proc datasets lib=work nolist; delete &wds; quit; run; 
            %end; 
        %mend delmac;
        %delmac(wds=TEMP_BAD);              
        %delmac(wds=_TEMP);
        %delmac(wds=&data_and_ascii_file_name._coded);
        %delmac(wds=&data_and_ascii_file_name._coded_del);
        %delmac(wds=coded_vars);
        %delmac(wds=MEDDRA_REPORTING);
        %delmac(wds=WHODRUG_REPORTING);
        %delmac(wds=_TEMP0);
        %do i=1 %to &total; 
            %delmac(wds=MEDDRA_REPORTING&i);
            %delmac(wds=WHODRUG_REPORTING&i);
            %delmac(wds=_TEMP&i);
        %end;       

        %put INFO:[PXL]----------------------------------------------;
        %put INFO:[PXL] &merge_coded_macro_name: Macro Completed; 
        %put INFO:[PXL] Output: &merge_coded_macro_output;
        %put INFO:[PXL]----------------------------------------------;
    
%mend mu_datalabs_merge_coded;